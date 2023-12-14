<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>

<div style="margin-bottom: 10px;">
	<label>
		<spring:message code="Cache.lbl_Domain"/>&nbsp;
		<select class="AXSelect" id="selectDomain"></select>
	</label>
	<label>
		사용자/관리자&nbsp;
		<select name="" class="AXSelect" id="selectIsAdmin"></select>
	</label>
	<label>
		<input type="button" value="전체열기" onclick="tree.expandAll();" class="AXButton" />
		<input type="button" value="전체닫기" onclick="tree.collapseAll();" class="AXButton" />				
	</label>
</div>
<div style="height:305px;overflow-y:hidden;" class="admin_moveMenu">
	<div id="treeDiv" class="treeList" style='height:300px;' ></div>
</div>
<div style="margin-top: 10px;text-align:center">
	<label>
		<input type="button" value="확인" onclick="moveMenu();" class="AXButton red" />
		<input type="button" value="취소" onclick="Common.Close();" class="AXButton" />				
	</label>
</div>

<script>
	var menuId = CFN_GetQueryString("menuId");
	var sortPath = CFN_GetQueryString("sortPath");
	var domain = CFN_GetQueryString("domain");
	var isAdmin = CFN_GetQueryString("isAdmin");
	var tree = new coviTree();
	
	init();
	
	function init() {
		setSelect();
	}

	function setSelect() {
 		coviCtrl.renderDomainAXSelect('selectDomain', 'ko', 'selectOnchange', 'selectRenderComplete', domain);
		
 		$("#selectIsAdmin").bindSelect({
			reserveKeys : {optionValue : "value", optionText : "name"},
			options : [{"name" : "사용자", "value" : "N"}, {"name" : "관리자", "value" : "Y"}],
			setValue : isAdmin,
			onchange : function() {
				setTree();		// 트리 조회
	        }
		});
 		
 		setTree();
	}

	function selectRenderComplete() {
		//setTree();
	}
	
	function selectOnchange() {
		setTree();		// 트리 조회
	}
	
	// 트리 조회
    function setTree() {
    	var treeBody = {};
    	
		$.ajax({
			type:"POST",
			data:{
				'domain' : $('#selectDomain').val(),
				'isAdmin' : $('#selectIsAdmin').val()
			},
			async:false,
			url:"/covicore/menu/getTreeList.do",
			success:function (data) {
				if (data.result == "ok") {
					tree.setTreeList("treeDiv", data.list, "no", "220", "left", false, false, treeBody);					
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/menu/getTreeList.do", response, status, error);
			}
		});
    }
    
	function moveMenu() {
		var obj = tree.getSelectedList();
		var tarMenuId = obj.item.no;
		var tarSortPath = obj.item.SortPath;
		var tarDomainId = obj.item.DomainID;
		var tarIsAdmin = obj.item.IsAdmin;
		
		Common.Confirm("<spring:message code='Cache.msg_inheritedAclDeleted'/>", "Confirm Dialog", function(result){ // 작업 수행 시 기존에 상속 받았던 권한은 삭제됩니다.<br>계속 진행하시겠습니까?
			if (result) {
		 		$.ajax({
					type: "POST",
					data: {
						'menuId' : menuId,
						'sortPath' : sortPath,
						'tarMenuId' : tarMenuId,
						'tarSortPath' : tarSortPath,
						'tarDomainId' : tarDomainId,
						'tarIsAdmin' : tarIsAdmin,
						'sourceDomain' : domain
					},
					async: false,
					url: "/covicore/menu/moveMenu.do",
					success: function(data){
						if (data.status === "SUCCESS") {
							parent.Refresh();
						} else {
							Common.Warning(data.message);
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/menu/moveMenu.do", response, status, error);
					}
				});
			}
		});
	}
	
 	// 트리 버튼
	function treeItem(mode) {
		var obj = tree.getSelectedList();
	    var entCode = $("#selectUseAuthority").val();
        var len = $("#treeDiv_AX_tbody tr").length;
        
        if (mode == "add" || mode == "upd") {
        	var data = "";
        	
	        // 최상위 폴더 없을때
	        if (len == 0) {
	        	Common.Inform('<spring:message code="Cache.apv_msg_rule01"/>'.replace(/&quot;/g, '"'));
	        	data = ",,0"
	        	parent.Common.open("","manageTreeItem","<spring:message code='Cache.lbl_apv_itemManagement'/>","/approval/admin/getRuleManagementTreePopup.do?mode="+mode+"&entCode="+entCode+"&data="+data,"550px","250px","iframe",false,null,null,true);
	        } else if (axf.isEmpty(obj.item)) {
	        	Common.Warning("<spring:message code='Cache.msg_apv_rule01'/>");
	        	return;
	        } else {
	        	if (mode == "add") {
	        		data = ",," + obj.item.no + ",,";
	        	} else {
	        		data = obj.item.no + "," + obj.item.nodeName + "," + obj.item.pno + "," + obj.item.DocKind + "," + obj.item.ItemDesc;
	        	}
	        	parent.Common.open("","manageTreeItem","<spring:message code='Cache.lbl_apv_itemManagement'/>","/approval/admin/getRuleManagementTreePopup.do?mode="+mode+"&entCode="+entCode+"&data="+data,"550px","250px","iframe",false,null,null,true);
	        }
        } else {
        	if (axf.isEmpty(obj.item)) {
        		Common.Warning("<spring:message code='Cache.msg_apv_rule01'/>");
	        	return;
        	} else {
        		Common.Confirm("<spring:message code='Cache.apv_msg_rule02'/>", "Confirmation Dialog", function (confirmResult) {
        			if (confirmResult) {
		         		$.ajax({
		        			type : "POST",
		        			data : {
		        				"itemId" : obj.item.no
		        			},
		        			url : "/approval/admin/deleteRuleTree.do",
		        			success:function (data) {
		        				if (data.result == "ok") {
		        					setTree();
		        				}
		        			},
		        			error:function(response, status, error){
		        				CFN_ErrorAjax("/approval/admin/deleteRuleTree.do", response, status, error);
		        			}
		        		});
        			} else {
        				return false;
        			}
        		});
        	}
        }
	}
</script>