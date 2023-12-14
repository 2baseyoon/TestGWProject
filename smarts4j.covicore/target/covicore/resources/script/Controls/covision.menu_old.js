/* 프로그램 저작권 정보
//이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
//(주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
//(주)코비젼의 지적재산권 침해에 해당됩니다.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
//
//You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
//as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
//owns the intellectual property rights in and to this program.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

///<creator>기술연구소</creator> 
///<createDate>2017.06.19</createDate> 
///<lastModifyDate></lastModifyDate> 
///<version>0.8.0</version>
///<summary> 
///메뉴 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/


/*
 * top menu draw
 * 
 * [
 * 	{	"MenuID":"4",
 * 		"DomainID":"1",
 * 		"IsAdmin":"N",
 * 		"MenuType":"Top",
 * 		"ParentObjectID":"1",
 * 		"ParentObjectType":"DN",
 * 		"ServiceDevice":"A",
 * 		"DisplayName":"통합게시",
 * 		"MultiDisplayName":"통합게시;;;;",
 * 		"MenuPath":"",
 * 		"SecurityLevel":"90",
 * 		"SortKey":"5",
 * 		"SortPath":"000000000000005;",
 * 		"HasFolder":"Y",
 * 		"IsInherited":"Y",
 * 		"IsUse":"Y",
 * 		"IsDisplay":"Y",
 * 		"URL":"/WebSite/Basic/Board/BoardMain.aspx?system=Board",
 * 		"Target":"Current",
 * 		"Description":"통합 게시"
 * 	},
 * 	{}
 * ]
 * 
 * */

Common.getSession();

//# sourceURL=covision.menu.js
function CoviMenu(opt){
	//설정
	this.config = {
			lang : 'ko',
			isPartial : 'true',
			domainId : '',
			isAdmin : '',
			bizSection : ''
	}
	
	if(!this.isEmpty(opt.lang)){
		this.config.lang = opt.lang;	
	}
		
	if(!this.isEmpty(opt.isPartial)){
		this.config.isPartial = opt.isPartial;	
	}
}


CoviMenu.prototype.render = function(target, data, templateType){//탑메뉴 로드
	
	var $this = this;
	var html = '';
    switch (templateType) {
		case "defaultHorizontal":		
	    	html = $this.draw(data, 'CoviMenu_ClickTop', 'subGnb');
	        $(target).html(html);
			break;
		case "adminTop":
	    	html = $this.drawAdminTop(data, 'CoviMenu_ClickTop');
	        $(target).html(html);
			break;
		case "adminLeft":
	    	html = $this.drawAdminLeft(data, 'CoviMenu_ClickLeft');
	        $(target).html(html);
			break;
		case "defaultVertical":
	    	html = $this.draw(data, 'CoviMenu_ClickLeft');
	        $(target).html(html);
			break;
	    case "jqueryUIVertical":
	    	html = $this.draw(data, 'CoviMenu_ClickLeft');
	        $(target).html(html).menu();
			break;
	    case "jqueryUIHorizontal":
	    	html = $this.draw(data, 'CoviMenu_ClickTop');
	        $(target).html(html).menubar();
			break;
	    case "defaultQuick":
	    	html = $this.drawQuick(data);
	    	$(target).html(html);
	    	setTimeout($this.setQuickInit(),7000);
	    	$this.setQuickLongPolling();
	        break; 
	    case "userLeft"://문서관리,통합계시
	    	html = $this.drawUserLeft(data, 'CoviMenu_ClickLeft', 'selOnOffBoxChk type02 boxList');
	        $(target).html(html);
	        break; 
	    case "userCustomLeft"://사용자 정의
	    	html = $this.drawUserLeft(data, '', 'selOnOffBoxChk type02 boxList');
	        $(target).html(html);
	}
}

CoviMenu.prototype.renderSiteMap = function(target, data){//사이트맵보기 그려주기	
	var $this = this;
	var html = '';	
	
	$this.drawSiteMap(data, 'CoviMenu_ClickTop', 'smalTitle');
	
	if(Common.getBaseConfig("usePortalSiteLink") == "Y"){
		$this.drawSiteLink();//FIXED: 퍼블리싱 데이터 그대로 그려줌
	}
	
//	html = $this.drawSiteMap(data, 'CoviMenu_ClickTop', 'smalTitle');
//    $(target).html(html);
}

CoviMenu.prototype.get = function(domainId, isAdmin, bizSection, menuType, memberOf, callback){
	var $this = this;
	$this.config.domainId = domainId;
	$this.config.isAdmin = isAdmin;
	$this.config.bizSection = bizSection;
	
	$.ajax({
		type:"POST",
		data:{
			"DomainID" : domainId,
			"IsAdmin" : isAdmin,
			"BizSection" : bizSection,
			"MenuType" : menuType,
			"MemberOf" : memberOf
		},
		url:"/covicore/menu/getmenu.do",
		success : function (res) {
			if(res.result == "ok"){
				//callback method 호출
				if(callback != null && callback != ''){
					if(window[callback] != undefined){
						window[callback](res.data);
					} else if(parent[callback] != undefined){
						parent[callback](res.data);
					} else if(opener[callback] != undefined){
						opener[callback](res.data);
					}
				}
			}
		},
		error : function(response, status, error){
			CFN_ErrorAjax("menu/getmenu.do", response, status, error);
		}
	});
	
}

CoviMenu.prototype.renderAjax = function(target, domainId, isAdmin, bizSection, menuType, memberOf, templateType){
	
	var $this = this;
	$this.config.domainId = domainId;
	$this.config.isAdmin = isAdmin;
	$this.config.bizSection = bizSection;
	
	var html = '';
	$.ajax({
		type:"POST",
		data:{
			"DomainID" : domainId,
			"IsAdmin" : isAdmin,
			"BizSection" : bizSection,
			"MenuType" : menuType,
			"MemberOf" : memberOf
		},
		url:"/covicore/menu/getmenu.do",
		success : function (res) {
			if(res.result == "ok"){				
				switch (templateType) {
					case "defaultHorizontal":
				    	html = $this.draw(res.data, 'CoviMenu_ClickTop');
				        $(target).html(html);
						break;
					case "defaultVertical":
				    	html = $this.draw(res.data, 'CoviMenu_ClickLeft');
				        $(target).html(html);
						break;
				    case "jqueryUIVertical":
				    	html = $this.draw(res.data, 'CoviMenu_ClickLeft');
				        $(target).html(html).menu();
						break;
				    case "jqueryUIHorizontal":
				    	html = $this.draw(res.data, 'CoviMenu_ClickTop');
				        $(target).html(html).menubar();
						break;
						
				    case "userLeft":
				    	html = $this.drawUserLeft(res.data, 'CoviMenu_ClickLeft');
				        $(target).html(html);
						break; 
				}
				
			}
		},
		error : function(response, status, error){
			CFN_ErrorAjax("menu/getmenu.do", response, status, error);
		}
	});
	
}

CoviMenu.prototype.draw = function(data, clickMethodName, subListClass){//탑메뉴바 : 전자결제, 메일,......
	var menuHtml = "";
	var topMenuConf = Common.getSession("TopMenuConf");
	//도메인별 분리작업 확인
	if(topMenuConf.indexOf("@@")>-1){
		var arrTopMenu = topMenuConf.split("@@");
		var ptopMenuConf = "";
		for(var i=0;i<arrTopMenu.length;i++){
			if(arrTopMenu[i] == Common.getSession("DN_ID")){//해당 domain
				ptopMenuConf = arrTopMenu[i+1];
				break;
			}
		}
		topMenuConf = ptopMenuConf;
	}
	
	$(data).each(function(idx,obj){
		if(this.IsUse!="N"){
			//TopMenuConf에 지정된 값이 없을 경우 앞에 5개만 표시되도록 변경
			if((topMenuConf == ""  || topMenuConf == undefined ) && idx >= Number(Common.getBaseConfig("TopMenuCount"))){
				return true;
			}
			
			//TopMenuConf에 해당하는 값이 아니면 Continue처리
			if(topMenuConf != "" && this.IsAdmin == "N" && topMenuConf.match(new RegExp("\\b"+this.MenuID + ";" , "g")) == null  ){
				return true;
			}
			menuHtml += "<li class= '"+this.IconClass+"' data-menu-id='" + this.MenuID + "'data-menu-target='" + this.Target + "' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "'><a href='javascript:;' onclick='" + clickMethodName + "(this);return false;'><span>" + this.DisplayName + "</span></a>";
				if(this.Sub != undefined && this.Sub.length > 0){
					
					if(subListClass != null && subListClass != undefined){
						menuHtml += "<ul class='" + subListClass + "'>";
					} else{
						menuHtml += "<ul>";
					}
					
					$(this.Sub).each(function () {
						menuHtml += "<li class='"+data.IconClass+"' data-menu-id='" + this.MenuID + "' data-menu-target='" + this.Target + "' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "'><a href='javascript:;' onclick='" + clickMethodName + "(this);return false;'>" + this.DisplayName + "</a></li>";
					});
					
					menuHtml += "</ul>"
				}
				
				menuHtml += "</li>";
		}
	});
	return menuHtml;
}

CoviMenu.prototype.drawAdminTop = function(data, clickMethodName){
	var menuHtml = "";
	$(data).each(function(){
			if(this.Sub != undefined && this.Sub.length > 0){
				menuHtml += "<li class='off' data-menu-id='" + this.MenuID +   "' data-menu-target='" + this.Target +"' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "' onmouseover='toggleheadermenu(this);' onmouseout='toggleheadermenu(this);'><a href='javascript:;' onclick='" + clickMethodName + "(this);return false;'><span>" + this.DisplayName + "</span></a>";
				menuHtml += "	<div class='gnb_sub' style='display:none;'>";
				
				$(this.Sub).each(function () {
					menuHtml += "	<div data-menu-id='" + this.MenuID +  "' data-menu-target='" + this.Target + "' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "'>";
					menuHtml += "		<a href='javascript:;' onclick='" + clickMethodName + "(this);return false;'><div>" + this.DisplayName + "</div></a>";
					menuHtml += "	</div>";
				});
				
				menuHtml += "	</div>"
			} else {
				menuHtml += "<li class= 'off over_non' data-menu-id='" + this.MenuID +   "' data-menu-target='" + this.Target + "' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "'><a href='javascript:;' onclick='" + clickMethodName + "(this);return false;'><span>" + this.DisplayName + "</span></a>";
			}
			
			menuHtml += "</li>";
	});
	return menuHtml;
}

