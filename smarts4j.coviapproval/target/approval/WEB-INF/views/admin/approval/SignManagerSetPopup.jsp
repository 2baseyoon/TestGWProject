<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = (function(){
		var MODE =  "${param.mode}";
		var PERSON_CODE  = "${param.key}";
		var DOMAIN =  "${param.domain}";
		
		return {
			mode : function() {
				return MODE
			},
			personCode : function(){
				return PERSON_CODE
			},
			domain : function(){
				return DOMAIN
			}			
		} 
	})();
	
	var filename;
	var SIGN_MODULE = "ApprovalSign";
	var signFileID;
	
	//var SignImagePath = Common.getBaseConfig("BackStorage").replace("{0}", param.domain()) + Common.getBaseConfig("SignImagePath");
	var noImgPath = Common.getBaseConfig("BackStorage").replace("{0}", param.domain());
	
	$(document).ready(function(){				
		$("#SignImg").attr("src", coviCmn.loadImage(noImgPath + "no_image.jpg"));
		$("#ChangeImg").attr("src", coviCmn.loadImage(noImgPath + "no_image.jpg"));
		modifySetData();
		
		//$("#SignImg").attr("src", coviCmn.loadImage(noImgPath + "/sign_no_img.gif"));
		//$("#ChangeImg").attr("src", coviCmn.loadImage(noImgPath + "/sign_no_img.gif"));
	});
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	//수정화면 data셋팅
	function modifySetData(){
		//data 조회
		$.ajax({
			type:"POST",
			data:{
				"UserCode" : param.personCode(),	//사용자 코드
				"IsUse" : "Y"					//사용유무				
			},
			url:"getSignData.do",
			success:function (data) {
				if(data.result && Object.keys(data.result).length !== 0){       
					$("#NowImg").css("display","inline-block");   //등록된서명
					$("#ChangeImgSpan").hide();  //새로운서명
					$("#btn_delete").show();
					
					//var strBackStoragePath = Common.getBaseConfig("BackStorage").replace("{0}", param.domain());
					var src = data.result.FilePath;
					filename = data.result.FileName;
					var fileID = data.result.FileID;
					
					//if(src.indexOf(strBackStoragePath) == -1){
						//src = strBackStoragePath + src;
					//}
					
					if (fileID && !isNaN(fileID)){
						src = coviCmn.loadImageId(fileID, SIGN_MODULE);
						signFileID = function(){
							var fileID = data.result.FileID;
							return function(){
								return fileID;
							}
						}();
					} 
					//else {
						//src = coviCmn.loadImage(src);
					//}
					
					$("#SignImg").attr("src", src);
					
					
				}
				else{ 
					$("#NowImg").hide();	
					$("#ChangeImgSpan").css("display","inline-block");	
					$("#btn_delete").hide();
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getSignData.do", response, status, error);
			}
		});
	}
	
	
	
	//저장
	function saveSubmit(){
		var FileName = $("#fileurl").val(); 		
		
        if (axf.isEmpty(FileName)) {
            Common.Warning("<spring:message code='Cache.msg_FileSelect' />");   //파일을 선택해 주세요.
            return false;
    	}
		
        if(!fileuploadBeforeCheck()){
        	return false; 
        }
        
        Common.Confirm("<spring:message code='Cache.msg_apv_155' />", "Confirmation Dialog", function(result){
			if(result){
				//파일업로드시스템 후 추가 개발
				var formData = new FormData();
				formData.append('MyFile', $('#MyFile')[0].files[0]);		
				formData.append('UserCode', param.personCode());
				
				//insert 호출		
				 $.ajax({
					 type : 'post',
					 url : 'insertSignData.do',
					 data : formData,
					 dataType : 'json',
					 processData : false,
					 contentType : false,
					 success : function(data){
						 if(data.status==="SUCCESS"){
			            	Common.Inform("<spring:message code='Cache.msg_insert'/>","<spring:message code='Cache.msg_apv_137'/>",function(){
								parent.searchConfig();
								closeLayer();
							});
		            	}
		            	else {
		            		Common.Warning(data.message);
		            	}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("insertSignData.do", response, status, error);
					}
				});
			}
		});
	}
	
	
	//삭제
	function deleteSubmit(){
		Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				//delete 호출
				$.ajax({
					type:"POST",
					data:{
						"UserCode" : param.personCode(),
						"FileID" : signFileID()
					},
					url:"deleteSignImage.do",
					success:function (data) {
						if(data.status === "SUCCESS"){
							parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />");
							parent.searchConfig();
							closeLayer();
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteSignImage.do", response, status, error);
					}
				});
			}
		});
	}
	
	
    function fileuploadBeforeCheck() {
        var file = document.getElementById("MyFile");
        if (file.value == "") {
            Common.Warning("<spring:message code='Cache.msg_FileSelect' />");		//파일을 선택해주세요.
            return false;
        }
        if (file.files.item(0).name.length > 20) {
            Common.Warning("<spring:message code='Cache.lbl_apv_warning_filename' />");	//파일명은 20글자 미만으로 해주세요.
            document.getElementById('fileurl').value = "";
            $('#ChangeImgSpan').hide();
            return false;
        }
        if (file.files.item(0).size > 512000) {
            Common.Warning("<spring:message code='Cache.lbl_apv_warning_filesize' />");		//피일크기는 500kb를 넘을 수 없습니다.

            $('#ChangeImgSpan').hide();
            return false;
        }
        return true;
    }
    
    function setChangeImg() {
        var check_result = fileFindCheck();
        if (check_result == true) {
            var url = document.getElementById('MyFile');
            document.getElementById('fileurl').value = url.value;
            var image = document.getElementById('ChangeImg');
	        if (url.value != null) {
	            $('#ChangeImgSpan').css("display","inline-block");
	            //image.src = url.value;
	            if (url.files && url.files[0]) {
	            	var reader = new FileReader();
	            	reader.onload = function (e) {
	            		$('#ChangeImg').attr('src', e.target.result);
	            	}
	            	reader.readAsDataURL(url.files[0]);
	            }
	        }
	        else {
	            $('#ChangeImgSpan').hide();
	        }
          
        }
    }
    
    function fileFindCheck() {
        var file = document.getElementById("MyFile");
        var filename = file.files.item(0).name;
        var fileUrlexe = file.files.item(0).name.split('.');
        var filerealname = filename.substring(0,filename.lastIndexOf("."));      
        if(filerealname.indexOf("_") >=0 ){
            Common.Warning('<spring:message code="Cache.lbl_file_no" />');		//파일명에 "_"를 사용할 수 없습니다.
            return false;                                
        }        
        if(filerealname.lenth>20){
        	 Common.Warning("<spring:message code='Cache.lbl_filename_20' />");		//파일명은 20자 이내로 작성하여 주십시요.
             return false;    
        }
        
        if (fileUrlexe[fileUrlexe.length - 1] != 'gif' && fileUrlexe[fileUrlexe.length - 1] != 'jpg' && fileUrlexe[fileUrlexe.length - 1] != 'bmp'&& fileUrlexe[fileUrlexe.length - 1] != 'png') {
            Common.Warning("<spring:message code='Cache.lbl_apv_warning_extension' />");		//지원하지 않는 확장자입니다.
            document.getElementById('fileurl').value = "";
            $('#ChangeImgSpan').hide();
            return false;
        }
        return true;
    }
    



