<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'>
	<meta http-equiv='expires' content='0'>
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>
<style>
.fileSize {
    width: auto;
    max-width: 80px;
    margin-left: 4px;
    margin-top: 1px;
}

.woRd {
   height: 18px !important;
}

.word {
    padding-left: 26px;
    line-height: 17px;
    color: #000;
    background: url('/HtmlSite/smarts4j_n/covicore/resources/images/common/ic_word.png') no-repeat 0 center;
    text-indent: 0 !important;    
}
</style>
<body>
	<div class="layer_divpop ui-draggable popBizCardView" id="testpopup_p" style="width:700px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div class="rowTypeWrap contDetail">
					<dl>
						<dt><spring:message code='Cache.lbl_TFProgress' /></dt> <!-- 진행상황 -->
						<dd><span id="spnState" ></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_TFName' /></dt> <!-- T/F 팀룸 명 -->
						<dd><span id="spnTFName" ></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_task_folder' /></dt> <!-- 분류 -->
						<dd><span id="spnCategory" ></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_HeadDept' /></dt> <!-- 주관부서 -->
						<dd><span id="spnMajorDept" ></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_TFPeriod' /></dt> <!-- 수행기간 -->
						<dd><span id="spnStartDate" ></span> ~ <span id="spnEndDate" ></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_TFPM' /></dt> <!-- PM -->
						<dd><span id="spnPM"></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_TFMember' /></dt> <!-- 팀원 -->
						<dd><span id="spnMember"></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_TFContent' /></dt> <!-- 추진내용 -->
						<dd><span id="spnSearchTitle"></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_apv_linkdoc' /></dt> <!-- 연결문서 -->
						<dd class="docLinksList" id="docLinksList"></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_biztask_linkCollaboration' /></dt> <!-- 연결협업 -->
						<dd class="collaboLinksList" id="collaboLinksList"></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_apv_filelist' /></dt> <!-- 첨부파일 -->
						<dd class="attFileListBox" style="position:relative;"></dd>
					</dl>
					<input type="hidden" id="hidDocLinks">
				</div>
				<div class="popBtnWrap">
					<a href="#" class="btnTypeDefault" onclick="closePopup();"><spring:message code='Cache.lbl_close' /></a>
				</div>
			</div>
		</div>	
	</div>
</body>

