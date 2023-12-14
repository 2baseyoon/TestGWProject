<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" style="padding: 0px 24px 30px;">
	<div class="">
		<div class="top">
			<ul class="noticeTextGrayBox">
				<li>※ <spring:message code="Cache.ACC_msg_excelUpload_1" /></li>
			</ul>
			<div class="ulList type02 mt20">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.ACC_lbl_file" /></strong></div>
						<div>																				<!-- 선택된 파일 없음 -->
							<input type="text" id="uploadfileText" placeholder="<spring:message code='Cache.ACC_msg_excelUpload_2' />"><a class="btnTypeDefault" onclick="$('#uploadfile').click();"><spring:message code="Cache.ACC_lbl_selectFile" /></a>
							<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>
						</div>
					</li>								
				</ul>							
			</div>
		</div>
		<div class="bottom" style="text-align: center;">
			<a class="btnTypeDefault btnTypeBg" onclick="BaseCodeExcelPopup.excelUpload()"><spring:message code="Cache.ACC_btn_upload" /></a>
			<a class="btnTypeDefault" onclick="BaseCodeExcelPopup.closeLayer()"><spring:message code='Cache.ACC_btn_close' /></a>
		</div>
	</div>
</div>
			
<script>

	if (!window.BaseCodeExcelPopup) {
		window.BaseCodeExcelPopup = {};
	}
	
	(function(window) {
		var BaseCodeExcelPopup = {
				
				/**
				초기화
				*/
				initContent : function(){
					$('#uploadfile').on('change', function(e) {
						var file = $(this)[0].files[0];
						
						if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
					});
				},
				
				/**
				엑셀 업로드
				*/
				excelUpload : function(){
					var formData = new FormData();
					formData.append("uploadfile",$('#uploadfile')[0].files[0]);
					
					$.ajax({
						url: "/account/baseCode/excelUpload.do",
						processData: false,
						contentType: false,
						data: formData,
						type: 'POST',
						success: function(result) {
							if(result.result == "ok"){
								parent.Common.Inform("<spring:message code='Cache.ACC_msg_excelUpload_3' />", "Inform", function() {	//업로드 성공하였습니다.
								
								BaseCodeExcelPopup.closeLayer();
								
								try{
									accountCtrl.popupCallBackStr([]);
								}catch (e) {
									coviCmn.traceLog(e);
									coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
								}
								
							});
							}else if(result.result == "D"){
								Common.Error("<spring:message code='Cache.ACC_DuplCode'/>");	// 이미 존재하는 코드입니다.
							}
							else if(result.result == "V"){
								Common.Error("<spring:message code='Cache.ACC_Valid'/>");	// 입력되지 않은 필수값이 있습니다.
							}
							else if(result.result == "G"){
								Common.Error("<spring:message code='Cache.ACC_NoGrp'/>");	// 존재하지 않는 그룹 코드입니다.
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
							}
						},
						error:function (error){
							if(error.result == "D"){
								Common.Error("<spring:message code='Cache.ACC_DuplCode'/>");	// 이미 존재하는 코드입니다.
							}
							else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // error.message;
							}
						}
					});
				},
				
				/**
				팝업 닫기
				*/
				closeLayer : function(){
					var isWindowed	= CFN_GetQueryString("CFN_OpenedWindow");
					var popupID		= CFN_GetQueryString("popupID");
					
					if(isWindowed.toLowerCase() == "true") {
						window.close();
					} else {
						parent.Common.close(popupID);
					}
				}
		}
		window.BaseCodeExcelPopup = BaseCodeExcelPopup;
	})(window);
	
	BaseCodeExcelPopup.initContent();
	
</script>