CoviMenu.prototype.drawAdminLeft = function(data, clickMethodName){
	var menuHtml = ""; 
	$(data).each(function(){
		
		if(this.Sub != undefined && this.Sub.length > 0)
		{
			menuHtml += "<li class= 'list_1dep_close' data-menu-id='" + this.MenuID +  "' data-menu-target='" + this.Target + "' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "'>";
			menuHtml += "<a href='javascript:;' onclick='toggleleftmenu(this);return false;'>" + this.DisplayName + "</a>";
		}
		else
		{
			menuHtml += "<li class= 'list_1dep' data-menu-id='" + this.MenuID +  "' data-menu-target='" + this.Target +  "' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "'>";
			menuHtml += "<a href='javascript:;' onclick='" + clickMethodName + "(this); setManuActive(this); return false;'>" + this.DisplayName + "</a>";
		}
	
		if(this.Sub != undefined && this.Sub.length > 0){
			
			if(this.Sub != undefined && this.Sub.length > 0){
				menuHtml += "<ul style='display: none;'>";
				
				$(this.Sub).each(function () {
					menuHtml += "	<li class='list_2dep' data-menu-id='" + this.MenuID +  "' data-menu-target='" + this.Target +  "' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "'>";
					menuHtml += "		<a href='javascript:;' onclick='" + clickMethodName + "(this); setManuActive(this); return false;'>" + this.DisplayName + "</a>";
					menuHtml += "	</li>";
				});
				
				menuHtml += "</ul>"
			}
		}
		
		menuHtml += "</li>";
	});
	return menuHtml;
}

CoviMenu.prototype.drawUserLeft = function(data, clickMethodName, subListClass){//업무 도우미 전자 설문
	var menuHtml = ""; 
	$(data).each(function(index){
		if(this.IconClass==undefined || this.IconClass == "")
			this.IconClass="noIcon";
		//하위가 있을 경우 위의 메뉴는 div로 그려줘야 한다.
		if(this.Sub != undefined && this.Sub.length > 0)
		{
			menuHtml += "<li class= '"+this.IconClass+"' data-menu-id='" + this.MenuID + "' data-menu-target='" + this.Target + "' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "' display-name='" + this.MultiDisplayName + "'>";
		}
		else
		{
			if(index==0){
			menuHtml += "<li class= '"+this.IconClass+"' data-menu-id='" + this.MenuID +  "' data-menu-target='" + this.Target + "' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "' display-name='" + this.MultiDisplayName + "'><a href='javascript:;' onclick='" + clickMethodName + "(this);return false;' class='non selected'>" + this.DisplayName + "</a>";
			}else{
				menuHtml += "<li class= '"+this.IconClass+"' data-menu-id='" + this.MenuID +  "' data-menu-target='" + this.Target +  "' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "' display-name='" + this.MultiDisplayName + "'><a href='javascript:;' onclick='" + clickMethodName + "(this);return false;' class='non'>" + this.DisplayName + "</a>";
			}
		}
		
		
	
		if(this.Sub != undefined && this.Sub.length > 0){
			
			if(this.Sub != undefined && this.Sub.length > 0){
				if(this.IconClass != "menuAllContact") //전체 연락처
					menuHtml +="<div class=selOnOffBox display-name='" + this.MultiDisplayName + "'><a href='javascript:;' class ='btnOnOff'>" + this.DisplayName + "<span></span></a></div>";
				else{
					menuHtml +="<div class=selOnOffBox display-name='" + this.MultiDisplayName + "'><a href='javascript:;' onclick='" + clickMethodName + "(this);return false;' class ='btnOnOff active'><span>" + this.DisplayName + "</span></a></div>";
				}				
				if(subListClass != null && subListClass != undefined){
					menuHtml += "<div class='"+subListClass+"'>";				
				} else{
					menuHtml += "<div>";
				}				
				$(this.Sub).each(function (idx, v) {
					if (v.Sub != undefined && v.Sub.length > 0)		menuHtml += "<div class= 'sel_depth02'>";
					menuHtml += "<div class= '"+(this.Sub != undefined && this.Sub.length > 0?"selOnOffBox":this.IconClass)+"' data-menu-id='" + this.MenuID  + "' data-menu-target='" + this.Target +"' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "' display-name='" + this.MultiDisplayName + "'>";				

					menuHtml += "<a href='javascript:;' onclick='" + clickMethodName + "(this);return false;'class='sub' ><span>" + this.DisplayName + " </span></a>";
					menuHtml += "</div>"
					if(v.Sub != undefined && v.Sub.length > 0){		
						menuHtml += "<div class= '"+subListClass+"' >";				
						$(v.Sub).each(function () {
							menuHtml += "<div class= '"+this.IconClass+"' data-menu-id='" + this.MenuID  + "' data-menu-target='" + this.Target +"' data-menu-alias='" + this.Reserved1 + "' data-menu-url='" + encodeURIComponent(this.URL) + "' display-name='" + this.MultiDisplayName + "'>";				
							menuHtml += "<a href='javascript:;' onclick='" + clickMethodName + "(this);return false;'class='sub' ><span>" + this.DisplayName + " </span></a>";
							menuHtml += "</div>"
							
						});
						menuHtml += "</div>";				
					}	
					if (v.Sub != undefined && v.Sub.length > 0)		menuHtml += "</div>";
				});
				
				menuHtml += "</ul>"
			}
		}
		
		menuHtml += "</li>";
	});
	return menuHtml;
	
	
}
/*
 * 1. 즐겨찾기 테이블 생성 및 java code 개발 필요함.
 * 2. Socket 또는 ajax polling을 이용한 Count에 대한 실시간 처리 구현 필요함.
 * */
CoviMenu.prototype.drawQuick = function(data){
	var $this = this;
	
	var menuHtml = "";
	$(data).each(function(){
		if(this.MenuID == "Integrated"||  this.MenuID == "Mention"){
			menuHtml += "<li class='" + this.IconClass + "' data-menu-id='" + this.MenuID + "'>";
			menuHtml += "	<a id='quick_" + this.MenuID  + "' onclick='CoviMenu_clickQuickIntegrated(\"" + this.MenuID + "\")'>";
		}else{
			menuHtml += "<li class='" + this.IconClass + "' data-menu-id='" + this.MenuID + "' data-menu-url='" + encodeURIComponent(this.URL) + "'>";
			menuHtml += "	<a id='quick_" + this.MenuID  + "'onclick='CoviMenu_ClickQuick(this)'>";
		}
		menuHtml += "		<span class='icon'>" + this.DisplayName + "</span>";
		
		var count =  $this.isEmpty(this.Count) ? 0 : this.Count;
	
		menuHtml += "		<span id='quickCnt_" + this.MenuID  + "' class='countStyle'>" + count + "</span>";
		menuHtml += "	</a>";
		menuHtml += "	<span class='toolTip'>" + this.DisplayName + "</span>";
		
		//통합알림
		if(this.MenuID == "Integrated" ||  this.MenuID == "Mention" ){
			menuHtml += '<div id="integratedAlarmCont"  class="combineNoticeCont ">';
			menuHtml += '		<div class="combineTop">';
			menuHtml += '			<h3>'+(this.MenuID == "Integrated"?Common.getDic("lbl_portal_IntegratedNotify"):"Mention")+'</h3>'; // 통합알림
			menuHtml += '			<div class="todoBtnBox">';		
			menuHtml += '				<a class="btnRemoveType02" onclick="CoviMenu_deleteAllAlarm(\'' + this.MenuID + '\'); ">삭제</a>';									
			menuHtml += '				<a class="btnRepeatType02" onclick="CoviMenu_getIntegratedList(\'' + this.MenuID + '\');">리피트</a>';									
			menuHtml += '				<a class="btnXCloseType02 " onclick="CoviMenu_clickQuickIntegrated(\'' + this.MenuID + '\');"></a>';
			menuHtml += '			</div>';
			menuHtml += '		</div>';
			menuHtml += '		<div class="combineBottom mScrollV scrollVType01">';
			menuHtml += '			<ul class="todoListCont combineListCont" id="integratedUL" ></ul>';
			menuHtml += '			<p id="noIntegratedAlarm" style="display:none;" class="noSearchListCont">조회할 목록이 없습니다.</p>';
			menuHtml += '		</div>';			
			menuHtml +='</div>';
		}
		menuHtml += "</li>";
	});
	return menuHtml;
}

CoviMenu.prototype.drawQuickSet = function(target){
	var html = '';
	html += '<li>';
	html += '	<a class="btnFavAdd">즐겨찾기 추가</a>';
	html += '</li>';
	//html += '<li class="btnFavSetView">';
	//html += '	<a class="btnFavSet">즐겨찾기 설정</a>';
	//html += '	<ul class="favSetList">';
	//html += '		<li><a href="javascript:;">최신순</a></li>';
	//html += '		<li class="select"><a href="javascript:;">가나다순</a></li>';
	//html += '		<li><a href="javascript:;">사용자 설정</a></li>';
	//html += '	</ul>';
	//html += '</li>';
	
	$(target).html(html);
	
	//click event 처리
	$(target + ' .btnFavAdd').on('click', function(e){
		e.preventDefault();
		
		//popup 호출
		var url = "";
		url += "/covicore/control/callFavoriteAdd.do?"
		url += "lang=ko&";
		url += "callback=CoviMenu_FavoriteAddCallback";
		
		Common.open("", "FavoriteAdd", Common.getDic("lbl_Enjoy_Estab"), url, "595px", "323px", "iframe", true, null, null, true);
		
	});
	
	var $btnFavSet = $(target + ' .btnFavSet');
	$btnFavSet.on('click', function(e){
		e.preventDefault();
		
		if($(this).closest('li').hasClass('active')){
			$(this).closest('li').removeClass('active');
		}else {
			$(this).closest('li').addClass('active');
		}
	});
	
	var $btnFavListSet = $(target + ' .favSetList>li');
	$btnFavListSet.on('click', function(){
		if($(this).hasClass('select')){
			$btnFavListSet.removeClass('select');
		}else {
			$btnFavListSet.removeClass('select');
			$(this).addClass('select');
		}				
	});
	
}