<script>
	var CU_ID = CFN_GetQueryString("CU_ID");
	
	$(function() {
		setData();
	});
	
	function setData() {
		$(".rowTypeWrap").find("dl > dt, dl > dd").css("line-height", "24px");
		$(".rowTypeWrap").find("dl > dt").attr("style", "font-weight:700 !important");
		
		$.ajax({
			type:"POST",
			data:{
				"CU_ID" : CU_ID
			},
			async : false,
			url:"/groupware/layout/selectTFDetailInfo.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					if(data.TFInfo != undefined && data.TFInfo.length > 0) {
						var info = data.TFInfo[0];
						
						$("#spnState").html(info.AppStatusName);
						$("#spnTFName").html(info.CommunityName);
						$("#spnCategory").html(info.TF_GUBUN);
						$("#spnMajorDept").html(info.TF_MajorDept);
						
						$("#spnStartDate").html(info.TF_StartDate);
						$("#spnEndDate").html(info.TF_EndDate);
						
						$("#spnPM").html(getTFUserName(info.TF_PM));
						$("#spnAdmin").html(getTFUserName(info.TF_Admin));
						$("#spnMember").html(getTFUserName(info.TF_Member));
						$("#spnViewer").html(getTFUserName(info.TF_Viewer));
						
						$("#spnSearchTitle").html(unescape(info.Description).replace(/(\r\n|\n|\r)/g,"<br />"));
						
						//TODO: 연결문서
						$("#hidDocLinks").val(info.TF_DocLinks);
						G_displaySpnDocLinkInfo();
						
						//연결협
						gridCollaboList(info.TF_CollaboLinks);
						
						if(data.fileList != undefined && data.fileList.length > 0) {
							var fileList = data.fileList;
							
							$(".attFileListBox").html("");
							
							var attFileAnchor = $('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');"/>').addClass('btnAttFile btnAttFileListBox').text('(' + fileList.length + ')');
							var attFileListCont = $('<ul>').addClass('attFileListCont').attr("style", "left: 0;");
							var attFileDownAll = $('<li>').append("<a href='#' onclick='javascript:downloadAll(fileList)'><spring:message code='Cache.lbl_download_all'/></a>").append($('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');" >').addClass("btnXClose btnAttFileListBoxClose"));
							var attFileList = $('<li>');
							var videoHtml = '';
							
							$.each(fileList, function(i, item){
								var iconClass = "";
								if(item.Extention == "ppt" || item.Extention == "pptx"){
									iconClass = "ppt";
								} else if (item.Extention == "excel" || item.Extention == "xlsx" || item.Extention == "xls"){
									iconClass = "fNameexcel";
								} else if (item.Extention == "pdf"){
									iconClass = "pdf";
								} else if (item.Extention == "doc" || item.Extention == "docx"){
									iconClass = "word";
								} else if (item.Extention == "zip" || item.Extention == "rar" || item.Extention == "7z"){
									iconClass = "zip";
								} else if (item.Extention == "jpg" || item.Extention == "gif" || item.Extention == "png"|| item.Extention == "bmp"){
									iconClass = "attImg";
								} else {
									iconClass = "default";
								}
								$(attFileList).append($('<p style="cursor:pointer;"/>').attr({"fileID": item.FileID, "fileToken": item.FileToken}).addClass('fName').append($('<span title="'+item.FileName+'">').addClass(iconClass).text(item.FileName)).append($('<span class="fileSize">').text("("+convertFileSize(item.Size)+")")));
							});
							
							$(attFileListCont).append(attFileDownAll, attFileList);
							$('.attFileListBox').append(attFileAnchor ,attFileListCont);
							$('.attFileListBox .fName').click(function(){
								Common.fileDownLoad($(this).attr("fileID"), $(this).text(), $(this).attr("fileToken"));
							});
							$('.attFileListBox').show();
						} else {
							$('.attFileListBox').hide();
						}
					} 
				}
			},
			error:function(response, status, error){
			 CFN_ErrorAjax("/groupware/layout/selectTFDetailInfo.do", response, status, error);
			}
		});
	}
	
	function getTFUserName(data) {
		var result = "";
		var data = data.split("@");
		
		for(var i = 0; i < data.length; i++) {
			if(data[i] != "") {
				var temp = data[i];
				result += temp.split("|")[1] + ",";
			}
		}
		
		if(result.length > 0) {
			result = result.substring(0, result.length-1);
		}
		
		return result;
	}
	
	function closePopup() {
		Common.Close();
	}
	function G_displaySpnDocLinkInfo() {//수정본
		var szdoclinksinfo = "";
		var szdoclinks =  $("#hidDocLinks").val();
		szdoclinks = szdoclinks.replace("undefined^", "");
		szdoclinks = szdoclinks.replace("undefined", "");
		var bEdit = false; 
		if (document.location.href.indexOf("Info.") > -1 || document.location.href.indexOf("InfoViewPopup.") > -1) {
			bEdit = false;
		} else {
			bEdit = true;
		}
		
		if (szdoclinks != "") {
			if (bEdit) {
				szdoclinksinfo += "<a onclick='openDocLinkTF()' class='btnTypeDefault'>"+"<spring:message code='Cache.lbl_apv_linkdoc' />"+"</a>";
				szdoclinksinfo += "&nbsp;<a onclick='deleteDocLinkTF()' class='btnTypeDefault'>"+"<spring:message code='Cache.lbl_apv_link_delete' />"+"</a><br />";
			}
			var adoclinks = szdoclinks.split("^^^");
			for (var i = 0; i < adoclinks.length; i++) {
				var adoc = adoclinks[i].split("@@@");
				var FormUrl = document.location.protocol + "//" + document.location.host + "/approval/approval_Form.do";
				var iWidth = 790;
				var iHeight = window.screen.height - 82;
				if (bEdit) {
					szdoclinksinfo += "<input type=checkbox id='chkDoc' name='_" + adoc[0] + "' value='" + adoc[0] + "' class='td_check' style='float:none;'>";
					szdoclinksinfo += "<span class='td_txt' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;float:none;'  onclick=\"CFN_OpenWindow('";
					szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
					szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">" + adoc[2] + "</span><br />";
				} else {
					szdoclinksinfo += "<span class='txt_gn11_blur' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;'  onclick=\"CFN_OpenWindow('";
					szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
					szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \">- " + adoc[2] + "</span><br />";
				}
			}
		}
		
		$("#docLinksList").html(szdoclinksinfo);
	}
	
	function gridCollaboList(_collaboList){
		if(_collaboList!=undefined && _collaboList.length>0){
			var cHtml = "";
			_collaboList.forEach(function (item){
				//cHtml += "<input type='checkbox' name='_" + item.CU_ID + "' value='" + item.CU_ID +"' class='td_check' style='float:none;'>";
				cHtml += "<span class='txt_gn11_blur' onmouseover='this.style.color=\"#2f71ba\";' onmouseout='this.style.color=\"#111111\";'  style='cursor:pointer;float:left;' >";
				cHtml += "- "+item.CommunityName;
				cHtml += "</span></br>"
			});
			
			$("#collaboLinksList").html(cHtml);
		}
	}
	
	function convertFileSize(pSize) {
		var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
	    if (pSize == 0) return 'n/a';
	    var i = parseInt(Math.floor(Math.log(pSize) / Math.log(1024)));
	    return (pSize / Math.pow(1024, i)).toFixed(1) + sizes[i];
	}
</script>