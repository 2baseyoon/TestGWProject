<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<script type="text/javascript">
	var myTree = new coviTree();
	 
	$(document).ready(function(){
		setLeftTree();
		setTreeData();
	});
	
	function setLeftTree(){
		myTree.setConfig({
			targetID : "UserMenuLeftTree",
			theme: "AXTree_none",
			//height:"auto",
			xscroll:false,
			showConnectionLine:true,
			relation:{
				parentKey:"parentcd",
				childKey:"nodeID",
				parentName:"parentnm",
				childName:"nodenm"
			},
			colGroup: [
				{key:"MN_ID", label:"ID", width:"55", align:"left", display:false},
				{key:"SortKey", label:"정렬", width:"50", align:"center", display:false},
				{key:"MenuType", label:"유형", width:"60", align:"center", display:false},
				{
					key:"DisplayName",
					label:"이름",
					width:"200", align:"left",
					indent:true,
					getIconClass: function(){
						var iconName = this.item.iconType;
						return iconName;
					},
					formatter:function(){
						return this.item.DisplayName;
						//return "<u>" + this.item.DisplayName + "</u>";
					},
					tooltip:function(){
						return this.item.DisplayName;
					}
				}
				,{key:"MenuAlias", label:"별칭", width:"80", align:"center", display:false}
				,{key:"Target", label:"대상", width:"70", align:"center", display:false}
				,{key:"PgName", label:"프로그램 이름", width:"80", align:"center", display:false}
				,{key:"ProgramType", label:"종류", width:"60", align:"center", display:false}
				,{key:"RegistDate", label:"등록일 (GMT+9)", width:"100", align:"left", display:false}
			]
		});

		//myTree.setTree(Tree);
	}
	
	function setTreeData(){
		var domain = "";
		$.ajax({
			type:"POST",
			data:{
				"domain" : domain,
				"type" : "LeftMenu" 
			},
			url:"menumanage/getusermenutreedata.do",
			success:function (data) {
				myTree.setTree(data.list);
			},
			error:function (error){
				Common.Error(error.message);
			}
		});
		
		$.ajax({
			type:"POST",
			data:{
				"domain" : domain,
				"type" : "UserMenu" 
			},
			url:"menumanage/getusermenutreedata.do",
			success:function (data) {
				if(typeof myGridTree != "undefined")
					myGridTree.setTree(data.list);
			},
			error:function (error){
				Common.Error(error.message);
			}
		});
	}
</script>

<nav class="lnb">
	<h2 class="gnb_left_tit"><span class="gnb_tit" onclick="">사용자 메뉴 관리</span></h2>
	<div style="float:left;width:201px;">
		<div style="width: 201px;height: 30px;text-align: center;padding-top: 15px">
			<select id="TreeDomain" onchange="setTreeData();">
				<option value="">코비그룹</option>
				<option value="" selected="selected">코비젼</option>
				<option value="">코비건설</option>
				<option value="">코비제약</option>
			</select>
		</div>
		<div id="UserMenuLeftTree" style="min-height:500px;background-color: white;"></div>
	</div>
</nav>