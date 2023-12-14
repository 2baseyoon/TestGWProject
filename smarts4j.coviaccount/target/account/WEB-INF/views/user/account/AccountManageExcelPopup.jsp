<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" style="padding: 0px 24px 30px;">
	<div class="">
		<div class="top">
			<ul class="noticeTextGrayBox">
				<!-- 업로드 할 엑셀파일은 [정보]-[호환모드 변환] 작업 후 올려주세요 -->
				<li>※ <spring:message code="Cache.ACC_msg_excelUpload_1" /></li>
			</ul>
			<div class="ulList type02 mt20">
				<ul>
					<li class="listCol">
						<!-- 파일 -->
						<div><strong><spring:message code="Cache.ACC_lbl_file" /></strong></div>
						<div>																									<!-- excelUpload_2 : 선택된 파일 없음
																																		SelectFile : 파일 선택 	-->
							<input type="text" id="uploadfileText" placeholder="<spring:message code='Cache.ACC_msg_excelUpload_2' />"><a class="btnTypeDefault" onclick="$('#uploadfile').click();"><spring:message code="Cache.ACC_lbl_selectFile" /></a>
							<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>
						</div>
					</li>								
				</ul>							
			</div>
		</div>
		<div class="bottom" style="text-align: center;">
			<a class="btnTypeDefault btnTypeBg" onclick="AccountManageExcelPopup.excelUpload()"><spring:message code="Cache.ACC_btn_upload" /></a>	<!-- 업로드 -->
			<a class="btnTypeDefault" onclick="AccountManageExcelPopup.closeLayer()"><spring:message code='Cache.ACC_btn_close' /></a>				<!-- 닫기 -->
		</div>
	</div>
</div>

<script>
	if (!window.AccountManageExcelPopup) {
		window.AccountManageExcelPopup = {};
	}
	
	(function(window) {
		var AccountManageExcelPopup = {
				initContent : function() {
					$('#uploadfile').on('change', function(e) {
						var file = $(this)[0].files[0];
						
						if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
					});
				},
				
				excelUpload : function() {
					var formData = new FormData();
					formData.append("uploadfile",$('#uploadfile')[0].files[0]);
					
					$.ajax({
						url: '/account/accountManage/accountManageExcelUpload.do',
						processData: false,
						contentType: false,
						data: formData,
						type: 'POST',
						success: function(result) {
							if(result.status == "SUCCESS"){ 
								if(result.err == 'accountCode'){
									parent.Common.Inform("<spring:message code='Cache.ACC_msg_excelAccountCode' />");	// 사용자 오류.(ID 중복/ ID 공백)
								}else if(result.err == 'nullErr'){
									parent.Common.Inform("<spring:message code='Cache.ACC_msg_excelNoData' />")			// 데이터 오류.(공백)
								}else{
									parent.Common.Inform("<spring:message code='Cache.ACC_msg_excelUpload_3' />", "Inform", function() {	//업로드 성공하였습니다.
								
									AccountManageExcelPopup.closeLayer();
								
									try{
										accountCtrl.popupCallBackStr([]);
									}catch (e) {
										coviCmn.traceLog(e);
										coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
									}
									});
								}
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
							}
						},error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
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
		window.AccountManageExcelPopup = AccountManageExcelPopup;
	})(window);

	AccountManageExcelPopup.initContent();
	
</script>
