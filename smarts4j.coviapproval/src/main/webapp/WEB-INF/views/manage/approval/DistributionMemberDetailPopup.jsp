<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramGroupMemberID =  param[1].split('=')[1];
	
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
				"GroupMemberID" : paramGroupMemberID
			},
			url:"getDistributionMemberData.do",
			success:function (data) {
				$("#UR_Name").text(data.list[0].UR_Name);
				$("#UserCode").text(data.list[0].UserCode);
				$("#DEPT_Name").text(data.list[0].DEPT_Name);
				$("#SortKey").val(data.list[0].SortKey);			
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getDistributionMemberData.do", response, status, error);
			}
		});
	}
	
	
	//저장
	function saveSubmit(){
		var SortKey = $("#SortKey").val(); 		
		
		if (axf.isEmpty(SortKey)) {
			parent.Common.Warning("<spring:message code='Cache.msg_apv_141' />");//정렬값은 숫자로 입력하십시오.
            return false;
        }
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{
				"GroupMemberID" : paramGroupMemberID,
				"SortKey" : SortKey					
			},
			url:"updateDistributionMember.do",
			success:function (data) {
				if(data.result == "ok"){
					parent.Common.Inform("<spring:message code='Cache.msg_apv_137' />");
					parent.searchConfig2();
					closeLayer();
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("updateDistributionMember.do", response, status, error);
			}
		});
	}
	
	//삭제
	function deleteSubmit(){
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"GroupMemberID" : paramGroupMemberID							
					},
					url:"deleteDistributionMember.do",
					success:function (data) {
						if(data.result == "ok"){
							parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />");
							parent.searchConfig2();
							closeLayer();
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteDistributionMember.do", response, status, error);
					}
				});
			}
		});
	}
	
</script>

<form id="DocFolderManagerSetPopup" name="DocFolderManagerSetPopup">
	<div class="sadmin_pop">
            <table class="sadmin_table sa_menuBasicSetting mb20" >
                <colgroup>
                    <col id="t_tit4" width="100px;">
                    <col id="" width="*">
                </colgroup>
                <tbody>
                    <tr>                        
                        <th><spring:message code='Cache.lbl_DistributionTarget'/></th>
                        <td id="UR_Name">                            
                        </td>
                    </tr>
                    <tr>
                        <th><spring:message code='Cache.lbl_ID'/></th>
                        <td id="UserCode">                        
                        </td>
                    </tr>
                    <tr>
                        <th><spring:message code='Cache.lbl_DeptName'/></th>
                        <td id="DEPT_Name">                            
                        </td>
                    </tr>
                    <tr>
                        <th style="weight:400px;"><spring:message code='Cache.lbl_apv_SortKey'/></th>
                        <td>
                            <input name="SortKey"  mode="numberint"  num_max="32767"  class=""  id="SortKey" type="text" maxlength="250"  style="" />                            
                        </td>
                    </tr>
                </tbody>
            </table>        
            <div class="bottomBtnWrap">
				<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveSubmit();" ><spring:message code="Cache.btn_apv_save"/></a>
				<a href="#" class="btnTypeDefault" onclick="deleteSubmit();"><spring:message code="Cache.btn_apv_delete"/></a>
				<a href="#" class="btnTypeDefault" onclick="closeLayer();"><spring:message code="Cache.btn_apv_close"/></a>
			</div>      
        </div>

        <input type="hidden" name="EntCode" id="EntCode" />        
        <input type="hidden" name="ParentDocClassID" id="ParentDocClassID" />
</form>