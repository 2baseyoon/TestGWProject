<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	const popupType = CFN_GetQueryString("type")=="undefined"? "" : CFN_GetQueryString("type"); // Add , Edit
	const legacyID = CFN_GetQueryString("id")=="undefined"? "" : CFN_GetQueryString("id");
	
	$(document).ready(function(){		
		setControl();
		
		if(popupType=="Edit"){
			modifySetData(); // 수정화면 기존 data셋팅
			$("#btn_delete").show();
		}
	});
	
	// Select box 및 이벤트 바인드
	function setControl(){
		// 도움말
		$('.collabo_help02 .help_ico').on('click', function(){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
			}else {
				$(this).addClass('active')
			}
		});
		
		// DB Pool
		$("#DatasourceSeq").coviCtrl("setSelectOption", "/covicore/dbsync/getDatasourceSelectData.do");
		$("#DatasourceSeq").prepend("<option value=''>" + Common.getDic('btn_Select') + "</option>");
		$("#DatasourceSeq").val("");
	}
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	// 수정화면 기존 data셋팅
	function modifySetData(){		
		$.ajax({
			type:"POST",
			data:{
				"LegacyID" : legacyID				
			},
			async : false,
			url:"getDraftLegacySystemData.do",
			success:function (data) {			
				if(data.status == "SUCCESS"){
					var arrData = data.list[0];
					if(Object.keys(arrData).length > 0){
						$.each(Object.keys(arrData), function(i,key) {
							var sValue = arrData[key];
							if(key == "ModifyDate") sValue = CFN_TransLocalTime(sValue)
							$("#" + key).val(sValue);
						});
					}else{
						Common.Error("<spring:message code='Cache.msg_ComNoData' />","",function(){ // 조회된 데이터가 없습니다.
							closeLayer();
						}); 
					}
				}else {
                    Common.Error(data.message);
                }
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getDraftLegacySystemData.do", response, status, error);
			}
		});
	}

	// 저장
	function saveSubmit(){
		var oData = fn_getData(); // 화면상의 데이터 가져오기
		oData["QueryType"] = popupType;
		
		if(!fn_validation(oData)) return; // 필수체크
		
		$.ajax({
			type:"POST",
			data:oData,
			url:"setDraftLegacySystemData.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					//if (popupType == 'Add' && data.object == 0) Common.Inform("<spring:message code='Cache._msg_CodeDuplicate' />");
					parent.Common.Inform("<spring:message code='Cache.msg_Processed' />","",function(){ // 처리 되었습니다
						parent.searchConfig();
						closeLayer();
					}); 
				} else {
					Common.Error(data.message);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("setDraftLegacySystemData.do", response, status, error);
			}
		});
	}
	
	//삭제
	function deleteSubmit(){
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "", function(result){ // 삭제하시겠습니까?
			if(result){
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"LegacyID" : legacyID
					},
					url:"deleteDraftLegacySystemData.do",
					success:function (data) {
						//if (data.object == 0)
						if(data.status == "SUCCESS"){
							parent.Common.Inform("<spring:message code='Cache.msg_Processed' />","",function(){ // 처리 되었습니다
								parent.searchConfig();
								closeLayer();
							});
						}else{
							Common.Error(data.message);
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteDraftLegacySystemData.do", response, status, error);
					}
				});
			}
		});
	}
	
	// 화면상의 데이터 가져오기
	function fn_getData(){
		var oData = {};
		
		// LegacyID,SystemCode,DatasourceSeq,DataTableName,DataTableKeyName,SubjectKeyName,EmpnoKeyName,DeptKeyName,MultiTableName,MultiTableKeyName,FormPrefix,Description
		$("#tbl_info").find(".data-field").each(function(idx,item){
			var sId = $(item).attr("id");
			oData[sId] = $(item).val();
		});
		
		return oData;
	}
	
	// 필수체크
	function fn_validation(oData){
		
		if (oData["SystemCode"].trim() == "") {
            Common.Warning("<spring:message code='Cache.mgs_valid_SystemName' />"); // 연동 시스템코드를 입력하세요.
            return false;
        } else if (oData["DatasourceSeq"] == null || oData["DatasourceSeq"].trim() == "") {
            Common.Warning("<spring:message code='Cache.mgs_valid_PoolName' />"); // 연동시스템 DB Pool을 선택하세요.
            return false;
        } else if (oData["DataTableName"].trim() == "" || oData["DataTableKeyName"].trim() == "" || oData["SubjectKeyName"].trim() == "" || oData["EmpnoKeyName"].trim() == "") {
            Common.Warning("<spring:message code='Cache.mgs_valid_DataTableKeyName' />"); // 데이터 테이블 및 컬럼명 정보를 입력하세요.
            return false;
        } else if (oData["MultiTableName"].trim() != "" && oData["MultiTableKeyName"].trim() == "") {
            Common.Warning("<spring:message code='Cache.mgs_valid_MultiTableKeyName' />"); // 멀티로우 테이블 키 컬럼을 입력하세요.
            return false;
        } else if (oData["FormPrefix"].trim() == "") {
            Common.Warning("<spring:message code='Cache.mgs_valid_FormPrefix' />"); // 양식키를 입력하세요.
            return false;
        }
		
		return true;
	}
	
</script>

<style>
	.sadmin_table .helppopup { text-align:left; }
	.sadmin_table .helppopup p { line-height:normal; }
	.sadmin_table .helppopup p:not(:last-child) { margin-bottom:5px; } 
</style>

