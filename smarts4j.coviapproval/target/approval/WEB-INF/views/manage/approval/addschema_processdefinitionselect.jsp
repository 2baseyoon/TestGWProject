<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<style type="text/css">
	body { height: auto; }
	tr.previous {
		display:none;
	}
	tr.lastest > td {
		font-weight:bold;
	}
</style>
<script>
	$(document).ready(function(){
		setList();
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
	function setList(){
		getPDEFList();
	}
	
	function setTreeData(pListData) {
		
		var htmlBuf = new StringBuilder();
		var maxVersion = {"draft1":0, "request1":0};
		
		var drawingList = [];
		for(var e = pListData.length-1; e >= 0; e--){
			var category = pListData[e].category;
			var id = pListData[e].id;
			if(category.indexOf("processdef") > -1 && (id.indexOf("draft1") > -1 || id.indexOf("request1") > -1) ){
				var version = pListData[e].version;
				var key = pListData[e].key;
				maxVersion[key] = Math.max(maxVersion[key], version);
				drawingList.push(pListData[e]);
			}
		}
		
		for(var e = 0; e < drawingList.length; e++){
			var category = drawingList[e].category;
			var id = drawingList[e].id;
			var key = drawingList[e].key;
			var version = drawingList[e].version;
			var name = drawingList[e].name;
			var className = "previous";
			if(maxVersion[key] == version){
				className = "lastest";
			}
			if(category.indexOf("processdef") > -1 && (id.indexOf("draft1") > -1 || id.indexOf("request1") > -1) ){
				
				htmlBuf.appendln("<tr class='"+ className +"'>");
				htmlBuf.appendln(	"<td>");
				htmlBuf.appendln(		"<input type='radio' PDEFid='" + id + "' PDEFname='" + name + "' name='rdotree'/>");
				htmlBuf.appendln(	"</td>");
				htmlBuf.appendln(	"<td class='left'>");
				htmlBuf.appendln(		name);
				htmlBuf.appendln(	"</td>");
				htmlBuf.appendln(	"<td>");
				htmlBuf.appendln(		version);
				htmlBuf.appendln(	"</td>");
				htmlBuf.appendln(	"<td class='left'>");
				htmlBuf.appendln(		id);
				htmlBuf.appendln(	"</td>");
				htmlBuf.appendln(	"<td>");
				htmlBuf.appendln(		key);
				htmlBuf.appendln(	"</td>");
				htmlBuf.append("</tr>");
			}
		}
		
		$("#divPDEF").html(htmlBuf.toString());
	}
	
	//저장 버튼 클릭
	function btnSave_Click(){
		var checkedItem = $("[name=rdotree]:checked");
		var pdefID = "";
		var pdefName = "";
		
		if($(checkedItem).length > 0){
			pdefID = checkedItem.attr("pdefid");
			pdefName = checkedItem.attr("pdefname");
		}else{
			alert("<spring:message code='Cache.msg_apv_003'/>");
			return;
		}
		
		parent._CallBackMethod(pdefID, pdefName);
		
		btnClose_Click();
	}
	
	//닫기 버튼 클릭
	function btnClose_Click(){
		Common.Close();
	}
	
	function StringBuilder (defaultStr){
		var rtn = defaultStr || "";
		this.append = function(str) {
			rtn = rtn + str;
		};
		this.appendln = function(str) {
			rtn = rtn + str + "\n";
		};
		this.toString = function() {
			return rtn;
		};
	}

	function toggleVersionView() {
		var checked = $("#chkToggle").is(":checked");
		if(checked){
			$("tr.previous").hide();
		}else{
			$("tr.previous").show();
		}
	}
</script>
<div class="sadminContent">
	<div class="tblList tblCont">
		<div style="margin-bottom:10px;text-align:right;font-weight:bold;">
			<label>
				<input id="chkToggle" type="checkbox" checked="checked" onclick="toggleVersionView()"/>
				<spring:message code="Cache.msg_apv_definition_desc"/><!-- Show only latest version. -->
			</label>
		</div>
		<div id="sadminTree" class="treeBody">
			<table class="treetable">
				<colgroup>
					<col width="60px">
					<col width="160px">
					<col width="75px">
					<col width="*">
					<col width="70px">
				</colgroup>
				<thead>
					<tr>
						<th>&nbsp;</th>
						<th>NAME</th>
						<th>Ver.</th>
						<th>ID</th>
						<th>KEY</th>
					</tr>
				</thead>
				<tbody id="divPDEF">
				</tbody>
			</table>
		</div>
	</div>
</div>
<div class="bottomBtnWrap" style="text-align:center;padding-bottom:10px;">
	<a class="btnTypeDefault btnTypeBg" onclick="btnSave_Click(); return false;" ><spring:message code="Cache.btn_ok"/></a>
	<a class="btnTypeDefault" onclick="btnClose_Click(); return false;" ><spring:message code="Cache.btn_apv_close"/></a>
</div>