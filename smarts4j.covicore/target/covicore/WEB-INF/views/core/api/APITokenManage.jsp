<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_api_tokenManage"/></span><%-- Token 관리 --%>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.lbl_ACL_Generation"/>" onclick="generateToken();"/>
			<input type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="deleteToken();"/>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<!--소유회사-->
			<spring:message code="Cache.lbl_Company"/>:
			<select id="companySelectBox" class="AXSelect W100"></select>
			&nbsp;
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchGrid();" class="AXButton"/><!--검색 -->
		</div>	
		<div id="tokengrid"></div>
	</div>
</form>

<script type="text/javascript">
	var tokenGrid;
	var headerData;
	var lang = Common.getSession("lang");
	
	initContent();
	
	function initContent(){ 
		tokenGrid = new coviGrid();
		// 헤더 설정
		
		headerData =[
		             {key:'chk', label:'chk', width:'25', align:'center', formatter:'checkbox'},
		             {key:'TokenID', label:'ID', width:'70', align:'center', display:false},
		             {key:'DomainID', label:'<spring:message code="Cache.lbl_Domain" />', display:false, width:'70', align:'center'},
            		 {key:'CompanyName',  label:'<spring:message code="Cache.lbl_Company"/>', width:'70', align:'center', formatter: function(){
            			 return CFN_GetDicInfo(this.item.CompanyName, lang);
            		 }},
		             {key:'Token', label:'TOKEN', width:'250', align:'center', formatter:function () {
	            		 	return "<a href='#' onclick='updateToken(false, \""+ this.item.TokenID +"\"); return false;'>"+this.item.Token+"</a>";
	            	 }},
		             {key:'IsActive', label:'<spring:message code="Cache.lbl_ComIsUse"/>', width:'70', align:'center'},
		             {key:'Descriptions', label:'<spring:message code="Cache.lbl_Description"/>', sort:false, width:'300', align:'center'},
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
		
		tokenGrid.setGridHeader(headerData);
		tokenGrid.setGridConfig({
			targetID : "tokengrid",
			height:"auto"
		});
	}
	
	// baseconfig 검색
	function searchGrid(){
		tokenGrid.page.pageNo = 1;
		tokenGrid.bindGrid({
 			ajaxUrl:"/covicore/api/config/getTokenList.do",
 			ajaxPars: {
 				"DomainID" : $("#companySelectBox").val()
 			}
		});
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function generateToken(){
		Common.Confirm("<spring:message code='Cache.msg_ConfirmGenerateToken'/>", "Confirm", function(result){
			if(result){
				var DomainID = $("#companySelectBox").val();
				$.ajax({
					type:"POST",
					data:{
						"DomainID" : DomainID
					},
					url:"/covicore/api/config/generateToken.do",
					success:function (data) {
						if(data.status == "SUCCESS"){
							Common.Inform("<spring:message code='Cache.msg_SuccessRegist'/>");
						}else{
							Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
						}
						tokenGrid.reloadList();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/api/config/generateToken.do", response, status, error);
					}
				});
			}
		});
	}

	function updateToken(pModal, TokenID) {
		parent.Common.open("","UpdateToken",'<spring:message code="Cache.lbl_detail"/>',"/covicore/common_popup/core_api_APITokenDetailPopup.do?mode=modify&TokenID="+TokenID,"700px","300px","iframe",pModal,null,null,true);
	}
	
	// Revoke
	function deleteToken(){
		var deleteobj = tokenGrid.getCheckedList(0);
		if(deleteobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
			return;
		}else{
			var deleteID = "";
			for(var i=0; i<deleteobj.length; i++){
				if(i==0){
					deleteID = deleteobj[i].TokenID;
				}else{
					deleteID = deleteID + "," + deleteobj[i].TokenID;
				}
			}
			
			Common.Confirm('<spring:message code="Cache.msg_ReallyDelete"/>', "Confirm", function (result) {
				if(result) {
					$.ajax({
						type:"POST",
						data:{
							"TokenID" : deleteID
						},
						url:"/covicore/api/config/deleteToken.do",
						success:function (data) {
							if(data.status == "SUCCESS")
								Common.Inform("<spring:message code='Cache.msg_138'/>");
							tokenGrid.reloadList();
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/api/config/deleteToken.do", response, status, error);
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