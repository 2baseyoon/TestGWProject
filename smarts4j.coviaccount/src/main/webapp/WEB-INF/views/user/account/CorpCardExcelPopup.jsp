<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" style="padding: 0px 24px 30px;">
	<div class="">
		<div class="top" style="padding-top:15px;">
			<ul class="noticeTextGrayBox">
				<!-- 업로드 할 엑셀파일은 [정보]-[호환모드 변환] 작업 후 올려주세요 -->
				<li>※ <spring:message code="Cache.ACC_msg_excelUpload_1" /></li>
			</ul>
			<div class="ulList type02 mt20">
				<ul>
					<li class="listCol">
						<!-- 파일 -->
						<div><strong><spring:message code="Cache.ACC_lbl_file" /></strong></div>
						<div>
							<!-- excelUpload_2 : 선택된 파일 없음 / SelectFile : 파일 선택 	-->
							<input type="text" id="uploadfileText" placeholder="<spring:message code='Cache.ACC_msg_excelUpload_2' />"><a class="btnTypeDefault" onclick="$('#uploadfile').click();"><spring:message code="Cache.ACC_lbl_selectFile" /></a>
							<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>
						</div>
					</li>								
				</ul>							
			</div>
		</div>
		<div class="bottom" style="text-align: center;">
			<a class="btnTypeDefault btnTypeBg" onclick="CorpCardExcelPopup.excelUpload()"><spring:message code="Cache.ACC_btn_upload" /></a>	<!-- 업로드 -->
			<a class="btnTypeDefault" onclick="CorpCardExcelPopup.closeLayer()"><spring:message code='Cache.ACC_btn_close' /></a>				<!-- 닫기 -->
		</div>
	</div>
</div>

<script>
	if (!window.CorpCardExcelPopup) {
		window.CorpCardExcelPopup = {};
	}
	
	(function(window) {
		var CorpCardExcelPopup = {
				initContent : function() {
					$('#uploadfile').on('change', function(e) {
						var file = $(this)[0].files[0];
						
						if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
					});
				},
				
				excelUpload : function() {
					//이미 등록된 데이터가 있을 경우 현재 업로드하는 데이터로 대치됩니다.
					Common.Confirm("<spring:message code='Cache.ACC_lbl_legacyExcelUploadConfirm'/>", "<spring:message code='Cache.ACC_btn_confirm' />", function(result){
				  		if(result){
				  			var formData = new FormData();
							formData.append("uploadfile",$('#uploadfile')[0].files[0]);
							
							$.ajax({
								url: '/account/corpCard/corpCardExcelUpload.do',
								processData: false,
								contentType: false,
								data: formData,
								type: 'POST',
								success: function(result) {
									if(result.status == "SUCCESS"){ 
										if(result.err == 'nullErr'){
											parent.Common.Inform("<spring:message code='Cache.ACC_msg_noReqData' />") //입력되지 않은 필수값이 있습니다.
										}else{
											parent.Common.Inform("<spring:message code='Cache.ACC_msg_excelUpload_3' />", "Inform", function() { //업로드 성공하였습니다.
											CorpCardExcelPopup.closeLayer();
										
											try{
												accountCtrl.popupCallBackStr([]);
											}catch (e) {
												coviCmn.traceLog(e);
												coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
											}
											});
										}
									}else{
										Common.Error(result.message);
									}
								},error:function (error){
									Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
								}
							});
				  		}
					});
				},
				
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
		window.CorpCardExcelPopup = CorpCardExcelPopup;
	})(window);

	CorpCardExcelPopup.initContent();
	
</script>
