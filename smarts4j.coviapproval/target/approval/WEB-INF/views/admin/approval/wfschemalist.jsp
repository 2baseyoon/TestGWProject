<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit">양식프로세스 관리</span>	
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addSchema(true);"/>
			
			&nbsp;
			<label for="selectUseAuthority"><spring:message code="Cache.lbl_Domain"/>:</label>
			<select name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select>
		</div>
		<div id="processListGrid"></div>
	</div>
</form>
<script type="text/javascript">
	var myGrid = new coviGrid();

	initWFSchemaList();

	function initWFSchemaList(){
		$("#selectUseAuthority").coviCtrl("setSelectOption", "/approval/common/getEntInfoListData.do", {"type" : "ID"});
		$("#selectUseAuthority").bindSelect({
			onchange: function(){
				setSchemaGridData();
			}
		});
		setGrid();			// 그리드 세팅
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[
		                  {key:'SCHEMA_NAME', label:'<spring:message code="Cache.lbl_apv_SchemaName"/>', width:'100', align:'center',
		                	  formatter:function () {
		      					return "<a onclick='updateSchema(true, \""+ this.item.SCHEMA_ID +"\"); return false;'>"+this.item.SCHEMA_NAME+"</a>";
		      				}, sort:"asc"},
		                  {key:'SCHEMA_DESC', label:'<spring:message code="Cache.lbl_apv_SchemaDesc"/>',   width:'200',
		                	  formatter:function () {
		                		  return "<span onclick='updateSchema(true, \""+ this.item.SCHEMA_ID +"\");'>"+this.item.SCHEMA_DESC+"</span>";
			      			}},
		                  {key:'DOMAIN_NAME', label:'<spring:message code="Cache.lbl_Domain"/>',   width:'100', align:'center'}
			      		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "processListGrid", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
		
		setSchemaGridData();
	}
	
	// data bind
	function setSchemaGridData(){
		var DomainId = $("#selectUseAuthority").val();
		var entcode = '';
		$.map($('#selectUseAuthority option'), function(e) {
			if(e.value!='') entcode+= e.value+',';
		});
		myGrid.bindGrid({
 			ajaxUrl:"/approval/admin/getschemalist.do",
 			ajaxPars:{
 				"DomainID" : DomainId,
 				"EntCode" : entcode
 			}
		});
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addSchema(pModal){
		parent.Common.open("","schemaDetailPopup","<spring:message code='Cache.lbl_ConfigCreation'/>","/approval/admin/addschemalayerpopup.do?mode=add","1000px","600px","iframe",pModal,null,null,true);
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateSchema(pModal, schema_Id){
		parent.Common.open("","schemaDetailPopup","<spring:message code='Cache.lbl_ConfigModify'/>","/approval/admin/addschemalayerpopup.do?mode=modify&id="+schema_Id,"1000px","600px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	function setFirstPageURL(){
		SaveFirstPageURL("/approval/approvaladmin_wfschemalist.do");
	}
</script>