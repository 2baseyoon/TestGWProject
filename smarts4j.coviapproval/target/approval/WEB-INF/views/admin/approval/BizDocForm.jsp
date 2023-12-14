<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>

<form id="BizDocForm">
    <div style="width:100%;">
    	<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addConfig(false);"/>	
		</div>	
		<div id="topitembar02" class="topbar_grid">			
			<label>
				<select class="AXSelect"  name="sel_Search" id="sel_Search" >
					<option selected="selected" value="FormName"><spring:message code="Cache.lbl_apv_formcreate_LCODE03"/></option>
					<option value="FormPrefix"><spring:message code="Cache.lbl_apv_formcreate_LCODE02"/></option>									
				</select>
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}"  class="AXInput" />
				<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig();" class="AXButton"/>
			</label>			
		</div>	
		<div id="BizDocFormgrid"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>

<script type="text/javascript">
	// 업무문서함 - 양식 목록 조회 화면
	//# sourceURL=BizDocForm.jsp 
	var mode =CFN_GetQueryString("mode");
	var paramBizDocID = CFN_GetQueryString("key");
	var paramEntCode = CFN_GetQueryString("entCode");
	var bizDocFormGrid = new coviGrid();
	
	//ready  - 그리드 세팅
	setGrid();			
	
	//그리드 세팅
	function setGrid(){
		bizDocFormGrid.setGridHeader([	
		        	                  {key:'FormPrefix',  label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE02"/>', width:'150', align:'center'},	                  
		        	                  {key:'FormName',  label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE03"/>', width:'150', align:'center',
		        	                	  formatter:function () {		
									   			return CFN_GetDicInfo(this.item.FormName);
										  }
		        	                  },	                
		        	                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_SortKey"/>', width:'50', align:'center', sort:"asc"}	                  
		        		      		]);
		setGridConfig();
		searchConfig();
	}
	
	// 그리드 설정
	function setGridConfig(){
		var configObj = {
			targetID : "BizDocFormgrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:8
			},
			body:{
				onclick: function(){				
					updateConfig(this.item.BizDocFormID);
			    }				
			}
		};
		
		bizDocFormGrid.setGridConfig(configObj);
	}
	
	// 검색
	function searchConfig(){
		 $(".AXPaging[value=1]").click();
		bizDocFormGrid.bindGrid({
				ajaxUrl:"/approval/admin/getBizDocFormList.do",
				ajaxPars: {
					"BizDocID":paramBizDocID,
					"SearchType": $("#sel_Search").val(),
					"SearchWord": $("#search").val()
				},
				onLoad:function(){
					$("#sel_Search").bindSelect();
				}
		});
	}	

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(bizDocFormID){		
		parent.Common.open("","updateBizDocFormConfig","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||<spring:message code='Cache.lbl_apv_bdform_title_instruction'/>","/approval/admin/goBizDocFormDetailPopup.do?mode=modify&key="+bizDocFormID,"530px","170px","iframe",true,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		$("#search").val("");
		$("#sel_Search").val($("#sel_Search").find("option").eq(0).val());
		searchConfig();
	}
	
	// 추가 버튼에 대한 레이어 팝업
	var _selectDataList = new Array();
	
	parent._CallBackMethod1 = searchConfig;			
	function addConfig(pModal){
		var selectData = {};
		$$(selectData).append("selectData", bizDocFormGrid.list);
		
		_selectDataList =$$(selectData).find("selectData").concat().attr("FormPrefix");
		
		parent.Common.open("","addBizDocForm","<spring:message code='Cache.lbl_apv_formchoice'/>","/approval/admin/goBizDocSelOrginFormPopup.do?key="+paramBizDocID+"&entCode="+paramEntCode+"&data=_selectDataList","500px","270px","iframe",true,null,null,true);
	}
	
</script>
