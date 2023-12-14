<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>

<form id="LayoutManagerSetPopup" name="LayoutManagerSetPopup"  method="post" enctype="multipart/form-data">
	<div class="pop_body1" style="width:100%;min-height: 100%">
	    <table class="AXFormTable" >       
	    	<colgroup>
				<col style="width: 110px;"></col>
				<col></col>
				<col style="width: 110px;"></col>
				<col></col>
	    	</colgroup>
	        <tbody>
	            <tr>
	                <th><spring:message code='Cache.lbl_EquipmentName'/><font color="red">*</font></th><!--장비명-->
	                <td colspan="3">   
	                	<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="equipmentName" style="width: 75%;" onchange="$('#hidNameDicInfo').val('');"/>                   
		                <input id="hidNameDicInfo" name="hidNameDicInfo" type="hidden" />
			  			<input type="button" value="<spring:message code='Cache.lbl_MultiLang2'/>" class="AXButton" onclick="callDicPop();" style="margin-left:5px;" /> <!-- 다국어 -->
	                </td>
	            </tr>
	            <tr>
	                <th><spring:message code='Cache.lbl_SmartIcon'/></th><!-- 아이콘 -->
	                <td colspan="3">
	                	<img id="imgPreThumb" width="16px" height="16px" src="/HtmlSite/smarts4j_n/covicore/resources/images/covision/noimg_s.gif" onerror="/smarts4j/covicore/resources/images/covision/noimg_s.gif"  style="vertical-align: sub; margin-left: 7px;"/>
	                	<input type="file" id="thumbnail" onchange="thumbnailUpload(this.value);" style="margin-left:10px;"/>
	                </td>
	            </tr>
	            <tr>
	            	<th><spring:message code='Cache.lbl_OwnedCompany'/></th><!--소유회사-->
	            	<td>
	            		<select id="companySelectBox" class="AXSelect"></select>
	            	</td>
	            	<th><spring:message code='Cache.lbl_selUse'/></th><!-- 사용유무-->
	                <td>
	               	 	<select id="isUseSelectBox" class="AXSelect" style="width:97%"></select>
					</td>
	            </tr>
	            <tr>
	                <th><spring:message code='Cache.lbl_PriorityOrder'/><font color="red">*</font></th><!--우선 순위-->
	                <td colspan="3">
	               	 	<input type="text" class="AXInput HtmlCheckXSS ScriptCheckXSS" id="sortKey" onkeyup="toNumFormat()" style="width: 90%;"/>                   
					</td>
	            </tr>                    
	        </tbody>
	    </table>        
	    <div class="pop_btn2" align="center" style="margin-top:25px">
	     	<input type="button" value="<spring:message code='Cache.btn_apv_save'/>" onclick="saveEquipment();" class="AXButton red" />
	     	<input type="button" value="<spring:message code='Cache.btn_apv_close'/>" onclick="Common.Close();"  class="AXButton" />                    
	    </div>           
	</div>
</form>

<script>

var equipmentID = CFN_GetQueryString("equipmentID") == 'undefined'? 0 : CFN_GetQueryString("equipmentID");
var openLayerName = CFN_GetQueryString("CFN_OpenLayerName") == 'undefined'? "" : CFN_GetQueryString("CFN_OpenLayerName");

var sessionObj = Common.getSession(); //전체호출
var lang = sessionObj["lang"];

$(document).ready(function (){
		setSelectBox();  	// 검색 조건 select box 바인딩
		
		if(equipmentID!=0){ 
			setData(equipmentID); //수정화면이라면 데이터 셋팅
		}
		
		 //이미지 파일이 변경 되었을때 처리하는 코드
		$("#thumbnail").change(function(){
		    readURL(this);
		});
});

function setSelectBox(){
	$("#isUseSelectBox").bindSelect({
		reserveKeys : {
			optionValue : "value",
			optionText : "name"
		},
		options : [ 
					{
						"name" : "<spring:message code='Cache.lbl_USE_Y'/>",    //사용함
						"value" : "Y"
					},
					{
						"name" : "<spring:message code='Cache.lbl_USE_N'/>",   //사용 안 함
						"value" : "N"
					}
		],
	});
	<%-- 
	22.04.26 해당 select에서 true값을 false값으로 변경. MariaDB에서는 전체로 놓고 입력 시 ''값이 0(그룹사(공용))으로 insert 되지만,
	Oracle/Tibero 에서는 NULL 값으로 들어가 오류 발생. 전체 항목 제외.
	--%>
	coviCtrl.renderDomainAXSelect('companySelectBox', Common.getSession("lang"), '', '', '', false);
}

