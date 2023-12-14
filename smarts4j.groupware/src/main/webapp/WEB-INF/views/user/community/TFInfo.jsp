<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop">
	<h2 class="title"><spring:message code='Cache.lbl_TFInfo'/></h2>						
</div>
<div class="ITMtrpfield_table_wrap pjtinfo_wrap">
	<p class="pjtroom_title"><spring:message code='Cache.lbl_baseInfo'/></p>
	<table class="pjtroom_info" cellpadding="0" cellspacing="0">
		<tbody>		
		<tr>
			<th><spring:message code='Cache.lbl_TFProgress' /></th> <!-- 주관부서 -->
			<td><span id="cState" ></span></td>
		</tr>
		<tr>
			<th><spring:message code='Cache.lbl_TFName' /></th> <!-- 주관부서 -->
			<td><span id="cTFName" ></span></td>
		</tr>				
		<tr>
			<th><spring:message code='Cache.lbl_HeadDept' /></th> <!-- 주관부서 -->
			<td><span id="cMajorDept" ></span></td>
		</tr>
		<tr>
			<th><spring:message code='Cache.lbl_TFPeriod' /></th> <!-- 수행기간 -->
			<td><span id="cStartDate" ></span> ~ <span id="cEndDate" ></span></td>
		</tr>
		<tr>
			<th><spring:message code='Cache.lbl_TFPM' /></th> <!-- PM -->
			<td><span id="cPM"></span></td>
		</tr>
		<tr>
			<th><spring:message code='Cache.lbl_TFAdmin' /></th>
			<td><span id="cAdmin"></span></td>
		</tr>
		<tr>
			<th><spring:message code='Cache.lbl_TFMember' /></th> <!-- 간사 -->
			<td><span id="cMember"></span></td>
		</tr>
		<tr>
			<th><spring:message code='Cache.lbl_TFContent' /></th> <!-- 추진내용 -->
			<td><span id="cSearchTitle"></span></td>
		</tr>
		</tbody>
	</table>	
	<div class="pjtroom_title_wrap"><p class="pjtroom_title"><spring:message code='Cache.lbl_att_approvalForm'/></p><input type="hidden" id="hidDocLinks"></div>
	<div id="docLinksList">
		<ul class="appdoc_list">
			<li><a href="#" class="btn_File ico_doc" style="">연결문서입니다</a></li>
			<li><a href="#" class="btn_File ico_doc" style="">연결문서입니다</a></li>
			<li><a href="#" class="btn_File ico_doc" style="">연결문서입니다</a></li>
		</ul>
	</div>			
	<div class="pjtroom_title_wrap">
		<p class="pjtroom_title"><spring:message code='Cache.lbl_apv_filelist' /></p>
		<!-- <a id="aBtnAllDown" href='#' class="btnAllDown" onclick='javascript:downloadAll(l_fileList)' style='display:none;'><span><spring:message code='Cache.lbl_download_all'/></span></a> -->
	</div>
	<div id="divFileList"></div>			
</div>
<script type="text/javascript">
$(function(){					
	setCommunityInfo();
});

