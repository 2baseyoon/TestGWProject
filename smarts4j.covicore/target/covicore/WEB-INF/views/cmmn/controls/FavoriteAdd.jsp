<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<jsp:include page="/WEB-INF/views/cmmn/PopupInclude.jsp"></jsp:include>

<div class="commNoticePopContainer" id="noticePopContainer">
	<div class="middle mt20">
		<div id="addNotificationList"  class="clearFloat noticeListBoxCont">
		</div>
	</div>
	<div class="bottom mt15">
		<div class="noticeSelectCont clearFloat">
			<div>
				<span class="blueStart"><spring:message code='Cache.msg_FavoriteAdd_1'/></span> <!-- 드래그하여 순서를 변경하고, 메뉴를 선택하세요. -->
			</div>
			<div class="notiBtnBox">
				<a class="btnTypeDefault btnTypeChk" onclick="saveUserConf();"><spring:message code='Cache.btn_save'/></a>
				<a class="btnTypeDefault ml5"  onclick="javascript: Common.Close();"><spring:message code='Cache.btn_Cancel'/></a>
			</div>
		</div>
	</div>
</div>

<script  type="text/javascript">
//# sourceURL=FavoriteAdd.jsp

var option = '${option}';
var userConf = '${userQuickConf}';
var lang = Common.getSession("lang");

//ready 
favoriteAddInit();

function favoriteAddInit(){
	setQuickMenuList();
	setClickEvent();
}

//설정 값 바인딩
function setQuickMenuList(){
	var arrQuick = Common.getBaseCode("QuickNotification").CacheData;
	var quickHTML = ''; 

	var arrBizSection =Common.getSession("UR_AssignedBizSection").split("|");
	
	//설정값이 없을 경우
	if(userConf == '' || userConf == 'null' || userConf == '{}'){
			$.each(arrQuick, function (idx,obj){
				if (arrBizSection.indexOf(obj.BizSection) > -1){
					quickHTML += '<div class="noticeListBox ' +obj.Reserved2 + '" code="'+obj.Code +'">';
					quickHTML += '	<a href="#">';
					quickHTML += '		<p><span>' +CFN_GetDicInfo(obj. MultiCodeName, lang) +'</span></p>';
					quickHTML += '		<div class="selOverBg noticeSelectCont"></div>';
					quickHTML += '	</a>';
					quickHTML += '</div>';
				}	
			});	
	}else{
		var oConf = $.parseJSON(userConf);
		var orderQuick = oConf.Order.split(";");
		
		$.each(orderQuick, function(idx, confObj){
			$.each(arrQuick, function(idx,quickObj){
				if(arrBizSection.indexOf(quickObj.BizSection) > -1 && quickObj.Code == confObj){
					quickHTML += '<div class="noticeListBox ' +quickObj.Reserved2 + '" code="'+quickObj.Code +'">';
					quickHTML += 	(oConf[quickObj.Code] == "Y") ? '<a  href="#" class="active">'  : '<a>';
					quickHTML += '		<p><span>' +CFN_GetDicInfo(quickObj. MultiCodeName, lang) +'</span></p>';
					quickHTML += '		<div class="selOverBg noticeSelectCont"></div>';
					quickHTML += '	</a>';
					quickHTML += '</div>';
					
					arrQuick.splice(idx,1); 
					
					return false;
				}
			});
		});
		
		//추가된 항목 추가
		$.each(arrQuick, function(idx,quickObj){
			if (arrBizSection.indexOf(quickObj.BizSection) > -1){
				quickHTML += '<div class="noticeListBox ' +quickObj.Reserved2 + '" code="'+quickObj.Code +'">';
				quickHTML += 	'<a href="#">';
				quickHTML += '		<p><span>' +CFN_GetDicInfo(quickObj. MultiCodeName, lang) +'</span></p>';
				quickHTML += '		<div class="selOverBg noticeSelectCont"></div>';
				quickHTML += '	</a>';
				quickHTML += '</div>';
			}	
		});
	}
	
	
	$("#addNotificationList").html(quickHTML);
	
	Common.toResizeDynamic("FavoriteAdd", "noticePopContainer");
}

//설정값을 JSON 으로 Return
function getQuickMenuConf(){
	var configObj = new Object();
	
	var order = '';
	var showList = '';
	
	$("#addNotificationList").children("div").each(function(idx,obj){
		var Code = $(obj).attr("code");
		var IsUse = $(obj).children("a").hasClass("active") ? "Y" : "N";
		if(IsUse == "Y"){
			showList += ( Code +';' ); 
		}
		order += ( Code +';' ); 
		
		configObj[Code] = IsUse;
	});
	
	configObj["ShowList"] = showList;  //실제 보여지는 목록
	configObj["Order"] = order; //설정 순서
	
	return configObj;
}

//저장
function saveUserConf(){
	 $.ajax({
	    	type:"POST",
	    	url: "/covicore/quick/updateUserConf.do",
	    	data:{
	    		"configObj" : JSON.stringify(getQuickMenuConf())
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			/*저장되었습니다.*/
		    		Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){
		    			parent[$.parseJSON(option).callback]();
		    			Common.Close();
		    		});
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
	    	}, 
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax(url, response, status, error);
	    	}
	    });
}

//알림 체크 설정 팝업 지정
function setClickEvent(){
	$('.noticeListBox>a').click(function(e){
		e.preventDefault();
		if(!$('.commNoticePopContainer').hasClass('oder')){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
			}else {
				$(this).addClass('active');
			}
		}
	});
	
	$( "#addNotificationList" ).sortable(); //드래그 앤 드롭
}

</script>
