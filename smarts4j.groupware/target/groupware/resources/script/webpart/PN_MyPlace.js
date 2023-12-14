/**
 * pnMyPlace - 마이 컨텐츠
 */
var pnMyPlace ={
	webpartType: "",
	seesionObj: {},
	pckry: "",
	init: function (data,ext){
		this.sessionObj = Common.getSession();
		this.setEvent();
		this.setWebpartThumbnailList();
		this.getWebpartList();
//		if (g_isActiveMyContents == 'Y') $(".PN_myContents .PN_myBtn").click();
	},
	setEvent: function(){
		$(".PN_thumbnail").fadeOut(1);
	},
	setWebpartThumbnailList: function(){
		$.ajax({
			url: "/groupware/pnPortal/setWebpartThumbnailList.do",
			type: "POST",
			data: {
				contentsMode: "MyPlace"
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					if(data.list != null && data.list.length > 0){
						var thumbHtml = "";
						
						$.each(data.list, function(idx, item){
							var thumbNailPath = ((item.Thumbnail[0] != '/') ? '/' : '')+item.Thumbnail;
							if (thumbNailPath.indexOf('HtmlSite') == -1) {
								thumbNailPath = coviCmn.loadImage(thumbNailPath)
							}
							var divWrap = $("<div class='PN_thumbList'></div>").attr("wID", item.WebpartID);
							divWrap
								.append($("<a href='#'></a>")
								.append($("<span class='thumbImg'></span>")
								.append($("<img onerror='setNoImage(this);'>").attr("src", thumbNailPath)))
								.append($("<span class='thumbTit'></span>").text(item.WebpartName)));
							
							thumbHtml += $(divWrap)[0].outerHTML;
						});
						
						$(".PN_thumbnail").empty().append(thumbHtml);
					}
					
					pnMyPlace.setWebpartDraggable();
				}
			}, 
			error:function(response, status, error){
				 CFN_ErrorAjax("/groupware/pnPortal/setWebpartThumbnailList.do", response, status, error);
			}
		});
	},
	getWebpartList: function(){
		
		$.ajax({
			url: "/groupware/mycontents/getMyContentSetWebpartList.do",
			type: "POST",
			data: {
				contentsMode: "MyPlace"
			},
			success:function(data){
				if(data.status == "SUCCESS"){
				
					pnMyPlace.webparts = data.webpartList;
					
					var oScript = document.createElement("script");
					var oScriptText = document.createTextNode(data.myContentsJavaScript);
					oScript.appendChild(oScriptText);
					document.body.appendChild(oScript);
					
					if (data.webpartList.length > 0) {
						pnMyPlace.loadWebpart(data.webpartList);
					} else {
						$("#PN_myContents_ItemList").append($("<div/>", {"id": "PN_myContents_hidden", "class": "PN_myContents_box", "style": "visibility: hidden;"}));
					}
					
					// 이벤트 바인딩
					pnMyPlace.setSortTable();
					pnMyPlace.deleteMycontents();
				}
			},
			error:function(response, status, error){
				 CFN_ErrorAjax("/groupware/mycontents/getMyContentSetWebpartList.do", response, status, error);
			}
		});
	},
	getMyPlaceWebpartList: function(webpartID, objPos){
		$.ajax({
			url: "/groupware/mycontents/getMyContentWebpartList.do",
			type: "POST",
			data: {
				"webpartID": webpartID
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var oScript = document.createElement("script");
					var oScriptText = document.createTextNode(data.myContentsJavaScript);
					oScript.appendChild(oScriptText);
					document.body.appendChild(oScript);
					
					pnMyPlace.addWebpart(data.webpartList, objPos);
					
					// 이벤트 바인딩
					pnMyPlace.deleteMycontents();
				}
			}, 
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/mycontents/getMyContentSetWebpartList.do", response, status, error);
			}
		});
	},
	loadWebpart: function(webpartList){
		$("#PN_myContents_ItemList").empty();
		$.each(webpartList, function(idx, value){
			try{
				var html = Base64.b64_to_utf8(value.viewHtml == undefined ? "" : value.viewHtml);

				if (html == '') html = Base64.b64_to_utf8( value.preview ? value.preview : "");
				
				if (html.indexOf('PN_myContents_box') == -1){
					html = pnMyPlace.setControl(html);
				}
				
				html = "<div name='mycontents_webpart' value='"+value.WebpartID+"'>"+html+"</div>";
				
				$("#PN_myContents_ItemList").append(html);
				
				if(value.initMethod != "" && typeof(value.initMethod) != "undefined"){
					if(typeof(value.ExtentionJSON) == "undefined"){
						value.ExtentionJSON = $.parseJSON("{}");
					}					
					//보안취약 조치(eval, Function)
					//let ptFunc = new Function('a', 'b', 'c', Base64.b64_to_utf8(value.initMethod)+'(a, b, c)');
					//ptFunc([], value.ExtentionJSON, 'myPlace') ;
					let fnName = Base64.b64_to_utf8(value.initMethod); // NS.fn
					coviCmn.callFnBasedNamespace(fnName, [], value.ExtentionJSON, 'myPlace');
				}
			}catch(e){
				coviCmn.traceLog("myContent > webpart"+value.WebpartID+"<br>"+e);
			}
		});
	},
	setControl: function(obj){
		var _returnHtml = '<div class="PN_myContents_box">'+
				'<div class="PN_portlet">'+
					'<div class="PN_portlet_head PN_portlet_handler">'+
						'<div class="PN_portlet_title">'+
							'<strong class="PN_portlet_link"></strong>'+
						'</div>'+
						'<div class="PN_portlet_function">'+
							'<a href="#" class="PN_portlet_btn" onclick="javascript:pnMyPlace.toggleMenu(this);">'+
								'<span class=""></span>'+
								'<span class=""></span>'+
								'<span class=""></span>'+
							'</a>'+
							'<div class="PN_portlet_menu">'+
								'<ul>'+
									'<li mode="hide"><a href="#"><spring:message code="Cache.lbl_HideContent"/></a></li>'+
								'</ul>'+
							'</div>'+
						'</div>'+
					'</div>'+
					'<div class="PN_portlet_contents">'+
						obj +
					'</div>'+
				'</div>'+
			'</div>';
		return _returnHtml;
	},
	toggleMenu: function(target){
		if(!$(target).hasClass("active")){
			$(target).addClass("active");
			$(target).next(".PN_portlet_menu").stop().slideDown(300);
			$(target).children(".PN_portlet_btn > span").addClass("on");
		}else{
			$(target).removeClass("active");
			$(target).next(".PN_portlet_menu").stop().slideUp(300);
			$(target).children(".PN_portlet_btn > span").removeClass("on");
		}
	},
	addWebpart: function(webpartList, objPos){
		$.each(webpartList, function(idx, value){
			try{
				var html = Base64.b64_to_utf8(value.viewHtml == undefined ? "" : value.viewHtml);
				if (html.indexOf('PN_myContents_box') == -1){
					html = pnMyPlace.setControl(html);
				}
				
				var divWrap = $("<div name='mycontents_webpart' value='"+value.WebpartID+"'></div>").append(html);

				var targetX = $(objPos).position().left;
				var targetY = $(objPos).position().top;
				var width = $(".PN_myContents_box").length ? parseInt($(".PN_myContents_box").css("width").replaceAll("px", "")) : parseInt($("#PN_myContents_ItemList").css("width").replaceAll("px", "")) / 2;
				var height = $(".PN_myContents_box").length ? parseInt($(".PN_myContents_box").css("height").replaceAll("px", "")) : 384;
				var posIdx = Math.round(targetX/width) + Math.round(targetY/height) * 2;
				
				var draggie = $(divWrap).find(".PN_myContents_box").draggable({
					handle: ".PN_portlet_handler"
				});
				
				pnMyPlace.pckry.packery("remove", $(".helper"));
				pnMyPlace.pckry.append($(divWrap)).packery("appended", $(divWrap));
				pnMyPlace.pckry.packery("bindUIDraggableEvents", draggie);
				
				var item = Packery.data(".PN_myContents_group").items.pop();
				Packery.data(".PN_myContents_group").items.splice(posIdx, 0, item);
				
				if(value.initMethod != "" && typeof(value.initMethod) != 'undefined'){
					if(typeof(value.ExtentionJSON) == 'undefined'){
						value.ExtentionJSON = $.parseJSON("{}");
					}
					
					//보안취약 조치(eval, Function)
					//let ptFunc = new Function('a', 'b', 'c', Base64.b64_to_utf8(value.initMethod)+'(a, b, c)');
					//ptFunc([], value.ExtentionJSON, 'myPlace') ;
					let fnName = Base64.b64_to_utf8(value.initMethod); // NS.fn
					coviCmn.callFnBasedNamespace(fnName, [], value.ExtentionJSON, 'myPlace');
				}
				
				if ($("#PN_myContents_hidden").length > 0) {
					pnMyPlace.pckry.packery("remove", $("#PN_myContents_hidden"));
					$("#PN_myContents_hidden").remove();
				}
				
				pnMyPlace.saveMyPlaceSetting();
			}catch(e){
				coviCmn.traceLog("myContent > webpart"+value.WebpartID+"<br>"+e);
			}
		});
	},
	setSortTable: function(){
		pnMyPlace.pckry = $(".PN_myContents_group").packery({
			percentPosition: true,
			itemSelector: ".PN_myContents_box, .helper",
			stagger: 0
		});
		
		var draggie = pnMyPlace.pckry.find(".PN_myContents_box").draggable({
			handle: ".PN_portlet_handler"
		});
		
		pnMyPlace.pckry.packery("bindUIDraggableEvents", draggie);
		
		pnMyPlace.pckry.off("dragItemPositioned").on("dragItemPositioned", function(event, ui){
			if($(ui.element).hasClass("helper")){
				var webpartID = $(ui.element).attr("wID");
				$(ui.element).css("visibility", "hidden");
				
				pnMyPlace.getMyPlaceWebpartList(webpartID, $(ui.element));
			}else{
				pnMyPlace.saveMyPlaceSetting();
			}
		});
	},
	saveMyPlaceSetting: function(){
		var webpartArr = new Array();
		
		var itemElems = pnMyPlace.pckry.packery("getItemElements");
		$(itemElems).each(function(i, itemElem) {
			webpartArr.push($(itemElem).closest("div[name=mycontents_webpart]").attr("value"));
		});
		  
		$.ajax({
			url: "/groupware/mycontents/saveMyContentsSetting.do",
			type: "POST",
			data: {
				webparts: webpartArr.join("-"),
				contentsMode: "MyPlace"
			},
			success:function(data){
				if(data.status=='SUCCESS'){
					pnMyPlace.pckry.packery("layout");
					$(".packery-drop-placeholder").length > 0 && $(".packery-drop-placeholder").remove();
				}else{
					Common.Error("<spring:message code='Cache.msg_MyP_ErrorMsg'/>");  // 에러가 발생하였습니다. 새로고침 후  다시 시도하여주세요.<br />지속적으로 문제가 발생하면 관리자에게 문의 바랍니다.
				}
			}, 
			error:function(response, status, error){
				 CFN_ErrorAjax("/groupware/mycontents/saveMyContentsSetting.do", response, status, error);
			}
		});
	},
	deleteMycontents : function(){
		$(".PN_portlet_menu li[mode=hide]").off("click").on("click", function(){
			pnMyPlace.pckry.packery("remove", $(this).parents(".PN_myContents_box"));
			$(this).parents("div[name='mycontents_webpart']").remove();
			
			pnMyPlace.saveMyPlaceSetting();
			
			if ($(".PN_myContents_box").length === 0) {
				$("#PN_myContents_ItemList").append($("<div/>", {"id": "PN_myContents_hidden", "class": "PN_myContents_box", "style": "visibility: hidden;"}));
				pnMyPlace.pckry.packery("appended", $("#PN_myContents_hidden"));
			}
			
			//오류 발생 시 원상 복귀 코드 
			/*$(this).parents("div[name='mycontents_webpart']").addClass("removeTarget");
			
			if(!myContents.saveMyContentsSetting()){
				$(this).parents("div[name='mycontents_webpart']").removeClass("removeTarget");
			}else{
				$(this).parents("div[name='mycontents_webpart']").remove();
			}*/
			
		});
	}, 
	setThumbSlide: function(){
		$(".PN_thumbnail").not(".slick-initialized").slick({
			slide: "div",			// 슬라이드 되어야 할 태그 ex) div, li
			infinite: true,			// 무한 반복 옵션
			slidesToShow: 7,		// 한 화면에 보여질 컨텐츠 개수
			slidesToScroll: 1,		// 스크롤 한번에 움직일 컨텐츠 개수
			speed: 500,				// 다음 버튼 누르고 다음 화면 뜨는데까지 걸리는 시간(ms)
			arrows: true, 			// 옆으로 이동하는 화살표 표시 여부
			dots: false,			// 스크롤바 아래 점으로 페이지네이션 여부
			autoplay: false,		// 자동 스크롤 사용 여부
			autoplaySpeed: 3000,	// 자동 스크롤 시 다음으로 넘어가는데 걸리는 시간 (ms)
			pauseOnHover: true,		// 슬라이드 이동 시 마우스 호버하면 슬라이더 멈추게 설정
			vertical: false,		// 세로 방향 슬라이드 옵션
			draggable: true,		// 드래그 가능 여부
			responsive: [
				{ // 반응형 웹 구현 옵션
					breakpoint: 1800, //화면 사이즈 960px
					settings: {
						//위에 옵션이 디폴트 , 여기에 추가하면 그걸로 변경
						slidesToShow: 6
					}
				},
				{
					breakpoint: 1600, //화면 사이즈 768px
					settings: {
						//위에 옵션이 디폴트 , 여기에 추가하면 그걸로 변경
						slidesToShow: 4
					}
				},
				{
					breakpoint: 1400, //화면 사이즈 1400px
					settings: {
						//위에 옵션이 디폴트 , 여기에 추가하면 그걸로 변경
						slidesToShow:3
					}
				}
			]
		});
		
		$(".PN_thumbnail [draggable!=true], .PN_thumbnail .slick-track").unbind("dragstart");
	},
	setWebpartDraggable: function(){
		$(".PN_thumbList").off("mousedown").on("mousedown", function(event){
			var webpartID = $(this).attr("wID");
			var chkVal = false;
			
			$("div[name=mycontents_webpart]:not(.removeTarget)").each(function(idx, obj){
				if($(obj).attr("value") == webpartID){
					Common.Warning("<spring:message code='Cache.msg_AlreadyAddWebpart'/>"); // 해당 웹파트가 이미 추가되어 있습니다.
					chkVal = true;
					return false;
				}
			});
			
			if(chkVal) return false;
			
			var $helper = $("<div class='helper'></div>")
				.append($(this).find("a").clone())
				.attr("wID", webpartID).css({"width": "149px", "z-index": "2000"});
			
			$helper.find(".thumbImg").css({"margin": "0 auto", "display": "block", "width": "126px", "height": "110px"});
			$helper.find(".thumbTit").css({"text-align": "center", "display": "block", "margin-top": "14px", "font-size": "17px"});
			
			var divX = $(event.currentTarget).offset().left;
			var divY = $(event.currentTarget).offset().top;
			var parentX = $(".PN_myContents_group").offset().left;
			var parentY = $(".PN_myContents_group").offset().top;
			
			$helper.appendTo($(".PN_myContents_group")).draggable();
			$helper.trigger(event);
			
			pnMyPlace.pckry.append($helper).packery("appended", $helper);
			pnMyPlace.pckry.packery("bindUIDraggableEvents", $helper);
			
			$helper.css({
				left: (divX - parentX - 30) + "px",
				top: (divY - parentY - 30) + "px",
				position: "absolute"
			});
		});
	},
	toggleMyPlace: function(target){
		var $myContents = $(target).parents().find(".PN_myContents")
		if($myContents.is(":hidden") == false){
			$(target).toggleClass("active");
			$myContents.toggleClass("active");
			saveUserPortalOption();
		}
	},
	toggleEditMode: function(target){
		var $thumbnail = $(target).parents().find(".PN_thumbnail");
		var mode = target.dataset.editMode;
		
		$(target).toggleClass('active');
		$thumbnail.toggle();
		$thumbnail.toggleClass("active");
		
		$(target).html((mode == 'off') ? "<spring:message code='Cache.lbl_Completed'/>" : "<spring:message code='Cache.btn_apv_modify'/>");
		if(mode == 'off'){
			// 조회된 항목이 있을 때만 setThumbSlide() 실행.
			// 웹파트관리에서 데이터를 추가할 때, 사용범위(Range)가 'MyPlace'로 등록된 웹파트를 불러온다.
			if ($thumbnail.find(".PN_thumbList").length > 0) {
				pnMyPlace.setThumbSlide();	
			} else {
				if ($thumbnail.find(".PN_nolist").length == 0) {
					var txtNoList = '<div class="PN_nolist" style="padding: 0px 0px;">';
						txtNoList += '<p class="list_none"><spring:message code="Cache.msg_NoDataList"/><br/><spring:message code="Cache.msg_WebPartManage_17"/></p>';    // 조회할 목록이 없습니다. 웹 모듈 사용범위를 선택하여 주십시오.
						txtNoList += '</div>';
					$thumbnail.append(txtNoList);	
				}
			}
		}
		
		$(target).attr("data-edit-mode", (mode == 'off') ? 'on' : 'off');
	}
}
