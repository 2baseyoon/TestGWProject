<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" style="padding: 0px 24px 30px;">
	<input type="hidden" value="${searchProperty}" id="searchProperty">
	<div class="">
		<div class="top">
			<ul class="noticeTextGrayBox">
				<li>※ <spring:message code="Cache.ACC_msg_excelUpload_1" /></li>
			</ul>
			<div class="ulList type02 mt20">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.ACC_lbl_file" /></strong></div>
						<div>																						<!-- excelUpload_2 : 선택된 파일 없음
																														SelectFile : 파일 선택 	-->
							<input type="text" id="uploadfileText" placeholder="<spring:message code='Cache.ACC_msg_excelUpload_2' />"><a class="btnTypeDefault" onclick="$('#uploadfile').click();"><spring:message code="Cache.ACC_lbl_selectFile" /></a>
							<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>
						</div>
					</li>								
				</ul>							
			</div>
		</div>
		<div class="bottom" style="text-align: center;">									
			<a class="btnTypeDefault btnTypeBg" onclick="CostCenterExcelPopup.excelUpload()"><spring:message code="Cache.ACC_btn_upload" /></a>	<!-- 업로드 -->
			<a class="btnTypeDefault" onclick="CostCenterExcelPopup.closeLayer()"><spring:message code='Cache.ACC_btn_close' /></a>				<!-- 취소 -->
		</div>
	</div>
</div>
			
<script type="text/javascript">
	if (!window.CostCenterExcelPopup) {
		window.CostCenterExcelPopup = {};
	}
	
	(function(window) {
		var CostCenterExcelPopup = {
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
						url: '/account/costCenter/costCenterExcelUpload.do',
						processData: false,
						contentType: false,
						data: formData,
						type: 'POST',
						success: function(result) {
							if(result.status == "SUCCESS"){ 
								if(result.err == 'subStr'){
									parent.Common.Inform("<spring:message code='Cache.ACC_msg_excelNoData' />");	//데이터 오류.(공백)
								}else if (result.err == "costCenterCode"){
									parent.Common.Inform("<spring:message code='Cache.ACC_msg_excelCostCenterCode' />");	//없는 CostCenterCode입니다.
								}else{
									parent.Common.Inform("<spring:message code='Cache.ACC_msg_excelUpload_3' />", "Inform", function() {	//업로드 성공하였습니다.
								
									CostCenterExcelPopup.closeLayer();
								
									try{
										accountCtrl.popupCallBackStr([]);
									}catch (e) {
										coviCmn.traceLog(e);
										coviCmn.traceLog(CFN_GetQueryString("callBackFunc"));
									}
									});
								}	
							}else{
								Common.Inform(result.message);
							}
						},error:function(error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); // 오류가 발생하였습니다. 관리자에게 문의 바랍니다.
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
		window.CostCenterExcelPopup = CostCenterExcelPopup;
	})(window);

	CostCenterExcelPopup.initContent();

</script>
