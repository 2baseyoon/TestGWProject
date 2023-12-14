<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<nav class="lnb">
	<h2 class="gnb_left_tit" style="cursor: pointer;"><span class="gnb_tit" onclick="leftmenu_goToPageMain(); return false"></span></h2>
	<div>
		<label>
			<spring:message code="Cache.lbl_Domain" />&nbsp;
			<select id="domainCodeSelectBox" onchange="javascript:changeCompany(this);" style="width: 150px;"></select>
		</label>
	</div>
	<ul id="lnb_con" class="lnb_list">
	</ul>
</nav>

<style>
	.contextMenuItem.plus, .contextMenuItem.minus{
		text-indent : 0;
		margin : 0;
		width : initial;
	}
	
	#organizationTree a, #organizationTreeGroup a,.AXTreeBody a {
		padding : 1px 0px !important;
	}
	
	.AXTree_none .AXTreeScrollBody .AXTreeBody{
		position: relative;
		max-height: 170px;
	}
</style>

<script type="text/javascript">
	var domainCode = CFN_GetQueryString("domainCode") == 'undefined' ? "" : CFN_GetQueryString("domainCode");
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var myDeptTree = new coviTree();
	var myOrgTree = new coviTree();
	var groupOrgTree = new coviTree();
	var isUser = false;
	
	$.urlParam = function(name){
		var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
		if(results != null) {
			return results[1] || 0;
		} else {
			return null;
		}
	}
	
	//ready
	leftInit();
	
	function leftInit(){	
		if ($("#left .gnb_tit").text() == "") {
			$.each(headerdata, function(idx, el){
				if(el.BizSection == CFN_GetQueryString("CLBIZ")) { $("#left .gnb_tit").text(el.DisplayName); return; }
			});	
		}	
		
		if(domainCode == ""){
			domainCode = Common.getSession("DN_Code");
		}

		$("#domainCodeSelectBox").coviCtrl("setSelectOption", "/covicore/admin/orgmanage/getdomainlist.do");	
		if (CFN_GetQueryString('domainCode') != 'undefined' && CFN_GetQueryString('domainCode') != '') { $("#domainCodeSelectBox").val(CFN_GetQueryString('domainCode')); }
		else { $("#domainCodeSelectBox").val(domainCode); }
		
		setMenuControl();
	}
	
	function setMenuControl(){	
		
		//left menu 그리는 부분
		var opt = {
				lang : "ko",
				isPartial : "true"
		};

		var orgLeft = new CoviMenu(opt);
		
		if(leftData.length != 0){
			orgLeft.render('#lnb_con', leftData, 'adminLeft');
			if(loadContent == 'true') {
				var $first = $("#lnb_con li").first().find("a");
				if($first) {
					$first.click();
				}
			}
		}
		
		$("#lnb_con").find("li[data-menu-alias=user]").after(
			"<li class='list_1dep'>" + 
			"	<div id='organizationTree' class='treeList'></div>" + 
			"	<div id='deptuserSearch' style='padding: 10px 0px; width: 100%; cursor: pointer;' onclick='clickSearch();'><spring:message code="Cache.lbl_search" /></div>" + 
			"</li>"
		);
		
		$("#lnb_con").find("li[data-menu-alias=group]").after(
			"<li class='list_1dep'><div id='organizationTreeGroup' class='treeList'></div></li>"
		);		
		
		setTreeConfig();
		setDeptTreeData();
		setGroupTreeData();
		
		if(loadContent == 'true'){
    		CoviMenu_GetContent('/covicore/layout/organization_organizationadminhome.do?CLSYS=core&CLMD=admin&CLBIZ=Organization');	
    	}
	}
	
	function setTreeConfig(){
		if($("#organizationTree").length > 0) {
			myDeptTree.setConfig({
				targetID : "organizationTree",	
				theme: "AXTree_none",	
				xscroll:true,
				width:"auto",
				showConnectionLine:true,		// 점선 여부
				relation:{
					parentKey: "MemberOf",		// 부모 아이디 키
					childKey: "GroupCode"		// 자식 아이디 키
				},
				persistExpanded: false,			// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
				persistSelected: false,			// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
				colGroup:[{
					key: "GroupDisplayName",		
					align: "left",	
					indent: true,				
					getIconClass: function(){	// indent 속성 정의된 대상에 아이콘을 지정 가능
						return '';
					},
					formatter:function(){
						var anchorName = $('<a />').attr('id', 'folder_item_'+this.item.GroupCode);
						anchorName.text(this.item.GroupDisplayName);
						if(this.item.url != "" && this.item.url != undefined){
							anchorName.attr('href', this.item.url);
						}
						var str = anchorName.prop('outerHTML');
						return str;
					}
				}],						
				body:{
					onexpand:function(idx, item){ 
						if(item.isLoad == "N" && item.haveChild == "Y"){ //하위 항목이 로드가 안된 상태
							myDeptTree.updateTree(idx, item, {isLoad: "Y"});
							getChildrenData(idx, item);
						}
					}
				}
			}); 
		}
		
		if($("#organizationTreeGroup").length > 0) {
			groupOrgTree.setConfig({
				width:"auto",
				xscroll:true
			}); 
		}
	}
	function leftmenu_goToPageMain(){
		location.href = "/covicore/layout/organization_organizationadminhome.do?CLSYS=core&CLMD=admin&CLBIZ=Organization";
	}
	
	function clickSearch() {
		$(".list_1dep > a").attr("class", "selected");
		$("#deptuserSearch").addClass("selected admin-menu-active");
		CoviMenu_GetContent("/covicore/layout/organization_deptusermanagesearch.do?CLSYS=core&CLMD=admin&CLBIZ=Organization&domainCode=" + $("#domainCodeSelectBox").val() + "&mode=User");
	}
	
	function changeCompany(domain){
		if(domain.value != domainCode){
			setDeptTreeData();
			setGroupTreeData();
			
			var url = location.href.replace(new RegExp(domainCode, "g"),domain.value);
		/*	if(location.pathname.indexOf("group") > -1) {
				getOrgListData($("#domainCodeSelectBox").val(), $("#domainCodeSelectBox").val(), "Company", "group");
			} else {
				getOrgListData($("#domainCodeSelectBox").val(), $("#domainCodeSelectBox").val(), "Company", "deptuser");
			}*/
			CoviMenu_GetContent(location.pathname + location.search.replace(new RegExp(domainCode, "g"), domain.value));
			
			var state = CoviMenu_makeState(url); 
			var title = url; 
			history.pushState(state, '', url);
			CoviMenu_SetState(state)
			
			domainCode = domain.value;
		}
	}

	//tree 데이터 조회
	function setDeptTreeData(){
		if($("#organizationTree").length > 0) {
			$.ajax({		
				url:"/covicore/admin/orgmanage/getInitOrgTreeList.do",
				type:"POST",
				data:{
					"companyCode" : $("#domainCodeSelectBox").val(),
					"groupType" : "dept"
				},
				async:false,
				success:function (data) {
					var List = data.list;
					//바인딩할 Selector, Param, DisplayName, width, align, checkbox, ? )
					myDeptTree.setList(List);				
					myDeptTree.expandAll(1);	
					$(myDeptTree.list).each(function(i,list){
						if(this.IsUse == "N"){
							$("#folder_item_"+this.GroupCode).css("text-decoration","line-through");							
						}						
					});
				},
				error:function (error){
					CFN_ErrorAjax("/covicore/admin/orgmanage/getInitOrgTreeList.do", response, status, error);
				}
			});
		}
	}
	
	//하위 항목 조회
	function getChildrenData(idx, item){		
		$.ajax({
			url:"/covicore/admin/orgmanage/getChildrenData.do",
			type:"POST",
			data:{
				"memberOf" : item.GroupCode,
				"companyCode" : item.CompanyCode,
				"groupType" : "dept"
			},
			async:false,
			success:function (data) {
				if(item.GroupCode != item.CompanyCode){
					myDeptTree.appendTree(idx, item, data.list);				
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/control/getChildrenData.do", response, status, error);
			},
		});
	}
	
	function setGroupTreeData() {
		if($("#organizationTreeGroup").length > 0) {
			$.ajax({
				url:"/covicore/admin/orgmanage/getgrouplist.do",
				type:"POST",
				data:{
					"domain" : $("#domainCodeSelectBox").val(),
					"grouptype" : "group"
				},
				async:false,
				success:function (data) {
					var List = data.list;
					groupOrgTree.setTreeList("organizationTreeGroup", List, "nodeName", "170", "left", false, false);
					groupOrgTree.expandAll(1);			
					$(groupOrgTree.list).each(function(i,list){
						if(this.IsUse == "N"){
							$("#folder_item_"+this.no).css("text-decoration","line-through");							
						}						
					});
						
				},
				error:function (error){
					CFN_ErrorAjax("/covicore/admin/orgmanage/getgrouplist.do", response, status, error);
				}
			});
			groupOrgTree.displayIcon(true);
		}
	}
	
	function clickOpenCloseBtn(obj, type) {
		if(type == 'deptuser') {
			if($(obj).text() == "+") {
				$("#organizationTree").css("display", "block");
				$("#deptuserSearch").css("display", "block");
				$(obj).text("-");
			} else if($(obj).text() == "-") {
				$("#organizationTree").css("display", "none");
				$("#deptuserSearch").css("display", "none");
				$(obj).text("+");
			}
		}
		else if(type == 'group') {
			if($(obj).text() == "+") {
				$("#organizationTreeGroup").css("display", "block");
				$(obj).text("-");
			} else if($(obj).text() == "-") {
				$("#organizationTreeGroup").css("display", "none");
				$(obj).text("+");
			}
		}
	}

	
	function getOrgListData(dn_code, gr_code, group_type, call_type) {
		if(gr_code != "" && group_type != "") {
			if(call_type == 'deptuser') {
				CoviMenu_GetContent("/covicore/layout/organization_deptusermanage.do?CLSYS=core&CLMD=admin&CLBIZ=Organization&domainCode="+dn_code+"&gr_code="+gr_code+"&group_type="+group_type+"&tab_type=dept");
			} else if(call_type == 'group') {
				CoviMenu_GetContent("/covicore/layout/organization_groupmanage.do?CLSYS=core&CLMD=admin&CLBIZ=Organization&domainCode="+dn_code+"&gr_code="+gr_code+"&group_type="+group_type);
			}
		}
	}
</script>