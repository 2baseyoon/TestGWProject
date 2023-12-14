<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>

<script>
	var PDEF_ID = CFN_GetQueryString("PDEF_ID");
	var myTree = new coviTree();
	
	$(document).ready(function(){
		setTree();
		
		if(PDEF_ID != ""){
			
		}
	});
	
	// pdef 데이터 조회
	function getPDEFList(){
		$.ajax({
		    url: "getactprocdef.do",
		    type: "POST",
		    data: {},
		    success: function (res) {
		    	setTreeData(res.list.data);
            },
            error:function(response, status, error){
				CFN_ErrorAjax("getactprocdef.do", response, status, error);
			}
		});
	}
	
	//Grid 세팅
	function setTree(){
		setTreeConfig();
		getPDEFList();
	}
	
	function setTreeConfig() {
		myTree.setConfig({
			targetID : "divPDEF",
         	height: "auto", 
			xscroll:true,
			relation:{
				parentKey:"pno",
				childKey:"no"
			},
			colGroup: [
		                  /* {key:'rdo', label:'rdo', width:'20', align:'center', formatter:function () {
		                	  if(this.item.pno == 0){
		                		  return "";
		                	  } else {
		                		  return "<input type='radio' PDEFid='" + this.item.id + "' PDEFname='" + this.item.nodeName + "' name='rdotree'/>";
		                	  }
		                  },checked:function () {}}, */
		                  {key:'nodeName', label:'<spring:message code="Cache.lbl_name"/>',align:"left", width:'100', indent:true ,formatter:function () {
		                	  if(this.item.pno == 0){
		                		  return this.item.nodeName;
		                	  } else {
		                		  return "<div><input type='radio' PDEFid='" + this.item.id + "' PDEFname='" + this.item.nodeName + "' name='rdotree'/><span>" + this.item.nodeName + "(" + this.item.id + ")" +"</span></div>";
		                	  }
		                  }}
			      		]
		});
	}
	
	// tree data bind
	function setTreeData(pListData) {
		var treeData = [];
		var categoryList = [];
		for(var d in pListData){
			if(!categoryList.includes(pListData[d].category))
				categoryList.push(pListData[d].category);
		}
		
		for(var d=0;d<$(categoryList).length;d++){
			var rowObj = {};
			var pno = d+1;
			
			// http://www.activiti.org/processdef 하위 항목만 조회되도록 처리함.
			if(categoryList[d] != undefined && categoryList[d] != 'undefined' && categoryList[d] != null && categoryList[d].indexOf("processdef") > -1){
				rowObj= {
							no : pno,
							nodeName : categoryList[d],
							pno:0
						};
				treeData.push(rowObj);
				
				var bDraft = false, bRequest = false;
				for(var e=$(pListData).length-1; e>=0; e--){
					if(categoryList[d] == pListData[e].category
							&& ((pListData[e].id.indexOf("draft1") > -1 && !bDraft) || (pListData[e].id.indexOf("request1") > -1 && !bRequest)) ){
						rowObj= {
									no : pno + "" + e,
									nodeName : pListData[e].name,
									pno : pno,
									id : pListData[e].id, 
									key :  pListData[e].key,
									ver : pListData[e].version
								};
						treeData.push(rowObj);
						
						// 공공데모에서는 각 1개씩만 표시되고, 제품에서는 전체 다 표시함
						if(pListData[e].id.indexOf("draft1") > -1 && location.href.indexOf("gov.covismart.com") > -1)
							bDraft = true;
						
						if(pListData[e].id.indexOf("request1") > -1 && location.href.indexOf("gov.covismart.com") > -1)
							bRequest = true;
					}
				}
			}
		}
				
		myTree.setList(treeData);
		myTree.callExpandAllTree("divPDEF", true); // 펼치기
	}
	
	//저장 버튼 클릭
	function btnSave_Click(){
		var checkedItem = $("[name=rdotree]:checked");
		var pdefID = "";
		var pdefName = "";
		
		if($(checkedItem).length > 0){
			pdefID = checkedItem.attr("pdefid");
			pdefName = checkedItem.attr("pdefname");
		}
		
		parent._CallBackMethod(pdefID, pdefName);
		
		btnClose_Click();
	}
	
	//닫기 버튼 클릭
	function btnClose_Click(){
		Common.Close();
	}
</script>
<form name="form1">
	<div id="divPDEF" style="height:450px"></div>
	<div id="divBtnArea" style="margin-top:30px">
		<input type="button" class="AXButton red" onclick="btnSave_Click(); return false;" value="<spring:message code="Cache.btn_apv_save"/>"/>
		<input type="button" class="AXButton" onclick="btnClose_Click(); return false;" value="<spring:message code="Cache.btn_apv_close"/>"/>
	</div>
</form>