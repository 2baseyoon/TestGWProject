<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
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
					parent.Common.Inform("<spring:message code='Cache.msg_apv_137' />", "", function() {
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
							parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />", "", function() {
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
<form id="BizDocFormDetailPopup" name="BizDocListSetPopup">
	<div>		 		
		<table class="AXFormTable" >
		  <colgroup>
			<col id="t_tit4">
			<col id="">
		  </colgroup>
		  <tbody>
		    <tr>
		      <th style="width: 85px ;"><spring:message code="Cache.lbl_apv_formcreate_LCODE02"/></th>
			  <td><input id="FormPrefix" name="FormPrefix" readonly="readonly" type="text" class="AXInput" maxlength="64" style="width:350px;"/></td>
		    </tr>
		    <tr>
		      <th style="width: 85px ;"><spring:message code="Cache.lbl_apv_formcreate_LCODE03"/></th>
			  <td>
			  	<input id="FormDisplayName" name="FormDisplayName" readonly="readonly" type="text" class="AXInput" maxlength="64" style="width:350px;"/>
  				<input type="hidden" id="FormName" name="FormName" />
			  </td>
		    </tr>
			<tr>
		      <th style="width: 85px ;"><spring:message code="Cache.lbl_apv_SortKey"/></th>
			  <td><input mode="numberint"  num_max="32767"  num_min="0" class="AXInput"   id="SortKey" name="SortKey" type="text" maxlength="16" style="width:350px;"/></td>
		    </tr>	
	      </tbody>
          
		</table>
		<div align="center" style="padding-top: 10px">
			<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveSubmit();" class="AXButton red" />
			<input type="button" id="btn_delete" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="deleteSubmit();" style="display: none"  class="AXButton" />
			<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="Common.Close();"  class="AXButton" />
		</div>
	</div>
</form>