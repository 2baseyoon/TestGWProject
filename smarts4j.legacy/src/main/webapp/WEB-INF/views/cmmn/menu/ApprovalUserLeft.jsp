<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class='cLnbTop'>
	<h2><spring:message code='Cache.lbl_apv_approval'/></h2> <!-- 전자결재  -->
	<div><a onclick="CoviMenu_GetContent('/approval/layout/approval_FormList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval');" class='btnType01 '><spring:message code='Cache.lbl_approval_writeApv'/></a></div> <!-- 결재작성  -->
</div>
<div class='cLnbMiddle mScrollV scrollVType01 '>
	<div >
		<ul id="leftMenu" class="contLnbMenu approvalMenu">
		</ul>
	</div>
</div>
<script type="text/javascript">
	//# sourceURL=SurveyUserLeft.jsp
	
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	
	var jobfunctionCnt = 0;
	var BizDocListCnt = 0;
	var mode = '${approvalPage}';
	
	initLeft();
	setDocreadCount();
	
	function initLeft(){
		
		// 스크롤
		coviCtrl.bindmScrollV($('.mScrollV'));
		
		var opt = {
    			lang : "ko",
    			isPartial : "true"
    	};
    	var coviMenu = new CoviMenu(opt);
    	
    	if(leftData.length != 0){
    		coviMenu.render('#leftMenu', leftData, 'userLeft');
    	}
    	if(loadContent == 'true') {
			//CoviMenu_GetContent('/approval/layout/approval_Home.do?CLSYS=approval&CLMD=user&CLBIZ=Approval'); 
			
    		if(mode==''|| mode==null)
    		{
    			CoviMenu_GetContent('/approval/layout/approval_Home.do?CLSYS=approval&CLMD=user&CLBIZ=Approval');
    		}
    		else{//mode 파라메터 전달 시 해당 페이지로 이동.
    			CoviMenu_GetContent('/approval/layout/approval_ApprovalList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode='+mode);
    		}
    	}
    	
    	// 메뉴 숨기기
    	getJobFunctionCount();
		getBizDocListCount();
    	if(jobfunctionCnt <= 0)
			$("[data-menu-alias=JobFunction]").hide();
		
		if(BizDocListCnt <= 0)
			$("[data-menu-alias=BizDoc]").hide();
	}
	
	$("#leftMenu > li .selOnOffBox").on('click',function(){		
		var $selEle 	= 	$(this).parent();
		var $onOff 		= 	$('div:eq(0)',$selEle);
		var $boxList 	= 	$('div:eq(1)',$selEle);
		var isClass		=	$('> a',$onOff).hasClass('active');		
		!isClass 	&& $('> a',$onOff).addClass('active') && $boxList.addClass('active');
		isClass 	&& $('> a',$onOff).removeClass('active') && $boxList.removeClass('active');		
	}).eq(0).trigger('click');
	
	
	
	function getJobFunctionCount(){
		$.ajax({
			type:"POST",
			url:"/approval/user/getJobFunctionCount.do",
			data:{
				JobFunctionType:"APPROVAL"
			},
			async: false, //jobfunctionCnt 값이 설정 안된 채로 메뉴목록을 그리는 현상 방지
			success:function (data) {
				if(data.result=="ok"){
					jobfunctionCnt = data.cnt;
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("user/getJobFunctionCount.do", response, status, error);
			}
		});
	}

	function getBizDocListCount(){
		$.ajax({
			type:"POST",
			url:"/approval/user/getBizDocCount.do",
			async: false, //BizDocListCnt 값이 설정 안된 채로 메뉴목록을 그리는 현상 방지
			success:function (data) {
				if(data.result=="ok"){
					BizDocListCnt = data.cnt;
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("user/getBizDocCount.do", response, status, error);
			}
		});
	}
</script>

