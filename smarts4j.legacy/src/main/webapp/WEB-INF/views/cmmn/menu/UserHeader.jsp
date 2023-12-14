
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil" %>
<%@ page import="java.net.URLEncoder" %>
<%
	String key = "";
	String resourceVersion = PropertiesUtil.getGlobalProperties().getProperty("resource.version", ""); 

	Cookie[] cookies = request.getCookies();

	if (cookies != null) {

		for (int i = 0; i < cookies.length; i++) {
			if ("CSJTK".equals(cookies[i].getName())) {
				session.setAttribute("KEY", cookies[i].getValue());
				key = cookies[i].getValue();
			}
		}
	}
%>
<style id="ConTitleStyle">
	#content .cRConTop{
		display:none !important;
	}
</style>
<div class="btnGnbView">
	<button type='button' class='btnGnb btnSiteMap'>사이트맵보기</button>
	<div id="siteMapCont" class="siteMapCont" >
		<div class="mScrollV scrollVType01">
			<h2 class="cycleTitle"><spring:message code='Cache.lbl_fullService'/></h2>	<!-- 전체서비스 -->
			<div class="todoBtnBox">																			
				<a class="btnTodoOption" onclick="javascript:coviCtrl.callTopMenuManagePopup();return false;">옵션</a>
				<a class="btnXCloseType02 btnSiteMap">닫기</a>
			</div>
			<div id="totalSiteMap" class="allServiceMenu clearFloat mt20">
				<div class="allServiceCont"></div>
				<div class="allServiceCont"></div>
				<div class="allServiceCont"></div>
				<div class="allServiceCont"></div>
				<!-- 전체 메뉴 -->
				<!-- 사이트 링크 -->
			</div>
			<h2 class="cycleTitle mt25"><spring:message code='Cache.lbl_favoriteMenu'/></h2>
			<ul class="favoriteSiteMenu clearFloat mt10">
				<!-- 즐겨찾기 메뉴 -->
			</ul>						
		</div>
	</div>
</div>
<h1 class="logo">
	<a id="anchorLogo" href="/groupware/portal/home.do?CLSYS=portal&CLMD=user&CLBIZ=Portal"></a>
</h1>
<nav class="hGnb">
	<ul id="topmenu" class="gnb clearFloat on"></ul>
