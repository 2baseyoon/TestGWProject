<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="staffNews_popup" style="padding:20px 0 20px 45px">
	<div class="bodysearch_Type01" style="marginLeft:10px">
		<div class="inPerView type07">
			<div style="width:745px;">
				<div class="inPerTitbox">
					<select class="selectType02" id="selMode" onchange="getListEmpPop(1)">
						<option value="ALL"><spring:message code='Cache.btn_All'/></option>
					</select>
				</div>
				<div class="inPerTitbox_right">
					<div class="inPerTitbox">
						<select class="selectType02" id="searchKind">
							<option value="Name"><spring:message code='Cache.lbl_FirstName'/></option>
						</select>
						<input type="text" style="width:200px;" id="SearchName" onkeypress="if (event.keyCode==13){ getListEmpPop(1); return false; }">							
					</div>
					<a href="javascript:getListEmpPop(1)" class="btnTypeDefault btnSearchBlue "><spring:message code='Cache.lbl_search'/></a>
				</div>
			</div>						
		</div>
	</div>
	<div class="staffNews_popup_list_wrap">
		<div class="staffNews_popup_list">
			<ul class="clearFloat stafList"  id="stafListUL" style="padding:0">
			</ul>							
			<div class="table_paging" id="empPaging"><!-- 버튼 클래스 paging_begin, paging_prev, paging_next, paging_end 비활성화 시 class="dis" 추가 -->				
			</div>
		</div>			
	</div>
</div>

<script>

var straddinterval = CFN_GetQueryString("addinterval") == 'undefined' ? '0' : CFN_GetQueryString("addinterval");
var strBirthMode = CFN_GetQueryString("birthMode") == 'undefined' ? 'D' : CFN_GetQueryString("birthMode");
var strEnterInterval = CFN_GetQueryString("enterInterval") == 'undefined' ? '14' : CFN_GetQueryString("enterInterval");
var strJobMode = CFN_GetQueryString("jobMode") == 'undefined' ? 'level' : CFN_GetQueryString("jobMode");
var strVacationMode = CFN_GetQueryString("vacationMode") == 'undefined' ? 'Y' : CFN_GetQueryString("vacationMode");

init();
function init(){
	getListEmpPop(1);
	initNoticeType();
	Common.getDicList(["lbl_Employees","lbl_news","lbl_Birthday","lbl_New_Recruit","lbl_Promotion","lbl_FirstBirthday","lbl_Marriage","lbl_Vacation"]);
}

var totCount = 0;
var curPage = 1;

function getListEmpPop(mPage){
	
	var profilePath = Common.getBaseConfig("ProfileImagePath").replace("{0}", Common.getSession("DN_Code"));
	var paging =  parseInt( (mPage-1) * 20  );
	
	curPage = mPage;
	
	$.ajax({
		url: "/groupware/portal/getEmployeesNoticeList.do",
		type:"post",
		data: {
			"selMode": $("#selMode").val(),
			"page": paging,
			"searchName":$("#SearchName").val(),
			"addinterval" : straddinterval,
			"birthMode" : strBirthMode,
			"enterInterval" : strEnterInterval,
			"vacationMode" : strVacationMode
		}, 
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			var sHTML = "";
         		if(data.employeesList.Count > 0){
         			
     				totCount = data.employeesList.Count;
    				Paging(totCount, 20, 5, curPage);
    				$.each( data.employeesList.list, function(index, obj) {
    					var classObj = getClassKind(obj);
    					var strJob = obj.JobLevelName;
						if (strJobMode == "position") strJob = obj.JobPositionName;
						else if (strJobMode == "title") strJob = obj.JobTitleName;
						
						var strDate = obj.Date.replaceAll('-', '.');
						if (obj.Type == "Birth") strDate = strDate.substring(5);
    					
    					sHTML += '<li class="'+ classObj.Class+'">'
						+ '<div class="flowerPopup" data-user-code="' + obj.UserCode + '" data-user-mail="'+ obj.MailAddress +'">'
						+ '<a class="btnFlowerName">'
						+ '<span class="stfIcon colorTheme"><strong>' + classObj.Name + '</strong></span>'
						+ '<span class="staffPhoto"><img src="' + coviCmn.loadImage(profilePath + obj.UserCode + '.jpg') +'" alt="프로필사진" onerror="coviCmn.imgError(this);" ></span>'
						+ '<span class="staffName">' +obj.UserName + ' ' +  strJob + '</span>'
						+ '<span class="date">' + strDate  + '</span>'
						+ '</a>'

						+   '</div>'
						+	'</li>';
    					
    				});
             		$('#empPaging').show();
     			}	
     			else {
     				totCount = 0;
     				sHTML = '<div class="tdRelBlock"><div align="center" class="bodyNode bodyTdText">'+ Common.getDic("msg_NoDataList")+'</div></div>';
             		$('#empPaging').hide();
     			}
    			$("#stafListUL").html(sHTML);
	    		
    		}else{
    		}
    	}, 
    	error:function(response, status, error){
    	     CFN_ErrorAjax("/groupware/portal/getEmployeesNoticeList.do", response, status, error);
    	}
	});
	
}

