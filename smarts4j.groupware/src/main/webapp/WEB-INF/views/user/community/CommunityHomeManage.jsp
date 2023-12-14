<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style type="text/css">
	#webpartSettingDiv {margin-top:20px;}
	#mainBoardDiv .con_table td input[type="text"], #mainBoardDiv .con_table td select {height:20px !important; margin:5px 0 !important;}
	span#portalInfo {margin-left:5px;}
	.btn_left, .btn_right {top:35%;}
	.layoutsetting_ul {margin:20px 45px !important;}
	.layoutsetting_ul .ui-widget {box-sizing:content-box;}
	.layoutsetting_list li {margin-top:5px;}
	.btn_paging {display:none;}
	.layout_in_webpart {padding:12px; height:40px; line-height:30px; border:1px solid #d5d5d5; border-radius:3px;}
	.searchBox {background:#fff !important;}
	.searchBox::placeholder {color:#fff;}
	.txt_gn11_blur3 {display:inline-block; margin-top:5px; font-size:11px;}
	.webpartListTitle {background-color:#60759a; border-radius:0;}
	#mainBoardDiv .con_table td input[type="text"].WebpartOrder {margin:2px 5px 0 0 !important; height:10px !important;}
	/*.webpart_title {margin-top:5px;}*/
	.layout_in_webpart .webpart_title {margin-top:0px;}
	.docIcn {margin:-32px -6px 0 0 !important;} 
	
	.webpart_title {width:70%!important; height:16px!important; line-height:12px!important; text-overflow:ellipsis; white-space:nowrap;}
	.layout_in_webpart .inputDel {margin-left:0px!important;}
	
	#webpartSettingDiv {margin-top:20px;}
	#mainBoardDiv .con_table td input[type="text"], #mainBoardDiv .con_table td select {height:20px !important; margin:5px 0 !important;}
	span#portalInfo {margin-left:5px;}
	.btn_left, .btn_right {top:35%;}
	.layoutsetting_ul {margin:20px 45px !important;}
	.layoutsetting_ul .ui-widget {box-sizing:content-box;}
	.layoutsetting_list li {margin-top:5px;}
	.btn_paging {display:none;}
	.layout_in_webpart {padding:12px; height:40px; line-height:30px; border:1px solid #d5d5d5; border-radius:3px;}
	.searchBox {background:#fff !important;}
	.searchBox::placeholder {color:#fff;}
	.txt_gn11_blur3 {display:inline-block; margin-top:5px; font-size:11px;}
	.webpartListTitle {background-color:#60759a; border-radius:0;}
	#mainBoardDiv .con_table td input[type="text"].WebpartOrder {margin:2px 5px 0 0 !important; height:10px !important;}
	/*.webpart_title {margin-top:5px;}*/
	.layout_in_webpart .webpart_title {margin-top:0px;}
	.docIcn {margin:-32px -6px 0 0 !important;}
	
	
	.webpartList .wpTitle .txt_gn11_blur3 {width: 80%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;}
	
</style>


<input type="hidden" id="doorID" value=''/>
<input type="hidden" id="fileID" value=''/>
<div class="individualContentLayout individualRigntCont">
	<div class="cRConTop">
		<h2 class="title"><spring:message code='Cache.lbl_Home_Settings'/></h2>						
	</div>
	<div class="mt20 tabMenuCont">
		<ul class="tabMenu clearFloat tabMenuType02">
			<li class="active"><a href="#"><spring:message code='Cache.lbl_layout2'/></a></li>
			<li class=""><a href="#"><spring:message code='Cache.lbl_CUImages'/></a></li>
			<li class=""><a href="#"><spring:message code='Cache.lbl_CommunityMainPage'/></a></li>
		</ul>
	</div>
	<div class="mt25 tabContentContanier">
		<div class="tabContent active"><!-- 레이아웃-->	
			<div class="layouThemeOptionCont">
				<h3 class="cycleTitle"><spring:message code='Cache.lbl_apv_thema'/></h3>
				<ul class="layouThemeOptionList mt20">
					<li class="layouThemeOptionList_blue">
						<a onclick="layoutHeaderSetting('blue')" name="layouTheme" id="layouThemeblue">
							<span></span>
						</a>
					</li>
					<li class="layouThemeOptionList_orange">
						<a onclick="layoutHeaderSetting('orange')" name="layouTheme" id="layouThemeorange">
							<span></span>
						</a>
					</li>
					<li class="layouThemeOptionList_yellow">
						<a onclick="layoutHeaderSetting('yellow')" name="layouTheme" id="layouThemeyellow">
							<span></span>
						</a>
					</li>
					<li class="layouThemeOptionList_green">
						<a onclick="layoutHeaderSetting('green')" name="layouTheme" id="layouThemegreen">
							<span></span>
						</a>
					</li>
					<li class="layouThemeOptionList_red">
						<a onclick="layoutHeaderSetting('red')" name="layouTheme" id="layouThemered">
							<span></span>
						</a>
					</li>
				</ul>
			</div>
			<div class="mt20" id="webPotalLoad">
				
			</div>
		</div>
		<div class="tabContent">
			<div class="commImgRadioBox">
				<div class="radioStyle04 inpBtnStyle">
					<input type="radio" id="rd01" name="rdAll" checked="checked"><label for="rd01"><span><span></span></span><spring:message code='Cache.lbl_ImageDirectRegistration'/></label>
				</div>
				<div class="radioStyle04 inpBtnStyle">
					<input type="radio" id="rd02" name="rdAll"><label for="rd02"><span><span></span></span>과거이미지</label>
				</div>
			</div>
			<div class="commImgUploadCont mt20" id="con_file" name="rdi01">
				<h3 class="cycleTitle"><spring:message code='Cache.lbl_ImageDirectRegistration'/></h3>
				<div class="commImgUploadSelectBox">
					<select class="selectType02" id="cphTopContent_ddlSelectImage">
						<option value="S"><spring:message code='Cache.msg_RepresentativeImg'/></option>
						<option value="T"><spring:message code='Cache.lbl_topTitle'/></option>
						<option value="B"><spring:message code='Cache.ThemeType_BgImage'/></option>
					</select>
				</div>
				<p class="mt15" id="CImgHelp"><spring:message code='Cache.msg_CuImage150_100'/></p>
				<p class="mt15">
					<button type="button" class="btnTypeDefault" name="addBtn" onclick="mainConFile()" style="cursor:pointer;" id="mainConfile">
						<i class="fa fa-plus" aria-hidden="true"></i> <spring:message code='Cache.lbl_RegistImage'/>
					</button>
				</p>
				<div class="commImgUploadView mt25" id="con_file_view" style="display:none">
					<p><spring:message code='Cache.lbl_ImgPreview'/></p>
				</div>
			</div>	
			<div class="mt30 commImgBtnBox" name="rdi01">
				<a class="btnTypeDefault btnTypeChk" onclick="goImgAdd();"><spring:message code='Cache.btn_RegistrationComplete'/></a>
			</div>
			<div class="commImgUploadCont mt20" name="rdi02" style="display: none;">
				<h3 class="cycleTitle"><spring:message code='Cache.lbl_PastImg'/></h3>
				<div class="commImgUploadSelectBox">
					<select class="selectType02" id="cphTopContent_ddlBeforeSelectImage">
						<option value="S"><spring:message code='Cache.msg_RepresentativeImg'/></option>
						<option value="T"><spring:message code='Cache.lbl_topTitle'/></option>
						<option value="B"><spring:message code='Cache.ThemeType_BgImage'/></option>
					</select>
				</div>
				<p class="mt15"><spring:message code='Cache.msg_SelectORDeleteImage'/></p>
				<div class="commImgUploadView mt25" id="communityImg" style="overflow: auto;">
						
				</div>
			</div>	
			<div class="mt30 commImgBtnBox" name="rdi02"  style="display: none;">
				<a class="btnTypeDefault btnTypeChk" onclick="goCommunityImgChoice();"><spring:message code='Cache.lbl_Choice'/></a>
			</div>	
										
		</div><!-- 이미지-->
		<div class="tabContent"><!-- 대문-->	
			<div class="commImgUploadCont">
				<h3 class="cycleTitle"><spring:message code='Cache.lbl_DirectRegi'/></h3>
				<p class="mt15"><spring:message code='Cache.msg_RegDirectDoorCU'/></p>
				
				<div class="mt20" id="editorDoor" style="width: 100%;"><spring:message code='Cache.lbl_EditArea'/></div>
				
				<div class="mt25 commImgBtnBox">
					<a class="btnTypeDefault btnTypeChk" onclick="goDoorAdd();"><spring:message code='Cache.lbl_SchAddItem'/></a>
					<a class="btnTypeDefault ml5" onclick="goDoorEdit();"><spring:message code='Cache.btn_Edit'/></a>
				</div>
			</div>
			<div class="commImgUploadCont mt20">
				<h3 class="cycleTitle"><spring:message code='Cache.lbl_ChangeGate'/></h3>
				<p class="mt15"><spring:message code='Cache.msg_SelectORDeleteDoor'/></p>
				<div class="mt10" id="deforeDoor">
				</div>
				<div class="mt65 commImgBtnBox">
					<a href="#" class="btnTypeDefault btnTypeChk" onclick="goDoorChoice();"><spring:message code='Cache.lbl_Choice'/></a>
					<a href="#" class="btnTypeDefault ml5" onclick="goDoorDel();"><spring:message code='Cache.btn_delete'/></a>
				</div>
			</div>
		</div>
	</div>
</div>
<div id="con_file"></div>

<script type="text/javascript">

var elemID = "";
var path = "";
var thumbSrc = "";
var size = "";
var savedName = "";
var fileName = "";
var frontAddPath = "";

var g_editorKind = Common.getBaseConfig('EditorType');

$(function(){					
	setEvent();
	serActive();
	setDoor();
	selCommunityImage();
	setWebPortalLoad();
});	

function setEvent(){
	$('.tabMenu>li').on('click', function(){
		
		$('.tabMenu>li').removeClass('active');
		$('.tabContent').removeClass('active');
		$(this).addClass('active');
		$('.tabContent').eq($(this).index()).addClass('active');
		
		if($(this).index() == "2"){
			$("iframe[id^='editDoorFrame']").contents().find("#resizeContainer").hide();
			
			if($("#editDoorFrame").length < 1){
			 	coviEditor.loadEditor(
			 			'editorDoor',
			 			{
			 				editorType : g_editorKind,
			 				containerID : 'editDoor',
			 				frameHeight : '520',
			 				focusObjID : ''
			 			}
			 	); 
			}
		}
		
		
	});	
		  
	$("#cphTopContent_ddlSelectImage").on("change",function(){
		if($("#cphTopContent_ddlSelectImage").val() == "S"){
			$("#CImgHelp").html("<spring:message code='Cache.msg_CuImage150_100'/>");
		}else if($("#cphTopContent_ddlSelectImage").val() == "T"){
			$("#CImgHelp").html("<spring:message code='Cache.msg_CuImage1020_272'/>");
		}else if($("#cphTopContent_ddlSelectImage").val() == "B"){
			$("#CImgHelp").html("<spring:message code='Cache.msg_CuImageAdd'/>");
		}
	});
	 
	$("#cphTopContent_ddlBeforeSelectImage").on('change',function(){
		 selCommunityImage();
	});
	 
	$("input[name='rdAll']").on("click",function(){
		if($(this).attr("id") == "rd01"){
			$("div[name='rdi01']").show();
			$("div[name='rdi02']").hide();
		}else{
			selCommunityImage();
			$("div[name='rdi01']").hide();
			$("div[name='rdi02']").show();
		}
	});
	 
}

function mainConFile(){
	elemID = random() + '_' + "file" + '_' + "IMG";
	
	var url = "/covicore/control/callFileUpload.do?"
	url += "lang=ko&";
	url += "listStyle=div&";
	url += "callback=callImgUploadCallBack&";
	url += "actionButton="+encodeURIComponent("add,upload")+"&";
	url += "multiple=false&";
	url += "servicePath=" + coviComment.commentVariables.servicePath + "&";
	url += "elemID=" + elemID+"&";
	url += "image=" + "true";

	Common.open("", elemID+"_CoviCommentImgUp", "<spring:message code='Cache.lbl_File'/>", url, "500px", "250px", "iframe", true, null, null, true);
}

//이미지 callback
function callImgUploadCallBack(data, elemID) {
	
		$.each(data, function (i, v) {
			var fileNames = v.SavedName;
			var frontAddPaths = v.FrontAddPath + "/";
			var src = coviCmn.commonVariables.frontPath + Common.getSession("DN_Code");
			
			thumbSrc = src + frontAddPaths + fileNames.split('.')[0] + '_thumb.jpg';
			var srcUrl = AwsS3.getS3ApUrl()+src+fileNames;
			$('#con_file_view').show();
			$("#con_file_view").html("<img style='width:100%;height:100%'/>");
			
			$("#con_file_view").find('img').attr('src', thumbSrc).attr('orgSrc', srcUrl);

			path = src;
			size = v.Size;
			savedName = v.SavedName;
			fileName = v.FileName;
			frontAddPath = v.FrontAddPath
		});
		
		Common.close(elemID+"_CoviCommentImgUp");
	
}

function serActive(){
	$.ajax({
		url:"/groupware/layout/userCommunity/communityHeaderSetting.do",
		type:"POST",
		async:false,
		data:{
			communityID : cID
		},
		success:function (data) {
			
			if(data.list.length > 0){
				$(data.list).each(function(i,v){
					$("a[name^='layouTheme']").removeClass('active');
					if(v.CommunityTheme != '' && v.CommunityTheme != null){
						$("#layouTheme"+v.CommunityTheme).addClass("active");
					}else{
						$("#layouThemeblue").addClass("active");
					}
				});
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communityHeaderSetting.do", response, status, error); 
		}
	}); 
	
}

function setDoor(){
	var str = "";
	var IsCurrent = "";
	$.ajax({
		url:"/groupware/layout/userCommunity/communityDoorList.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID
		},
		success:function (e) {
			
			if(e.list.length > 0){
				$(e.list).each(function(i,v){
					str += "<input type='radio' name='doorRadio' value='"+v.DoorID+"' onclick='doorChoice("+v.DoorID+")'> "+v.RegistDate+"</br>";
					if(v.IsCurrent == "Y"){
						IsCurrent = v.DoorID;
					}
				});
			}
			
			$("#deforeDoor").html(str);
			
			$("input[value='"+IsCurrent+"']").attr('checked', true);
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communityDoorList.do", response, status, error); 
		}
	}); 
}


function setHomeHeader(color){
	$("a[name^='layouTheme']").removeClass('active');
	
	$("#cheader").attr("href", communityCssPath+"/covicore/resources/css/theme/community/"+color+".css?v="+random());
	
	$("#layouTheme"+color).addClass("active");
}

function random(){
	var result = Math.floor(coviCmn.random() * 1000) + 1;

	return result;
}

function layoutHeaderSetting(color){
	$.ajax({
		url:"/groupware/layout/userCommunity/communityLayoutHeaderSet.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID,
			color : color
		},
		success:function (data) {
			if(data.status == "SUCCESS"){
				setHomeHeader(color)
			}else{ 
				Common.Error("<spring:message code='Cache.msg_FailProcess' />"); //처리에 실패했습니다
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communityLayoutHeaderSet.do", response, status, error); 
		}
	}); 
}

function goDoorAdd(){
	var txtDoorEditer = coviEditor.getBody(g_editorKind, 'editDoor');
	var txtDoorInlineImage = coviEditor.getImages(g_editorKind, 'editDoor');
	
	Common.Confirm("<spring:message code='Cache.msg_CuDoorConfirm'/>", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/communityLayoutDoorSet.do",
				type:"POST",
				async:false,
				data:{
					CU_ID : cID,
					BodyText : txtDoorEditer,
					BodyInlineImage : txtDoorInlineImage,
					Type : 'C'
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_SuccessRegist' />"); //정상적으로 등록되었습니다.
						goDoorReset();
					}else{ 
						Common.Error("<spring:message code='Cache.msg_FailProcess' />"); //처리에 실패했습니다
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/communityLayoutDoorSet.do", response, status, error); 
				}
			});	
		}
	});
	
}

function goDoorEdit(){
	var txtDoorEditer = coviEditor.getBody(g_editorKind, 'editDoor');
	var txtDoorInlineImage = coviEditor.getImages(g_editorKind, 'editDoor');
	
	if($("#doorID").val() == "" || $("#doorID").val() == null){
		Common.Inform("<spring:message code='Cache.msg_EditDoorCheck' />"); //수정할 대문을 선택하세요.
		return ;
	}
	
	Common.Confirm("<spring:message code='Cache.msg_CuEditDoorConfirm' />", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/communityLayoutDoorSet.do",
				type:"POST",
				async:false,
				data:{
					CU_ID : cID,
					BodyText : txtDoorEditer,
					BodyInlineImage : txtDoorInlineImage,
					Type : 'U',
					doorID :  $("#doorID").val()
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_Edited' />"); //수정되었습니다
						goDoorReset();
					}else{ 
						Common.Error("<spring:message code='Cache.msg_FailProcess' />"); //처리에 실패했습니다
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/communityLayoutDoorSet.do", response, status, error); 
				}
			});	
		}
	});
}

