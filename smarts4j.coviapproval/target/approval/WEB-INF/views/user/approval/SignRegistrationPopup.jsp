<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String mode = request.getParameter("mode");
%>
<c:set var="mode" value="<%=mode%>"/>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
	ul.signBox{ box-sizing: content-box; }
</style>
<form>
<div class="divpop_contents">
	<div class="pop_header" id="testpopup_ph">
			<!-- 팝업 Contents 시작 -->
		<div class="popBox">
			<div class="bgPop">
				<div class="signPopL">
					<ul class="signBox popSign ml10">
						<li><spring:message code='Cache.lbl_apv_setschema_114'/></li>
						<li class="sigFill"><img id="img_preview" onerror="coviCmn.imgError(this);" src="" alt="Sign Image Preview" style="max-width: 100%;height: auto;"/></li>
						<li><spring:message code='Cache.lbl_apv_approval_sign'/></li>
						<li><spring:message code='Cache.lbl_apv_approvdate'/></li>
					</ul>
				</div>
				<div class="signPopR">
					<spring:message code='Cache.lbl_file_no'/> <!--파일명에 "_"와 ";" 를 사용할 수 없습니다.--><br>
					<spring:message code='Cache.lbl_filename_20'/> <!--파일명은 20자 이내로 작성하여 주십시요.--><br>
					<spring:message code='Cache.lbl_file_exe'/> <!--업로드 가능한 파일 확장자는 .jpg, .bmp, .gif, .png 입니다.--><br>
					<spring:message code='Cache.lbl_filesize_500'/> <!--이미지 용량은 500kb이하만 가능합니다.--><br><br>
					<input id="FileName" name="FileName" type="file" onchange="readURL(this)" value="213123" accept=".jpg,.bmp,.gif,.png"/>
					<input type="checkbox" id="delegateYn" value="Y"/><spring:message code='Cache.msg_RepresentativeImg'/><!-- 대표이미지 -->
				</div>
			</div>
		</div>
		<!-- 하단버튼 시작 -->
		<div class="popBtn borderNon t_center">
			<c:if test="${mode eq 'inst'}">
				<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="insertUserSign()" class="ooBtn ooBtnChk">
			</c:if>
			<c:if test="${mode eq 'updt'}">
				<input type="button" value="<spring:message code='Cache.btn_Modify'/>" onclick="updateUserSign()" class="ooBtn">
			</c:if>
			<input type="button" value="<spring:message code='Cache.btn_Close'/>" onclick="closeLayer()" class="owBtn">
		</div>
		<!-- 하단버튼 끝 -->
		<!-- 팝업 Contents 끝 -->
		</div>
	</div>
</form>
<script>
	var mode = "${param.mode}";
	var signID = "${param.signID}";
	
	initSignPopup();
	
	function initSignPopup(){
		if(mode == 'updt'){
			setUserSignList();
		}else{
			$("#delegateYn").attr("checked", true);
		}
	}
	
	// 수정일경우 조회
	function setUserSignList(){
		$.ajax({
			url:"/approval/user/getUserSignImage.do",
			type:"GET",
			data:{"signID":signID},
			async:false,
			success:function (data) {
				if(data.result.IsUse == "Y"){
					$("#delegateYn").prop('checked',true);
				}
				
				var strBackStoragePath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")); // 이전 서명 표시를 위해서만 사용, 신규 데이터는 무관
			    var src;
			    if(data.result.FileID > 0){
			    	src = coviCmn.loadImageId(data.result.FileID,"ApprovalSign");
			    } else {
			    	src = data.result.FilePath;
				    if(src.indexOf(strBackStoragePath) == -1)
				    	src = strBackStoragePath + src;
				    src = coviCmn.loadImage(src);
			    }			    	
			    $('#img_preview').attr('src', src);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getUserSignImage.do", response, status, error);
			}
		});
	}
	
	//파일이 선택되면 미리보기로 화면에 표시
	function readURL(input) {
	    if (input.files && input.files[0]) {
	    	
	    	if(input.files[0].type.match('image.*')){
	    		var reader = new FileReader(); //파일을 읽기 위한 FileReader객체 생성
		        reader.onload = function (e) {
		            //파일 읽어들이기를 성공했을때 호출되는 이벤트 핸들러
		            $('#img_preview').attr('src', e.target.result);
		            //이미지 Tag의 SRC속성에 읽어들인 File내용을 지정
		            //(아래 코드에서 읽어들인 dataURL형식)
		        }
		        reader.readAsDataURL(input.files[0]);
		        //File내용을 읽어 dataURL형식의 문자열로 저장
	    	}else{
	    		Common.Warning("이미지 파일로 등록해주시기 바랍니다.", "Warning", function(){
	    			$(input).val("");
	    			$(input).click();
	    		});
	    	}
	    }
	}
	
	//서명등록
	function insertUserSign(){
		var IsUse = "N";
		if($("#delegateYn").prop('checked') == true){
			IsUse = "Y";
		}
		
		if(checkValidation() == true){
	
			//파일업로드시스템 후 추가 개발
			var fileName = $("input[id=FileName]").val();
	
			var formData = new FormData();
			formData.append('fileName', fileName);
			formData.append('IsUse', IsUse);
			formData.append('MyFile', $('#FileName')[0].files[0]);
	
			//insert 호출
			 $.ajax({
	            type : 'post',
	            url : '/approval/user/insertUserSign.do',
	            data : formData,
	            dataType : 'json',
		        processData : false,
		        contentType : false,
	            success : function(data){
	            	if(data.status == "SUCCESS"){
		            	Common.Inform("<spring:message code='Cache.msg_insert'/>","<spring:message code='Cache.lbl_apv_Regisign'/>",function(){
							closeLayer();
							parent.refresh();
						});
	            	} else{
						Common.Error(data.message);
	            	}
	            },
	            error:function(response, status, error){
					CFN_ErrorAjax("/approval/user/insertUserSign.do", response, status, error);
				}
	        });
		}
	}
	
	//서명수정
	function updateUserSign(){
		//파일업로드시스템 후 추가 개발
		var IsUse;
		if($("#delegateYn").prop('checked') == true){
			IsUse = "Y";
		}else{
			IsUse = "N";
		}
		var fileName = $("input[id=FileName]").val();
	
		var formData = new FormData();
		formData.append('fileName', fileName);
		formData.append('MyFile', $('#FileName')[0].files[0]);
		formData.append('IsUse', IsUse);
		formData.append('SignID', signID);
		//update 호출
		 $.ajax({
	            type : 'post',
	            url : '/approval/user/updateUserSign.do',
	            data : formData,
	            dataType : 'json',
		        processData : false,
		        contentType : false,
	            success : function(data){
	            	if(data.result=="ok"){
		            	Common.Inform("<spring:message code='Cache.msg_Edited'/>","<spring:message code='Cache.lbl_apv_Regisign'/>",function(){
							closeLayer();
							parent.refresh();
						});
	            	}
	            	else {
	            		Common.Warning(data.message);
	            	}
	            },
	            error:function(response, status, error){
					CFN_ErrorAjax("/approval/user/updateUserSign.do", response, status, error);
				}
	        });
	}
	
	//서명등록시 Validation Check
	function checkValidation(){
	    if ($("input[id=FileName]").val() == "") {
	    	//파일을 선택해주십시요., 서명등록
	    	Common.Warning("<spring:message code='Cache.msg_apv_066'/>","<spring:message code='Cache.lbl_apv_Regisign'/>","");
	        return false;
	    }
	
	    return true;
	}
	
	//팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	//새로고침
	function refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
</script>