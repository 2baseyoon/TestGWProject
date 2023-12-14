<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<style>
	#form1 div{
		font-size: 13px;
	}
	
	.AXgridStatus {
		display:none;
	}
</style>
<form id="form1">
	<h3>▶ <spring:message code='Cache.lbl_commonFields'/></h3>
	<div id="commonFieldGrid" class="mt12">
	</div>
	
	<h3>▶ <spring:message code='Cache.lbl_formFields'/></h3>
	<div id="formFieldGrid" class="mt12">
	</div>
	<div class="center mt12">
		<input type="button" id="btnAdd" class="AXButton" value="<spring:message code='Cache.btn_Add'/>" />
	</div>
</form>
<script>
	var AggregationField = function(){
	    var commonFieldGrid = new coviGrid();
	    var formFieldGrid = new coviGrid();
	    var aggFormId;
	    var entCode;
	    
	    var init = function(){
	    	aggFormId = CFN_GetQueryString("aggFormId");
	    	entCode = CFN_GetQueryString("entCode");
	    	initCommonFieldGrid();
	    	initFormFieldGrid();
	    	
	    	getFormsData(aggFormId);
	    	
	    	document.querySelector("#btnAdd").addEventListener("click", addFields);
	    };
	    
	    var initCommonFieldGrid = function(){
	    	var headerData = [
	    		{key:'chk', label:'chk', width:'25', align:'center', width: '1', formatter:'checkbox',sort:false},
	    		{ key: 'fieldName', label: '<spring:message code="Cache.lbl_FieldNm"/>', width: '3', align: 'center', formatter: function(){
	            	return CFN_GetDicInfo(this.item.fieldName)
	            }},
	            { key: 'fieldId', label: '<spring:message code="Cache.lbl_FieldId"/>', width: '3', align: 'center' },
	    	]
	        
	        var configObj = {
	            targetID: "commonFieldGrid",
	            height: "auto",
	            paging: false,
	            body: {
	                onclick: function(){
	                }
	            },
	            ajaxInfo : {}
	        };
	        
	    	commonFieldGrid.setGridHeader(headerData);
	    	commonFieldGrid.setGridConfig(configObj);
	    }

	    var initFormFieldGrid = function(){
	    	var headerData = [
	    		{key:'chk', label:'chk', width:'25', align:'center', width: '1', formatter:'checkbox',sort:false},
	    		{ key: 'FieldLabel', label: '<spring:message code="Cache.lbl_FieldNm"/>', width: '3', align: 'center', formatter: function(){
	            	return CFN_GetDicInfo(this.item.FieldLabel)
	            }},
	            { key: 'FieldName', label: '<spring:message code="Cache.lbl_FieldId"/>', width: '3', align: 'center' },
	    	]
	        
	        var configObj = {
	            targetID: "formFieldGrid",
	            height: "auto",
	            paging: false,
	            body: {
	                onclick: function(){
	                }
	            },
	            ajaxInfo : {}
	        };
	        
	    	formFieldGrid.setGridHeader(headerData);
	        formFieldGrid.setGridConfig(configObj);
	    }

	    var getFormsData = function(aggFormId){
	    	$.ajax({
	            type:"GET",
	            url:"/approval/admin/aggregation/form/fieldsForAdd.do?entCode="+entCode+"&aggFormId=" + aggFormId,
	            success:function (data) {
	                if(data.status === "SUCCESS"){
	                	var commonFields = data.info.commonFields;
	                	var formFields = data.info.formFields;
	                	commonFieldGrid.bindGrid(commonFields);
	                	formFieldGrid.bindGrid(formFields);
	                } else {
	                    Common.Error(data.message);
	                }
	            },
	            error:function(response){
	                if(response.status === 400 && response.responseJSON){
	                    Common.Error(response.responseJSON.message);
	                } else {
	                    CFN_ErrorAjax("/approval/admin/aggregation/forms.do", response, response.status, response.statusText);
	                }
	            }
	        });
	    }
	    
	    var addFields = function(){
	    	var addCommonFields = commonFieldGrid.getCheckedList(0);
	    	var addFormFields = formFieldGrid.getCheckedList(0);
	    	
	    	if(addCommonFields.length == 0 && addFormFields.length == 0){
				Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
	    		return;
	    	}
	    	
	    	var data = {
    			aggFormId,
	    		commonFields : addCommonFields,
	    		formFields : addFormFields 
	    	}
	    	
	    	parent.callBackAddFields(data);
	    	Common.Close();
	    };
	    init();
	};
	
	new AggregationField();

</script>