CoviMenu.prototype.getQuickData = function(){
	var $this = this;
	var arrQuick = Common.getBaseCode("QuickNotification").CacheData;
	var lang = Common.getSession("lang");
	var quickMenuData= new Array();
	
	$.ajax({
		type:"POST",
		url:"/covicore/quick/getUserQuickMenu.do",
		async:false,
		success : function (obj) {
			if(obj.status == "SUCCESS"){
				var arrShowList = $this.isEmpty(obj.data.ShowList) ? new Array() :  obj.data.ShowList.split(";");

				$.each(arrShowList, function(idx, confCode){
					$.each(arrQuick, function(idx,quickObj){
						if(confCode == quickObj.Code && confCode != ""){
							var menuObj = new Object();
							menuObj.URL = quickObj.Reserved1;
							menuObj.MenuID = confCode;
							menuObj.DisplayName = CFN_GetDicInfo(quickObj.MultiCodeName, lang);
							menuObj.IconClass  = quickObj.Reserved3;
							quickMenuData.push(menuObj);
						}
					});
				});
				
				return true;
			}
		},
		error : function(response, status, error){
			CFN_ErrorAjax("/covicore/quick/getUserQuickMenu.do", response, status, error);
		}
	});
	
	return quickMenuData;
}


CoviMenu.prototype.setQuickInit= function(){
	var $this = this;
	var menuListStr = "";	
	$("#quickContainer").children("li").each(function(idx,obj){
		menuListStr += ($(obj).attr("data-menu-id") +";") ;
	});
	
    $.ajax({ 
    	type : "POST",
		url: "/groupware/longpolling/getQuickData.do",
		data : { "menuListStr" : menuListStr },
		success: function(data){ 
			for(var strKey in data.countObj) {
				$("#quickCnt_"+strKey).text(data.countObj[strKey]);
			}
		}, 
		error:function(response, status, error){
			
			if(status == "parsererror") {
				location.href = "/covicore/login.do";
			} else if (status == "error") {
				Common.Warning("네트워크 상태가 원할하지 않아 페이지를 새로고침합니다.<br/>(ex. 절전모드 사용, 네트워크 통신장애)", "안내", function() {document.location.reload();});
			}
			// location.href = "/covicore/login.do";
			//longpolling 방식 alert 주석 처리
			//CFN_ErrorAjax("/groupware/longpolling/getQuickData.do", response, status, error);
		},
		dataType: "json", 
		timeout: 10000 //10 sec 
    });

	if(Common.getBaseConfig("isUseExchMail") == "Y" && Common.getBaseConfig("isUseMail") == "Y"){
		// 메일 카운트
    	$.ajax({ 
    		type : "POST",
			url: "/groupware/portal/getUnMailCount.do",
			success: function(data){ 
				$("#quickCnt_Mail").text(data.count);
			}
    	});
	}
}


CoviMenu.prototype.setQuickLongPolling = function(){
	var $this = this;
	var menuListStr = "";
	
	$("#quickContainer").children("li").each(function(idx,obj){
		menuListStr += ($(obj).attr("data-menu-id") +";") ;
	});
	
	 setTimeout(function(){
	        $.ajax({ 
	        	type : "POST",
				url: "/groupware/longpolling/getQuickData.do",
				data : { "menuListStr" : menuListStr },
				success: function(data){ 
					for(var strKey in data.countObj) {
						$("#quickCnt_"+strKey).text(data.countObj[strKey]);
					}
				}, 
				error:function(response, status, error){
					
					if(status == "parsererror") {
						location.href = "/covicore/login.do";
					} else if (status == "error") {
						Common.Warning("네트워크 상태가 원할하지 않아 페이지를 새로고침합니다.<br/>(ex. 절전모드 사용, 네트워크 통신장애)", "안내", function() {document.location.reload();});
					}
					// location.href = "/covicore/login.do";
					//longpolling 방식 alert 주석 처리
					//CFN_ErrorAjax("/groupware/longpolling/getQuickData.do", response, status, error);
				},
				dataType: "json", 
				complete: $this.setQuickLongPolling(), 
				timeout: 1500 //10 sec --> 3sec 2019.07.08 --> 1.5sec 2019.07.16
	        });
	    }, 150000);//50 sec --> 90sec 2019.07.08 --> 150sec 2019.07.16
}

/*
 * 개인 비서 컨트롤
 * 1. data 포맷에 대한 확정이 필요
 * 2. balloon 영역에 대한 처리?
 * */
CoviMenu.prototype.drawSecretary = function(target, data){
	var html = '';
	html += '<a href="javascript:;" class="balloon"></a>';
	html += '<div class="secretaryView">';
	html += '	<div class="secretaryCont">';
	html += '		<a href="javascript:;" class="btnSerImg" onclick="CoviMenu_SecretaryOnOff(this);">';
	html += '			<strong>개인비서</strong>';
	html += '		</a>';
	html += '		<a href="javascript:;" class="btnSecOnOff" onclick="CoviMenu_SecretaryOnOff(this);"></a>';
	html += '	</div>';
	html += '	<span class="cycleNew new">N</span>';
	html += '</div>';
	
	$(target).html(html);
}

/*
 * 개인 정보 영역
 * 1. data 포맷에 대한 확정이 필요
 * 		data : {
 * 				PhotoPath : "/covicore/resources/images/test/person1.png"
 * 				Name : "김소현",
 * 				BaseGroupInfo : [ {} ,{}  ], //겸직 정보를 포함한  json array
 * 				Themes : [] //테마 정보 json array
 * 			   }
 * 2. data 처리 부분은 typed가 아닌 animation 처리를 하는 편이...
 * */

CoviMenu.prototype.drawMyInfo = function(target, data){
	//set locale
	var sessionLang = Common.getSession("lang");
	var sessionUR_ThemeType = Common.getSession("UR_ThemeType");
	
	if(sessionUR_ThemeType == undefined || sessionUR_ThemeType == "" ){
		sessionUR_ThemeType = "blue";
	}
	
	if(typeof sessionLang != "undefined" && sessionLang != ""){
		this.config.lang = sessionLang;
	}
	
	//set dictionary
	var localDictionary =  Common.getDicAll(["lbl_MyInfo", "lbl_TurnOnNotify", "lbl_MobileAlert", "lbl_ChangeOfficeConcurrently", "lbl_ChangeTheme", 
	                                         "lbl_ChangePortal", "lbl_SetMyInfo", "lbl_CacheInitialization", "lbl_Logout"]);

	var detpNm = "";
	for(var i=0;i<data["baseGroupInfo"].length;i++){
		if(Object.keys(data["baseGroupInfo"][i])[0] == "detpNm"){
			detpNm = Object.values(data["baseGroupInfo"][i])[0];
		}
	}
	/*
	//grid상단에 기본검색,상세검색에 포함되는 input항목에 Enter 조회
	$("#searchInput, div[class=searchInner] input").keydown(function (key) {
		  if (key.keyCode == 13) {
			  onClickSearchButton();
		  }
	});*/

	var html = '';
	html += '<a class="myInfoViewBtn">';
	html += '	<div class="photo">';
	html += '		<img id="userImg" src="/covicore/common/photo/photo.do?img='+encodeURIComponent(data.photoPath) + ( data.photoPath != '' ?  '&time=' + new Date().getTime() : '' ) + '" onerror="coviCmn.imgError(this, true);" alt="ProfilePhoto">';
	html += '	</div>';
	html += '	<p class="dep">';
	html += '		<strong>'+data.name+(data.licName != null && data.licName != ""?'['+data.licName+']':'')+'</strong> <span>'+detpNm+'</span>';
	html += '	</p>';
	html += '	<article class="myInfoView">';
	html += '		<span class="myInfoViewCont">내정보보기</span>';
	html += '	</article>';
	html += '</a>';
	html += '<ul id="myInfoViewList" class="myInfoViewList">';
	
	html += '	<li><a href="javascript:;" onclick="CoviMenu_CallMyInfo();return false;">' + localDictionary["lbl_MyInfo"] + '</a></li>';
	html += '	<li id="liLanguage"></li>';			//언어변경
	
	//겸직 변경
	html += '   <li id="liPosition" class="">';
	html += '		<a class="arrowBtn01">' + localDictionary["lbl_ChangeOfficeConcurrently"] + '</a>';
	html += '   </li>';
	
	if(data.themeUsed != 'N'){
		html += '	<li>';
		html += '		<a class="arrowBtn01">' + localDictionary["lbl_ChangeTheme"] + '</a>';
		html += '		<ul class="">';			
		
		var themeColor = Common.getBaseCode("ThemeColor");
		
		$(themeColor.CacheData).each(function(idx, obj){
			html += '			<li class="radioStyle01"><input type="radio" id="radio_'+ obj.Code + '" name="themeColor" value ="' + obj.Code + '" ' + (obj.Code == sessionUR_ThemeType ? 'checked="checked"' : '') +  ' onclick="CoviMenu_setMyInfo(\'Theme\',\'' + obj.Code + '\'); "/><label for="radio_' + obj.Code + '"><span class="' + obj.Reserved1 + '"></span>' + Common.getBaseCodeDic("ThemeColor", obj.Code)+ '</label></li>';
		});
		
		html += '		</ul>';
		html += '	</li>';
	}

	if (data["portalpage"] != undefined && data["portalpage"].length>1){
		html += '	<li>';
		html += '		<a  href="javascript:;" onclick="CoviMenu_GetPortalList()" class="arrowBtn01">' + localDictionary["lbl_ChangePortal"] + '</a>';
		html += '		<ul class="" id="portal_list">';			
		html += '		</ul>';
		html += '	</li>';
	}	


	html += '	<li id="liLast" class="liLast">';
	html += data.managerSite;
	html += '		<p><a href="javascript:;" onclick="CoviMenu_GetLeftState(\'/covicore/layout/left.do?CLSYS=privacy&CLMD=user&CLBIZ=Privacy\');return false;">' + localDictionary["lbl_SetMyInfo"] + '</a></p>';
	html += '		<p><a href="javascript:;" onclick="coviCmn.clearCache(true, true);">' + localDictionary["lbl_CacheInitialization"] + '</a></p>';
	
	//통합 인증일 경우 로그아웃 사용 X
	if(Common.getSecurityProperties("loginAuthType") != "Unify"){
		html += '	<p><a href="javascript:;" onclick="XFN_LogOut();">' + localDictionary["lbl_Logout"] + '</a>	</p>';
	}
	
	html += '	</li>';
	html += '</ul>';
	
	$(target).html(html);
	
	CoviMenu_LangCodeList();		//언어변경 메뉴 생성
	CoviMenu_BaseGroupList();		//겸직변경 메뉴 생성
	//이벤트 처리
	//$("#userImg").error(function() {
    //    $("img").attr("src",  Common.getBaseConfig('ProfileImagePath',1)+"noimg.png");
    //});
	
	$(target + ' .myInfoViewBtn').on('click', function(){
		var view = $(this).closest('.myInfo');

		if(view.hasClass('active')){
			view.removeClass('active');
		} else {
			view.addClass('active');
		} 
	});
	
	$(target + ' .arrowBtn01').on('click', function(){		
		if($(this).hasClass('on')){
			$(this).closest('li').removeClass('on');
			$(this).removeClass('on');
		}else {
			$(this).addClass('on');
			$(this).closest('li').addClass('on');
		}
	});
	
	$(target + ' .alarm').on('click', function(){
		if($(this).find('.onOffBtn').hasClass('on')){
			$(this).find('.onOffBtn').removeClass('on');
		} else {
			$(this).find('.onOffBtn').addClass('on');
		} 
	});
	
}

