<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramJobFunctionMemberID =  param[1].split('=')[1];
	
	$(document).ready(function(){		
		modifySetData()
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
				"JobFunctionMemberID" : paramJobFunctionMemberID				
			},
			url:"getJobFunctionMemberData.do",
			success:function (data) {
				$("#UR_Name").text(data.list[0].UR_Name);
				$("#UserCode").text(data.list[0].UserCode);
				$("#DEPT_NAME").text(data.list[0].DEPT_NAME);
				$("#SortKey").val(data.list[0].SortKey);			
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getJobFunctionMemberData.do", response, status, error);
			}
		});
	}
	
	
	//저장
	function saveSubmit(){
		var SortKey = $("#SortKey").val(); 		
		
        if (axf.isEmpty(SortKey)) {
            parent.Common.Warning("<spring:message code='Cache.msg_apv_297' />"); //정렬순서를 입력하세요  
            return false;
    	}
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{
				"JobFunctionMemberID" : paramJobFunctionMemberID,
				"SortKey" : SortKey					
			},
			url:"updateJobFunctionMember.do",
			success:function (data) {
				if(data.result == "ok"){
					parent.Common.Inform("<spring:message code='Cache.msg_apv_117' />", "", function() { // 성공적으로 저장하였습니다.
						parent.searchConfig();
						closeLayer();
					});
				}				
								
			},
			error:function(response, status, error){
				CFN_ErrorAjax("updateJobFunctionMember.do", response, status, error);
			}
		});
		
	}
	
	
	//삭제
	function deleteSubmit(){
		parent.Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"JobFunctionMemberID" : paramJobFunctionMemberID							
					},
					url:"deleteJobFunctionMember.do",
					success:function (data) {
						if(data.result == "ok"){
							parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />", "", function() { // 성공적으로 삭제되었습니다.
								parent.searchConfig();
								closeLayer();
							});
						}				
										
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteJobFunctionMember.do", response, status, error);
					}
				});
			}
		});
	}
	
</script>
<div class="sadmin_pop">		 		
			<table class="sadmin_table sa_menuBasicSetting" >
                <colgroup>
                    <col id="t_tit4" width="100px">
                    <col id="">
                </colgroup>
                <tbody>
                    <tr>
                        <th><spring:message code='Cache.lbl_apv_ChargerName'/></th>
                        <td id="UR_Name">                            
                        </td>
                    </tr>
                    <tr>
                        <th><spring:message code='Cache.lbl_apv_ChargerCode'/></th>
                        <td id="UserCode" >                            
                        </td>
                    </tr>
                    <tr>
                        <th><spring:message code='Cache.lbl_apv_AdminDept'/></th>
                        <td id="DEPT_NAME" >                            
                        </td>
                    </tr>
                    <tr>
                        <th><spring:message code='Cache.lbl_apv_SortKey'/></th>
                        <td>
                            <input name="SortKey"  mode="numberint"  num_max="32767"  class="w100"  id="SortKey" type="text" maxlength="250"/>                            
                        </td>
                    </tr>
                </tbody>
            </table>        
			<div class="bottomBtnWrap">
				<a onclick="saveSubmit();" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_apv_save'/></a>
				<a onclick="deleteSubmit();" class="btnTypeDefault" ><spring:message code='Cache.btn_apv_delete'/></a>
				<a onclick="closeLayer();"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>
			</div>           
</div>