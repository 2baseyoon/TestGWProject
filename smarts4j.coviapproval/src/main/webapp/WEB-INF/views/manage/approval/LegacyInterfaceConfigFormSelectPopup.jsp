<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var domainID = "";
	var formPopupManager;
	$(document).ready(function(){		
		formPopupManager = new FormPopupManager();
		formPopupManager.init();
	});
	
	function FormPopupManager () {
		var formsGrid = new coviGrid();
		var DomainCode;
		//Const
		this.init = function () {
			setGrid();
			domainID = parent.legacyIfConfigManage.getDomainID(); // /manage/approval/LegacyInterfaceConfigPopup.jsp
	    	getFormsList(Number(domainID));
		};
		
		var setGrid = function () {
		   formsGrid.config.fitToWidthRightMargin = 15;
		    
		    var headerData = [
		        { key: 'Choose', label: '<spring:message code="Cache.lbl_Choice"/>', width: '50', align: 'center', formatter: function(){
		        	return '<a onclick="formPopupManager.selectChoose(' + this.index + ')" class="btnTypeDefault"><spring:message code="Cache.lbl_Choice"/></a>';
		        }},
		        { key: 'FormName', label: '<spring:message code="Cache.lbl_apv_formcreate_LCODE03"/>', width: '200', align: 'left', formatter: function(){
		        	return CFN_GetDicInfo(this.item.FormName)
		        }, sort:"asc"},
		        { key: 'FormPrefix', label: '<spring:message code="Cache.lbl_apv_formcreate_LCODE02"/>', width: '80', align: 'center' },
		    ];

		    var configObj = {
		        targetID: "formsGrid",
		        height: "auto",
				page : {
					pageNo:1,
					pageSize:10
				},
				paging : true
		    };
		    
		    formsGrid.setGridHeader(headerData);
		    formsGrid.setGridConfig(configObj);
		};

	    var getFormsList = function(DomainID){
	    	$.ajax({
	    		url : "/covicore/domain/get.do",
	    		data : { "DomainID" : DomainID},
	    		method : "POST",
	    		success : function (data) {
	    			var DomainCode = data.list[0].DomainCode;
	    			setDomainCode(DomainCode);
	    			
	    			// after get domain code.
					configList();
			    	// formsGrid.windowResize();
	    		}
	    	});
	    };
	    
	    var setDomainCode = function(domainCode) {
	    	DomainCode = domainCode;
	    };
	    
	    var configList = function () {
	    	formsGrid.page.pageNo = 1;
	    	formsGrid.bindGrid({
				ajaxUrl:"/approval/manage/getAdminFormListData.do",
				ajaxPars: {
					"EntCode" : DomainCode,
					"IsUse":"Y",
					"sel_Search" : "FormName",
					"search": $("#searchText").val()
				}
			});
	    }
	    this.search = function () {
	    	configList();
	    };
	    
	    this.selectChoose = function(index) {
	    	var FormPrefix = formsGrid.list[index].FormPrefix;
	    	var FormID = formsGrid.list[index].FormID;
	    	var FormName = formsGrid.list[index].FormName;
	    	
	    	parent.legacyIfConfigManage.setFormSelected(FormID, FormPrefix, FormName);
	    };
	}
</script>
<div class="sadmin_pop" style="margin:0px;">
	<div>
		<spring:message code="Cache.lbl_FormNm"/><!-- 양식명 -->
		<input type="text" id="searchText" onkeypress="if (event.keyCode==13){ formPopupManager.search(); return false;}" >
		<a class="btnTypeDefault" onclick="formPopupManager.search();" ><spring:message code="Cache.lbl_search"/></a>
	</div>	
	<div id="formsGrid" class="tblList">
	</div>
</div>