</nav>
<div class="topMenuCont clearFloat">
	<!-- 전체 검색 -->
	 <article class="search_form clearFloat" id="artSearchFrom" style="display:none;">
		<div class="search_formInp">
			<input type="text" id="txtPortalUnifiedSearch" placeholder="Search" class="inp_Search" />
			<button type="button" class="btnComSearch" onclick="javascript:XFN_PortalUnifiedSearch();return false;"><spring:message code='Cache.btn_search'/></button>
		</div>
	 </article>
	<ul class="topMCcenter clearFloat">
		<li id="btnOrgChart" class="btnOrganizationChart" style="display:none;">
			<a><spring:message code='Cache.lbl_DeptOrgMap'/></a>
			<span class="toolTip1"><spring:message code='Cache.lbl_DeptOrgMap'/></span>		<!-- 조직도 -->
		</li>
		<li  id="btnSimpleWrite" class="btnOrderBusiness"  style="display:none;">
			<a onclick="coviCtrl.toggleSimpleMake();"><spring:message code='Cache.lbl_SimpleMake'/></a>
			<span class="toolTip2"><spring:message code='Cache.lbl_SimpleMake'/></span>		<!-- 간편작성 -->
		</li>
		<li id="gadgetLi" class="btnTopMenuTabCont"  style="display:none;">
			<a class="btnTopMenu">가젯</a>
			<span class="toolTip3"><spring:message code='Cache.lbl_Gadgets'/></span>		<!-- 가젯 -->
			<!-- <span class="countStyle new">4</span> --><!-- 하드코딩 제거 -->	
			<article class="orderBusi">
				<div class="orderContent">
					<div class="oderContCloseBox"><button class="btnOrderContClose">업무지시창 닫기</button></div>
					<div class="orderBusiMenuCont">								
						<ul class="orderTabMenu clearFloat">
							<li class="iconTimeSquare" type="Messenger"><a><span><spring:message code="Cache.lbl_Eum"/></span><!-- <span class="countStyle new ">99</span>--></a></li>
							<li class="iconTodo active" type="Todo"><a><span>To-Do</span><span class="countStyle new"><!-- 99+ --></span></a></li>
							<li class="iconSubscription" type="Subscription"><a><span><spring:message code="Cache.lbl_Subscription"/></span></a></li>
							<li class="iconContact" type="ContactNumber"><a><span><spring:message code="Cache.lbl_Mail_Contact"/></span></a></li>
						</ul>
						<div class="oderTabContent timeSquareTab">
							<!-- 타임스퀘어-->
							<div class="tsTop">
								<select class="selectType02">
									<option>Java 포탈 그룹웨어 기획/개발</option>
								</select>
							</div>
							<!-- inline style 추가 ( 171205 서민주 ) -->
							<div class="oderScrollcont" style="position: absolute;">
								<!--  iframe 삽입 ( 171205 서민주 )-->
								<div>
								  <iframe id="messenger" name="messenger" src='' frameborder='0' style='overflow:hidden;overflow-x:hidden;overflow-y:hidden;height:100%;width:100%;position:absolute;top:0px;left:0px;right:0px;bottom:0px' height='100%' width='100%'>
									<html>
										<head></head>
										<body>
											<div style='font:15px arial, serif;'>
							 					iFrame을 지원하지 않는 브라우저입니다.<br>
						 					</div>
						 				</body>
						 			</html>
								  </iframe>
							  </div>
							</div>
						</div>
						
						<!-- ToDo 시작 -->
						<div class="oderTabContent toDoTab active" id="todoDiv">
						</div>
						<!-- ToDo 끝 -->
						
						<div class="oderTabContent subscriptionTab">
							<div class="subScriptionTop">
								<div class="todoBtnBox">												
									<a href="javascript:;" class="btnRepeatType02" onclick="coviCtrl.getSubscriptionList();">리피트</a>
									<a href="javascript:;" class="btnTodoOption" onclick="coviCtrl.callSubscriptionPopup();return false;">옵션</a>
								</div>
							</div>
							<div id="divSubscriptionList" class="oderScrollcont subscriptionBottom">
								<ul class="subscriptionListCont"></ul>
							</div>
						</div>
						<!-- 연락처 시작 -->
						<div class="oderTabContent contactTab">
							<div class="oderScrollcont" id="contactNumberDiv">
							</div>
						</div>
						<!-- 연락처 끝 -->												
					</div>
				</div>				
			</article>
		</li>
	</ul>
	
	<div id="myInfoContainer" class="myInfo"></div>
	
</div>

