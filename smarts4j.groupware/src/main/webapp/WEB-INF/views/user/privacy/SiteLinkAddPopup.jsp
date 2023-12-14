<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/groupware/resources/script/user/task.js"></script>

<style>
	.bottom { text-align: center; margin-top: 10px; }
	.AXFormTable input {
		width: 90%;
		height: 26px !important;
		border: 1px solid #d9d9d9;
		vertical-align: top;
		padding: 0px
	}
</style>

<div class="divpop_contents" style="height:100%;">
	<div class="divpop_body" style="overflow:hidden; padding:0;">
		<div class="popContent">
			<div class="middle">
				<table class="AXFormTable">
					<colgroup>
						<col width="40%" />
						<col width="60%" />
					</colgroup>
					<tr>
						<th><font color="red">* </font><spring:message code="Cache.lbl_SiteLinkName"/></th> <!-- 사이트링크 이름 -->
						<td>
							<input type="text" id="siteLinkName" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><font color="red">* </font><spring:message code="Cache.lbl_SiteLinkAddress"/></th> <!-- 사이트링크 주소 -->
						<td>
							<input type="text" id="siteLinkURL" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
					<tr>
						<th><spring:message code="Cache.lbl_Thumbnail"/></th> <!-- 썸네일 -->
						<td>
							<input type="text" id="uploadfileText" placeholder="<spring:message code='Cache.lbl_vacationMsg30'/>"><a href="#" class="btnTypeDefault" onclick="$('#thumbnail').click();"><spring:message code="Cache.lbl_SelectFile"/></a> <!-- 선택된 파일 없음 / 파일선택 -->
							<input type="file" id="thumbnail" style="display:none;">
						</td>
					</tr>
					<tr>
						<th><spring:message code="Cache.lbl_SortOrder"/></th> <!-- 정렬순서 -->
						<td>
							<input type="text" id="sortKey" mode="number" class="AXInput HtmlCheckXSS ScriptCheckXSS"/>
						</td>
					</tr>
				</table>
			</div>
			<div class="bottom">
				<a href="#" id="btnAdd" class="btnTypeDefault btnTypeChk" style="display: none;"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->
				<a href="#" id="btnModify" class="btnTypeDefault btnTypeChk" style="display: none;"><spring:message code="Cache.btn_Modify"/></a> <!-- 수정 -->
				<a href="#" id="btnCancel" class="btnTypeDefault"><spring:message code="Cache.btn_Cancel"/></a> <!-- 취소 -->
			</div>
			<input type="hidden" id="siteLinkID" />
		</div>
	</div>
</div>

<script>
	var mode = CFN_GetQueryString("mode") == "undefind" ? "" : CFN_GetQueryString("mode");
	var callBackFunc = CFN_GetQueryString("callBackFunc") == "undefined" ? "" : CFN_GetQueryString("callBackFunc");
	var openerID = CFN_GetQueryString("openerID") == "undefined" ? "" : CFN_GetQueryString("openerID");
	
	function init(){
		// 파일 선택, 취소
		$('#thumbnail').on('change', function(e) {
			var file = $(this)[0].files[0];
			
			if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
		});
		
		if(mode == "Add") $("#btnAdd").show();
		else if(mode == "Modify"){
			var siteLinkID = CFN_GetQueryString("siteLinkID") == "undefind" ? "" : CFN_GetQueryString("siteLinkID");
			
			$("#btnModify").show();
			$("#siteLinkID").val(siteLinkID);
			
			getSiteLinkData(siteLinkID);
		}
		
		setEvent();
	}
	
	function setEvent(){
		$("#btnCancel").click(function(){
			Common.Close();
		});
		
		$("#btnAdd, #btnModify").click(saveSiteLink);
	}
	
	function getSiteLinkData(pSiteLinkID){
		$.ajax({
			url: "/groupware/pnPortal/selectSiteLinkData.do",
			type: "POST",
			data: {
				"siteLinkID": pSiteLinkID
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var listData = data.list[0];
					
	        		$("#siteLinkID").val(listData.SiteLinkID);
	        		$("#siteLinkName").val(listData.SiteLinkName);
	        		$("#siteLinkURL").val(listData.SiteLinkURL);
	        		if(listData.Thumbnail != ""){
	        			var ThumbTitleName = listData.Thumbnail.split("/")[3];
	        			$('#uploadfileText').val(ThumbTitleName);
	        		}else{
	        			$('#uploadfileText').val('');
	        		}
	        		$("#sortKey").val(listData.SortKey);
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	function saveSiteLink(){
		if(!checkValidation()) return false;
		
		var url = "/groupware/pnPortal/insertSiteLink.do";
		var formData = new FormData();
		
		if(mode == "Modify") url = "/groupware/pnPortal/updateSiteLink.do";
		
		formData.append("siteLinkID", $("#siteLinkID").val());
		formData.append("siteLinkName", $("#siteLinkName").val());
		formData.append("siteLinkURL", $("#siteLinkURL").val());
		formData.append("thumbnail", $("#thumbnail")[0].files[0]);
		formData.append("sortKey", $("#sortKey").val());
		
		$.ajax({
			url: url,
			type: "POST",
			data: formData,
			dataType: "json",
            processData: false,
	        contentType: false,
			success: function(data){
				if(data.status == "SUCCESS"){
	        		Common.Inform("<spring:message code='Cache.msg_Been_saved'/>", "Information", function(result){ // 저장되었습니다
	        			if(callBackFunc){
	        				try{
	        					if(openerID){
	    			    			XFN_CallBackMethod_Call(openerID, callBackFunc, "");
	    			    		}else{
	    			    			callBackFunc = "parent.window."+callBackFunc+"()";
	    			    			new Function (callBackFunc).apply();
	    						}
	        					Common.Close();
	        				}catch(e){
	        					console.error(e);
	        				}
	        			}else{
	        				Common.Close();
	        			}
	        		});
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
	
	function checkValidation(){
		if (!XFN_ValidationCheckOnlyXSS(false)) return false;
		
		if(!$("#siteLinkName").val()){
			Common.Warning("<spring:message code='Cache.msg_EnterSiteLinkName'/>", "Warning", function(result){ // 사이트링크 이름을 입력해주세요.
				$("#siteLinkName").focus();
			});
			return false;
		}else if(!$("#siteLinkURL").val()){
			Common.Warning("<spring:message code='Cache.msg_EnterSiteLinkAddress'/>", "Warning", function(result){ // 사이트링크 주소를 입력해주세요.
				$("#siteLinkURL").focus();
			});
			return false;
		}else{
			return true;
		}
	}
	
	init();
</script>