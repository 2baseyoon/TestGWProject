<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop portalMyContentPopCont">
	<div class="">
		<div class="top scrollVType01">						
			<ul id="webpartListUL" class="pMyContentChkList clearFloat" ></ul>
		</div>
		<div class="bottom ">
			<a class="btnTypeDefault btnTypeBg" onclick="saveSetting(); return false;"><spring:message code='Cache.lbl_Save'/></a>
			<a class="btnTypeDefault " onclick="javascript:Common.Close(); return false;"><spring:message code='Cache.lbl_close'/></a>
		</div>
	</div>
</div>

<script>
	var oldWebpartArr = CFN_GetQueryString("webpartArr").split("-");
	var contentsMode = CFN_GetQueryString("contentsMode") == "undefined" ? "MyContents" : CFN_GetQueryString("contentsMode");
	
	//ready 
	init();
	
	function init(){
		var listHTML = ''
		$.each(${webpartList}, function(idx, obj){
			listHTML += '<li>'
			listHTML += '	<div class="chkStyle04  chkType01">';
			listHTML += '		<input type="checkbox" id="webpart'+obj.WebpartID+'" value="' +obj.WebpartID +'" '+(oldWebpartArr.includes(obj.WebpartID+"") ? "checked='checked'" : "" )+'>';
			listHTML += '		<label for="webpart'+obj.WebpartID+'" title="' +  obj.DisplayName + '"><span></span>' + obj.DisplayName + '</label>';
			listHTML += '	</div>';
			listHTML += '</li>';
		});
		

		$("#webpartListUL").html(listHTML);
		$(".portalMyContentPopCont .top").mCustomScrollbar({
			mouseWheelPixels: 50, scrollInertia: 350
		});
		
	}
	
	function saveSetting(){
		var saveWebpartArr = new Array();
		
		var newWebpartArr = new Array(); 
		$("#webpartListUL").find("input[type='checkbox'][id^='webpart']:checked").each(function(idx,obj){
			newWebpartArr.push(obj.value);
		});
		
		$.each(oldWebpartArr, function(idx, obj){
			if(newWebpartArr.includes(obj)){
				saveWebpartArr.push(obj);
				newWebpartArr.splice(newWebpartArr.indexOf(obj), 1);
			}
		});
		
		saveWebpartArr = saveWebpartArr.concat(newWebpartArr);
		
		$.ajax({
			url: "/groupware/mycontents/saveMyContentsSetting.do",
			type:"post",
			data: {
				webparts: saveWebpartArr.join("-"),
				contentsMode: contentsMode
			}, 
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
		    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){	/*저장되었습니다.*/
		    			Common.Close();
		    			parent.myContents.init();
		    		});
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
	    	}, 
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/mycontents/saveMyContentsSetting.do", response, status, error);
	    	}
		});
		
	}
	
	
</script>
