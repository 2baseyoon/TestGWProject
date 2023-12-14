////////////////////////////////////////// 관리자 Menu (top, left) ////////////////////////////////

function toggleheadermenu(pObj){
	$(pObj).find(".gnb_sub").toggle();

}

///////////////////////////////////////////////////////////////

//로그아웃 버튼 클릭시 호출 > 세션 스토리지 초기화
var XFN_LogOut = function () {
	XFN_closeWindowOpenList();
    coviCmn.clearLocalCache();
    Common.Progress("Logout...", function () { location.href = "/covicore/logout.do"; }, 1200);
}

// 관리자상단 메뉴 선택
function XFN_SelectedTopMenu_Admin(pUrl) {
    // 선택된 상단 메뉴 정보 기억
    window.sessionStorage.setItem("TopMenuUrl_Admin", pUrl);

    // 좌측 메뉴 선택 상태값 초기화
    if (window.sessionStorage.getItem("AdminLeftID") != undefined && window.sessionStorage.getItem("AdminLeftID") != null && window.sessionStorage.getItem("AdminLeftID") != "" && window.sessionStorage.getItem("AdminLeftID") != "undefined")
        window.sessionStorage.removeItem("AdminLeftID");
}
//사용자상단 메뉴 선택
function XFN_SelectedTopMenu_User(pUrl) {
    // 선택된 상단 메뉴 정보 기억
    window.sessionStorage.setItem("TopMenuUrl_User", pUrl);

    // 좌측 메뉴 선택 상태값 초기화
    if (window.sessionStorage.getItem("UserLeftID") != undefined && window.sessionStorage.getItem("UserLeftID") != null && window.sessionStorage.getItem("UserLeftID") != "" && window.sessionStorage.getItem("UserLeftID") != "undefined")
        window.sessionStorage.removeItem("UserLeftID");
}

// 관리자 좌측 메뉴 선택
function XFN_SelectedLeftMenu_Admin(pId, pMenuSave) {
    if (pMenuSave) { window.sessionStorage.setItem("AdminLeftID", pId); } // 구분 메뉴의 경우에는 메뉴아이디를 저장하지 않음.
}
//사용자 좌측 메뉴 선택
function XFN_SelectedLeftMenu_User(pId, pMenuSave) {
    if (pMenuSave) { window.sessionStorage.setItem("UserLeftID", pId); } // 구분 메뉴의 경우에는 메뉴아이디를 저장하지 않음.
}

//ywcho, header menu draw
function drawAdminHeaderMenu(pObj) {
	var headermenuhtml = "<ul>";

	$(pObj).each(function(){
		if(this.sub != undefined && this.sub.length > 0){
			headermenuhtml += "<li class='off' onmouseover='toggleheadermenu(this);' onmouseout='toggleheadermenu(this);'><a href='"+ this.url +"'>" + this.label + "</a>";

			headermenuhtml += "<div class='gnb_sub' style='display:none'>"
			$(this.sub).each(function () {
				headermenuhtml += "<a href='"+ this.url +"' onclick='XFN_SelectedTopMenu_Admin(this);'><div>" + this.label + "</div></a>";
			});
			headermenuhtml += "</div>"
		} else {
			headermenuhtml += "<li class='off over_non'><a href='"+ this.url +"' onclick='XFN_SelectedTopMenu_Admin(this);'>" + this.label + "</a>";
		}
		headermenuhtml += "</li>";
	});

	headermenuhtml+="</ul>";

	return headermenuhtml;
}


/////admin left menu draw/////////

var adminleftmenuhtml = "";

function drawleftmenu(pObj,pDepth) {
	var leftmenu_depth = pDepth + 1;

	$(pObj).each(function(){
		if(this.cn != undefined && this.cn.length > 0){
			adminleftmenuhtml += "<li class='list_" + leftmenu_depth + "dep_close'><a href='"+ this.url +"' id='adminleft_" + this.menuid +"' onclick='toggleleftmenu(this);'>" + this.label + "</a>";

			adminleftmenuhtml+="<ul>";
			drawleftmenu(this.cn, leftmenu_depth);
			adminleftmenuhtml+="</ul>";
		} else {
			adminleftmenuhtml += "<li class='list_" + leftmenu_depth + "dep'><a id='adminleft_" + this.menuid + "' href='"+ this.url +"' onclick='return XFN_SelectedLeftMenu_Admin(\"" + this.menuid + "\",true);'>" + this.label + "</a>";
		}
		adminleftmenuhtml += "</li>";

	});
}

function toggleleftmenu(pObj){
	if($(pObj).parent().find("ul").length > 0){/*
		if($(pObj).parent().attr("class") != "list_1dep_f"){
			$($(pObj).parent().parent().find(".list_1dep_open")).find("ul").toggle();
			$($(pObj).parent().parent().find(".list_1dep_open")).attr("class","list_1dep_close");
		}*/
		if($($(pObj).parent().parent().find(".list_1dep_open")).length > 0){
			if($($(pObj).parent().parent().find(".list_1dep_open")).length != 1 || !($($(pObj).parent().parent().find(".list_1dep_open")).is($(pObj).parent())) ){
				$($(pObj).parent().parent().find(".list_1dep_open")).find("ul").toggle();
				$($(pObj).parent().parent().find(".list_1dep_open")).attr("class","list_1dep_close");
			}
		}
		
		$(pObj).parent().find("ul").toggle();

		if($(pObj).parent().find("ul").is(":visible") == true ){
			$(pObj).parent().attr("class",$(pObj).parent().attr("class").replace(/_close/gi,"_open"));
		} else {
			$(pObj).parent().attr("class",$(pObj).parent().attr("class").replace(/_open/gi,"_close"));
		}
	}
}

