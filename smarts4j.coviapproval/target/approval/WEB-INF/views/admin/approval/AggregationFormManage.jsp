<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<style>
	#FieldNmContainer {
		padding: 0px;
	}
	
	#FieldNmContainer .AXFormTable {
		box-shadow: none;
	}
		#FieldNmContainer .AXFormTable tbody th {
			border-left: 0px !important;
		}

		#FieldNmContainer .AXFormTable tbody tr:last-child th {
			border-bottom: 0px !important;
		}
	
		#FieldNmContainer .AXFormTable tbody td {
			border-right: 0px;
		}
</style>
<form id="form1">
	<table class="AXFormTable">
		<colgroup>
			<col style="width:35%" />
			<col style="width:65%" />
		</colgroup>
		<tbody>
			<tr>
				<th><spring:message code="Cache.lbl_Domain"/></th><!-- 도메인 -->
				<td>
					<div style="display:none;"><select name="companys" class="AXSelect"></select></div>
					<span id="dp_companys"></span>
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_apv_form"/></th><!-- 양식 -->
				<td>
					<input type="button" id="formSelectBtn" class="AXButton" value="선택" style="display:none;" />
					<input type="text" id="form" class="AXInput" disabled=true style="width:calc(100% - 55px)" />
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_isDisplayInAggBox"/></th><!-- 집계함 노출 여부 -->
				<td>
					<select name="displayYN" class="AXSelect">
						<option value="Y" selected="selected"><spring:message code="Cache.lbl_exposure"/></option><!-- 노출 -->
						<option value="N"><spring:message code="Cache.lbl_notExposure"/></option><!-- 노출하지 않음 -->
					</select>
				</td>
			</tr>
		</tbody>
	</table>
	<div class="center mt12">
		<input type="button" id="btnAdd" class="AXButton" style="display:none;" value="<spring:message code='Cache.btn_Add'/>" /> <!-- 추가 -->
		<input type="button" id="btnModify" class="AXButton" style="display:none;" value="<spring:message code='Cache.btn_apv_update'/>" /> <!-- 수정 -->
		<input type="button" id="btnDelete" class="AXButton" style="display:none;" value="<spring:message code='Cache.btn_apv_delete'/>" /> <!-- 삭제 -->
	</div>
