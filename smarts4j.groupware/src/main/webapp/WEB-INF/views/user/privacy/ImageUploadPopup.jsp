<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup">
	<div class="">
		<div class="top">
			<ul class="noticeTextGrayBox">
				<li><spring:message code="Cache.msg_ImageUploadMessage"/></li>
			</ul>
			<div class="ulList type02 mt20">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_File"/></strong></div> <!-- 파일 -->
						<div>
							<input type="text" id="uploadfileText" placeholder="<spring:message code='Cache.lbl_vacationMsg30'/>"><a href="#" class="btnTypeDefault" onclick="$('#uploadfile').click();"><spring:message code="Cache.lbl_SelectFile"/></a> <!-- 선택된 파일 없음 / 파일선택 -->
							<input type="file" id="uploadfile" style="display:none;">
						</div>
					</li>								
				</ul>							
			</div>
		</div>
		<div class="bottom" style="text-align: center;">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="imageUpload()"><spring:message code="Cache.btn_Upload"/></a> <!-- 업로드 -->
			<a href="#" class="btnTypeDefault" onclick="parent.Common.Close('target_pop');"><spring:message code="Cache.btn_Close"/></a> <!-- 닫기 -->
		</div>
	</div>
</div>
			
<script>
	initContent();

	// 개인환경설정 > 기본정보 > 이미지업로드 팝업
	function initContent() {
		// 파일 선택, 취소
		$('#uploadfile').on('change', function(e) {
			var file = $(this)[0].files[0];
			
			if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
		});
	}
	
	// 이미지 업로드
	function imageUpload() {
		var file = $('#uploadfile')[0].files[0];
		var extension = file.name.replace(/^.*\./, '').toLowerCase();
		
		if (file.size > 1048576) {
			Common.Warning("<spring:message code='Cache.msg_only1MB'/>"); //1MB 이하만 가능합니다.
			return;
		}
		
		if (extension != 'jpg') {
			Common.Warning("<spring:message code='Cache.msg_onlyJpg'/>"); //jpg만 가능합니다.
			return;
		}
		
 		var formData = new FormData();
		formData.append("uploadfile",$('#uploadfile')[0].files[0]);
		
		$.ajax({
			url: '/groupware/privacy/imageUpload.do',
			processData: false,
			contentType: false,
			data: formData,
			type: 'POST',
			success: function(result) {
				if(result.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_UploadOk'/>", "Inform", function() { //업로드 되었습니다.
						parent.Common.Close("target_pop");
					
						var profileImgPath = coviCmn.loadImage(result.data.photoPath);
						
						$("#myImg", parent.document).attr("src",  profileImgPath+'&time=' + new Date().getTime());
						$("#userImg", parent.document).attr("src", profileImgPath+'&time=' + new Date().getTime());
					});
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); //오류가 발생했습니다.
				}
			},
			error:function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("/groupware/privacy/imageUpload.do", response, status, error);
			}
		});
	}	
</script>
