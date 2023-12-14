<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<form id="form1">
	<div class="sadmin_pop">
		<table class="sadmin_table sa_menuBasicSetting mb20">
			<colgroup>
				<col style="width:35%" />
				<col style="width:65%" />
			</colgroup>
			<tbody>
				<tr style="display:none;">
					<th><spring:message code="Cache.lbl_Domain"/></th><!-- 도메인 -->
					<td>
						<!-- <div style="display:none;"><select name="companys" class="AXSelect"></select></div>
						<span id="dp_companys"></span> -->
						<input type="hidden" id="entcode" name="entcode" />
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_apv_form"/></th><!-- 양식 -->
					<td>
						<input type="text" id="form" class="menuName04 mr0" disabled="true" style="" />
						<a href="#" id="formSelectBtn" class="btnTypeDefault" style="display:none;"><spring:message code="Cache.lbl_apv_selection"/></a> 
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_isDisplayInAggBox"/></th><!-- 집계함 노출 여부 -->
					<td>
						<select name="displayYN" class="">
							<option value="Y" selected="selected"><spring:message code="Cache.lbl_exposure"/></option><!-- 노출 -->
							<option value="N"><spring:message code="Cache.lbl_notExposure"/></option><!-- 노출하지 않음 -->
						</select>
					</td>
				</tr>
			</tbody>
		</table>
		<div class="bottomBtnWrap">
			<a id="btnAdd" href="#" class="btnTypeDefault btnTypeBg" style="display:none;"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->
			<a id="btnModify" href="#" class="btnTypeDefault btnTypeBg" style="display:none;"><spring:message code="Cache.btn_apv_update"/></a> <!-- 수정 -->
			<a id="btnDelete" href="#" class="btnTypeDefault" style="display:none;"><spring:message code="Cache.btn_apv_delete"/></a> <!-- 삭제 -->
			<a href="#" class="btnTypeDefault" onclick="closeLayer();" ><spring:message code="Cache.btn_apv_close"/></a>
		</div>
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
	        
			$("#entcode").val(entCode);
			
	        if(aggFormId != "undefined"){ // 수정
	        	getFormInfo();
	        	$(modifyBtn).show();
	        	$(deleteBtn).show();
	        	modifyBtn.addEventListener("click", modifyForm);
	        	deleteBtn.addEventListener("click", deleteForm);
	        }else{ // 추가
	        	$(addBtn).show();
	        	$(formSelectBtn).show();
	        	addBtn.addEventListener("click", addForm);
	        	formSelectBtn.addEventListener("click", formSelect);
	        }
	    };
	
	    var getFormData = function(){
	        return {
	            entCode : document.querySelector("[name=entcode]").value,
	            formPrefix : formData.FormPrefix,
	            displayYN : document.querySelector("[name=displayYN]").value,
	            userCode : Common.getSession("UR_Code")
	        };
	    };
	    
	    var getFormInfo = function(){
	        var selFormData = parent.window.aggregationManage.selectedForm;
	        formData = {FormDesc:"", FormName:selFormData.formName, FormPrefix:selFormData.formPrefix};
         	document.querySelector('#form').value = CFN_GetDicInfo(selFormData.formName);
         	$("[name=displayYN]").val(selFormData.displayYN);
	    };
	    
	    var modifyForm = function(){
	    	var tmpFormData = getFormData();
	    	tmpFormData.aggFormId = aggFormId;
	        $.ajax({
	            type:"PUT",
	            data:JSON.stringify(tmpFormData),
	            contentType: 'application/json; charset=utf-8',
	            url:"/approval/manage/aggregation/form/" + aggFormId + ".do",
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
	                    CFN_ErrorAjax("/approval/manage/aggregation/form.do", response, response.status, response.statusText);
	                }
	            }
	        });
	    };
	    
	    var addForm = function(){
	        $.ajax({
	            type:"POST",
	            data:JSON.stringify(getFormData()),
	            contentType: 'application/json; charset=utf-8',
	            url: "/approval/manage/aggregation/form.do",
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
	                    CFN_ErrorAjax("/approval/manage/aggregation/form.do", response, response.status, response.statusText);
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
		                url:"/approval/manage/aggregation/form/" + aggFormId + ".do", // formData.aggFormId
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
		                        CFN_ErrorAjax("/approval/manage/aggregation/forms[delete].do", response, response.status, response.statusText);
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
	                "/approval/manage/aggregation/form/formSelect.do?entCode=" + entCode + "&key=" + key,
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