function goDoorChoice(){
	
	var value = $('input:radio[name="doorRadio"]:checked').val();

	Common.Confirm("<spring:message code='Cache.msg_CuChangeDoorConfirm' />", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/communityLayoutDoorChange.do",
				type:"POST",
				async:false,
				data:{
					CU_ID : cID,
					doorID : value
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_Changed' />"); //변경되었습니다
						goDoorReset();
					}else{ 
						Common.Error("<spring:message code='Cache.msg_FailProcess' />"); //처리에 실패했습니다
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/communityLayoutDoorChange.do", response, status, error); 
				}
			});	
		}
	});
}

function goDoorDel(){
	var value = $('input:radio[name="doorRadio"]:checked').val();

	Common.Confirm("<spring:message code='Cache.msg_CuDelDoorConfirm' />", "Confirmation Dialog", function (confirmResult) {
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/communityLayoutDoorSet.do",
				type:"POST",
				async:false,
				data:{
					CU_ID : cID,
					doorID : value,
					Type : 'D'
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_50' />"); //삭제되었습니다.
						goDoorReset();
					}else{ 
						Common.Error("<spring:message code='Cache.msg_FailProcess' />"); //처리에 실패했습니다
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/communityLayoutDoorSet.do", response, status, error); 
				}
			});	
		}
	});
}