function setCommunityInfo(){
	var str = "";
	$.ajax({
		url:"/groupware/layout/selectTFDetailInfo.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID
		},
		success:function (data) {
			if(data.status == "SUCCESS"){
				if(data.TFInfo != undefined && data.TFInfo.length > 0) {
					var info = data.TFInfo[0];
					
					$("#cState").html(info.AppStatusName);
					$("#cTFName").html(info.CommunityName);
					$("#cCategory").html(info.TF_DomainName);						
					$("#cMajorDept").html(info.TF_MajorDept);

					$("#cStartDate").html(info.TF_StartDate);
					$("#cEndDate").html(info.TF_EndDate);
											
					$("#cPM").html(getTFUserName(info.TF_PM));
					$("#cAdmin").html(getTFUserName(info.TF_Admin));
					$("#cMember").html(getTFUserName(info.TF_Member));
					$("#cViewer").html(getTFUserName(info.TF_Viewer));	

					$("#cSearchTitle").html(unescape(info.Description).replace(/(\r\n|\n|\r)/g,"<br />"));
					
					//TODO: 연결문서
					$("#hidDocLinks").val(info.TF_DocLinks);
					G_displaySpnDocLinkInfo4Detail();

					if(data.fileList != undefined && data.fileList.length > 0) {
						var fileList = data.fileList;
						
						$("#divFileList").html("");
						
						var attFileAnchor = $('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');"/>').addClass('btnAttFile btnAttFileListBox').text('(' + fileList.length + ')');
						var attFileListCont = $('<ul>').addClass('file_list');
						var attFileDownAll = $('<li style="width:100%;">').append($('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');" >'));//.addClass("btnXClose btnAttFileListBoxClose")//.append("<a href='#' onclick='javascript:downloadAll(fileList)'><spring:message code='Cache.lbl_download_all'/></a>")
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
							
							var attFileList = $('<li></li>');
							$(attFileList).append($($('<a href="#" onclick="javascript:Common.fileDownLoad(\'' + item.FileID+  '\',\'' + item.FileName + '\',\''  + item.FileToken + '\');"/>').addClass('btn_File '+iconClass).text(item.FileName)).append($('<span title="'+item.FileName+'">').addClass('tx_size').text('(' + coviFile.convertFileSize(item.Size) + ')')));
							$(attFileListCont).append(attFileList);
						});
						
						$("#divFileList").append(attFileListCont);//attFileAnchor ,
						$("#divFileList").show();
						$(".attFileListCont").toggleClass("active");
						l_fileList = data.fileList;
						if(l_fileList.length > 1) $("#aBtnAllDown").show();
					} else {
						$("#divFileList").html("<ul class=\"appdoc_list\"><li>"+"<spring:message code='Cache.msg_NoDataList' />"+"</li></ul>");
					}
				} 
			}		
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/selectTFDetailInfo.do", response, status, error); 
		}
	}); 
}

function setCurrentLocation(categoryID){
	var locationText= "";
	$.ajax({
		type:"POST",
		data:{
			"CategoryID" : categoryID
		},
		async : false,
		url:"/groupware/layout/userCommunity/setCurrentLocation.do",
		success:function (data) {
			
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					
					if(v.num == '1'){
						locationText += v.DisplayName;
					}else{
						if(data.list.length == 1){
							locationText += v.DisplayName;
						}else{
							locationText += v.DisplayName+" > ";
						}
					}
    			});
			}
			$("#cCategoryNm").html(locationText);
			
		},
		error:function (error){
			  CFN_ErrorAjax("/groupware/layout/community/setCurrentLocation.do", response, status, error);
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
function G_displaySpnDocLinkInfo4Detail() {//수정본
	   var szdoclinksinfo = "";
	   var szdoclinks =  $("#hidDocLinks").val();
	   szdoclinks = szdoclinks.replace("undefined^", "");
	   szdoclinks = szdoclinks.replace("undefined", "");
	   var bEdit = false; 
	   var bDisplayOnly = false;
	   if (szdoclinks != "") {
	       var adoclinks = szdoclinks.split("^^^");
	       if(adoclinks.length > 0){
	    	   szdoclinksinfo ="<ul class=\"appdoc_list\">";
		       for (var i = 0; i < adoclinks.length; i++) {
		           var adoc = adoclinks[i].split("@@@");
		           var FormUrl = document.location.protocol + "//" + document.location.host + "/approval/approval_Form.do";
		           var iWidth = 790;
		           var iHeight = window.screen.height - 82;
	               szdoclinksinfo += "<li><a href='#' class='btn_File ico_doc' onclick=\"CFN_OpenWindow('";
	               szdoclinksinfo += FormUrl + "?mode=COMPLETE" + "&processID=" + adoc[0] + "&forminstanceID=" + (typeof adoc[3] != "undefined" ? adoc[3] : "&archived=true") + "&bstored=" + (typeof adoc[4] != "undefined" ? adoc[4] : "false");
	               szdoclinksinfo += "',''," + iWidth + ", " + iHeight + ", 'scroll') \"><span>" + adoc[2] + "</a></li>";
		       }
		       szdoclinksinfo +="</ul>";
	       }else{
	    	   szdoclinksinfo ="<ul class=\"appdoc_list\"><li>"+"<spring:message code='Cache.msg_NoDataList' />"+"</li></ul>";
		   }
	   }else{
		   szdoclinksinfo ="<ul class=\"appdoc_list\"><li>"+"<spring:message code='Cache.msg_NoDataList' />"+"</li></ul>";
	   }
	   $("#docLinksList").html(szdoclinksinfo);
	}
</script>