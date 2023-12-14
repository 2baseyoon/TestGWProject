<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>

<form id="BizDocFormSetPopup" name="BizDocFormSetPopup">
	<div id="formList"  style="overflow:auto;height:230px; margin-bottom:8px;">
	</div>
	<div align="center">
		<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveSubmit(); return false;" class="AXButton red" />
		<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="	Common.Close(); return false;"  class="AXButton" />
	</div>
</form>

<script  type="text/javascript">
	//# sourceURL=BizDocSelOriginFormPopup.jsp
	var paramBizDocID ="${key}";
	var paramBizEntCode = "${entCode}";
	
	//ready 
	setData();
	
	//수정화면 data셋팅
	function setData(){
		//data 조회
		var name;
		var fix;
		$.ajax({
			type:"POST",
			url:"getBizDocSelOrginFormList.do",
			data : {
				bizDocID : paramBizDocID,
				bizEntCode : paramBizEntCode
			},
			success:function (data) {				
				var selectDataList = data.list.map( function(item){ return item.formPrefix; });				
				var $ele = data.list.map(function(item,idx){
					item.SortKey = '0';
					var $div = $("<div>",{ style : "margin-bottom: 10px" });
					var $label = $("<label>");					
					var $input = $("<input>",{ type : "checkbox", checked : selectDataList.indexOf( item.FormPrefix ) > -1 ? true : false }).data('item', item );
					var $a = $("<a>",{ style : "margin-left: 3px", text : CFN_GetDicInfo(item.FormName)+"("+ item.FormPrefix +")" });
					$label.append( $input ).append( $a ).appendTo( $div );
					return $div;
				});				
				$("#formList").append($ele);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getBizDocSelOrginFormList.do", response, status, error);
			}
		});
	}
	
	//저장
	function saveSubmit(){
		
		var BizDocFormArray = 
				Array.prototype.slice.call($("#formList").find("input[type=checkbox]:checked")).map(function(obj,idx){
					return $(obj).data('item'); 
				});
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{				
				"BizDocID" : paramBizDocID,
				"BizDocForm" : JSON.stringify(BizDocFormArray)
			},
			url:"insertBizDocForm.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					parent.Common.Inform("<spring:message code='Cache.msg_apv_137'/>", "", function() {
						coviCmn.getParentFrameObj("updateBizForm").searchConfig();
						Common.Close();
					});
				}else{
					parent.Common.Warning(data.message);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("insertBizDocForm.do", response, status, error);
			}
		});
	}

	
</script>
