<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
</head>

<body>

	<div class='cLnbTop'>
		<h2>e-Accounting</h2>
		<div id="eaccountingTopGroupMenuList" class="cLnbTop_group">
			<%-- 
			<a class='btnType01' style="display:none;" id="account_CombineCostApplicationaccountuserAccount"		name="LeftSub" type="CO" url="/account/layout/account_CombineCostApplication.do?CLSYS=account&CLMD=user&CLBIZ=Account"><spring:message code="Cache.lbl_combineCostApp"/></a>
			<a class='btnType01' style="display:none;" id="account_SimpleApplicationaccountuserAccount" 			name="LeftSub" type="SC" url="/account/layout/account_SimpleApplication.do?CLSYS=account&CLMD=user&CLBIZ=Account"><spring:message code="Cache.lbl_SimpleApp"/></a>
			--%>
			
			<a class='btnType01' id="EmployeeSimpleApplicationBtn" onclick="togglePopup(this)"><spring:message code='Cache.ACC_btn_employeeExpenceApplication'/></a>
			<a class='btnType01' id="VendorCostSettlementBtn" onclick="togglePopup(this)"><spring:message code='Cache.ACC_btn_vendorCostSettlement'/></a>
			<div class="nea_menu_wrap" id="EmployeeSimpleApplicationMenuArea" style="display:none; height: auto; z-index: 4;">
				<ul class="nea_menu_list" menuType="E">
				</ul>
			</div>
			<div class="nea_menu_wrap" id="VendorCostSettlementMenuArea" style="display:none; top: 101px; height: auto; z-index: 4;">
				<ul class="nea_menu_list" menuType="V">
				</ul>
			</div>			
		</div>
	</div>					
	<div class='cLnbMiddle mScrollV scrollVType01 cLnbTop3' style="top: 150px;">
		<div>
			<ul id="eaccountingMenuList" class="contLnbMenu eaccountingMenu">
			</ul>
			<!-- 테스트 용 
			<ul class="contLnbMenu eaccountingMenu">
				<li class="eaccountingMenu02">
					<div id="groupBox9" class="selOnOffBox">
						<a id="groupA9" class="btnOnOff"  onclick="CoviMenu_GetContent('/account/layout/account_AccountPortalHome.do?CLSYS=account&CLMD=user&CLBIZ=Account&Auth=M');return false;">대쉬보드-관리자</a>
					</div>
				</li>
				<li class="eaccountingMenu02">
					<div id="groupBox9" class="selOnOffBox">
						<a id="groupA9" class="btnOnOff"  onclick="CoviMenu_GetContent('/account/layout/account_AccountPortalHome.do?CLSYS=account&CLMD=user&CLBIZ=Account&Auth=A');return false;">대쉬보드-사용자</a>
					</div>
				</li>
			</ul>-->
		</div>
	</div>
	
		
	<script type="text/javascript">		
		var leftData = ${leftMenuData};
		var loadContent = '${loadContent}';
		var jobfunctionCnt = 0;
		var BizDocListCnt = 0;

		initLeft();
		setAccountDocreadCount();
		
		function initLeft() {
			
	    	if(loadContent == 'true') {
	    		CoviMenu_GetTab('/account/layout/tab.do?CLSYS=account&CLMD=user&CLBIZ=Account');
//	    		CoviMenu_GetContent('/account/layout/account_AccountPortalHome.do?CLSYS=account&CLMD=user&CLBIZ=Account&Auth=A');
	    		CoviMenu_GetContent('/account/accountPortal/portalHome.do?CLSYS=account&CLMD=user&CLBIZ=Account&Auth=A');
//	    		CoviMenu_GetContent('/account/layout/account_AccountPortal.do?CLSYS=account&CLMD=user&CLBIZ=Account');
	    	}
	    	
			/* $.ajax({
				type:"POST",
				data:{
					"codeGroups" : 'ExpAppType'
				},
				url:"/account/accountCommon/getBaseCodeCombo.do",
				async	: false,
				success	: function (data) {
					if(data.result == "ok"){
						if(data.list.length > 0) {
							type = data.list[0].ExpAppType;
							btn = $("a[name=LeftSub][class=btnType01]");
							
							for(var i = 0; i < type.length; i++) {
								for(var j = 0; j < btn.length; j++) {
									if(type[i].Code == $(btn[j]).attr("type")) {
										$(btn[j]).show();
										$("div.cLnbMiddle").css("top", Number($("div.cLnbMiddle").css("top").replace("px", "")) + 40 + "px");
									}	
								}								
							}
						}						
					}
				},
				error:function (error){
					Common.Error(error.message);
				}
			}); */
			
			$.ajax({
				type:"POST",
				data:{
				},
				url:"/account/formManage/getFormMenuList.do",
				async	: false,
				success	: function (data) {
					if(data.result == "ok"){
						if(data.list.length > 0) {
							$(data.list).each(function(i, obj){
								var isDisplay = '';
								if(obj.FormCode == "BIZTRIP" || obj.FormCode == "OVERSEA") { // TODO: IsDisplay 컬럼 추가 & 하드코딩 제거
									isDisplay = 'display: none;';
								}
								
								var ExpAppTypeName = "";
								switch(obj.ExpAppType) {
								case "CO": ExpAppTypeName = "CombineCostApplication"; break;
								case "SC": ExpAppTypeName = "SimpleApplication"; break;
								}
								
								var className = (nullToBlank(obj.ReservedStr1) == '' ? 'nea_menu_link01' : obj.ReservedStr1);
								$("ul.nea_menu_list[menuType="+obj.MenuType+"]").append(
										'<li><a class="'+obj.ReservedStr1+'" style="'+isDisplay+'" id="account_'+ExpAppTypeName+'accountuserAccount'+obj.FormCode+'" name="LeftSub" onclick="removeMenuActive();"'
										+ ' url="/account/layout/account_'+ExpAppTypeName+'.do?CLSYS=account&CLMD=user&CLBIZ=Account&requesttype='+obj.FormCode+'">'+obj.FormName+'</a></li>');
							});
						}						
					}
				},
				error:function (error){
					Common.Error(error.message);
				}
			});
	    	
			//home
			makeMenu(leftData);
			
			coviCtrl.bindmScrollV($('.mScrollV'));
				
			$('.btnOnOff').click(function(){
				if($(this).closest("li").hasClass('eaccountingMenu02')) {
					if($(this).hasClass('active')){
						$(this).removeClass('active');
						$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').removeClass('active');
					}else {
						$(this).addClass('active');
						$(this).closest('.selOnOffBox').siblings('.selOnOffBoxChk').addClass('active');			
					}
				}
			});
			
			// 메뉴 숨기기
	    	getJobFunctionCount();
	    	getBizDocListCount();
	    	if(jobfunctionCnt <= 0)
				$("[data-menu-alias=JobFunction]").hide();
	    	
	    	if(BizDocListCnt <= 0)
	    		$("[data-menu-alias=BizDoc]").closest("li").hide();
		}
		
		function removeMenuActive() {
			$(".nea_menu_wrap").removeClass("active");
		}
		
		var settingID;
		var selectedID;
		var selectedLabel;
		var selectedContentUrl;
		
		function makeMenu(data){
			var list			= data;
			var appendStr		= "";
			var appendStrHeader	= "";
			var appendStrBody	= "";
			var appendStrBottom	= "";			
			
			var ChildCnt		= 0;
			var ChildAddCnt		= 0;
			var groupAddCnt		= 0;		

			settingID			= "";
			selectedID			= "";
			selectedLabel		= "";
			selectedContentUrl	= "";
			
			if(list.length > 0){				
				var LeftDisplayName = "";
				
				for(var i=0; i<list.length; i++){
					var info = list[i];
					
					ChildCnt		= info.Sub.length;
					ChildAddCnt		= 0;
					LeftDisplayName	= info.DisplayName;
					
					if(info.URL == "LEFT" || info.URL == "") { //서브메뉴가 있는 좌측메뉴
						appendStrHeader	=	"<li class=\"eaccountingMenu02\">"
										+		"<div id=\"groupBox"+groupAddCnt+"\" class=\"selOnOffBox\">"
										+			"<a id=\"groupA"+groupAddCnt+"\" class=\"btnOnOff\">"+LeftDisplayName+"<span></span></a>"
										+		"</div>"
										+		"<div id=\"groupChk"+groupAddCnt+"\" class=\"selOnOffBoxChk type02 boxList\">";
										
						groupAddCnt	+= 1;
						
						for(var j=0; j<info.Sub.length; j++) {
							var subInfo = info.Sub[j];
							
							setSelectedData(subInfo.URL, subInfo.DisplayName);
							
							appendStrBody	+= "<a id=\""+settingID+"\" name='LeftSub' data-menu-alias=\""+subInfo.Reserved1+"\" url=\""+subInfo.URL+"\">"+subInfo.DisplayName+"</a>";
						}
						
						appendStrBottom = "</div></li>";
					} else { //서브메뉴가 없는 좌측메뉴
						appendStrHeader = "<li class=\"eaccountingMenu02\">";
						
						setSelectedData(info.URL, LeftDisplayName);
						
						appendStrBody = 		"<a id=\""+settingID+"\" name='LeftSub' url=\""+info.URL+"\" style=\"padding:15px 5px 15px 39px;margin-left:10px;height:47px;line-height:17px;\">"+LeftDisplayName+"</a>"
						appendStrBottom = "</li>";
					}
					
					appendStr += appendStrHeader + appendStrBody + appendStrBottom;
					
					appendStrHeader	= "";
					appendStrBody	= "";
					appendStrBottom	= "";
				}
				$("#eaccountingMenuList").append(appendStr);
				
				if(selectedID == ""){
	    	        setTab();  
				}else{
					eAccountContentHtmlChangeAjax(selectedID,selectedLabel,selectedContentUrl);
					selectedID			= "";
					selectedLabel		= "";
					selectedContentUrl	= "";
				}
			}
		}
		
		function setSelectedData(pUrl, pDisplayName) {
			var chkStr = (location.pathname + location.search).replace('&fragments=content','');
			
			var setClassTF	= false;			
			if(pUrl.indexOf(chkStr) > -1){
				setClassTF = true;
			}
			
			settingID = pUrl.split('/')[3].split('.')[0];
			
			var searchStr			= pUrl;
			var searchStrReplaceAll	= searchStr.replaceAll('?','');
			var searchStrsplitAND	= searchStrReplaceAll.split('&');
			
			for(var sstr = 0; sstr < searchStrsplitAND.length; sstr++){
				var searchStrsplitEQ	= searchStrsplitAND[sstr].split('=');
				settingID += searchStrsplitEQ[1];
			}
			
			if(setClassTF){
				selectedID			= settingID;
				selectedLabel		= pDisplayName;
				selectedContentUrl	= pUrl;
			}
		}
		
		function setTab() {
			var pathname		= location.pathname;
			var searchParams	= location.search;
			var fullUrl			= (pathname+searchParams).replace('&fragments=content','');
			
			var viewNum	= -1;
			var list	= leftData;
			
			for(var i=0; i<list.length; i++){
				if(list[i].URL == fullUrl){
					viewNum = i;
					break;
				}
			}
			
			var viewId		= "";
			var viewLabel	= "";
			var viewUrl		= "";
	
			if(viewNum == -1){
				viewId		= 'fixedTabAcc';
				viewLabel	= 'Home';
				viewUrl		= fullUrl;
				var topGroupList = $('#eaccountingTopGroupMenuList').find("a");
				for(var i=0; i<topGroupList.length;i++){
					if(topGroupList[i].getAttribute('url') == fullUrl){
						viewId		= topGroupList[i].id;
						viewLabel	= topGroupList[i].text;
						viewUrl		= fullUrl;
						break;
					}
				}
				eAccountContentHtmlChangeAjax(viewId,viewLabel,fullUrl);
			}
		}
		
		function togglePopup(obj) {
			$(".nea_menu_wrap").hide();
			
			var menuArea = $(obj).attr("id").replace("Btn", "MenuArea");
			if($("#"+menuArea).hasClass("active")) {
				$("#"+menuArea).removeClass("active");
			} else {
				$(".nea_menu_wrap").removeClass("active");
				$("#"+menuArea).addClass("active");
			}
			
			$(".nea_menu_wrap.active").show();
		}
		
		function getJobFunctionCount(){
			$.ajax({
				type:"POST",
				url:"/approval/user/getJobFunctionCount.do",
				data:{
					JobFunctionType:"ACCOUNT"
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
				data:{
					BizDocType:"ACCOUNT"
				},			
				async: false,
				success:function (data) {
					if(data.result=="ok"){
						BizDocListCnt = data.cnt;
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/user/getBizDocCount.do", response, status, error);
				}
			});
		}
	</script>
</body>