function goDoorReset(){
	coviEditor.setBody(g_editorKind, 'editDoor', '');
	setDoor();
}

function doorChoice(doorID){
	$("#doorID").val(doorID);
	selDoorText(doorID);
}

function selDoorText(doorID){
	$.ajax({
		url:"/groupware/layout/userCommunity/communitySelectDoorText.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID,
			doorID : doorID
		},
		success:function (data) {
			 coviEditor.setBody(g_editorKind, 'editDoor', data.DoorText);
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communitySelectDoorText.do", response, status, error); 
		}
	}); 
}

function goImgAdd(){
	Common.Confirm("<spring:message code='Cache.msg_CuAddImgConfirm'/>", "Confirmation Dialog", function (confirmResult) {
		
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/communityImgSet.do",
				type:"POST",
				async:false,
				data:{
					CU_ID : cID,
					FileType : $("#cphTopContent_ddlSelectImage").val(),
					Context : path,
					FileName : fileName,
					Extention : 'jpg',
					Size : size,
					SavedName : savedName,
					FrontAddPath : frontAddPath
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_DeonRegist'/>"); //등록 되었습니다.
						goImgReset();
						
						if($("#cphTopContent_ddlSelectImage").val() == "T"){
							setHeader();
						}else if($("#cphTopContent_ddlSelectImage").val() == "B"){
							setHeader();
						}
						
					}else if(data.status == "MAX"){
						Common.Warning("<spring:message code='Cache.msg_ExcessVolume' />"); //커뮤니티에서 사용할 수 있는 용량을 초과하였습니다. 
					}else{ 
						Common.Error("<spring:message code='Cache.msg_FailProcess' />"); //처리에 실패했습니다
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/communityImgSet.do", response, status, error); 
				}
			});	
		}
	});
}

