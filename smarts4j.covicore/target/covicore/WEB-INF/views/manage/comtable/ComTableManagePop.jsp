<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	const popupType = CFN_GetQueryString("type")=="undefined"? "" : CFN_GetQueryString("type"); // Add , Edit
	const comTableID = CFN_GetQueryString("id")=="undefined"? "" : CFN_GetQueryString("id");
	const companyCode = CFN_GetQueryString("companyCode")=="undefined"? "" : CFN_GetQueryString("companyCode");
	
	$(document).ready(function(){		
		setControl();
		
		if(popupType=="Edit"){
			modifySetData(); // 수정화면 기존 data셋팅
			$("#btn_delete").show();
			$("#tr_ID").show();
		}
	});
	
	// Select box 및 이벤트 바인드
	function setControl(){
		// 다국어 로딩		
		coviDic.renderInclude('ComTableNameContainer', {
            lang : 'ko',
            hasTransBtn : 'true',
            allowedLang : 'ko,en,ja,zh',
            dicCallback : '',
            popupTargetID : '',
            init : '',
            styleType : 'U'
        });
		// 다국어영역 디자인 변경(테이블 내부 테이블용)
		$("#ComTableNameContainer").find("table.sadmin_table").addClass("sadmin_inside_table"); 
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
				"ComTableID" : comTableID				
			},
			async : false,
			url:"getComTableManageData.do",
			success:function (data) {			
				if(data.status == "SUCCESS"){
					if(Object.keys(data.list[0]).length > 0){
						$("#ComTableID").text(comTableID); // data.list[0].ComTableID
						coviDic.bindData(data.list[0].ComTableName);
						$("#SortKey").val(data.list[0].SortKey);				
						$("#IsUse").val(data.list[0].IsUse);		
						$("#Description").val(data.list[0].Description);
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
				CFN_ErrorAjax("getComTableManageData.do", response, status, error);
			}
		});
	}

	// 저장
	function saveSubmit(){
		var comTableName = coviDic.convertDic(coviDic.makeDic());
		var sortKey = $("#SortKey").val();
		var isUse = $("#IsUse").val();
		var description = $("#Description").val();
		
		if (comTableName.split(";")[0].trim() == "") {
            Common.Warning("<spring:message code='Cache.mgs_valid_tableName' />"); // 테이블명을 입력하세요.
            return false;
        }
		if (sortKey.trim() == "") {
            Common.Warning("<spring:message code='Cache.mgs_valid_sortKey' />"); // 정렬 값을 입력하세요.
            return false;
        }	
		
		$.ajax({
			type:"POST",
			data:{
				"QueryType" : popupType,
				"CompanyCode" : companyCode,
				"ComTableID" : comTableID,
				"ComTableName" : comTableName,
				"SortKey" : sortKey,
				"IsUse" : isUse,
				"Description" : description
			},
			url:"setComTableManageData.do",
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
				CFN_ErrorAjax("setComTableManageData.do", response, status, error);
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
						"ComTableID" : comTableID
					},
					url:"deleteComTableManageData.do",
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
						CFN_ErrorAjax("deleteJobFunction.do", response, status, error);
					}
				});
			}
		});
	}
	
</script>
<div class="sadmin_pop">		 		
	<table class="sadmin_table sa_menuBasicSetting" >
		<colgroup>
			<col width="120px">
			<col width="*">
		</colgroup>
		<tbody>
		
			<tr id="tr_ID" style="display:none;">
		      	<th>ID</th>
			  	<td><span id="ComTableID"></span></td>
		    </tr>
		    <tr>
		      	<th><spring:message code="Cache.lbl_ComTableName"/></th> <!-- 테이블명 -->
			  	<td id="ComTableNameContainer" style="padding:0px;"></td>
		    </tr>
		    <tr>
		      	<th><spring:message code="Cache.lbl_Sort"/></th> <!-- 정렬 -->
			  	<td><input mode="numberint" class="w100" id="SortKey" name="SortKey" type="text" maxlength="9" /></td>
		    </tr>
		    <tr>
		    	<th><spring:message code="Cache.lbl_ComIsUse"/></th> <!-- 사용여부 -->
	            <td>
					<select id="IsUse" name="IsUse" class="selectType02 w190p">
						<option value="Y" selected><spring:message code="Cache.lbl_UseY"/></option>
						<option value="N"><spring:message code="Cache.lbl_UseN"/></option>
					</select>
	        	</td>
		    </tr>
		    <tr>
		      	<th><spring:message code="Cache.lbl_Description"/></th> <!-- 설명 -->
			  	<td><textarea id="Description" name="Description" style="resize:none"></textarea></td>
		    </tr>
    	</tbody>
	</table>
	<div class="bottomBtnWrap">
		<a onclick="saveSubmit();" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_save'/></a> <!-- 저장 -->
		<a id="btn_delete" onclick="deleteSubmit();" style="display: none"  class="btnTypeDefault" ><spring:message code='Cache.btn_delete'/></a> <!-- 삭제 -->
		<a onclick="closeLayer();" class="btnTypeDefault" ><spring:message code='Cache.btn_Close'/></a> <!-- 닫기 -->
	</div>		
</div>
