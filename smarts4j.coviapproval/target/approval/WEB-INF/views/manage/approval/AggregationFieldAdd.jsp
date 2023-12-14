<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
	#form1 div{
		font-size: 13px;
	}
	
	.AXgridStatus {
		display:none;
	}
</style>
<form id="form1">
	<div class="sadmin_pop sadminContent" style="margin:0px;">
		<h3><spring:message code="Cache.lbl_commonFields"/></h3><!-- 공통필드 -->
		<div class="tblList tblCont" style="margin-bottom:20px;">
			<div id="commonFieldGrid">
			</div>
		</div>
		<h3><spring:message code="Cache.lbl_formFields"/></h3><!-- 양식필드 -->
		<div class="tblList tblCont" style="">
			<div id="formFieldGrid">
			</div>
		</div>
		<div class="bottomBtnWrap">
			<a id="btnAdd" href="#" class="btnTypeDefault btnTypeBg"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->
		</div>
	</div>
</form>
<script>
	var AggregationField = function(){
	    var commonFieldGrid = new coviGrid();
	    var formFieldGrid = new coviGrid();
	    commonFieldGrid.config.fitToWidthRightMargin = 0;
	    formFieldGrid.config.fitToWidthRightMargin = 0;
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
	    		{ key: 'fieldName', label: '<spring:message code="Cache.lbl_FieldNm"/>', width: '3', align: 'center', sort:false,formatter: function(){
	            	return CFN_GetDicInfo(this.item.fieldName)
	            }},
	            { key: 'fieldId', label: '<spring:message code="Cache.lbl_FieldId"/>', width: '3', align: 'center',sort:false },
	    	]
	        
	        var configObj = {
	            targetID: "commonFieldGrid",
	            height: "auto",
	            paging: false,
	            sort:false,
	            page: {
					display: false,
					paging: false
				},
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
	            sort:false,
	            page: {
					display: false,
					paging: false
				},
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
	            url:"/approval/manage/aggregation/form/fieldsForAdd.do?entCode="+entCode+"&aggFormId=" + aggFormId,
	            success:function (data) {
	                if(data.status === "SUCCESS"){
	                	var commonFields = data.info.commonFields;
	                	var formFields = data.info.formFields;
	                	commonFieldGrid.bindGrid(commonFields);
	                	formFieldGrid.bindGrid(formFields);
	                	commonFieldGrid.windowResize();
	                	formFieldGrid.windowResize();
	                } else {
	                    Common.Error(data.message);
	                }
	            },
	            error:function(response){
	                if(response.status === 400 && response.responseJSON){
	                    Common.Error(response.responseJSON.message);
	                } else {
	                    CFN_ErrorAjax("/approval/manage/aggregation/forms.do", response, response.status, response.statusText);
	                }
	            }
	        });
	    }
	    
	    var addFields = function() {
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