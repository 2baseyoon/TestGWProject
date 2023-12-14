
	var myTimer_lo = "";
	var myTimer_lv = "";
	
	var isConnectServer = false;
	var sibNode='';
	var opt = {
			lang : "ko",
			isPartial : "true"
	};
	var coviMenu = new CoviMenu(opt);
    let cellW= 346;
    let cellH= 286;
	let coviTabs;

	var sessionTimer;
	$(window).load(function() {
		if (tabMode == "Y")		{
			coviTabs = new CoviTabs();
			if (CFN_GetQueryString("CLBIZ") != "Portal"){	//포탈이 아닌경우 첫번째 탭 설정(탭저장시 저장으로 생성하는 로직 추가)
				let menuUrl = window.location.pathname+location.search.replace("&fragments=content","");
				coviTabs.createTabs(menuUrl,"menu_id","", true);
			}	
		}
		/*==>layout은 user_default.jsp에서 세팅
		if (CFN_GetQueryString("CLSYS") == "portalEx"){//신규 포탈
			$(".ui_app").addClass("ui_portal");
			$("#portal_root").show();
			$("#comm_container").hide();
			$(".ui_tab_menu .tab_menu_list").empty();
		}
		else{	//asis 2023년 uiux 개선 후 제거 예정
			$(".ui_app").removeClass("ui_portal");
			$("#portal_root").hide();
			$("#comm_container").show();

			if (CFN_GetQueryString("CLBIZ") == "Portal"){
				$(".ui_tab_menu").hide();
				$(".commContLeft").hide();
				$("#contents").removeClass("commContRight");//portal layout 조정
//				$(".commContRight").css("left",-1)
			}else{
				$(".commContLeft").show();
				$(".btn_foldArea").show();
				$("#contents").addClass("commContRight");
				
				if (typeof coviTabs !== "undefined"){
					$(".ui_tab_menu").show();
					let menuUrl = window.location.pathname+location.search.replace("&fragments=content","");
					coviTabs.createTabs(menuUrl,"","home");
				}
			}
		}
		*/
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
		coviMenu.setQuickInit();

		$( document ).on( "idle.idleTimer", function(event, elem, obj){
			var sessionLastActiveTime = localStorage.getItem(ls_USERID + "_sessionLastActiveTime");
			var idleTimerLastActiveTime = $.idleTimer("getLastActiveTime");
			
			if(sessionLastActiveTime == idleTimerLastActiveTime) {
				// 현재 브라우저의 LastActive 값이 SessionStorage의 LastActive 값과 일치하면 마지막 Active 브라우저라고 판단하여 세션종료 팝업 호출 그 외일 경우  
				if( $(".layer_dialog[id^=sessionOut]").size() == 0 ){
					coviCmn.sessionOut( '세션이 만료됩니다. <br />세션 시간 연장을 원하시면 <b>OK</b> 버튼을 선택해주세요.',  redirectAfterTime ,  coviCmn.continuSession , XFN_LogOut );	 
				}
			} else {
				$.idleTimer("reset");
			}

	    });

		// timer 설정 전 기존 localstorage에 모든 _sessionLastActiveTime 제거
		$.idleTimer( {timeout : ((sessionOutPopupTime == undefined?3600:sessionOutPopupTime) - redirectAfterTime) * 1000, sessionId : ls_USERID});
		
		coviCtrl.bindmScrollV($('.mScrollV'));
		// 전체메뉴 토글
	    $(document).on('click', '#all_menu_toggle', function () {
	        UI_Drawer('all_menu_drawer', 'left', 'lg');
	    });
	
	    //전체메뉴 설정
	    $(document).on('click', '#all_menu_setting_toggle', function () {
	    	coviCtrl.callTopMenuManagePopup();
	    });
	    
	    // 전체메뉴에 즐겨찾기 메뉴
	    $(document).on("click", ".all_menu_drawer .favorites_menu .menu_toggle", function () {
	        const $favoritesMenu = $(this).parent();
	        if ($favoritesMenu.attr('aria-expanded') === 'true') {
	            $favoritesMenu.attr('aria-expanded', 'false');
	        } else {
	            $favoritesMenu.attr('aria-expanded', 'true');
	        }
	    });
	
	    // 글로벌 검색
	    $(document).on('click', '#global_search_toggle', function () {
	        if ($(this).attr('aria-pressed') === 'true') {
	            $(this).attr('aria-pressed', 'false').prev().attr('hidden', 'hidden').find('input,button').attr('disabled', 'true');
	        } else {
	            $(this).attr('aria-pressed', 'true').prev().removeAttr('hidden').find('input,button').removeAttr('disabled');
	        }
	        UI_Gnb();
	    });
	
	    // 포털 설정 팝업 펼침
	    $(document).on('click', '#setting_toggle', function (e) {
	        e.preventDefault();
	        //가젯이 열려있으면 
	        if ( $('.orderBusi').hasClass('open')){
	        	$('.orderBusi').toggleClass('open');
	        }
	        UI_Drawer('setting_drawer');
	
	        const $settingDrawerSortable = document.querySelector('.setting_drawer .sortable');
	        if ($settingDrawerSortable) {
	            Sortable.create($settingDrawerSortable, {
	                forceFallback: true,
	                handle: '.handle',
	                animation: 250,
	                onEnd: function (e, ui) {
	              	  //드롭했을때 이벤트 실행
	                	//let startIdx = e.newIndex;
	                	//saveMyContentsOrder("widgetSorting", startIdx, "Widget");
	                }	
	            });
	        }
	    });
	    /*
	    // 설정 팝업 포털변경 탭 클릭 시 미리보기 도움말 표시
	    $(document).on('click', '#setting_design_tab', function (e) {
	        $('#setting_design_tab_panel .preview_help').each(function () {
	            if ($(this).attr('aria-expanded') !== 'true') {
	                const $this = $(this).find('.help_toggle');
	                UIHelpShow($this);
	            }
	        });
	    });
*/
	    // 설정 팝업 그리드 타이틀 토글
	    $(document).on('click', '.setting_drawer .setting_grid .grid_toggle', function () {
	        const expanded = $(this).parents('.setting_grid').attr('aria-expanded');
	        $(this).attr('aria-label', expanded === 'false' ? '접기' : '펼치기');
	        $(this).parents('.setting_grid').attr('aria-expanded', expanded === 'false' ? 'true' : 'false');
	    });

	
	  //편집
	    $(document).on('click', '#btnFavAdd', function (e) {
	    	e.preventDefault();
	    	//popup 호출
	    	var url = "";
	    	url += "/covicore/control/callFavoriteAdd.do?"
	    	url += "lang=ko&";
	    	url += "callback=CoviMenu_FavoriteAddCallback";
	    	
	    	Common.open("", "FavoriteAdd", Common.getDic("lbl_Enjoy_Estab"), url, "595px", "323px", "iframe", true, null, null, true);
	    });
	    
	    /* 메인 좌측영역 슬라이드 */ 
        $(document).on('click','.cLnbToggle .btnOpen',function(){
            $('.commContLeft').css('left',0);
            $('.cLnbToggle').css('left',280);
            $('.commContRight').css('left',280);
            $(this).hide();
            $('.cLnbToggle .btnClose').show();
        });
        /* 메인 좌측영역 슬라이드*/
        $(document).on('click','.cLnbToggle .btnClose',function(){
            $('.commContLeft').css('left','-280px');
            $('.cLnbToggle').css('left',0);
            $('.commContRight').css('left',0);
            $(this).hide();
            $('.cLnbToggle .btnOpen').show();
        });

	    // 위젯 클릭 이벤트 체크
        $(document).on('click', '#widgetSorting', function () {
        	$("#widgetSorting").attr("data-move", true);
        });	
	    $(document).on('click', '#widgetSorting input[type=checkbox]', function () {
	    	//saveMyContents("Widget",this, "widgetSorting");
	    });
	    
	    // 마이컨텐츠 클릭 이벤트 체크
        $(document).on('click', '#contentsSorting input[type=checkbox]', function (e) {
        	$("#contentsSorting").attr("data-move", true);
        	let oldCnt = $("#myContentList .grid_item").length;
        	let newCnt = $("#contentsSorting input[type=checkbox]:checked").length;
        	let maxCnt = Common.getBaseConfig("PortalWebpatMax");
        	if (maxCnt == "") maxCnt = 10;
        	if (maxCnt < oldCnt + newCnt){
				Common.Inform(String.format(Common.getDic("msg_MaxContentsSize"),maxCnt, oldCnt, newCnt)); // 사용자 정의 필드의 수와 다중 카테고리 개수의 합이<br>10을 넘는 경우 사용자 정의 컬럼이 제대로 표시되지 않을 수 있습니다.
        		return false;
        	}
        	
        });	
	    /*  마이컨텐츠 체크박스 이벤트
	    $(document).on('click', '#contentsSorting input[type=checkbox]', function () {
	    });
*/
	    // 설정 팝업 그리드 타이틀 토글
	    $(document).on('click', '.setting_drawer .setting_grid button.grid_title', function () {
	        const expanded = $(this).parent().attr('aria-expanded');
	        $(this).parent().attr('aria-expanded', expanded === 'false' ? 'true' : 'false');
	    });
	
	    
	    // custom scrollbar
	    if (!/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
	        $('[data-custom-scrollbar]').each(function (index, element) {
	            new SimpleBar(element);
	        });
	    }

		//업무시스템 바로가기
		$(document).on('change', '#siteLink', function () {
			if ($("#siteLink option:selected").attr("data-url") != ""){
				if ($("#siteLink option:selected").attr("data-target") == ""){
					location.href = $("#siteLink option:selected").attr("data-url");
				}else{
					window.open($("#siteLink option:selected").attr("data-url"),$("#siteLink option:selected").attr("data-target"));
				}
			}
	
		});
	
		//검색
		$(document).on('keypress', '#txtPortalUnifiedSearch', function () {
			if (event.keyCode === 13) {
				XFN_PortalUnifiedSearch();
			}
		});
	
			
		$(document).on('click', '.global_utility .ui_icon_button[data-icon="search"]', function () {
			XFN_PortalUnifiedSearch();
		});
	
		//알림
		$(document).on('click', '.global_utility .global_icon[data-icon="notifications"]', function () {
			CoviMenu_clickQuickIntegrated("Integrated", "Top");
		});
	
		//조직도
		$(document).on('click', '.global_utility .global_icon[data-icon="organization"]', function () {
			Common.open("","orgmap_pop",Common.getDic("lbl_DeptOrgMap"),"/covicore/control/goOrgChart.do?type=A0&treeKind=Group","1170px","675px","iframe",true,null,null,true);
		});
	
		//간편작성
		$(document).on('click', '.global_utility .global_icon[data-icon="writing"]', function () {
			coviCtrl.toggleSimpleMake();
		});
	
		//가젯
		$(document).on('click', '.global_utility .global_icon[data-icon="gadget"]', function () {
	        $('.orderBusi').toggleClass('open');
	        $('.orderTabMenu>li.active').click();
		});
		//가젯 내의 탭 클릭시
		$('.orderTabMenu>li').on('click', function(){
			var menuType = $(this).attr("type");

			initPortalMenu(menuType);
			
			$('.orderTabMenu>li').removeClass('active');
			$('.oderTabContent').removeClass('active');
			$(this).addClass('active');
			$('.oderTabContent').eq($(this).index()).addClass('active');
		});	
		
		//가젯내 닫기
		$('.orderContent .btnOrderContClose').on('click', function(){
	        $('.orderBusi').toggleClass('open');
    	});
    	
		//권한 초기화
		$(document).on('click', '#setting_basic_tab_panel .setting_reset_button', function () {
			coviCmn.clearCache(true, true);
		});
		
		//나의 정보
		$(document).on('click', '#setting_basic_tab_panel .grid_title[data-icon="profile"]', function () {
			CoviMenu_CallMyInfo();
		});
		
		//개인 정보 설정
		$(document).on('click', '#setting_basic_tab_panel .grid_title[data-icon="my"]', function () {
			$(".drawer_container .drawer_close").trigger("click");
			CoviMenu_GetLeftState('/covicore/layout/left.do?CLSYS=privacy&CLMD=user&CLBIZ=Privacy');
		});
		
		//언어 변경
		$(document).on('click', '.setting_grid #lang input:radio', function (event) {
			CoviMenu_setMyInfo('Lang',$(this).val()); 
	    });
	
	
		//겸직 변경
		$(document).on('click', '.setting_grid #position input:radio', function (event) {
			CoviMenu_setMyInfo('ChangePosition',$(this).val()); 
	    });
	
		//portal 변경
		$(document).on('click', '.setting_grid #portal input:radio', function (event) {
			CoviMenu_setMyInfo('Portal',$(this).val()); 
	    });
	
		
		// 기본모드
		$(document).on('click', '.setting_grid #mode input:radio', function (event) {
			saveUserPortalOption('mode',$(this).val()); 
	    });
	
		// 컬러 thema
		$(document).on('click', '.setting_grid #theme input:radio', function (event) {
			saveUserPortalOption('theme',$(this).val());
	    });
		
		//logout
		$(document).on('click', '.setting_grid a[data-icon="logout"]', function () {
			XFN_LogOut();
		})
		
		//포탈 초기화
		$(document).on('click', '#setting_design_tab_panel .setting_reset_button', function () {
			resetPortalWebpart();
//			alert("porta")
			//coviCmn.clearCache(true, true);
		});
		//마이컨텐츠만
		$(document).on('click', '.setting_grid #onlyContents input:checkbox', function (event) {
//			saveUserPortalOption('onlyContents',$(this).is(":checked") ?"Y":"N"); 
	    });
		
		//포타배경(dim)
		$(document).on('click', '.setting_grid #dim input:checkbox', function (event) {
			if ($(this).is(":checked")){
				$(".portal_dim").removeAttr("hidden");
			}else{
				$(".portal_dim").attr("hidden", true);
			}
//			saveUserPortalOption('dim',$(this).is(":checked") ?"Y":"N"); 
	    });
		
		//이미지배경
		$(document).on('click', '.setting_grid #portalBg input:radio', function (event) {
			document.querySelector('.portal_background').setAttribute("data-background",$(this).val());
//			saveUserPortalOption('portalBg',$(this).val()); 
	    });

		//단색 컬러
		$(document).on('click', '.setting_grid #portalBgText input:radio', function (event) {
			document.querySelector('.portal_background').setAttribute("data-background",$(this).val());
//			saveUserPortalOption('portalBg',$(this).val());
	    });

		//마이컨텐츠 배경사용
		$(document).on('click', '.setting_grid #contentsBg input:checkbox', function (event) {
			$(".ui_portal").toggleClass("normal");
//			saveUserPortalOption('contentsBg',$(this).is(":checked") ?"Y":"N"); 
	    });
		
		//포털 텍스트
		$(document).on('click', '.setting_grid #portalText input:radio', function (event) {
			document.querySelector('.ui_portal').setAttribute("data-text-color",$(this).val());
//			saveUserPortalOption('portalText',$(this).val()); 
	    });
	
		//포털 취소
		$(document).on('click', '#portalCancel', function (event) {
			$(".drawer_container .drawer_close").trigger("click");
//			location.reload();
	    });
		//포털 저장
		$(document).on('click', '#portalSave', function (event) {
			savePortalWebpart(true); 	//포탈 옵션과 같이 저장
	    });
		$(document).on('change', '#portalBg input[type="file"]', function(){
			var file = $(this)[0].files[0];
			var allowType = {};

			if ($(this).attr("accept") != undefined ) allowType = $(this).attr("accept").replaceAll(" ", "").split(",");
			if(file.name != ""){
				var pathPoint = file.name.lastIndexOf('.');
				var filePoint = file.name.substring(pathPoint + 1, file.name.length);
				var fileType = filePoint.toLowerCase();
				
				if(file.size > 1000000){
					Common.Warning(Common.getDic("msg_only1MB")); // 1MB 이하만 가능합니다
					$(this).val("");
					return;
				}

				if(allowType.length>0 && $.inArray("."+fileType, allowType) == -1) {
					Common.Warning(Common.getDic("msg_ExistLimitedExtensionFile"));	
					return;
				}
				
/*					if(fileType != "png"){
					Common.Warning("<spring:message code='Cache.msg_onlyPng'/>"); // png만 가능합니다.
					$(this).val("");
					return;
				}
*/				
				if ($("#portalBg .custom-img").size()==0){
					$(".drawer_content .image_upload")
					.after($("<label>",{"class":"selector custom-img"})
							.append($("<input>",{"type":"radio","name":"background","value":"image-custom","checked":""}).append($("<i>")))
							.append($("<button>",{"class":"selector_delete","onclick":""}).append($("<span>",{"text":"삭제"})))
						);
				}
				
				coviUtil.readURL($("#portalBg .custom-img"), file, false);
			}
			
		});
		//배경이미지 삭제
		$(document).on('click', '#portalBg .selector_delete', function(){
			$(this).closest(".selector").remove();
			$("#portalBg input[type='file']").val("");
		});
		
	});

