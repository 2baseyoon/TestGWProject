<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% String strGroupID 	= request.getParameter("configkey");%>
<c:set var="strGroupID" value="<%=strGroupID%>"/>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramEntCode =  param[1].split('=')[1];
	var paramGroupID =  param[2].split('=')[1];
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가

	$(document).ready(function(){		
		if(mode=="modify"){
			$("#btn_delete").show();
			modifySetData();
			$("#GroupCode").attr("disabled",true);
			
			//$("#SeqHiddenValue").val(key);					
		}
		//selSelectbind();		
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
				"GroupID" : paramGroupID,
			},
			url:"getDistirbutionData.do",
			success:function (data) {					
				if(Object.keys(data.list[0]).length > 0){
					
					$("#GroupName").val(data.list[0].GroupName);				
					$("#GroupCode").val(data.list[0].GroupCode);				
					$("#Description").val(data.list[0].Description);				
					$("#SortKey").val(data.list[0].SortKey);
					$("#IsUse").val(data.list[0].IsUse);
					$("#InsertDate").val(data.list[0].InsertDate);
				}
				//parent.searchConfig1();
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getDistirbutionData.do", response, status, error);
			}
		});
	}
	
	
	//GroupID체크
	function checkGroupID(){
		var returnval;
		//data 조회
		$.ajax({
			type:"POST",
			data:{
				"GroupCode" : $("#GroupCode").val()
			},
			url:"getDistirbutionData.do",
			async:false,
			success:function (data) {					
				if(Object.keys(data.list[0]).length > 0){					
					returnval = true;
				}else{
					returnval = false;
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getDistirbutionData.do", response, status, error);
			}
		});
		return returnval;
	}

	
	//저장
	function saveSubmit(){
		//data셋팅	
		var GroupCode = $("#GroupCode").val();				
		var GroupName = $("#GroupName").val();
		var Description = $("#Description").val();		
		var SortKey = $("#SortKey").val();		
		var IsUse = $("#IsUse").val();
		
		if (axf.isEmpty(GroupName)) {
			parent.Common.Warning("<spring:message code='Cache.msg_apv_distribute_group_name_enter' />");//배포그룹명을 입력하십시오.
            return false;
        }
		if (axf.isEmpty(GroupCode)) {
			parent.Common.Warning("<spring:message code='Cache.msg_apv_distribute_group_code_enter' />");//배포그룹코드를 입력하십시오.
            return false;
        }
		if (axf.isEmpty(SortKey)) {
			parent.Common.Warning("<spring:message code='Cache.msg_apv_141' />");//정렬값은 숫자로 입력하십시오.
            return false;
        }
		
		var urlSubmit;
		if(mode == 'add'){
			urlSubmit = 'insertDistributionList.do';			
			if(checkGroupID()){
				parent.Common.Warning("<spring:message code='Cache.msg_apv_adminDupDistributionCode' />");
				return false;
			}
		}else{
			urlSubmit = 'updateDistribution.do';
		}		
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{
				"GroupID" : paramGroupID,
				"EntCode" : paramEntCode,				
				"GroupCode"   : GroupCode,
				"GroupName"   : GroupName,
				"Description"   : Description,				
				"SortKey"   : SortKey,				
				"IsUse"   : IsUse
			},
			url:urlSubmit,
			success:function (data) {
				if(data.result == "ok") {
					var sMessage;
					
					if(mode == "add") {
						sMessage = Common.getDic("msg_apv_136");
					} else {
						sMessage = Common.getDic("msg_apv_137");
					}
					
					parent.Common.Inform("<spring:message code='Cache.msg_apv_136' />", "", function() {
						closeLayer();
						parent.searchConfig1();
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax(urlSubmit, response, status, error);
			}
		});
	}
	
	
	//삭제
	function deleteSubmit(){
		parent.Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				var GroupID = paramGroupID;
				
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"GroupID" : GroupID
					},
					url:"deleteDistribution.do",
					success:function (data) {
						if(data.result == "ok") {
							parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />", "", function() {
								closeLayer();
								parent.setUseAuthority();
								parent.$("#divMember").hide();
							});
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteDistribution.do", response, status, error);
					}
				});
			}
		});
	}
		
	//axisj selectbox변환
	function selSelectbind(){
		//검색selectbind
		
	}
</script>

<form id="GroupListSetPopup.jsp" name="GroupListSetPopup.jsp">
	<div class="sadmin_pop">		 		
		<table class="sadmin_table sa_menuBasicSetting mb20" >
		  <colgroup>
			<col id="t_tit4" width="120px;">
			<col id="" width="*">
		  </colgroup>
		  <tbody>
		    <tr>
		      <th><spring:message code="Cache.lbl_apv_grform_01"/></th>
			  <td><input id="GroupName" name="GroupName" type="text" class="" maxlength="64" /></td>
		    </tr>
		    <tr>
		      <th><spring:message code="Cache.lbl_apv_grform_02"/></th>
			  <td><input id="GroupCode" name="GroupCode" type="text" class="" maxlength="64" /></td>
		    </tr>
			<tr>
		      <th><spring:message code="Cache.lbl_apv_grform_03"/></th>
			  <td><textarea id="Description" name="Description" class="" maxlength="512" style="height:50px; overflow:scroll; overflow-x:hidden;resize:none;"></textarea></td>
		    </tr>
			<tr>
		      <th><spring:message code="Cache.lbl_apv_Sort"/></th>
			  <td><input mode="numberint"  num_max="32767" class=""   id="SortKey" name="SortKey" type="text" maxlength="16" /></td>
		    </tr>		    
			<tr>
		      <th><spring:message code="Cache.lbl_apv_grform_05"/></th>
                <td>
                    <select id="IsUse" name="IsUse" class="selectType02">
						<option value="Y" selected><spring:message code="Cache.lbl_apv_jfform_07"/></option>
						<option value="N"><spring:message code="Cache.lbl_apv_jfform_08"/></option>
					</select>
                </td>
		    </tr>
		    <c:if test="${!empty strGroupID}">
			<tr>
		      <th><spring:message code="Cache.lbl_apv_grform_06"/></th>
			  <td><input id="InsertDate" name="InsertDate" type="text" readonly="readonly" class="" style=""></td>
		    </tr>
		    </c:if>
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