function setData(equipmentID){
	$.ajax({
		type:"POST",
		url:"/groupware/resource/getEquipmentData.do",
		data:{
			"equipmentID":equipmentID
		},
		success:function(obj){
			if(obj.status == 'SUCCESS'){
				var backStorage = Common.getBaseConfig("BackStorage").replace("{0}", obj.list[0].CompanyCode) ; // baseconfig EquipmentThumbnail_SavePath 경로의 파일을 조회(202205 현재는 해당 설정값이 없어서 루트경로에 들어감)
				$("#hidNameDicInfo").val(obj.list[0].MultiEquipmentName);
				$("#equipmentName").val( CFN_GetDicInfo(obj.list[0].MultiEquipmentName) );
				$("#isUseSelectBox").bindSelectSetValue(obj.list[0].IsUse);
				$("#sortKey").val(obj.list[0].SortKey);
				$("#companySelectBox").bindSelectSetValue(obj.list[0].DN_ID);
				
				if(obj.list[0].IconPath!=''){
					$('#imgPreThumb').attr('src', coviCmn.loadImage(backStorage + obj.list[0].IconPath));
				}else{
					$('#imgPreThumb').attr('src','/HtmlSite/smarts4j_n/covicore/resources/images/covision/no_img.gif');
				}
			}
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/resource/getEquipmentData.do", response, status, error);
		}
	});
}


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
       	   $('#imgPreThumb').attr('src', "/HtmlSite/smarts4j_n/covicore/resources/images/covision/noimg_s.gif");
           return false;
       }
    }else{
       $('#imgPreThumb').attr('src', "/HtmlSite/smarts4j_n/covicore/resources/images/covision/noimg_s.gif");
       return false;
    }
}

function readURL(input) {
	 if (input.files && input.files[0]) {
		 var reader = new FileReader(); //파일을 읽기 위한 FileReader객체 생성
		 reader.onload = function (e) {
			 //파일 읽어들이기를 성공했을때 호출되는 이벤트 핸들러
	         $('#imgPreThumb').attr('src', e.target.result);
	         //이미지 Tag의 SRC속성에 읽어들인 File내용을 지정
	     }                   
	     reader.readAsDataURL(input.files[0]);
	     //File내용을 읽어 dataURL형식의 문자열로 저장
	 }
}

// 다국어 팝업
function callDicPop(){
	
	var option = {
			lang : lang,
			popupTargetID: 'setDictionary',
			hasTransBtn : 'true',
			allowedLang : 'ko,en,ja,zh,lang1',
			useShort : 'false',
			dicCallback : 'dicCallback',
			init : 'dicInit',
			openerID: openLayerName
	};
	
	var url = "";
	url += "/covicore/control/calldic.do?lang=" + option.lang;
	url += "&hasTransBtn=" + option.hasTransBtn;
	url += "&popupTargetID=" + option.popupTargetID;
	url += "&useShort=" + option.useShort;
	url += "&dicCallback=" + option.dicCallback;
	url += "&allowedLang=" + option.allowedLang;
	url += "&init=" + option.init;
	url += "&openerID=" + option.openerID;
	
	parent.Common.open("","setDictionary","<spring:message code='Cache.lbl_MultiLangSet'/>|||<spring:message code='Cache.msg_MultilanguageSettings'/>",url, "400px", "300px", "iframe", true, null, null, true);
} 

function dicCallback(dicData){
	var multiLangData = coviDic.convertDic(JSON.parse(dicData));
	document.getElementById("hidNameDicInfo").value = multiLangData;
	document.getElementById('equipmentName').value = CFN_GetDicInfo(multiLangData, lang)
}

function dicInit(){
	var value;
	
	if(document.getElementById("hidNameDicInfo").value == ''){
		//value = encodeURIComponent(document.getElementById('equipmentName').value);
		value = document.getElementById('equipmentName').value;
	}else{
		//value = encodeURIComponent(document.getElementById("hidNameDicInfo").value);
		value = document.getElementById("hidNameDicInfo").value;
	}
	
	return value;
}

