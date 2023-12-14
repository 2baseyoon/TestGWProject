<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript" src="/approval/resources/script/forms/WebEditor_Approval_HWP.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Hwp/HwpToolbars.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/covicore/resources/script/Hwp/HwpCtrl.js<%=resourceVersion%>"></script>

<head>
<title></title>
</head>
<body>
	<div class="layer_divpop ui-draggable schPopLayer">
		<div class="divpop_contents" style="padding: 10px;">
			<div class="pop_header" name="default_info">
				<h4 class="divpop_header ui-draggable-handle"><span class="divpop_header_ico">기본 등록사항</span></h4>
			</div>
			<table class="table_3 tableStyle linePlus mt10" cellpadding="0" cellspacing="0" name="default_info">
				<colgroup>
					<col style="width: 20%">
					<col style="width: 30%">
					<col style="width: 20%">
					<col style="width: 30%">
				</colgroup>
				<tr>
					<th>제목</th>
					<td colspan="3"><span id="TITLE"></span></td>
				</tr>
				<tr>		
					<th>시행일자</th>
					<td><span id="COMPLETEDATE"></span></td>		
					<th>등록구분</th>
					<td><span id="REGISTCHECK" name="selectField"></span></td>
				</tr>
				<tr>
					<th>처리과기관코드</th>
					<td><span id="RECORDDEPTCODE"></span></td>
					<th>기록물생산기관명</th>
					<td><span id="RECORDPRODUCTNAME"></span></td>
				</tr>
				<tr>
					<th>생산(접수)등록번호</th>
					<td><span id="PRODUCTNUM"></span></td>
					<th>생산(접수)등록일자</th>
					<td><span id="PRODUCTDATE"></span></td>
				</tr>
				<tr>
					<th>생산기관등록번호</th>
					<td><span id="RECORDSEQ"></span></td>
					<th>기록물문서번호</th>
					<td><span id="OLDPRODUCTNUM"></span></td>
				</tr>
				<!-- 
				<tr>
					<th>분리등록번호(첨부번호)</th>
					<td><span id="ATTACHNUM"></span></td>
					<th>쪽수</th>
					<td><span id="RECORDPAGECOUNT"></span></td>
				</tr>
				 -->
				<tr>
					<th>기안자(업무담당자)</th>
					<td><span id="PROPOSALNAME"></span></td>
					<th>결재권자(직위/직급)</th>
					<td><span id="APPROVALNAME"></span></td>
				</tr>
				<tr>
					<th>수신자(발신자)</th>
					<td><span id="RECEIPTNAME"></span></td>
					<th>문서과배부번호</th>
					<td><span id="DISTNUM"></span></td>
				</tr>
				<tr>
					<th>전자기록물 여부</th>
					<td><span id="RECORDCHECK" name="selectField"></span></td>
					<th>기록물구분(신/구)</th>
					<td><span id="RECORDCLASS" name="selectField"></span></td>
				</tr>
			</table>
			
			<br>
			
			<div class="pop_header" name="record_info">
				<h4 class="divpop_header ui-draggable-handle"><span class="divpop_header_ico">기록물철 등록사항</span></h4>
			</div>
			<table class="table_3 tableStyle linePlus mt10" cellpadding="0" cellspacing="0" name="record_info">
				<colgroup>
					<col style="width: 20%">
					<col style="width: 30%">
					<col style="width: 20%">
					<col style="width: 30%">
				</colgroup>
				<tr>
					<th>분류번호</th>
					<td><span id="RECORDCLASSNUM"></span></td>
					<th>기록물철명</th>
					<td><span id="RECORDSUBJECT"></span></td>
				</tr>
				<tr>
					<th>특수기록물</th>
					<td><span id="SPECIALRECORD" name="selectField"></span></td>
					<th>보존기간</th>
					<td><span id="KEEPPERIOD" name="selectField"></span></td>
				</tr>
				<tr>
					<th>공개여부</th>
					<td>
						<span id="RELEASECHECK" name="selectField"></span>
						<div id="RELEASERESTRICTION" style="display: none;"></div>
					</td>
					<th>열람범위<br>(보안등급)</th>
					<td><span id="SECURELEVEL" name="selectField"></span></td>
				</tr>
			</table>
			
			<br>
			
			<div class="pop_header" name="audiovisual_info" style="display:none">
				<h4 class="divpop_header ui-draggable-handle"><span class="divpop_header_ico">시청각기록물 추가 등록사항</span></h4>
			</div>
			<table class="table_3 tableStyle linePlus mt10" cellpadding="0" cellspacing="0" name="audiovisual_info" style="display:none">
				<colgroup>
					<col style="width: 20%">
					<col style="width: 30%">
					<col style="width: 20%">
					<col style="width: 30%">
				</colgroup>
				<tr>
					<th>내용요약</th>
					<td><span id="CONTENTSUMMARY"></span></td>
					<th>기록물형태</th>
					<td><span id="RECORDTYPE"></span></td>
				</tr>
			</table>
			
			<br>
			
			<div class="pop_header" name="add_info">
				<h4 class="divpop_header ui-draggable-handle"><span class="divpop_header_ico">부가 정보</span></h4>
			</div>
			<table class="table_3 tableStyle linePlus mt10" cellpadding="0" cellspacing="0" name="add_info">
				<colgroup>
					<col style="width: 20%">
					<col style="width: 30%">
					<col style="width: 20%">
					<col style="width: 30%">
				</colgroup>
				<!-- 
				<tr>
					<th>수정여부</th>
					<td><span id="MODIFYCHECK" name="selectField"></span></td>
					<th>반려여부</th>
					<td><span id="REJECTCHECK" name="selectField"></span></td>
				</tr>
				-->
				<tr>
					<th>전자결재문서 팝업</th>
					<td colspan="3"><a class="link_a" id="APPROVALDOCLINK" target="_blank" style="color: blue; text-decoration: underline;"></a></td>
				</tr>
				<!-- 
				<tr id="AttFileInfoList">
					<th id="TIT_ATTFILEINFO">파일경로</th>
					<td colspan="3" id="AttFileInfo"><span id="RECORDFILEPATH"></span>
						
					</td>
				</tr>
				-->
			</table>
			
			<div class="bottom">
				<a class="btnTypeDefault" href="javascript:readerRecordDoc();">조회자</a>
				<a class="btnTypeDefault" href="javascript:editRecordDoc();">수정</a>
				<a class="btnTypeDefault" href="javascript:Common.Close();">닫기</a>
			</div>
		</div>	
	</div>
