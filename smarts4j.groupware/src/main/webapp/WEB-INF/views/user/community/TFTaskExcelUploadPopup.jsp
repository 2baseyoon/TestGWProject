<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" style="padding: 0px 24px 30px;">
	<div class="">
		<div class="top">
			<ul class="noticeTextGrayBox">
				<li><spring:message code="Cache.msg_activityfilecomment" /></li>
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
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_templatedownload" /></strong></div>
						<div>
							<a href="#" class="btnTypeDefault" onclick="excelTemplateDownload();"><spring:message code="Cache.lbl_templatedownload" /></a>
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
	var param = location.search.substring(1).split('&');
	var key = CFN_GetQueryString("CU_ID");		//프로젝트코드
	initContent();
	function initContent() {
		// 파일 선택, 취소
		$('#uploadfile').on('change', function(e) {
			var file = $(this)[0].files[0];
			
			if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
		});
	}
	
	// 템플릿 파일 다운로드
	function excelTemplateDownload() {
 		if (confirm("템플릿 파일을 다운로드 하시겠습니까?")) {
			var searchParam = {
					"prjcode" : key
				};
			ajax_download('/groupware/tf/excelTemplateDownload.do', searchParam);	
		}
	}
	
	// 엑셀 업로드
	function excelUpload() {
		var formData = new FormData();
		formData.append("uploadfile",$('#uploadfile')[0].files[0]);
		formData.append("CU_ID",key);
		
		$.ajax({
			url: '/groupware/tf/excelUpload.do',
			processData: false,
			contentType: false,
			data: formData,
			type: 'POST',
			success: function(result) {
				if(result.data > 0) {
					Common.Inform("<spring:message code='Cache.lbl_vacationMsg31' />", "Inform", function() {
						parent.Common.Close("target_pop");
						parent.search();
					});
				} else {
					Common.Inform("업로드 실패하였습니다. 관리자에게 문의하세요.", "Inform", function() {
						parent.Common.Close("target_pop");
						parent.search();
					});
				}
			}
		});
	}	
</script>
