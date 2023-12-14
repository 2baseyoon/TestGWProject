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
			<col style="width:25%" />
			<col style="width:75%" />
		</colgroup>
		<tbody>
			<tr>
				<th><spring:message code="Cache.lbl_Domain"/></th><!-- 도메인 -->
				<td>
					<div style="display:none;"><select name="companys" class="AXSelect" display:none;></select></div>
					<span id="dp_companys"></span>
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_FieldId"/></th><!-- 필드ID -->
				<td>
					<select name="fieldIds" class="AXSelect">
						<option value="Subject">Subject</option>
						<option value="InitiatorName">InitiatorName</option>
						<option value="InitiatorUnitName">InitiatorUnitName</option>
						<option value="InitiatedDate">InitiatedDate</option>
						<option value="CompletedDate">CompletedDate</option>
						<option value="DocNo">DocNo</option>
						<option value="IsFile">IsFile</option>
					</select>
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_FieldNm"/></th><!-- 필드명 -->
				<td id="fieldNmContainer">
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_ItemProcessing"/></th><!-- 항목 처리 -->
				<td>
					<select name="dataFormat" class="AXSelect">
						<option value=""><spring:message code="Cache.lbl_NotApplicable"/></option><!-- 해당없음 -->
						<option value="dictionary"><spring:message code="Cache.lbl_MultiLang2"/></option><!-- 다국어 -->
						<option value="dateFormat"><spring:message code="Cache.lbl_date"/>(YYYY-MM-DD)</option><!-- 날짜(YYYY-MM-DD) -->
						<option value="formOpen"><spring:message code="Cache.lbl_openApprovalDoc"/></option><!-- 결재문서 열기 -->
						<option value="linkFile"><spring:message code="Cache.lbl_apv_filelink"/></option><!-- 첨부파일 링크 -->
					</select>
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_apv_Sort"/></th><!-- 정렬 -->
				<td>
					<input type="number" name="sortKey" class="AXInput" />
				</td>
			</tr>
		</tbody>
	</table>
	<div class="center mt12">
		<input type="button" id="btnAdd" class="AXButton" value="<spring:message code='Cache.btn_Add'/>" />
		<input type="button" id="btnModify" class="AXButton" value="<spring:message code='Cache.btn_Modify'/>" />
		<input type="button" id="btnDelete" class="AXButton" value="<spring:message code='Cache.btn_Delete'/>" />
	</div>