function goImgReset(){
	$("#con_file_view").html("<p>"+"<spring:message code='Cache.lbl_ImgPreview'/>"+"</p>");
	
	path = "";
	fileName = "";
	size = "";
	savedName = "";
	$('#con_file_view').hide();//이미지 미리보기 영역 
	
}

function selCommunityImage(){
	var str = "";
	var IsCurrent = "";
	
	$.ajax({
		url:"/groupware/layout/userCommunity/communitySelectImage.do",
		type:"POST",
		async:false,
		data:{
			CU_ID : cID,
			FileType : $("#cphTopContent_ddlBeforeSelectImage").val()
		},
		success:function (bi) {
			if(bi.list.length > 0){
				//var backStorage = Common.getBaseConfig("BackStorage");
				var imgPath = "";
				
				$(bi.list).each(function(i,v){
					//imgPath = coviCmn.loadImage(backStorage.replace("{0}", v.CompanyCode) + v.FilePath);
					imgPath = coviCmn.loadImage(v.FullPath);
					str += "<div style='display: inline-block;margin-top:10px;'>";
					str += "<div class='photoImg delete frontPhoto' style='margin-right: 0px;'>";
					str += "<img src='"+imgPath+"' onerror='coviCmn.imgError(this);' alt='' style='width: 120px; height: 104px;'>";
					str += "<a class='btnPhotoRemove' onclick='removeImg("+v.FileID+")'>"+"<spring:message code='Cache.btn_DelPicture'/>"+"</a>";
					str += "</div>";
					str += "<div class='mt10' id='cimg' style='margin-right: 10px;'>";
					str += "<input type='radio' name='cimgRadio' value='c_"+v.FileID+"' onclick='cimgChoice("+v.FileID+")'> "+v.RegistDate+"</div>"
					str += "</div>";
					if(v.IsCurrent == "Y"){
						IsCurrent = v.FileID;
					}
					
				});
			}
			
		 	$("#communityImg").html(str);
		 	$("#fileID").val(IsCurrent);
		 	$("input[value='c_"+IsCurrent+"']").attr('checked', true);  
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userCommunity/communitySelectImage.do", response, status, error); 
		}
	}); 
}

