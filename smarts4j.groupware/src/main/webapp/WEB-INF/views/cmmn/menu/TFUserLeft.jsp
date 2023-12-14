<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cLnbTop">
	<h2 onclick="goMain();" style="cursor: pointer;"><spring:message code='Cache.MN_972' /></h2><!-- T/F 팀룸 -->
	<div class="selectBox lnb">
		<select class="selectType02" id="selectJoinTFTeamRoom"></select>
	</div>
</div>
<div class="cLnbMiddle mScrollV scrollVType01">
	<div id="mCSB_2" class="mCustomScrollBox mCS-light mCSB_vertical mCSB_inside" style="max-height: none;" tabindex="0">
		<div id="mCSB_2_container" class="mCSB_container mCS_y_hidden mCS_no_scrollbar_y" style="position: relative; top: 0px; left: 0px;" dir="ltr">
			<div>
				<ul id="leftmenu" class="contLnbMenu TFTeamRoom"></ul>
			</div>
		</div>
		<div id="mCSB_2_scrollbar_vertical" class="mCSB_scrollTools mCSB_2_scrollbar mCS-light mCSB_scrollTools_vertical" style="display: none;">
			<a href="#" class="mCSB_buttonUp" oncontextmenu="return false;" style="display: block;"></a>
			<div class="mCSB_draggerContainer">
				<div id="mCSB_2_dragger_vertical" class="mCSB_dragger" style="position: absolute; min-height: 30px; display: block; max-height: 271px; height: 0px; top: 0px;" oncontextmenu="return false;">
					<div class="mCSB_dragger_bar" style="line-height: 30px;"></div>
				</div>
				<div class="mCSB_draggerRail"></div>
			</div>
			<a href="#" class="mCSB_buttonDown" oncontextmenu="return false;" style="display: block;"></a>
		</div>
	</div>
</div>


<script type="text/javascript">
	//# sourceURL=TFUserLeft.jsp
	
	var leftData = ${leftMenuData};
	var loadContent = '${loadContent}';
	var g_bizSection = '<%=request.getParameter("CLBIZ")%>';
	var g_lastURL;
	
	initLeft();
	setEvent();
	
	function initLeft(){
		
		// 스크롤
		coviCtrl.bindmScrollV($('.mScrollV'));
		
		var opt = {
    			lang : "ko",
    			isPartial : "true"
    	};
    	var coviMenu = new CoviMenu(opt);
    	
    	g_lastURL = '/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=' + g_bizSection;
    	
    	if(leftData.length != 0){
    		coviMenu.render('#leftmenu', leftData, 'userLeft');
    		$(".TFTeamRoom01").find("a").removeClass("selected");
    	}
    	if(loadContent == 'true') {
    		CoviMenu_GetContent('/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ='+ g_bizSection);
    		g_lastURL = '/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=' + g_bizSection;
    	}
		
    	$(".selOnOffBox").find('a').click(function () { 		
    		var liname = liname = $(this).parent().parent().attr("class");
    		var cla= $(this).closest('li').find('.selOnOffBoxChk');		
    		if(liname=="TFTeamRoom02" || liname=="TFTeamRoom04"){
    			if(cla.hasClass('active')){
    				cla.removeClass("active");
    				$(this).removeClass("active");
    			}else{
    				cla.addClass("active");
    				$(this).addClass("active");
    			}					
    		}
    	}); 
	}	

	function goMain(){
		CoviMenu_GetContent('/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=' + g_bizSection);
		g_lastURL = '/groupware/layout/TF_TFMainList.do?CLSYS=TF&CLMD=user&CLBIZ=' + g_bizSection;
	}
	
	function setEvent(){
		$("#selectJoinTFTeamRoom").coviCtrl(
			"setSelectOption", 
			"/groupware/layout/selectUserJoinTF.do",
			{},
			"내가 가입한 프로젝트룸",
			""
		);
		
		$("#selectJoinTFTeamRoom").change(function(){
			if($("#selectJoinTFTeamRoom").val() != "" ){
				 var specs = "left=10,top=10,width=1050,height=900";
				 specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
				 //window.open("/groupware/layout/userTF/TFMain.do?C="+$("#selectJoinTFTeamRoom").val(), "TF"+$("#selectJoinTFTeamRoom").val(), specs);
				 window.open("/groupware/layout/userCommunity/communityMain.do?C="+$("#selectJoinTFTeamRoom").val(), "community"+$("#selectJoinTFTeamRoom").val(), specs);	 
				 $("#selectJoinTFTeamRoom").val("");	//커뮤니티 팝업 호출 이후 초기 값으로 재설정
			}
		});
	}
</script>