function getClassKind(eventObj){
	var oType = new Object();
	
	switch(eventObj.Type){
		case 'Birth': //생일
			oType["Class"] ="birthday";
			oType["Name"] = coviDic.dicMap["lbl_Birthday"];
			break;
		case 'Enter'://신규 입사
			oType["Class"] ="newJoin";
			oType["Name"] = coviDic.dicMap["lbl_New_Recruit"];
			break;
		case 'Vacation'://휴가
			oType["Class"] ="newJoin";
			oType["Name"] = coviDic.dicMap["lbl_Vacation"];
			break;
		case 'Vacation_off'://반차
			oType["Class"] ="newJoin";
			oType["Name"] = coviDic.dicMap["lbl_Vacation_off"];
			break;
		default:
			var $eventCodeData = $$(Common.getBaseCode("eventType")).find('CacheData[Code='+eventObj.Type+']');
			
			if(eventObj.Type.indexOf("VACATION")> -1){
				oType["Class"] ="newJoin";
				oType["Name"] = CFN_GetDicInfo($$(Common.getBaseCode("VACATION_TYPE")).find("CacheData[Code="+eventObj.Type+"]").attr("MultiCodeName"));
			}else if($eventCodeData.length > 0){
				if($eventCodeData.attr("Code") != "condolence" && $eventCodeData.attr("Code") != ""){
					oType["Class"] = $eventCodeData.attr("Code");
				}else{
					oType["Class"] = "newJoin";
				}
				oType["Name"] = CFN_GetDicInfo($eventCodeData.attr("MultiCodeName"));
			}else {
				oType["Class"] ="";
				oType["Name"] ="";
			}
			break;
	}
	
	return oType;
}

$('body').on('click', '.btnFlowerName', function(){
		
	//이벤트 호출시 flowerPopup내부 Context Menu 태그 생성
	 if($(this).closest('.flowerPopup').find('.flowerMenuList').size() == 0){
		 
		$(this).closest('.flowerPopup').coviCtrl('setUserInfoContext');
	} 
	sibNode = $(this).closest('.flowerPopup').find('.flowerMenuList');
	
	if(sibNode.hasClass('active')){
		sibNode.removeClass('active');
	}else {
		$('.flowerMenuList').removeClass('active');
		sibNode.addClass('active');
	}
});

function Paging(totalCnt, dataSize, pageSize, pageNo){ 
	totalCnt = parseInt(totalCnt);// 전체레코드수 	
	dataSize = parseInt(dataSize); // 페이지당 보여줄 데이타수 
	pageSize = parseInt(pageSize); // 페이지 그룹 범위 1 2 3 5 6 7 8 9 10 
	pageNo = parseInt(pageNo); // 현재페이지
	
	var html = new Array(); 
	if(totalCnt == 0){ return ""; } 
	
	// 페이지 카운트	
	var pageCnt = totalCnt % dataSize; 
	if(pageCnt == 0){ 
		pageCnt = parseInt(totalCnt / dataSize); 
	} else { 
		pageCnt = parseInt(totalCnt / dataSize) + 1; 
	} 
	
	var pRCnt = parseInt(pageNo / pageSize); 
	if(pageNo % pageSize == 0){ 
		pRCnt = parseInt(pageNo / pageSize) - 1; 
	} 
	

	
	//이전 화살표
	if(pageNo > pageSize){ 
		var s2; 
		if(pageNo % pageSize == 0){ 
			s2 = pageNo - pageSize; 
		}else{ 
			s2 = pageNo - pageNo % pageSize; 
		}		
		html.push('<input type="button" class="paging_begin" onclick="getListEmpPop(1)"><input type="button" class="paging_prev" onclick="getListEmpPop('+s2+')">');
	} else { 
		if (pageNo != pageCnt){
			var s2 = pageNo -1 ;
			html.push('<input type="button" class="paging_begin"  onclick="getListEmpPop(1)"><input type="button" class="paging_prev" onclick="getListEmpPop('+s2+')">');
		} else {
			html.push('<input type="button" class="paging_begin"  onclick="getListEmpPop(1)"><input type="button" class="paging_prev" onclick="getListEmpPop(1)">');
		}
	} 
	
	//paging Bar	
	for(var index=pRCnt * pageSize + 1;index<(pRCnt + 1)*pageSize + 1;index++){ 
		if(index == pageNo){ 
			html.push('<input class="paging selected" type="button" value="'+index+'">');  
		} else { 
			html.push('<input class="paging" type="button" value="'+index+'" onclick="getListEmpPop('+index+')">');
		} 
		if(index == pageCnt){ break; }
	} 
	
	//다음 화살표	
	if(pageCnt > (pRCnt + 1) * pageSize){ 	
		var e1 = (pRCnt + 1) * pageSize+1;
		
		html.push('<input type="button" class="paging_next" onclick="getListEmpPop('+e1+')"><input type="button" class="paging_end" onclick="getListEmpPop('+pageCnt+')"> ');
	} else { 
		if (pageNo != pageCnt){
			var e1 = pageNo +1;
			html.push('<input type="button" class="paging_next"  onclick="getListEmpPop('+e1+')"><input type="button" class="paging_end" onclick="getListEmpPop('+pageCnt+')">');
		}else {
			html.push('<input type="button" class="paging_next" onclick="getListEmpPop('+pageCnt+')"><input type="button" class="paging_end" onclick="getListEmpPop('+pageCnt+')">');
		}
	} 
	
	$("#empPaging").html( html.join(""));
	
	
}

function initNoticeType(){
	var noticeType = Common.getBaseCode('EmployeesNotice');
	var lang = Common.getSession('lang');
	$.each(noticeType.CacheData, function(idx, el){
		if(el.CodeName != null && el.CodeName != ''){
			$("#selMode").append('<option value="'+el.Code+'">' + CFN_GetDicInfo(this.MultiCodeName, lang) + '</option>');
		}
	});
}

</script>