CoviMenu.prototype.drawSimpleMyInfo = function(target, data, option){

	var _useTheme = option.useTheme;
	var _useAlarm = option.useAlarm;
	var _isMobile = option.isMobile;
	var _useLang = option.useLang;
	var _useMultiJob = option.useMultiJob;
	
	//set locale
	var sessionLang = Common.getSession("lang");
	if(typeof sessionLang != "undefined" && sessionLang != ""){
		this.config.lang = sessionLang;
	}
	
	//set dictionary
	var localDictionary =  Common.getDicAll(["lbl_MyInfo", "lbl_TurnOnNotify", "lbl_MobileAlert", "lbl_ChangeOfficeConcurrently",
											 "lbl_ChangeTheme", "lbl_SetMyInfo", "lbl_CacheInitialization", "lbl_Logout"]);
	
	var detpNm = "";
	for(var i=0;i<data["baseGroupInfo"].length;i++){
		if(Object.keys(data["baseGroupInfo"][i])[0] == "detpNm"){
			detpNm = Object.values(data["baseGroupInfo"][i])[0];
		}
	}
	//grid상단에 기본검색,상세검색에 포함되는 input항목에 Enter 조회
	$("#searchInput, div[class=searchInner] input").keydown(function (key) {
		  if (key.keyCode == 13) {
			  onClickSearchButton();
		  }
	});
	
	var html = '';
	html += '<a class="myInfoViewBtn">';
	html += '	<div class="photo">';
	html += '		<img id="userImg" src="/covicore/common/photo/photo.do?img='+encodeURIComponent(data.photoPath) + ( data.photoPath != '' ?  '&time=' + new Date().getTime() : '' ) + '" onerror="coviCmn.imgError(this, true);" alt="ProfilePhoto">';
	html += '	</div>';
	html += '	<p class="dep">';
	html += '		<strong>'+data.name+'</strong> <span>'+detpNm+'</span>';
	html += '	</p>';
	html += '	<article class="myInfoView">';
	html += '		<span class="myInfoViewCont">내정보보기</span>';
	html += '	</article>';
	html += '</a>';
	html += '<ul class="myInfoViewList">';
	html += '	<li><a href="javascript:;" onclick="CoviMenu_CallMyInfo();return false;">' + localDictionary["lbl_MyInfo"] + '</a></li>';
		
	if(_useLang == 'Y'){
		html += '	<li id="liLanguage"></li>';			//언어변경
	}
	
	if(_useAlarm == 'Y'){
		html += '	<li id="liAlarmSetting" class="">';
		html += '		<p class="alarm">';
		html += '			<span>' + localDictionary["lbl_TurnOnNotify"] + '</span> <a class="onOffBtn"><span>알람켜기</span></a>';
		html += '		</p>';
		html += '		<p class="alarm">';
		html += '			<span>' + localDictionary["lbl_MobileAlert"] + '</span></span> <a class="onOffBtn on"><span>알람끄기</span></a>';
		html += '		</p>';
		html += '	</li>';
	}
	
	if(_useMultiJob == 'Y'){
		html += '   <li id="liPosition" class="">';
		html += '		<a class="arrowBtn01">' + localDictionary["lbl_ChangeOfficeConcurrently"] + '</a>';
		html += '   </li>';
	}
	
	if(_useTheme == 'Y'){
		html += '	<li>';
		html += '		<a class="arrowBtn01">' + localDictionary["lbl_ChangeTheme"] + '</a>';
		html += '		<ul class="">';
		html += '			<li class="radioStyle01"><input type="radio" id="radio01" name="themeColor" onclick="CoviMenu_setTheme(\'blue\');"/><label for="radio01"><span class="busi"></span>비지니스</label></li>';
		html += '			<li class="radioStyle01"><input type="radio" id="radio02" name="themeColor" onclick="CoviMenu_setTheme(\'red\');"/><label for="radio02"><span class="ardor"></span>열정</label></li>';
		html += '			<li class="radioStyle01"><input type="radio" id="radio03" name="themeColor" onclick="CoviMenu_setTheme(\'green\');"/><label for="radio03"><span class="nature"></span>네츄럴</label></li>';
		html += '		</ul>';
		html += '	</li>';
	}
	
	html += '	<li id="liLast" class="liLast">';
	html += data.managerSite;
	html += '		<p><a href="javascript:;" onclick="CoviMenu_GetLeftState(\'/covicore/layout/left.do?CLSYS=privacy&CLMD=user&CLBIZ=Privacy\');return false;">' + localDictionary["lbl_SetMyInfo"] + '</a></p>';
	html += '		<p><a href="javascript:;" onclick="coviCmn.clearCache();">' + localDictionary["lbl_CacheInitialization"] + '</a></p>';
	html += '		<p><a href="javascript:;" onclick="XFN_LogOut();">' + localDictionary["lbl_Logout"] + '</a>	</p>';
	html += '	</li>';
	html += '</ul>';
	
	$(target).html(html);
	
	if(_useLang == 'Y'){
		CoviMenu_LangCodeList();		//언어변경 메뉴 생성
	}
	
	if(_useMultiJob == 'Y'){
		CoviMenu_BaseGroupList();		//겸직변경 메뉴 생성
	}
	
	$(target + ' .myInfoViewBtn').on('click', function(){
		var view = $(this).closest('.myInfo');
		if(view.hasClass('active')){
			view.removeClass('active');
		} else {
			view.addClass('active');
		} 
	});
	
	$(target + ' .arrowBtn01').on('click', function(){		
		if($(this).hasClass('on')){
			$(this).closest('li').removeClass('on');
			$(this).removeClass('on');
		}else {
			$(this).addClass('on');
			$(this).closest('li').addClass('on');
		}
	});
	
	$(target + ' .alarm').on('click', function(){
		if($(this).find('.onOffBtn').hasClass('on')){
			$(this).find('.onOffBtn').removeClass('on');
		} else {
			$(this).find('.onOffBtn').addClass('on');
		} 
	});
	
}

//전체 메뉴 표시
CoviMenu.prototype.drawSiteMap = function(data, clickMethodName, subListClass){
	$(data).each(function(){
		if(this.IsUse!="N"){//사용하기 유무 Y일때만
			var ulWrap = $('<ul/>');
			var liBigTitle = $('<li class="bigTitle"/>').attr({'data-menu-id':this.MenuID, 'data-menu-alias':this.Reserved1, 'data-menu-url': encodeURIComponent(this.URL),'data-menu-target': this.Target });
				liBigTitle.append($('<a onclick="'+ clickMethodName +'(this);return false;"/>').text(this.DisplayName));
			ulWrap.append(liBigTitle);
			
			if(this.Sub != undefined && this.Sub.length > 0){
				$(this.Sub).each(function () {
					var liSmallTitle = $('<li class="'+ subListClass +'"/>').attr({'data-menu-id':this.MenuID, 'data-menu-alias':this.Reserved1, 'data-menu-url': encodeURIComponent(this.URL),'data-menu-target': this.Target});
						liSmallTitle.append($('<a onclick="'+ clickMethodName +'(this);return false;"/>').text(this.DisplayName));
					ulWrap.append(liSmallTitle);
				});
			}
			$('#totalSiteMap .allServiceCont:nth('+ this.SiteMapPosition +')').append(ulWrap);
		}		
	});
}

