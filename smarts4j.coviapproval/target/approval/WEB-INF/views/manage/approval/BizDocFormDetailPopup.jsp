<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramBizDocFormID =  param[1].split('=')[1];

	$(document).ready(function(){					
		if(mode=="modify"){
			$("#btn_delete").show();
			modifySetData();			
		}
	});
	
		
	
	//수정화면 data셋팅
	function modifySetData(){
		//data 조회
		$.ajax({
			type:"POST",
			data:{
				"BizDocFormID" : paramBizDocFormID				
			},
			url:"getBizDocFormData.do",
			success:function (data) {
				if(Object.keys(data.list[0]).length > 0){					
					$("#FormPrefix").val(data.list[0].FormPrefix);				
					$("#FormName").val(data.list[0].FormName);
					$("#FormDisplayName").val(CFN_GetDicInfo(data.list[0].FormName));
					$("#SortKey").val(data.list[0].SortKey);					
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getBizDocFormData.do", response, status, error);
			}
		});
	}
	

	
	//저장
	function saveSubmit(){
		//data셋팅	
		var FormPrefix = $("#FormPrefix").val();				
		var FormName = $("#FormName").val();		
		var SortKey = $("#SortKey").val();		
		
	
		if (axf.isEmpty(SortKey)) {
			Common.Warning("<spring:message code='Cache.msg_apv_141' />");//정렬값은 숫자로 입력하십시오.
            return false;
        }
	
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{
				"BizDocFormID"   : paramBizDocFormID,
				"FormPrefix"   : FormPrefix,
				"FormName"   : FormName,						
				"SortKey"   : SortKey	
				
			},
			url:'updateBizDocForm.do',
			success:function (data) {
				if(data.result == "ok") {
					parent.Common.Inform("<spring:message code='Cache.msg_apv_117' />", "", function() { // 성공적으로 저장하였습니다.
						coviCmn.getParentFrameObj("updateBizForm").searchConfig();
						Common.Close();
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("updateBizDocForm.do", response, status, error);
			}
		});
	}
	
	//삭제
	function deleteSubmit(){
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				var BizDocFormID = paramBizDocFormID;
				
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"BizDocFormID" : BizDocFormID
					},
					url:"deleteBizDocForm.do",
					success:function (data) {
						if(data.result == "ok") {
							parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />", "", function() { // 성공적으로 삭제되었습니다.
								coviCmn.getParentFrameObj("updateBizForm").searchConfig();
								Common.Close();
							});
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteBizDocForm.do", response, status, error);
					}
				});
			}
		});
		
	}
		
	
</script>
<div class="sadmin_pop">		 		
	<table class="sadmin_table sa_menuBasicSetting" >
	  <colgroup>
		<col width="100px">
		<col width="*">
	  </colgroup>
	  <tbody>
	    <tr>
	      <th><spring:message code="Cache.lbl_apv_formcreate_LCODE02"/></th>
		  <td><input id="FormPrefix" name="FormPrefix" readonly="readonly" type="text" class="w100" maxlength="64" /></td>
	    </tr>
	    <tr>
	      <th><spring:message code="Cache.lbl_apv_formcreate_LCODE03"/></th>
		  <td>
		  	<input id="FormDisplayName" name="FormDisplayName" readonly="readonly" type="text" class="w100" maxlength="64" />
 			<input type="hidden" id="FormName" name="FormName" />
		  </td>
	    </tr>
		<tr>
	      <th><spring:message code="Cache.lbl_apv_SortKey"/></th>
		  <td><input mode="numberint"  num_max="32767"  num_min="0" class="w100"   id="SortKey" name="SortKey" type="text" maxlength="16"/></td>
	    </tr>	
      </tbody>
         
	</table>
	<div class="bottomBtnWrap">
		<a onclick="saveSubmit();" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_apv_save'/></a>
		<a id="btn_delete" onclick="deleteSubmit();" style="display: none"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_delete'/></a>
		<a onclick="Common.Close();"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>
	</div>
</div>
