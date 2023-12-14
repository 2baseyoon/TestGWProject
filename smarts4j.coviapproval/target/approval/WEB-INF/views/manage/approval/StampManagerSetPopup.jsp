<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var MODE = "${param.mode}";
	var paramStampID  = "${param.key}";
	var SERVICE_TYPE = "ApprovalStamp";
	var lang = Common.getSession("lang");
	var previousUseY = "";
	
	var noImgPath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
	
	$(document).ready(function(){				
		setSelect();
		if(MODE === "modify"){			
			$("#btn_delete").show();
			modifySetData();					
		}
		
		 //file 양식으로 이미지를 선택(값이 변경) 되었을때 처리하는 코드

		$("#oFile").change(function(){
		    readURL(this);
		});
		 
		$("#imgPreThumb").attr("src", coviCmn.loadImage(noImgPath + "no_image.jpg"));
	});
	
	function readURL(input) {
		 if (input.files && input.files[0]) {
			 
			 if(input.files[0].type.match('image.*')){
				 var reader = new FileReader(); //파일을 읽기 위한 FileReader객체 생성
				 reader.onload = function (e) {
					 //파일 읽어들이기를 성공했을때 호출되는 이벤트 핸들러
			         $('#imgPreThumb').attr('src', e.target.result);
			         //이미지 Tag의 SRC속성에 읽어들인 File내용을 지정
			         //(아래 코드에서 읽어들인 dataURL형식)
			     }                   
			     reader.readAsDataURL(input.files[0]);
			     //File내용을 읽어 dataURL형식의 문자열로 저장
			 }else{
				 parent.Common.Warning("이미지 파일로 등록해주시기 바랍니다.", "Warning", function(){
		    			$("#fileurl").val("");
		    			$(input).val("");
		    			$(input).click();
		    		});
		    	}
		 }
	}
	
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
				"StampID" : paramStampID	//StampID		
			},
			url:"getStampData.do",
			success:function (data) {
				if(Object.keys(data.list[0]).length > 0){
					var _data = data.list[0];
					$("#ddlCompany").bindSelectSetValue(_data.EntCode);
					$("#txtStampNm").val(_data.StampName);
					$("#txtOrderNo").val(_data.OrderNo)
					if(_data.UseYn=="Y"){
						$("#rdoUseY").prop("checked",true);		    
					}else{
						$("#rdoUseN").prop("checked",true);		    
					}
					previousUseY = _data.UseYn;
					
					var strBackStoragePath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")); // 이전 직인표시를 위해서만 사용, 신규문서와는 무관
					var src;
					if(_data.FileID && !isNaN(_data.FileID)){
						src = coviCmn.loadImageId(_data.FileID, SERVICE_TYPE);
						$("#hidFileID").val(_data.FileID);// for Delete.
					} else {
						src = _data.FileInfo;
						if(src.indexOf(strBackStoragePath) == -1){
							src = strBackStoragePath + src;
						}
						src = coviCmn.loadImage(src);
					}
					
					$("#imgPreThumb").attr("src", src);
				}
				else{ 
					$("#btn_delete").hide();
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getStampData.do", response, status, error);
			}
		});
	}
	
	 // 입력값 체크
    function Validation() {
        var strStampID = $("#hdnStampID").val();
        var strEntCode = $("#ddlCompany").val();
        var strStampNm = $("#txtStampNm").val();
        var strOrderNo = $("#txtOrderNo").val();
        var strUseY = $("#rdoUseY").is(":checked");
        var strUseN = $("#rdoUseN").is(":checked");
        var strUseNn = "";

        if(strEntCode == "")
        {
            //[2016-04-12 modi kh] 다국어 변경
            ////회사(도메인)을 선택하여 주십시오.
            parent.Common.Warning("<spring:message code='Cache.msg_Company_07' />", null, function() {
	            $("#ddlCompany").focus();
            });
            return false;
        }

        if (strStampNm == "")
        {
        	//직인명을 입력하십시요.
        	parent.Common.Warning("<spring:message code='Cache.mgs_apv_Insert_SealName' />", null, function(){
	            $("#txtStampNm").focus();
        	});
            return false;
        }
        
        if (strOrderNo == "")
        {
        	//정렬순서를 입력하세요
            parent.Common.Warning("<spring:message code='Cache.msg_apv_297' />", null, function(){
	            $("#txtOrderNo").focus();
            });
            return false;
        }

		return true;
    }
	
	//저장
	function saveSubmit(){
		if(!Validation()){
        	return false;
        }
		
		if(MODE != "modify"){
	        if(!fileuploadBeforeCheck()){
	        	return false; 
	        }
		}
		
		var msg = "<spring:message code='Cache.msg_apv_155' />";
		if (previousUseY == "Y") { // 사용여부 변경없이 내용만 변경하는 경우
            //사용중인 직인을 변경하시겠습니까?
            msg = "<spring:message code='Cache.msg_apv_confirm_reg_stamp' />";
		}
	
		parent.Common.Confirm(msg, "Confirmation Dialog", function(result){
			if(result){
				//파일업로드시스템 후 추가 개발
   				var formData = new FormData();
   				
   				formData.append('StampID', paramStampID);
   				formData.append('EntCode', $("#ddlCompany").val());
   				formData.append('EntName', $("#ddlCompany option:selected").text());
   				formData.append('StampName', $("#txtStampNm").val());
   				formData.append('FileInfo', $('#oFile')[0].files[0]);
   				formData.append('OrderNo', $("#txtOrderNo").val());
   				formData.append('UseYn', $(":input:radio[name=rdoUseYn]:checked").val());

   				var url;
   				if(MODE==="modify"){			
   					url = "updateStampData.do";			
   				}else{
   					url = "insertStampData.do";
   				}
   				
   				//insert 호출		
   				 $.ajax({
   					type : 'post',
   		            url : url,
   		            data : formData,
   		            dataType : 'json',
   			        processData : false,
   			        contentType : false,	            
   		            success : function(json){
   		            	if(json.status == "SUCCESS"){
    		            	parent.Common.Inform("<spring:message code='Cache.msg_apv_137' />");
    						//parent.searchConfig(); // 스위치 작동이상
    						parent.Refresh();
    						closeLayer();
   		            	}else{
   		            		parent.Common.Error("<spring:message code='Cache.msg_apv_030'/>");
   		            	}
   		            },
   		            error:function(response, status, error){
   						CFN_ErrorAjax(url, response, status, error);
   					}
   		        });
			}else{
				return false;
			}
		});
	}
	
	//삭제
	function deleteSubmit(){
		parent.Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				var FileID = $("#hidFileID").val();
				//delete 호출 
				$.ajax({
					type:"POST",
					data:{
						"StampID" : paramStampID,
						"FileID" : FileID
					},
					url:"deleteStampData.do",
					success:function (data) {
						if(data.result == "ok"){
							parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />");
							//parent.searchConfig(); // 스위치 작동이상
    						parent.Refresh();
							closeLayer();
						}				
										
					},
					error:function(response, status, error){
						CFN_ErrorAjax("deleteStampData.do", response, status, error);
					}
				});
			}
		});
	}	
	
    function fileuploadBeforeCheck() {
        var file = document.getElementById("oFile");
        if (file.value == "") {
        	parent.Common.Warning("<spring:message code='Cache.msg_FileSelect' />");		//파일을 선택해주세요.
            return false;
        }
        if (file.files.item(0).name.length > 20) {
        	parent.Common.Warning("<spring:message code='Cache.lbl_apv_warning_filename' />");		//파일명은 20글자 미만으로 해주세요.
            document.getElementById('fileurl').value = "";
            return false;
        }
        if (file.files.item(0).size > 512000) {
        	parent.Common.Warning("<spring:message code='Cache.lbl_apv_warning_filesize' />");			//피일크기는 500kb를 넘을 수 없습니다.
            return false;
        }
        
        return true;
    }
    
 // Select box 바인드
	function setSelect(){
		coviCtrl.renderCompanyAXSelect("ddlCompany", lang, false,"","", Common.getSession("DN_Code"), {codeType: "Code"});
	}
	
	// 임시 이미지 업로드
    function imgUpload(obj) {
        // 선택파일의 경로를 분리하여 확장자를 구합니다.
        $('#fileurl').val(obj);
        
        pathPoint = obj.lastIndexOf('.');
        filePoint = obj.substring(pathPoint + 1, obj.length);
        fileType = filePoint.toLowerCase();
        strImgNm = obj.substring(obj.lastIndexOf("\\") +1, obj.length);
  
        // 확장자가 이미지 파일이면 preview에 보여줍니다.
        if (fileType == 'jpg' || fileType == 'gif' || fileType == 'png' || fileType == 'jpeg' || fileType == 'bmp') {
        	return true;
        }
        else {
            //Common.Warning("<spring:message code='Cache.msg_OnlyImageFileAttach' />");			//이미지 파일만 첨부해 주세요.
            return false;
        }
    }