//CoviMenu.prototype.drawSiteMap = function(data, clickMethodName, subListClass){
//	var divAllServiceCont = $('<div class="allServiceCont">');
//	var heightCondition = 0;
//	$(data).each(function(i){
//		var ulWrap = $('<ul position="'+ i +'"/>');
//		var liBigTitle = $('<li class="bigTitle"/>').attr({'data-menu-id':this.MenuID, 'data-menu-alias':this.Reserved1, 'data-menu-url': encodeURIComponent(this.URL)});
//			liBigTitle.append($('<a onclick="'+ clickMethodName +'(this);return false;"/>').text(this.DisplayName));
//		ulWrap.append(liBigTitle);
//		
//		if(this.Sub != undefined && this.Sub.length > 0){
//			$(this.Sub).each(function () {
//				var liSmallTitle = $('<li class="'+ subListClass +'"/>').attr({'data-menu-id':this.MenuID, 'data-menu-alias':this.Reserved1, 'data-menu-url': encodeURIComponent(this.URL)});
//					liSmallTitle.append($('<a onclick="'+ clickMethodName +'(this);return false;"/>').text(this.DisplayName));
//				ulWrap.append(liSmallTitle);
//			});
//		}
//		divAllServiceCont.append(ulWrap);
//		$('#totalSiteMap').append(divAllServiceCont);
//		
//		heightCondition += ulWrap.height();
//		if(heightCondition > 270){
//			divAllServiceCont.find('ul:last').remove();
//			divAllServiceCont = $('<div class="allServiceCont"/>');
//			divAllServiceCont.append(ulWrap);
//			heightCondition = 0;
//		}
//	});
//}

//사이트 링크 목록표시
CoviMenu.prototype.drawSiteLink = function(){
	var siteLinkList = Common.getBaseCode('SiteLinkList');
	var divAllServiceCont = $('<div class="allServiceCont mScrollV scrollVType01" />');
	var ulWrap = $('<ul class="siteLInkList" />');
	if(siteLinkList != undefined){
		$.each(siteLinkList.CacheData, function(i, item){
			ulWrap.append($('<li/>').append( $('<a class="'+item.Reserved2+'" href="'+item.Reserved1+'" '+ (item.Reserved3 != ''? "target="+item.Reserved3 : '') +'  />').text( CFN_GetDicInfo(item.MultiCodeName) ) ));
		});
		divAllServiceCont.append(ulWrap);
		$('#totalSiteMap').append(divAllServiceCont);
	}
}

function CoviMenu_CallMyInfo(){
	Common.open("","MyInfo",Common.getDic("lbl_UserProfile_00"),"/covicore/control/callMyInfo.do","610px","500px","iframe",true,null,null,true);
}

function CoviMenu_FavoriteAddCallback(data){
	var opt = {
			lang : "ko",
			isPartial : "true"
	};
	var coviMenu = new CoviMenu(opt);
	
	var hardCodedQuickData = coviMenu.getQuickData();
	coviMenu.render("#quickContainer", hardCodedQuickData, "defaultQuick");
	coviMenu.setQuickInit();
}

//통합 알림 클릭
function CoviMenu_clickQuickIntegrated(menuID){
	if($("li[data-menu-id="+menuID+"]").hasClass('active')){
		$("li[data-menu-id="+menuID+"]").removeClass('active');
	}else {
		CoviMenu_getIntegratedList(menuID);
		$("li[data-menu-id="+menuID+"]").addClass('active');
	}
}

//통합 알림 데이터 조회
function CoviMenu_getIntegratedList(menuID){	
	$.ajax({
		url: "/covicore/quick/getIntegratedList.do",
	    type: "POST",
	    data:{"alarmType":menuID},
	    success:function(data){	    	
    		if(data.status=='SUCCESS'){
    			CoviMenu.prototype.setQuickInit();
				CoviMenu.prototype.setQuickLongPolling();
    			CoviMenu_drawInteratedList(data.list, menuID);    			
    		}
    	 },
    	 error:function(response, status, error){
    	      CFN_ErrorAjax("/covicore/quick/getIntegratedList.do", response, status, error);
    	 }
	});
}

//포탈 리스트 조회
function CoviMenu_GetPortalList(){
	var sessionUR_InitPortal = Common.getSession("UR_InitPortal");
	$.ajax({
		url: "/groupware/privacy/getMyPortalList.do",
	    type: "POST",
	    success:function(data){
	    	
    		if(data.status=='SUCCESS'){
    			var html = "";
    			for (var i=0; i < data.list.length; i++){
    				var obj = data.list[i];
    				html += '			<li class="radioStyle01"><input type="radio" id="radio2_'+ obj["PortalID"] + '" name="portalColor" value ="' + obj["PortalID"] + '" ' + (obj["PortalID"] == sessionUR_InitPortal ? 'checked="checked"' : '') +  ' onclick="CoviMenu_setMyInfo(\'Portal\',\'' + obj["PortalID"]+ '\'); "/><label for="radio2_' + obj["PortalID"] + '"><span class="busi"></span>' + obj["DisplayName"]+ '</label></li>';
    			}
    			
    			$("#portal_list").html(html);    			
    		}
    	 },
    	 error:function(response, status, error){
    	      CFN_ErrorAjax("/groupware/getMyPortalList.do", response, status, error);
    	 }
	});
}

//통합 알림 리스트 그리기
function CoviMenu_drawInteratedList(list, menuID){
	var html = '';	
	if(list.length > 0){		
		$("li[data-menu-id="+menuID+"] #noIntegratedAlarm").hide();
		$("li[data-menu-id="+menuID+"] #integratedUL").show();		
		$.each(list, function(idx, obj){
			var alarmTitle = (menuID=="Mention"?"":"[" + Common.getBaseCodeDic("TodoCategory" , obj.Category) + "-" + Common.getBaseCodeDic("TodoMsgType", obj.MsgType) + "] ") + obj.Title;
			
			html +='<li class="'+ CoviMenu_getIntegratedClass(obj.Category) + '">';
			html +='	<div class="todTitle">';
			html +='		<a '+(obj.URL==null|| obj.URL==''?'style="cursor:cell"':'')+' onclick="CoviMenu_clickInteratedAlarm(\''+obj.AlarmID+'\',\''+obj.URL+'\',\''+ obj.Category +'\',\''+obj.FormPrefix+'\')">';
			html +='			<p class="tit" title="'+alarmTitle+'">'+alarmTitle+'</p>';
			html +='			<p class="todoInfo"><span>' +obj.PusherName + '</span><span class="date">' +CFN_TransLocalTime(obj.ReceivedDate)+ '</span></p>';
			html +='		</a>';
			html +='	</div>';
			html +='	<a class="todo_layer_list_del" onclick="CoviMenu_deleteEachAlarm(' + obj.AlarmID+ ',\'' + menuID+ '\')" style="z-index: 2;" ></a>';
			html +='</li>';
		});
		
		$("li[data-menu-id="+menuID+"] #integratedUL").html(html);
		
	}else{
		$("li[data-menu-id="+menuID+"] #noIntegratedAlarm").show();
		$("li[data-menu-id="+menuID+"] #integratedUL").hide();
	}
	
}

function CoviMenu_getIntegratedClass(category){
	var retClass = '';
	
	if(category == undefined){
		return '';
	}
	
	switch(category.toUpperCase()){
		case 'MAIL' :
			retClass = 'todoListMail';
			break;
		case 'APPROVAL' :
			retClass = 'todoListReport';
			break;
		case 'SCHEDULE' :
			retClass = 'todoListMeeting';
			break;
		case 'RESOURCE' :
			retClass = 'todoListReservation';
			break;
		case 'SURVEY' :
			retClass = 'todoListSurvey';
			break;
			break;
		case 'WORKREPORT' :
			retClass = 'todoListWork';
			break;
		case 'COMMUNITY' :
			retClass = 'todoListCommunity';
			break;
		case 'TIMESQUARE' :
			retClass = 'todoListDocControl';
			break;
		case 'CHECKLIST':
			retClass = 'todoListChekList';
			break;
		case 'SOCIAL' : 
		case 'BOARD' :
		case 'TASK' :
			retClass = 'todoListDocControl';
			break;
		default:
			retClass = 'todoListDocControl';
			break;
			
	}
	
	return retClass;
}