function saveUserPortalOption(key, val){
	if (key == undefined){	//기존 스마트 포탈에서 호출
		portalOption.isDark = $("#wrap").hasClass("PN_darkmode") ? "Y" : "N";
		if (location.pathname.indexOf('portal') > -1){
			portalOption.useLeft = $(".PN_mainLeft .PN_btnArea a").hasClass("btnClose") ? "Y" : "N";
			portalOption.isActiveMyContents = $(".PN_myContents .PN_myBtn").hasClass("active") ? "Y" : "N";
		}
		$.ajax({
			url: "/groupware/pnPortal/saveUserPortalOption.do",
			type: "POST",
			data: {
				"portalOption": JSON.stringify(portalOption),
				'DarkMode': $("#wrap").hasClass("PN_darkmode") ? "Y" : "N"
			},
			success: function(data){},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/pnPortal/saveUserPortalOption.do", response, status, error);
			}
		});
	}
	else{
		$.ajax({
			url: "/groupware/portal/saveUserPortalOption.do",
			type: "POST",
			data: {"key":key, "val": val		},
			success: function(data){
				switch (key){
					case "mode":	//모드
						document.documentElement.setAttribute('data-mode', val);
						//스마트 포탈 인 경우 
						if (val == "dark"){
							$("#contents").addClass("PN_darkmode");
						}else{
							$("#contents").removeClass("PN_darkmode");
						}
						break;
					case "theme"://컬러 테마	
						document.documentElement.setAttribute('data-theme', val);
/*						var ch = document.getElementById('themeCSS');
						if (ch){
							ch.href=cssPath + "/covicore/resources/css/theme/"+val+".css";
						}*/
						location.reload();
						break;
					case "useLeft"://스마트포탈-좌측 open
					case "isActiveMyContents"://스마트포탈-contens영역 open	
						break;
					default:
						location.reload();

					
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/portal/saveUserPortalOption.do", response, status, error);
			}
		});
	}	
}
//웹파트 색상 변경
function saveMyContentsWebpartColor(obj, webpartId, webpartColor){
	$.ajax({
		url: "/groupware/portal/saveMyContentsWebpartColor.do",
		type: "post",
		data: {
			webpartId: 	webpartId.substring(2),
			webpartColor:	webpartColor,
			serviceDevice : "P"
		},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			obj.setAttribute('data-color', webpartColor);
    			//retVal =  true;
    		}else{
				Common.Warning(Common.getDic("msg_MyP_ErrorMsg"));	 //에러가 발생하였습니다. 새로고침 후  다시 시도하여주세요.<br />지속적으로 문제가 발생하면 관리자에게 문의 바랍니다.
    		}
    	}, 
    	error:function(response, status, error){
    		CFN_ErrorAjax('/groupware/portal/saveMyContentsWebpartColor.do', response, status, error);
    	}
	});
	
	//return retVal;
}