function setEquipmentNameDic(){
	  var sDictionaryInfo = document.getElementById("hidNameDicInfo").value;
	    if (sDictionaryInfo == "") {
	        switch (Common.getSession("lang").toUpperCase()) {
	            case "KO": sDictionaryInfo = document.getElementById("equipmentName").value + ";;;;;;;;;"; break;
	            case "EN": sDictionaryInfo = ";" + document.getElementById("equipmentName").value + ";;;;;;;;"; break;
	            case "JA": sDictionaryInfo = ";;" + document.getElementById("equipmentName").value + ";;;;;;;"; break;
	            case "ZH": sDictionaryInfo = ";;;" + document.getElementById("equipmentName").value + ";;;;;;"; break;
	            case "E1": sDictionaryInfo = ";;;;" + document.getElementById("equipmentName").value + ";;;;;"; break;
	            case "E2": sDictionaryInfo = ";;;;;" + document.getElementById("equipmentName").value + ";;;;"; break;
	            case "E3": sDictionaryInfo = ";;;;;;" + document.getElementById("equipmentName").value + ";;;"; break;
	            case "E4": sDictionaryInfo = ";;;;;;;" + document.getElementById("equipmentName").value + ";;"; break;
	            case "E5": sDictionaryInfo = ";;;;;;;;" + document.getElementById("equipmentName").value + ";"; break;
	            case "E6": sDictionaryInfo = ";;;;;;;;;" + document.getElementById("equipmentName").value; break;
	            default : sDictionaryInfo = document.getElementById("equipmentName").value+ ";;;;;;;;;"; break;
	        }
	        document.getElementById("hidNameDicInfo").value = sDictionaryInfo
	    }
}

//저장
function saveEquipment(){

    if(!fileuploadBeforeCheck()){
    	return false; 
    }
    
    if(!Validation()){
    	return false;
    }

	setEquipmentNameDic();
	
	var url;
	
	var formData = new FormData();
	formData.append('equipmentID', equipmentID);
	formData.append('equipmentName',$("#hidNameDicInfo").val());
	formData.append('sortKey', $("#sortKey").val());
	formData.append('isUse', $("#isUseSelectBox").val());
	formData.append('domainID', $("#companySelectBox").val());
	formData.append('thumbnail', $('#thumbnail')[0].files[0]);
	
	if(equipmentID!=0){			
		url = "/groupware/resource/modifyEquipmentData.do";			
	}else{
		url = "/groupware/resource/saveEquipmentData.do";
	}
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
	            		if(parent.equipmentGrid != undefined){parent.equipmentGrid.reloadList();}
						Common.Close();
	            	});
            	}else{
            		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");  /*오류가 발생했습니다. */
            	}
            },
            error:function(response, status, error){
                CFN_ErrorAjax(url, response, status, error);
            }
        });
	
}

function fileuploadBeforeCheck() {
    var file = document.getElementById("thumbnail");
    
    if(file.files.length<=0){
    	return true;
	}else if (file.files.item(0).name.length > 20) {
        Common.Warning("<spring:message code='Cache.lbl_apv_warning_filename'/>");  /*파일명은 20글자 미만으로 해주세요. */
        return false;
    }else if (file.files.item(0).size > 512000) {
    	Common.Warning("<spring:message code='Cache.lbl_apv_warning_filesize'/>");  /*피일크기는 500kb를 넘을 수 없습니다.*/
        return false;
    }else {
        return true;
    }
}

// 입력값 체크
function Validation() {
	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

    if( $("#equipmentName").val() == ""){
        Common.Warning("<spring:message code='Cache.msg_272'/>");   	/*장비명을 입력하여 주십시오.*/
        $("#equipmentName").focus();
        return false;
    }else if ( $("#sortKey").val()  == "") {
        Common.Warning("<spring:message code='Cache.msg_Common_02'/>");   	/* 우선순위를 입력하여 주십시오. */
        $("#sortKey").focus();
        return false;
    }else {
        return true;
    }
}

//숫자 체크
function ckNaN(val) {
	var retVal = 0;
	
	if(isNaN(val)) {
		retVal = 0;
	} else {
		retVal = Number(val);	
	}
	
	return retVal;
}

// 숫자 외 입력값 처리
function toNumFormat() {
	var val = $("#sortKey").val();
	if(val != undefined) {
		$("#sortKey").val(ckNaN(val.replace(/[^0-9]/g, "")));
	}
}

</script>