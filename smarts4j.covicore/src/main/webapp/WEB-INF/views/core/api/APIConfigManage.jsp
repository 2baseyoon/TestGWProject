<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_api_configManage"/></span><%-- API 설정관리 --%>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.lbl_Add"/>" onclick="addAPIConfig();"/>
			<input type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="deleteAPIConfig();"/>
			<input type="button" class="AXButton BtnDefault"  value="<spring:message code="Cache.lbl_Synchronization"/>" onclick="syncAPIConfig();"/>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<!--소유회사-->
			<spring:message code="Cache.lbl_Company"/>:
			<select id="companySelectBox" class="AXSelect W100"></select>
			&nbsp;
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchGrid();" class="AXButton"/><!--검색 -->
		</div>	
		<div id="configgrid"></div>
	</div>
</form>

<script type="text/javascript">
	var configGrid;
	var headerData;
	var lang = Common.getSession("lang");
	
	initContent();
	
	function initContent(){ 
		configGrid = new coviGrid();
		// 헤더 설정
		
		headerData =[
		             {key:'chk', label:'chk', width:'25', align:'center', formatter:'checkbox'},
		             {key:'ConfigID', label:'ID', width:'70', align:'center', display:false},
		             {key:'DomainID', label:'<spring:message code="Cache.lbl_Domain" />', display:false, width:'70', align:'center'},
            		 {key:'CompanyName',  label:'<spring:message code="Cache.lbl_Company"/>', width:'70', align:'center', formatter: function(){
            			 return CFN_GetDicInfo(this.item.CompanyName, lang);
            		 }},
		             {key:'ConfigName', label:'<spring:message code="Cache.lbl_SettingName"/>', width:'160', align:'center', formatter:function () {
	            		 	return "<a href='#' onclick='updateAPIConfig(false, \""+ this.item.ConfigID +"\"); return false;'>"+CFN_GetDicInfo(this.item.MultiDisplayName, lang)+"</a>";
	            	 }},
		             {key:'Path', label:'Path', width:'150', align:'center'},
		             {key:'ServiceURL', label:'ServiceURL', width:'190', align:'center'},
		             {key:'ReqLimitPerDay', label:'<spring:message code="Cache.lbl_api_limit"/>', width:'85', align:'center'},
		             {key:'IsUse', label:'<spring:message code="Cache.lbl_Use"/>',   width:'60', align:'center',
		              	  formatter:function () {
			            		return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.ConfigID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.ConfigID+"\");' />";
			      			}},
		             {key:'Descriptions', label:'<spring:message code="Cache.lbl_Description"/>', sort:false, width:'300', align:'left'},
		             {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'130', align:'center', sort:"desc", 
				          formatter: function(){
			      			return CFN_TransLocalTime(this.item.ModifyDate);
			      		  }, dataType:'DateTime'
			      	  }
			      	];
		setGrid();			// 그리드 세팅
		searchGrid();
	}
	//그리드 세팅
	function setGrid(){
		coviCtrl.renderDomainAXSelect("companySelectBox", lang, null, null, '');
		
		configGrid.setGridHeader(headerData);
		configGrid.setGridConfig({
			targetID : "configgrid",
			height:"auto"
		});
	}
	
	// baseconfig 검색
	function searchGrid(){
		configGrid.page.pageNo = 1;
		configGrid.bindGrid({
 			ajaxUrl:"/covicore/api/config/getConfigList.do",
 			ajaxPars: {
 				"DomainID" : $("#companySelectBox").val()
 			}
		});
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addAPIConfig(pModal){
		var DomainID = $("#companySelectBox").val();
		parent.Common.open("","AddConfig",'<spring:message code="Cache.lbl_detail"/>',"/covicore/common_popup/core_api_APIConfigDetailPopup.do?mode=add&DomainID="+DomainID,"700px","450px","iframe",pModal,null,null,true);
	}

	function updateAPIConfig(pModal, ConfigID) {
		parent.Common.open("","UpdateConfig",'<spring:message code="Cache.lbl_detail"/>',"/covicore/common_popup/core_api_APIConfigDetailPopup.do?mode=modify&ConfigID="+ConfigID,"700px","450px","iframe",pModal,null,null,true);
	}
	
	/**
	* 사용/미사용 Toggle
	*/
	function updateIsUse(ConfigID) {
		var domainID = $("#companySelectBox").val();
		var isUseValue = $("#AXInputSwitch"+ConfigID).val();
		$.ajax({
			type:"POST",
			data:{
				"ConfigID" : ConfigID,
				"IsUse" : isUseValue
			},
			url:"/covicore/api/config/editConfigIsUse.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					// Common.Inform("<spring:message code='Cache.msg_apv_170'/>");
				}
				// configGrid.reloadList();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/api/config/editConfigIsUse.do", response, status, error);
				configGrid.reloadList();
			}
		});
				
	}
	
	
	/**
	* 실제 메소드 기준으로 설정추가 및 사용불가 설정삭제, 이미 존재하는 설정은 수정하지 않음.
	*/
	function syncAPIConfig() {
		Common.Confirm('<spring:message code="Cache.msg_api_syncconfig"/>', "Confirm", function (result) {
			if(result) {
				var domainID = $("#companySelectBox").val();
				
				var strVersion = prompt('Version(Definition) name. \r\n ex) Version1.0');
				if(!strVersion) return;
				
				$.ajax({
					type:"POST",
					data:{
						"DomainID" : domainID,
						"Version" : strVersion
					},
					url:"/covicore/api/config/synchronizeComponents.do",
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_apv_170'/>");
						}else{
							CFN_ErrorAjax("/covicore/api/config/synchronizeComponents.do", null, "500", "");	
						}
						configGrid.reloadList();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/api/config/synchronizeComponents.do", response, status, error);
					}
				});
				
			}
		});
	}
	// Delete
	function deleteAPIConfig(){
		var deleteobj = configGrid.getCheckedList(0);
		if(deleteobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
			return;
		}else{
			var deleteID = "";
			for(var i=0; i<deleteobj.length; i++){
				if(i==0){
					deleteID = deleteobj[i].ConfigID;
				}else{
					deleteID = deleteID + "," + deleteobj[i].ConfigID;
				}
			}
			
			Common.Confirm('<spring:message code="Cache.msg_ReallyDelete"/>', "Confirm", function (result) {
				if(result) {
					$.ajax({
						type:"POST",
						data:{
							"ConfigID" : deleteID
						},
						url:"/covicore/api/config/deleteConfig.do",
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.msg_138'/>");
							}
							configGrid.reloadList();
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/api/config/deleteConfig.do", response, status, error);
						}
					});
					
				}
			});
		}
	}
	
	// 새로고침
	function Refresh(){
		searchGrid();
	}
	
</script>