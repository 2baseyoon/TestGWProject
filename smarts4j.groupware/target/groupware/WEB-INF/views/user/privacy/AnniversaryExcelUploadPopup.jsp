<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" style="padding: 0px 24px 30px;">
	<div class="">
		<div class="top">					
			<ul class="noticeTextGrayBox">
				<li>※ <spring:message code="Cache.msg_SelectFile"/></li> <!-- 파일을 선택해 주세요. -->
			</ul>
			<div class="ulList type02 mt20">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_AnniversaryFileSelect"/></strong></div>
						<div>
							<input type="file" name="uploadfile"/>
						</div>
					</li>								
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_templatedownload"/></strong></div>  <!-- 템플릿 파일 다운로드 -->
						<div>
							<a href="#" class="btnTypeDefault" onclick="excelTemplateDownload();"><spring:message code="Cache.lbl_templatedownload"/></a> <!-- 템플릿 파일 다운로드 -->
						</div>
					</li>						
				</ul>							
			</div>
			
		</div>
		<div class="bottom">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="excelUpload()"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->
			<a href="#" class="btnTypeDefault" onclick="Common.Close()"><spring:message code="Cache.btn_Close"/></a> <!-- 닫기 -->
		</div>
	</div>
</div>

<script>
	// 템플릿 파일 다운로드
	function excelTemplateDownload() {
 		if (confirm("<spring:message code='Cache.msg_bizcard_downloadTemplateFiles'/>")) { //템플릿 파일을 다운로드 하시겠습니까?
			location.href = '/groupware/privacy/excelTemplateDownload.do';
		}
	}
	
	// 추가
	function excelUpload() {
		var formData = new FormData();
		formData.append("uploadfile",$("input[name=uploadfile]")[0].files[0]);
		
		$.ajax({
			url: '/groupware/privacy/excelUpload.do',
			processData: false,
			contentType: false,
			data: formData,
			type: 'POST',
			success: function(result) {
				Common.Inform("<spring:message code='Cache.msg_UploadOk'/>", "Inform", function() { //업로드 되었습니다.
					if(opener){
						opener.searchData();
						opener.Common.Close("target_pop");
					}else{
						parent.searchData();		
						parent.Common.Close("target_pop");
					}
					
				});
			}
		});
	}	
</script>
