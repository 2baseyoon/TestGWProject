<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" style="padding: 0px 24px 30px;">
	<div class="">
		<div class="top">
			<ul class="noticeTextGrayBox">
				<!-- 업로드 할 엑셀파일은 [정보]-[호환모드 변환] 작업 후 올려주세요 -->
				<li>※ <spring:message code="Cache.lbl_ExcelUpload" /></li>
			</ul>
			<div class="ulList type02 mt20">
				<ul>
					<li class="listCol">
						<!-- 파일 -->
						<div><strong><spring:message code="Cache.lbl_SelectFile" /></strong></div>
						<div>																									<!-- excelUpload_2 : 선택된 파일 없음
																																		SelectFile : 파일 선택 	-->
							<input type="text" id="uploadfileText" placeholder="<spring:message code='Cache.lbl_ExcelUpload' />"><a class="btnTypeDefault" onclick="$('#uploadfile').click();"><spring:message code="Cache.lbl_SelectFile" /></a>
							<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>
						</div>
					</li>								
				</ul>							
			</div>
		</div>
		<div class="bottom" style="text-align: center;">
			<a class="btnTypeDefault btnTypeBg" id="btnUpload"><spring:message code="Cache.btn_Upload" /></a>	<!-- 업로드 -->
			<a class="btnTypeDefault" id="btnClose"><spring:message code='Cache.ACC_btn_close' /></a>				<!-- 닫기 -->
		</div>
	</div>
</div>

<script>
	$(document).ready(function(){
		$('#uploadfile').on('change', function(e) {
			var file = $(this)[0].files[0];
			
			if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
		});
		
		$("#btnUpload").click(function(){
			
			var formData = new FormData();
			formData.append("uploadfile",$('#uploadfile')[0].files[0]);
			formData.append("mode",CFN_GetQueryString("mode"));
			$.ajax({
				url: '/groupware/attendCommon/uploadExcel.do',
				processData: false,
				contentType: false,
				data: formData,
				type: 'POST',
				success: function(result) {
					if(result.status == "SUCCESS"){ 
						var message = "\n"+"<spring:message code='Cache.lbl_sum' /> : "+result.totalCnt + 
							",<spring:message code='Cache.lbl_Regist' /> : "+result.successCnt + 
							",<spring:message code='Cache.lbl_Fail' /> : "	+result.failCnt ;							
						
						Common.Inform("<spring:message code='Cache.msg_UploadOk' />"+message, "Inform", function() {	//업로드 성공하였습니다.
							Common.Close();
							try{
								var pNameArr = [];
								new Function (pNameArr).apply();
							}catch (e) {
								coviCmn.traceLog(e);
							}
						});
					}else{
						Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
					}
				},error:function (error){
					Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
				}
			});
		});	
		
		$("#btnClose").click(function(){	
			Common.Close();
		});
	});				
</script>
