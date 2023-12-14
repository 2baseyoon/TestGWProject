<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramCategoryID =  param[1].split('=')[1];
	var doublecheck = false;
	var flag = 2;  //falg 0=권한부서선택 falg 1=피권한부서추가

	$(document).ready(function(){	
		// 양식명 다국어 세팅
		coviDic.renderInclude('dic', {
			lang : 'ko',
			hasTransBtn : 'true',
			allowedLang : 'ko,en,ja,zh',
			dicCallback : '',
			popupTargetID : '',
			init : '',
			styleType : "U"
		});
		
		$("#dic").find(".sadmin_table").css("border-top", "none");
		$("#dic").find(".sadmin_table tr:last").css("border-bottom", "none");
		
		if(mode=="modify"){
			$("#btn_delete").show();
			modifySetData();
		}
	});
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	//저장
	function saveSubmit(){
		//data셋팅	
		var CategoryName = $("#ko_full").val() + ";" + $("#en_full").val() + ";" + $("#ja_full").val() + ";" + $("#zh_full").val();
		var SortKey = $("#SortKey").val();		
		
		if (axf.isEmpty(CFN_GetDicInfo(CategoryName))) {
            Common.Warning("<spring:message code='Cache.msg_Common_39' />"); //분류명을 입력하여 주십시오.
            return false;
        }
		
		var urlSubmit;
		var confirmMessage;
			
		if(mode == 'add'){
			urlSubmit = 'insertCategoryData.do';
			confirmMessage = "<spring:message code='Cache.msg_RUSave' />";
		}else{
			urlSubmit = 'updateCategoryData.do';
			confirmMessage = "<spring:message code='Cache.msg_RUEdit' />";
		}
		
		parent.Common.Confirm(confirmMessage, "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				//insert 호출
				$.ajax({
					type:"POST",
					data:{
						"CategoryID" : paramCategoryID,	
						"CategoryName" : CategoryName,
						"SortKey" : SortKey
					},
					url:urlSubmit,
					success:function (data) {
						if(data.result == "ok")
							Common.Inform(data.message);				
						closeLayer();
						parent.setCategoryGridData();
					},
					error:function(response, status, error){
						CFN_ErrorAjax(urlSubmit, response, status, error);
					}
				});
			}
		});
	}	
	
	//수정화면 data셋팅
	function modifySetData(){
		//data 조회
		$.ajax({
			type:"POST",
			data:{
				"CategoryID" : paramCategoryID				
			},
			url:"getCategoryData.do",
			success:function (data) {					
				if(Object.keys(data.list[0]).length > 0){					
					//$("#FormClassID").val(data.list[0].FormClassID);				
					$("#ko_full").val(data.list[0].CategoryName.split(";")[0]);
					try { // 기존데이터에서 오류 발생할 수 있음.
		 				$("#en_full").val(data.list[0].CategoryName.split(";")[1]);
		 				$("#ja_full").val(data.list[0].CategoryName.split(";")[2]);
		 				$("#zh_full").val(data.list[0].CategoryName.split(";")[3]);
					} catch(e) { coviCmn.traceLog(e); }
					
					$("#SortKey").val(data.list[0].Seq);
				}
				
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getFormClassData.do", response, status, error);
			}
		});
	}
</script>
<div class="sadmin_pop">
	<table class="sadmin_table sa_menuBasicSetting">
		<colgroup>
			<col width="130px;">
			<col width="*">
		</colgroup>
		<tbody>
			<tr>
				<th><spring:message code='Cache.lbl_CateName' /></th>
				<td style="padding: 0px" id="dic"></td>
			</tr>
			<tr>
				<th><spring:message code='Cache.lbl_apv_SortKey' /></th>
				<td>
					<input class="w300p" max_length="5" mode="numberint" id="SortKey" name="SortKey" type="text" maxlength="64" />
				</td>
			</tr>			
		</tbody>
	</table>
	<div class="bottomBtnWrap">
		<a onclick="saveSubmit();" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_apv_save'/></a>
		<a onclick="closeLayer();" class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>
	</div>
</div>