//사용자 포탈의 웹파트  추가 /삭제-개별
function saveMyContents(pMode,obj, id){
	let saveMode = !$(obj).is(":checked")?"D":"I"
	$.ajax({
		url: "/groupware/portal/saveMyContents.do",
		type: "post",
		data: {
			webpartId: 	$(obj).val(),
			saveMode:	saveMode,
			cMode: pMode,
			sortKey:$("#"+id+" input[type=checkbox]").index($(obj)),
			serviceDevice : "P"
		},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			if (saveMode == "D"){//삭제
    				if (pMode == "Widget"){
    					mainSwiper.removeSlide($('.portal_main_widget_swiper .swiper-slide').index($(".portal_main_widget_swiper #WP"+$(obj).val())));
    				}else{
//        		        $(this).parents('.grid_item').remove();
        		        wall.refresh();
    				}
    			}else{
					var oScript = document.createElement("script");
					var oScriptText = document.createTextNode(data.myContentsJavaScript);
					oScript.appendChild(oScriptText);
					document.body.appendChild(oScript);
					
					var webpartData = data.webpartData;
					if (pMode == "Widget"){
						var html ='<div class="swiper-slide" id="WP'+webpartData["WebpartID"]+'">'+
						'<div class="portal_widget simplify '+webpartData["Reserved3"]+'">'+
							' <div class="widget_card">'+
								(webpartData["viewHtml"] == undefined ? "" : Base64.b64_to_utf8(webpartData["viewHtml"]) )+
							'</div>'+
						'</div>	'+
						'</div>';
						mainSwiper.appendSlide(html);
						mainSwiper.update();  //슬라이드를 새로 추가할 경우 꼭 update 함수를 호출하는게 좋다
					}else{
						let html ='<div class="grid_item '+webpartData["Reserved4"] +' '+webpartData["Reserved5"]+' data-handle=".move" data-id="WP'+webpartData["WebpartID"]+'" >'+
						'<div class="portal_widget ${list.Reserved3}" id="WP'+webpartData["WebpartID"]+'">'+
							(webpartData["viewHtml"] == undefined ? "" : Base64.b64_to_utf8(webpartData["viewHtml"]) )+
							'</div>'+
						'</div>';
        		        wall.appendBlock(html);
        		        wall.refresh();
    				}
					
					gwPortal[webpartData.WebpartID] =  window[Base64.b64_to_utf8(webpartData.initMethod)].call(this, webpartData.data, webpartData.ExtentionJSON, 'portal', webpartData.WebpartID);
    			}
    			//retVal =  true;
    		}else{
				Common.Warning(Common.getDic("msg_MyP_ErrorMsg"));	 //에러가 발생하였습니다. 새로고침 후  다시 시도하여주세요.<br />지속적으로 문제가 발생하면 관리자에게 문의 바랍니다.
    		}
    	}, 
    	error:function(response, status, error){
    		CFN_ErrorAjax('/groupware/portal/saveMyContents.do', response, status, error);
    	}
	});
	
	//return retVal;
}

