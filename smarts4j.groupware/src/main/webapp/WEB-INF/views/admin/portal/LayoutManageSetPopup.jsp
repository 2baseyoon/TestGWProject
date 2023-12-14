<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>


<form id="LayoutManagerSetPopup" name="LayoutManagerSetPopup"  method="post" enctype="multipart/form-data">
	<div class="pop_body1" style="width:100%;min-height: 100%">
	    <table class="AXFormTable" >       
	    	<colgroup>
				<col style="width: 110px ;"></col>
				<col></col>
	    	</colgroup>       
	        <tbody>
	            <tr>
	                <th><spring:message code='Cache.lbl_layoutName'/><font color="red">*</font></th>
	                <td>   
	                	<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="layoutName"  style="width: 95%;"/>                   
	                </td>
	            </tr>
	            <tr>
	                <th><spring:message code='Cache.lbl_layoutHTML'/><font color="red">*</font></th><!-- 레이아웃 HTML  -->
	                <td>
	                	<textarea id="layoutHTML" rows="5" style="width: 95%; margin: 0px;  resize:vertical; font-family: 'Nanum Gothic','맑은고딕'; " id="layoutHTML" class="AXTextarea"></textarea>                         
	                </td>
	            </tr>
	            <tr>
	                <th>설정용 HTML<font color="red">*</font></th><!-- 레이아웃 HTML  -->
	                <td>
	                	<textarea id="SettingLayoutHTML" rows="5" style="width: 95%; margin: 0px;  resize:vertical; font-family: 'Nanum Gothic','맑은고딕'; " id="layoutHTML" class="AXTextarea"></textarea>                         
	                </td>
	            </tr>
	            <tr>
	                <th><spring:message code='Cache.lbl_Thumbnail'/></th><!-- 썸네일-->
	                <td>
	               	 	<input type="file" id="thumbnail" onchange="thumbnailUpload(this.value);" style="width:300px;"/>
					</td>
	            </tr>                    
	            <tr>
	                <th><spring:message code='Cache.btn_apv_preview'/></th>
	                <td style="height:55px;">        
	                	<img id="imgPreThumb" width="50px" height="50px" src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/no_img.gif" onerror="/smarts4j/covicore/resources/images/covision/no_img.gif"/>                   
	                </td>
	            </tr>
	           	<tr>
				  <th><spring:message code="Cache.lbl_PriorityOrder"/><font color="red">*</font></th> <!--우선순위 -->
				  <td>
				  	<input id="sortKey" name="sortKey" type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" style="width: 95%;"/> 
				  </td>
			    </tr>
	  <%--      <tr>
	                <th><spring:message code="Cache.lbl_DefaultUsage"/></th><!--기본 사용여부  -->
	                <td>  
	    	 			<label>
	                        <input type="checkbox" id="isDefault" name="isDefault" />
	                        <spring:message code='Cache.lbl_DefaultLayout'/> <!-- 기본 레이아웃 -->
	                    </label>                         
	                </td>
	            </tr> --%>
	        </tbody>
	    </table>        
	    <div class="pop_btn2" align="center">
	     	<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveLayout();" class="AXButton red" />
	     	<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="Common.Close();"  class="AXButton" />                    
	    </div>           
	</div>
	<input id="isDefault" type="hidden" />
</form>