</form>
<script>
	var AggregationCommonField = function(){
	    var addBtn = document.querySelector("#btnAdd");
	    var modifyBtn = document.querySelector("#btnModify");
	    var deleteBtn = document.querySelector("#btnDelete");
	    var key;
	    var url;
	    
	    var init = function(){
	        var mode = CFN_GetQueryString("mode");
	        key = CFN_GetQueryString("key");
	        var BASE_URL = "/approval/admin/aggregation/form/commonfield";
	        
	        coviDic.renderInclude('fieldNmContainer', {
				//lang : langCode,
				lang : 'ko',
				hasTransBtn : 'true',
				allowedLang : 'ko,en,ja,zh',
				dicCallback : '',
				popupTargetID : '',
				init : '',
				styleType : 'T'
			});
			$("#fieldNmContainer").find(".AXFormTable").css("box-shadow", "none");
			$("#fieldNmContainer").find(".AXFormTable tbody td").css("border-right", "0px !important");
			$("#fieldNmContainer").find(".AXFormTable tbody th:last").css("border-bottom", "0px");
			$("#fieldNmContainer").find("input[id$='_full']").attr("maxlength", 50);
	        
	        $("[name=companys]").bindSelect({
	            reserveKeys: {
	                options: "list",
	                optionValue: "optionValue",
	                optionText: "optionText"
	            },
	            ajaxUrl: "/approval/common/getEntInfoListAssignData.do",			
	            ajaxAsync:false
	        });
	        
	        $(".AXSelect").bindSelect();			
	        
	        if(mode === "m"){
	            url = BASE_URL + "/" + key + ".do";
	            initForModify();
	        } else {
	        	key = "";
	            url = BASE_URL + ".do";
	            initForAdd();
	        }
	    };

	    var initForAdd = function(){
	        modifyBtn.remove();
	        deleteBtn.remove();
	        addBtn.addEventListener("click", addCommonField);

	        var entCode = CFN_GetQueryString("entCode");
	        if(entCode && entCode !== "undefined"){
        		$('[name=companys]').bindSelectSetValue(entCode);
        		$("#dp_companys").text($("[name=companys] :selected").text());
	        }
	    };
	    
	    var initForModify = function(){       
	        addBtn.remove();
	        modifyBtn.addEventListener("click", modifyCommonField);
	        deleteBtn.addEventListener("click", deleteCommonField);
	        getData();
	    };
	    
	    var getFormData = function(){
	        return {
	            entCode : document.querySelector("[name=companys]").value,
	            fieldName : coviDic.convertDic(coviDic.makeDic()),
	            fieldId : document.querySelector("[name=fieldIds]").value,
	            dataFormat : document.querySelector("[name=dataFormat]").value,
	            sortKey : document.querySelector("[name=sortKey]").value,
	            aggFieldId : key
	        };
	    };
	    
	    var addCommonField = function(){
	        $.ajax({
	            type:"POST",
	            data:JSON.stringify(getFormData()),
	            contentType: 'application/json; charset=utf-8',
	            url:url,
	            success:function (data) {
	                if(data.status === "SUCCESS"){
	                    parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
	                    	parent.setList();
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
	                    CFN_ErrorAjax(url, response, response.status, response.statusText);
	                }
	            }
	        });
	    };
	
	    var modifyCommonField = function(){
	        $.ajax({
	            type:"PUT",
	            data:JSON.stringify(getFormData()),
	            contentType: 'application/json; charset=utf-8',
	            url:url,
	            success:function (data) {
	                if(data.status === "SUCCESS"){
	                    parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
	                    	parent.setList();
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
	                    CFN_ErrorAjax(url, response, response.status, response.statusText);
	                }
	            }
	        });
	    };
	
	    var deleteCommonField = function(){
	    	Common.Confirm("<spring:message code='Cache.msg_apv_093'/>" , "" , function(result){ // 삭제하시겠습니까?
	    		if(result){
		    		$.ajax({
			            type:"DELETE",
			            data:JSON.stringify(getFormData()),
			            contentType: 'application/json; charset=utf-8',
			            url:url,
			            success:function (data) {
			                if(data.status === "SUCCESS"){
			                    parent.Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
			                    	parent.setList();
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
			                    CFN_ErrorAjax(url, response, response.status, response.statusText);
			                }
			            }
			        });
	    		}
	    	});
	    };
	    
	    var getData = function(){
	        $.ajax({
	            type:"GET",
	            contentType: 'application/json; charset=utf-8',
	            url:url,
	            success:function (data) {
	                if(data.status === "SUCCESS"){
	                	const { entCode, fieldId, fieldName, sortKey, dataFormat } = data.info;
	                	$('[name=companys]').bindSelectSetValue(entCode);
	                	$("#dp_companys").text($("[name=companys] :selected").text());
	                	coviDic.bindData(fieldName);
	                	$('[name=fieldIds]').bindSelectSetValue(fieldId);
	                	$('[name=fieldIds]').bindSelectDisabled(true);
	    	            //document.querySelector("[name=dataFormat]").value = dataFormat;
	    	            $('[name=dataFormat]').bindSelectSetValue(dataFormat);
	    	            document.querySelector("[name=sortKey]").value = sortKey;
	                } else {
	                    Common.Error(data.message);
	                }
	            },
	            error:function(response){
	                if(response.status === 400 && response.responseJSON){
	                    Common.Error(response.responseJSON.message);
	                } else {
	                    CFN_ErrorAjax(url, response, response.status, response.statusText);
	                }
	            }
	        });
	    };
	    
	    init();
	};
	
	new AggregationCommonField();

</script>