</body>

<script>

var doc_id = "${doc_id}";
var isAuth = "${isAuth}";
let isRecordDeptAdmin = 'N';
let RecordAdmin = 'N';
var isAdmin = "";

$(window).load(function () {
	if (isAuth == 'N') {
		Common.Warning('조회 권한이 없습니다.', 'Warning', function () {
			Common.Close();
		});
	} else {
		setRestrictionCheckBox();
		setSavedInfo();
		setRecordDeptAdmin();
		setDeptAdmin();
	}
});

function setRestrictionCheckBox() {
	var checkHtml = "";
	for(var i = 1; i <= 8; i++) {
		checkHtml += "<input type='checkbox' name='ReleaseCheckField' id='RELEASECHECK_HO"+i+"'><label for='RELEASECHECK_HO"+i+"'> "+i+"호</label>&nbsp;&nbsp;";
		if(i == 4) {
			checkHtml += "<br/>";
		}
	}
	$("#RELEASERESTRICTION").html(checkHtml);
}

function setSavedInfo() {
	$.ajax({
		url	: "/approval/user/getRecordDocInfo.do",
		type: "POST",
		data: {
			"RecordDocumentID" : doc_id
		},
		success:function (data) {
			if(data.status == "SUCCESS" && data.data != 0){
				var docInfo = data.data.map[0];
				$(".table_3 span, .link_a").each(function(i, obj){
					var id = $(obj).attr("id");
					var name = $(obj).attr("name");
					
					if(name != undefined && name == "selectField") {
						id = id + "_NAME";
					}
					
					var savedVal = docInfo[id];
					
					if(id == "RELEASECHECK_NAME") {
						$(obj).text(savedVal);

						var rstVal = docInfo["RELEASECHECK"];
						var hoArr = rstVal.substring(1).split('');
						for(var h = 1; h <= 8; h++) {
							if(hoArr[h-1] == "Y") {
								$("#RELEASECHECK_HO"+h).prop("checked", "checked");
							} else {
								$("#RELEASECHECK_HO"+h).prop("checked", false);
							}
						}
						
						toggleCheckDiv();
					} else if (id == "APPROVALDOCLINK") {
						if(savedVal != "") {
							$(obj).attr("onclick", "openOrgDoc('"+savedVal+"');");
							$(obj).html(docInfo.TITLE);
						}
					} else if (id == "RECORDFILEPATH"){
						formDisplaySetFileInfo(savedVal);
					} else {
						$(obj).text(CFN_GetDicInfo(savedVal));
					}
				});	
			}else{
				Common.Error("오류가 발생했습니다. 관리자에게 문의 바랍니다.");
			}
		},
		error:function (error){
			Common.Error("오류가 발생했습니다. 관리자에게 문의 바랍니다.");
		}
	});
}

