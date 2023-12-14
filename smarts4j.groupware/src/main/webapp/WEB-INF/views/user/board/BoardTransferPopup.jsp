<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<html lang="ko">
	<head>
		<title><%=PropertiesUtil.getGlobalProperties().getProperty("front.title")%></title>
	</head>
	<body>
		<div class="layer_divpop ui-draggable boradPopLayer" id="testpopup_p" style="width:349px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
			<div class="divpop_contents">
				<div class="popContent layerType02 treeDefaultPop mailInputtree">
					<div class="">
						<div class="top">
							<select id="selectMenuID" class="selectType02" onchange="setBoardTreeData();">
							</select>
						</div>
						<div class="middle">
							<div class="mScrollV scrollVType01">
								<div id="coviTree_FolderMenu" class="treeList radio">
								</div>
							</div>
						</div>
						<div class="bottom">
							<div class="popTop">
								<p><spring:message code='Cache.Approval_msg_Transfer'/></p>
							</div>
							<div class="popBottom">
								<a class="btnTypeDefault btnTypeBg" onclick="transferConfirm();"><spring:message code='Cache.CPMail_Confirm'/></a>
								<a class="btnTypeDefault" onclick="transferClose();"><spring:message code='Cache.CPMail_Cancel'/></a>
							</div>
						</div>
					</div>
				</div>
			</div>	
		</div>
	</body>
</html>