function savePortalWebpart(bOptSave){
	var optMap = {};
	var widgetArr = new Array();
	var contentsArr = new Array();
	var sortKey =0;
	//data: {"key":key, "val": val		},
	
	if (bOptSave){	//기타 포탈 설정가이 저장할지 여부에 따라
		//마이컨텐츠만
		optMap["onlyContents"]=$("#onlyContents input:checkbox").is(":checked") ?"Y":"N";
		//포타배경(dim)
		optMap["dim"]=$("#dim  input:checkbox").is(":checked") ?"Y":"N";
		//이미지배경
//		optMap["portalBg"]=$("#portalBg  input:checked").val();
		//단색 컬러
		optMap["portalBg"]=$("input[name=background]:checked").val();
		//마이컨텐츠 배경사용
		optMap["contentsBg"]=$("#contentsBg input:checkbox").is(":checked") ?"Y":"N";
		//포털 텍스트
		optMap["portalText"]=$("#portalText  input:checked").val();
		
		if ($("#portalBg .custom-img").size() == 0){
			optMap["portalBgPath"] = "";
			if ($("input[name=background]:checked").length == 0){
				optMap["portalBg"] = "black-1";
			}
			
		}	
	}
	
	//위젯 데이타 세팅
//	if ($("#widgetSorting").attr("data-move")){
		$("#widgetSorting li").each(function (i, v) {
			var item = $(v);
			if (item.find("input[type=checkbox]").is(":checked")){
				widgetArr.push({ "sortKey":sortKey++, "webpartId":item.find("input[type=checkbox]").val()});
			}
		});
//	}	
	//컨텐츠 데이타 세팅
	if ($("#contentsSorting").attr("data-move")){
		if ($("#contentsSorting li input[type=checkbox]:checked").length>0){
			contentsArr = getContentsOrder("myContentList");
			sortKey = contentsArr.length;
	
			$("#contentsSorting li").each(function (i, v) {
				var item = $(v);
				if (item.find("input[type=checkbox]").is(":checked")){
					contentsArr.push({ "sortKey":sortKey++, "webpartId":item.find("input[type=checkbox]").val()});
				}
			});
		}	
	}	
	var formData = new FormData();
	formData.append("serviceDevice", "P");
	//#portalBg input[type="file"]', function(){
	//var file = $(this)[0].files[0]
	
	formData.append("file", $("#portalBg input[type='file']")[0].files[0]);
//	formData.append("widgetMove", $("#widgetSorting").attr("data-move"));
	formData.append("widgetList", JSON.stringify(widgetArr));
	formData.append("contentsList", JSON.stringify(contentsArr));
	formData.append("portalOption", JSON.stringify(optMap));
//	formData.append("trgMember", JSON.stringify(collabUtil.getUserArray("resultViewMember")));
	
	$.ajax({
       	type:"POST",
    	enctype: 'multipart/form-data',
    	data: formData,
    	processData: false,
    	contentType: false,
   		url:"/groupware/portal/savePortalWebpart.do",
   		success:function (data) {
   			location.reload();
   		},
   		error:function (request,status,error){
   			CFN_ErrorAjax('/groupware/portal/savePortalWebpart.do', response, status, error);
   		}
   	});
}