function CoviMenu_SecretaryOnOff(elem){
	var $this = $(elem);
	var parentCont = $this.closest('.secretary_cont');
	if(parentCont.hasClass('off')){
		parentCont.removeClass('off');
		$('.secretaryCont').addClass('ani');
		var typed = new Typed('.balloon', {
//			strings: ['<p><strong>김소현 과장님</strong>안녕하십니까.</p><p>기한이 지난 작업이 <span class="col_red">3</span>건 있습니다.</p>'],
			strings: ['<p>개인비서 기능은 준비중입니다.</p>'],
			typeSpeed: 20,
			backSpeed: 0,
			showCursor:false,
			fadeOut: true,
			onStringTyped: function() {
				$('.secretaryCont').removeClass('ani');
			}
		});
		
	}else{
		parentCont.addClass('off');
		$('.balloon').children('p').remove();
	}
}
//통합알림 선택확인(알람읽음처림)
function CoviMenu_clickInteratedAlarm(alarmID, url, category, elm){
	if(url != '' && url != null &&  url != 'undefined'){
		$(elm).closest('div.isUnRead').removeClass('isUnRead').addClass('isRead');
		
		// 연결할 url의 쿼리 스트링 분석 (커뮤니티 여부 확인용)
		var urlSearch = url.split('?')[1]
		var queryStr = JSON.parse('{"' + ((urlSearch) ? urlSearch.replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') : '') + '"}');

		if(url.indexOf('/approval/approval_Form.do') > -1) {
			// 결재 양식의 경우 window popup으로 호출
			var pWidth =  IsWideOpenFormCheck(arguments[3]) ? 1070 : 790;
			var pHeight = $(window).height();
			var centerPosX = $(window).width() / 2 - (pWidth / 2);
			var centerPosY = $(window).height() / 2 - (pHeight / 2);
			
			var popOption = 'width=' + pWidth + ',height=' + pHeight + ',location=no,menubar=no,status=no,resizable=yes,scrollbars=yes,toolbar=no,top=' + centerPosY + ',left=' + centerPosX;

			window.open(url , 'alarm'+alarmID, popOption);
		}
		else if(url.indexOf('/mail/userMail/goMailWindowPopup.do?') > -1) {
			//메일 읽음 창 일경우 window popup으로 호출
			window.open(url, 'alarm'+alarmID, "height=700, width=1200, resizable=yes");
		}
		else if(url.indexOf('/groupware/collabTask/CollabTaskPopup.do') > -1) {
			window.open(url , 'alarm'+alarmID, "height=1200, width=900, resizable=yes");
		}
		else if(queryStr.communityId && queryStr.communityId != 'undefined' && queryStr.communityId != '0') {
			// 커뮤니티에서 등록한 설문인 경우 window popup으로 호출. 윈도우 창은 커뮤니티와 동일하게 가져옴
			var specs = "left=10,top=10,width=1050,height=900";
			specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
			window.open(url , 'alarm'+alarmID, specs);
		}
		else {
			window.open(url , 'alarm'+alarmID);
		}
		
		$.ajax({
			url: "/covicore/quick/updateAlarmIsRead.do",
			type: "POST",
			data: { "alarmID" : alarmID	},
			success:function(data){
				if(data.status=="SUCCESS"){
					// 스타일 읽음 처리
					// CoviMenu_getIntegratedList();
					// CoviMenu.prototype.setQuickInit();
					// CoviMenu.prototype.setQuickLongPolling();
				}					
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/quick/updateInteratedIsRead.do", response, status, error);
			}
		});
	}else{
		// 스타일 읽음 처리
		$(elm).closest('div.isUnRead').removeClass('isUnRead').addClass('isRead');
//		Common.Warning("연결된 페이지가 없습니다.");
	}
	
}

//통합 알람 전체 지우기
function CoviMenu_deleteAllAlarm(menuID){
	Common.Confirm(Common.getDic("msg_TodoList_02"),"Inform",function(result) {
		if(result==true){
			$.ajax({
				url: "/covicore/quick/deleteAllAlarm.do",
				type: "POST",
			    data:{"alarmType":menuID},
				success:function(data) {
					if(data.status=="SUCCESS"){
						CoviMenu_getIntegratedList(menuID);
						CoviMenu.prototype.setQuickInit();
						// CoviMenu.prototype.setQuickLongPolling();
					}					
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/quick/deleteAllAlarm.do", response, status, error);
				}
			});
		}else{
			return false;
		}
	});
}

function CoviMenu_deleteEachAlarm(alarmID, menuID){
	$.ajax({
		url: "/covicore/quick/deleteEachAlarm.do",
		type: "POST",
		data: {"deleteID" : alarmID},
		success:function(data) {
			if(data.status=="SUCCESS"){
				CoviMenu_getIntegratedList(menuID);
				CoviMenu.prototype.setQuickInit();
				// CoviMenu.prototype.setQuickLongPolling();
			}					
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/covicore/quick/deleteEachAlarm.do", response, status, error);
		}
	});
}


//Header Context Menu에서 사용자 개인 정보 설정: 언어변경, 겸직변경, 테마
//pType: Lang, ChangePosition ...
function CoviMenu_setMyInfo(pType, pValue) {//체크
	
	$.ajax({
		url : "/groupware/privacy/setMyInfo.do",
		data : {
			"type": pType,
			"value": pValue
		},
		type : "post",
		async : false,
		success : function(res) {
			if (res.status == "SUCCESS") {
				if(pType == "Lang"){
					//쿠키정보 변경
					coviCmn.setCookie("langCode", pValue, 1);
					coviCmn.setCookie("pValue", pValue, 365);
					coviCmn.clearLocalCache();
					coviStorage.clear("DICTIONARY"); // 로컬 스토리지의 Dictionary, DictionarySyncTime 삭제 - dyjo 2019.04.16
					location.reload();
					//coviCmn.clearCache();
				}else if (pType=="Portal"){
					coviCmn.clearLocalCache();
					$("#anchorLogo").get(0).click();
				}
				else if (pType=="ChangePosition"){
					//겸직 변경의 경우, 캐시초기화 후 포탈로 이동 처리. (겸직 변경으로 인해 권한이 없는 위치에서 리로드 되는 것 방지)
					coviCmn.clearCache('home');
				}
				else {
					coviCmn.clearCache(true, false);
				}
			} else {
				Common.Warning(res.message);
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/privacy/setMyInfo.do", response, status, error);
		}
	});
}

//언어 변경
function CoviMenu_LangCodeList(){
	var langCodeList = Common.getBaseCode('LanguageCode');
	var lang = Common.getSession("lang");
	var currentLanguage = Common.getDic("LanguageCode_" + lang);
	var returnHTML = $('<a class="btnLangSet arrowBtn01"/>').text(currentLanguage).prop("outerHTML");
	
	if(langCodeList != undefined && langCodeList != ""){
		var ulWrap = $('<ul/>');

		$.each(langCodeList.CacheData, function(i, item){
			var liWrap = $('<li class="radioStyle02"/>');
			var inputRadio = $('<input type="radio" name="langSet" onclick="CoviMenu_setMyInfo(\'Lang\',\'' + item.Code + '\'); "/>').attr('id', 'lang'+i);
			var labelLangCode = $('<label/>').attr('for', 'lang'+i).append($('<span/>'), item.CodeName);
			
			if(item.Code==lang) { inputRadio.attr('checked','checked'); }
				
			liWrap.append(inputRadio, labelLangCode);
			ulWrap.append(liWrap);
		});
		returnHTML += ulWrap.prop('outerHTML');
		//다국어 1개인 경우 숨김처리
		if(langCodeList.CacheData != undefined && langCodeList.CacheData.length < 2) $('#liLanguage').hide();
	}
	$('#liLanguage').append(returnHTML);
}

//겸직 변경 Element 생성
function CoviMenu_BaseGroupList(){
	$.ajax({
		type:"POST",
		data:{
		},
		url:"/groupware/privacy/getUserBaseGroupAll.do",
		async:false,
		success : function (data) {
			if(data.status == "SUCCESS"){
				//var returnHTML = $('<a class="arrowBtn01"/>').text("겸직변경").prop("outerHTML");
				var userBaseGroupID = Common.getSession("URBG_ID");
				if(data.list != undefined && data.list.length > 1){
					var ulWrap = $('<ul/>');
					$.each(data.list, function(i, item){
						var liWrap = $('<li class="radioStyle02"/>');
						var inputRadio = $('<input type="radio" name="conOf" onclick="CoviMenu_setMyInfo(\'ChangePosition\',' + item.Seq + '); "/>').attr('id', 'chk'+i);
						//var labelPosition = $('<label/>').attr('for', 'chk'+i).append($('<span/>'), item.DeptName + ' ' + item.JobLevelName);
						var labelPosition = $('<label/>').attr('for', 'chk'+i).append($('<span/>'), item.DeptName + "(" + item.CompanyName + ")");
						
						if(item.Seq==userBaseGroupID) { inputRadio.attr('checked','checked'); }
							
						liWrap.append(inputRadio, labelPosition);
						ulWrap.append(liWrap);
					});

					$('#liPosition').append(ulWrap);

				}
				else{//겸직없을 시 숨김처리
					$('#liPosition').hide()
				}
			}
		},
		error : function(response, status, error){
			CFN_ErrorAjax("/groupware/privacy/getUserBaseGroupAll", response, status, error);
		}
	});
	
	
}

/*
window.onbeforeunload = function(event) {
	var message = 'Are you sure you want to leave?';
	if (typeof event == 'undefined') {
		event = window.event;
	}
	if (event) {
		event.returnValue = message;
	}
	return message;
}
*/

/*
if (window.addEventListener) {
	window.addEventListener("keydown", CoviMenu_Onkeydown_Handler, false);
} else if (window.attachEvent) {
	window.attachEvent("onkeydown", CoviMenu_Onkeydown_Handler);
} else {
	window["onkeydown"] = CoviMenu_Onkeydown_Handler;
}
function CoviMenu_Onkeydown_Handler() {
    switch (event.keyCode) {
        case 116 : // 'F5'
            var currentState = CoviMenu_GetCurrentState();
    		
    		if(currentState != undefined){
    			event.returnValue = false;
                event.keyCode = 0;
                window.status = "We have disabled F5";
    			
    			CoviMenu_GetLeftState(currentState.leftUrl);
    			CoviMenu_GetContentState(currentState.url);
    		}
            break;
    }
}
*/

window.onpopstate = function(event) {
	if(event && event.state) {
		CoviMenu_PersistState(event.state);
	}
}

function CoviMenu_PersistState(state){
	//reload 방식으로 back, forward 처리 시
	location.href = state.url;
	
	/*
	var currentState = CoviMenu_GetCurrentState();
	var onpopState = state;
	
	if(currentState.biz == onpopState.biz){
		CoviMenu_GetContentState(onpopState.url);
	} else{
		//CoviMenu_GetLeftState(onpopState.leftUrl);
		//CoviMenu_GetContentState(onpopState.url);
	}
	*/
}

function CoviMenu_getParameterByName(name, url) {
	if (!url) url = window.location.href;
	name = name.replace(/[\[\]]/g, "\\$&");
	var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
		results = regex.exec(url);
	if (!results) return null;
	if (!results[2]) return '';
	return decodeURIComponent(results[2].replace(/\+/g, " "));
}

var g_stateHistory = [];
function CoviMenu_makeState(url){
	var stateObj;
	
	if(url != null && url != ''){
		stateObj = { 
				system : CoviMenu_getParameterByName('CLSYS', url),
				mode : CoviMenu_getParameterByName('CLMD', url),
				biz : CoviMenu_getParameterByName('CLBIZ', url),
				url : url,
				leftUrl : g_leftUrl
			};	
	}
	
	return stateObj;
}

function CoviMenu_SetState(state){
	g_stateHistory.push(state);
}

function CoviMenu_GetCurrentState(){
	return g_stateHistory[g_stateHistory.length - 1];
}

function CoviMenu_GetPrevState(){
	var urlObj;
	
	if(g_stateHistory.length > 1){
		urlObj = g_stateHistory[g_stateHistory.length - 2];
	}
	
	return urlObj;
}


function CoviMenu_SetLayout(currentURL, targetURL){
	//tab 처리
	var current = new Object(); //location.href  
	var target = new Object(); 
	current['CLBIZ'] = coviCmn.isNull(CoviMenu_getParameterByName('CLBIZ', currentURL), '').toLowerCase();	
	current['CLMD'] = coviCmn.isNull(CoviMenu_getParameterByName('CLMD', currentURL), '').toLowerCase();	
	target['CLBIZ'] = coviCmn.isNull(CoviMenu_getParameterByName('CLBIZ', targetURL), '').toLowerCase();	
	target['CLMD'] = coviCmn.isNull(CoviMenu_getParameterByName('CLMD', targetURL), '').toLowerCase();	

	if(target['CLMD'] == "user" || target['CLMD'] == "manage"){ //admin 은 모듈별 layout 동일
		//모듈 별 처리 
		if(current['CLBIZ'] == 'portal' && $("#left").length < 1 ){ // 포탈에서 다른 모듈로 이동 시
			//신규 포찰인 경우 
			$(".ui_portal").empty().hide();
			$("#wrap").show();
			$('.portalBodyWrap').removeClass('portal_wrap');
			var html = '';
			html += '<div id="left" class="commContLeft"></div><div id="contents" class="commContRight"><div id="tab"></div><div id="content"></div> </div>';
			if(Common.getBaseConfig("useWorkPortal") == "Y"){
				html += '<section id="work_portal" class="mainContent work_pop clearFloat" style="right: -100%;"></section>'
				html += '<div class="btn_work close"> <a href="#"></a> <span class="toolTip2">기본포탈</span> </div>';
				html += '<div class="btn_work open"> <a href="#"></a> <span class="toolTip1">업무포탈</span> </div>';
			}
           $("section.commContent").html(html);
           
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
		}
		
		if(target['CLBIZ'] =="mail"){ 
			$(".commContRight").attr("id", "divMailCommContRight");
		}else{
			$(".commContRight").removeAttr("id");
			$('#mailTapMoreItems').empty();
			$('#mailTabListDiv').empty();
		}
		
		if(target['CLBIZ'] =="account"){
			$('#content').addClass('accountContent');
			$('#tab').addClass('accountTab');
		}else{
			$('#eAccountTabListDiv').empty();
    		$('#eAccountTapMoreItems').empty();
    		$('#content').removeClass('accountContent');
    		$('#tab').removeClass('accountTab');
		}
		
		//tab 처리
		if(['account'].includes(target['CLBIZ'])){
			$('#tab').show();
		}else{
			$('#tab').hide();
		}
	}

}

var g_leftUrl = "";
function CoviMenu_ClickTop(elem){//탑메뉴 클릭
	var $a = $(elem);
	var $li = $a.parent();
	var target = $li.attr('data-menu-target');
	var Reserved1 = $li.attr('data-menu-alias');	// 예비1 필드
	var url = decodeURIComponent($li.attr('data-menu-url'));
	
	if(url != null && url != ''){
		//var menuId = $li.attr('data-menu-id');
		//var leftUrl = url + "&fragments=left&loadContent=true&menuid=" + menuId;
		var leftUrl = url + "&fragments=left&loadContent=true";
		g_leftUrl = url + "&fragments=left";
		//coviCmn.setCookie("c_leftId", menuId, 1);
		
		// 토큰 생성 및 MP연동 주소 세팅
		if (Common.getBaseConfig("isUseMail") == 'Y' && Common.getBaseConfig("isUseExchMail") == 'Y' && Reserved1 == "token"){
			var result = GetEncryptToken();
			url = '?ReturnUrl='+url;
			url = Common.getBaseConfig("Exch_mailSvcUrl") + Common.getBaseConfig("Exch_MailServerSLOUrl") + url + "&token="+result;
		}
		
		if(target=="New"){//새로운창
			window.open(url, '_blank');
			return false;		
		}else{//현재창
			/*if (CoviMenu_getParameterByName('CLBIZ', url).toLowerCase() == 'mail' 
				&& CoviMenu_getParameterByName('CLMD', url).toLowerCase() == 'user'){
				location.href = url;
				return false;
			}else if (CoviMenu_getParameterByName('CLBIZ', url).toLowerCase() == 'account' 
				&& CoviMenu_getParameterByName('CLMD', url).toLowerCase() == 'user'){
				location.href = url;
				return false;
			}*/
			
			//left menu 영역

			var loadMenu = true;
			
			if( $('#mailWriteIFrame').length > 0 || $('#divJspMailWrite').length > 0 ){
				loadMenu = confirm(Common.getDic('CPMail_MailWillNotSaved'));
			}

			if(loadMenu){
				$.ajax({
			        type : "GET",
			        beforeSend : function(req) {
			            req.setRequestHeader("Accept", "text/html;type=ajax");
			        },
			        cache : false,
			        url : leftUrl,
			        success : function(res) {
						$('.commContLeft').css('left','0');
						$('.commContRight').css('left','280px');
			        	$('#content').empty(); //content 영역 클리어
			        	
			        	CoviMenu_SetLayout(location.href, url); //tiles issue에 따른 스크립트 내 layout 수정
			     
			        	$("#left").html(res); //left 처리
					    if(document.getElementById('left') && document.getElementById('left').classList.length > 1){
					    	if(CoviMenu_getParameterByName('CLBIZ', url).toLowerCase() != 'store') $('.commContLeft').removeClass("appstoreLeft");
					    	if(CoviMenu_getParameterByName('CLBIZ', url).toLowerCase() != 'conf') $('.commContLeft').removeClass("sadminLeft");
					    };
			            
			        	//관리자 title 처리
			            if(CoviMenu_getParameterByName('CLSYS', url).toLowerCase() == 'core'){
			            	var leftTitle = "";
			            	
			            	if($a.find('span').length > 0){ 		// Top Menu
			            		leftTitle = $a.find('span').text();
			            	}else if($a.find('div').length > 0 ){	// TopSub Menu
			            		leftTitle = $a.find('div').text();
			            	}
			            	
			            	$("#left .gnb_tit").text(leftTitle);
			            }else{
			            	//메일>포탈 이동시 title 처리
			            	if(CoviMenu_getParameterByName('CLSYS', url).toLowerCase() != 'mail'){
			            		setTimeout(function(){
			            			$(document).attr("title", Common.getGlobalProperties("front.title"));
			            		}, 500);
			            	}
			            }
			            CoviMenu_SetCurrentTopMenu();
			        },
			        error : function(response, status, error){
			        	if(status == "parsererror") {
		                    location.href = "/covicore/login.do";
		                }else if (status == "error") {
		                	Common.Warning("네트워크 상태가 원할하지 않아 페이지를 새로고침합니다.<br/>(ex. 절전모드 사용, 네트워크 통신장애)", "안내", function() {document.location.reload();});
		                }else {
		                    CFN_ErrorAjax(leftUrl, response, status, error);
		                }
			        }
			    });
			}
			else { CoviMenu_SetCurrentTopMenu(); }
		}
	}
	//reload 방식으로 페이지 이동 처리 시
	//location.href = url;
}

function CoviMenu_SetCurrentTopMenu() {
	if(CFN_GetQueryString('CLMD') != 'admin') return false;
	
	if(!leftData) return false;
	
	$('.current-top-menu').removeClass('current-top-menu');
	
	var topMenuID = leftData[0].MemberOf;
	var currentTopMenu = $("*[data-menu-id="+ topMenuID +"]")[0];
	if (!currentTopMenu) {
		$.each(headerdata, function(idx, el) {
		    if (el.OriginMenuID == topMenuID) topMenuID = el.MenuID; // 좌측메뉴가 속한 메뉴ID가 구성되어 있지 않는 경우, 상속된 메뉴로 보고 OriginMenuID를 가져와 탑메뉴 객체를 가져온다.
		});
		currentTopMenu = $("*[data-menu-id="+topMenuID+"]")[0];
	}
	
	var nameElement = (currentTopMenu.nodeName == 'DIV') ? 'div' : 'span';
	if (nameElement == 'div'){
		$(currentTopMenu).closest('li').find('a:first').addClass('current-top-menu');
	}
	else {
		$(currentTopMenu).find('a:first').addClass('current-top-menu');
	}

	$(".gnb_tit").text($("*[data-menu-id="+topMenuID+"] a " + nameElement).text());
}

function CoviMenu_GetLeftState(url){
    g_leftUrl = url;
	//coviCmn.setCookie("c_leftId", CoviMenu_getParameterByName('menuid', url), 1);
	var leftUrl = url + "&loadContent=true";
	
	$.ajax({
        type : "GET",
        beforeSend : function(req) {
            req.setRequestHeader("Accept", "text/html;type=ajax");
        },
        cache : false,
        url : leftUrl,
        success : function(res) {
        	$('#content').empty();
        	
        	CoviMenu_SetLayout(location.href, url);
        	
            $("#left").html(res);
        },
        error : function(response, status, error){
				CFN_ErrorAjax(leftUrl, response, status, error);
        }
    });
}

function CoviMenu_GetContentState(url){
	if(url != null && url != ''){
		var contentUrl = url + "&fragments=content";
		var state = CoviMenu_makeState(url); 
		CoviMenu_SetState(state)
		
		//content
		$.ajax({
	        type : "GET",
	        beforeSend : function(req) {
	            req.setRequestHeader("Accept", "text/html;type=ajax");
	        },
	        cache : false,
	        url : contentUrl,
	        success : function(res) {
	        	$("#content").html(res);
	        	coviInput.init();
	        },
	        error : function(response, status, error){
				CFN_ErrorAjax(contentUrl, response, status, error);
	        }
	    });	
	}
}




function CoviMenu_ClickLeft(elem, isHistory){//클릭

	var $a = $(elem);
	var $li = $a.parent();
	var target = $li.attr('data-menu-target');
	
	//선택된 리스트항복 selected

	$('.non').removeClass('selected');
	$('.sub').removeClass('selected');
	$('.gridBodyTr').removeClass('selected'); 
	$a.addClass('selected');
	
	var url = decodeURIComponent($li.attr('data-menu-url'));
	if(url == null || url == '' || url == "undefined"){
		if($a.attr('data-menu-url') != undefined) {
			url = decodeURIComponent($a.attr('data-menu-url'));
		} else {
			$li = $li.parent();
			url = decodeURIComponent($li.attr('data-menu-url'));
		}
	}
	
	if(url != null && url != '' && url != "undefined"){
		if(target=="New"){//새로운창
			window.open(url, '_blank');
			return false;		
		}else{//현재창{
			var contentUrl = url + "&fragments=content";
			if(isHistory != false){
				var state = CoviMenu_makeState(url); 
				var title = url; 
				history.pushState(state, title, url);
				CoviMenu_SetState(state)
			}
			
			//content
			$.ajax({
		        type : "GET",
		        beforeSend : function(req) {
		            req.setRequestHeader("Accept", "text/html;type=ajax");
		        },
		        cache : false,
		        url : contentUrl,
		        success : function(res) {
		        	$("#content").html(res);
		        	coviInput.init();
		        	if($(".admin-menu-active").length == 1) $(".con_tit").text($(".admin-menu-active").text());
					var menuTutle = $li.attr("display-name");
					if(menuTutle && $("#content .title").length > 0){
						$("#content .title:eq(0)").html(CFN_GetDicInfo(menuTutle));
						coviCmn.setCookie("BeforeMenuTitle", Base64.utf8_to_b64(menuTutle), 1);
						coviCmn.setCookie("BeforeMenuUrl", location.pathname + location.search, 1);
					}
		        },
		        error : function(response, status, error){
		        	if(status == "parsererror") {
	                    location.href = "/covicore/login.do";
	                }else if (status == "error") {
	                	Common.Warning("네트워크 상태가 원할하지 않아 페이지를 새로고침합니다.<br/>(ex. 절전모드 사용, 네트워크 통신장애)", "안내", function() {document.location.reload();});
	                }else {
	                    CFN_ErrorAjax(leftUrl, response, status, error);
	                }
		        }
		    });	
		}
	}
}

function CoviMenu_GetTab(url){
	if(url != null && url != ''){
		//tab
		$.ajax({
	        type : "GET",
	        beforeSend : function(req) {
	            req.setRequestHeader("Accept", "text/html;type=ajax");
	        },
	        url : url,
	        success : function(res) {
	        	$("#tab").html(res);
	        },
	        error : function(response, status, error){
				CFN_ErrorAjax(contentUrl, response, status, error);
	        }
	    });	
	}
}

function CoviMenu_GetContent(url,isHistory){
	if(url != null && url != ''){
		if(url.substring(url.length - 1, url.length) == "#"){
			url = url.substring(0, url.length - 1);
		}
		
		var contentUrl = url + "&fragments=content";
		
		if(isHistory != false){
			var state = CoviMenu_makeState(url);
			var title = url; 
			history.pushState(state, title, url);
			CoviMenu_SetState(state)
		}
		
		//content
		$.ajax({
	        type : "GET",
	        beforeSend : function(req) {
	            req.setRequestHeader("Accept", "text/html;type=ajax");
	        },
	        cache : false,
	        url : contentUrl,
	        success : function(res) {
	        	if($("#content").length > 0) {
	        		$("#content").html(res);
	        	} else {
	        		$("body").html(res);
	        	}
	        	
	        	coviInput.init();
	        	if($(".admin-menu-active").length == 1) $(".con_tit").text($(".admin-menu-active").text());
	        	// menu name --> content title
	    		if(typeof(coviMenu) != "undefined" && typeof coviMenu.setContentTitle != "undefined") coviMenu.setContentTitle();
	        },
	        error : function(response, status, error){
				CFN_ErrorAjax(contentUrl, response, status, error);
	        }
	    });	
	}
}

function CoviMenu_GetContent_Mail(url){

	if(url != null && url != ''){
		var contentUrl = url + "&fragments=content";
		var state = CoviMenu_makeState(url);
		var title = url; 
		history.pushState(state, title, url);
		CoviMenu_SetState(state)
		
		//content
		$.ajax({
	        type : "GET",
	        beforeSend : function(req) {
	            req.setRequestHeader("Accept", "text/html;type=ajax");
	        },
	        url : contentUrl,
	        success : function(res) {
	        	$("#content").html(res);
	        	cpMailInit();
	        },
	        error : function(response, status, error){
				CFN_ErrorAjax(contentUrl, response, status, error);
	        }
	    });	
	}
}

///////////////////////
//[ehjeong] 자원예약/일정관리에서 좌측 폴더를 비동기로 연속 클릭 할 경우를 대비하여 함수 분리 2018.11.16
function CoviMenu_GetContentFolder(url,isHistory,from){
	var g_ResourceLoad, g_ScheduleLoad;
	
	if(url != null && url != ''){
		var contentUrl = url + "&fragments=content";
		
		if(isHistory != false){
			var state = CoviMenu_makeState(url);
			var title = url; 
			history.pushState(state, title, url);
			CoviMenu_SetState(state)
		}
		//content
		$.ajax({
	        type : "GET",
	        beforeSend : function(req) {
	            req.setRequestHeader("Accept", "text/html;type=ajax");
	        },
	        url : contentUrl,
	        success : function(res) {
	        	if(from == "R"){
					g_ResourceLoad = true;
				}
	        	else if(from == "S"){
	        		g_ScheduleLoad = true;
	        	}
	        	
	        	$("#content").html(res);
	        	coviInput.init();
	        },
	        error : function(response, status, error){
	        	if(from == "R"){
					g_ResourceLoad = true;
				}
	        	else if(from == "S"){
	        		g_ScheduleLoad = true;
	        	}
				CFN_ErrorAjax(contentUrl, response, status, error);
	        }
	    });	
	}
}

function CoviMenu_ClickQuick(elem){
	var $a = $(elem);
	var $li = $a.parent();
	
	var url = decodeURIComponent($li.attr('data-menu-url'));
	
	var menuID = decodeURIComponent($li.attr('data-menu-id'));
	
	if(url.indexOf("plugin.covi_sso") > -1 || $a.attr("id").indexOf("Eum") > -1){
		window.open(url, '_blank');
		return false;
	}
	
	//Mail은 별도 창 열림
	if(CoviMenu_getParameterByName('CLBIZ', url).toLowerCase() == 'tchat' || CoviMenu_getParameterByName('CLBIZ', url).toLowerCase() == 'indisso'){
		//본사 운영 임시 반영
		window.open(url, '_blank');
		return false;
	} else if(Common.getBaseConfig("isUseMail") == 'Y' && Common.getBaseConfig("isUseExchMail") == 'Y' && menuID == 'Mail'){

		// 토큰 생성
		var result = GetEncryptToken();
		url = '?ReturnUrl='+url;
		url = Common.getBaseConfig("Exch_mailSvcUrl") + Common.getBaseConfig("Exch_MailServerSLOUrl") + url + "&token="+result;
		//본사 운영 임시 반영
		window.open(url, '_blank');
		return false;
	}else{
		//location.href = url;
		//JSYun AJAX로 페이지 이동 (Original:CoviMenu_ClickTop)
		var leftUrl = url + "&fragments=left&loadContent=true";
		$.ajax({
	        type : "GET",
	        beforeSend : function(req) {
	            req.setRequestHeader("Accept", "text/html;type=ajax");
	        },
	        cache : false,
	        url : leftUrl,
	        success : function(res) {
	        	$('#content').empty(); //content 영역 클리어
	        	
	        	CoviMenu_SetLayout(location.href, url); //tiles issue에 따른 스크립트 내 layout 수정
	     
	        	$("#left").html(res); //left 처리
	            
	        	//관리자 title 처리
	            if(CoviMenu_getParameterByName('CLSYS', url).toLowerCase() == 'core'){
	            	$("#left .gnb_tit").text($a.find('span').text());
	            }
	        },
	        error : function(response, status, error){
	        	if(status == "parsererror") {
                    location.href = "/covicore/login.do";
                }else if (status == "error") {
                	Common.Warning("네트워크 상태가 원할하지 않아 페이지를 새로고침합니다.<br/>(ex. 절전모드 사용, 네트워크 통신장애)", "안내", function() {document.location.reload();});
                }else {
                    CFN_ErrorAjax(leftUrl, response, status, error);
                }
	        }
	    });
		
	}
}

/**
 * 빈값 체크
 * @param value
 * @returns {Boolean}
 */
CoviMenu.prototype.isEmpty = function(value){
  return (value == null || value.length === 0);
}

CoviMenu.prototype.parseQuery = function(url){
    var query = {};
    var a = (url[0] === '?' ? url.substr(1) : url).split('&');
    for (var i = 0; i < a.length; i++) {
        var b = a[i].split('=');
        query[decodeURIComponent(b[0])] = decodeURIComponent(b[1] || '');
    }
    return query;
}

/**
 * 선택한 메뉴 하이라이트
 * @param obj 이벤트발생 객체
 * @description 메뉴 선택 시 selected 클래스를 a태그에 부여하나 다른 메뉴 클릭 시 제거하지 않음. 소스 검증이 완료되지 않아 별도 클래스 부여 및 이벤트 처리함수를 추가하였음.
 */
function setManuActive(obj){
	$("#lnb_con .admin-menu-active").removeClass("admin-menu-active");
	$(obj).addClass("admin-menu-active")
}

// menu name --> content title
CoviMenu.prototype.setContentTitle = function(url){
	var sTitle = coviCmn.getCookie("BeforeMenuTitle");
	var sUrl = coviCmn.getCookie("BeforeMenuTitle");
	if(sTitle && sUrl && $("#content .title").length > 0){
		if(coviCmn.getCookie("BeforeMenuUrl").indexOf(location.pathname + location.search) > -1){ // 직접접근/새로고침할 경우, 직전 URL과 같을때만 타이틀 변경
			$("#content .title:eq(0)").html(CFN_GetDicInfo(Base64.b64_to_utf8(sTitle)));
		}
	}
}