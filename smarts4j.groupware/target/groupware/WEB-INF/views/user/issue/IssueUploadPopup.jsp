<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>

.divContent{
	padding:20px;
}

.divInnerContent{
	margin:10px;
}

.pTitle{
	width:80px;
	display:inline-block;
	font-weight:bold;
}

.divInnerContent input[type=text]{
	width:240px;	
}

.productTypeLabel{
	margin-right:20px;
}

.issueFile{
	width:100%;
}

.txtFileName{
    display: inline-block;
    width: 290px;
    height: 30px;
    padding: 0 8px;
    line-height: 28px;
    border: 1px solid #eaeaea;
    background: #fff;
    text-overflow: ellipsis;
    overflow: hidden;
    white-space: nowrap;
    position: relative;
    z-index: 1;
}

</style>

<div class="layer_divpop ui-draggable surveryAllPop" id="testpopup_p" style="width:100%;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	
	<form method="POST" enctype="multipart/form-data" id="issueUploadForm">
		<div class="divContent">
			<div class="divInnerContent">
				<p class="pTitle"><spring:message code='Cache.lbl_issue_customerName'/></p><!-- 고객사명 -->
				<input type="text" name="customerName" class="HtmlCheckXSS ScriptCheckXSS"/>
			</div>
			<div class="divInnerContent">
				<p class="pTitle"><spring:message code='Cache.lbl_issue_projectName'/></p><!-- 프로젝트명 -->
				<input type="text" name="projectName" class="HtmlCheckXSS ScriptCheckXSS"/>
			</div>
			<div class="divInnerContent">
				<p class="pTitle"><spring:message code='Cache.lbl_issue_projectManager'/></p><!-- PM명 -->
				<input type="text" name="projectManager" class="HtmlCheckXSS ScriptCheckXSS"/>
			</div>
			<div class="divInnerContent">
				<p class="pTitle"><spring:message code='Cache.lbl_issue_productType'/></p><!-- 제품구분 -->
				<label class="productTypeLabel"><input type="radio" name="productType" value="0">CP</label>
				<label class="productTypeLabel"><input type="radio" name="productType" value="1">MP</label>
			</div>
			<div>
				<div>
					<input type="file" id="IssueFile" name="IssueFile" style="display: none;" accept=".xlsx" onchange="changeAttachFile()">
					<div class="inputFileForm" onclick="clickAttachFile(this);">
						<strong class="txtFileName" id="IssueFileText"></strong>
						<span class="btnTypeDefault btnIco btnThemeLine btnInputFile"></span>
					</div>
				</div>
			</div>	
			<div class="popBottom">
				<a href="#" class="btnTypeDefault btnTypeBg" onclick="javascript:saveComment();"><spring:message code='Cache.lbl_Confirm'/></a> <!-- 확인 -->
				<a href="#" class="btnTypeDefault" onclick="javascript:closeLayer();"><spring:message code='Cache.lbl_Cancel'/></a> <!-- 취소 -->
			</div>
		</div>	
	</form>
