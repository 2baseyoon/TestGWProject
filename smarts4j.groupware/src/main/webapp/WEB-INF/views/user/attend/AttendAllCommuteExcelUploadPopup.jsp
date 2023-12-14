<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<style>
	.popupBody { padding: 20px; }
	
	.bottom {
		padding-top: 15px;
		text-align: center;
	}
	.ulList .btnTypeDefault { margin: 0; }
</style>
<body>
	<div class="popupBody">
		<div class="top">
			<ul class="noticeTextGrayBox">
				<li><spring:message code="Cache.msg_allCommuteExcelUploadInform"/></li> <!-- 템플릿 파일에 일괄 출퇴근 데이터 작성 후 업로드 해주세요. -->
				<li><spring:message code="Cache.msg_attCommuteExcelWritingInform"/></li> <!-- 엑셀에 출퇴근 시간 작성 시 해당 시간이 등록되고 작성하지 않을 시 관리자 설정에서 적용된 시간으로 등록됩니다. -->
			</ul>
			<div class="ulList type02 mt20">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_chooseExcelFile"/></strong></div> <!-- 엑셀 파일 선택 -->
						<div>
							<input type="file" name="uploadfile"/>
						</div>
					</li>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_templatedownload"/></strong></div> <!-- 템플릿 파일 다운로드 -->
						<div>
							<a id="btnTemplateDown" class="btnTypeDefault" href="#"><spring:message code="Cache.lbl_templatedownload"/></a> <!-- 템플릿 파일 다운로드 -->
						</div>
					</li>
				</ul>
			</div>
		</div>
		<div class="bottom">
			<a id="btnAdd" class="btnTypeDefault btnTypeBg" href="#"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->
			<a id="btnClose" class="btnTypeDefault" href="#"><spring:message code="Cache.btn_Close"/></a> <!-- 닫기 -->
		</div>
	</div>
</body>
<script>
	
	$(document).ready(function(){
		// 추가
		$("#btnAdd").off("click").on("click", function(){
			excelUpload();
		});
		
		// 닫기
		$("#btnClose").off("click").on("click", function(){
			Common.Close();
		});
		
		// 템플릿 파일 다운로드
		$("#btnTemplateDown").off("click").on("click", function(){
			excelTemplateDownload();
		});
	});
	
	// 템플릿 파일 다운로드
	function excelTemplateDownload() {
		Common.Confirm("<spring:message code='Cache.msg_bizcard_downloadTemplateFiles'/>", "Confirm", function(res){ // 템플릿 파일을 다운로드 하시겠습니까?
			if (res) {
				location.href = '/groupware/attendUserSts/allCommuteExcelTemplateDownload.do';
			}
		})
	}
	
	// 엑셀 업로드
	function excelUpload() {
		var formData = new FormData();
		formData.append("uploadfile", $("input[name=uploadfile]")[0].files[0]);
		
		$.ajax({
			url: "/groupware/attendUserSts/allCommuteExcelUpload.do",
			type: "POST",
			processData: false,
			contentType: false,
			data: formData,
			success: function(result){
				if (result.status === "SUCCESS") {
					Common.Inform("<spring:message code='Cache.msg_UploadOk'/>", "Inform", function(res){ // 업로드 되었습니다.
						if (res) Common.Close();
					});
				} else {
					if (result.data === -1) {
						Common.Warning("<spring:message code='Cache.mag_Attendance23'/>"); // 지정일에 근무가 없습니다.
					} else {
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생했습니다.
					}
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/attendUserSts/allCommuteExcelUpload.do", response, status, error);
			}
		});
	}
</script>