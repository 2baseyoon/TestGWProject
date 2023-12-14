<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.psTaskExam {
	background-image:url('/HtmlSite/smarts4j_n/covicore/resources/images/common/pstask_excelImg.png');
}

</style>

<div class="popContent vmExcelUploadPopup" style="padding: 0px 24px 30px;">
	<div class="">
		<div class="top" style="margin-top: 20px;">
			<strong style="font-size: 17px;"><spring:message code="Cache.lbl_ExcelTemplateuplad" /></strong>  <%-- 전결규정 엑셀 업로드 --%>
			<div class="ulList type02 mt20">
				<ul>
					<li class="listCol">
						<div>
							<input type="text" id="uploadfileText" placeholder="<spring:message code='Cache.lbl_vacationMsg30' />" style="width:300px;" readonly>
							<a href="#" class="btnTypeDefault" onclick="$('#uploadfile').click();"><spring:message code="Cache.lbl_SelectFile" /></a>
							<a class="btnTypeDefault" onclick="excelDownLoad();" href="#"><spring:message code="Cache.lbl_ExcelTemplateDown" /></a>
							<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>
						</div>
					</li>								
				</ul>							
			</div>
			<ul class="noticeTextGrayBox">
				<li>* 주의사항</li>
				<li>- 파일형식: Excel (*.xls)</li>
				<li>- 1행은 제목, 2행부터 처리시작</li>
				<li>- code01,code02,code03,code04,code05 5개읠 컬럼을 합쳐서 유일한 키를 생성하기 때문에 합친 문자가 중복이 있으면 안됩니다.</li>
				<li>- charge는 기안자를 의미합니다.</li>
				<li>- 결재자는 10명까지 세팅이 가능합니다.(approval01 ~ approval10)</li>
			</ul>
			<br>
			<div>
				<p><strong>(예제)</strong></p>
				<table class="tableStyle linePlus mt10">
				<colgroup>
					<col style="width:3%" />
					<col style="width:5%" />
					<col style="width:5%" />
					<col style="width:5%" />
					<col style="width:5%" />
					<col style="width:5%" />
					<col style="width:7%" />
					<col style="width:7%" />
					<col style="width:7%" />
					<col style="width:7%" />					
					<col style="width:7%" />		
					<col style="width:5%" />
					<col style="width:8%" />	
					<col style="width:8%" />	
					<col style="width:8%" />														
				</colgroup>
					<tr>
					    <th></th>
						<th>code01</th>
						<th>code02</th>
						<th>code03</th>
						<th>code04</th>
						<th>code05</th>
						<th>name01</th>
						<th>name02</th>
						<th>name03</th>
						<th>name04</th>
						<th>name05</th>
						<th>charge</th>
						<th>approval01</th>
						<th>approval02</th>
						<th>approval03</th>
					</tr>
					<tr>
						<th>1</th>
						<td>01</td>
						<td>01</td>
						<td>01</td>
						<td></td>
						<td></td>
						<td>휴가신청</td>
						<td>연차유급휴가</td>
						<td>본부장</td>
						<td></td>
						<td></td>
						<td>본부장</td>
						<td>사장</td>
						<td></td>
						<td></td> 											
					</tr>
					<tr>
						<th>2</th>
						<td>01</td>
						<td>01</td>
						<td>03</td>
						<td></td>
						<td></td>
						<td>휴가신청</td>
						<td>연차유급휴가</td>
						<td>팀장</td>
						<td></td>
						<td></td>
						<td>팀장</td>
						<td>소속부본부장</td>
						<td>소속본부장</td>
						<td>사장</td> 											
					</tr>
					<tr>
						<th>3</th>
						<td>02</td>
						<td>01</td>
						<td></td>
						<td></td>
						<td></td>
						<td>재경심사</td>
						<td>환예약</td>
						<td></td>
						<td></td>
						<td></td>
						<td>팀원</td>
						<td>소속팀장</td>
						<td></td>
						<td></td>	 											
					</tr>					
				</table>

			</div>
		</div>
		<div class="bottom" style="text-align: center; padding-top:30px;">
			<a href="#" class="btnTypeDefault btnTypeBg" onclick="decDrmDocument();"><spring:message code='Cache.btn_apv_save' /></a>
			<a href="#" class="btnTypeDefault" onclick="Common.Close();"><spring:message code='Cache.btn_Close' /></a>
		</div>
	</div>
</div>
			
<script>
	initContent();

	function initContent() {
		// 파일 선택, 취소
		$('#uploadfile').on('change', function(e) {
			var file = $(this)[0].files[0];
			
			if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
		});
	}
	
	function decDrmDocument() {
		var formData = new FormData();
		formData.append("uploadfile",$('#uploadfile')[0].files[0]);
		var list;
		$.ajax({
			url: '/approval/admin/decRequestApproval.do',
			processData: false,
			contentType: false,
			data: formData,
			type: 'POST',
			async: false,
			success: function(result) {
				if(result.status=="SUCCESS"){
					excelUpload(result.FilePath);
				}else{
					Common.Warning("<spring:message code='Cache.msg_SelectFile' />")			
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/decRequestApproval.do", response, status, error);
			}
		});
	} 
	
	// 엑셀 업로드
	function excelUpload(FilePath) {
		var list;
		 var text = "<spring:message code='Cache.msg_checkExcelUplad' />";  //업로드시에 기존 전결규정 데이터가 전부 삭제되고 새로 등록 됩니다.</br> 진행하시겠습니까?
		 
		Common.Confirm(text, "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				Common.Progress(); 
				$.ajax({
					type:"POST",
					data:{
						"FilePath" : Base64.utf8_to_b64(FilePath),
						"entcode" : opener.$("#selectUseAuthority").val()
					},   
					url:"/approval/admin/excelUploadRuleManage.do",
					success:function (result) {		
						if(result.status=="SUCCESS"){
							list = result.data;
		
							alert("<spring:message code='Cache.msg_UploadOk' />")
							Common.AlertClose();
							Common.Close();
						}else{
							Common.AlertClose();
							Common.Warning(result.message);			
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("excelUploadBudget.do", response, status, error);
					}
				});
			} else {
				return false;
			}
		});	
	}	
	
	function fileDownLoad(pFileID, pFileName) {
	    var fileUrl = String.format('/covicore/common/ReferenceFileDown.do?BaseConfigID={0}', pFileID);
	    if (navigator.msSaveBlob) {			//IE의 경우 인스턴트용 폼 생성하여 Submit 후  삭제
	        var downLoadFrm = $('<form id="frmDownload" name="frmDownload"/>')
	            .attr('action', fileUrl)
	            .attr('method', 'POST');
	        $('body').append(downLoadFrm);

	        $('#frmDownload').submit();
	        $('#frmDownload').remove();
	    } else {
	        var anchor = $('<a />')
	            .attr('href', fileUrl)
	            .attr('download', pFileName);	//다운로드시 생성될 파일명 ( 저장시점의 원본파일명 )
	        setTimeout(function () {
	            // 사파리에서 동작하지 않는 문제 해결을 위함
	            try {
	                var a = anchor[0];
	                var evObj = document.createEvent('MouseEvents');
	                evObj.initMouseEvent('click', true, true, window);
	                a.dispatchEvent(evObj);
	            } catch (e) {
	                // IE에서는 위 함수가 실행되지 않는 문제 해결을 위함
	                anchor[0].click();
	            }
	            anchor.remove();
	        }, 300);
	    }
	}
	
	function excelDownLoad(){
		location.href = "excelRulManageDownload.do?entcode="+opener.$("#selectUseAuthority").val();
	}
</script>