<div class="sadmin_pop">
	<div style="color:red;margin-bottom:5px;"><b>* <spring:message code="Cache.lbl_dl_popupDesc"/></b></div> <!-- bodycontext로 변환시 모두 컬렴명의 대문자로 적용되며, 멀티로우는 테이블명으로 적용됩니다. -->
	<table id="tbl_info" class="sadmin_table sa_menuBasicSetting" >
		<colgroup>
			<col width="30%">
			<col width="20%">
			<col width="50%">
		</colgroup>
		<tbody>
		
			<tr id="tr_ID" style="display:none;">
		      	<th>ID</th>
			  	<td colspan="2"><input id="LegacyID" name="LegacyID" type="text" readonly="readonly" class="data-field" /></td>
		    </tr>
		    <tr>
		      	<th><span class="thstar">*</span><spring:message code="Cache.lbl_dl_SystemName"/></th> <!-- 연동 시스템 코드 -->
			  	<td colspan="2"><input id="SystemCode" name="SystemCode" type="text" class="data-field" /></td>
		    </tr>
		    <tr>
		      	<th>
		      		<span class="thstar">*</span>
		      		<spring:message code="Cache.lbl_dl_PoolName"/> <!-- 연동시스템 DB Pool -->
		      		<div class="collabo_help02">
						<a href="javascript:void(0);" class="help_ico"></a>
						<div class="helppopup" style="width:400px;">
							 <p><spring:message code="Cache.lbl_dl_PoolDesc1"/></p> <!-- 연동시스템 DB를 먼저 등록한 뒤 사용한다. -->
							 <p><spring:message code="Cache.lbl_dl_PoolDesc2"/></p> <!-- 시스템관리 > 외부DB연계설정 > Datasource 관리 -->
						</div>
					</div>
		      	</th>
			  	<td colspan="2"><select id="DatasourceSeq" name="DatasourceSeq" class="selectType02 w190p data-field"></select></td>
		    </tr>
		    <tr>
		      	<th rowspan="5"><spring:message code="Cache.lbl_dl_DataTable"/></th> <!-- 데이터 테이블 -->
		      	<th><span class="thstar">*</span><spring:message code="Cache.lbl_dl_TableName"/></th> <!-- 테이블명-->
			  	<td><input id="DataTableName" name="DataTableName" type="text" class="data-field" /></td>
		    </tr>
		    <tr>
		      	<th><span class="thstar">*</span><spring:message code="Cache.lbl_dl_DataTableKeyName"/></th> <!-- PK 컬럼명 -->
			  	<td><input id="DataTableKeyName" name="DataTableKeyName" type="text" class="data-field" /></td>
		    </tr>
		    
		    <tr>
		      	<th><span class="thstar">*</span><spring:message code="Cache.lbl_dl_SubjectKeyName"/></th> <!-- 제목 컬럼명 -->
			  	<td><input id="SubjectKeyName" name="SubjectKeyName" type="text" class="data-field" /></td>
		    </tr>
		    <tr>
		      	<th><span class="thstar">*</span><spring:message code="Cache.lbl_dl_EmpnoKeyName"/></th> <!-- 사번 컬럼명 -->
			  	<td><input id="EmpnoKeyName" name="EmpnoKeyName" type="text" class="data-field" /></td>
		    </tr>
		    <tr>
		      	<th><spring:message code="Cache.lbl_dl_DeptKeyName"/></th> <!-- 부서코드 컬럼명 -->
			  	<td><input id="DeptKeyName" name="DeptKeyName" type="text" class="data-field" /></td>
		    </tr>
		    <tr>
		      	<th rowspan="2"><spring:message code="Cache.lbl_dl_MultiTable"/></th> <!-- 멀티로우 테이블 -->
		      	<th><spring:message code="Cache.lbl_dl_TableName"/></th> <!-- 테이블명-->
			  	<td><input id="MultiTableName" name="MultiTableName" type="text" class="data-field" /></td>
		    </tr>
		    <tr>
		      	<th><spring:message code="Cache.lbl_dl_DataTableKeyName"/></th> <!-- PK 컬럼명 -->
			  	<td><input id="MultiTableKeyName" name="MultiTableKeyName" type="text" class="data-field" /></td>
		    </tr>
		    <tr>
		      	<th><span class="thstar">*</span><spring:message code="Cache.lbl_dl_FormPrefix"/></th> <!-- 양식키 -->
			  	<td colspan="2"><input id="FormPrefix" name="FormPrefix" type="text" class="data-field" /></td>
		    </tr>
		    
		    <tr>
		      	<th><spring:message code="Cache.lbl_dl_Description"/></th> <!-- 설명-->
			  	<td colspan="2"><textarea id="Description" name="Description" style="resize:none" class="data-field" ></textarea></td>
		    </tr>
		    <tr>
		      	<th><spring:message code="Cache.lbl_ModifyDate"/></th> <!-- 수정일 -->
			  	<td colspan="2"><input id="ModifyDate" name="ModifyDate" type="text" readonly="readonly" /></td>
		    </tr>
    	</tbody>
	</table>
	<div class="bottomBtnWrap">
		<a onclick="saveSubmit();" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_save'/></a> <!-- 저장 -->
		<a id="btn_delete" onclick="deleteSubmit();" style="display: none"  class="btnTypeDefault" ><spring:message code='Cache.btn_delete'/></a> <!-- 삭제 -->
		<a onclick="closeLayer();" class="btnTypeDefault" ><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
	</div>		
</div>