</form>
<script>
	var AggregationForm = function(){
	    var addBtn = document.querySelector("#btnAdd");
	    var modifyBtn = document.querySelector("#btnModify");
	    var deleteBtn = document.querySelector("#btnDelete");
	    var formSelectBtn = document.querySelector("#formSelectBtn");
	    var entCode;
	    var aggFormId;
	    var formData;
	    var key;
	    
	    var init = function(){
	        entCode = CFN_GetQueryString("entCode");
	        aggFormId = CFN_GetQueryString("formId");
	        
	        $("[name=companys]").bindSelect({
	            reserveKeys: {
	                options: "list",
	                optionValue: "optionValue",
	                optionText: "optionText"
	            },
	            ajaxUrl: "/approval/common/getEntInfoListAssignData.do",			
	            ajaxAsync:false
	        }).bindSelectSetValue(entCode);
	        $("#dp_companys").text($("[name=companys] :selected").text());
	        
	        $(".AXSelect").bindSelect();
			
	        if(aggFormId != "undefined"){ // 수정
	        	getFormInfo();
	        	$(modifyBtn).show();
	        	modifyBtn.addEventListener("click", modifyForm);
	        }else{ // 추가
	        	$(addBtn).show();
	        	$(formSelectBtn).show();
	        	addBtn.addEventListener("click", addForm);
	        	formSelectBtn.addEventListener("click", formSelect);
	        }
	    };
	
	    var getFormData = function(){
	        return {
	            entCode : document.querySelector("[name=companys]").value,
	            formPrefix : formData.FormPrefix,
	            displayYN : document.querySelector("[name=displayYN]").value
	        };
	    };
	    
	    var getFormInfo = function(){
	        var selFormData = parent.window.aggregationManage.selectedForm;
	        formData = {FormDesc:"", FormName:selFormData.formName, FormPrefix:selFormData.formPrefix};
         	document.querySelector('#form').value = CFN_GetDicInfo(selFormData.formName);
         	$("[name=displayYN]").bindSelectSetValue(selFormData.displayYN);
	    };
	    
	    var modifyForm = function(){
	    	var tmpFormData = getFormData();
	    	tmpFormData.aggFormId = aggFormId;
	        $.ajax({
	            type:"PUT",
	            data:JSON.stringify(tmpFormData),
	            contentType: 'application/json; charset=utf-8',
	            url:"/approval/admin/aggregation/form/" + aggFormId + ".do",
	            success:function (data) {
	                if(data.status === "SUCCESS"){
	                    parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
	                    	if(parent.window.aggregationManage){
	                    		parent.window.aggregationManage.refreshGrid();
	                    	}
	                        Common.Close();
	                    });
	                } else {
	                    Common.Error(data.message);
	                }
	            },
	            error:function(response){
	                if(response.status === 400 && response.responseJSON){
	                    Common.Error(response.responseJSON.message);
	                } else {
	                    CFN_ErrorAjax("/approval/admin/aggregation/form.do", response, response.status, response.statusText);
	                }
	            }
	        });
	    };
	    
	    var addForm = function(){
	        $.ajax({
	            type:"POST",
	            data:JSON.stringify(getFormData()),
	            contentType: 'application/json; charset=utf-8',
	            url: "/approval/admin/aggregation/form.do",
	            success:function (data) {
	                if(data.status === "SUCCESS"){
	                    parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
	                    	if(parent.window.aggregationManage){
	                    		parent.window.aggregationManage.refreshTree();
	                    	}
	                        Common.Close();
	                    });
	                } else {
	                    Common.Error(data.message);
	                }
	            },
	            error:function(response){
	                if(response.status === 400 && response.responseJSON){
	                    Common.Error(response.responseJSON.message);
	                } else {
	                    CFN_ErrorAjax("/approval/admin/aggregation/form.do", response, response.status, response.statusText);
	                }
	            }
	        });
	    };
	    
	    /*
	    * 집계함 Form 삭제
	    */
	    var deleteForm = function() {
    		Common.Confirm("<spring:message code='Cache.msg_apv_aggFormDelete'/>" // 양식 삭제시 권한, 필드 설정 또한 함께 삭제됩니다. 정말 삭제하시겠습니까?
	    			, "<spring:message code='Cache.lbl_delAggregationForm'/>" 
	    			, function(result){ 
	    		if(result){
		    		$.ajax({
		                type:"DELETE",
		                url:"/approval/admin/aggregation/form/" + aggFormId + ".do",
		                success:function (data) {
		                    if(data.status === "SUCCESS"){
		                    	if(parent.window.aggregationManage){
		                    		parent.window.aggregationManage.refreshGrid();
		                    	}
		                        Common.Close();
		                    } else {
		                        Common.Error(data.message);
		                    }
		                },
		                error:function(response){
		                    if(response.status === 400 && response.responseJSON){
		                        Common.Error(response.responseJSON.message);
		                    } else {
		                        CFN_ErrorAjax("/approval/admin/aggregation/forms[delete].do", response, response.status, response.statusText);
		                    }
		                }
		            });
	    		}
	    	});
	    };
	    
	    var formSelect = function(){
	        var popup = "formSelectPopup";
	        key = popup + new Date().getTime();
	        parent.Common.open("", popup,
	                "<spring:message code='Cache.lbl_apv_formchoice'/>",/* 양식 선택 */
	                "/approval/admin/aggregation/form/formSelect.do?entCode=" + entCode + "&key=" + key,
	                "400px","400px","iframe",true,null,null,true);
	    }
	    
	    this.bindFormData = function(pKey, pFormData){
	        if(key === pKey){
	            formData = pFormData;
	            document.querySelector('#form').value = CFN_GetDicInfo(formData.FormName);
	        } else {
	            Common.Error("<spring:message code='Cache.msg_ErrorOccurred'/>")
	        }
	    }
	    
	    init();
	};
	
	var aggregationForm = new AggregationForm();

	// 팝업 닫기
	function closeLayer() {
		Common.Close();
	}
	
</script>