function getContentsOrder(id){
	var webpartArr = new Array();
	var findKey = "#"+id+" .grid_item";

	$(findKey).each(function (i, v) {
		var item = $(v);
		var position = item.position()
		var top = Math.round(position.top / cellH);
		var left = Math.round(position.left / cellW);
		var width = Math.round(item.width() / cellW);
		var height = Math.round(item.height() / cellH);
		top =Math.max(0, top);//
		left = Math.max(0, left);
		var webpartColor =  $("#"+item.attr("data-id")).attr("data-color");
		if (webpartColor == "") webpartColor= "default";

		webpartArr.push({ "sortKey":top*10+left, "webpartId":item.attr("data-id").replace("WP",""), "webpartColor":webpartColor});
	});
	return webpartArr;
}
//웹파트 순서변경
function saveMyContentsOrder(id, startIdx, pMode, optMap){
	var webpartArr = new Array();
	
	if (pMode == "Widget"){
		var findKey = "#"+id+" li";
	
		$(findKey).each(function (i, v) {
			var item = $(v);
			 webpartArr.push({ "sortKey":i, "webpartId":item.find("input[type=checkbox]").val()});
		});
	}else{
		webpartArr = getContentsOrder(id)
/*		var findKey = "#"+id+" .grid_item";

		$(findKey).each(function (i, v) {
			var item = $(v);
			var position = item.position()
			var top = Math.round(position.top / cellH);
			var left = Math.round(position.left / cellW);
			var width = Math.round(item.width() / cellW);
			var height = Math.round(item.height() / cellH);
			top =Math.max(0, top);//
			left = Math.max(0, left);
			var webpartColor =  $("#"+item.attr("data-id")).attr("data-color");
			if (webpartColor == "") webpartColor= "default";

			webpartArr.push({ "sortKey":top*10+left, "webpartId":item.attr("data-id").replace("WP",""), "webpartColor":webpartColor});
		});*/
	}	
	 $.ajax({
       	type:"POST",
       	contentType:'application/json; charset=utf-8',
   		dataType   : 'json',
   		data:JSON.stringify({"cMode": pMode, "serviceDevice": "P","webpartList":webpartArr, "portalOption":optMap}),
   		url:"/groupware/portal/saveMyContentsOrder.do",
   		success:function (data) {
   			location.reload();
   		},
   		error:function (request,status,error){
   			CFN_ErrorAjax('/groupware/portal/saveMyContentsOrder.do', response, status, error);
   		}
   	});
	 
}

