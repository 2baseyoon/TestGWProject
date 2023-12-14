<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramVerNum =  param[1].split('=')[1];
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가

	$(document).ready(function(){	
		if(mode=="modify"){
			//$("#btn_delete").show();
			modifySetData();
			//$("#SeqHiddenValue").val(key);					
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
				"vernum" : paramVerNum				
			},
			url:"getRulHistoryData.do",
			success:function (data) {					
				if(Object.keys(data.list[0]).length > 0){
					
					$("#VerNum").html(data.list[0].VerNum);	
					$("#EntCode").text(data.list[0].EntCode);				
					$("#InsertUser").text(data.list[0].InsertUser);				
					$("#insertdate").text(data.list[0].insertdate);
					$("#UpdateUser").text(data.list[0].UpdateUser);				
					$("#Updatedate").text(data.list[0].Updatedate);					
					$("#IsUse").val(data.list[0].IsUse);
					if(data.list[0].IsUse == "N") $("#btn_delete").show();
					$("#Description").val(data.list[0].Description);
				}
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getRuleHistoryData.do", response, status, error);
			}
		});
	}
	

	
	//저장
	function saveSubmit(){
		//data셋팅	
		var VerNum = $("#VerNum").text();				
		var Description = $("#Description").val();
		var IsUse = $("#IsUse").val();		
        var text = "<spring:message code='Cache.msg_RUEdit' />";   //수정하시겠습니까?
			
		var urlSubmit;
		if(mode == 'add'){
			//urlSubmit = 'insertBizDoc.do';
		}else{
			urlSubmit = '/approval/manage/updateRuleHistoryData.do';
		}
		
		if(IsUse=="Y"){
			text =  VerNum +"<spring:message code='Cache.msg_VersionCheck' />";   //버전으로 변경하시겠습니까?
		}
 
		Common.Confirm(text, "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				$.ajax({
					type:"POST",
					data:{
						"VerNum"   : VerNum,
						"Description"   : Description,
						"IsUse"   : IsUse 
					},
					url:urlSubmit,
					success:function (data) {
						if(data.result == "ok"){
							parent.Common.Inform("<spring:message code='Cache.msg_apv_117' />");
							closeLayer();
							parent.searchConfig();
						}
						else if(data.result == "fail"){
						   alert(data.message);	
						}
						
					},
					error:function(response, status, error){
						CFN_ErrorAjax(urlSubmit, response, status, error);
						alert("error");
					}
				});
			} else {
				return false;
			}
		});	
	
		
	}
	
	
	//삭제
	function deleteSubmit(){
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				var BizDocID = paramVerNum;
					
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"BizDocID" : BizDocID
					},
					url:"deleteBizDoc.do",
					success:function (data) {
						if(data.result == "ok")
							Common.Inform("<spring:message code='Cache.msg_apv_138' />");
						closeLayer();
						parent.searchConfig();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteBizDoc.do", response, status, error);
					}
				});
			}
		});
	}
		
</script>
<form id="BizDocListSetPopup" name="BizDocListSetPopup">
	<div class="sadmin_pop">		 		
		<table class="sadmin_table sa_menuBasicSetting mb20" >
		  <colgroup>
			<col style="width: 25%;">
			<col style="width: 25%;">
			<col style="width: 25%;">
			<col style="width: 25%;">
		  </colgroup>
		  <tbody>
		    <tr>
		      <th ><spring:message code='Cache.lbl_versionCont'/></th>  <!-- 버젼 -->
			  <td><span id="VerNum"></span></td>
		      <th><spring:message code='Cache.lbl_apv_entcode'/></th> <!-- 회사코드 -->
			  <td><span id="EntCode"></span></td>			  
		    </tr>
		    <tr>
		      <th><spring:message code='Cache.lbl_Register'/></th>  <!-- 등록자 -->
			  <td><span id="InsertUser"></span></td>
		      <th><spring:message code='Cache.lbl_RegistDate'/></th>  <!-- 등록일 -->
			  <td><span id="insertdate"></span></td>			  
		    </tr>	
		    <tr>
		      <th><spring:message code='Cache.lbl_apv_modiuser'/></th>  <!-- 수정자 -->
			  <td><span id="UpdateUser"></span></td>
		      <th><spring:message code='Cache.lbl_ModifyDate'/></th>  <!-- 수정일 -->
			  <td><span id="Updatedate"></span></td>			  
		    </tr>	
			<tr>
		      <th><spring:message code='Cache.lbl_apv_IsUse'/></th>
              <td colspan="3">
                    <select id="IsUse" name="IsUse" class="selectType02 w200p">
						<option value="Y" selected><spring:message code='Cache.lbl_apv_jfform_07'/></option>
						<option value="N"><spring:message code='Cache.lbl_apv_jfform_08'/></option>
					</select>
              </td>
		    </tr>		    		    	    
			<tr>
		      <th><spring:message code='Cache.lbl_apv_desc'/></th>
			  <td colspan="3"><textarea id="Description" name="Description" maxlength="512" class="" style="height:50px; overflow:scroll; overflow-x:hidden;"></textarea></td>
		    </tr>
	      </tbody>        
		</table>
		<div class="bottomBtnWrap">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="saveSubmit();" ><spring:message code="Cache.btn_apv_save"/></a>
			<a id="btn_delete" href="#" class="btnTypeDefault" onclick="deleteSubmit();" style="display:none"><spring:message code="Cache.btn_apv_delete"/></a>
			<a href="#" class="btnTypeDefault" onclick="closeLayer();" ><spring:message code="Cache.btn_apv_close"/></a>
		</div>
	</div>
	<input type="hidden" id="SeqHiddenValue" value="" />
	<input type="hidden" id="EntCode" value="" />
</form>