<script>
	const g_BizSection = "Board";
	const g_DomainID = Common.getSession("DN_ID");
	const g_MenuID = Common.getBaseConfig('BoardMain', g_DomainID);
	const g_MyFolderTree = new coviTree();
	const body = {
		onclick:function(idx, item) { //[Function] 바디 클릭 이벤트 콜백함수
			if(item.rdo == 'Y'){
				$('#coviTree_FolderMenu_treeRadio_'+item.FolderID).prop('checked',true);
			}
		}
	};
	
	$(document).ready(function() {
		setSelect();
		setBoardTreeData();
	});
	
	function setSelect() {
		$("#selectMenuID").coviCtrl("setSelectOption", 
				"/groupware/admin/selectMenuList.do", 
				{"domainID": g_DomainID, "bizSection": g_BizSection}
		).val(g_MenuID);
	}
	
	function setBoardTreeData(){
		let myFolderTree = g_MyFolderTree;
		const myTreeDivID = "coviTree_FolderMenu";
		const selectMenuID = $("#selectMenuID").val();
		const url = '/groupware/board/selectUserBoardTreeData.do';
		$.ajax({
            type : 'POST',
            url: url,
            data:{
			 	"menuID": selectMenuID,
				"bizSection": g_BizSection
			},
            dataType : 'json',
            success : function(data){
            	if(data.status=='SUCCESS'){
    				const treeList = data.list;
    				myFolderTree.setTreeList(myTreeDivID, treeList, "nodeName", "100%", "left", false, true, body);
    				myFolderTree.expandAll(2);
    				myFolderTree.displayIcon(true);
    				
    				$.each($("input[type=radio][id^=coviTree_FolderMenu_treeRadio_]"), function(idx, el){
    				    var valueObj = JSON.parse(el.value);
    				    if (valueObj['createAuth'] != 'C') {
    				    	$(el).remove();
    				    }
    				});
            	}else{
            		Common.Warning("<spring:message code='Cache.CPMail_AnErrorOccurred'/>", Common.getDic("CPMail_warning_msg"));  //오류가 발생했습니다.
            	}
            },
            error:function(response, status, error){
                CFN_ErrorAjax(url, response, status, error);
            }
		});
	}
	
	// 확인버튼 클릭시
	function transferConfirm(){
		if($('#coviTree_FolderMenu input[type=radio]:checked').length == 0){
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem'/>", Common.getDic("CPMail_warning_msg"));
			return;
		}
		const value = JSON.parse($('#coviTree_FolderMenu input[type=radio]:checked')[0].value);
		const callType = CFN_GetQueryString("callType");
		if (callType != undefined) {
			window[callType].apply(null, [value]);
		}
	}

	// 결재문서 게시이관
	function approvalTransfer(obj) {
		Common.Confirm('<spring:message code='Cache.Approval_msg_Transfer'/>', 'Confirm', function(result) {
			if (result) {
				let copyCss = ''; // style sheet
				Array.from(opener.document.getElementsByTagName('link')).forEach((link) => { 
					copyCss += link.outerHTML; 
				});
				
				let copyBody = opener.document.getElementById('bodytable').cloneNode(true); // body context
				// 문서상 커서 스타일 변경, 클릭 이벤트 삭제
				Array.from(copyBody.getElementsByTagName('*')).forEach((el) => { 
					if (el.style.cursor == 'pointer' || el.tagName == 'A') el.style.cursor = 'auto';
					if (el.hasAttribute('onclick')) el.removeAttribute('onclick');
					if (el.hasAttribute('onmouseover')) el.removeAttribute('onmouseover');
					if (el.hasAttribute('onmouseout')) el.removeAttribute('onmouseout');
					if (el.hasAttribute('href')) el.removeAttribute('href');
				});
				// 첨부 이모티콘, 미리보기 삭제
				if (copyBody.querySelector('#AttFileInfo') != null) {
					Array.from(copyBody.querySelector('#AttFileInfo').getElementsByTagName('dl')).forEach((el) => { 
						el.querySelector('span').remove();
						el.querySelector('dd').remove();
					});
				}
				if (copyBody.querySelector('a.totDownBtn') != null) copyBody.querySelector('a.totDownBtn').remove(); // 전체받기 삭제
				// 서버 pdf  변환용이 아니므로 옵션을 다르게 함. (서버변환용은 photo.do  이미지를 base64 처리하지 않음.)
				var forPdfConvert = "N";
				opener.convertInlineImages(copyBody, forPdfConvert); // img tag to base64
				
				// 첨부파일
				let fileInfoList = new Array();
				JSON.parse(opener.getInfo('FileInfos')).forEach((file) => {
					fileInfoList.push(file);
				});
				
				let approvalFormData = new Object();
				approvalFormData.subject = opener.getInfo('ProcessInfo.ProcessDescription.FormSubject');
				approvalFormData.body = escape(copyCss + copyBody.innerHTML.replace(/\n/gi, '').replace(/\t/gi, '').replace(/\r/gi, ''));
				approvalFormData.bodyText = copyBody.innerText.replace(/<.+\>/g, '').replace(/\n/gi, '').replace(/\t/gi, '').replace(/\r/gi, '').trim();
				approvalFormData.fileInfoList = fileInfoList;
				approvalFormData.userCode = opener.getInfo("AppInfo.usid");
				approvalFormData.folderID = obj.FolderID;
				approvalFormData.messageAuth = "[]";
				approvalFormData.registDept = opener.getInfo("AppInfo.dpnm");
				approvalFormData.DNID = opener.getInfo("AppInfo.etid");
				approvalFormData.groupCode = opener.getInfo("AppInfo.grpath").split(';')[0];
				approvalFormData.ownerCode = opener.getInfo("AppInfo.usid");
				approvalFormData.number = opener.document.getElementById('DocNo').innerText;
				approvalFormData.registDate = opener.getInfo("AppInfo.svdt");
				
				$.ajax({
					contentType: "application/json; charset=utf-8",
					url:"/groupware/board/approvalTransferMessage.do",
					type:"POST",
					data:JSON.stringify(approvalFormData),
					processData: false,
					async:false,
					success:function (data) {
						if (data.status === "SUCCESS") {
							Common.Inform(Common.getDic('msg_170'), 'Inform', function () { // 완료되었습니다.
								Common.Close();
							});
						} else {
							Common.Error(Common.getDic('ACC_msg_error')); // 오류가 발생하였습니다.관리자에게 문의하세요.
						}
					},
					error:function (error){
						Common.Error(Common.getDic('ACC_msg_error')); // 오류가 발생하였습니다.관리자에게 문의하세요.
					}
				});
			}
		});
	}

	// 팝업닫기
	function transferClose(){
		Common.Close();
	}
</script>