<script  type="text/javascript">
	var layoutID = CFN_GetQueryString("layoutID") == 'undefined'? 0 : CFN_GetQueryString("layoutID");

	//ready
	init();
	
	function init(){
		if(layoutID!=0){ 
			setData(layoutID); //수정화면이라면 데이터 셋팅
		}
		
		 //이미지 파일을 선택(값이 변경) 되었을때 처리하는 코드
		$("#thumbnail").change(function(){
		    readURL(this);
		});
	}
	
	function setData(layoutID){
		$.ajax({
			type:"POST",
			url:"/groupware/portal/getLayoutData.do",
			data:{
				"layoutID":layoutID
			},
			success:function(data){
				if(data.status == 'SUCCESS'){
					$("#layoutName").val(data.list[0].DisplayName);
					if(data.list[0].LayoutTag) $("#layoutHTML").val(Base64.b64_to_utf8(data.list[0].LayoutTag));
					if(data.list[0].SettingLayoutTag) $("#SettingLayoutHTML").val(Base64.b64_to_utf8(data.list[0].SettingLayoutTag));
					$("#sortKey").val(data.list[0].SortKey);
					$("#isDefault").val(data.list[0].IsDefault);
					/* if(data.list[0].IsDefault == 'Y'){
						$("input:checkbox[id='isDefault']").prop("checked",true);
					}else{
						$("input:checkbox[id='isDefault']").prop("checked",false);
					}
					 */
					if(data.list[0].LayoutThumbnail!=''){
						// baseconfig LayoutThumbnail_SavePath 경로의 파일 조회
						$('#imgPreThumb').attr('src', coviCmn.loadImage(Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + data.list[0].LayoutThumbnail));
					}else{
						$('#imgPreThumb').attr('src', '/HtmlSite/smarts4j_n/covicore/resources/images/covision/no_img.gif');
					}
				}
			},
			error:function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("/groupware/portal/getLayoutData.do", response, status, error);
			}
			
			
		});
	}
	
	
	
	 function readURL(input) {
		 if (input.files && input.files[0]) {
			 var reader = new FileReader(); //파일을 읽기 위한 FileReader객체 생성
			 reader.onload = function (e) {
				 //파일 읽어들이기를 성공했을때 호출되는 이벤트 핸들러
		         $('#imgPreThumb').attr('src', e.target.result);
		         //이미지 Tag의 SRC속성에 읽어들인 File내용을 지정
		         //(아래 코드에서 읽어들인 dataURL형식)
		     }                   
		     reader.readAsDataURL(input.files[0]);
		     //File내용을 읽어 dataURL형식의 문자열로 저장
		 }
	}

	
	//저장
	function saveLayout(){
		
		
// 		if($("#isDefault").val()=="Y"){
// 			Common.Inform("<spring:message code='Cache.msg_LayoutCreate6'/>");
// 			return false;
// 		}
		
        if(!fileuploadBeforeCheck()){
        	return false; 
        }
        
        if(!Validation()){
        	return false;
        }
	
		var url;
		
		var formData = new FormData();
		formData.append('layoutID', layoutID);
		formData.append('layoutName',$("#layoutName").val());
		formData.append('layoutHTML', Base64.utf8_to_b64($("#layoutHTML").val()));
		formData.append('settingLayoutHTML', Base64.utf8_to_b64($("#SettingLayoutHTML").val()));
		formData.append('sortKey', $("#sortKey").val());
		formData.append('isDefault', "Y");
		formData.append('isCommunity', "N");
		//formData.append('isDefault', ($("input:checkbox[id='isDefault']").is(":checked")==true?"Y":"N"));
		formData.append('thumbnail', $('#thumbnail')[0].files[0]);
		
		if(layoutID!=0){			
			url = "/groupware/portal/updateLayoutData.do";			
		}else{
			url = "/groupware/portal/insertLayoutData.do";
		}
		
		parent.Common.Progress(Common.getDic('msg_apv_008'));
		
		//insert 호출		
		 $.ajax({
	            type : 'post',
	            url : url,
	            data : formData,
	            dataType : 'json',
	            processData : false,
		        contentType : false,	  
	            success : function(data){	
	            	if(data.status=='SUCCESS'){
		            	Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ //저장되었습니다.
							Common.Close();
		            		if(parent.layoutGrid != undefined){parent.layoutGrid.reloadList();}
		            	});
	            	}else{
	            		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
	            	}
	            },
	            error:function(response, status, error){
	                //TODO 추가 오류 처리
	                CFN_ErrorAjax(url, response, status, error);
	            }
	        });
		
	}
	
	
    function fileuploadBeforeCheck() {
        var file = document.getElementById("thumbnail");
        
        if(file.files.length<=0){
        	return true;
    	}else if (file.files.item(0).name.length > 20) {
            Common.Warning("<spring:message code='Cache.lbl_apv_warning_filename'/>");
            document.getElementById('fileurl').value = "";
            return false;
        }else if (file.files.item(0).size > 512000) {
        	Common.Warning("<spring:message code='Cache.lbl_apv_warning_filesize'/>");
            return false;
        }else {
            return true;
        }
    }
    
   
	// 임시 이미지 업로드
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
	       	   $('#imgPreThumb').attr('src', "/HtmlSite/smarts4j_n/covicore/resources/images/covision/no_img.gif");
	           return false;
	       }
        }else{
	       $('#imgPreThumb').attr('src', "/HtmlSite/smarts4j_n/covicore/resources/images/covision/no_img.gif");
	       return false;
        }
    }

 // 입력값 체크
    function Validation() {
        var layoutName = document.getElementById("layoutName").value;
        var sortKey = document.getElementById("sortKey").value;
        var layoutHTML = document.getElementById("layoutHTML").value;

        if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

        if(layoutName == ""){
        	/*레이아웃 명이 입력되지 않아 저장할 수 없습니다.*/
            Common.Warning("<spring:message code='Cache.msg_LayoutCreate4'/>");   
            document.getElementById("layoutName").focus();
            return false;
        }else if (sortKey == "") {
        	/* 정렬키를 입력해주세요. */
            Common.Warning("<spring:message code='Cache.msg_needSortKey'/>");
            document.getElementById("sortKey").focus();
            return false;
        }else if(layoutHTML == ""){
    		/*레이아웃 HTML이 입력되지 않아 저장할 수 없습니다.*/
    		Common.Warning("<spring:message code='Cache.msg_LayoutHTMLCreate'/>");   
    		document.getElementById("layoutHTML").focus();
    		return false;
    	}else {
            return true;
        }
    }
</script>

