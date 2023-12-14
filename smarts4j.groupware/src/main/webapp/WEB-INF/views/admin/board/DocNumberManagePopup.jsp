<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
		
<form>
	<div class="pop_body1" style="width:100%;min-height: 100%">
	    <table class="AXFormTable" >       
	    	<colgroup>
				<col style="width: 110px ;"></col>
				<col></col>
	    	</colgroup>       
	        <tbody>
	        	<tr>
	                <th><spring:message code='Cache.lbl_OwnedCompany'/> </th>
	                <td colspan="3">   
	                	<select id="selectDomainID" name="domainID" class="AXSelect W100">
						</select>        	           
	                </td>
	            </tr>
	        	<tr>
	        		<th><spring:message code='Cache.lbl_PriorityOrder'/> </th>
	                <td>   
	                	<input type="text" class="AXInput" id="txtSeq"  style="width: 90%;" disabled/>                   
	                </td>
	                <th>필드유형 </th>
	                <td>   
	                	<select id="selectFieldType" name="fieldType" class="AXSelect">
	                	</select>                   
	                </td>
	            </tr>
	        	<tr>
	              	<th>필드크기 <font color="red">*</font></th>
	                <td>   
	                	<input type="text" class="AXInput" id="txtFieldLength" name="fieldLength"  style="width: 90%;"/>                   
	                </td>
	                <th>언어 </th>
	                <td>   
	                	<select id="selectLanguageCode" name="languageCode" class="AXSelect">
	                	</select>                   
	                </td>
	            </tr>
	            <tr>
	                <th>구분 </th>
	                <td>   
	                	<select id="selectSeparator" name="separator" class="AXSelect">
	                	</select>                   
	                </td>
	                <th><spring:message code='Cache.lbl_selUse'/> <font color="red">*</font></th>	<!-- 사용 유무 -->
	                <td>   
	                	<select id="selectIsUse" name="isUse" class="AXSelect W100">
							<option value=""><spring:message code='Cache.lbl_Choice'/></option>
							<option value="Y"><spring:message code='Cache.lbl_USE_Y'/></option>
							<option value="N"><spring:message code='Cache.lbl_noUse'/></option>
						</select> 	                  
	                </td>
	            </tr>
	           
	        </tbody>
	    </table>        
	    <div class="pop_btn2" align="center">
	     	<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="setDocNumber();" class="AXButton red" />
	     	<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="Common.Close();"  class="AXButton" />                    
	    </div>           
	</div>
	<input type="hidden" id ="mode" value = "${mode}"/>
	<input type="hidden" id ="selCategoryID" value = ""/>
	<input type="hidden" id="_ParentID" value= ""/>
</form>
<script  type="text/javascript">
var domainID = CFN_GetQueryString("domainID");
var managerID = CFN_GetQueryString("managerID");
var mode = CFN_GetQueryString("mode");
var domainList = ${domainList};

$(document).ready(function(){	
	init();
});

function init(){
	$("#selectDomainID").coviCtrl("setSelectOption", "/groupware/admin/selectDomainList.do");
	
	// 21.12.02 : CFN_GetQueryString("domainID") 통해서 domainID를 못 받아왔을 경우, 위의 동작을 통해 가져온 $("#selectDomainID").val() 통해 값을 지정.
	if (domainID === 'undefined') {
		domainID = $("#selectDomainID").val();
	}
	else {
		$("#selectDomainID").val(domainID);
	}
	
	$("#selectFieldType").coviCtrl("setSelectOption", "/groupware/admin/selectBaseCodeList.do", {codeGroup: "NumberFieldType", "domainID": domainID});
	$("#selectLanguageCode").coviCtrl("setSelectOption", "/groupware/admin/selectBaseCodeList.do", {codeGroup: "LanguageCode", "domainID": domainID});
	$("#selectSeparator").coviCtrl("setSelectOption", "/groupware/admin/selectBaseCodeList.do", {codeGroup: "Separator", "domainID": domainID});

	if(mode != 'create'){
		selectDocNumberInfo();
	}
}

function selectDocNumberInfo(){
	$.ajax({
		type:"POST",
		data:{
			'managerID': managerID 
		},
		async : false,
		url:"/groupware/admin/selectDocNumberInfo.do",
		success:function (data) {
			if(data.status == 'SUCCESS'){
				var info = data.list[0];
				$("#selectDomainID").val(info.DomainID);
				$("#selectFieldType").val(info.FieldType);
				$("#selectLanguageCode").val(info.LanguageCode);
				$("#selectIsUse").val(info.IsUse);
				$("#selectSeparator").val(info.Separator == "" ? "none" : info.Separator);
				$("#txtFieldLength").val(info.FieldLength);
				$("#txtSeq").val(info.Seq);
			}
		},
		error:function(response, status, error){
		     CFN_ErrorAjax("/groupware/admin/selectDocNumberInfo.do", response, status, error);
		}
	});
}

function checkValidation(){
	var flag = false;
	
	if($("#selectDomainID").val() == ''){
		parent.Common.Warning("<spring:message code='Cache.msg_Common_38'/>", "Warning Dialog", function () { 
        });
		return false;
	}
	
	if($("#selectIsUse").val() == ''){
		parent.Common.Warning("<spring:message code='Cache.msg_Common_04'/>", "Warning Dialog", function () { 
        });
		return false;
	}
	
	if($("#txtFieldLength").val() == '' || $("#txtFieldLength").val() == null){
		parent.Common.Warning("필드 크기를 입력해주세요.", "Warning Dialog", function () { 
			$("#txtFieldLength").focus();
        });
		return false;
	}
	
	return true;
}

function setDocNumber(){
	if(checkValidation()){
		$.ajax({
			type:"POST",
			data:{
				'mode': mode,
				'managerID': managerID,
				'domainID': $("#selectDomainID").val(),
				'seq': $("#txtSeq").val(),
				'fieldType': $("#selectFieldType").val(),
				'fieldLength': $("#txtFieldLength").val(),
				'languageCode': $("#selectLanguageCode").val(),
				'separator': $("#selectSeparator").val()!="none"?$("#selectSeparator").val():"",
				'isUse': $("#selectIsUse").val()
			},
			async : false,
			url:"/groupware/admin/setDocNumber.do",
			success:function (data) {
				if(data.status == 'SUCCESS'){
					Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
						if(parent.lowerMsgGrid != undefined){
							//parent.lowerMsgGrid.reloadList();
							parent.selectDocNumberGridList();
						}		    			
		    			Common.Close();
			    	});
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/admin/selectDocNumberInfo.do", response, status, error);
			}
		});
	}
}
</script>