<script type="text/javascript">
	function logout() {
		coviCmn.clearLocalCache();
		coviStorage.clear();
		
		location.href = "/covicore/logout.do";
	}
	
	//View
	var myTimer_lo = "";
	var myTimer_lv = "";
	
	//# sourceURL=UserHeader.jsp
	var isConnectServer = false;
	var headerdata = ${topMenuData};
	var myInfoData = ${myInfoData};
	var sibNode='';
	var key = "<%=key%>";
	var resourceVersion = "<%=resourceVersion%>";
	
	var opt = {
			lang : "ko",
			isPartial : "true"
	};
	
	var coviMenu = new CoviMenu(opt);
	coviMenu.render("#topmenu", headerdata, "defaultHorizontal");
	
	
	$(document).ready(function(){
		// menu name --> content title
		if(typeof coviMenu.setContentTitle != "undefined") coviMenu.setContentTitle();
		$("#ConTitleStyle").remove();
		
		if(resourceVersion != ""){
			if(coviStorage.getValue("resourceVersion") == null || coviStorage.getValue("resourceVersion") != resourceVersion){
				//캐시초기화 
				coviCmn.clearCache(false, false);
				coviStorage.setValue("resourceVersion", resourceVersion);
			}
		}
		
    	coviStorage.syncStorage();
        coviStorage.syncLocalBase( "BASE_CONFIG" );

		Common.getBaseConfigList(["usePortalOrgchart", "usePortalSimpleWrite", "usePortalGadget", "usePortalLeft", "sessionExpirationTime", "usePortalEumGadget", "eumServerUrl"]);
		
		var sessionOutPopupTime = coviCmn.configMap.sessionExpirationTime; 
		var redirectAfterTime = 300; //초
		
		var ls_USERID = Common.getSession("USERID");
		$( document ).on( "idle.idleTimer", function(event, elem, obj){
			var sessionLastActiveTime = localStorage.getItem(ls_USERID + "_sessionLastActiveTime");
			var idleTimerLastActiveTime = $.idleTimer("getLastActiveTime");
			
			if(sessionLastActiveTime == idleTimerLastActiveTime) {
				// 현재 브라우저의 LastActive 값이 SessionStorage의 LastActive 값과 일치하면 마지막 Active 브라우저라고 판단하여 세션종료 팝업 호출 그 외일 경우  
				if( $(".layer_dialog[id^=sessionOut]").size() == 0 ){
					coviCmn.sessionOut(Common.getDic("msg_sessionExpire"),  redirectAfterTime ,  coviCmn.continuSession , logout );	 
				}
			} else {
				$.idleTimer("reset");
			}

	    });

		// timer 설정 전 기존 localstorage에 모든 _sessionLastActiveTime 제거
		$.idleTimer( {timeout : ((sessionOutPopupTime == undefined?3600:sessionOutPopupTime) - redirectAfterTime) * 1000, sessionId : ls_USERID});
		
    	coviMenu.renderSiteMap("#totalSiteMap", headerdata);
    	
    	//quick menu set
    	if(coviCmn.configMap.usePortalLeft == "Y"){
	    	coviMenu.drawQuickSet("#quickSetContainer");
    	}
    	
    	if(Common.getBaseConfig("useWorkPortal") == "Y"){
    		// 업무형포탈 오픈
    		$('.btn_work').click(function(){
    			if($('.commContent').hasClass('oh')){
    				$('.commContent').removeClass('oh');
    				$('.work_pop').animate({'right':'-100%'}, 200);
    			}else {
    				$('.commContent').addClass('oh');
    				$('.work_pop').animate({'right':'0'}, 200);
    				if($("#work_portal").html() == ""){    					
	    				$("#work_portal").load("/groupware/layout/workPortal.do");
    				}
    			}
    		});
    	}else{
    		$("#work_portal").hide();
    		$(".btn_work").hide();
    	}

    	if(Common.getBaseConfig("PortalUnifiedSearchUse") == "Y"){
    		// 통합검색사용
    		$('#artSearchFrom').show();
    	}else{
    		$("#artSearchFrom").hide();
    	}   	
    	
		//사이트맵 표시/숨김
    	$('.btnGnb, .btnSiteMap').on('click', function(){
    		if($('.btnGnbView').hasClass('active')){
    			$('.btnGnbView').removeClass('active');
    		}else {
    			$('.btnGnbView').addClass('active');
    			initPortalMenu("Favorite");
    		}				
    	});
    	
		//사이트맵 내부 아이템 선택시 사이트맵 닫기 처리
    	$('.siteMapCont a').on('click',function(){
    		$('.btnGnbView').removeClass('active');
    	});
    	
    	if(coviCmn.configMap.usePortalGadget == "Y"){
    		$("#gadgetLi").show();
    	}
			
		if(coviCmn.configMap.usePortalSimpleWrite == "Y"){
			$('#btnSimpleWrite').show();
		}
		
		if(coviCmn.configMap.usePortalEumGadget != "Y"){
			$(".orderTabMenu li[type=Messenger]").hide();
			$(".orderContent .timeSquareTab").hide();
		}
		
		if(coviCmn.configMap.usePortalOrgchart == "Y"){
			$('#btnOrgChart').show();
	    	// 조직도 클릭
	    	$('#btnOrgChart').on('click',  function () {
	    		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?type=A0&treeKind=Group","1170px","675px","iframe",true,null,null,true);
	    	});
		}
    	
    	
    	// 플로워 팝업메뉴
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
    	
     	$(document).click(function(e){ //문서 body를 클릭했을때 팝업종료
     		// 내 정보, 사이트링크, 사용자 정보 플라워 메뉴, 통합 알림 팝업
     		 if (!($("#myInfoViewList").has(e.target).length > 0 || $("#siteMapCont").has(e.target).length > 0  || $(".flowerMenuList").has(e.target).length > 0
     				 	|| $("#integratedAlarmCont").has(e.target).length > 0)) {
                 if ($('.btnSiteMap').has(e.target).length > 0 || $('.btnSiteMap').is(e.target)) {
         			$('.myInfo').removeClass('active');
         			$('.flowerMenuList ').removeClass('active');
         			$("li[data-menu-id=Integrated]").removeClass('active');
                     return false;
                 } else if ($('.myInfoViewBtn').has(e.target).length > 0 || $('.myInfoViewBtn').is(e.target)) {
         			$('.btnGnbView').removeClass('active');
         			$('.flowerMenuList ').removeClass('active');
         			$("li[data-menu-id=Integrated]").removeClass('active');
                     return false;
                 } else if ($('.btnFlowerName').has(e.target).length > 0 || $('.btnFlowerName').is(e.target)) {
                	$('.myInfo').removeClass('active');
         			$('.btnGnbView').removeClass('active');
         			$("li[data-menu-id=Integrated]").removeClass('active');
                     return false;
                 } else if ($("li[data-menu-id=Integrated]").has(e.target).length > 0 || $("li[data-menu-id=Integrated]").is(e.target)) {
                	$('.myInfo').removeClass('active');
          			$('.btnGnbView').removeClass('active');
          			$('.flowerMenuList ').removeClass('active');
                 } else {
         			 $('.myInfo').removeClass('active');
                	 $('.btnGnbView').removeClass('active');
                	 $('.flowerMenuList ').removeClass('active');
                	 $("li[data-menu-id=Integrated]").removeClass('active');
                	 
	      				//2019.04 메일 좌우분할 시 너비 조정
	      				try{
	      					if((btnTopMenu) && CFN_GetQueryString("CLSYS") == "mail" && CFN_GetQueryString("CLMD") == "user" && CFN_GetQueryString("CLBIZ") == "Mail" ){
	      						if($("#divJspMailLeftRightList").css("display") != "none"){
	      							setTimeout(function(){
		          						ResizeWidthMailLeftRightList(OnOff);
	      							}, 1000); 	      							
	      						}
	      						btnTopMenu = false;
	      					}
	      				}catch(e){
   						}                    	 
                 }
             }		
      	});
 
    	
		if(coviCmn.webBrowserVersion()!= ""){
			var htmlTag = "<html>";
			htmlTag += "<head></head>";
			htmlTag += "<body style='font:15px arial, serif;'>";
			htmlTag += "<div>";
			htmlTag += "지원하지 않는 브라우저입니다.</br>";
			htmlTag += "지원하는 브라우저는 아래와 같습니다.</br>";
			htmlTag += "&nbsp;  - Chrome </br>";
			htmlTag += "&nbsp;  - IE 11 이상 </br>";
			htmlTag += "&nbsp;  - Edge </br>";	
			htmlTag += "&nbsp;  - Firefox </br>";
			htmlTag += "&nbsp;  - Safari/iOS Safari";
			htmlTag += "</div>";
			htmlTag += "</body>";
			htmlTag += "</html>";
			
			iframeElementContainer = document.getElementById('messenger').contentDocument;
			iframeElementContainer.open();
			iframeElementContainer.writeln(htmlTag);
			iframeElementContainer.close();
		}else{
			var agt = navigator.userAgent.toLowerCase(); 
		
		if(navigator.appName == 'Microsoft Internet Explorer' || (navigator.appName == 'Netscape' && agt.indexOf('trident') != -1) || agt.indexOf("msie") != -1){
				var htmlTag = "<html>";
 				htmlTag += "<head></head>";
 				htmlTag += "<body style='font:15px arial, serif;'>";
 				htmlTag += "<div>";
 				htmlTag += "지원하지 않는 브라우저입니다.</br>";
 				htmlTag += "지원하는 브라우저는 아래와 같습니다.</br>";
 				htmlTag += "&nbsp;  - Chrome </br>";
 				htmlTag += "&nbsp;  - Edge </br>";	
 				htmlTag += "&nbsp;  - Firefox </br>";
 				htmlTag += "&nbsp;  - Safari/iOS Safari";
 				htmlTag += "</div>";
 				htmlTag += "</body>";
 				htmlTag += "</html>";
 				
 				iframeElementContainer = document.getElementById('messenger').contentDocument;
 				iframeElementContainer.open();
 				iframeElementContainer.writeln(htmlTag);
 				iframeElementContainer.close();
			}else{
				if(coviCmn.configMap.usePortalEumGadget == "Y"){
					myTimer_lv = setTimeout(function(){
 	 					setEumView();
 	 				}, 1800);
				}
			}
		}
    	
	});
	
	$(window).load(function() {
		//myInfo load
    	coviMenu.drawMyInfo("#myInfoContainer", myInfoData);
		
    	//quick menu set
    	if(coviCmn.configMap.usePortalLeft == "Y"){
	    	var hardCodedQuickData =coviMenu.getQuickData();
	    	coviMenu.render("#quickContainer", hardCodedQuickData, "defaultQuick");
    	}
    	
    	if(coviCmn.configMap.usePortalGadget == "Y"){
    		//event binding
	    	// 업무지시
	    	//업무지시 탭메뉴
			$('.orderTabMenu>li').on('click', function(){
				var menuType = $(this).attr("type");
	
				initPortalMenu(menuType);
				
				$('.orderTabMenu>li').removeClass('active');
				$('.oderTabContent').removeClass('active');
				$(this).addClass('active');
				$('.oderTabContent').eq($(this).index()).addClass('active');
				
				//타임스퀘어 => 이음
				if($(this).index() == "0"){
					var agt = navigator.userAgent.toLowerCase(); 
					
					if(navigator.appName == 'Microsoft Internet Explorer' || (navigator.appName == 'Netscape' && agt.indexOf('trident') != -1) || agt.indexOf("msie") != -1){
	 					var htmlTag = "<html>";
	 	 				htmlTag += "<head></head>";
	 	 				htmlTag += "<body style='font:15px arial, serif;'>";
	 	 				htmlTag += "<div>";
	 	 				htmlTag += "지원하지 않는 브라우저입니다.</br>";
	 	 				htmlTag += "지원하는 브라우저는 아래와 같습니다.</br>";
	 	 				htmlTag += "&nbsp;  - Chrome </br>";
	 	 				htmlTag += "&nbsp;  - Edge </br>";	
	 	 				htmlTag += "&nbsp;  - Firefox </br>";
	 	 				htmlTag += "&nbsp;  - Safari/iOS Safari";
	 	 				htmlTag += "</div>";
	 	 				htmlTag += "</body>";
	 	 				htmlTag += "</html>";
	 	 				
	 	 				iframeElementContainer = document.getElementById('messenger').contentDocument;
	 	 				iframeElementContainer.open();
	 	 				iframeElementContainer.writeln(htmlTag);
	 	 				iframeElementContainer.close();
	 				}else{
						if($('#messenger').attr('src') == "" && coviCmn.configMap.usePortalEumGadget == "Y"){
							setEumView();
						}
	 				}
				}
				
			});
			var OnOff = "On";
			var btnTopMenu = null;
	    	$('.btnTopMenu').on('click', function(){
				var siblingsCont = $(this).siblings('.orderBusi');
				
				if($(this).closest('li').hasClass('active')){
					// siblingsCont.removeClass('active');	
					$(this).closest('li').removeClass('active');
					$('.commContRight').removeClass('orderActive');
					coviCmn.setCookie("SideMenuViewType", "", 1);		//1day: 저장일 기준에 대해 확인 필요
					OnOff = "Off";
				}else {
					$('.orderBusi').removeClass('active');				
					$(this).closest('li').addClass('active');
					$('.commContRight').addClass('orderActive');
					coviCmn.setCookie("SideMenuViewType", "active", 1);	//1day: 저장일 기준에 대해 확인 필요
					OnOff = "On";

					initPortalMenu($('.orderTabMenu>li.active').attr("type"));
				}
				btnTopMenu = true;
	    	});
	    	
	    	$('.orderContent .btnOrderContClose').on('click', function(){
	    		$('#gadgetLi').removeClass('active');
				$('.commContRight').removeClass('orderActive');
				coviCmn.setCookie("SideMenuViewType", "", 1);		//1day: 저장일 기준에 대해 확인 필요	 
	    	});
    		
	    	//SideMenu Cookie값에 따라 열림/닫힘 상태 설정
	    	if(coviCmn.getCookie("SideMenuViewType") != ""){ //가젯 열기 
				// siblingsCont.removeClass('active');	
	    	
				$('.orderBusi').removeClass('active');				
				$('.btnTopMenu').closest('li').addClass('active');
				$('.commContRight').addClass('orderActive');
				
				$('.orderTabMenu>li.active').click();
			}
    	}
    	
    	coviCtrl.bindmScrollV($('.mScrollV'));
	});
	
	
	var isPortalMenuLoad = new Object();
	isPortalMenuLoad["Subscription"] = false; 
	isPortalMenuLoad["ContactNumber"] = false; 
	isPortalMenuLoad["Todo"] = false;			
	isPortalMenuLoad["Favorite"] = false;		

	function initPortalMenu(menuType){
		if(menuType == "Subscription" && isPortalMenuLoad["Subscription"] == false){ //구독 목록 조회	
			coviCtrl.getSubscriptionList();
			isPortalMenuLoad["Subscription"] = true;
		}else if(menuType == "ContactNumber" && isPortalMenuLoad["ContactNumber"] == false){ // 연락처 조회 및 그리기
			// 연락처 버튼 컨트롤
	    	$('#contactNumberDiv').on('click', '.btnPerBoxMore', function(){
	    		var parent = $(this).closest('.personBox');
	    		
	    		if ($(this).hasClass('active')) {
	    			parent.removeClass('active');
	    			$(this).removeClass('active');
	    		} else {
	    			parent.addClass('active');
	    			$(this).addClass('active');
	    		}		 
	    	});
			
			coviCtrl.getContactNumberList();
			isPortalMenuLoad["ContactNumber"] = true;
		}else if(menuType == "Todo" && isPortalMenuLoad["Todo"] == false){ // TODO 조회 및 그리기    	
			// To-Do 완료 체크박스
	    	$('.toDoTab').on('change', '.allChkInput', function () {
				var todoId = '';
				$('.toDoTab').find('.indiChkInput').each(function (i, v) {
					if (i > 0) todoId += ',';
					todoId += $(this).val();
				});
				
	 			$.ajax({
					type : "POST",
					data : {
						todoId : todoId,
						isComplete : ($(this).is(":checked") == true) ? 'Y' : 'N'
					},
					url : '/covicore/subscription/updateTodo.do',
					success:function (list) {
						coviCtrl.getTodoList();	// TODO 조회 및 그리기
					},
					error:function(response, status, error) {
						CFN_ErrorAjax('/covicore/subscription/updateTodo.do', response, status, error);
					}
				});
	    	});
	    	
	    	// To-Do 체크박스
	    	$('.toDoTab').on('change', '.indiChkInput', function () {
	 			$.ajax({
					type : "POST",
					data : {
						todoId : $(this).val(),
						isComplete : ($(this).is(":checked") == true) ? 'Y' : 'N'
					},
					url : '/covicore/subscription/updateTodo.do',
					success:function (list) {
						coviCtrl.getTodoList();	// TODO 조회 및 그리기
					},
					error:function(response, status, error) {
						CFN_ErrorAjax('/covicore/subscription/updateTodo.do', response, status, error);
					}
				});    		 
	    	});
			
			coviCtrl.getTodoList();
			
			isPortalMenuLoad["Todo"] =  true;
		}else if(menuType == "Favorite" && isPortalMenuLoad["Favorite"] == false){ // 즐겨찾기 메뉴 목록 조회 
			coviCtrl.getFavoriteMenuList();
			isPortalMenuLoad["Favorite"] = true;
		}
	}
	
	function setEumView(){
		var eumServer = coviCmn.configMap.eumServerUrl;
		var eumUrl = eumServer + "/manager/na/sso/gate.do?CSJTK="+encodeURIComponent(key)+"&dir=/client";
		
		$('#messenger').attr('src', eumUrl);
	}
</script>