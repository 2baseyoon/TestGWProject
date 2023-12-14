<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<style type="text/css">
	#pathArea > li{
		width:100%;
		overflow:hidden;
		text-overflow:ellipsis;
		white-space:nowrap;
	}
</style>

<div class="layer_divpop ui-draggable" id="testpopup_p" style="width:700px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent">
			<div class="subscriptionLayerPopContent">
				<div class="top">
					<div class="clearFloat subPopContent">
						<div>
							<ul class="subscriptionMenuList">
								<li class="subscriptionMenu01"><a onclick="getFolderList('Board')"><spring:message code="Cache.lbl_Boards"/></a></li>
								<li class="subscriptionMenu02"><a onclick="getFolderList('Schedule')"><spring:message code="Cache.lbl_schedule_title"/></a></li>
<!-- 								<li class="subscriptionMenu03"><a>문서관리</a></li> -->
							</ul>
						</div>
						<div class="subscriptionAddListCont">
							<ul id="pathArea" class="subscriptionAddList">
<!-- 								<li>
										<span>전자게시</span>
										<span class="arrowPoint">></span>
										<strong class="colorTheme">경조사</strong>
										<a class="btnXClose "></a>
									</li> -->
<!-- 								<li><span>통합게시 분류</span><span class="arrowPoint">></span><span>공지</span><span class="arrowPoint">></span><strong class="colorTheme">CEO 메세지</strong><a class="btnXClose "></a></li> -->
<!-- 								<li><span>부서게시</span><span class="arrowPoint">></span><span>연구1팀</span><span class="arrowPoint">></span><strong class="colorTheme">자료실</strong><a class="btnXClose "></a></li>									 -->
							</ul>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<script>
var subscriptionList = [];	//구독목록 전체 조회
var serviceType = '';

function renderFolderData(pSubscriptionID, pFolderName, pFolderPath){
	var liPath = $('<li/>');
// 	var pathList = board.getFolderPath(pFolderPath);	//FolderPath에 해당하는 Folder 이름 조회
	var pathList = pFolderPath.split(";");
	
	if(typeof pathList != 'undefined' && pathList.length > 0){
// 		if(pathList.length > 3){		//게시판이 3 depth 이상일때 압축하여 표시, 전체 경로는 tooltip으로 표시하도록 attribute로 추가
// 			liPath.append(String.format("<span>{0}</span><span class='arrowPoint'>></span>", pathList[0]));
// 			liPath.append(String.format("<span>{0}</span><span class='arrowPoint'>></span>", '...'));
// 		} else {
		$.each(pathList, function(i, item){
			liPath.append(String.format("<span>{0}</span><span class='arrowPoint'>></span>", pathList[i]));
			if(pathList.length-2 == i) return false;
		});
		liPath.append(String.format("<strong class='colorTheme'>{0}</strong>", pFolderName));
		liPath.append($('<a class="btnXClose" onclick="javascript:deleteSubscription(' + pSubscriptionID + ')"></a>'));
// 		}

		var tooltip = '';
		$.each(pathList, function(i, item){
			tooltip += String.format("{0}>", pathList[i]);
		});
		tooltip = tooltip.substring(0, tooltip.length-1);
		liPath.attr("title", tooltip);
		
		if(liPath.text().length > 30) liPath.find('span:nth-child(odd)').not('span:nth-child(1)').text('...');
		
		$('#pathArea').append(liPath);
	}
}

function getFolderList( pServiceType ){		//pServiceType: Board, Schedule
	//서비스 타입에 따라 조회된 리스트에서 필터처리
	var filterList = $.grep(subscriptionList, function(item){ return item.TargetServiceType == pServiceType });
	serviceType = pServiceType;		//조회시 사용된 service type 값 설정
	
	$("#pathArea").html("");		//폴더 목록 초기화
	$.each(filterList, function(i, item){
		renderFolderData(item.SubscriptionID, item.FolderName, item.FolderPath);
	});
}

function deleteSubscription(pSubscroptionID){
	Common.Confirm("<spring:message code='Cache.msg_deleteSubscriptionConfirm'/>", 'Confirmation Dialog', function (result) {
        if (result) {
			$.ajax({
		    	type:"POST",
		    	url:"/covicore/subscription/deleteFolder.do",
		    	async:false,
		    	data:{
		        	'subscriptionID': pSubscroptionID
		    	},
		    	success:function(data){
		        	if(data.status == 'SUCCESS'){
		        		subscriptionList = coviCtrl.getSubscriptionFolderList();
		        		Common.Warning("<spring:message code='Cache.msg_50'/>");		//삭제됐습니다.
		        		getFolderList(serviceType);
		            } else {
		            	Common.Warning("<spring:message code='Cache.msg_apv_030'/>");	//오류가 발생헸습니다.
		            }
		    	},
		    	error:function(response, status, error){
		    	     CFN_ErrorAjax("/covicore/subscription/deleteSubscription.do", response, status, error);
		    	}
		    });
        }
	});
}

function deleteAllServiceData(){
	Common.Confirm("<spring:message code='Cache.msg_deleteAllSubscriptionConfirm'/>", 'Confirmation Dialog', function (result) {
        if (result) {
			$.ajax({
		    	type:"POST",
		    	url:"/covicore/subscription/deleteFolder.do",
		    	async:false,
		    	data:{
		        	'targetServiceType': serviceType
		    	},
		    	success:function(data){
		        	if(data.status == 'SUCCESS'){
		        		subscriptionList = coviCtrl.getSubscriptionFolderList();
		        		Common.Warning("<spring:message code='Cache.msg_50'/>");		//삭제됐습니다.
		        		getFolderList(serviceType);
		            } else {
		            	Common.Warning("<spring:message code='Cache.msg_apv_030'/>");	//오류가 발생헸습니다.
		            }
		    	},
		    	error:function(response, status, error){
		    	     CFN_ErrorAjax("/covicore/subscription/deleteSubscription.do", response, status, error);
		    	}
		    });
        }
	});
}

$(document).ready(function(){
	subscriptionList = coviCtrl.getSubscriptionFolderList();
	//getSubscriptionFolderList();
	//첫번째 서비스 항목 선택
	getFolderList('Board');
})

</script>