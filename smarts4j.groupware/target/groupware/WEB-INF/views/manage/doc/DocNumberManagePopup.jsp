<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
		
<form>
	<div class="sadmin_pop">
	    <table class="sadmin_table" >       
	    	<colgroup>
				<col style="width: 110px ;"></col>
				<col></col>
				<col style="width: 110px ;"></col>
				<col></col>
	    	</colgroup>       
	        <tbody>
	        	<tr>
	        		<th><spring:message code='Cache.lbl_PriorityOrder'/></th> 	<!-- 우선순위 -->
	                <td><input type="text"  id="txtSeq"  style="width: 90%;" disabled/></td>
	                <th><spring:message code='Cache.lbl_FieldType'/> </th> 			<!-- 필드유형 -->
	                <td><select id="selectFieldType" name="fieldType" class="selectType04"></select></td>
	            </tr>
	        	<tr>
	              	<th><spring:message code='Cache.lbl_FieldSize'/> <font color="red">*</font></th> 	<!-- 필드크기 -->
	                <td><input type="text"  id="txtFieldLength" name="fieldLength" /></td>
	                <th><spring:message code='Cache.lbl_DicModify'/> </th> 		<!-- 언어설정 -->
	                <td><select id="selectLanguageCode" name="languageCode" class="selectType04"></select></td>
	            </tr>
	            <tr>
	                <th><spring:message code='Cache.lbl_Gubun'/> </th> 	<!-- 구분 -->
	                <td><select id="selectSeparator" name="separator" class="selectType04"></select></td>
	                <th><spring:message code='Cache.lbl_selUse'/> </th>	<!-- 사용 유무 -->
	                <td>
	                	<select id="selectIsUse" name="isUse" class="selectType04">
							<option value=""><spring:message code='Cache.lbl_Choice'/></option>
							<option value="Y"><spring:message code='Cache.lbl_USE_Y'/></option>
							<option value="N"><spring:message code='Cache.lbl_noUse'/></option>
						</select> 	                  
	                </td>
	            </tr>
	        </tbody>
	    </table>      
	    <div class="pop_btn2" align="center">
	     	<a onclick="setDocNumber();"  class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_apv_save'/></a> 	<!-- 저장 -->            
	     	<a onclick="Common.Close();"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>     			<!-- 닫기 -->                
	    </div>           
	</div>
	<input type="hidden" id ="mode" value = "${mode}"/>
	<input type="hidden" id ="selCategoryID" value = ""/>
	<input type="hidden" id="_ParentID" value= ""/>
</form>
<script  type="text/javascript">

(function() {
	var domainID = CFN_GetQueryString("domainID");
	var managerID = CFN_GetQueryString("managerID");
	var mode = CFN_GetQueryString("mode");
	var domainList = ${domainList};

	var initFunc = function () {
		$("#selectFieldType").coviCtrl("setSelectOption", "/groupware/board/manage/selectBaseCodeList.do", {codeGroup: "NumberFieldType", "domainID": domainID});
		$("#selectLanguageCode").coviCtrl("setSelectOption", "/groupware/board/manage/selectBaseCodeList.do", {codeGroup: "LanguageCode", "domainID": domainID});
		$("#selectSeparator").coviCtrl("setSelectOption", "/groupware/board/manage/selectBaseCodeList.do", {codeGroup: "Separator", "domainID": domainID});

		if(mode != 'create'){
			selectDocNumberInfo();
		}
	};
	
	var selectDocNumberInfo = function () {
		$.ajax({
			type:"POST",
			data:{
				'managerID': managerID 
			},
			async : false,
			url:"/groupware/board/manage/selectDocNumberInfo.do",
			success:function (data) {
				if(data.status == 'SUCCESS'){
					var info = data.list[0];
					$("#selectFieldType").val(info.FieldType);
					$("#selectLanguageCode").val(info.LanguageCode);
					$("#selectIsUse").val(info.IsUse);
					$("#selectSeparator").val(info.Separator == "" ? "none" : info.Separator);
					$("#txtFieldLength").val(info.FieldLength);
					$("#txtSeq").val(info.Seq);
				}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/manage/selectDocNumberInfo.do", response, status, error);
			}
		});
	}
	
	var checkValidation = function () {
		var flag = false;
		
		if($("#selectIsUse").val() === ''){
			parent.Common.Warning("<spring:message code='Cache.msg_Common_04'/>", "Warning Dialog", function () {});		// 사용유무를 선택하여 주십시오.
			return false;
		}
		
		if($("#txtFieldLength").val() == '' || $("#txtFieldLength").val() == null){
			parent.Common.Warning("<spring:message code='Cache.lbl_FieldSize'/> <spring:message code='Cache.CPMail_quickReplayContEmpty_msg'/>", "Warning Dialog", function () {  	// 필드 크기 내용을 입력해주세요
				$("#txtFieldLength").focus();
	        });
			return false;
		}
		
		return true;
	}
	
	// 저장(신규/수정)
	this.setDocNumber = function () {
		if(checkValidation()){
			$.ajax({
				type:"POST",
				data:{
					'mode': mode,
					'managerID': managerID,
					'domainID': domainID,
					'seq': $("#txtSeq").val(),
					'fieldType': $("#selectFieldType").val(),
					'fieldLength': $("#txtFieldLength").val(),
					'languageCode': $("#selectLanguageCode").val(),
					'separator': $("#selectSeparator").val()!="none"?$("#selectSeparator").val():"",
					'isUse': $("#selectIsUse").val()
				},
				async : false,
				url:"/groupware/board/manage/setDocNumber.do",
				success:function (data) {
					if(data.status === 'SUCCESS'){
						Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ 	// 저장되었습니다.
							// postMessage for callback.
							window.parent.postMessage({functionName : "docNumMngPop", param1 : "callback_setDocNumber"}, "*");
			    			Common.Close();
				    	});
		    		}else{
		    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");  // 저장 중 오류가 발생하였습니다.
		    		}
				},
				error:function(response, status, error){
				     CFN_ErrorAjax("/groupware/board/manage/setDocNumber.do", response, status, error);
				}
			});
		}
	}
	
	initFunc();
	
})();

</script>