function drawadminleftmenu (pData) {
	drawleftmenu(pData,0);

	$(".lnb_list").html(adminleftmenuhtml);

	$(".lnb_list > li > ul").each(function(){
		$(this).hide();
	});

	$("li[class*=list]").each(function () {
		if($(this).find("ul").is(":visible") == true ){
			$(pObj).attr("class",$(pObj).attr("class").replace(/_close/gi,"_open"));
		} else {
			$(this).attr("class",$(this).attr("class").replace(/_open/gi,"_close"));
		}
	});

	if(window.sessionStorage.getItem("AdminLeftID") != undefined && window.sessionStorage.getItem("AdminLeftID") != null && window.sessionStorage.getItem("AdminLeftID") != "" && window.sessionStorage.getItem("AdminLeftID") != "undefined"){
		if($("#adminleft_" + window.sessionStorage.getItem("AdminLeftID")).parent().attr("class") == "list_2dep")
			toggleleftmenu($("#adminleft_" + window.sessionStorage.getItem("AdminLeftID")).parent().parent());

		$("#adminleft_" + window.sessionStorage.getItem("AdminLeftID")).css("color","#ff832c");
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////

/////user left menu draw/////////

var userleftmenuhtml = "";

function drawleftmenudetail(pObj,pDepth) {
	//var leftmenu_depth = pDepth + 1;
	$(pObj).each(function(){
//		if(this.cn != undefined && this.cn.length > 0){
//			//userleftmenuhtml += "<li class='list_" + leftmenu_depth + "dep_close'><a href='"+ this.url +"' id='userleft_" + this.menuid +"' onclick='toggleuserleftmenu(this);' alias='" + this.alias + "'>" + this.label + "</a>";
//			userleftmenuhtml += "<li class='"+this.SortPath+"'><a href='"+ this.url +"' id='userleft_" + this.menuid +"' onclick='toggleuserleftmenu(this);' alias='" + this.alias + "'>" + this.label + "</a>";
//			userleftmenuhtml+="<ul>";
//			drawleftmenudetail(this.cn,leftmenu_depth);
//			userleftmenuhtml+="</ul>";
//		} else {
//			//userleftmenuhtml += "<li class='list_" + leftmenu_depth + "dep'><a id='userleft_" + this.menuid + "' href='"+ this.url +"' onclick='return XFN_SelectedLeftMenu_User(\"" + this.menuid + "\",true);' alias='" + this.alias + "'>" + this.label + "</a>";
//			userleftmenuhtml += "<li class='"+this.SortPath+"'><a id='userleft_" + this.menuid + "' href='"+ this.url +"' onclick='return XFN_SelectedLeftMenu_User(\"" + this.menuid + "\",true);' alias='" + this.alias + "'>" + this.label + "</a>";
//		}
//		userleftmenuhtml += "</li>";
//		if(this.cn != undefined && this.cn.length > 0){
//			//userleftmenuhtml += "<li class='list_" + leftmenu_depth + "dep_close'><a href='"+ this.url +"' id='userleft_" + this.menuid +"' onclick='toggleuserleftmenu(this);' alias='" + this.alias + "'>" + this.label + "</a>";
//			userleftmenuhtml += "<li class='"+this.SortPath+"'><a href='"+ this.url +"' id='userleft_" + this.menuid +"' onclick='toggleuserleftmenu(this);' alias='" + this.alias + "'>" + this.label + "</a>";
//			userleftmenuhtml+="<ul>";
//			drawleftmenudetail(this.cn,leftmenu_depth);
//			userleftmenuhtml+="</ul>";
//		} else {
			//userleftmenuhtml += "<li class='list_" + leftmenu_depth + "dep'><a id='userleft_" + this.menuid + "' href='"+ this.url +"' onclick='return XFN_SelectedLeftMenu_User(\"" + this.menuid + "\",true);' alias='" + this.alias + "'>" + this.label + "</a>";
			if(this.menuid == 474){ // 개인함
				if(approvalCnt != 0 || tcInfoCnt != 0){ //미결함-진행함-참조함 안읽음 표시
					userleftmenuhtml += "<li class='"+this.SortPath+"'><a id='userleft_" + this.menuid + "' href='"+ this.url +"' onclick='return XFN_SelectedLeftMenu_User(\"" + this.menuid + "\",true);' alias='" + this.alias + "'>" + this.label + "<span class=\"newIcn\">new</span></a>";
				}else{
					userleftmenuhtml += "<li class='"+this.SortPath+"'><a id='userleft_" + this.menuid + "' href='"+ this.url +"' onclick='return XFN_SelectedLeftMenu_User(\"" + this.menuid + "\",true);' alias='" + this.alias + "'>" + this.label + "</a>";
				}
			}else if(this.menuid == 484){ // 부서함
				if(receiveCnt != 0 || deptTcInfoCnt != 0){ // 수신함-참조함 안읽음 표시
					userleftmenuhtml += "<li class='"+this.SortPath+"'><a id='userleft_" + this.menuid + "' href='"+ this.url +"' onclick='return XFN_SelectedLeftMenu_User(\"" + this.menuid + "\",true);' alias='" + this.alias + "'>" + this.label + "<span class=\"newIcn\">new</span></a>";
				}else{
					userleftmenuhtml += "<li class='"+this.SortPath+"'><a id='userleft_" + this.menuid + "' href='"+ this.url +"' onclick='return XFN_SelectedLeftMenu_User(\"" + this.menuid + "\",true);' alias='" + this.alias + "'>" + this.label + "</a>";
				}
			}else{
				userleftmenuhtml += "<li class='"+this.SortPath+"'><a id='userleft_" + this.menuid + "' href='"+ this.url +"' onclick='return XFN_SelectedLeftMenu_User(\"" + this.menuid + "\",true);' alias='" + this.alias + "'>" + this.label + "</a>";
			}
//		}
		userleftmenuhtml += "</li>";

	});
}

function toggleuserleftmenu(pObj){
	if($(pObj).parent().find("ul").length > 0){
		if($(pObj).parent().attr("class") != "list_1dep_open"){
			$($(pObj).parent().parent().find(".list_1dep_open")).find("ul").toggle();
			$($(pObj).parent().parent().find(".list_1dep_open")).attr("class","list_1dep_close");
		}

		$(pObj).parent().find("ul").toggle();

		if($(pObj).parent().find("ul").is(":visible") == true ){
			$(pObj).parent().attr("class",$(pObj).parent().attr("class").replace(/_close/gi,"_open"));
		} else {
			$(pObj).parent().attr("class",$(pObj).parent().attr("class").replace(/_open/gi,"_close"));
		}
	}
}

function drawuserleftmenu (pData) {
	drawleftmenudetail(pData,0);
	$(".lmb_menu").html(userleftmenuhtml);
//	$(".lmb_menu > li > ul").each(function(){
//		$(this).hide();
//	});
//	$("li[class*=lmb]").each(function () {
//		if($(this).find("ul").is(":visible") == true ){
//			$(pObj).attr("class",$(pObj).attr("class").replace(/_off/gi,"_on"));
//		} else {
//			$(this).attr("class",$(this).attr("class").replace(/_open/gi,"_close"));
//		}
//	});
//	$("li[class*=lmb]").each(function () {
//	if($(this).find("ul").is(":visible") == true ){
//		$(pObj).attr("class",$(pObj).attr("class").replace(/_off/gi,"_on"));
		//$(pObj).parent().attr("class",$(pObj).parent().attr("class").replace(/_off/gi,"_on"));
//	}
//});

	//수정
	if(window.sessionStorage.getItem("UserLeftID") != undefined && window.sessionStorage.getItem("UserLeftID") != null && window.sessionStorage.getItem("UserLeftID") != "" && window.sessionStorage.getItem("UserLeftID") != "undefined"){
		$("#userleft_" + window.sessionStorage.getItem("UserLeftID")).parent().attr("class",$("#userleft_" + window.sessionStorage.getItem("UserLeftID")).parent().attr("class").replace(/_off/gi,"_on"));
	}
	//
	if(window.sessionStorage.getItem("UserLeftID") != undefined && window.sessionStorage.getItem("UserLeftID") != null && window.sessionStorage.getItem("UserLeftID") != "" && window.sessionStorage.getItem("UserLeftID") != "undefined"){
		if($("#userleft_" + window.sessionStorage.getItem("UserLeftID")).parent().attr("class") == "list_2dep")
			toggleuserleftmenu($("#userleft_" + window.sessionStorage.getItem("UserLeftID")).parent().parent());

		$("#userleft_" + window.sessionStorage.getItem("UserLeftID")).css("color","#ff832c");
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////

(function(){	
	var addScript = function(src){		
		var $script = document.createElement("script");	
		$script.type = "text/javascript";
		$script.src = src;
		document.head.appendChild($script);		
	}	
	addScript("/covicore/resources/script/jszip.min-3.1.5.js");
	addScript("/covicore/resources/script/FileSaver.min.js");
})();

var Common = {
		isDevMode: "N",
	    minWidth: 30,
	    minHeight: 20,
	    align: "center",
	    toTop: function (id) {
	        var str = id.substr(id.length - 2);
	        var rid = id;
	        if (str != "_p") {
	            rid += "_p"
	        }

	        var zMax = parseInt($("#" + rid).css("zIndex"), 10); // 자신의 Z-Index를 가져옴.

	        $(".layer_divpop").each(function () {
	            if ($(this).attr("id") != $("#" + rid).attr("id") && $(this).attr("ModalLayer") == $("#" + rid).attr("ModalLayer")) {
	                if (parseInt($(this).css("zIndex"), 10) > zMax) {
	                    zMax = $(this).css("zIndex")
	                }
	            }
	        });

	        var val = parseInt(zMax, 10) + 1;
	        $("#" + rid).css("zIndex", val);
	    },
	    toCenter: function (id) {
	        var top = parseInt($(window).scrollTop(), 10);
	        var left = parseInt($(window).scrollLeft(), 10);
	        var rid = id + "_p";
	        var pos = $("#" + rid).offset();
	        var box_x = parseInt($("#" + rid).width(), 10);
	        var box_y = parseInt($("#" + rid).height(), 10);
	        var center_x = parseInt($(window).width(), 10) / 2 - box_x / 2 + left;
	        var center_y = parseInt($(window).height(), 10) / 2 - box_y / 2 + top;
	        if (center_y < 0) { center_y = 0; }
	        if (center_x < 0) { center_x = 0; }

	        // 띄우려고 하는 위치에 레이어가 존재한다면
	        $(".layer_divpop").each(function () {
	            if ($(this).attr("id") != $("#" + rid).attr("id") && $(this).attr("ModalLayer") == $("#" + rid).attr("ModalLayer")) {
	                if (parseInt($(this).css("left"), 10) == parseInt(center_x)) {
	                    center_x = center_x + 22;
	                }

	                if (parseInt($(this).css("top"), 10) == parseInt(center_y)) {
	                    center_y = center_y + 32;
	                }
	            }
	        });

	        $("#" + rid).css({ left: center_x, top: center_y })
	    },
	    toResize: function (object_id, w, h) {
	        var l_HederSize = $(".divpop_header").height() + 6;
	        $("#" + object_id + "_pc").css({ "width": w, "height": h }) // 팝업 레이어 창에 대한 사이즈 조정
	        $("#" + object_id + "_pc").css("width", $("#" + object_id + "_pc").width() - 40); //20160513 안기현 수정
	        $("#" + object_id + "_ph").css({ "width": w }) // 팝업 레이어 창에 해더에 대한 사이즈 조정(제목 말줄임을 위해)
	        $("#" + object_id + "_ph").css("width", $("#" + object_id + "_ph").width() + 6); //20160513 안기현 수정
	        $("#" + object_id + "_p").css({ "width": parseInt(w, 10) + 6, "height": parseInt(h, 10) + l_HederSize }) // 팝업 레이어 창에 대한 사이즈 조정
	        $("#" + object_id + "_hideDiv").css({ "width": parseInt(w, 10) + 6, "height": parseInt(h, 10) + l_HederSize }) // ActiveX에 대한 레이어 숨김 현상을 막기 위해
	        $("#" + object_id + "_hideIfram").attr({ "width": parseInt(w, 10) + 6, "height": parseInt(h, 10) + l_HederSize }) // ActiveX에 대한 레이어 숨김 현상을 막기 위해
	        if ($("#" + object_id + "_if").length > 0) {
	            $("#" + object_id + "_if").css("height", $("#" + object_id + "_p").height() - l_HederSize);
	            $("#" + object_id + "_if").css("width", $("#" + object_id + "_p").width() - 2);
	        }
	    },
	    toResizeDynamic: function (object_id, content_id) {
			var w = $("#" + content_id).innerWidth();
			var h = $("#" + content_id).innerHeight();
			if(h > parent.window.innerHeight-100){
				h = parent.window.innerHeight-100;
			}
	        var l_HederSize = $(".divpop_header", parent.document).height() + 6;
	        $("#" + object_id + "_pc", parent.document).css({ "width": w, "height": h }) // 팝업 레이어 창에 대한 사이즈 조정
	        $("#" + object_id + "_pc", parent.document).css("width", $("#" + object_id + "_pc", parent.document).width() - 40); //20160513 안기현 수정
	        $("#" + object_id + "_ph", parent.document).css({ "width": w }) // 팝업 레이어 창에 해더에 대한 사이즈 조정(제목 말줄임을 위해)
	        $("#" + object_id + "_ph", parent.document).css("width", $("#" + object_id + "_ph", parent.document).width() + 6); //20160513 안기현 수정
	        $("#" + object_id + "_p", parent.document).css({ "width": parseInt(w, 10) + 6, "height": parseInt(h, 10) + l_HederSize }) // 팝업 레이어 창에 대한 사이즈 조정
	        $("#" + object_id + "_hideDiv", parent.document).css({ "width": parseInt(w, 10) + 6, "height": parseInt(h, 10) + l_HederSize }) // ActiveX에 대한 레이어 숨김 현상을 막기 위해
	        $("#" + object_id + "_hideIfram", parent.document).attr({ "width": parseInt(w, 10) + 6, "height": parseInt(h, 10) + l_HederSize }) // ActiveX에 대한 레이어 숨김 현상을 막기 위해
	        if ($("#" + object_id + "_if", parent.document).length > 0) {
	            $("#" + object_id + "_if", parent.document).css("height", $("#" + object_id + "_p", parent.document).height() - l_HederSize);
	            $("#" + object_id + "_if", parent.document).css("width", $("#" + object_id + "_p", parent.document).width() - 2);
	        }
			parent.Common.toCenter(object_id);
	    },
	    close: function (object_id) {
	        // 창을 닫기전 타입이 ContainerId였다면 팝업에 있는 컨텐츠를 다시 불러온 페이지 넣어줌.
	        if ($("#" + object_id + "_p").attr("layerType") == "id") {
	            if ($("#" + object_id + "_p").attr("pProperty").indexOf("contentMove") > -1) { // 객체를 이동시킴
	                $("#" + $("#" + object_id + "_p").attr("source")).append($("#" + object_id + "_pc").children());
	            } else {
	                $("#" + $("#" + object_id + "_p").attr("source")).html($("#" + object_id + "_pc").html());
	            }
	        }
	        //모달인 경우 먼저 overlay 레이어를 닫음.
	        if ($("#" + object_id + "_overlay").length > 0) {
	            $("#" + object_id + "_overlay").hide();
	            $("#" + object_id + "_overlay").detach();
	        }

	        $("#" + object_id + "_container").slideUp(500, function () {
	            // 하위위의 존재하는 컨텐츠 들도 제거
	            $("#" + object_id + "_ph").detach();
	            $("#" + object_id + "_hideIfram").detach();
	            $("#" + object_id + "_hideDiv").detach();
	            $("#" + object_id + "_pc").detach();

	            if ($("#" + object_id + "_if").length > 0) {
	                $("#" + object_id + "_if").detach();
	            }
	            $("#" + object_id + "_p").detach();
	        });
	    },

	    // 레이어 팝업 형태 생성
	    CreatePopup: function (object_id, w, h, type, source, pIsModal, pProperty, pReSize,objectType) {
	        // 모달일 경우는 기존 레이어 보다 상위로 올림
	        var l_LayerZindex = "50";
	        if (pIsModal) { l_LayerZindex = "103"; }

	        // id 인경우만 창을 닫을때 되돌려 주기위해~~!
	        var l_source = source;
	        if (type != "id") { l_source = type }

	        //컨텐츠가 로드 되기전 레이어 표시를 위해 기본 사이즈를 표시
	        var l_pcStyle = "";
	        //l_pcStyle = "width:" + w + ";height:" + h;
	        l_pcStyle = "height:" + h; //20160408 안기현 수정

	        //Body Layer의 Property 조정
	        var l_bodyProperty = "overflow:hidden;";
	        if (pProperty.indexOf("bodyScroll") > -1) {
	            l_bodyProperty = "overflow:auto;";
	        }

	        if(objectType == 'UA'){
	        	l_bodyProperty = l_bodyProperty +"padding: 30px;";
	        }
	        
	        var popupwrapper = '<div id="' + object_id + '_p" class="layer_divpop" pProperty="' + pProperty + '" layerType="' + type + '" ModalLayer="' + pIsModal + '" source="' + l_source + '" style="z-index:' + l_LayerZindex + '">';
	        // ActiveX에 대한 Z-Index 조정을 위한 Iframe 삽입
	        popupwrapper += '<div id="' + object_id + '_hideDiv" style="position:absolute;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"><iframe frameborder="0" id="' + object_id + '_hideIfram"></iframe></div>'
	        popupwrapper += '<div id="' + object_id + '_container" class="divpop_contents">';
	        if (type.indexOf("iframe") > -1 || type.indexOf("url") > -1) {
	            // 리사이즈 이벤트 처리
	            if (pReSize) {
	                popupwrapper += '<div id="' + object_id + '_ph"><h4 id="' + object_id + '_Title" class="divpop_header"></h4>' +
	                    '<a id="' + object_id + '_px" class="divpop_close" style="cursor:pointer;"></a>' +
	                    '<a class="divpop_window" id="' + object_id + '_LayertoWindow" style="cursor:pointer;display:none;" onclick="Common.LayerToWindow(\'' + source + '\', \'' + object_id + '\', \'' + w + '\', \'' + h + '\', \'both\')"></a>' +
	                    '<a class="divpop_full" style="cursor:pointer;" onclick="Common.ScreenFull(\'' + object_id + '\', $(this))"></a>' +
	                    '<a class="divpop_mini" style="cursor:pointer;" onclick="Common.ScreenMini(\'' + object_id + '\', $(this))"></a></div>';
	            } else {
	                popupwrapper += '<div id="' + object_id + '_ph"><h4 id="' + object_id + '_Title" class="divpop_header"></h4>' +
	                    '<a id="' + object_id + '_px" class="divpop_close" style="cursor:pointer;"></a>' +
	                    '<a class="divpop_window_fix" id="' + object_id + '_LayertoWindow" style="cursor:pointer;display:none;" onclick="Common.LayerToWindow(\'' + source + '\', \'' + object_id + '\', \'' + w + '\', \'' + h + '\', \'fix\')"></a>' +
	                    '<a class="divpop_full" style="cursor:pointer;display:none;" onclick="Common.ScreenFull(\'' + object_id + '\')"></a>' +
	                    '<a class="divpop_mini" style="cursor:pointer;" onclick="Common.ScreenMini(\'' + object_id + '\')"></a></div>';
	            }
	        } else {
	            popupwrapper += '<div id="' + object_id + '_ph"><h4 id="' + object_id + '_Title" class="divpop_header"></h4>' +
	                '<a id="' + object_id + '_px" class="divpop_close" style="cursor:pointer;"></a>' +
	                '<a class="divpop_full" style="cursor:pointer;display:none;" onclick="Common.ScreenFull(\'' + object_id + '\')"></a>' +
	                '<a class="divpop_mini" style="cursor:pointer;" onclick="Common.ScreenMini(\'' + object_id + '\')"></a>' +
	                '</div>';
	        }

	        popupwrapper += '<div class="divpop_body" style="' + l_bodyProperty + '">';
	        popupwrapper += '<div id="' + object_id + '_pc" style="' + l_pcStyle + '"><div style="position:absolute;top:43%;left:43%;"></div></div>'; // 컨텐츠 삽입 장소
	        popupwrapper += '</div>';
	        popupwrapper += '</div>';
	        //popupwrapper += '<div id="' + object_id + '_ps" class="jqpopup_resize"></div>';
	        popupwrapper += '</div>';

	        try {
	            return popupwrapper
	        } finally {
	            popupwrapper = null;
	        }
	    },
	    open: function (button_id, object_id, title, source, w, h, pMode, pIsModal, posX, posY, pReSize, objectType) {
	    	
	        var l_Mode = "" // 컨텐츠 로드 방식
	        var l_Property = "" // 레이어 및 하위 컨텐츠 속성 설정
	        if (pMode.split("-").length > 1) { // 프로퍼티 처리
	            l_Mode = pMode.split("-")[0];
	            l_Property = pMode.split("-")[1];
	        } else {
	            l_Mode = pMode;
	        }

	        var content = this.CreatePopup(object_id, w, h, l_Mode, source, pIsModal, l_Property, pReSize,objectType);
	        if ($("#" + object_id + "_p").length > 0) {
	            Common.toTop(object_id);
	            return false;
	        }

	        $("body").append(content);

	        // 레이어 팝업의 X버튼 처리(특정 서버 PC에 문제점)
	        $('#' + object_id + '_px').bind("click", function () {
	            Common.close(object_id);
	        });

	        var l_HederSize = $(".divpop_header").height() + 6;
	        // 컨텐츠 사이즈 지정
	        if (parseInt(w, 10) == 0 || parseInt(h, 10) == 0) {
	            $("#" + object_id + "_p").css({ "width": parseInt(w, 10) + 6, "height": parseInt(h, 10) }) // 팝업 레이어 창에 대한 사이즈 조정
	            //$("#" + object_id + "_ph").css({ "width": w }) // 팝업 레이어 창에 해더에 대한 사이즈 조정(제목 말줄임을 위해) //20160408 안기현 수정
	            $("#" + object_id + "_hideDiv").css({ "width": parseInt(w, 10) + 6, "height": parseInt(h, 10) }) // ActiveX에 대한 레이어 숨김 현상을 막기 위해
	            $("#" + object_id + "_hideIfram").attr({ "width": parseInt(w, 10) + 6, "height": parseInt(h, 10) }) // ActiveX에 대한 레이어 숨김 현상을 막기 위해
	        } else {
	            $("#" + object_id + "_p").css({ "width": parseInt(w, 10) + 6, "height": parseInt(h, 10) + l_HederSize }) // 팝업 레이어 창에 대한 사이즈 조정
	            //$("#" + object_id + "_ph").css({ "width": w }) // 팝업 레이어 창에 해더에 대한 사이즈 조정(제목 말줄임을 위해) //20160408 안기현 수정
	            $("#" + object_id + "_hideDiv").css({ "width": parseInt(w, 10) + 6, "height": parseInt(h, 10) + l_HederSize }) // ActiveX에 대한 레이어 숨김 현상을 막기 위해
	            $("#" + object_id + "_hideIfram").attr({ "width": parseInt(w, 10) + 6, "height": parseInt(h, 10) + l_HederSize }) // ActiveX에 대한 레이어 숨김 현상을 막기 위해
	        }
	        // 파라메터 암호화 관련 처리
	        if (l_Mode == "iframe" || l_Mode == "url") {
	            if (source.indexOf("EncryptURL=") > -1) {
	                if (source.indexOf("EncryptURL=M") > -1) {
	                    var l_param = source.split("?")[1]
	                    source = Common.GetEncryptURL(fileName) + "&" + l_param.replace("&EncryptURL=M", "");
	                } else {
	                    source = Common.GetEncryptURL(fileName)
	                }
	            }
	        }
	        // 받은 URL로 iframe을 삽입하고 경로를 설정함.
	        if (l_Mode == "iframe") {
	            var l_iframeProperty = 'scrolling = "auto"';
	            if (l_Property.indexOf("ifNoScroll") > -1) {
	                l_iframeProperty = 'scrolling = "no"';
	            }
	            if (source.indexOf("?") > -1) { source += "&CFN_OpenLayerName=" + object_id; } else { source += "?CFN_OpenLayerName=" + object_id; }
	            var html = '<iframe id="' + object_id + '_if" class="bgiframe" frameborder="0" src="' + source + '" style="display:block;position:relative;width:100%;" ' + l_iframeProperty + '/>';
	            $("#" + object_id + "_pc").html(html);
	            // URL을 받아서 Ajax로 컨텐츠를 받아다가 로드시킴.
	        } else if (l_Mode == "url") {
	            if (source.indexOf("?") > -1) { source += "&CFN_OpenLayerName=" + object_id; } else { source += "?CFN_OpenLayerName=" + object_id; }
	            $("#" + object_id + "_pc").load(source, null, function (response, status, xhr) {
	                if (status == "error") {
	                    var msg = "Sorry but there was an error: ";
	                    Common.Error(msg + xhr.status + " " + xhr.statusText, "Error");
	                }
	            });
	            // html 컨텐츠를 바로 삽입함.
	        } else if (l_Mode == "html") {
	            $("#" + object_id + "_pc").html(source);
	            // 컨테이너 아이디를 받아서 컨텐츠 꺼내어 넣어줌.
	        } else if (l_Mode == "id") {
	            if (l_Property.indexOf("contentMove") > -1) { // 객체를 이동시킴
	                $("#" + object_id + "_pc").html("");
	                $("#" + object_id + "_pc").append($("#" + source).children());
	            } else {
	                $("#" + object_id + "_pc").html($("#" + source).html());
	                $("#" + source).html("");
	            }
	        }

	        if (parseInt(w, 10) == 0 || parseInt(h, 10) == 0) {
	            $("#" + object_id + "_p").css({ "width": 0, "height": 0 }) //20160408 안기현 수정
	            $("#" + object_id + "_ph").attr("class","pop_header"); //20160408 안기현 수정
	            $("#" + object_id + "_ph").hide();
	            // Layer Draggable 처리
	            $("#" + object_id + "_p").draggable({ handle: $("#" + object_id + "_pc") }).draggable({ iframeFix: true }).draggable({ containment: 'document' });
	        } else {
	            // Layer Draggable 처리
	            $("#" + object_id + "_p").draggable({ handle: $("#" + object_id + "_Title") }).draggable({ iframeFix: true }).draggable({ containment: 'document' });
	            $("#" + object_id + "_ph").attr("class","pop_header"); //20160408 안기현 수정
	        }

	        // 모달일 경우 바닥을 까는 레이어를 추가함.
	        if (pIsModal) {
	        	var overlay;
	            $("body").append(overlay = $('<div id="' + object_id + '_overlay"></div>'));
	            $('#' + object_id + '_overlay').bind("click", function (e) {
	                if (_ie) { $('#' + object_id + '_p').hide(5).show(10) }
	                else { $('#' + object_id + '_p').hide(5).show(5).hide(5).show(5) }
	            });
	            $('#' + object_id + '_overlay').css({
	                position: 'fixed',
	                zIndex: 59,
	                top: '0px',
	                left: '0px',
	                width: '100%',
	                height: $("body").height(),
	                background: "#000000",
	                opacity: "0.3"
	            });
	        } else {
	            // 최상위로 올리는 처리
	            $("#" + object_id + "_p").bind("click", function () {
	                Common.toTop(object_id);
	            });
	        }

	        if (posX == undefined || posY == undefined) {
	            Common.toCenter(object_id);
	        } else {
	            if (posX == "target") { posX = $(button_id).offset().left + 15; }
	            if (posY == "target") { posY = $(button_id).offset().top + 15; }
	            $("#" + object_id + "_p").css({ left: posX, top: posY });
	        }

	        // Layer Title 설정
	        if (title.split("|||").length > 1) { // 프로퍼티가 있다면
	            $("#" + object_id + "_ph .divpop_header").html('<span class="divpop_header_ico">' + title.split("|||")[0] + '</span>');
	            $("#" + object_id + "_ph .divpop_header").append("<span class='menubar_gray5'>&nbsp;I&nbsp;</span> <span class='txt_gn11'>" + title.split("|||")[1] + "</span>");
	        } else {
	            $("#" + object_id + "_ph .divpop_header").html('<span class="divpop_header_ico">' + title + '</span>');
	        }
	        // iframe의 사이즈 조정
	        if ($("#" + object_id + "_if").length > 0) {
	            $("#" + object_id + "_if").css("height", $("#" + object_id + "_p").height() - l_HederSize);
	        }

	        // 현재 띄운 창을 가장 위로 올림.
	        Common.toTop(object_id);

	        // z-Index 조정
	        if (pIsModal) {
	            $("#" + object_id + "_overlay").css("zIndex", parseInt($("#" + object_id + "_p").css("zIndex"), 10) - 1);
	        }
	    },
	    CreateBalloon: function (object_id, title, content, halign) {
	        var balloonwrapper = '<div id="' + object_id + '_p" class="layer_balloon" style="z-index:40">';
	        if (_ie) {
	            if (_ieVer < 9) {
	                balloonwrapper += '<div id="' + object_id + '_hideDiv" style="position:absolute;top:0px;left:0px;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"><iframe style="margin-left:-1px;" frameborder="0" id="' + object_id + '_hideIfram"></iframe></div>'
	            } else {
	                balloonwrapper += '<div id="' + object_id + '_hideDiv" style="position:absolute;top:-1px;left:-1px;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"><iframe frameborder="0" id="' + object_id + '_hideIfram"></iframe></div>'
	            }
	        } else {
	            balloonwrapper += '<div id="' + object_id + '_hideDiv" style="position:absolute;top:-1px;left:-1px;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"><iframe frameborder="0" id="' + object_id + '_hideIfram"></iframe></div>'
	        }

	        balloonwrapper += '<div id="' + object_id + '_pc" style="position:absolute;"><strong>' + title + '</strong>';
	        balloonwrapper += '<p>' + content + '</p>';
	        balloonwrapper += '</div>'
	        //<!--꼭지가 우측에 있어야 할때는 edge_rgt 클래스 사용 -->
	        if (halign == "center") {
	            balloonwrapper += '<div id="' + object_id + '_xyTop" class="edge_cen">';
	        } else if (halign == "right") {
	            balloonwrapper += '<div id="' + object_id + '_xyTop" class="edge_rgt">';
	        } else if (halign == "left") {
	            balloonwrapper += '<div id="' + object_id + '_xyTop" class="edge_lgt">';
	        }

	        balloonwrapper += '</div>';
	        balloonwrapper += '</div>';

	        try {
	            return balloonwrapper
	        } finally {
	            balloonwrapper = null;
	        }
	    },
	    openballoon: function (pParentid, pObjectId, pTitle, pContent, pW, pH, pPosX, pPosY, pAlign, pEvent) {
	        var l_width, l_height // 컨텐츠의 사이즈
	        if ($("#" + pObjectId + "_p")) {
	            $("#" + pObjectId + "_p").hide();
	            $("#" + pObjectId + "_p").detach();
	        }
	        var balloon = this.CreateBalloon(pObjectId, pTitle, pContent, ((pAlign == undefined) ? this.align : pAlign));
	        $("body").append(balloon);

	        // 레이어의 사이즈 조절 width
	        if (pW == null || pW == "") {// 레이어의 사이즈가 정해지 않은 경우
	            l_width = $("#" + pObjectId + "_pc").width();
	            if (l_width < this.minWidth) {
	                l_width = this.minWidth;
	            }
	        } else {  // 레이어의 w 사이즈가 정해진 경우
	            l_width = pW;
	        }
	        $("#" + pObjectId + "_p").css({ "width": l_width });

	        // 레이어의 사이즈 조절 height
	        if (pH == null || pH == "") { // 레이어의 사이즈가 정해지 않은 경우
	            l_height = $("#" + pObjectId + "_pc").height();
	            if (l_height < this.minHeight) {
	                l_height = this.minHeight;
	            }
	        } else { // 레이어의 h 사이즈가 정해진 경우
	            l_height = pH;
	        }
	        $("#" + pObjectId + "_p").css({ "height": l_height })

	        // ActiveX에 대한 레이어 숨김 현상을 막기 위해
	        $("#" + pObjectId + "_hideDiv").css({ "width": l_width, "height": l_height })
	        if (_ie) {
	            if (_ieVer < 9) {
	                $("#" + pObjectId + "_hideIfram").attr({ "width": $("#" + pObjectId + "_p").width() + 12, "height": parseInt($("#" + pObjectId + "_p").height(), 10) + 11 })
	            } else {
	                $("#" + pObjectId + "_hideIfram").attr({ "width": $("#" + pObjectId + "_p").width() + 12, "height": parseInt($("#" + pObjectId + "_p").height(), 10) + 12 })
	            }
	        } else {
	            $("#" + pObjectId + "_hideIfram").attr({ "width": $("#" + pObjectId + "_p").width() + 12, "height": parseInt($("#" + pObjectId + "_p").height(), 10) + 12 })
	        }

	        // 레이어를 보여줄 위치를 지정하지 않은 경우
	        if (pPosX == null || pPosY == undefined) {
	            var e = (typeof pEvent !== "undefined") ? pEvent : event; // Firefox 경우 객체가 틀림
	            var popup_x = 0;
	            var popup_y = 0;
	            if (_ie || _firefox || _opera) { // IE, Firefox, Opera
	                popup_x = e.clientX;
	                popup_y = e.clientY;
	            } else { // 그외의 브라우져
	                popup_x = event.x;
	                popup_y = event.y;
	            }

	            if (typeof (window.pageYOffset) == "number") {
	                // 스크롤의 상태 적용
	                popup_y = parseInt(popup_y + window.pageYOffset, 10)
	                popup_x = parseInt(popup_x + window.pageXOffset, 10)
	            } else if (typeof (document.documentElement.scrollTop) == "number") {
	                // 스크롤의 상태 적용
	                popup_y = parseInt(popup_y + document.documentElement.scrollTop, 10)
	                popup_x = parseInt(popup_x + document.documentElement.scrollLeft, 10)
	            }

	            if (pAlign == "center") {
	                popup_x = popup_x - (parseInt($("#" + pObjectId + "_p").width() / 2, 10) + 6)
	            } else if (pAlign == "left") {
	                popup_x = popup_x - 14
	            } else if (pAlign == "right") {
	                popup_x = popup_x - (parseInt($("#" + pObjectId + "_p").width(), 10) - 2)
	            }

	            // 컨텐츠가 레이어 영역을 벗어 났을때 처리(레이어인 경우만)
	            if (document.getElementById("divFixWrap") == null && $("body").height() > 200) {
	                if ((popup_y + $("#" + pObjectId + "_p").height()) > ($("body").height())) {
	                    popup_y = (popup_y - ((popup_y + $("#" + pObjectId + "_p").height()) - $("body").height())) - 5;
	                    $("#" + pObjectId + "_xyTop").hide();
	                }
	                if ((popup_x + $("#" + pObjectId + "_p").width()) > $("body").width()) {
	                    popup_x = (popup_x - ((popup_x + $("#" + pObjectId + "_p").width()) - $("body").width())) - 5;
	                    $("#" + pObjectId + "_xyTop").hide();
	                }
	            }
	            $("#" + pObjectId + "_p").css({ left: popup_x, top: popup_y });
	        } else {
	            $("#" + pObjectId + "_p").css({ left: pPosX, top: pPosY });
	        }

	        $("#" + pObjectId + "_p").show("slow");

	        // 내용 크릭시 레이어가 사라지지 않도록 처리
	        $("#" + pObjectId + "_p").mouseover(function () {
	            $("#" + pObjectId + "_p").attr("layerout", "N")
	        });
	        $("#" + pObjectId + "_p").mouseout(function () {
	            $("#" + pObjectId + "_p").attr("layerout", "Y")
	        });

	        // 기존 이벤트가 있다면 저장
	        if (document.onmouseup) {
	            document.oldMouseEvent = document.onmouseup
	        }
	        // 컨트롤 말풍선 외의 공간을 클릭시 레이어 사라짐.
	        document.onmouseup = function () {
	            if ($("#" + pObjectId + "_p").attr("layerout") != "N") {
	                $("#" + pObjectId + "_p").hide();
	                $("#" + pObjectId + "_p").detach();
	                // 기존 이벤트가 있다면 복구
	                if (document.oldMouseEvent) {
	                    document.onmouseup = document.oldMouseEvent;
	                }
	            }
	        }
	    },
	    closeBalloon: function (pObjectId) {
	        $("#" + pObjectId + "_p").hide();
	        $("#" + pObjectId + "_p").detach();
	        // 기존 이벤트가 있다면 복구
	        if (document.oldMouseEvent) {
	            document.onmouseup = document.oldMouseEvent;
	        }
	    },
		toolTip: function(targetObj, codeArr, opt){
			var toolTip = $("<div>",{ "class" : "helppopup", "style":opt});
			var dicArray=[];
			if ( !$.isArray(codeArr)){
				var codeTmp =codeArr ;
				codeArr = [codeTmp];
				
			}
			for(var i=0; i<codeArr.length; i++){
				dicArray.push(codeArr[i]+"_tit");
				dicArray.push(codeArr[i]+"_ex");
				dicArray.push(codeArr[i]+"_cont");
			}

			Common.getDicList(dicArray);
			for(var i=0; i<codeArr.length; i++){
				var code = codeArr[i];
				if (Common.getDic(code+"_ex","","",true) == null || Common.getDic(code+"_ex","","",true) == ""){
					toolTip.text(Common.getDic(code+"_tit","","", true));
				}
				else{
					toolTip.append($("<div>",{ "class" : "help_p"})
							.append($("<p>",{ "class" : "helppopup_tit", "text" : Common.getDic(code+"_tit","","", true) }))
							.append((Common.getDic(code+"_ex","","",true) != "")?$("<span>",{ "class" : "tx_ex", "text" : Common.getDic(code+"_ex","","",true) }):"")
							.append((Common.getDic(code+"_cont","","",true) != "")?Common.getDic(code+"_cont","","",true):""))
				}
			}
			if (toolTip.text() == "") { 
				targetObj.remove();
				return;
			}
			
	        targetObj.parent().append(toolTip);

			targetObj.mouseover(function() {
				$(this).toggleClass("active");
			});
			
			targetObj.mouseout(function() {
				$(this).toggleClass("active");
			});
		}
	};

Common.Close = function (pLayerId) {
    // Popup Window 오픈인 경우
    if (opener != null && CFN_GetQueryString("CFN_OpenWindowName") != "undefined" && (pLayerId == undefined || pLayerId == "")) {
        window.close();
    } else {
        if (pLayerId == undefined || pLayerId == "") {
            pLayerId = CFN_GetQueryString("CFN_OpenLayerName");
            if(pLayerId == "undefined"){//부모창이 먼저 닫힌경우 종료되지 않아, 레이어이름으로 한번더 체크
            	window.close();    	
            }else{
            	parent.Common.close(pLayerId);
            }
        } else {
            Common.close(pLayerId);
        }
    }
};

// 화면 사이즈 확대/축소(컨텐츠 레이어 내에서 사이즈 조정)
Common.ScreenZoom = function (pWidth, pHeight, pLayerId) {
    if (pLayerId == undefined || pLayerId == "") { pLayerId = CFN_GetQueryString("CFN_OpenLayerName"); }
    var l_pcWidth = parent.$("#" + pLayerId + "_pc").width() + pWidth;
    var l_pcHeight = parent.$("#" + pLayerId + "_pc").height() + pHeight;
    if ($(window).width() < l_pcWidth) {
        l_pcWidth = $(window).width();
    }
    _ShowLayerSize[pLayerId] = l_pcWidth + "|" + l_pcHeight;
    parent.Common.toResize(pLayerId, l_pcWidth + "px", l_pcHeight + "px");
    parent.Common.toCenter(pLayerId)
};

// 레이어 사이즈 확대
Common.ScreenFull = function (pLayerId, obj) {
    var l_pcWidth = $(window).width();
    var l_pcHeight = $("#" + pLayerId + "_pc").height();

    // 최초 사이즈 기억
    if (_ShowLayerSize[pLayerId] == undefined) {
        _ShowLayerSize[pLayerId] = $("#" + pLayerId + "_pc").width() + "|" + $("#" + pLayerId + "_pc").height();
    }

    if (obj.hasClass("divpop_full")) {
        if ($("a.divpop_origin2")) { $("a.divpop_origin2").attr('class', 'divpop_mini'); }
        obj.attr('class', 'divpop_origin');
        l_pcHeight = $(window).height() - ($(".divpop_header").height() + 6);
    } else if (obj.hasClass("divpop_origin")) {
        obj.attr('class', 'divpop_full');
        l_pcWidth = _ShowLayerSize[pLayerId].split("|")[0];
        l_pcHeight = _ShowLayerSize[pLayerId].split("|")[1];
    }

    Common.toResize(pLayerId, (l_pcWidth - 10) + "px", l_pcHeight + "px");
    Common.toCenter(pLayerId);
};

// 레이어 사이즈 최소화
Common.ScreenMini = function (pLayerId, obj) {
    var l_pcWidth = 250;
    var l_pcHeight = 0;

    // 최초 사이즈 기억
    if (_ShowLayerSize[pLayerId] == undefined) {
        _ShowLayerSize[pLayerId] = $("#" + pLayerId + "_pc").width() + "|" + $("#" + pLayerId + "_pc").height();
    }

    if (obj.hasClass("divpop_mini")) {
        //최대화 했다가 최소화 할 경우, 이미 divpop_origin이 사용되고 있기 때문에 바꿔줘야 한다.
        //만약 이미 divpop_origin 이 있다면 바꿔주고, 그 다음에 obj를 divpop_origin 으로 바꿔준다.
        if ($("a.divpop_origin")) { $("a.divpop_origin").attr('class', 'divpop_full'); }
        obj.attr('class', 'divpop_origin2');
        Common.toResize(pLayerId, l_pcWidth + "px", l_pcHeight + "px");
        $("#" + pLayerId + "_p").find(".pro_today_x").hide();
        // 원래 위치로 복원
        if (_ShowLayerPosition[pLayerId] != undefined) {
            $("#" + pLayerId + "_p").css({ left: _ShowLayerPosition[pLayerId].split("|")[0], top: _ShowLayerPosition[pLayerId].split("|")[1] });
            // 바닥으로 내리기
        } else {
            // 띄우려고 하는 위치에 레이어가 존재한다면
            var l_Left_y = $("#" + pLayerId).css("top");
            var l_Left_x = $("#" + pLayerId).css("left");
            $("#" + pLayerId + "_p").css({ left: l_Left_x, top: l_Left_y });
        }
    } else if (obj.hasClass("divpop_origin2")) {
        obj.attr('class', 'divpop_mini');
        l_pcWidth = _ShowLayerSize[pLayerId].split("|")[0];
        l_pcHeight = _ShowLayerSize[pLayerId].split("|")[1];
        _ShowLayerPosition[pLayerId] = $("#" + pLayerId + "_p").css("left") + "|" + $("#" + pLayerId + "_p").css("top");
        Common.toResize(pLayerId, l_pcWidth + "px", l_pcHeight + "px");
        Common.toCenter(pLayerId);
        $("#" + pLayerId + "_p").find(".pro_today_x").show();
    }
};

// 레이어 타이틀 변경
Common.ChangeTitle = function (pTitle, pLayerId) {
    if (pTitle.split("|||").length > 1) { // 프로퍼티가 있다면
        $("#" + pLayerId + "_ph .divpop_header").html('<span class="divpop_header_ico">' + pTitle.split("|||")[0] + '</span>');
        $("#" + pLayerId + "_ph .divpop_header").append("<span class='menubar_gray5'>&nbsp;I&nbsp;</span> <span class='txt_gn11'>" + pTitle.split("|||")[1] + "</span>");
    } else {
        $("#" + pLayerId + "_ph .divpop_header").html('<span class="divpop_header_ico">' + pTitle + '</span>');
    }
};

// 레이어 윈도우 팝업으로 재오픈
Common.LayerToWindow = function (pUrl, pParentID, pWidth, pHeight, pOpenType) {
    // 기본은 Fix
    if (pOpenType == undefined) { pOpenType = "fix"; }
    parent.CFN_OpenWindow(pUrl + "&CFN_OpenWindowName=" + pParentID + "&CFN_OpenedWindow=true", pParentID, pWidth + "px", pHeight + "px", pOpenType);
    parent.Common.Close(pParentID);
};

// 윈도우 팝업으로 재오픈 버튼 표시
Common.ButtonToWindow = function (pLayerId) {
    // Popup Window 오픈인 경우
    if (opener == null || CFN_GetQueryString("CFN_OpenWindowName") == "undefined") {
        if (pLayerId == undefined || pLayerId == "") {
            pLayerId = CFN_GetQueryString("CFN_OpenLayerName");
            $("#" + pLayerId + "_LayertoWindow", parent.document).show();
        } else {
            $("#" + pLayerId + "_LayertoWindow").show();
        }
    }
};

// POST 방식 파일다운로드(서버에서 Content-Disposition 처리) 함수 (self submit)
Common.downloadFilePost = function (pUrl, pParamJson) {
    if(!document.frmCmmDownload) {
		$(document.body).append("<form id='frmCmmDownload' name='frmCmmDownload'/>");
	}
	var f = document.frmCmmDownload;
	f.target = "_self";
	f.action = pUrl;
	f.method = "post";
	
	$f = $(f);
	$f.children().remove();
	for(var key in pParamJson){
		$("<input/>").attr({"type":"hidden", "name":key, "value": pParamJson[key]}).appendTo($f);
	}
	f.submit();
};

//////////////////////////////////////////window open  Strat ////////////////////////////////
var g_WinGlobalScope = false;
var g_Win;
var g_ChildWin = {};
//일반window.open
function CFN_OpenWindow(fileName, windowName, theWidth, theHeight, etcParam, doublechk) {
	var popupObj;
    var x = theWidth;
    var y = theHeight;
    var sy = window.screen.height / 2 - parseInt(y) / 2 - 70;
    var sx = (window.screen.width / 2 - parseInt(x) / 2) + window.screenLeft;

    if (etcParam == 'fix') {
        etcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=0";
        sy = window.screen.height / 2 - parseInt(y) / 2 - 40;
    } else if (etcParam == 'resize') {
        etcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=1";
        sy = window.screen.height / 2 - parseInt(y) / 2 - 40;
    } else if (etcParam == 'scroll') {
        etcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=1,resizable=0";
    } else if (etcParam == 'both') {    //전자결재 문서 오픈시 스크롤:O, 리사이즈:X
        etcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=1,resizable=1";
    } else if (etcParam == 'all') {    //전자결재 문서 오픈시 스크롤:O, 리사이즈:X
        etcParam = "toolbar=1,location=1,directories=1,status=1,menubar=1,scrollbars=1,resizable=1";
    }

    if (sy < 0) { sy = 0; }

    var sz = ",top=" + sy + "px,left=" + sx + "px";

    // 파라메터 암호화 관련 처리
    if (fileName.indexOf("EncryptURL=") > -1) {
        if (fileName.indexOf("EncryptURL=M") > -1) {
            var l_param = fileName.split("?")[1];
            fileName = Common.GetEncryptURL(fileName) + "&" + l_param.replace("&EncryptURL=M", "");
        } else {
            fileName = Common.GetEncryptURL(fileName);
        }
    }
    //결재의견창 가운데 띄우기 작업
    if (fileName.indexOf("CommentWrite.do") > -1) {
    	var winWidth = document.body.clientWidth;//현재창의 너비
    	var winHeight = document.body.clientHeight;//현재창의 높이
    	var winX = window.screenX||window.screenLeft||0;//현재창의 x좌표
    	var winY = window.screenY||window.screenTop||0;//현재창의y좌표
    	var left = winX+(winWidth - x)/2;
    	var top = winY+(winHeight - y)/2;
    	sz= ",top=" + top + "px,left=" + left + "px";
    }   
    
    //500 interval의 더블클릭 방지
    if (g_WinGlobalScope){
    	return false;
	}
    
    var fileKey;
    g_WinGlobalScope = true; 
    setTimeout(function () { g_WinGlobalScope = false; }, 500);
    
    //한글
    const korean = /[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/;

    if (windowName != null && windowName != ""  && korean.test(windowName)){
    	windowName = "";
    }
    if (windowName == null || windowName == "" || windowName == "newMessageWindow") {
        windowName = new String(Math.round(coviCmn.random() * 100000));
    }

    if (windowName == null || windowName == "" || windowName == "newMessageWindow") {
		windowName = new String(Math.round(coviCmn.random() * 100000));
	}

	if (fileName.indexOf("?") > -1) {
		fileKey = "&CFN_OpenWindowName=" + windowName;
	}
	else {
		fileKey = "?CFN_OpenWindowName=" + windowName;
	}
    
	if(doublechk == "false"){
	    //IE8 windowName 버그
	    try{
	    	popupObj = window.open(fileName+fileKey, windowName, etcParam + ",width=" + x + ",height=" + y + sz);
			popupObj.onunload = function(e){
				if (e.target.URL != "about:blank"){
					XFN_removeWindow(windowName);
				}
			}
			popupObj.onload = function(){
				XFN_addWindowOpenList(fileName+fileKey, windowName);
			}
	    } catch(e){
	    	popupObj = window.open(fileName+fileKey, null, etcParam + ",width=" + x + ",height=" + y + sz);
	    }
	    popupObj.focus();
	} else {
		//ie 팝업 열지 않음 선택 시 오류처리
		if(g_ChildWin.hasOwnProperty(fileName)&&g_ChildWin[fileName] == null){
			alert(Common.getDic("msg_allowPopBlocker")); //팝업 차단을 허용해 주세요.
			return false;
		}
		
		if(typeof(g_ChildWin[fileName]) == 'undefined' 
		||!g_ChildWin.hasOwnProperty(fileName)
		|| g_ChildWin[fileName].closed 
		|| (g_ChildWin[fileName].location && String(g_ChildWin[fileName].location.pathname + g_ChildWin[fileName]._QueryString ).split("CFN_OpenWindowName")[0] != String(fileName+fileKey).split("CFN_OpenWindowName")[0])){
			//IE8 windowName 버그
			try{
				g_ChildWin[fileName] = window.open(fileName+fileKey, windowName, etcParam + ",width=" + x + ",height=" + y + sz);	
				popupObj = g_ChildWin[fileName];
				popupObj.onunload = function(e){
					if (e.target.URL != "about:blank"){
						XFN_removeWindow(windowName);
					}
				}
				popupObj.onload = function(){
					XFN_addWindowOpenList(fileName+fileKey, windowName);
				}
				
			} catch(e){
				g_ChildWin[fileName] = window.open(fileName+fileKey, null, etcParam + ",width=" + x + ",height=" + y + sz);
				popupObj = g_ChildWin[fileName];
			}
			if(popupObj == null) {
				delete g_ChildWin[fileName];
				alert(Common.getDic("msg_allowPopBlocker")); //팝업 차단을 허용해 주세요.
				return false;
			}
			popupObj.focus();
		} else {
			g_ChildWin[fileName].focus();
		}
	}

    return popupObj;
}
/*
window.onbeforeunload = function (e) {
    var e = e || window.event;

    //close child popup
	for (var fileName in g_ChildWin) {
		if(typeof(g_ChildWin[fileName]) != 'undefined') {
			g_ChildWin[fileName].close();
		}
    }
    
    // For IE and Firefox
    if (e) {
        //e.returnValue = 'Leaving the page';
    }

    // For Safari
    //return 'Leaving the page';
};
*/

/*******************************************************
CFN_OpenWindowPost 함수 : Post방식 팝업 열기
인수 1 fileName : 주소
2 theWidth : 창 넓이
3 theHeight : 창 높이
4 windowName :윈도우이름
5 etcParam : Pararam
반환 1 objNewWin : 생성된 window오브젝트
********************************************************/

function CFN_OpenWindowPost(fileName, theWidth, theHeight, windowName, etcParam) {
    var objNewWin; var x = theWidth;
    var y = theHeight;
    var sy = window.screen.height / 2 - y / 2 - 70;

    if (etcParam == 'fix') {
        etcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=0";
        sy = window.screen.height / 2 - parseInt(y) / 2 - 40;
    } else if (etcParam == 'resize') {
        etcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=1";
        sy = window.screen.height / 2 - parseInt(y) / 2 - 40;
    } else if (etcParam == 'scroll') {
        etcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=1,resizable=0";
    } else if (etcParam == 'both') {    //전자결재 문서 오픈시 스크롤:O, 리사이즈:X (중앙미디어)
        etcParam = "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=1,resizable=1";
    } else if (etcParam == 'all') {    //전자결재 문서 오픈시 스크롤:O, 리사이즈:X (중앙미디어)
        etcParam = "toolbar=1,location=1,directories=1,status=1,menubar=1,scrollbars=1,resizable=1";
    }

    var sx = window.screen.width / 2 - x / 2;
    if (sy < 0) { sy = 10; }
    var sz = ",top=" + sy + ",left=" + sx;
    if (!windowName || windowName == "newMessageWindow" || windowName == "") {
        windowName = new String(Math.round(coviCmn.random() * 100000));
    }

    windowName = windowName.replace('-', '');

    var sPageName;

    var $form = $("<form>");

    // 파라메터 암호화 관련 처리
    if (fileName.indexOf("EncryptURL=") > -1) {
        if (fileName.indexOf("EncryptURL=M") > -1) {
            var l_param = fileName.split("?")[1];
            fileName = Common.GetEncryptURL(fileName) + "&" + l_param.replace("&EncryptURL=M", "");
        } else {
            fileName = Common.GetEncryptURL(fileName);
        }
    }

    if (fileName.indexOf('?') > -1) {
        var aParams = new Array();
        var aValues = new Array();
        var aParameter = new Array();

        sPageName = fileName.split('?')[0];
        var sParams = fileName.split('?')[1];

        if (sParams != "") {
            aParameter = sParams.split('&');

            //url파라미터를 파라미터와 값으로 분류
            for (var i = 0; i < aParameter.length; i++) {
                aParams.push(aParameter[i].substring(0, aParameter[i].indexOf('=')));
                aValues.push(aParameter[i].substring(aParameter[i].indexOf('=') + 1, aParameter[i].length));
            }
        }

        //url파라미터를 form안에 hidden태그로 생성
        for (var i = 0; i < aParameter.length; i++) {
            $form.append($("<input>").attr({ "type": "hidden", "name": aParams[i], "value": aValues[i] }));
        }
    } else {
        sPageName = fileName;
    }
    objNewWin = window.open("about:blank", windowName, etcParam + ",width=" + x + ",height=" + y + sz);
    if (objNewWin != null) objNewWin.focus();
    $form.attr({ "method": "post", "target": windowName, "action": sPageName });
    $form.appendTo($(document.body));
    $form.submit();

    return objNewWin;
}
////////////////////////////////////////// window open  End ////////////////////////////////




//Get 방식으로 호출되는 페이지에서 QueryString을 파싱하여 파라메터를 가져오는 함수
function CFN_GetQueryString(pParamName, pPath) {
	var _QureyObject = {};
	if (_QureyObject[pParamName] == "undefined" || _QureyObject[pParamName] == null) {
		
		var queryString = location.search.replace('?', '').split('&');
		if (pPath != undefined) queryString = pPath.replace('?', '').split('&');
		for (var i = 0; i < queryString.length; i++) {
			var name = queryString[i].split('=')[0];
			var value = queryString[i].split('=')[1];
			_QureyObject[name] = value;
		}
		if (_QureyObject[pParamName] == "undefined" || _QureyObject[pParamName] == null) {
			return "undefined";
		} else {
			try {
				return _QureyObject[pParamName];
			} finally {
				_QureyObject = null;
			}
		}
	} else {
		try {
			return _QureyObject[pParamName];
		} finally {
			_QureyObject = null;
		}
	}
}

//////////////////////////////////////////JavaScript StringBuilder ////////////////////////////////
//스트링 빌더 객체 생성
var StringBuilder = function () {
	this.buffer = new Array();
}

//순서대로 문자열을 추가한다.
StringBuilder.prototype.Append = function (strValue) {
	this.buffer[this.buffer.length] = strValue;
	// this.buffer.push( strValue ); //IE5.5 NS4
}
//문자열의 형식을 지정해서 추가한다.
StringBuilder.prototype.AppendFormat = function () {
	var count = arguments.length;
	if (count < 2) return "";
	var strValue = arguments[0];
	for (var i = 1; i < count; i++) {
		strValue = strValue.replace("{" + (i - 1) + "}", arguments[i]);
		if (strValue.indexOf("{" + (i - 1) + "}") > -1) {
			i = i - 1;
		}
	}
	this.buffer[this.buffer.length] = strValue;
}
//해당하는 위치에 문자열을 추가한다. (문자위치가 아님);
StringBuilder.prototype.Insert = function (idx, strValue) {
	this.buffer.splice(idx, 0, strValue);     //IE5.5 NS4
}
//해당문자열을 새로운 문자열로 바꾼다.
//(배열방 단위로 바꾸므로 배열방 사이에 낀 문자열은 바꾸지 않음)
StringBuilder.prototype.Replace = function (from, to) {
	for (var i = this.buffer.length - 1; i >= 0; i--)
		this.buffer[i] = this.buffer[i].replace(new RegExp(from, "g"), to); //IE4  NS3
}
//문자열로 반환한다.
StringBuilder.prototype.ToString = function () {
	return this.buffer.join("");    //IE4 NS3
}
//문자열을 초기화함.
StringBuilder.prototype.Clear = function () {
	this.buffer = new Array();
}


///---------------------------------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////////////////////////////// alert & confirm

//Usage:
//		Common.Alert( message, [title, callback] )
//		Common.Confirm( message, [title, callback] )
//		Common.Prompt( message, [value, title, callback] )
//
jQuery(function ($) {

 $.alerts = {
     // These properties can be read/written by accessing $.alerts.propertyName from your scripts at any time
     verticalOffset: -75,                // vertical offset of the dialog from center screen, in pixels
     horizontalOffset: 0,                // horizontal offset of the dialog from center screen, in pixels/
     repositionOnResize: true,           // re-centers the dialog on window resize
     overlayOpacity: 0.00,                // transparency level of overlay
     overlayColor: '#000',               // base color of overlay
     draggable: true,                    // make the dialogs draggable (requires UI Draggables plugin)
     dialogClass: null,                  // if specified, this class will be applied to all dialogs
     minWidth: 230,
     maxWidth: 450,

     // Public methods
     inform: function (message, title, callback) {
         if (title == null || title == "") title = 'Information';
         $.alerts._show(title, message, null, 'inform', function (result) {
             if (callback) callback(result);
         });
     },

     progress: function (message, title, callback) {
         if (title == null || title == "") title = 'Progress';
         if (message == null || message == "") { message = Common.getDic("msg_Processing") }
         $.alerts._show(title, message, null, 'progress', function (result) {
             if (callback) callback(result);
         });
     },

     warning: function (message, title, callback) {
         if (title == null || title == "") title = 'Warning';
         $.alerts._show(title, message, null, 'warning', function (result) {
             if (callback) callback(result);
         });
     },

     error: function (message, title, callback) {
         if (title == null || title == "") title = 'Error';
         
         $.alerts._show(title, message, null, 'error', function (result) {
             if (callback) callback(result);
         });
     },

     confirm: function (message, title, callback) {
         if (title == null || title == "") title = 'Confirm';
         $.alerts._show(title, message, null, 'confirm', function (result) {
             if (callback) callback(result);
         });
     },

     prompt: function (message, value, title, callback) {
         if (title == null || title == "") title = 'Prompt';
         $.alerts._show(title, message, value, 'prompt', function (result) {
             if (result != null) {
                 result = result.replace(/'/gi, "＇").replace(/"/gi, "〃");
             }
             if (callback) callback(result);
         });
     },

     promptArea: function (message, value, title, callback) {
         if (title == null || title == "") title = 'Prompt';
         $.alerts._show(title, message, value, 'promptArea', function (result) {
             if (result != null) {
                 result = result.replace(/'/gi, "＇").replace(/"/gi, "〃").replace(/\r/gi, "").replace(/\n/gi, "");
             }
             if (callback) callback(result);
         });
     },

     password: function (message, value, title, callback) {
         if (title == null || title == "") title = 'Check Password';
         $.alerts._show(title, message, value, 'password', function (result) {
             if (callback) callback(result);
         });
     },

     DetailErrPwMsg: function (message, value, title, callback) {
         if (title == null || title == "") title = 'Password Change';
         $.alerts._show(title, message, value, 'passwordchange', function (result) {
             if (callback) callback(result);
         });
     },	
     
     // Private methods
     _show: function (title, msg, value, type, callback) {
         //$.alerts._hide();
         $("#AlertLayer").detach();
         $.alerts._overlay('hide');
         $.alerts._maintainPosition(false);
         $.alerts._overlay('show');

         if (_ieVer < 9) {
             $("BODY").append(
			        '<div id="AlertLayer" class="layer_alert" style="z-index:302">' +
                 '<div id="alert_container" class="alert_content">' +
                     '<div id="' + type + '_hideDiv" style="position:absolute;top:0px;left:0px;filter: progid:DXImageTransform.Microsoft.Alpha(opacity=0);"><iframe style="margin-left:-3px; margin-top:-3px;" frameborder="0" id="' + type + '_hideIfram"></iframe></div>' +
				        '<div id="popup_content" style="position:relative;"><h4 id="popup_title" class="alert_header"></h4>' +
				        '<div class="alert_body">' +
				            '<div id="popup_message" style="text-align:center;overflow-y:auto;"></div>' +
				        '</div>' +
                     '<a id="btn_AlertCloseX" onclick="$.alerts._hide()" style="cursor:pointer;" class="ly_close"></a>' +
                 '</div></div>' +
			        '</div>');
         } else {
             $("BODY").append(
			        '<div id="AlertLayer" class="layer_alert" style="z-index:302">' +
                 '<div id="alert_container" class="alert_content">' +
                     '<div id="' + type + '_hideDiv" style="position:absolute;top:-3px;left:-3px;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);"><iframe frameborder="0" id="' + type + '_hideIfram"></iframe></div>' +
				        '<div id="popup_content" style="position:relative;"><h4 id="popup_title" class="alert_header"></h4>' +
				        '<div class="alert_body">' +
				            '<div id="popup_message" style="txt-align:center;overflow-y:auto;"></div>' +
				        '</div>' +
                     '<a id="btn_AlertCloseX" onclick="$.alerts._hide()" style="cursor:pointer;" class="ly_close"></a>' +
                 '</div></div>' +
			        '</div>');
         }

         // 컨테이너의 스타일을 줌
         //if ($.alerts.dialogClass) $("#alert_container").addClass($.alerts.dialogClass);
         // IE6 Fix
         var pos = (_ie && _ieVer <= 6) ? 'absolute' : 'fixed';
         if (!_mobile) {// 특정 모바일기기에서 활성화시 레이어를 선택할 수 없는 오류 발생시킴!!
             $("#alert_container").css({ position: pos });
         }

         if (type != "progress" && type != "passwordchange") {
             if (_mobile) {
                 $("#popup_title").html('<span class="alert_header_ico">' + title + '</span>');
                 $("#popup_message").text(msg);
                 $("#popup_message").html('<div class="approval_ok_box" style="display:inline-table; "><div class="approval_ok"><div class="' + type + '"></div>' + $("#popup_message").text().replace(/\\n|\n/ig, '<br />') + "<div></div>");
             } else {
                 $("#popup_title").html('<span class="alert_header_ico">' + title + '</span>');
                 $("#popup_message").text(msg);
                 $("#popup_message").html('<p><div class="join_' + type + '"></div> ' + $("#popup_message").text().replace(/\\n|\n/ig, '<br />') + "</p>");
             }
         }else if(type == "passwordchange"){
        	 
        	 $("#popup_title").html('<span class="alert_header_ico">' + title + '</span>');
        	 
        	 var detailMsg = "";
        	 
        	 if(msg != undefined && msg != ""){
        		 
        		 var _detailMsg = msg.split("|");
        		 
        		 if(_detailMsg.length != 0){
     				for(var i=0; i < _detailMsg.length; i++){
     					
     					detailMsg += _detailMsg[i];
     				}
     			}else{
     				detailMsg = msg;	
     			}
        		 
        	 }else{
        		 detailMsg = "";
        	 }
        	 
             $("#popup_message").text(detailMsg);
             $("#popup_message").html('<p><div class="join_' + type + '"></div> ' + $("#popup_message").text().replace(/\\n|\n/ig, '<br />') + "</p>");
             $("#popup_message").css("text-align","left");
        	 
         }else { // 상태 표시인 경우
             $("#popup_title").hide();
             if (title == "loading") {
                 $("#popup_message").html('<p><div style="min-width:100px;min-height:15px;"><img src="/covicore/resources/images/covision/' + _lodingImage + '"><br /></div></p>');
             } else if (title == "Indicator") {
                 $("#popup_message").html('<p><div style="min-width:100px;min-height:15px;"><img src="/covicore/resources/images/covision/' + _IndicatorImage + '">&nbsp;&nbsp;<strong>' + msg + '</strong></div></p>');
             }  else {
                 $("#popup_message").html('<p><div style="min-width:200px;min-height:15px;"><img src="/covicore/resources/images/covision/' + _progressImage + '"><br /><br /></div><div style="min-height:20px;min-width:200px;"><div class="join_inform"></div>' + msg + '</div></p>');
             }
         }

         if ($("#alert_container").outerWidth() < $.alerts.minWidth) { // 최소 사이즈를 지정함.
             $("#alert_container").css({
                 width: $.alerts.minWidth + 10
             });
         } else if ($("#alert_container").outerWidth() > $.alerts.maxWidth) { // 최소 사이즈를 지정함.
             $("#alert_container").css({
                 width: $.alerts.maxWidth + 10
             });
         } else {
             $("#alert_container").css({
                 minWidth: $("#alert_container").outerWidth() + 10,
                 maxWidth: $("#alert_container").outerWidth() + 10
             });
         }
         //ActiveX 컨트롤 위로 레이어를 올리기 위해
         if (type != "progress") {
             $("#" + type + "_hideIfram").attr({ "width": $("#alert_container").outerWidth(), "height": parseInt($("#alert_container").outerHeight(), 10) + 36 })
         } else {
             $("#" + type + "_hideIfram").attr({ "width": $("#alert_container").outerWidth(), "height": parseInt($("#alert_container").outerHeight(), 10) + 3 })
         }

         //$("#popup_content").css({ "width": parseInt($("#alert_container").outerWidth() - 6, 10) })

         $.alerts._reposition();
         $.alerts._maintainPosition(true);

         switch (type) {
             case 'confirm':
                 if (_mobile) {
                     $("#popup_message").after('<center><table class="ly_btn"><tbody><tr><td>'
                         + '<button style="border:0;padding:0;background:transparent;outline:none;cursor:pointer" id="popup_ok"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em></button>'
                         + '<button style="border:0;padding:0;background:transparent;outline:none;cursor:pointer" id="popup_cancel"><em class="btn_ws_l"><span class="btn_ws_r"><strong class="txt_btn_ws">' + $.alerts._getBtnDicionary("btn_Cancel") + '</strong></span></em></button>'
                         + '</td></tr></tbody></table></center>');
                 } else {
                     $("#popup_message").after('<center><table class="ly_btn"><tbody><tr><td>'
                         + '<center>'
                         + '<button style="border:0;padding:0;background:transparent;outline:none;cursor:pointer" id="popup_ok"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em></button>'
                         + '<button style="border:0;padding:0;background:transparent;outline:none;cursor:pointer" id="popup_cancel"><em class="btn_ws_l"><span class="btn_ws_r"><strong class="txt_btn_ws">' + $.alerts._getBtnDicionary("btn_Cancel") + '</strong></span></em></button>'
                         + '</center>'
                         + '</td></tr></tbody></table></center>');
                 }
                 $("#popup_ok").click(function () {
                     $.alerts._hide();
                     if (callback) callback(true);
                 });
                 $("#popup_cancel").click(function () {
                     $.alerts._hide();
                     if (callback) callback(false);
                 });
                 $("#popup_ok").focus();
                 $("#popup_ok, #popup_cancel").keypress(function (e) {
                     if (e.keyCode == 27) $("#popup_cancel").trigger('click');
                 });
                 break;
             case 'prompt':
                 //if (_mobile) {
            	 //    $("#popup_message").append('<br /><input type="text" size="30" id="popup_prompt" />').after('<center><table class="ly_btn"><tbody><tr><td>'
            	 //        + '<a style="cursor:pointer" id="popup_ok"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em></a>'
            	 //        + '<a style="cursor:pointer" id="popup_cancel"><em class="btn_ws_l"><span class="btn_ws_r"><strong class="txt_btn_ws">' + $.alerts._getBtnDicionary("btn_Cancel") + '</strong></span></em></a>'
            	 //        + '</td></tr></tbody></table></center>');
            	 //} else {
                     $("#popup_message").append('<br /><input type="text" size="30" id="popup_prompt" />').after('<center><table class="ly_btn"><tbody><tr><td>'
                         + '<a style="cursor:pointer" id="popup_ok"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em></a>'
                         + '<a style="cursor:pointer" id="popup_cancel"><em class="btn_ws_l"><span class="btn_ws_r"><strong class="txt_btn_ws">' + $.alerts._getBtnDicionary("btn_Cancel") + '</strong></span></em></a>'
                         + '</td></tr></tbody></table></center>');
                 //}
                 $("#popup_prompt").width($("#popup_message").width() - 10);
                 $("#popup_ok").click(function () {
                     var val = $("#popup_prompt").val();
                     $.alerts._hide();
                     if (callback) callback(val);
                 });
                 $("#popup_cancel").click(function () {
                     $.alerts._hide();
                     if (callback) callback(null);
                 });
                 $("#popup_prompt, #popup_ok, #popup_cancel").keypress(function (e) {
                     if (e.keyCode == 13) $("#popup_ok").trigger('click');
                     if (e.keyCode == 27) $("#popup_cancel").trigger('click');
                 });
                 if (value) $("#popup_prompt").val(value);
                 $("#popup_prompt").focus().select();
                 break;
             case 'promptArea':
            	 //if (_mobile) {
            	 //    $("#popup_message").append('<br /><textarea name="popup_prompt" rows="4" cols="20" id="popup_prompt" onkeydown="return CFN_CheckMaxLength(this, \'500\')" style="width:250px;vertical-align:middle;text-align:left;overflow:auto;"></textarea>').after('<center><table class="ly_btn"><tbody><tr><td>'
            	 //        + '<a style="cursor:pointer" id="popup_ok"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em></a>'
            	 //        + '<a style="cursor:pointer" id="popup_cancel"><em class="btn_ws_l"><span class="btn_ws_r"><strong class="txt_btn_ws">' + $.alerts._getBtnDicionary("btn_Cancel") + '</strong></span></em></a>'
            	 //        + '</td></tr></tbody></table></center>');
            	 //} else {
                     $("#popup_message").append('<br /><textarea name="popup_prompt" rows="4" cols="20" id="popup_prompt" onkeydown="return CFN_CheckMaxLength(this, \'500\')" style="width:250px;vertical-align:middle;text-align:left;overflow:auto;"></textarea>').after('<center><table class="ly_btn"><tbody><tr><td>'
                         + '<a style="cursor:pointer" id="popup_ok"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em></a>'
                         + '<a style="cursor:pointer" id="popup_cancel"><em class="btn_ws_l"><span class="btn_ws_r"><strong class="txt_btn_ws">' + $.alerts._getBtnDicionary("btn_Cancel") + '</strong></span></em></a>'
                         + '</td></tr></tbody></table></center>');
                 //}
                 $("#popup_prompt").width($("#popup_message").width() - 20);
                 $("#popup_ok").click(function () {
                     var val = $("#popup_prompt").val();
                     $.alerts._hide();
                     if (callback) callback(val);
                 });
                 $("#popup_cancel").click(function () {
                     $.alerts._hide();
                     if (callback) callback(null);
                 });
                 $("#popup_ok, #popup_cancel").keypress(function (e) {
                     if (e.keyCode == 13) $("#popup_ok").trigger('click');
                     if (e.keyCode == 27) $("#popup_cancel").trigger('click');
                 });
                 if (value) $("#popup_prompt").val(value);
                 $("#popup_prompt").focus().select();
                 break;
             case 'password':
                 if (title.indexOf("◈") == -1) {
                	 //if (_mobile) {
                	 //    $("#popup_message").append('<br /><input type="password" size="30" id="popup_prompt" />').after('<center><table class="ly_btn"><tbody><tr><td>'
                	 //        + '<a style="cursor:pointer" id="popup_ok"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em></a>'
                	 //        + '<a style="cursor:pointer;display:none;" id="popup_e1"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Close") + '</strong></span></em></a>'
                	 //        + '<a style="cursor:pointer" id="popup_cancel"><em class="btn_ws_l"><span class="btn_ws_r"><strong class="txt_btn_ws">' + $.alerts._getBtnDicionary("btn_Cancel") + '</strong></span></em></a>'
                	 //        + '</td></tr></tbody></table></center>');
                	 //} else {
                         $("#popup_message").append('<br /><input type="password" size="30" id="popup_prompt" />').after('<center><table class="ly_btn"><tbody><tr><td>'
                             + '<a style="cursor:pointer" id="popup_ok"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em></a>'
                             + '<a style="cursor:pointer;display:none;" id="popup_e1"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Close") + '</strong></span></em></a>'
                             + '<a style="cursor:pointer" id="popup_cancel"><em class="btn_ws_l"><span class="btn_ws_r"><strong class="txt_btn_ws">' + $.alerts._getBtnDicionary("btn_Cancel") + '</strong></span></em></a>'
                             + '</td></tr></tbody></table></center>');
                     //}
                 } else {
                     if (_mobile) {
                         $("#popup_message").append('<br /><input type="password" size="30" id="popup_prompt" />').after('<center><table class="ly_btn"><tbody><tr><td>'
                             + '<a style="cursor:pointer" id="popup_ok"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em></a>'
                             + '<a style="cursor:pointer;display:none;" id="popup_e1"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Close") + '</strong></span></em></a>'
                             + '<a style="cursor:pointer" id="btn_AlertCloseX" onclick="$.alerts._hide()"><span>&nbsp;&nbsp;&nbsp;<em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Close") + '</strong></span></em>&nbsp;&nbsp;&nbsp;</span></a>'
                             + '</td></tr></tbody></table></center>');


                     } else {
                         $("#popup_message").append('<br /><input type="password" size="30" id="popup_prompt" />').after('<center><table class="ly_btn"><tbody><tr><td>'
                             + '<a style="cursor:pointer" id="popup_ok"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em></a>'
                             + '</td></tr></tbody></table></center>');
                     }
                 }
                 $("#popup_prompt").width($("#popup_message").width() - 10);
                 $("#popup_ok").click(function () {
                     var val = $("#popup_prompt").val();
                     $.alerts._hide();
                     if (callback) callback(val);
                 });
                 $("#popup_e1").click(function () {
                     $.alerts._hide();
                     if (callback) callback("e1Value:"+ $("#popup_prompt").val());
                 });
                 $("#popup_cancel").click(function () {
                     $.alerts._hide();
                     if (callback) callback(null);
                 });
                 $("#popup_prompt, #popup_ok, #popup_cancel").keypress(function (e) {
                     if (e.keyCode == 13) $("#popup_ok").trigger('click');
                     if (e.keyCode == 27) $("#popup_cancel").trigger('click');
                 });
                 if (value) $("#popup_prompt").val(value);
                 $("#popup_prompt").focus().select();
                 $("#btn_AlertCloseX").hide();
                 break;
                 
             case 'passwordchange':
                $("#popup_message").after('<center><table class="ly_btn"><tbody><tr><td>'
                         + '<center>'
                         + '<button style="border:0;padding:0;background:transparent;outline:none;cursor:pointer" id="popup_ok"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em></button>'
                         + '</center>'
                         + '</td></tr></tbody></table></center>');
                 $("#popup_ok").click(function () {
                     $.alerts._hide();
                     if (callback) callback(true);
                 });
                 $("#popup_ok").focus().keypress(function (e) {
                     if (e.keyCode == 27) $("#popup_ok").trigger('click');
                 });
                 // 확인창에서는 X을 눌러도 확인이 되도록
                 $("#btn_AlertCloseX").click(function () {
                     $.alerts._hide();
                     if (callback) callback(true);
                 });
                 $("#btn_AlertCloseX").focus().keypress(function (e) {
                     if (e.keyCode == 13 || e.keyCode == 27) $("#popup_ok").trigger('click');
                 });
            	 
            	 break;
             case 'progress':
                 $("#btn_AlertCloseX").hide();
                 break;
             default:
                 if (_mobile) {
                     $("#popup_message").after('<center><table class="ly_btn"><tbody><tr><td>'
                         + '<a style="cursor:pointer" id="popup_ok"><span>&nbsp;&nbsp;&nbsp;<em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em>&nbsp;&nbsp;&nbsp;</span></a>'
                         + '<a style="cursor:pointer" id="btn_AlertCloseX" onclick="$.alerts._hide()"><span>&nbsp;&nbsp;&nbsp;<em class="btn_ws_l"><span class="btn_ws_r"><strong class="txt_btn_ws">' + $.alerts._getBtnDicionary("btn_Close") + '</strong></span></em>&nbsp;&nbsp;&nbsp;</span></a>'
                         + '</td></tr></tbody></table>');
                 } else {
                     $("#popup_message").after('<center><table class="ly_btn"><tbody><tr><td>'
                         + '<center>'
                         + '<button style="border:0;padding:0;background:transparent;outline:none;cursor:pointer" id="popup_ok"><em class="btn_bs_l"><span class="btn_bs_r"><strong class="txt_btn_bs">' + $.alerts._getBtnDicionary("btn_Ok") + '</strong></span></em></button>'
                         + '</center>'
                         + '</td></tr></tbody></table></center>');
                 }
                 $("#popup_ok").click(function () {
                     $.alerts._hide();
                     if (callback) callback(true);
                 });
                 $("#popup_ok").focus().keypress(function (e) {
                     if (e.keyCode == 27) $("#popup_ok").trigger('click');
                 });
                 // 확인창에서는 X을 눌러도 확인이 되도록
                 $("#btn_AlertCloseX").click(function () {
                     $.alerts._hide();
                     if (callback) callback(true);
                 });
                 $("#btn_AlertCloseX").focus().keypress(function (e) {
                     if (e.keyCode == 13 || e.keyCode == 27) $("#popup_ok").trigger('click');
                 });
                 break;
         }

         // Make draggable
         if ($.alerts.draggable) {
             try {
                 if (type != "progress") {
                     $("#AlertLayer").draggable({ handle: $("#popup_title") }).draggable({ iframeFix: true }).draggable({ containment: 'document' });
                     $("#popup_title").css({ cursor: 'move' });
                 } else {
                     $("#AlertLayer").draggable({ handle: $("#popup_message") }).draggable({ iframeFix: true }).draggable({ containment: 'document' });
                     $("#popup_message").css({ cursor: 'move' });
                 }
             } catch (e) {coviCmn.traceLog(e) }
         }
         $(".btn_ws_l").css('background-image','none');
         $(".btn_ws_r").css('background-image','none');
     },
     // 알림창 닫기
     _hide: function () {
         $("#alert_container").slideUp(300, function () {
             $("#AlertLayer").detach();
             $.alerts._overlay('hide');
             $.alerts._maintainPosition(false);
         })
     },
     // 레이어 처리
     _overlay: function (status) {
         switch (status) {
             case 'show':
                 $.alerts._overlay('hide');
                 $("BODY").append('<div id="alert_overlay"></div>');
                 $("#alert_overlay").bind("click", function (e) {
                     if (_ie) { $("#AlertLayer").hide(10).delay(10).show(10).hide(10).delay(10).show(10) }
                     else { $("#AlertLayer").hide(20).show(20).hide(20).delay(20).show(20).hide(20).show(20) }
                 });
                 $("#alert_overlay").css({
                     position: (_ie && _ieVer <= 6) ? 'absolute' : 'fixed',
                     zIndex: 299,
                     top: '0px',
                     left: '0px',
                     width: '100%',
                     height: $("body").height(),
                     background: $.alerts.overlayColor,
                     opacity: $.alerts.overlayOpacity
                 });
                 break;
             case 'hide':
                 $("#alert_overlay").detach();
                 break;
         }
     },

     _reposition: function () {
         var top = (($(window).height() / 2) - ($("#alert_container").outerHeight() / 2)) + $.alerts.verticalOffset;
         var left = (($(window).width() / 2) - ($("#alert_container").outerWidth() / 2)) + $.alerts.horizontalOffset;
         if (top < 0) top = 0;
         if (left < 0) left = 0;

         // IE6 fix
         if (_ie && _ieVer <= 6) top = top + $(window).scrollTop();
         $("#AlertLayer").css({ top: top + 'px', left: left + 'px' });
         $("#alert_overlay").height($(document).height() + $(window).scrollTop());

         if ($(window).height() < $("#alert_container").outerHeight()) {
             $("#alert_container").css("height", $(window).height() - 8);
             $("#popup_message").css("height", $(window).height() - 100);
             $(".alert_body").css("padding-right", 0);
         }
     },

     _maintainPosition: function (status) {
         if ($.alerts.repositionOnResize) {
             switch (status) {
                 case true:
                     $(window).bind('resize', $.alerts._reposition);
                     break;
                 case false:
                     $(window).unbind('resize', $.alerts._reposition);
                     break;
             }
         }
     },

     // 인증 만료시 오류 처리를 위해
     _getBtnDicionary: function (pBtnTitle) {
         var strReturn = "";
         try {
             if (pBtnTitle == "btn_Ok") {
                 strReturn = _btnAlertOK;
             } else {
                 strReturn = _btnAlertCancel;
             }
         } catch (e) {
             if (pBtnTitle == "btn_Ok") {
                 strReturn = "OK";
             } else {
                 strReturn = "Cancel";
             }
         }
         return strReturn;
     }

 }

});

//Shortcut functions
Common.Inform = function (message, title, callback) {
 setTimeout(function () { top.$.alerts.inform(message, title, callback); }, 350);
}

Common.Warning = function (message, title, callback) {
 setTimeout(function () { top.$.alerts.warning(message, title, callback); }, 350);
}


Common.DetailErrPwMsg = function (message, title, callback) {
	 setTimeout(function () { top.$.alerts.DetailErrPwMsg(message, title, callback); }, 350);
}


var g_ErrorMessage = "";
var g_ErrorSeq = 0;
Common.Error = function (message, title, callback) {
 if (g_ErrorMessage.indexOf(message) == -1) {
     if (g_ErrorSeq > 0) {
         g_ErrorMessage += "<strong>"+ g_ErrorSeq +") </strong> " + message + "<br />";
     } else {
         g_ErrorMessage += message + "<br />";
     }
 } else {
     g_ErrorMessage += ".";
 }

 ++g_ErrorSeq;
 setTimeout(function () { top.$.alerts.error(g_ErrorMessage, title, callback); }, 350);
 setTimeout(function () { g_ErrorMessage = ""; g_ErrorSeq = 0; }, 1000);
}

Common.Confirm = function (message, title, callback) {
 setTimeout(function () { top.$.alerts.confirm(message, title, callback); }, 350);
};

Common.Prompt = function (message, value, title, callback) {
 setTimeout(function () {top.$.alerts.prompt(message, value, title, callback); }, 350);
};

Common.PromptArea = function (message, value, title, callback) {
 setTimeout(function () {top.$.alerts.promptArea(message, value, title, callback); }, 350);
};

Common.Password = function (message, value, title, callback) {
 setTimeout(function () {top.$.alerts.password(message, value, title, callback); }, 350);
};

Common.Progress = function (message, callback, setTime) {
 $.alerts.progress(message, "progress", null);
 if (callback != undefined) {  // 콜백 메써드 처리
     if (setTime != undefined) {
         setTimeout(callback, setTime);
     } else {
         setTimeout(callback);
     }
 }
};

Common.Loading = function (message, callback, setTime) {
 $.alerts.progress(message, "loading", null);
 if (callback != undefined) { // 콜백 메써드 처리
     if (setTime != undefined) {
         setTimeout(callback, setTime);
     } else {
    	 setTimeout(callback);
     }
 }
};

var g_IndicatorID = 0;
Common.Indicator = function (message, callback, setTime) {
    /*$.alerts.progress(message, "Indicator", null);
	if (callback != undefined) { // 콜백 메써드 처리
        if (setTime != undefined) {
            setTimeout(callback, setTime);
        } else {
            setTimeout(callback);
        }
    } else {
        if (setTime == undefined) {
            setTimeout("Common.AlertClose()", 1000);
        } else {
            setTimeout("Common.AlertClose()", setTime);
        }   
    }*/
	if (message == null || message == undefined || message == "") { message = Common.getDic("msg_Processing") }

	var l_IndicatorLayerID = "IndicatorLayer" + g_IndicatorID;
    ++g_IndicatorID;
    
    var l_BottomY = 5;
    $(".IndicatorLayer").each(function () {
        var l_y = parseInt($(this).css("bottom"), 10);
        if (l_BottomY <= l_y) {
            l_BottomY = l_y + 55;        }
    });
    
    var l_IndicatorContainerID = "Indicator_container" + g_IndicatorID;
    
    var indicatorHTML = '';
    indicatorHTML += '<div id="'+l_IndicatorLayerID+'" class="layer_alert IndicatorLayer" style="z-index:1001; position:fixed; right:10px; bottom:'+l_BottomY+'px;">';
    indicatorHTML += '	<div id="'+l_IndicatorContainerID+'" class="alert_content">';
    indicatorHTML += '		<div id="Indicator_hideDiv" style="position:absolute; top:'+((_ieVer < 9) ? 0 : -3)+'px; left:'+((_ieVer < 9) ? 0 : -3)+'px; filter: progid:DXImageTransform.Microsoft.Alpha(opacity=0);">';
    indicatorHTML += '			<iframe'+((_ieVer < 9) ? ' style="margin-left:-3px; margin-top:-3px;"' : '')+' frameborder="0" id="Indicator_hideIfram' + g_IndicatorID + '"></iframe>';
    indicatorHTML += '		</div>';
    indicatorHTML += '		<div id="Indicator_content" style="position:relative;">';
    indicatorHTML += '			<div class="alert_body" style="padding: 10px;">';
    indicatorHTML += '				<div id="Indicator_message" style="txt-align:center; overflow-y:auto;">';
    indicatorHTML += '					<p>';
    indicatorHTML += '						<div style="min-width:100px; min-height:15px;">';
    indicatorHTML += '							<img src="/covicore/resources/images/covision/' + _IndicatorImage + '" />';
    indicatorHTML += '							<strong>' + message + '</strong>';
    indicatorHTML += '						</div>';
    indicatorHTML += '					</p>';
    indicatorHTML += '				</div>';
    indicatorHTML += '			</div>';
    indicatorHTML += '		</div>';
    indicatorHTML += '	</div>';
    indicatorHTML += '</div>';
    
	$("body").append(indicatorHTML);
 	
 	var l_IndicatorContainer = document.getElementById(l_IndicatorContainerID);
    $("#Indicator_hideIfram" + g_IndicatorID).attr({ 
		"width": $(l_IndicatorContainer).outerWidth(), 
		"height": parseInt($(l_IndicatorContainer).outerHeight(), 10) + 3 
	})
    
    if (typeof (setTime) == "undefined" || setTime == "" || setTime == null) {
        setTime = 5000;
    }
	
	setTimeout("Common.IndicatorClose('" + l_IndicatorLayerID + "')", setTime);

    if (typeof (callback) != "undefined" && callback != "" && callback != null) {
        if (typeof (callback) == "string") { //CallBackMethod명칭을 String으로 넘길 경우
            setTimeout(function(){
				if(jQuery.isFunction(window[callback])){
					window[callback].apply(this);// no argument
				}
			}, setTime);
        } else if (typeof (callback) == "function") { //CallBackMethod를 Funtion 형태로 넘길 경우
            setTimeout(callback, setTime)
        }
    }
};

Common.IndicatorClose = function (pId) {
    if (typeof (pId) == "undefined" || pId == "") {
        $(".IndicatorLayer").slideUp(300, function () {
            $(this).detach();
        })
    } else {
		var target = document.getElementById(pId);
        $(target).slideUp(300, function () {
            $(target).detach();
        })
    }
}

Common.AlertClose = function () {
 $.alerts._hide();
}
///////////////////////////////////////////////////////////////////////////////////////////////

//////// Polyfill /////////////////////////

//String replaceAll

String.prototype.replaceAll = function(org, dest) {
    return this.split(org).join(dest);
}

/*	String Format
*	ex)	String.format('a {0} c {1} e','b', 'd'); = "a b c d e"
**/
String.format = function() {
    // The string containing the format items (e.g. "{0}")
    // will and always has to be the first argument.
	var theString = arguments[0];
	
	// start with the second argument (i = 1)
	for (var i = 1; i < arguments.length; i++) {
		// "gm" = RegEx options for Global search (more than one instance)
		var regEx = new RegExp("\\{" + (i - 1) + "\\}", "gm");
		theString = theString.replace(regEx, arguments[i]);
    }
	return theString;
};


//jquery selector escape
if (!String.prototype.jqid) {
	String.prototype.jqid = function () {
		return this.replace(/([;&,\.\+\*\~':"\!\^#$%@\[\]\(\)=>\|])/g, '\\\\$1');
	};
}

// ie에서 includes 함수
if (![].includes) {
	  Array.prototype.includes = function(searchElement /*, fromIndex*/ ) {
	    'use strict';
	    var O = Object(this);
	    var len = parseInt(O.length) || 0;
	    if (len === 0) {
	      return false;
	    }
	    var n = parseInt(arguments[1]) || 0;
	    var k;
	    if (n >= 0) {
	      k = n;
	    } else {
	      k = len + n;
	      if (k < 0) {k = 0;}
	    }
	    var currentElement;
	    while (k < len) {
	      currentElement = O[k];
	      if (searchElement === currentElement ||
	         (searchElement !== searchElement && currentElement !== currentElement)) {
	        return true;
	      }
	      k++;
	    }
	    return false;
	  };
	}

/////////End of Polyfill//////////////////////////

/////////////////////다국어 조회//////////////////////////////////////////////////////////////////////
/* 기존 Common.getDic 함수에 로컬 스토리지로부터 다국어 조회하는 코드 추가 - dyjo 2019.04.16 */
Common.getDic = function(pKey, pDicType, pLocale, pOnlyStor) { // pDicType이 있으면 Full 없으면 Short
	var returnData = "";
	var dicMap = {};
	if(pKey.indexOf(';') > -1){
		var dictionary = coviStorage.getDictionary();

		if (dictionary != null) {

			var msg = "";
			$.each(pKey.split(";"), function (idx, pDic) {
				if (pDic != undefined && pDic != "") {
					msg = coviStorage.getMessage(pDic);
					dicMap[pDic] = msg;
				}
			});
			returnData = {};
			returnData[0] = dicMap;
		}
	} else {
		returnData = coviStorage.getMessage(pKey);
	}

	if (pOnlyStor == true) return returnData;
	if (returnData == null || returnData == "" ) {
		var jsonData = {};
		var lang = Common.getSession("lang");
		jsonData["keys"] = pKey;
		jsonData["EXCLUDE_VALD"] = true;
		
		if(pLocale != "" && pLocale != undefined && pLocale != "undefined" && pLocale != "null"){
			jsonData["locale"] = pLocale;
		}else{
			if(typeof lang != "undefined" && lang != ""){
				jsonData["locale"] = lang;
			} else {
				jsonData["locale"] = "ko";
			}
		}

		if (localCache[pKey] == "undefined" || localCache[pKey] == null || localCache[pKey] == "") {
			var url = "/covicore/common/getdicall.do";
			$.ajax({
				url: url,
				data: jsonData,
				type: "post",
				async: false,
				success: function(res) {
					if (res.status == "SUCCESS") {
						returnData = res.list;
						$.extend(localCache, res.dicMap);
						localCache[pKey] = returnData;
					} 
				},
				error: function(response, status, error){
					CFN_ErrorAjax("helper/getdicall.do", response, status, error);
				}
			});
		} else {
			returnData = localCache[pKey];
		}
	}

	return returnData;
};


/*
 * 다국어 일괄 조회용 공통 스크립트
 * pDicArray	다국어코드	: (Array) ["lbl_Registor", "lbl_Approval", "lbl_Rejected"]
 * pDicType		다국어 타입	: (String) Full, Short
 * pLocale		국가코드	: (String) ko, en, ja, zh
 *
 * ex) Common.getDicList(["lbl_Registor", "lbl_Approval", "lbl_Rejected"]);
 *
 */
/* 기존 Common.getDicList 함수에 로컬 스토리지로부터 다국어 조회하는 코드 추가 - dyjo 2019.04.16 */
Common.getDicList = function (pDicArray, pDicType, pLocale) {
    if (pDicArray.length > 0) {
        var dictionary = coviStorage.getDictionary();

        if (dictionary != null) {
            var msg = "";
            $.each(pDicArray, function (idx, pDic) {
                if (pDic != undefined && pDic != "") {
                    msg = coviStorage.getMessage(pDic);
                    //dicMap[pDic] = msg;
                    coviDic.dicMap[pDic] = msg;
                    //IE 에서 Object 에 한글데이터를 담을 경우 Native Memory 를 과하게(+90Mb) 점유하는 버그(?)가 있어 인코딩값으로 셋팅함. 2021.08.09
                    var val = encodeURIComponent(msg);
                    Object.defineProperty(coviDic.dicMap, pDic, {
                    	get : function(){return decodeURIComponent(val);}
                    });
                }
            });
            //$.extend(coviDic.dicMap, dicMap);
        } else {
            var param = {
                dicArray: encodeURIComponent(JSON.stringify(pDicArray))
            };

            $.ajax({
                url: "/covicore/common/getDicList.do",
                data: param,
                type: "post",
                async: false,
                success: function (res) {
                    if (res.status == "SUCCESS") {
                    	//IE 에서 Object 에 한글데이터를 담을 경우 Native Memory 를 과하게(+90Mb) 점유하는 버그(?)가 있어 인코딩값으로 셋팅함. 2021.08.09
                    	$.each(res.dicMap, function (name, value) {
                            var val = encodeURIComponent(value);
                            Object.defineProperty(res.dicMap, name, {
                            	get : function(){return decodeURIComponent(val);}
                            });
                    	});
                    	
                        $.extend(coviDic.dicMap, res.dicMap);
                        res.dicMap = null;
                    }
                },
                error: function (response, status, error) {
                    CFN_ErrorAjax("/covicore/common/getDicList.do", response, status, error);
                }
            });
        }
    }
}

/* 기존 Common.getDicAll 함수에 로컬 스토리지로부터 다국어 조회하는 코드 추가 - dyjo 2019.04.16 */
Common.getDicAll = function (pStr, pDicType, pLocale){
	var returnData = {};
	var jsonData = {};

    if (pDicType != "" && pDicType != undefined && pDicType != "undefined" && pDicType != "null") {
        jsonData["dicType"] = pDicType;
    }

	if(pLocale != "" && pLocale != undefined && pLocale != "undefined" && pLocale != "null"){
		jsonData["locale"] = pLocale;
	}else{
		var lang = Common.getSession("lang");
		if(typeof lang != "undefined" && lang != ""){
			jsonData["locale"] = lang;
		} else {
			jsonData["locale"] = "ko";
		}
	}

	var keyStrs="";

	if($.isArray(pStr)==true){
		$(pStr).each(function(idx, obj){
			keyStrs += obj+";";
		});
	} else {
		keyStrs = pStr;
	}

	var arrKeys = keyStrs.split(";");

	if(arrKeys.length > 1){
		var dictionary = coviStorage.getDictionary();

		if (dictionary != null) {
			var msg = "";
			$.each(arrKeys, function (idx, obj) {
				if (obj != null) {
					msg = coviStorage.getMessage(obj.toString());
					returnData[obj.toString()] = msg;
				}
			});

			return returnData;
		} else {
			//로컬캐쉬 체크
			var pKeys = "";
			$(arrKeys).each(function (i, item) {
				if(item != ""){
					if(localCache[item] != undefined) {
						returnData[item] = localCache[item];
					} else {
						pKeys += item + ";";
					}
				}
			});

			if(pKeys.split(';').length > 1){
				jsonData["keys"] = pKeys;
				jsonData["EXCLUDE_VALD"] = true;
				$.ajax({
					url:"/covicore/common/getdicall.do",			// [2016-10-26] 박경연. approval/user에서 접근할 때 문제가 있음
					data:jsonData,
					type:"post",
					async:false,
					success: function (res) {
						$(pKeys.split(';')).each(function (idx, obj) {
							var dicItem = res.list[0][obj];
							returnData[obj.toString()] = dicItem;
							localCache[obj] = dicItem;
						});
					},
					error:function(response, status, error){
						CFN_ErrorAjax("common/getdicall.do", response, status, error);
					}
				});
			}

			return returnData;
		}
	} else {
		arrKeys[0] = arrKeys[0] == null ? "" : arrKeys[0];
		return Common.getDic(arrKeys[0]);
	}
};

// 특정 언어로 입력된 정보를 보여주기(';'로 구분된 다국어 정보)
function CFN_GetDicInfo(pStringInfo, pLanguageCode) {
    var l_Return = "";
    try{
        if (pStringInfo == undefined) {
            pStringInfo = "undefined";
        }
        if (pLanguageCode == undefined) {
            if (typeof _LanguageCode == "undefined") {
                pLanguageCode = Common.getSession("lang");
            } else {
                pLanguageCode = _LanguageCode;
            }
        }

        var l_ArrInfo = pStringInfo.split(';');
        //배열에 없는 값인지 체크
        if (_LanguageIndex[pLanguageCode] <= l_ArrInfo.length) {
            l_Return = l_ArrInfo[_LanguageIndex[pLanguageCode]];
        }
    	if(l_Return == undefined || l_Return == ""){
    		l_Return = l_ArrInfo[0];
    	}
        return  l_Return;
    }catch(e){
    	coviCmn.traceLog(e)
    }finally{
    	l_Return = null;
    }
    /*
    // 값을 못가져 오던지 들어있는 값이 없다면
    if (l_Return == null || l_Return == "") {
        try { // 혹시 에러 발생시(Web.Config에 설정된 기본언어 값으로 대입)
            //l_Return = l_ArrInfo[parseInt(Common.GetAppConfig("BaseLanguage"), 10)];
            l_Return = l_ArrInfo[parseInt("0", 10)];			// 0 - ko
        } catch (e) {
        }
        // 기본언어에도 값이 없다면 정보를 그대로 반환
        if (l_Return == "") {
            l_Return = pStringInfo;
        }
    }

    try {
        return l_Return;
    } finally {
        l_Return = null;
    }*/
}

/////////////////////////기초설정 조회////////////////////////////////////////////////////////

Common.getBaseConfig = function (pKey, pDN_ID) {

    var returnData = coviStorage.getBaseConfig(pKey, pDN_ID);
    if( returnData == null || returnData == "") {
        var jsonData = {};
        jsonData["key"] = pKey;
        jsonData["EXCLUDE_VALD"] = true;
        if (pDN_ID != undefined && pDN_ID != "undefined" && pDN_ID != "null")
            jsonData["dn_id"] = pDN_ID;

        // var returnData = "";
        if (localCache.exist(pKey + "_" + pDN_ID)) {
            returnData = localCache.get(pKey + "_" + pDN_ID);
        } 

        if (returnData == null || returnData == "" || returnData == undefined){
            $.ajax({
                // url:XFN_getContextPath() + "/helper/getdicall.do",
                url: "/covicore/common/getbaseconfig.do", // [2016-06-09] 박경연. approval에서 접근할 때 문제가 있음
                data: jsonData,
                type: "post",
                async: false,
                success: function (res) {
                    returnData = res.value;
                    localCache.set(pKey + "_" + pDN_ID, returnData, "");
                },
                error: function (response, status, error) {
                    CFN_ErrorAjax("common/getbaseconfig.do", response, status, error);
                }
            });
        }
    }



    return returnData;
};

/*
 * 기초설정 일괄 조회용 공통 스크립트
 * pConfigArray	다국어코드	: (Array) ["ImageServiceURL", "BoardMain", ...]
 *
 * ex) Common.getBaseConfigList(["lbl_Registor", "lbl_Approval", "lbl_Rejected"]);
 *
 */
Common.getBaseConfigList = function (pConfigArray, pDN_ID) {
    if (pConfigArray.length > 0) {

        var baseConfig = coviStorage.getLocalBase("BASE_CONFIG" , 0); 
    	
        if( baseConfig != null ) {
            var baseCf = {};

            $.each(pConfigArray, function(idx, pBaseCf) {
                if( pBaseCf != undefined && pBaseCf != "" ) {
                    baseCf[pBaseCf] = coviStorage.getBaseConfig( pBaseCf , pDN_ID);
                }
            });

            $.extend(coviCmn.configMap, baseCf);

        } else {
            var param = {
                configArray: encodeURIComponent(JSON.stringify(pConfigArray))
            };
            
            if (pDN_ID != undefined && pDN_ID != "undefined" && pDN_ID != "null"){
            	param["dn_id"] = pDN_ID;
            }


            $.ajax({
                url: "/covicore/common/getBaseConfigList.do",
                data: param,
                type: "post",
                async: false,
                success: function (res) {
                    if (res.status == "SUCCESS") {
                        $.extend(coviCmn.configMap, res.configMap);
                    }
                },
                error: function (response, status, error) {
                    CFN_ErrorAjax("/covicore/common/getBaseConfigList.do", response, status, error);
                }
            });
        }
    }
};

Common.getBaseCode = function (pStrGroupCode) {
    if (pStrGroupCode == undefined) return;

    var jsonData = {};
    jsonData["key"] = pStrGroupCode;

    var returnData = "";
    if (localCache.exist("CODE_" + pStrGroupCode)) {
        returnData = localCache.get("CODE_" + pStrGroupCode);
    } else {
        $.ajax({
            url: "/covicore/common/getbasecode.do",
            data: jsonData,
            type: "post",
            async: false,
            success: function (res) {
                returnData = res.value;
                localCache.set("CODE_" + pStrGroupCode, returnData, "");
            },
            error: function (response, status, error) {
                CFN_ErrorAjax("common/getbasecode.do", response, status, error);
            }
        });
    }

    return returnData;
};

Common.getBaseCodeDic = function (pStrGroupCode, code ) {
    if (pStrGroupCode == undefined) return;

    var jsonData = {};
    jsonData["key"] = pStrGroupCode;

    var returnData = "";
    if (localCache.exist("CODE_" + pStrGroupCode)) {
        returnData = localCache.get("CODE_" + pStrGroupCode);
    } else {
        $.ajax({
            url: "/covicore/common/getbasecode.do",
            data: jsonData,
            type: "post",
            async: false,
            success: function (res) {
                returnData = res.value;
                localCache.set("CODE_" + pStrGroupCode, returnData, "");
            },
            error: function (response, status, error) {
                CFN_ErrorAjax("common/getbasecode.do", response, status, error);
            }
        });
    }

    if (code != null && code != ""){
        for (var i = 0; i < returnData["CacheData"].length; i++) {
    		var item = returnData["CacheData"][i];
    		if (code == item["Code"]) return CFN_GetDicInfo(item["MultiCodeName"]);
    	}
        return pStrGroupCode+"_"+code;
    }
    else     return returnData;
};

/*
 * 기초코드 일괄 조회용 공통 스크립트
 * pCodeArray	다국어코드	: (Array) ["BizSection", "TodoMsgType", ...]
 *
 * ex) Common.getBaseCodeList(["BizSection", "TodoMsgType", ...]);
 *
 */
Common.getBaseCodeList = function (pCodeArray) {
    if (pCodeArray.length > 0) {
        var param = {
            codeGroupArray: encodeURIComponent(JSON.stringify(pCodeArray)),
            "EXCLUDE_VALD": true
        }

        $.ajax({
            url: "/covicore/common/getBaseCodeList.do",
            data: param,
            type: "post",
            async: false,
            success: function (res) {
                if (res.status == "SUCCESS") {
                    $.extend(coviCmn.codeMap, res.codeMap);
                }
            },
            error: function (response, status, error) {
                CFN_ErrorAjax("/covicore/common/getBaseCodeList.do", response, status, error);
            }
        });
    }
}

///////////////////////////////// global.properties 값 조회//////////////////////////////////////////

Common.getGlobalProperties = function (pKey) {
    var returnData = "";

    if (localCache.exist(pKey)) {
        returnData = localCache.get(pKey);
    } else {
        if (pKey != undefined && pKey != "") {
            $.ajax({
                url: "/covicore/helper/getglobalproperties.do", // [2016-06-09] 박경연. approval에서 접근할 때 문제가 있음
                data: {
                    "key": pKey,
                    "EXCLUDE_VALD":true                },
                type: "post",
                async: false,
                success: function (res) {
                    if (res.status == "SUCCESS") {
                        returnData = res.value;
                        localCache.set(pKey, returnData, "");
                    }
                    else {
                        returnData = undefined;
                        //localCache.set(pKey, returnData, "");
                    }
                },
                error: function (response, status, error) {
                    CFN_ErrorAjax("helper/getglobalproperties.do", response, status, error);
                    //				alert($.parseJSON(response.responseText).Message);
                }
            });
        }
    }
    return returnData;
}


Common.getS3Properties = function (pKey) {
	var returnData = "";

	if (localCache.exist(pKey)) {
		returnData = localCache.get(pKey);
	} else {
		if (pKey != undefined && pKey != "") {
			$.ajax({
				url: "/covicore/helper/getS3properties.do", // [2016-06-09] 박경연. approval에서 접근할 때 문제가 있음
				data: {
					"key": pKey
				},
				type: "post",
				async: false,
				success: function (res) {
					if (res.status == "SUCCESS") {
						returnData = res.value;
						localCache.set(pKey, returnData, "");
					}
					else {
						returnData = undefined;
						//localCache.set(pKey, returnData, "");
					}
				},
				error: function (response, status, error) {
					CFN_ErrorAjax("helper/getS3properties.do", response, status, error);
					//				alert($.parseJSON(response.responseText).Message);
				}
			});
		}
	}
	return returnData;
}

Common.getSecurityProperties = function(pKey){
	var returnData = "";
	
	if (localCache.exist(pKey)) {
		returnData = localCache.get(pKey);
	} else {
		if(pKey != undefined && pKey != ""){
			$.ajax({
				url : "/covicore/helper/getsecurityproperties.do", // [2016-06-09] 박경연. approval에서 접근할 때 문제가 있음
				data : {
					"key" : pKey
				},
				type : "post",
				async : false,
				success : function(res) {
					if(res.status == "SUCCESS"){
						returnData = res.value;
						localCache.set(pKey, returnData, "");
					}
					else{
						returnData = undefined;
						//localCache.set(pKey, returnData, "");
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("helper/getsecurityproperties.do", response, status, error);
		//				alert($.parseJSON(response.responseText).Message);
				}
			});
		}
	}
	return returnData;
}

Common.getExtensionProperties = function(pKey){
	var returnData = "";
	
	if (localCache.exist(pKey)) {
		returnData = localCache.get(pKey);
	} else {
		if(pKey != undefined && pKey != ""){
			$.ajax({
				url : "/covicore/helper/getextensionproperties.do",
				data : {
					"key" : pKey
				},
				type : "post",
				async : false,
				success : function(res) {
					if(res.status == "SUCCESS"){
						returnData = res.value;
						localCache.set(pKey, returnData, "");
					}
					else{
						returnData = undefined;
						//localCache.set(pKey, returnData, "");
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("helper/getsecurityproperties.do", response, status, error);
		//				alert($.parseJSON(response.responseText).Message);
				}
			});
		}
	}
	return returnData;
}

////////////////////////////////////////////////////////////////////////////////////

function XFN_getContextPath(){
    var offset=location.href.indexOf(location.host)+location.host.length;
    var ctxPath=location.href.substring(offset,location.href.indexOf('/',offset+1));
    return ctxPath;
}

///////////////uuid 가져오기/////////////////////

Common.getUUID = function () {
var returndata = "";

	$.ajax({
		url:"/covicore/common/getuuid.do",
		type:"get",
		async:false,
		success: function (res) {
			if(res.status == "SUCCESS"){
				returndata = res.resultData;
			} else {
				alert("message : " + res.message);
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("common/getuuid.do", response, status, error);
		}
	});

	return returndata;
}

//////////////////////////////////////////////

/////////////////// local cache /////////////////////
var localCache = {
	timeout : 3600000*2, // 60 minutes
	// timeout: 60000, // 1 minutes
	data : {}, // @type {{_: number, data: {}}}
	remove : function(key) {
		if(localCache.isLocalStorage()){
			sessionStorage.removeItem(key);
		} else {
			delete localCache.data[key];	
		}
	},
	removeAll : function(){
		localCache.data = {};
		sessionStorage.clear();
//		localStorage.clear(); // 로컬 스토리지 다국어 적용을 위해 주석처리 - dyjo 2019.04.16
	},
	exist : function(key) {
		if(localCache.isLocalStorage()){
			var sessionStoragedItem = JSON.parse(sessionStorage.getItem(key));
			return !!sessionStorage.getItem(key) && ((new Date().getTime() - sessionStoragedItem._) < localCache.timeout);
		} else {
			return !!localCache.data[key] && ((new Date().getTime() - localCache.data[key]._) < localCache.timeout);	
		}
	},
	get : function(key) {
		if(localCache.isLocalStorage()){
			var sessionStoragedItem = JSON.parse(sessionStorage.getItem(key));
			return sessionStoragedItem.data;
		} else {
			return localCache.data[key].data;	
		}
	},
	set : function(key, cachedData, callback) {
		if(localCache.isLocalStorage()){
			sessionStorage.removeItem(key);
			var sessionStoragedItem = {
				_ : new Date().getTime(),
				data : cachedData
			}
			sessionStorage.setItem(key, JSON.stringify(sessionStoragedItem))
		} else {
			localCache.remove(key);
			localCache.data[key] = {
				_ : new Date().getTime(),
				data : cachedData
			};
		}
		
		if ($.isFunction(callback))
			callback(cachedData);
	},
	isLocalStorage : function(){
		var test = 'test';
	    try {
	        sessionStorage.setItem(test, test);
	        sessionStorage.removeItem(test);
	        return true;
	    } catch(e) {
	        return false;
	    }
	}
};

/** 
 * coviStorage : 로컬 스토리지 관련 함수 제공 
 * @author dyjo
 * @since 2019.04.16 
 */
var coviStorage = {

    /* 로컬 스토리지 사용 가능 여부 확인 */
    isAvailable: function () {
        var x = "__storage_test__";

        try {
            localStorage.setItem(x, x);
            localStorage.removeItem(x);
            return true;
        } catch (e) {
            return false;
        }
    },

	/* callback 함수를 지원하는 비동기 Ajax 함수 */
	asyncSubmit : function (url, params, callback) {
		$.ajax({
			async : true,
			url : url,
			type : "POST",
			data : JSON.stringify(params),
			dataType : "json",
			contentType : "application/json; charset=utf-8",
			success : function (result) {
				callback(result);
			},
			error : function (response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});				
	},
	
	/* 로컬 스토리지에서 특정 키에 해당하는 값 리턴 */
	getValue : function (key) {
		var value = localStorage.getItem(key);
		return value;
	},
	
	/* 로컬 스토리지에 키와 값을 저장 */
	setValue : function (key, value) {
		localStorage.setItem(key, value);
	},
	
	/* 로컬 스토리지에서 Dictionary 데이터 조회 */
	getDictionary : function () {
		return coviStorage.getValue("Dictionary");
	},

    /* 로컬 스토리지에서 BaseConfig 데이터 조회 */
    getLocalBase : function( syncObjectType , pDN_ID) {
        return coviStorage.getValue("BaseConfig_" + pDN_ID);
    },
	
	/* Dictionary 데이터에서 특정 다국어 코드에 해당하는 메시지 리턴 */
	getMessage : function (key) {
		var msg = null;
		var dictionary = coviStorage.getDictionary();
		
        if (dictionary != null) {
            var beginIdx = dictionary.indexOf("†" + key + "§") + 1;
            if (beginIdx != 0) {
                var endIdx = dictionary.indexOf("†", beginIdx);
                //마지막 값이면
                if (endIdx == -1) endIdx = dictionary.length;
                var dicData = dictionary.substring(beginIdx, endIdx);
				
                if (dicData != null) {
                    msg = dicData.split("§")[1];
                }
            } else {
                msg = "";
            }
        }
		
        return msg;
	},

    getBaseConfig: function(key, pDN_ID) {
        var msg = null, baseConfig = null;
		
        if (pDN_ID == undefined || pDN_ID == "undefined" || pDN_ID == "null"){
        	pDN_ID = Common.getSession("DN_ID");
        }
		
        baseConfig = coviStorage.getLocalBase("BASE_CONFIG" , pDN_ID);
		
        if (baseConfig != null) {
            var beginIdx = baseConfig.indexOf("†" + key + "§") + 1;
			
            if (beginIdx != 0) {
                var endIdx = (baseConfig.indexOf("†", beginIdx) === -1) ? baseConfig.length : baseConfig.indexOf("†", beginIdx);
                var dicData = baseConfig.substring(beginIdx, endIdx);
				
                if (dicData != null) {
                    msg = dicData.split("§")[1];
                }
            } else {
                if(pDN_ID != 0 && pDN_ID != undefined){ //현재 도메인에 지정된 기초설정 값이 없을 경우 그룹사(공용)값 조회
                	msg = coviStorage.getBaseConfig(key,0);
                }else{
                	msg = "";
                }
            }
        }else if(pDN_ID != 0 && pDN_ID != undefined){ //해당 도메인에 설정된 기초설정값이 없을 경우 
        	msg = coviStorage.getBaseConfig(key,0);
        }else{ //그룹사(공용), 현재 도메인 모두에 설정된 값이 없을 경우 
        	msg = "";
        }
        
		return msg;
	},
	
	/* 로컬 스토리지의 Dictionary, DictionarySyncTime 데이터 삭제 */
	clear : function (target) {
		target = (target == undefined ? "ALL" : target.toUpperCase());
		
		if(target == "ALL" || target == "DICTIONARY"){
			localStorage.removeItem("Dictionary");
			localStorage.removeItem("DictionaryLang");
			localStorage.removeItem("DicSyncKey");
		}
		
		if(target == "ALL" || target == "CONFIG"){
			var targetKey = [];
			localStorage.removeItem("ConfigSyncKey");
			for (var i = 0; i < localStorage.length; i++) {
				var key = localStorage.key(i);
				
				if(key != null && key.indexOf("BaseConfig") > -1){
					targetKey.push(key);
				}
			}
			$.each(targetKey, function(idx, key){
				localStorage.removeItem(key);
			})
			
		}
	},
	
	/* 로컬 스토리지 다국어 동기화 */
	syncStorage : function () {
		var localDicSyncKey = coviStorage.getValue("DicSyncKey"); //syncLocalBase
        var isAvailable = coviStorage.isAvailable();
        if (isAvailable) {
        	if (localDicSyncKey == ""  || localDicSyncKey != serverDicSyncKey || coviStorage.getValue("DictionaryLang") !=  Common.getSession("lang")){
        		var url = "/covicore/common/syncStorage.do";
				var params = {};
				coviStorage.clear("DICTIONARY");
				coviStorage.asyncSubmit(url, params, function (result) {
					var target = result;

					if (target != null) {
						coviStorage.clear("DICTIONARY");
    
						for (var key in target) {
							coviStorage.setValue(key, target[key]);
						}
					}
	
					coviStorage.getDictionary();
					coviStorage.setValue("DicSyncKey",serverDicSyncKey);
				});      		
        	}
        } else {
            Common.Inform("This browser do not support Local Storage.");
        }
        
/*		if (isAvailable) {
			var isSubmit = true;
			var dicSyncLang = coviStorage.getValue("DictionaryLang");
			var dicSyncTime = coviStorage.getValue("DictionarySyncTime");

            if (dicSyncTime != undefined && dicSyncTime != "") {
            	var sysSyncLang = Common.getSession("lang");
                var sysSyncTime = Common.getSession("SYS_SYNC_TIME");

                if (dicSyncLang == sysSyncLang && sysSyncTime != null && sysSyncTime != "") {
                    var dtime = parseInt(dicSyncTime);
                    var stime = parseInt(sysSyncTime);

                    if (dtime > stime) {
                        isSubmit = false;
                    }
                } else {
                    isSubmit = false;
                }
            }

            if (isSubmit) {
                var url = "/covicore/common/syncStorage.do";
                var params = {};

                coviStorage.asyncSubmit(url, params, function (result) {
                    var target = result;

                    if (target != null) {
                        coviStorage.clear("DICTIONARY");

                        for (var key in target) {
                            coviStorage.setValue(key, target[key]);
                        }
                    }

                    coviStorage.getDictionary();
                });
            }
        } else {
            Common.Inform("This browser do not support Local Storage.");
        }*/
    },
    
    /* 로컬 스토리지 기초설정 동기화 
     * (기초코드 향후 구현 예정)
     * */
    syncLocalBase: function( objectType ) {
        var localConfigSyncKey = coviStorage.getValue("ConfigSyncKey"); //syncLocalBase
        var isAvailable = coviStorage.isAvailable();
        if (isAvailable) {
        	if (localConfigSyncKey == "" || localConfigSyncKey != serverConfigSyncKey){
                var params = { objectType: "BASE_CONFIG", "EXCLUDE_VALD":true };
                coviStorage.asyncSubmit("/covicore/common/syncBaseCfNCd.do", params, function (result) {
                    var target = result;

                    if (target != null) {
                        coviStorage.clear("CONFIG");
                		localCache.removeAll();

                        for (var key in target) {
                            coviStorage.setValue(key, target[key]);
                        }
                    }
                    coviStorage.setValue("ConfigSyncKey",serverConfigSyncKey);
                });
                
        	}
        } else {
            Common.Inform("This browser do not support Local Storage.");
        }

        /*
        var _syncTime = "BaseConfigSyncTime";
        var _sessionTime = "SYS_BASE_CONFIG_SYNC_TIME";

        var localKey = localCache.get("ConfigSyncKey"); //syncLocalBase

        if (isAvailable) {
            var isSubmit = true;
            var dicSyncTime = coviStorage.getValue( _syncTime );

            if (dicSyncTime != undefined && dicSyncTime != "") {
                var sysSyncTime = Common.getSession( _sessionTime );

                if (sysSyncTime != null && sysSyncTime != "") {
                    var dtime = parseInt(dicSyncTime);
                    var stime = parseInt(sysSyncTime);

                    if (dtime > stime) {
                        isSubmit = false;
                    }
                } else {
                    isSubmit = false;
                }
            }

            if (isSubmit) {
                var params = { objectType: "BASE_CONFIG", "EXCLUDE_VALD":true };
                coviStorage.asyncSubmit("/covicore/common/syncBaseCfNCd.do", params, function (result) {
                    var target = result;

                    if (target != null) {
                        coviStorage.clear("CONFIG");

                        for (var key in target) {
                            coviStorage.setValue(key, target[key]);
                        }
                    }
                });
            }
        } else {
            Common.Inform("This browser do not support Local Storage.");
        }*/
    }
};

Common.getSession = function (pKey) {
    var returndata = "";
    var localStorageKey = (pKey == undefined ? "SESSION_all" : "SESSION_"+ pKey);
    
    if(localCache.exist("SESSION_UR_ID") && localCache.get("SESSION_UR_ID") != coviCmn.getCookie("LastLoginUser")){
    	localCache.removeAll();
    }
    
    //TODO logout또는 접속 종료 시 localCache의 초기화 처리가 해결되지 않으면 아래 주석을 풀지 말 것.
    if (localCache.exist(localStorageKey)) {
        returndata = localCache.get(localStorageKey);
    } else {
        $.ajax({
            url: "/covicore/common/getSession.do",
            data: {
                "key": pKey,
                "EXCLUDE_VALD":true
            },
            type: "post",
            async: false,
            success: function (res) {
                if (res.status == "SUCCESS") {
                    if ($(res.resultList).length >= 1 && pKey != undefined && pKey != "" && pKey != null) {
                        returndata = res.resultList[pKey];
                        localCache.set(localStorageKey, returndata, "");
                    } else {
                        returndata = res.resultList;

                        localCache.set(localStorageKey, returndata, "");
                        
                        for(var objVarName in returndata) { 
                        	localCache.set("SESSION_"+ objVarName, res.resultList[objVarName], "");
                        }                        
                    }
                } else {
                    //alert("session : " + res.message);
                }
            },
            error: function (response, status, error) {
                CFN_ErrorAjax("common/getSession.do", response, status, error);
            }
        });
    }

	return returndata;
}
///////////////// 세션 조회  끝/////////////////////


/////////////////// 파일 다운로드 /////////////////////
/*	pFileID 		: 파일ID
*	pFileName		: 원본파일명
*/
Common.fileDownLoad = function (pFileID, pFileName, pFileToken) {
	if ($("#divFileDownLoadHiddenLayer").length < 1) {
		$("body").append('<div id="divFileDownLoadHiddenLayer" style="display: none;"></div>');
	}

	$("#divFileDownLoadHiddenLayer").append(
		'<iframe id="ifrDownLoadHiddenFrame_'+pFileID+'" src="/covicore/common/fileDown.do?fileID='+pFileID+'&fileToken='+pFileToken+'" name="download" style="width:0px; heigth:0px"></iframe>'
	);
}

/*	HTML5 Anchor File Download Script
 *	Param : files ( Common.downloadAll($.parseJSON(getInfo("FileInfos"))) )
 *	
 */
Common.downloadAll = function (files) {
	var fileJSONArray = files;
    if(fileJSONArray.length == 0) return;  
    var file = fileJSONArray.pop();
	Common.fileDownLoad(file.FileID, "", file.FileToken);
	Common.downloadAll(files);		//getInfo("FileInfos")가 object array타입이므로 모두pop하여 다운로드 호출할때까지 재귀호출 시도
}  

Common.zipFiledownload = function (bizSection, pFolderID, pMessageID, pVersion) {
	if ($("#divZipFileDownLoadHiddenLayer").length < 1) {
		$("body").append('<div id="divZipFileDownLoadHiddenLayer" style="display: none;"></div>');
	}

	$("#divZipFileDownLoadHiddenLayer").append(
		'<iframe id="ifrDownLoadHiddenFrame_zip" src="/covicore/common/zipFileDownload.do?bizSection='+bizSection+'&folderID='+pFolderID+'&messageID='+pMessageID+'&version='+pVersion+'" name="download" style="width:0px; heigth:0px"></iframe>'
	);
}  


Common.getFileSrc = function(bizSection, fileID){
	var returnData = "";

	if((bizSection != null && bizSection != "")
			&& (fileID != null && fileID != "")){
		
		if (localCache.exist("FILE_" + bizSection + "_" + fileID)) {
			returnData = localCache.get("FILE_" + bizSection + "_" + fileID);
		} else {
			$.ajax({
				url : "/covicore/common/viewsrc/" + fileID + ".do",
				type : "get",
				success : function(res) {
					localCache.set("FILE_" + bizSection + "_" + fileID, res, "");
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/common/viewsrc/" + fileID + ".do", response, status, error);
				}
			});
			returnData = "/covicore/common/view/" + fileID + ".do";
		}
	} else {
		returnData = "/covicore/resources/images/no_image.jpg";
	}

	return returnData;
}

Common.getThumbSrc = function(bizSection, fileID){
	var returnData = "";

	if((bizSection != null && bizSection != "") && (fileID != null && fileID != "")){
		if (localCache.exist("THUMB_" + bizSection + "_" + fileID)) {
			returnData = coviCmn.loadImage(localCache.get("THUMB_" + bizSection + "_" + fileID));
		} else {
			$.ajax({
				url : "/covicore/common/previewsrc/" + fileID + ".do",
				type : "get",
				async: false,
				success : function(res) {
					localCache.set("THUMB_" + bizSection + "_" + fileID, res, "");
					returnData = coviCmn.loadImage(localCache.get("THUMB_" + bizSection + "_" + fileID));
				},
				error:function(response, status, error){					
					// Preview 이미지가 없는 경우 원본사진
					if(response.status == "404") {
						returnData = coviCmn.loadImageId(fileID, bizSection);
					} else {
						CFN_ErrorAjax("/covicore/common/previewsrc/" + fileID + ".do", response, status, error);
					}
				}
			});
		}
	} else {
		returnData = "no_image.jpg";
	}

	return returnData;
}

/*파일 미리보기*/
Common.filePreview = function (pFileID, pFileToken, pExtention, pSelf) {
   var extention = (pExtention==null)?"":pExtention.toLowerCase();
   if (extention ==  "jpg" ||
	   extention ==  "jpeg" ||
	   extention ==  "png" ||
	   extention ==  "tif" ||
	   extention ==  "bmp" ||
	   extention ==  "xls" ||
	   extention ==  "xlsx" ||
	   extention ==  "doc" ||
	   extention ==  "docx" ||
	   extention ==  "ppt" ||
	   extention ==  "pptx" ||
	   extention ==  "txt" ||
	   extention ==  "pdf" ||
	   extention ==  "hwp") {
		var url = Common.getBaseConfig("MobileDocConverterURL") + "?fileID=" + pFileID + "&fileToken=" + encodeURIComponent(pFileToken);
//	    var url = "/covicore/common/convertPreview.do" + "?fileID=" + pFileID + "&fileToken=" + encodeURIComponent(pFileToken);
		if (pSelf == "Y"){	//my창에서 열기
	    	if ($('#filePreview').length>0){
	    		$('#filePreview').remove();
	    	}
	    	
	    	var previewFrm ='<div id="filePreview">'+
				'<div class="conin_view" style="left:790px;position: fixed; top:70px;">'+
				'	<div class="xbar"></div>'+
				'	<div class="wordView" style="height: calc(100% - 91px);">'+
				'		<iframe id="IframePreview" name="IframePreview" frameborder="0" width="100%" height="100%" scrolling="no"></iframe>'+
				'	</div>'+
			  	'</div>'+
			'</div>';
	    	
	    	 $('body').append(previewFrm);

	    	 $("#IframePreview").attr('src', url);
//	    	 window.open(url, "", "width=850, height=" + (window.screen.height-100));
	    	 window.moveTo(0, 0);
	    	 if (window.screen.width < 1550) {
				window.resizeTo(window.screen.width, window.screen.height);
	    	 }
	    	 else {
				window.resizeTo(1550, window.screen.height);
	    	 }
	    }
		else{
			window.open(url, "", "width=850, height=" + (window.screen.height-100));
		}	
	} else if(extention == "diff") {
		window.open("/covicore/common/diffFilePreview.do?fileID="+pFileID+"&fileToken="+pFileToken, "", "width=" + screen.width + ", height=" + screen.height + ", fullscreen=yes");
	} else {
	   alert(Common.getDic("msg_ConversionNotSupport"));//"변환이 지원되지않는 형식입니다."
	   return false;
	}
}
///////////////// 파일 다운로드  끝/////////////////////

Common.ObjectToString = function(object){

	var type = typeof object;
	switch (type) {
        case 'undefined':
        case 'function':
        case 'unknown': return;
        case 'boolean': return object.toString();
        case 'string': return object.toString();
        case 'number': return object.toString();
        case 'object': return JSON.stringify(object);
    }
	
}

Common.getSystemName = function(){
	var systemName = "";
	var targetUrl = "";
	var domain = location.protocol + "//" + location.host;
	try{
		// 팝업인경우 호출한 시스템명 추출
		if(CFN_GetQueryString("CFN_OpenWindowName") != "undefined" || CFN_GetQueryString("CFN_OpenLayerName") != "undefined") targetUrl = document.referrer;
		else targetUrl = location.href;
		
		if(targetUrl && domain && targetUrl.indexOf(domain) > -1){
			var arr_systemName = targetUrl.replace(domain,"").split("/");
			if(arr_systemName.length > 1) systemName = arr_systemName[1];
		}
	} catch(e){
		systemName = "";
	}
	
	return systemName;
}

//-----------------------------------------------------------------------------------------------
function SaveFirstPageURL(url){
	if(url != "/covicore/admin.do"){
		var result = confirm(Common.getDic("lbl_AreYouSetStartPage"));
		if(result){
			CFN_SetCookieDay("SaveAdminURL", url + "|" + Common.getSession("USERID"), 365 * 24 * 60 * 60 * 1000);
			alert(Common.getDic("msg_HasBeenProcess"));
		}
	}else{
		alert(Common.getDic("lbl_CannotStartPage"));
	}
}


//////////////////////////////////////////BaseObjectInfo Start ////////////////////////////////
//객체 정보 가져오기 Table 형태로 반환
/// <param name="pMode">정보 조회 대상 - (UR-User, GR-Group, DN-Domain)</param>
/// <param name="pObjectIDs">객체 아이디(코드) - k96mi005;a;b</param>
/// <param name="pSearchFields">조회 필드(UR_Code,DisplayName)</param>
/// <param name="pFilter">필터 조건</param>
/// <param name="pOrder">Sort 조건</param>
/// <returns>Json 형식의 DataTable</returns>
Common.GetObjectInfo = function (pMode, pObjectID, pSearchFields) {
 var oResult, bSucces;
 if (pMode == undefined || pObjectID == null || pObjectID == undefined || pObjectID == null) return;
 if (pSearchFields == undefined || pSearchFields == null) { pSearchFields = ''; }

 try {
	 $.ajax({
		url : "/covicore/control/GetBaseObjectInfo.do",
		data: {
            "mode": pMode,
            "objId": pObjectID,
            "fields": pSearchFields
        },
        type: "post",
        async: false,		
		success : function(res) {
			if (res.status == "SUCCESS") {
				bSucces = true;
				oResult = res.result.list[0];
		     } else {
		    	 oResult = res.message;
		     }
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/covicore/control/GetBaseObjectInfo.do", response, status, error);
		}
	});
	 
	 if (bSucces) {
         return oResult;
     } else {
         Common.Error(oResult);
     }
 } finally {
     oResult = null;
     bSucces = null;
 }
}
//////////////////////////////////////////BaseObjectInfo End ////////////////////////////////

//////////////////////////////////////////TimeZone Start ////////////////////////////////

//시스템 기준시와 UTC 타임과의 차이 및 입력한 특정 타임존 코드의 타임죤과 시스템 표준 타임죤과 차이
Common.GetTimeZoneTimeDiff = function (pTimeZoneCode) {
 var l_AjaxResult;
 if (pTimeZoneCode == undefined) { pTimeZoneCode = "StandardTimeZone"; }
 if (_TimeZoneTimeDiff[pTimeZoneCode] == "undefined" || _TimeZoneTimeDiff[pTimeZoneCode] == null) {
     l_AjaxResult = CFN_CallAjaxJson("/WebSite/Base/Controls/WebService.asmx/GetTimeZoneTimeDiff", "{pTimeZoneCode:'" + pTimeZoneCode + "'}", false, null);
     _TimeZoneTimeDiff[pTimeZoneCode] = $.parseJSON(l_AjaxResult).d;
 }

 l_AjaxResult = null;
 return _TimeZoneTimeDiff[pTimeZoneCode];
}

//서버시간을 자신의 타임존 시간으로 변환하여 반환함.
//pLocalFormat - 임력하지 않으면 로컬 포멧으로 변환하여 반환함.
//pUrTimeZone - 사용자 타임존 값으로 입력하지 않으면 세션에서 조회
function CFN_TransLocalTime(pServerTime, pLocalFormat, pUrTimeZone) {
	var l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS;  // 입력 년월일시분초
	var l_TimeZone, l_ZoneHH, l_ZoneMM, l_ZoneSS, l_Minus, l_UR_TimeZone;  // 타임존 시분초 +- 여부
	var l_StringDate, l_StringTime, l_DateFormat = "", l_DateFormatCount;  // 입력 날짜, 입력 시간, 입력날짜 형식, 입력한 값 길이
	var l_ReturnString = "";

	if (pServerTime =="" ||pServerTime ==null || pServerTime == undefined) return "";
	
	//pServerTime이 Date Object로 넘어올 경우 처리
	if(typeof pServerTime === "object") {
		pServerTime = new Date(pServerTime.time).format("yyyy-MM-dd HH:mm:ss")
	}
	
	l_DateFormatCount = pServerTime.length;
	
	//공백대신 T로 오는경우 치환
	if (pServerTime.indexOf("T") != -1) {
		pServerTime = pServerTime.replace("T"," ");
	}
	
	// 1. 날짜(2011-01-04)와 시간(09:12, 08:12:12)이 같이 들어와야 한다.
	if (pServerTime.indexOf(" ") == -1) {
	    if (pServerTime.length == 10) {
	        pServerTime += " 00:00:00";
	    } else if (pServerTime.length === 8 && pServerTime.indexOf('-')===-1) {
			pServerTime = pServerTime.substring(0,4)+"-"+pServerTime.substring(4,6)+"-"+pServerTime.substring(6) + " 00:00:00";
		} else {
	        return pServerTime;
	    }
	} 
	
	l_StringDate = pServerTime.split(' ')[0]
	l_StringTime = pServerTime.split(' ')[1]
	
	// 2. 날짜 형식은 "-", ".", "/"을 받는다.
	// 입력 포멧 확인
	if (l_StringDate.indexOf(".") > -1) { l_DateFormat = "."; }
	if (l_StringDate.indexOf("-") > -1) { l_DateFormat = "-"; }
	if (l_StringDate.indexOf("/") > -1) { l_DateFormat = "/"; }
	
	if (l_DateFormat == "") {
	    return pServerTime;
	}
	l_StringDate = l_StringDate.replace(/-/g, "")
	l_StringDate = l_StringDate.replace(/\./g, "")
	l_StringDate = l_StringDate.replace(/\//g, "")
	l_StringTime = l_StringTime.replace(/:/g, "")
	
	// 3. 시간은 시분까지는 들어와야 한다.(초는 없어도 됨.)
	if (l_StringDate.length != 8 || l_StringTime.length < 4) {
	    return pServerTime;
	}
	
	// 형식에 맞게 숫자를 체워줌
	l_StringTime = CFN_PadRight(l_StringTime, 6, "0");
	
	// 입력받은 일시 분해
	l_InputYear = l_StringDate.substring(0, 4);
	l_InputMonth = l_StringDate.substring(4, 6) - 1; // 월은 1을 빼줘야 함.
	l_InputDay = l_StringDate.substring(6, 8);
	l_InputHH = l_StringTime.substring(0, 2);
	l_InputMM = l_StringTime.substring(2, 4);
	l_InputSS = l_StringTime.substring(4, 6);
	
	// 시간 형식 체크
	var l_InputDate = new Date(l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS);
	if (l_InputDate.getFullYear() != l_InputYear || l_InputDate.getMonth() != l_InputMonth || l_InputDate.getDate() != l_InputDay ||
	    l_InputDate.getHours() != l_InputHH || l_InputDate.getMinutes() != l_InputMM || l_InputDate.getSeconds() != l_InputSS) {
	    return pServerTime;
	}
	// 9999년의 타임존 처리는 패스함(9999년은 대부분 영구를 의미함)
	if(Common.getBaseConfig("useTimeZone") == "Y" && pServerTime.indexOf('9999') == -1){
		// 자신의 타임존 시간 가져오기(세션에 정의된 타임존 값을 가져옴.)
		if (typeof pUrTimeZone != "undefined"){
		 l_UR_TimeZone = pUrTimeZone
		}else if (typeof _UR_TimeZone == "undefined") {
		    l_UR_TimeZone = Common.getSession("UR_TimeZone");
		} else {
		    l_UR_TimeZone = _UR_TimeZone;
		}
		l_Minus = l_UR_TimeZone.substring(0, 1);
		l_TimeZone = l_UR_TimeZone.replace("-", "").replace(":", "").replace(":", "");
		l_ZoneHH = l_TimeZone.substring(0, 2);
		l_ZoneMM = l_TimeZone.substring(2, 4);
		l_ZoneSS = l_TimeZone.substring(4, 6);
		
		var l_TimeZoneTime = (parseInt(l_ZoneHH, 10) * 3600000) + (parseInt(l_ZoneMM, 10) * 60000) + (parseInt(l_ZoneSS, 10) * 1000)
		
		if (l_Minus == "-") {
		    l_InputDate.setTime(l_InputDate.getTime() - l_TimeZoneTime);
		} else {
		    l_InputDate.setTime(l_InputDate.getTime() + l_TimeZoneTime);
		}	
	}    
	
	if (pLocalFormat == undefined || pLocalFormat == "") {
	    // 포멧을 지정하지 않을 경우 원래 요청한 (로컬 표준포멧의)형식으로 반환
	    pLocalFormat = "yyyy-MM-dd HH:mm:ss";
	    l_ReturnString = pLocalFormat
	    .replace("yyyy", CFN_PadLeft(l_InputDate.getFullYear(), 4, "0"))
	    .replace("MM", CFN_PadLeft(l_InputDate.getMonth() + 1, 2, "0"))
	    .replace("dd", CFN_PadLeft(l_InputDate.getDate(), 2, "0"))
	    .replace("HH", CFN_PadLeft(l_InputDate.getHours(), 2, "0"))
	    .replace("mm", CFN_PadLeft(l_InputDate.getMinutes(), 2, "0"))
	    .replace("ss", CFN_PadLeft(l_InputDate.getSeconds(), 2, "0"));
	    l_ReturnString = l_ReturnString.substr(0, l_DateFormatCount);
	}
	else // 사용자가 포멧을 지정하여 요청하면 요청한 데로 반환
	{
	    l_ReturnString = pLocalFormat
	    .replace("yyyy", CFN_PadLeft(l_InputDate.getFullYear(), 4, "0"))
	    .replace("MM", CFN_PadLeft(l_InputDate.getMonth() + 1, 2, "0"))
	    .replace("dd", CFN_PadLeft(l_InputDate.getDate(), 2, "0"))
	    .replace("HH", CFN_PadLeft(l_InputDate.getHours(), 2, "0"))
	    .replace("mm", CFN_PadLeft(l_InputDate.getMinutes(), 2, "0"))
	    .replace("ss", CFN_PadLeft(l_InputDate.getSeconds(), 2, "0"));
	}
	
	return l_ReturnString;
}

//타임존 시간을 서버시간으로 변환하여 반환함.
//pServerFormat - 임력하지 않으면 서버 포멧으로 변환하여 반환함.
//pUrTimeZone - 사용자 타임존 값으로 입력하지 않으면 세션에서 조회
function CFN_TransServerTime(pLocalTime, pServerFormat, pUrTimeZone) {
	var l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS;  // 입력 년월일시분초
	var l_TimeZone, l_ZoneHH, l_ZoneMM, l_ZoneSS, l_Minus, l_UR_TimeZone;  // 타임존 시분초 +- 여부
	var l_StringDate, l_StringTime, l_DateFormat = "", l_DateFormatCount;  // 입력 날짜, 입력 시간, 입력날짜 형식, 입력한 값 길이
	var l_ReturnString = "";
	
	l_DateFormatCount = pLocalTime.length;
	
	// 1. 날짜(2011-01-04)와 시간(09:12, 08:12:12)이 같이 들어와야 한다.
	if (pLocalTime.indexOf(" ") == -1) {
	   if (pLocalTime.length == 10) {
	       pLocalTime += " 00:00:00";
	   } else {
	       return pLocalTime;
	   }
	}
	
	// 0000으로 넘어온 값은 빈값으로 치환하여 리턴
	if (pLocalTime.indexOf("0000") > -1) {
		return "";
	}
	
	l_StringDate = pLocalTime.split(' ')[0]
	l_StringTime = pLocalTime.split(' ')[1]
	
	// 2. 날짜 형식은 "-", ".", "/"을 받는다.
	// 입력 포멧 확인
	if (l_StringDate.indexOf(".") > -1) { l_DateFormat = "."; }
	if (l_StringDate.indexOf("-") > -1) { l_DateFormat = "-"; }
	if (l_StringDate.indexOf("/") > -1) { l_DateFormat = "/"; }
	
	if (l_DateFormat == "") {
	   return pLocalTime;
	}
	l_StringDate = l_StringDate.replace(/-/g, "")
	l_StringDate = l_StringDate.replace(/\./g, "")
	l_StringDate = l_StringDate.replace(/\//g, "")
	l_StringTime = l_StringTime.replace(/:/g, "")
	
	// 3. 시간은 시분까지는 들어와야 한다.(초는 없어도 됨.)
	if (l_StringDate.length != 8 || l_StringTime.length < 4) {
	   return pLocalTime;
	}
	
	// 형식에 맞게 숫자를 체워줌
	l_StringTime = CFN_PadRight(l_StringTime, 6, "0");
	
	// 입력받은 일시 분해
	l_InputYear = l_StringDate.substring(0, 4);
	l_InputMonth = l_StringDate.substring(4, 6) - 1; // 월은 1을 빼줘야 함.
	l_InputDay = l_StringDate.substring(6, 8);
	l_InputHH = l_StringTime.substring(0, 2);
	l_InputMM = l_StringTime.substring(2, 4);
	l_InputSS = l_StringTime.substring(4, 6);
	
	// 시간 형식 체크
	var l_InputDate = new Date(l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS);
	if (l_InputDate.getFullYear() != l_InputYear || l_InputDate.getMonth() != l_InputMonth || l_InputDate.getDate() != l_InputDay ||
	   l_InputDate.getHours() != l_InputHH || l_InputDate.getMinutes() != l_InputMM || l_InputDate.getSeconds() != l_InputSS) {
	   return pLocalTime;
	}
	
	// 9999년의 타임존 처리는 패스함(9999년은 대부분 영구를 의미함)
	if(Common.getBaseConfig("useTimeZone") == "Y" && pLocalTime.indexOf('9999') == -1){
		 // 자신의 타임존 시간 가져오기(세션에 정의된 타임존 값을 가져옴.)
		 if (typeof pUrTimeZone != "undefined"){
			 l_UR_TimeZone = pUrTimeZone
		 }else if (typeof _UR_TimeZone == "undefined") {
		     l_UR_TimeZone = Common.getSession("UR_TimeZone");
		 } else {
		     l_UR_TimeZone = _UR_TimeZone;
		 }
		 l_Minus = l_UR_TimeZone.substring(0, 1);
		 l_TimeZone = l_UR_TimeZone.replace("-", "").replace(":", "").replace(":", "");
		 l_ZoneHH = l_TimeZone.substring(0, 2);
		 l_ZoneMM = l_TimeZone.substring(2, 4);
		 l_ZoneSS = l_TimeZone.substring(4, 6);
		
		 var l_TimeZoneTime = (parseInt(l_ZoneHH, 10) * 3600000) + (parseInt(l_ZoneMM, 10) * 60000) + (parseInt(l_ZoneSS, 10) * 1000)
		
		 if (l_Minus == "-") {
		     l_InputDate.setTime(l_InputDate.getTime() + l_TimeZoneTime);
		 } else {
		     l_InputDate.setTime(l_InputDate.getTime() - l_TimeZoneTime);
		 }
	}    
	
	if (pServerFormat == undefined || pServerFormat == "") {
	   // 포멧을 지정하지 않을 경우 원래 요청한 (로컬 표준포멧의)형식으로 반환
	   pServerFormat = "yyyy-MM-dd HH:mm:ss";
	   l_ReturnString = pServerFormat
	   .replace("yyyy", CFN_PadLeft(l_InputDate.getFullYear(), 4, "0"))
	   .replace("MM", CFN_PadLeft(l_InputDate.getMonth() + 1, 2, "0"))
	   .replace("dd", CFN_PadLeft(l_InputDate.getDate(), 2, "0"))
	   .replace("HH", CFN_PadLeft(l_InputDate.getHours(), 2, "0"))
	   .replace("mm", CFN_PadLeft(l_InputDate.getMinutes(), 2, "0"))
	   .replace("ss", CFN_PadLeft(l_InputDate.getSeconds(), 2, "0"));
	   l_ReturnString = l_ReturnString.substr(0, l_DateFormatCount);
	}
	else // 사용자가 포멧을 지정하여 요청하면 요청한 데로 반환
	{
	   l_ReturnString = pServerFormat
	   .replace("yyyy", CFN_PadLeft(l_InputDate.getFullYear(), 4, "0"))
	   .replace("MM", CFN_PadLeft(l_InputDate.getMonth() + 1, 2, "0"))
	   .replace("dd", CFN_PadLeft(l_InputDate.getDate(), 2, "0"))
	   .replace("HH", CFN_PadLeft(l_InputDate.getHours(), 2, "0"))
	   .replace("mm", CFN_PadLeft(l_InputDate.getMinutes(), 2, "0"))
	   .replace("ss", CFN_PadLeft(l_InputDate.getSeconds(), 2, "0"));
	}
	
	return l_ReturnString;
}

//지정한 컨테이너 안의 특정 class를 준 하위 텍스트의 타임죤 처리
function CFN_TransLocalTimeContainer(pContainerID, pTargetClass) {
 $("#" + pContainerID).each(function () {
     $(this).find("." + pTargetClass).each(function () {
         $(this).text(CFN_TransLocalTime($(this).text()))
         $(this).removeClass(pTargetClass);
     });
 });
}

// 오늘 날짜에 해당하는 Local시간 문자열을 리턴
function CFN_GetLocalCurrentDate(pLocalFormat) {
    var l_TimeZone, l_ZoneHH, l_ZoneMM, l_ZoneSS, l_Minus;
    var toTime = new Date();
    var hour = toTime.getTimezoneOffset() / 60;

    // GMT(그리니치 표준시) 런던(GMT + 0) 시간 구하기
    var calGmtHour = toTime.setHours(toTime.getHours() + hour);
    var calGmt = new Date();
	// 타임존 사용 여부에 따른 처리
	if(Common.getBaseConfig("useTimeZone") == "Y"){
		calGmt = new Date(calGmtHour);
	    var l_StandardTimeZoneValue = Common.getBaseConfig("StandardTimeZoneValue"); // 서버시간과 표준시(GMT)와의 차이 값
	    l_Minus = l_StandardTimeZoneValue.substring(0, 1);
	    l_TimeZone = l_StandardTimeZoneValue.replace("-", "").replace(":", "").replace(":", "");
	    l_ZoneHH = l_TimeZone.substring(0, 2);
	    l_ZoneMM = l_TimeZone.substring(2, 4);
	    l_ZoneSS = l_TimeZone.substring(4, 6);
	
	    var l_TimeZoneTime = (parseInt(l_ZoneHH, 10) * 3600000) + (parseInt(l_ZoneMM, 10) * 60000) + (parseInt(l_ZoneSS, 10) * 1000)
	
	    if (l_Minus == "-") {
	        calGmt.setTime(calGmt.getTime() + l_TimeZoneTime);
	    } else {
	        calGmt.setTime(calGmt.getTime() - l_TimeZoneTime);
	    }
	} 

    var strServerTime = calGmt.getFullYear() + '-' + CFN_PadLeft(calGmt.getMonth() + 1, 2, "0") + '-' + CFN_PadLeft(calGmt.getDate(), 2, "0") + ' '
        + CFN_PadLeft(calGmt.getHours(), 2, "0") + ':' + CFN_PadLeft(calGmt.getMinutes(), 2, "0") + ':' + CFN_PadLeft(calGmt.getSeconds(), 2, "0");
	
	return CFN_TransLocalTime(strServerTime, pLocalFormat);
}
//////////////////////////////////////////TimeZone  End ////////////////////////////////

///////////////////////////////////////// MOBILE / PC  - START //////////////////////// 
//[pType]  
//1. P : Properties
Common.agentFilterGetData = function(pKey, pType){
	var returnData = "";
	if(pKey != undefined && pKey != "" && pType != undefined && pType != ""){
			$.ajax({
				url : "/covicore/helper/agentFilterGetData.do", 
				data : {
					"key" : pKey,
					"pType" : pType
				},
				type : "post",
				async : false,
				success : function(res) {
					if(res.status == "SUCCESS"){
						returnData = res.value;
					}
					else{
						returnData = undefined;
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/helper/agentFilterGetData.do", response, status, error);
				}
			});
	}
	
	return returnData;
}

////////////////////////////////////////MOBILE / PC - END   /////////////////////////


//ApprovalListCommon.js 파일로 이동
/*///////////////// 엑셀저장 /////////////////////
function ExcelDownLoad(selectParams, queryID,  title, headerData, listCount){
	if(listCount == 0){
		alert(Common.getDic("msg_apv_279"));
	}else if(listCount > 0){
		if(confirm(Common.getDic("msg_ExcelDownMessage"))){
			location.href = "/covicore/exceldownload.do?"
				+"selectParams="+JSON.stringify(selectParams)
				+"&queryID="+queryID
				+"&title="+title
				+"&headerkey="+headerData[0]
				+"&headername="+headerData[1];
		}
	}
}

//엑셀 저장시 필요한 헤더값 저장
// 반드시 Grid의 Header 변수는 jsp 의 스크립트에서 전역 변수로 "headerData"로 선언해야 함
function getHeaderDataForExcel(){
	var returnArr = new Array();
	var headerKey = "";
	var headerName = "";

	for(var i=0;i<headerData.length; i++){
		if(headerData[i].formatter != "checkbox"){
			headerKey += headerData[i].key + ",";
			headerName += headerData[i].label + ";";
		}
	}
	returnArr.push(headerKey.slice(0,-1));
	returnArr.push(headerName);

	return returnArr;
}*/




/* JSONPath 0.8.4 - XPath for JSON
*
* Copyright (c) 2007 Stefan Goessner (goessner.net)
* Licensed under the MIT (MIT-LICENSE.txt) licence.
*/
function jsonPath(obj, expr, arg) {
  var P = {
     resultType: arg && arg.resultType || "VALUE",
     result: [],
     normalize: function(expr) {
        var subx = [];
        return expr.replace(/[\['](\??\(.*?\))[\]']|\['(.*?)'\]/g, function($0,$1,$2){return "[#"+(subx.push($1||$2)-1)+"]";})  /* http://code.google.com/p/jsonpath/issues/detail?id=4 */
                   .replace(/'?\.'?|\['?/g, ";")
                   .replace(/;;;|;;/g, ";..;")
                   .replace(/;$|'?\]|'$/g, "")
                   .replace(/#([0-9]+)/g, function($0,$1){return subx[$1];});
     },
     asPath: function(path) {
        var x = path.split(";"), p = "$";
        for (var i=1,n=x.length; i<n; i++)
           p += /^[0-9*]+$/.test(x[i]) ? ("["+x[i]+"]") : ("['"+x[i]+"']");
        return p;
     },
     store: function(p, v) {
        if (p) P.result[P.result.length] = P.resultType == "PATH" ? P.asPath(p) : v;
        return !!p;
     },
     find: function(expr, val, path) {
        if (expr !== "") {
           var x = expr.split(";"), loc = x.shift();
           x = x.join(";");
           if (val && val.hasOwnProperty(loc))
              P.find(x, val[loc], path + ";" + loc);
           else if (loc === "*")
              P.walk(loc, x, val, path, function(m,l,x,v,p) { P.find(m+";"+x,v,p); });
           else if (loc === "..") {
              P.find(x, val, path);
              P.walk(loc, x, val, path, function(m,l,x,v,p) { typeof v[m] === "object" && P.find("..;"+x,v[m],p+";"+m); });
           }
           else if (/^\(.*?\)$/.test(loc)) // [(expr)]
              P.find(P.exprCondition(loc, val, path.substr(path.lastIndexOf(";")+1))+";"+x, val, path);
           else if (/^\?\(.*?\)$/.test(loc)) // [?(expr)]
              P.walk(loc, x, val, path, function(m,l,x,v,p) { if (P.exprCondition(l.replace(/^\?\((.*?)\)$/,"$1"), v instanceof Array ? v[m] : v, m)) P.find(m+";"+x,v,p); }); // issue 5 resolved
           else if (/^(-?[0-9]*):(-?[0-9]*):?([0-9]*)$/.test(loc)) // [start:end:step]  phyton slice syntax
              P.slice(loc, x, val, path);
           else if (/,/.test(loc)) { // [name1,name2,...]
              for (var s=loc.split(/'?,'?/),i=0,n=s.length; i<n; i++)
                 P.find(s[i]+";"+x, val, path);
           }
        }
        else
           P.store(path, val);
     },
     walk: function(loc, expr, val, path, f) {
        if (val instanceof Array) {
           for (var i=0,n=val.length; i<n; i++)
              if (i in val)
                 f(i,loc,expr,val,path);
        }
        else if (typeof val === "object") {
           for (var m in val)
              if (val.hasOwnProperty(m))
                 f(m,loc,expr,val,path);
        }
     },
     slice: function(loc, expr, val, path) {
        if (val instanceof Array) {
           var len=val.length, start=0, end=len, step=1;
           loc.replace(/^(-?[0-9]*):(-?[0-9]*):?(-?[0-9]*)$/g, function($0,$1,$2,$3){start=parseInt($1||start);end=parseInt($2||end);step=parseInt($3||step);});
           start = (start < 0) ? Math.max(0,start+len) : Math.min(len,start);
           end   = (end < 0)   ? Math.max(0,end+len)   : Math.min(len,end);
           for (var i=start; i<end; i+=step)
              P.find(i+";"+expr, val, path);
        }
     },
     exprCondition: function(x, _v, _vname) {
		//ex] jsonPath(json, "$..book[?(@.isbn)]")
    	//try { return $ && _v && eval(x.replace(/@/g, "_v")); } => eval _v.xxx format 
    	try { 
			let exp = x.replace(/^\((.*?)\)$/,"$1");
			exp = exp.repace(/@\./g, "");
			return $ && _v && _v[exp]; 
    	}catch(e) { throw new SyntaxError("jsonPath: " + e.message + ": " + x.replace(/@/g, "_v").replace(/\^/g, "_a")); }
     }
  };

  var $ = obj;
  if (expr && obj && (P.resultType == "VALUE" || P.resultType == "PATH")) {
     P.find(P.normalize(expr).replace(/^\$;?/,""), obj, "$");  // issue 6 resolved
     return P.result.length ? P.result : false;
  }
}



//Base64
var Base64 = {
		utf8_to_b64 : function ( str ) {
			return window.btoa(unescape(encodeURIComponent( str )));
		},
		b64_to_utf8 : function ( str ) {
			return decodeURIComponent(escape(window.atob( str )));
		}
}
/*
 * function changeSourceView(obj) {
    var encodeStr = Base64.utf8_to_b64( obj.value );
    var decodeStr = Base64.b64_to_utf8( encodeStr )
    document.mainForm.resultEncode.value = encodeStr;
    document.mainForm.resultDecode.value = decodeStr;
}
*/


// Select Box 디자인 변경된 컨트롤
function clickSelectBox(pObj){
	if($(pObj).parent().parent().find('.selList').css('display') == 'none'){
		$(pObj).parent().parent().find('.selList').show();
	}else{
		$(pObj).parent().parent().find('.selList').hide();
	} 
	if($(pObj).attr('class')=='listTxt'||$(pObj).attr('class')=='listTxt select'){
		$(pObj).parent().find(".listTxt").attr("class","listTxt");
		$(pObj).attr("class","listTxt select");
		$(pObj).parent().parent().find(".up").html($(pObj).text());
		$(pObj).parent().parent().find(".up").attr("value",$(pObj).attr("value"));
	}
}

function urlEncodeValue(str) {

    str = (str + '').toString();

    return encodeURIComponent(str).replace(/!/g, '%21').replace(/'/g, '%27').replace(/\(/g, '%28').replace(/\)/g, '%29').replace(/\*/g, '%2A').replace(/%20/g, '+');

}

function urlDecodeValue(str) {

    return decodeURIComponent((str + '').replace(/%(?![\da-f]{2})/gi, function() {

            return '%25';

        }).replace(/\+/g, '%20'));

}

//통합검색 페이지로 이동
function XFN_PortalUnifiedSearch(pType) {
    var l_SearchKeyword = (pType == 'Gadget') ? $("#txtGadgetUnifiedSearch").val() : $("#txtPortalUnifiedSearch").val();
    var l_URL = Common.getBaseConfig("PortalUnifiedSearchExternal");
    var l_queryString = (l_URL + encodeURIComponent(l_SearchKeyword)).split('?');
    var l_Params = "";
    var l_param = "";

    for (var i = 0; i < l_queryString[1].split('&').length; i++) {
        l_param = l_queryString[1].split('&')[i].split('=');
        if ( l_param[1].indexOf("@@") > -1){
            l_Params += "<input type=\"hidden\" id=\"" + l_param[0] + "\" name=\"" + l_param[0] + "\" value=\"" + XFN_ConvertVariableSession(l_param[1]) + "\"/>";
        	
        }else{
            l_Params += "<input type=\"hidden\" id=\"" + l_param[0] + "\" name=\"" + l_param[0] + "\" value=\"" + l_param[1] + "\"/>";
        }
    }

    if (Common.getBaseConfig("PortalUnifiedSearchType") == "T") {
        $(parent.document).find("body > form[id=\"PortalUnifiedSearchTypeForm\"]").remove();//기존에 생성한 form 제거 
        l_Params += "<input type=\"hidden\" name=\"S_CKEY\" />";
        var sform = "<form id=\"PortalUnifiedSearchTypeForm\" name=\"PortalUnifiedSearchTypeForm\" method=\"post\" target=\"PortalUnifiedSearchTypeForm\">" + l_Params + "</form>";
        $(parent.document).find("body").append(sform);//form 추가
        var oPortalUnifiedSearchTypeForm = parent.document.PortalUnifiedSearchTypeForm;
        if(coviCmn.getCookie("CSJTK") != null && coviCmn.getCookie("CSJTK") != undefined){
	        oPortalUnifiedSearchTypeForm.S_CKEY.value = coviCmn.getCookie("CSJTK").replaceAll("\"", "");
		}
        oPortalUnifiedSearchTypeForm.action = l_URL.substring(0, l_URL.indexOf('?'));
        oPortalUnifiedSearchTypeForm.submit();
    } else {
        location.href = Common.getBaseConfig("PortalUnifiedSearchInernal") + encodeURIComponent($("#txtPortalUnifiedSearch").val());
    }
}
function XFN_ConvertVariableSession(pSessionVar){
	return Common.getSession(pSessionVar.replace("@@",""));
}

//GMT+0를 GMT+9로 강제변경
//pServerTime - GMT0시간
//pLocalFormat - 임력하지 않으면 로컬 포멧으로 변환하여 반환함.
//pUrTimeZone - 사용자 타임존 값으로 입력하지 않으면 세션에서 조회
function CFN_TransLocalTime4GMT9(pServerTime, pLocalFormat, pUrTimeZone) {
	var l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS;  // 입력 년월일시분초
	var l_TimeZone, l_ZoneHH, l_ZoneMM, l_ZoneSS, l_Minus, l_UR_TimeZone;  // 타임존 시분초 +- 여부
	var l_StringDate, l_StringTime, l_DateFormat = "", l_DateFormatCount;  // 입력 날짜, 입력 시간, 입력날짜 형식, 입력한 값 길이
	 var l_ReturnString = "";
	var l_Use_TimeZone = "";
	 
	//pServerTime이 Date Object로 넘어올 경우 처리
	if(typeof pServerTime === "object") {
	 pServerTime = new Date(pServerTime.time).format("yyyy-MM-dd HH:mm:ss")
	}
	
	l_DateFormatCount = pServerTime.length;
	
	// 1. 날짜(2011-01-04)와 시간(09:12, 08:12:12)이 같이 들어와야 한다.
	if (pServerTime.indexOf(" ") == -1) {
	    if (pServerTime.length == 10) {
	        pServerTime += " 00:00:00";
	    } else {
	        return pServerTime;
	    }
	}
	
	l_StringDate = pServerTime.split(' ')[0]
	l_StringTime = pServerTime.split(' ')[1]
	
	// 2. 날짜 형식은 "-", ".", "/"을 받는다.
	// 입력 포멧 확인
	if (l_StringDate.indexOf(".") > -1) { l_DateFormat = "."; }
	if (l_StringDate.indexOf("-") > -1) { l_DateFormat = "-"; }
	if (l_StringDate.indexOf("/") > -1) { l_DateFormat = "/"; }
	
	if (l_DateFormat == "") {
	    return pServerTime;
	}
	l_StringDate = l_StringDate.replace(/-/g, "")
	l_StringDate = l_StringDate.replace(/\./g, "")
	l_StringDate = l_StringDate.replace(/\//g, "")
	l_StringTime = l_StringTime.replace(/:/g, "")
	
	// 3. 시간은 시분까지는 들어와야 한다.(초는 없어도 됨.)
	if (l_StringDate.length != 8 || l_StringTime.length < 4) {
	    return pServerTime;
	}
	
	// 형식에 맞게 숫자를 체워줌
	l_StringTime = CFN_PadRight(l_StringTime, 6, "0");
	
	// 입력받은 일시 분해
	l_InputYear = l_StringDate.substring(0, 4);
	l_InputMonth = l_StringDate.substring(4, 6) - 1; // 월은 1을 빼줘야 함.
	l_InputDay = l_StringDate.substring(6, 8);
	l_InputHH = l_StringTime.substring(0, 2);
	l_InputMM = l_StringTime.substring(2, 4);
	l_InputSS = l_StringTime.substring(4, 6);
	
	// 시간 형식 체크
	var l_InputDate = new Date(l_InputYear, l_InputMonth, l_InputDay, l_InputHH, l_InputMM, l_InputSS);
	if (l_InputDate.getFullYear() != l_InputYear || l_InputDate.getMonth() != l_InputMonth || l_InputDate.getDate() != l_InputDay ||
	    l_InputDate.getHours() != l_InputHH || l_InputDate.getMinutes() != l_InputMM || l_InputDate.getSeconds() != l_InputSS) {
	    return pServerTime;
	}
	
	l_Use_TimeZone = "Y";
	
	if( l_Use_TimeZone == "Y"){
	 // 자신의 타임존 시간 가져오기(세션에 정의된 타임존 값을 가져옴.)
   l_UR_TimeZone = "09:00:00";

   l_Minus = l_UR_TimeZone.substring(0, 1);
	 l_TimeZone = l_UR_TimeZone.replace("-", "").replace(":", "").replace(":", "");
	 l_ZoneHH = l_TimeZone.substring(0, 2);
	 l_ZoneMM = l_TimeZone.substring(2, 4);
	 l_ZoneSS = l_TimeZone.substring(4, 6);

	 var l_TimeZoneTime = (parseInt(l_ZoneHH, 10) * 3600000) + (parseInt(l_ZoneMM, 10) * 60000) + (parseInt(l_ZoneSS, 10) * 1000)

	 if (l_Minus == "-") {
	     l_InputDate.setTime(l_InputDate.getTime() - l_TimeZoneTime);
	 } else {
	     l_InputDate.setTime(l_InputDate.getTime() + l_TimeZoneTime);
	 }
	
	}    
	
	if (pLocalFormat == undefined || pLocalFormat == "") {
	    // 포멧을 지정하지 않을 경우 원래 요청한 (로컬 표준포멧의)형식으로 반환
	    pLocalFormat = "yyyy-MM-dd HH:mm:ss";
	    l_ReturnString = pLocalFormat
	    .replace("yyyy", CFN_PadLeft(l_InputDate.getFullYear(), 4, "0"))
	    .replace("MM", CFN_PadLeft(l_InputDate.getMonth() + 1, 2, "0"))
	    .replace("dd", CFN_PadLeft(l_InputDate.getDate(), 2, "0"))
	    .replace("HH", CFN_PadLeft(l_InputDate.getHours(), 2, "0"))
	    .replace("mm", CFN_PadLeft(l_InputDate.getMinutes(), 2, "0"))
	    .replace("ss", CFN_PadLeft(l_InputDate.getSeconds(), 2, "0"));
	    l_ReturnString = l_ReturnString.substr(0, l_DateFormatCount);
	}
	else // 사용자가 포멧을 지정하여 요청하면 요청한 데로 반환
	{
	    l_ReturnString = pLocalFormat
	    .replace("yyyy", CFN_PadLeft(l_InputDate.getFullYear(), 4, "0"))
	    .replace("MM", CFN_PadLeft(l_InputDate.getMonth() + 1, 2, "0"))
	    .replace("dd", CFN_PadLeft(l_InputDate.getDate(), 2, "0"))
	    .replace("HH", CFN_PadLeft(l_InputDate.getHours(), 2, "0"))
	    .replace("mm", CFN_PadLeft(l_InputDate.getMinutes(), 2, "0"))
	    .replace("ss", CFN_PadLeft(l_InputDate.getSeconds(), 2, "0"));
	}
	
	return l_ReturnString;
}

function  CFN_setDic(data){
	var pObj = $("#"+data.DicID);
	pObj.val(data.KoFull);
	if(pObj.attr("dic_src") != undefined){
		$('#'+pObj.attr("dic_src")).val(coviDic.convertDic(data))
	}
	Common.close(data.popupTargetID);
}


// 화면 사이즈 확대/축소(컨텐츠 레이어 내에서 사이즈 조정)
var AwsS3 = {
	isActive: function(){
		var s3AP_URL_val = Common.getGlobalProperties("s3.ap.url");
		if(s3AP_URL_val!=null && s3AP_URL_val!=""){
			var arrS3APurl = s3AP_URL_val.split(".");
			if(arrS3APurl.length==5) {
				var isActive = Common.getS3Properties(Common.getSession("DN_Code"));
				if (isActive != null && isActive === "Y") {
					return true;
				}
			}
		}
		return false;
	},
	getS3ApUrl: function (){
		return "/covicore/common/photo/photo.do?img=";
	}
}
var coviSec = {
	getHeader : function(plainText, aesType){
		let keySize= 128/32;
		let iterationCount = 1000;
		let salt = "18b00b2fc5f0e0ee40447bba4dabc123";
		let iv   = "4378110db6392f93e95d5159dabde123";

		let passPhrase  = Common.getSession('UR_PrivateKey');
		switch (aesType){
			case "SHA256":
				return sha256(plainText); 
			case "SHA":
				return sha512(plainText); 
			default:
				let key = CryptoJS.PBKDF2(
						passPhrase, 
						  CryptoJS.enc.Hex.parse(salt),
						  { keySize: keySize, iterations: iterationCount });
				let encrypted = CryptoJS.AES.encrypt(
					  plainText,
					  key,
					  { iv: CryptoJS.enc.Hex.parse(iv) });
	
				return encrypted.ciphertext.toString(CryptoJS.enc.Base64);
				
		}	
	}

}
// 통합검색 -------------- End

//로그인 CapsLock함수
function checkCapsLock(event){
	var msgValue = (dicData['msg_caps_lock'] != undefined) ? dicData['msg_caps_lock'] : 'Caps Lock이 켜져 있습니다';
	var parent = event.target.parentNode;
		
	var inner_box = document.createElement('p');
	inner_box.className = 'capslock_box';
	inner_box.innerHTML += msgValue;
	
	if(event instanceof KeyboardEvent == true){
	   if(event.getModifierState("CapsLock")){
			if($(".capslock_box").length < 1)
				parent.append(inner_box);     
	   }else{
			$(parent).find('.capslock_box').remove();
	   }
	}
}

/*
	Subject : 메일 발송
	MP 메일 발송 팝업 표시
	입력값 : JSON 데이터
	mailJson = {
		"Token": GetEncryptToken(), // 인증용 JWT 토큰
		"Subject": "", // 메일 제목
		"Body": "", // 메일 본문
		"To": [], // 받는 사람
		"Cc": [], // 참조
		"Bcc": [], // 숨은 참조
		"Attachment": [] // 첨부 파일
	};
*/
function exch_mailSend(mailJson){
			// 메일 SLO URL // 기초코드 
			var url = Common.getBaseConfig("Exch_mailSvcUrl") + "/WebSIte/Mail/MailWriteIF.aspx"; // form Action URL
			
			var formMailSend = document.createElement("form"); // 동적 form 생성
			
			// form 세팅
			formMailSend.setAttribute("charset", "UTF-8");
			formMailSend.setAttribute("id", "formMailSend");
			formMailSend.setAttribute("method", "Post");  //Post 방식
			formMailSend.setAttribute("action", url); //요청 보낼 주소
			formMailSend.setAttribute("target", "MailWritePopup"); //대상
			
			var SendJsonData = JSON.stringify(MailJsonData); //전송데이터 String 변환
			
			// 전송 데이터 Field 세팅
			var hiddenField = document.createElement("input");
			hiddenField.setAttribute("type", "hidden");
			hiddenField.setAttribute("name", "SendJsonData");
			hiddenField.setAttribute("value", SendJsonData);
			
			formMailSend.appendChild(hiddenField);
			
			document.body.appendChild(formMailSend); // 크롬에서 동적 생성 form을 전송할 수 없어 추가
			
			// form 실행시 열리는 새창 세팅
			window.open("","MailWritePopup", "height=800, width=1000, resizable=yes");
			
			formMailSend.submit(); // form 실행
	
}

/*
Subject : Token 발급 
Method : GetEncryptToken
jwt 토큰 발급 common/jwtToken.do 호출
*/
function GetEncryptToken() {
	var token;
		$.ajax({
			type: "GET",
			async: false,
			url: "/covicore/common/jwtToken.do",
			success: function(data) {
				token = data.JWTtoken;
			}
		}); 
	return token;
}

function XFN_addWindowOpenList(pWinOpenUrl, pWinOpenName) {
	try {
		var winOpenData = {
			url: pWinOpenUrl,
			name: pWinOpenName
		};
		var windowOpenDataList = [];
		var windowOpenDataStr = localStorage.getItem("windowOpenList");
		if(windowOpenDataStr){
			windowOpenDataList = JSON.parse(windowOpenDataStr);
		}
		windowOpenDataList.push(winOpenData);

		// openWin 창의 정보를 로컬 스토리지에 저장
		localStorage.setItem("windowOpenList", JSON.stringify(windowOpenDataList));
	} catch (e) {
		coviCmn.traceLog(e);
	}
}

function XFN_removeWindow(pWinOpenName) {
	try {
		var windowOpenDataList = [];
		var windowOpenDataStr = localStorage.getItem("windowOpenList");
		if(windowOpenDataStr){
			$.each(JSON.parse(windowOpenDataStr), function(idx, el){
				if (el.name != pWinOpenName) {
					windowOpenDataList.push(el);
				}
			});
		}
		localStorage.setItem("windowOpenList", JSON.stringify(windowOpenDataList));
	} catch (e) {
		coviCmn.traceLog(e);
	}
}

function XFN_closeWindowOpenList() {
	try{
		var windowOpenList = localStorage.getItem("windowOpenList");

		if(windowOpenList){
			var windowList = JSON.parse(windowOpenList);
			$.each(windowList, function(idx, el){
				var openWin = window.open(el.url, el.name);
				
				if (openWin && !openWin.closed) {
					openWin.close();
				}
			})

			localStorage.removeItem("windowOpenList");
		}
	} catch (e) {
		coviCmn.traceLog(e);
	}
}