function cimgChoice(fileID){
	$("#fileID").val(fileID);
}

function removeImg(fileID){
	Common.Confirm("<spring:message code='Cache.msg_CuDelImgConfirm'/>", "Confirmation Dialog", function (confirmResult) {
		
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/communityImgDel.do",
				type:"POST",
				async:false,
				data:{
					CU_ID : cID,
					FileID : fileID
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_50'/>"); //삭제되었습니다.
						selCommunityImage();
						
						if($("#cphTopContent_ddlSelectImage").val() == "T"){
							setHeader();
						}else if($("#cphTopContent_ddlSelectImage").val() == "B"){
							setHeader();
						}
						
					}else{ 
						Common.Error("<spring:message code='Cache.msg_FailProcess' />"); //처리에 실패했습니다
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/communityImgDel.do", response, status, error); 
				}
			});	
		}
	});
}

function goCommunityImgChoice(){
	Common.Confirm("<spring:message code='Cache.msg_CuSelImgConfirm' />", "Confirmation Dialog", function (confirmResult) {
		
		if (confirmResult) {
			$.ajax({
				url:"/groupware/layout/userCommunity/communityImgChoice.do",
				type:"POST",
				async:false,
				data:{
					CU_ID : cID,
					FileID : $("#fileID").val(),
					FileType : $("#cphTopContent_ddlBeforeSelectImage").val()
				},
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_37' />"); //저장되었습니다.
						selCommunityImage();
						
						if($("#cphTopContent_ddlSelectImage").val() == "T"){
							setHeader();
						}else if($("#cphTopContent_ddlSelectImage").val() == "B"){
							setHeader();
						}
						
					}else{ 
						Common.Error("<spring:message code='Cache.msg_FailProcess' />"); //처리에 실패했습니다
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/userCommunity/communityImgChoice.do", response, status, error); 
				}
			});	
		}
	});	
}

function setWebPortalLoad(){

	
	var contentUrl = "/groupware/portal/goWebpartSetting.do?communityId="+cID+"&portalID="+portalID;
	
	//content
	$.ajax({
	       type : "GET",
	       beforeSend : function(req) {
	           req.setRequestHeader("Accept", "text/html;type=ajax");
	       },
	       url : contentUrl,
	       success : function(res) {
	       	$("#webPotalLoad").html(res);
	       },
	       error : function(response, status, error){
			CFN_ErrorAjax(contentUrl, response, status, error);
	       }
	});	
	
}

</script>