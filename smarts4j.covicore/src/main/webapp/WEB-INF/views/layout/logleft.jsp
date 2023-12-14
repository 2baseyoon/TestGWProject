<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!-- tree css -->
<link rel="stylesheet" type="text/css" href="<c:url value='/resources/css/axisj/arongi/AXTree.css'/>" />

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
			{no:1, nodeName:"접속로그", writer:"tom", type:"0", pno:0},
			{no:2, nodeName:"접속실패로그", writer:"tom", type:"0", pno:0},
			{no:3, nodeName:"에러로그", writer:"tom", type:"0", pno:0},
			{no:4, nodeName:"페이지이동로그", writer:"tom", type:"0", pno:0},
			{no:5, nodeName:"성능로그", writer:"tom", type:"0", pno:0},
			{no:6, nodeName:"사용자정보처리로그", writer:"tom", type:"0", pno:0}
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
-->