</div>
<script>
	var infoMsg="";
	
	//하단의 닫기 버튼 함수
	function closeLayer(){
		Common.Close();
	}

	function saveComment(){
		if(chkValidation()){
			var formData = new FormData();
			formData.append("mode", "create");
			formData.append("menuID", parent.menuID);
			formData.append("bizSection", parent.bizSection);
			formData.append("boardType", parent.CFN_GetQueryString("boardType"));
			formData.append("folderID", parent.folderID);
			
			formData.append("CSMU", "X");
		  	
			var messageData = $('#issueUploadForm').serializeArray();
		    $.each(messageData,function(key,input){
		    	formData.append(input.name,input.value);
		    });
		    
		    formData.append("msgType", "O");	//O: 원본, S: 스크랩
			formData.append("noticeMedia", "");
			formData.append("eventDate", "");
			formData.append("eventType","");
			
			//url = "/groupware/board/createMessage.do";
			formData.append("ownerCode",Common.getSession("USERID"));
			formData.append("msgState", "C");
			
			formData.append("bodySize", 0);
			formData.append("bodyText", "");
			formData.append("bodyInlineImage", "");
			formData.append("body", "");
			formData.append("frontStorageURL", escape(Common.getGlobalProperties("smart4j.path")+ Common.getBaseConfig("FrontStorage").replace("{0}", Common.getSession("DN_Code"))));
			
			var files = document.getElementById("IssueFile").files[0];
			formData.append("files", files);
			
			var fileObj = new Object();
			
			fileObj.FileType = files.fileType; 
			fileObj.FileName = encodeURIComponent(files.fileName);
			fileObj.Size = files.fileSize;
			fileObj.FileID = files.fileId;
			fileObj.FilePath = files.filePath;
			fileObj.SavedName = files.savedName;
			
			formData.append("fileInfos", fileObj);
			
			formData.append("aclList", "");
			formData.append("isInherited", "Y");
			formData.append("step", "0");
			formData.append("depth", "0");
			formData.append("isApproval", "N");
			formData.append("fileCnt", "0");
			formData.append("isTop", "N");
			formData.append("isUserForm", "N");
			formData.append("useRSS", "Y");
			formData.append("useReplyNotice", "Y");
			
			
			$.ajax({
		    	type:"POST",
		    	url: "/groupware/issue/uploadIssueMessage.do",
		    	data: formData,
		    	dataType : 'json',
		        processData : false,
		        contentType : false,
		    	success:function(data){
		    		if(data.status == 'SUCCESS'){
			    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ // 등록되었습니다.
			    			parent.$('#btnRefresh').click();
			    			Common.Close();
			    		});
		    		}else{
		    			Common.Warning(data.message);
		    		}
		    	}, 
		  		error:function(error){
		  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
		  		}
		    });
			
		}else{
			Common.Inform(infoMsg,"Information",function(){});
		}
	}
	
	function chkValidation(){
		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		if($("[name=customerName]").val()==""){
			infoMsg=infoMsg=Common.getDic("msg_chkCustomerName"); //고객사명을 입력해주세요.
			return false;
		}
		
		if($("[name=projectName]").val()==""){
			infoMsg=Common.getDic("msg_chkProjectName"); //프로젝트명을 입력해주세요.
			return false;
		}
		
		if($("[name=projectManager]").val()==""){
			infoMsg=Common.getDic("msg_chkProjectManager"); //PM명을 입력해주세요.
			return false;
		}
		
		if(!($("input:radio[name=productType]").is(":checked"))){
			infoMsg=Common.getDic("msg_chkProductType"); //제품구분을 선택해주세요.
			return false;
		}
		
		if($("#IssueFile").val()==""){
			infoMsg=Common.getDic("msg_chkIssueFile"); //파일을 선택해주세요.
			return false;
		}
		
		return true;
	}

	function clickAttachFile(obj) {
		$("#IssueFile").trigger('click');
	}
	
	function changeAttachFile() {
		if($("#IssueFile").val() != "") {
			chkExtension();
		}
	}
	
	function chkExtension() {
		var ext = $("#IssueFile").val().slice($("#IssueFile").val().indexOf(".") + 1).toLowerCase();
		if (ext != "xlsx") {
			Common.Warning(Common.getDic("msg_cannotLoadExtensionFile"), ""); //불러올 수 없는 확장자 파일입니다.
			if (_ie) { // ie
				$("#IssueFile").replaceWith($("#IssueFile").clone(true));
			} else { // 타브라우저
				$("#IssueFile").val("");
			}
		} else {
			var fileValue = $("#IssueFile").val().split("\\");
			var fileName = fileValue[fileValue.length-1]; // 파일명
			$("#IssueFileText").text(fileName);
		}
	}
	
</script>
