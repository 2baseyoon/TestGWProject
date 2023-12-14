<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:500px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">	
		<div class="popContent" style="position:relative;">
			<div class="middle">
				<table class="tableTypeRow">
					<colgroup>
						<col style="width: 40%;">
						<col style="width: 60%;">
					</colgroup>
					<tbody>
						<tr>	
							<th><font color="red">* </font>년도선택</th>	
							<td id="tdSelectBoxArea">		
									
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a id="btnSave" class="btnTypeDefault btnTypeChk" href="#" onclick="ExecuteCopy();"><spring:message code='Cache.lbl_apv_Run'/></a>
				<a id="btnClose" class="btnTypeDefault" onclick="Common.Close(); return false;"><spring:message code='Cache.btn_Cancel'/></a> <!-- 취소 -->
			</div>
		</div>
	</div>	
</div>

<script>
	
	setPopup();
	
	function setPopup(){
		var popupHtml = '';
		var btnTxt = '';
		
		var cDate = new Date();
	    var cNowYear = cDate.getFullYear();
	    var cNextYear = cDate.getFullYear()+1;
		
		popupHtml += '<select class="selectType02" id="selYear" style="width: 90%; margin-left: 5px;">';
		popupHtml += '<option value="' + cNowYear.toString() + '">' + cNowYear.toString() + '년</option>';
		popupHtml += '<option selected="selected" value="' + cNextYear.toString() + '">' + cNextYear.toString() + '년</option>';
		popupHtml += '</select>';
		
		$("#tdSelectBoxArea").html(popupHtml);
	}
	
	
	function ExecuteCopy(){
		var selYear = $("#selYear").val();
		if(selYear == null || selYear == "") {
			var cDate = new Date();
		    var cNextYear = cDate.getFullYear()+1;
		    selYear = cNextYear.toString();
		}
		
		//alert(selYear);
		
		// 데이터를 복사하시겠습니까?
		Common.Confirm("전년도 기준으로 차년도 데이터가 생성됩니다.<br/>데이터를 복사하시겠습니까?", "Information", function(result){
			if(result){
				$.ajax({
					url: "/approval/user/insertRecordGFileByYear.do",
					type: "POST",
					data: {
						"BaseYear": selYear
					},
					success: function(data){
						if(data.status == "SUCCESS"){
							Common.Inform(data.message, "Information", function(result){
								if(result){
									Common.Close();
								}
							});
						}else{
							Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
						}
					},
					error: function(error){
						Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
					}				
				});
				
			}
		});
		
		
	}
	
	
</script>