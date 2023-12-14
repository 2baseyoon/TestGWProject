<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>

<div align="center" >
	<div>
		<table class="AXFormTable">
			<colgroup>
				<col width="100px;"/>
				<col width="*"/>
			</colgroup>
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_DN_Code"/></th>	<!-- 도메인 코드 -->
				<td>
					<select id="add_domain" style="height: 28px;"></select>
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_Upload"/> <spring:message code="Cache.lbl_File"/></th> <!-- 업로드 파일 -->
				<td>
					<a class="btnTypeDefault btnExcel" href="#" onclick="excelDownload();"><spring:message code="Cache.lbl_excelSample"/></a>	<!-- 엑셀양식 -->
				</td>
			</tr>
			<tr>
				<th><font color="red">* </font><spring:message code="Cache.lbl_File"/></th>	<!-- 파일 -->
				<td>
					<input type="text" id="uploadfileText" readonly="readonly" class="AXInput"/>
					<input type="button" value="<spring:message code="Cache.lbl_SelectFile"/>" onclick="$('#uploadfile').click();" class="AXButton"/>	<!-- 파일선택 -->
					<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>
				</td>
			</tr>
			<!-- 업로드 할 엑셀파일은 [정보]-[호환모드 변환] 작업 후 올려주세요 -->
			<!-- 
			<tr>
				<td colspan="2">
					※ <spring:message code="Cache.ACC_msg_excelUpload_1" />	
				</td>
			</tr>
			 -->
		</table>
	</div>
	<div style="padding-top: 10px">
		<input type="button" value="<spring:message code="Cache.btn_Upload"/>" onclick="excelUpload()" class="AXButton" />	<!-- 업로드 -->
		<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer()" class="AXButton"/>	<!-- 닫기 -->
	</div>
</div>

<script type="text/javascript">

$(document).ready(function(){
	
	// Select box 세팅
	coviCtrl.renderDomainAXSelect('add_domain', Common.getSession("lang"), null, null);
	
	//파일 선택, 취소
	$('#uploadfile').on('change', function(e) {
		var file = $(this)[0].files[0];
		
		if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
	});
});

function closeLayer(){
	Common.Close();
}

//양식 다운로드
function excelDownload(){
	Common.Confirm("<spring:message code='Cache.msg_bizcard_downloadTemplateFiles'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
   		if(result){
			var url = "/covicore/baseconfig/uploadSampleDownload.do";
		    var $iframe, iframe_doc, iframe_html;

		    if (($iframe = $('#download_iframe')).length === 0) 
		        $iframe = $("<iframe id='download_iframe' style='display: none' src='about:blank'></iframe>").appendTo("body");

		    iframe_doc = $iframe[0].contentWindow || $iframe[0].contentDocument;
		    if (iframe_doc.document) 
		        iframe_doc = iframe_doc.document;

		    iframe_html = "<html><head></head><body><form method='POST' action='" + url +"'></form></body></html>";

		    iframe_doc.open();
		    iframe_doc.write(iframe_html);
		    $(iframe_doc).find('form').submit();
		}
	});
}

//엑셀 업로드
function excelUpload() {
	
    if($("#uploadfile").val() == ""){
		Common.Error("<spring:message code='Cache.msg_SelectFile' />"); 
        return false;
    }
    
	var formData = new FormData();
	formData.append("add_domain", $('#add_domain').val());
	formData.append("uploadfile",$('#uploadfile')[0].files[0]);
		
	$.ajax({
		url: '/covicore/baseconfig/uploadExcel.do',
		processData: false,
		contentType: false,
		data: formData,
		type: 'POST',
		success: function(result) {
			if(result.status == "SUCCESS"){
				Common.Inform(result.message, "Information Dialog", function(result) {
					Common.Close();	
				});				
			}else{
				Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
			}
		}
	});
}

</script>