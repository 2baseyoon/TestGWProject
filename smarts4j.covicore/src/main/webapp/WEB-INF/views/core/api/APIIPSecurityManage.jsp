<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_api_ipsecureManage"/></span><%-- IP허용 관리 --%>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.lbl_Add"/>" onclick="addIPSecure();"/>
			<input type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="deleteIPSecure();"/>
			<input type="button" class="AXButton BtnCheck"  value="<spring:message code="Cache.btn_api_ipcheck_test"/>" onclick="checkIP();"/>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<!--소유회사-->
			<spring:message code="Cache.lbl_Company"/>:
			<select id="companySelectBox" class="AXSelect W100"></select>
			&nbsp;
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchGrid();" class="AXButton"/><!--검색 -->
		</div>	
		<div id="ipsecureGrid"></div>
	</div>
</form>

<script type="text/javascript">
	var ipconfigGrid;
	var headerData;
	var lang = Common.getSession("lang");
	
	initContent();
	
	function initContent(){ 
		ipconfigGrid = new coviGrid();
		// 헤더 설정
		
		headerData =[
		             {key:'chk', label:'chk', width:'25', align:'center', formatter:'checkbox'},
		             {key:'SecID', label:'ID', width:'70', align:'center', display:false},
		             {key:'DomainID', label:'<spring:message code="Cache.lbl_Domain" />', display:false, width:'70', align:'center'},
            		 {key:'CompanyName',  label:'<spring:message code="Cache.lbl_Company"/>', width:'70', align:'center', formatter: function(){
            			 return CFN_GetDicInfo(this.item.CompanyName, lang);
            		 }},
		             {key:'IP', label:'IP', width:'150', align:'center', formatter : function(){
		            	 return "<a href='#' onclick='updateIPSecure(false, \""+ this.item.SecID +"\"); return false;'>"+this.item.IP+"</a>";
		             }},
		             {key:'ControlType', label:'<spring:message code="Cache.lbl_api_ipallowyn"/>', width:'75', align:'center', formatter : function(){
		            	 return this.item.ControlType == "ACCEPT" ? '<spring:message code="Cache.lbl_api_ipallowyn_y"/>' : '<span style="color:red;"><spring:message code="Cache.lbl_api_ipallowyn_n"/></span>';
		             }},
		             {key:'IsUse', label:'<spring:message code="Cache.lbl_Use"/>',   width:'50', align:'center',
		              	  formatter:function () {
			            		return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.SecID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.SecID+"\");' />";
			      			}},
		             {key:'Descriptions', label:'<spring:message code="Cache.lbl_Description"/>', sort:false, width:'320', align:'center'},
		             {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', sort:"desc", 
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
		
		ipconfigGrid.setGridHeader(headerData);
		ipconfigGrid.setGridConfig({
			targetID : "ipsecureGrid",
			height:"auto"
		});
	}
	
	// baseconfig 검색
	function searchGrid(){
		ipconfigGrid.page.pageNo = 1;
		ipconfigGrid.bindGrid({
 			ajaxUrl:"/covicore/api/config/getIPSecureList.do",
 			ajaxPars: {
 				// "DomainID" : $("#companySelectBox").val()
 			}
		});
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addIPSecure(pModal){
		var DomainID = $("#companySelectBox").val();
		parent.Common.open("","AddIPSecure",'<spring:message code="Cache.lbl_detail"/>',"/covicore/common_popup/core_api_APIIPSecureDetailPopup.do?mode=add&DomainID=" + DomainID,"700px","400px","iframe",pModal,null,null,true);
	}

	function updateIPSecure(pModal, SecID) {
		parent.Common.open("","UpdateIPSecure",'<spring:message code="Cache.lbl_detail"/>',"/covicore/common_popup/core_api_APIIPSecureDetailPopup.do?mode=modify&SecID="+SecID,"700px","400px","iframe",pModal,null,null,true);
	}
	
	/**
	* 사용/미사용 Toggle
	*/
	function updateIsUse(SecID) {
		var domainID = $("#companySelectBox").val();
		var isUseValue = $("#AXInputSwitch"+SecID).val();
		$.ajax({
			type:"POST",
			data:{
				"SecID" : SecID,
				"IsUse" : isUseValue
			},
			url:"/covicore/api/config/editIPSecureIsUse.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					// Common.Inform("<spring:message code='Cache.msg_apv_170'/>");
				}
				// ipconfigGrid.reloadList();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/api/config/editIPSecureIsUse.do", response, status, error);
				ipconfigGrid.reloadList();
			}
		});
				
	}
	
	function checkIP(){
		var testIP = prompt('<spring:message code="Cache.msg_api_ipcheck_input"/>');
		if(!testIP || testIP == "") return;
		
		$.ajax({
			type:"POST",
			data:{
				"TestIP" : testIP
			},
			async : false,
			url:"/covicore/api/config/checkIPSecure.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					if(data.data == "SUCCESS") {
						alert('<spring:message code="Cache.msg_api_ipcheck_ok"/>');
					}else{
						alert('<spring:message code="Cache.msg_api_ipcheck_fail"/>');
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/api/config/editIPSecureIsUse.do", response, status, error);
				ipconfigGrid.reloadList();
			}
		});
		
	}
	
	// Delete
	function deleteIPSecure(){
		var deleteobj = ipconfigGrid.getCheckedList(0);
		if(deleteobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
			return;
		}else{
			var deleteID = "";
			for(var i=0; i<deleteobj.length; i++){
				if(i==0){
					deleteID = deleteobj[i].SecID;
				}else{
					deleteID = deleteID + "," + deleteobj[i].SecID;
				}
			}
			
			Common.Confirm('<spring:message code="Cache.msg_ReallyDelete"/>', "Confirm", function (result) {
				if(result) {
					$.ajax({
						type:"POST",
						data:{
							"SecID" : deleteID
						},
						url:"/covicore/api/config/deleteIPSecure.do",
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.msg_138'/>");
							}
							ipconfigGrid.reloadList();
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/api/config/deleteIPConfig.do", response, status, error);
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