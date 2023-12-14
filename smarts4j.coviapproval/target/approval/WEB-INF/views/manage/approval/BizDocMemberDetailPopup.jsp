<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramBizDocMemberID =  param[1].split('=')[1];
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가

	$(document).ready(function(){					
		if(mode=="modify"){
			$("#btn_delete").show();
			modifySetData();			
		}
	});
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
		
	
	//수정화면 data셋팅
	function modifySetData(){
		//data 조회
		$.ajax({
			type:"POST",
			data:{
				"BizDocMemberID" : paramBizDocMemberID				
			},
			url:"getBizDocMemberData.do",
			success:function (data) {					
				if(Object.keys(data.list[0]).length > 0){					
					$("#UR_Code").val(data.list[0].UR_Code);				
					$("#UR_Name").val(data.list[0].UR_Name);
					$("#DEPT_NAME").val(data.list[0].DEPT_NAME);
					$("#SortKey").val(data.list[0].SortKey);					
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getBizDocMemberData.do", response, status, error);
			}
		});
	}
	

	
	//저장
	function saveSubmit(){
		//data셋팅			
		var SortKey = $("#SortKey").val();
		
		if (axf.isEmpty(SortKey)) {
			parent.Common.Warning("<spring:message code='Cache.msg_apv_141' />");//정렬값은 숫자로 입력하십시오.
            return false;
        }
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{
				"BizDocMemberID"   : paramBizDocMemberID,								
				"SortKey"   : SortKey
			},
			url:'updateBizDocMember.do',
			success:function (data) {
				if(data.result == "ok"){
					parent.Common.Inform("<spring:message code='Cache.msg_apv_117' />", "", function() { // 성공적으로 저장하였습니다.
						parent.searchConfig();
						closeLayer();
					}); 
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("updateBizDocMember.do", response, status, error);
			}
		});
	}
	
	
	//삭제
	function deleteSubmit(){
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				var BizDocMemberID = paramBizDocMemberID;
				
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"BizDocMemberID" : BizDocMemberID
					},
					url:"deleteBizDocMember.do",
					success:function (data) {
						if(data.result == "ok"){
							parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />", "", function() { // 성공적으로 삭제되었습니다.
								parent.searchConfig();
								closeLayer();
							}); 
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteBizDocMember.do", response, status, error);
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
	      <th><spring:message code="Cache.lbl_apv_ChargerName"/></th>
		  <td><input id="UR_Name" name="UR_Name" readonly="readonly" type="text" class="w100" maxlength="64" /></td>
	    </tr>
	    <tr>
	      <th><spring:message code="Cache.lbl_apv_ChargerCode"/></th>
		  <td><input id="UR_Code" name="UR_Code" readonly="readonly" type="text" class="w100" maxlength="64" /></td>
	    </tr>
	    <tr>
	      <th><spring:message code="Cache.lbl_apv_AdminDept"/></th>
		  <td><input id="DEPT_NAME" name="DEPT_NAME" readonly="readonly" type="text" class="w100" maxlength="64" /></td>
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
		<a onclick="closeLayer();"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>
	</div>
</div>