</script>
<form id="SignManagerSetPopup" name="SignManagerSetPopup"  method="post" enctype="multipart/form-data">
	<div class="pop_body1" >
		<div class="sign_n1_wrap">
            <table class="AXFormTable" >              
                <tbody>
                    <tr>
				        <td class="sign_n_td1" style="text-align: center; width: 170px;height: 103px;">
				            <span id="NowImg" style="left: 73px; width: 80px; display: none;">
				            	<img id="SignImg" alt="NowImage" onerror="coviCmn.imgError(this)" style="border-style: hidden; border-color: inherit; width: 56px; height: 50px;" >
				            	<br><spring:message code='Cache.lbl_nowsign'/>
				            </span>
				            <span id="ChangeImgSpan" style="left: 73px; width: 80px; display: none; ">
				            	<input id="ChangeImg" alt="ChangeImage" onerror="coviCmn.imgError(this)" style="border-style: hidden; border-color: inherit; width: 56px; height: 50px; cursor: default;" onclick="return false;" type="image" >
				            	<br><spring:message code='Cache.lbl_newsign'/>
				            </span>
				        </td>
				        <td class="sign_n_td2">
				     		<input name="fileurl" id="fileurl" type="text" readonly="readonly">				            
				        </td>
				        <td class="sign_n_td3" align="center">
				        <input type="button" class='AXButton' onclick="document.getElementById('MyFile').click();" value="<spring:message code='Cache.lbl_apv_sign'/><spring:message code='Cache.btn_apv_register'/>">			        
                             <!--서명등록-->                         
					    <input type="file" id="MyFile" name="MyFile" accept=".jpg,.bmp,.gif,.png" onchange="setChangeImg();" style="width:0px;filter:alpha(opacity:'0');opacity:0;position:absolute;cursor: pointer;"/>
				        </td> 
				    </tr>
				    <tr>
				        <td style="text-align: left; height:43px" colspan="3">
				            &nbsp;&nbsp;<spring:message code='Cache.lbl_file_no'/><br/>
				            &nbsp;&nbsp;<spring:message code='Cache.lbl_filename_20'/>
				            &nbsp;&nbsp;<br>
				            &nbsp;&nbsp;<spring:message code='Cache.lbl_file_exe'/>
				            <br/>
				            &nbsp;&nbsp;<spring:message code='Cache.lbl_filesize_500'/>
				        </td>
				    </tr>
                </tbody>
            </table>   
        </div>     
                <div class="pop_btn2" align="center">
                	<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveSubmit();" class="AXButton red" />
                	<input type="button" id="btn_delete" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="deleteSubmit();" style="display: none"  class="AXButton" />
                	<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="closeLayer();"  class="AXButton" />                    
                </div>           
        </div>
</form>