function editRecordDoc() {
	var oApproveStep;
	var iHeight = 800; 
	var iWidth = 1080;
	var sUrl = "/approval/user/goRecordDocWritePopup.do?doc_id="+doc_id;
	var sSize = "scrollbars=yes,toolbar=no,resizable=yes";
	
	CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
	Common.Close();
}

function toggleCheckDiv() {
	if($("#RELEASECHECK").val() == "" || $("#RELEASECHECK").val() == "1") {
		$("#RELEASERESTRICTION").hide();
	} else {
		$("#RELEASERESTRICTION").show();
	}
}

function openOrgDoc(url) {
	var iHeight = 800; 
	var iWidth = 790;
	var sSize = "scrollbars=yes,toolbar=no,resizable=yes";
	var sUrl = url + "&GovRecordID=" + doc_id;
	CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
}

var fileObj;
function formDisplaySetFileInfo(fileInfos) {
	var fileInfoHtml = "";
	fileObj = fileInfos;
	if (fileInfos.length > 0 ) {
		$(fileInfos).each(function(i, fileInfoObj) {
            var l_FileExt = fileInfoObj.name.substring(fileInfoObj.name.lastIndexOf(".") + 1).toLowerCase();
			var className = setFileIconClass(l_FileExt);
		
			fileInfoHtml += "<dl class='excelData'><dt>";
			
			fileInfoHtml += "<a href='#' onclick='attachFileDownLoadCall("+i+")' >";
			fileInfoHtml += "<span class='" + className + "'>파일첨부</span>";
			fileInfoHtml += "<span class='fileName'>" + $$(fileInfoObj).attr("name")+"</span>";
			fileInfoHtml += "<span class='fileSize'>(" + ConvertFileSizeUnit($$(fileInfoObj).attr("size")) + ")</span>";
			fileInfoHtml += "</a>";
		
			fileInfoHtml += "</dt>";
			if (CFN_GetQueryString("listpreview") != "Y") {
				fileInfoHtml += "<dd>";
				fileInfoHtml += "<a class='previewBtn fRight' href='#ax' onclick='attachFilePreview(\"" + $$(fileInfoObj).attr("FileID") + "\",\"" + $$(fileInfoObj).attr("FileToken") + "\",\"" + l_FileExt + "\");'>" + Common.getDic("lbl_preview") + "</a>";
				fileInfoHtml += "</dd>";
			}
			fileInfoHtml += "</dl>";

		});

		$("#AttFileInfo").html(fileInfoHtml);
	}
}

