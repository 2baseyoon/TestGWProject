<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var MODE = "${param.mode}";
	var paramStampID  = "${param.key}";
	var SERVICE_TYPE = "ApprovalStamp";

	//var SignImagePath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + Common.getBaseConfig("SignImagePath");
	var noImgPath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
	
	$(document).ready(function(){				
		setSelect();
		if(MODE === "modify"){			
			$("#btn_delete").show();
			modifySetData();					
		}
		
		 //file 양식으로 이미지를 선택(값이 변경) 되었을때 처리하는 코드

		$("#oFile").change(function(){
		    //Common.Warning(this.value); //선택한 이미지 경로 표시
		    readURL(this);
		});
		 
		//$("#imgPreThumb").attr("src", coviCmn.loadImage(SignImagePath + "/sign_no_img.gif"));
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
					
					var strBackStoragePath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")); // 이전 직인표시를 위해서만 사용, 신규문서와는 무관
					var src;
					if(_data.FileID && !isNaN(_data.FileID)){
						src = coviCmn.loadImageId(_data.FileID, SERVICE_TYPE);
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
        var strStampID = document.getElementById("hdnStampID").value;
        var strEntCode = document.getElementById("ddlCompany").value;
        var strStampNm = document.getElementById("txtStampNm").value;
        var strOrderNo = document.getElementById("txtOrderNo").value;
        var strUseY = document.getElementById("rdoUseY").checked;
        var strUseN = document.getElementById("rdoUseN").checked;
        var strUseNn = "";

        if(strEntCode == "")
        {
            //[2016-04-12 modi kh] 다국어 변경
            parent.Common.Warning("<spring:message code='Cache.msg_Company_07' />");    //회사(도메인)을 선택하여 주십시오.
            document.getElementById("ddlCompany").focus();
            return false;
        }

        if (strStampNm == "")
        {
        	parent.Common.Warning("<spring:message code='Cache.mgs_apv_Insert_SealName' />");		//직인명을 입력하십시요.
            document.getElementById("txtStampNm").focus();
            return false;
        }
        
        if (strOrderNo == "")
        {
            parent.Common.Warning("<spring:message code='Cache.msg_apv_297' />");		//정렬순서를 입력하세요
            document.getElementById("txtOrderNo").focus();
            return false;
        }

		return true;
    }
	
	//저장
	function saveSubmit(){
		var strUseY = document.getElementById("rdoUseY").checked;
		
		if(!Validation()){
        	return false;
        }
		
		if(MODE!="modify"){
	        if(!fileuploadBeforeCheck()){
	        	return false; 
	        }
		}
		
		if (strUseY == true) {
            //사용중인 직인을 변경하시겠습니까?
			parent.Common.Confirm("<spring:message code='Cache.msg_apv_confirm_reg_stamp' />", "Confirmation Dialog", function(result){
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
    		            	parent.Common.Inform("<spring:message code='Cache.msg_apv_137' />");
    						parent.searchConfig();
    						closeLayer();
    		            },
    		            error:function(response, status, error){
    						CFN_ErrorAjax(url, response, status, error);
    					}
    		        });
				}else{
					return false;
				}
			});
        } else {
        	//저장하시겠습니까?
        	parent.Common.Confirm("<spring:message code='Cache.msg_apv_155' />", "Confirmation Dialog", function(result){
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
    				if(MODE === "modify"){			
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
    		            	parent.Common.Inform("<spring:message code='Cache.msg_apv_137' />");
    						parent.searchConfig();
    						closeLayer();
    						parent.Refresh();
    		            },
    		            error:function(response, status, error){
    						CFN_ErrorAjax(url, response, status, error);
    					}
    		        });
    			}
    		});
        }
	}
	
	//삭제
	function deleteSubmit(){
		parent.Common.Confirm("<spring:message code='Cache.msg_AreYouDelete' />", "Confirmation Dialog", function(result){
			if(!result){
				return false;
			}else{
				var FileName=$("#hidFilename").val();
				//delete 호출 
				$.ajax({
					type:"POST",
					data:{
						"StampID" : paramStampID,
						"FileName" : FileName
					},
					url:"deleteStampData.do",
					success:function (data) {
						if(data.result == "ok"){
							parent.Common.Inform("<spring:message code='Cache.msg_apv_138' />");
							parent.searchConfig();
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
		$("#ddlCompany").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			},
			ajaxUrl: "../common/getEntInfoListAssignData.do",			
			ajaxAsync:false,
			onchange: function(){				
			}
		});
		
	}
	
	// 임시 이미지 업로드
    function imgUpload(obj) {
        // 선택파일의 경로를 분리하여 확장자를 구합니다.
        document.getElementById('fileurl').value = obj;
        
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
<form id="SignManagerSetPopup" name="SignManagerSetPopup"  method="post" enctype="multipart/form-data">
	<div class="pop_body1" style="width:100%;min-height: 100%">
		<table class="AXFormTable" >              
		    <tbody>
		        <tr>
		            <th style="width: 85px ;"><spring:message code='Cache.lbl_apv_Corp'/></th>
		            <td id="Sender">   
		            	<select  name="ddlCompany" class="AXSelect" id="ddlCompany"></select>	                      
		            </td>
		        </tr>
		        <tr>
		            <th style="width: 85px ;"><spring:message code='Cache.lbl_apv_OfficailSeal_Name'/></th>
		            <td id="Sender">
		            	<input type="text" id="txtStampNm" class="AXInput" style="width:200px;"/>                           
		            </td>
		        </tr>
		        <tr>
		            <th style="width: 85px ;"><spring:message code='Cache.lbl_RegistImage'/></th>
		            <td id="Sender">    
		            	<input name="fileurl" id="fileurl" type="text" class="AXButton" readonly="readonly">
		             <input type="button" class='AXButton' onclick="document.getElementById('oFile').click();" value="<spring:message code='Cache.btn_apv_AddStempImage'/>">
		           	 	<input type="file" id="oFile"  onchange="imgUpload(this.value);" style="width:0px;filter:alpha(opacity:'0');opacity:0;position:absolute;cursor: pointer;" accept=".gif,.jpg,.png"/>
		            	<p  style="clear:both; font-size:11px; color:#aaaaaa;"><spring:message code='Cache.lbl_apv_image_message'/></p>
		            </td>
		        </tr>                    
		        <tr>
		            <th style="width: 85px ;"><spring:message code='Cache.btn_apv_preview'/></th>
		            <td id="Sender">        
		            	<img id="imgPreThumb" onerror="coviCmn.imgError(this)" style="border-style: hidden; border-color: inherit; width: 61px; height: 55px;" alt="Stamp Image Preview" />                   
		            </td>
		        </tr>
		        <tr>
		            <th style="width: 85px ;"><spring:message code='Cache.lbl_SortOrder'/></th>
		            <td id="Sender">   
		            	<input name="txtOrderNo"  mode="numberint"  num_max="32767"  class="AXInput"  id="txtOrderNo" type="text" maxlength="250"  style="width:300px;" />                        
		            </td>
		        </tr>
		        <tr>
		            <th style="width: 85px ;"><spring:message code='Cache.lbl_IsUse'/></th>
		            <td id="Sender">                           
		            	<input type="radio" id="rdoUseY" name="rdoUseYn" value="Y" style="float:left;" /> <div style="float:left;"><spring:message code='Cache.lbl_USE_Y'/><!-- 사용함 --></div> 
		                <input type="radio" id="rdoUseN" name="rdoUseYn" value="N" style="float:left;margin-left:10px;" checked="checked" /> <div style="float:left; "><spring:message code='Cache.lbl_noUse'/><!-- 사용안함 --></div>
		            </td>
		        </tr>
		    </tbody>
		</table>        
		<div class="pop_btn2" align="center">
			<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveSubmit();" class="AXButton red" />
			<input type="button" id="btn_delete" value="<spring:message code='Cache.btn_apv_delete'/>" onclick="deleteSubmit();" style="display: none"  class="AXButton" />
			<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="closeLayer();"  class="AXButton" />                    
		</div>
	</div>

	<input type="hidden" name="EntCode" id="EntCode" />        
	<input type="hidden" name="hdnStampID" id="hdnStampID" />
	<input type="hidden" name="hidFilename" id="hidFilename" />
</form>