</script>
<div class="sadmin_pop">
	<table class="sadmin_table sa_menuBasicSetting" >              
		<colgroup>
        	<col width="100px;">
        	<col width="*">
        </colgroup>
	    <tbody>
	        <tr <covi:admin hiddenWhenEasyAdmin="true"/>>
	            <th><spring:message code='Cache.lbl_apv_Corp'/></th>
	            <td id="Sender">
	            	<select name="ddlCompany" class="selectType02" id="ddlCompany"></select>	                      
	            </td>
	        </tr>
	        <tr>
	            <th><spring:message code='Cache.lbl_apv_OfficailSeal_Name'/></th><!-- 직인명 -->
	            <td id="Sender">
	            	<input type="text" id="txtStampNm" class="w200p" />                           
	            </td>
	        </tr>
	        <tr>
	            <th><spring:message code='Cache.lbl_RegistImage'/></th><!-- 직인이미지 -->
	            <td id="Sender">
	            	<input name="fileurl" id="fileurl" type="text" readonly="readonly" style="display:none;">
	             	<a class="btnTypeDefault" onclick="document.getElementById('oFile').click();" ><spring:message code='Cache.lbl_SelectFile'/></a>
	           	 	<input type="file" id="oFile"  onchange="imgUpload(this.value);" style="width:0px;filter:alpha(opacity:'0');opacity:0;position:absolute;cursor: pointer;" accept=".gif,.jpg,.png"/>
	            	<p style="clear:both; font-size:11px; color:#aaaaaa;margin-top:5px;"><spring:message code='Cache.lbl_apv_image_message'/></p><!-- 도움말 -->
	            </td>
	        </tr>
	        <tr>
	            <th><spring:message code='Cache.btn_apv_preview'/></th>
	            <td id="Sender">
	            	<img id="imgPreThumb" onerror="coviCmn.imgError(this)" style="border-style: hidden; border-color: inherit; width: 61px; height: 55px;" alt="Stamp Image Preview" />                   
	            </td>
	        </tr>
	        <tr>
	            <th><spring:message code='Cache.lbl_SortOrder'/></th>
	            <td id="Sender">
	            	<input name="txtOrderNo"  mode="numberint"  num_max="32767"  class="w100p"  id="txtOrderNo" type="text" maxlength="250"  style="width:300px;" />                        
	            </td>
	        </tr>
	        <tr>
	            <th><spring:message code='Cache.lbl_IsUse'/></th>
	            <td id="Sender">
					<span class="radioStyle04 size"><input type="radio" id="rdoUseY" name="rdoUseYn" value="Y"><label for="rdoUseY"><span><span></span></span><spring:message code='Cache.lbl_USE_Y'/><!-- 사용함 --></label></span>
					<span class="radioStyle04 size"><input type="radio" id="rdoUseN" name="rdoUseYn" value="N" checked="checked"><label for="rdoUseN"><span><span></span></span><spring:message code='Cache.lbl_noUse'/><!-- 사용안함 --></label></span>
	            </td>
	        </tr>
	    </tbody>
	</table>        
	<div class="bottomBtnWrap">
		<a onclick="saveSubmit();" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_apv_save'/></a>
		<a id="btn_delete" onclick="deleteSubmit();" style="display: none"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_delete'/></a>
		<a onclick="closeLayer();"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>                    
	</div>
</div>
<input type="hidden" name="EntCode" id="EntCode" />        
<input type="hidden" name="hdnStampID" id="hdnStampID" />
<input type="hidden" name="hidFileID" id="hidFileID" />