function attachFileDownLoadCall(index) {
	var fileInfoObj = fileObj[index];
	Common.fileDownLoad($$(fileInfoObj).attr("id"), $$(fileInfoObj).attr("name"), $$(fileInfoObj).attr("FileToken"));
}

//첨부파일 미리보기 (Synap)
function attachFilePreview(fileId, fileToken, extention) {
	extention = extention.toLowerCase();
	if (extention ==  "jpg" ||
			extention ==  "jpeg" ||
			extention ==  "png" ||
			extention ==  "tif" ||
			extention ==  "bmp" ||
			extention ==  "xls" ||
			extention ==  "xlsx" ||
			extention ==  "doc" ||
			extention ==  "docx" ||
			extention ==  "ppt" ||
			extention ==  "pptx" ||
			extention ==  "txt" ||
			extention ==  "pdf" ||
			extention ==  "hwp") {
		var url = "/covicore/common/convertPreview.do" + "?fileID=" + fileId + "&fileToken=" + encodeURIComponent(fileToken);
		if(Common.getBaseConfig("usePreviewPopup") == "Y") {
			window.open(url, "", "width=850, height=" + (window.screen.height-100));
		} else {
			if ($("#filePreview").css('display') == 'none') {
				$("#filePreview").show();
				$("#evidPreview").hide();
				
				if(getInfo("ExtInfo.UseWideForm") == "Y") { // 가로양식
					$("#formBox").css('width', '1070px');
					$("#filePreview .conin_view").css("left", "1070px");
				}
				else {
					$("#formBox").css('width', '790px');
					$("#filePreview .conin_view").css("left", "790px");
				}
				
				$("#IframePreview").attr('src', url);
				window.moveTo(0, 0);
				if (window.screen.width < 1550) {
					window.resizeTo(window.screen.width, window.screen.height);
				}
				else {
					window.resizeTo(1550, window.screen.height);
				}
				$("#previewVal").val(fileId);
			} else {
				if ($("#previewVal").val() == fileId) {
					$("#filePreview").hide();
					$("#formBox").css('width', '');
					$("#IframePreview").attr('src', '');
					var centerplaceWidth = (window.screen.width / 2) - 385;
					if (window.screen.width < 1550) {
						window.resizeTo(790, window.screen.height);
						window.moveTo(centerplaceWidth, 0);
					}
					else {
						window.resizeTo(790, window.screen.height);
					}
				} else {
					$("#IframePreview").attr('src', url);
					$("#previewVal").val(fileId);
				}
			}
		}
	} else {
		alert("변환이 지원되지않는 형식입니다.");
		return false;
	}
}


function hasRecordAdmin(){
	$.ajax({
		url: '/approval/user/getRecordAdmin.do',
		type: 'POST',
		data: {'UserId': sessionObj.USERID},
		async: false,
		success: function(data){
			if(data.Cnt >0){
				RecordAdmin = 'Y';
				document.getElementById("selectrecordDept").style.display = '';
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax(url, response, status, error);
		},
	});
}

function setRecordDeptAdmin(){
	$.ajax({
		url: '/approval/user/getRecordDeptAdmin.do',
		type: 'POST',
		data: {'UserId': sessionObj.USERID},
		async: false,
		success: function(data){
			if(data.Cnt >0){
				isRecordDeptAdmin = 'Y';
			}
		},
		error: function(response, status, error){
			CFN_ErrorAjax(url, response, status, error);
		},
	});
}

function setDeptAdmin(){
	if(isAdmin != "Y" && isRecordDeptAdmin != "Y"){
			//document.getElementById('uploadExlBtn').style.display = "none";
			$("#uploadExlBtn").hide();
	}
}

// 조회자 팝업
function readerRecordDoc() {
	const popupID = 'readerRecordDocPopup';
	const popupName = '기록물 조회자';
	const url = '/approval/user/goRecordDocReadPopup.do?doc_id=' + doc_id;
	
	parent.Common.open("",popupID,popupName,url,"1000px","650px","iframe",true,null,null,true);
}
</script>