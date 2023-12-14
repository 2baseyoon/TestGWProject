<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" style="padding: 10px 24px 30px;">
	<div class="">
		<div class="top">
			<p class="tr mb10"><a href="#" class="btnTypeDefault btnExcel" id="excelDownBtn" onclick="excelDownload();"><spring:message code='Cache.lbl_templatedownload' /></a></p>
			<ul class="noticeTextGrayBox">
				<li>※ <spring:message code="Cache.lbl_vacationMsg28" /></li>
				<li>※ <spring:message code="Cache.lbl_vacationMsg29" /></li>
			</ul>
			<div class="ulList type02 mt20">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_File" /></strong></div>
						<div>
							<input type="text" id="uploadfileText" placeholder="<spring:message code='Cache.lbl_vacationMsg30' />"><a href="#" class="btnTypeDefault" onclick="$('#uploadfile').click();"><spring:message code="Cache.lbl_SelectFile" /></a>
							<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>
						</div>
					</li>								
				</ul>							
			</div>
		</div>
		<div class="bottom" style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="excelUpload()"><spring:message code="Cache.btn_Upload" /></a>
			<a href="#" class="btnTypeDefault" onclick="parent.Common.Close('target_pop');"><spring:message code='Cache.btn_Close' /></a>
		</div>
	</div>
</div>
			
<script>
	var reqType = CFN_GetQueryString("reqType");	// reqType : manage(연차관리),  promotionPeriod(연차촉진 기간설정)

	initContent();

	function initContent() {
		// 파일 선택, 취소
		$('#uploadfile').on('change', function(e) {
			var file = $(this)[0].files[0];
			
			if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
		});
	}
	
	// 엑셀 업로드
	function excelUpload() {
		var formData = new FormData();
		formData.append("uploadfile",$('#uploadfile')[0].files[0]);
		
		$.ajax({
			url: '/groupware/vacation/excelUpload.do',
			processData: false,
			contentType: false,
			data: formData,
			type: 'POST',
			success: function(result) {
				if(result.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.lbl_vacationMsg31' />", "Inform", function() {
						parent.Common.Close("target_pop");
						parent.search();
					});
				}
			}
		});
	}
	
	// 템플릿 파일 다운로드
	function excelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_bizcard_downloadTemplateFiles' />", "Confirm", function(result){
			if(result){
			location.href = "/groupware/vacation/excelDownload.do?reqType="+reqType;
			}
		});
	}
</script>
