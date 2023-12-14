<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
%>
<!-- 컨텐츠앱 추가 -->
	<link rel="stylesheet" type="text/css" href="<%=cssPath%>/contentsApp/resources/css/contentsApp.css">
<body>

<div class="layer_divpop contentsAppPop" style="width:382px; left:0; top:0; z-index:104;">
    <div class="divpop_contents">
      <div class="caContent">
        <h3 class="cycleTitle"><spring:message code='Cache.lbl_builtInIcon'/></h3>
        <div class="listBox_app">
          <span class="icon app01"></span>
          <span class="icon app02"></span>
          <span class="icon app03"></span>
          <span class="icon app04"></span>
          <span class="icon app05"></span>
          <span class="icon app06"></span>
          <span class="icon app07"></span>
          <span class="icon app08"></span>
          <span class="icon app09"></span>
          <span class="icon app10"></span>
          <span class="icon app11"></span>
          <span class="icon app12"></span>
          <span class="icon app13"></span>
          <span class="icon app14"></span>
          <span class="icon app15"></span>
          <span class="icon app16"></span>
          <span class="icon app17"></span>
          <span class="icon app18"></span>
          <span class="icon app19"></span>
          <span class="icon app20"></span>
          <span class="icon app21"></span>
          <span class="icon app22"></span>
          <span class="icon app23"></span>
          <span class="icon app24"></span>
          <span class="icon app25"></span>
          <span class="icon app26"></span>
          <span class="icon app27"></span>
          <span class="icon app28"></span>
          <span class="icon custom"><spring:message code='Cache.lbl_directly'/><br><spring:message code='Cache.lbl_Regist'/></span>
        </div>
        
        <h3 class="cycleTitle" style="display:none;"><spring:message code='Cache.lbl_directlyRegist'/></h3>
        <div class="appicon_custom" style="display:none;">
          <input type="text" id="iconFileText" value="" disabled="">
          <a class="btnTypeDefault" href="#" id="btnFile"><spring:message code='Cache.btn_findFiles'/></a>
          <p class="explain"><span class="thstar">* </span><span><spring:message code='Cache.lbl_fileSizeNotify'/></span></p>
        </div>
        <div class="bottomBtnWrap">
          <a href="#" class="btnTypeDefault btnTypeBg" id="btnSave" style="display:none;"><spring:message code='Cache.btn_save'/></a>
          <a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.btn_Cancel'/></a>
        </div>

      </div>
    </div>
  </div>

</body>
</html>

<script type="text/javascript">
var targetObj = $("#btnSetting", parent.document).parent();

var iconChange = {
	objectInit : function(){			
		this.addEvent();
	}	,
	addEvent : function(){
		
		$(".listBox_app span").off("mouseover").on("mouseover", function(){
			$(this).css("background-color", "#F7F7F7");
		});
		$(".listBox_app span").off("mouseout").on("mouseout", function(){
			$(this).css("background-color", "#FFFFFF");
		});
		
		// 아이콘선택
		$(".listBox_app span").off("click").on("click", function(){
			var val = $(this).attr("class");
			
			if(val.split(' ')[1] == "custom"){
				$(".appicon_custom").prev().slideToggle();
				$(".appicon_custom").slideToggle();
				$("#btnSave").slideToggle();
				return;
			}
			
			targetObj.attr("style", "");
			targetObj.attr("class", val);
			
			Common.Close();
		});
		
		//파일찾기
		$('#btnFile').off("click").on("click", function(){
			$('#iconFile', parent.document).click();
		});
		
		//이미지 파일을 선택(값이 변경) 되었을때 처리하는 코드
		$("#iconFile", parent.document).off("change").on("change", function(){
			if(!thumbnailUpload(this.value)) return;
			
		    if (this.files && this.files[0]) {
				 $('#iconFileText').val(this.files[0].name);
			}
		});
		
		$("#btnSave").on('click', function(){
			var BackStorage = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
			
			if(!fileuploadBeforeCheck()) return;
			
			readURL($("#iconFile", parent.document)[0]);
			
			Common.Close();
		});
		
		$("#btnClose").on('click', function(){
			Common.Close();
		});
	}	
}

function readURL(input) {
	var BackStorage = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
	
	 if (input.files && input.files[0]) {
		 var reader = new FileReader(); //파일을 읽기 위한 FileReader객체 생성
		 reader.onload = function (e) {
			 targetObj.attr("class", "icon custom");
			 targetObj.attr("style", "background: url('"+e.target.result+"') no-repeat center;");
	     }                   
	     reader.readAsDataURL(input.files[0]);
	     //File내용을 읽어 dataURL형식의 문자열로 저장
	 }
}

//파일선택시 이미지 체크
function thumbnailUpload(obj) {
    // 선택파일의 경로를 분리하여 확장자를 구합니다.
    if(obj!=''){
       pathPoint = obj.lastIndexOf('.');
       filePoint = obj.substring(pathPoint + 1, obj.length);
       fileType = filePoint.toLowerCase();
       // 확장자가 이미지 파일이면 preview에 보여줍니다.
       if (fileType == 'jpg' || fileType == 'gif' || fileType == 'png' || fileType == 'jpeg' || fileType == 'bmp') {
       	return true;
       }
       else {
           Common.Warning("<spring:message code='Cache.msg_OnlyImageFileAttach'/>");/*이미지 파일만 업로드 하실수 있습니다.  */
           return false;
       }
    }else{
       return false;
    }
}

//업로드전 파일 체크
function fileuploadBeforeCheck() {
    var file = parent.document.getElementById("iconFile");
    
    if(file.files.length<=0){
    	return true;
	}else if (file.files.item(0).name.length > 20) {
        Common.Warning("<spring:message code='Cache.lbl_apv_warning_filename'/>");
        parent.document.getElementById('iconFile').value = "";
        return false;
    }else if (file.files.item(0).size > 512000) {
    	Common.Warning("<spring:message code='Cache.lbl_apv_warning_filesize'/>");
        return false;
    }else {
        return true;
    }
}

$(document).ready(function(){
	iconChange.objectInit();
});

</script>