function resetPortalWebpart(){
	 $.ajax({
	       	type:"POST",
	   		url:"/groupware/portal/resetPortalOption.do",
	   		success:function (data) {
	   			location.reload();
	   		},
	   		error:function (request,status,error){
	   			CFN_ErrorAjax('/groupware/portal/resetPortalOption.do', response, status, error);
	   		}
	   	});
}

var isPortalMenuLoad = new Object();
isPortalMenuLoad["Subscription"] = false; 
isPortalMenuLoad["ContactNumber"] = false; 
isPortalMenuLoad["Todo"] = false;			

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
	}
}

function UI_Drawer(element, direction, size) {
    let className = 'ui_drawer drawer_' + (direction === undefined ? 'right' : direction) + ' ' + element;
    if (size !== undefined) className += ' drawer_' + size;

    const $drawerContent = document.getElementById(element).innerHTML;

    function close() {
        $drawer.setAttribute('data-animation', 'leave');
        //좌측 설정 클릭후 닫힐 때 미리보기 원복
        if (element=="setting_drawer" && CoviMenu_getParameterByName('CLSYS') == "portalEx"){
	        //dim
	        if ($('.setting_grid #dim').attr("data-org") == "Y"){
				$(".portal_dim").removeAttr("hidden");
			}else{
				$(".portal_dim").attr("hidden", true);
	        }
	        //콘텐츠 배경
	        if ($('.setting_grid #contentsBg').attr("data-org") == "Y"){
	        	$(".ui_portal").removeClass("normal");
			}else{
	        	$(".ui_portal").addClass("normal");
	        }
	
	        //배경이미지
	        document.querySelector('.portal_background').setAttribute("data-background",$('.setting_grid #portalBg').attr("data-org")==""?"black-1":$('.setting_grid #portalBg').attr("data-org"));
	        //텍스트 컬러
	        document.querySelector('.ui_portal').setAttribute("data-text-color",$('.setting_grid #portalText').attr("data-org")==""?"black":$('.setting_grid #portalText').attr("data-org"));
        }    
        $drawerContainer.addEventListener('transitionend', function () {
            $drawer.parentNode.removeChild($drawer);
        });
    }

    const $drawer = document.createElement('div');
    $drawer.className = className;
    const $drawerDim = document.createElement('div');
    $drawerDim.className = 'drawer_dim';
    $drawerDim.addEventListener('click', close);
    const $drawerContainer = document.createElement('div');
    $drawerContainer.className = 'drawer_container';
    $drawerContainer.innerHTML = $drawerContent;
    const $drawerCloseButton = document.createElement('button');
    $drawerCloseButton.type = 'button';
    $drawerCloseButton.className = 'drawer_close';
    $drawerCloseButton.innerHTML = '<span>Close</span>';
    $drawerCloseButton.addEventListener('click', close);

    $drawerContainer.appendChild($drawerCloseButton);
    $drawer.appendChild($drawerDim);
    $drawer.appendChild($drawerContainer);
    document.body.appendChild($drawer);
    
    if (element == "all_menu_drawer"){	//전체메뉴일 때
	    document.getElementById("favoriteSiteMenu").innerHTML =document.getElementById('my_content_favorite').innerHTML;
	    
	    /*포탈변경 즐겨찾기 처리*/
	    if ($("#favoriteSiteMenu li").length>0){
	    	$(".drawer_toolbar").show();
	    }else{
	    	$(".drawer_toolbar").hide();
	    }	
    }else{ //포탈변경 관련 탭 처리
        if (CoviMenu_getParameterByName('CLSYS') == "portalEx"){
        	$(".drawer_tabs").show();
        }else{
        	$(".drawer_tabs").hide();
        }	
    }
   	setTimeout(function () {
        $drawer.setAttribute('data-animation', 'enter');
    }, 30);
}
