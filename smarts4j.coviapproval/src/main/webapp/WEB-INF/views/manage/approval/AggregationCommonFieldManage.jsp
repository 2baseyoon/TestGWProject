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
				<col style="width:25%" />
				<col style="width:75%" />
			</colgroup>
			<tbody>
				<tr style="display:none;">
					<th><spring:message code="Cache.lbl_Domain"/></th><!-- 도메인 -->
					<td>
						<!-- <div style="display:none;"><select name="companys" class="AXSelect" display:none;></select></div>
						<span id="dp_companys"></span> -->
						<input type="hidden" id="entcode" name="entcode" />
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_FieldId"/></th><!-- 필드ID -->
					<td>
						<select name="fieldIds" class="selectType02 menuName04">
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
					<td id="fieldNmContainer" style="padding:0px;">
					</td>
				</tr>
				<tr>
					<th><spring:message code="Cache.lbl_ItemProcessing"/></th><!-- 항목 처리 -->
					<td>
						<select name="dataFormat" class="selectType02 menuName04">
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
						<input type="number" name="sortKey" class="menuName04" />
					</td>
				</tr>
			</tbody>
		</table>
		<div class="bottomBtnWrap">
			<a id="btnAdd" href="#" class="btnTypeDefault btnTypeBg" ><spring:message code="Cache.btn_apv_add"/></a>
			<a id="btnModify" href="#" class="btnTypeDefault btnTypeBg" ><spring:message code="Cache.btn_Modify"/></a>
			<a id="btnDelete" href="#" class="btnTypeDefault"><spring:message code="Cache.btn_apv_delete"/></a>
			<a href="#" class="btnTypeDefault" onclick="closeLayer();" ><spring:message code="Cache.btn_apv_close"/></a>
		</div>
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
	        var BASE_URL = "/approval/manage/aggregation/form/commonfield";
	        
	        coviDic.renderInclude('fieldNmContainer', {
	            lang : 'ko',
	            hasTransBtn : 'true',
	            allowedLang : 'ko,en,ja,zh',
	            dicCallback : '',
	            popupTargetID : '',
	            init : '',
	            styleType : 'U'
	        });
	        $("#fieldNmContainer").find("table.sadmin_table").addClass("sadmin_inside_table");
	        
	        /*
	        $("[name=companys]").bindSelect({
	            reserveKeys: {
	                options: "list",
	                optionValue: "optionValue",
	                optionText: "optionText"
	            },
	            ajaxUrl: "/approval/common/getEntInfoListAssignData.do",			
	            ajaxAsync:false
	        });
	        */
	        
	        //$(".AXSelect").bindSelect();			
	        
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
        		//$('[name=companys]').bindSelectSetValue(entCode);
        		//$("#dp_companys").text($("[name=companys] :selected").text());
        		$("#entcode").val(entCode);
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
	            entCode : document.querySelector("[name=entcode]").value,
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
	                	//$('[name=companys]').bindSelectSetValue(entCode);
	                	//$("#dp_companys").text($("[name=companys] :selected").text());
	                	$("#entcode").val(entCode);
	                	coviDic.bindData(fieldName);
	                	$('[name=fieldIds]').val(fieldId);
	                	$('[name=fieldIds]').attr("disable",true);
	                	$('[name=dataFormat]').val(dataFormat);
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

	// 팝업 닫기
	function closeLayer() {
		Common.Close();
	}
</script>
