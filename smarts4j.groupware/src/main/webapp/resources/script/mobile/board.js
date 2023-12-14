/*!
 * 
 * 
 * SmartS4j / MobileOffice / 모바일 게시 js 파일
 * 함수명 : mobile_board_...
 * 
 * 
 */

/*!
 * 
 * 페이지별 init 함수
 * 
 */

//게시 목록 페이지
$(document).on('pageinit', '#board_list_page', function () {	
	if($("#board_list_page").attr("IsLoad") != "Y"){
		delete sessionStorage.mobileBoardType;
		delete sessionStorage.mobileBoardSelectedFDType;
		delete sessionStorage.mobileBoardSelectedFDID;
		delete sessionStorage.mobileBoardSearchText;

		$("#board_list_page").attr("IsLoad", "Y");
		setTimeout("mobile_board_ListInit()",10);
	}
});

//게시 상세보기 페이지
$(document).on('pageinit', '#board_view_page', function () {	
	if($("#board_view_page").attr("IsLoad") != "Y"){
		$("#board_view_page").attr("IsLoad", "Y");
		setTimeout("mobile_board_ViewInit()",10);
		setTimeout("mobile_comm_showwatermark()",10);	
	}
});

//게시 작성 페이지
$(document).on('pageinit', '#board_write_page', function () {
	if($("#board_write_page").attr("IsLoad") != "Y"){
		$("#board_write_page").attr("IsLoad", "Y");
		setTimeout("mobile_board_WriteInit()",10);
	}	
});

//조회자 목록 페이지
$(document).on('pageinit', '#board_viewer_page', function () {
	if($("#board_viewer_page").attr("IsLoad") != "Y"){
		$("#board_viewer_page").attr("IsLoad", "Y");
		setTimeout("mobile_board_ViewerInit()",10);
	}
});

//문서관리 목록 페이지
$(document).on('pageinit', '#doc_list_page', function () {	
	if($("#doc_list_page").attr("IsLoad") != "Y"){
		delete sessionStorage.mobileBoardType;
		delete sessionStorage.mobileBoardSelectedFDType;
		delete sessionStorage.mobileBoardSelectedFDID;
		delete sessionStorage.mobileBoardSearchText;
		
		$("#doc_list_page").attr("IsLoad", "Y");
		setTimeout("mobile_board_ListInit()",10);
	}
});

//문서관리 상세보기 페이지
$(document).on('pageinit', '#doc_view_page', function () {
	if($("#doc_view_page").attr("IsLoad") != "Y"){
		$("#doc_view_page").attr("IsLoad", "Y");
		setTimeout("mobile_doc_ViewInit()",10);
	}	
});

//문서관리 작성 페이지
$(document).on('pageinit', '#doc_write_page', function (e) {
	if($("#doc_write_page").attr("IsLoad") != "Y"){
		$("#doc_write_page").attr("IsLoad", "Y");
		setTimeout("mobile_doc_WriteInit()",10);
	}
});

//문서관리 권한 요청/승인 페이지
$(document).on('pageinit', '#doc_auth_page', function () {
	if($("#doc_auth_page").attr("IsLoad") != "Y"){
		$("#doc_auth_page").attr("IsLoad", "Y");
		setTimeout("mobile_doc_AuthInit()",10);
	}	
});



var _mobile_board_config = null;
var _mobile_message_config = null;
var g_editorBody = ""; //본문 내용, 에디터 바인딩 시점 문제 해결을 위한 변수



/*!
 * 
 * 게시 목록
 * 
 */


var _mobile_board_list = {
	
	// 리스트 조회 초기 데이터
	MenuID: '',			//메뉴ID-없으면 BoardMain의 기초설정값에서 조회
	BizSection: '',		//메뉴 Code
	BoardType: '',		//boardType-Total/Approval 등등
	BoxType: '',		//boxType-Receive/Request/Distribute 등등
	FolderID: '',		//폴더ID-없으면 전체 조회
	FolderType: '',		//폴더type-Board/Notice/File/Album 등등
	Page: 1,			//조회할 페이지
	PageSize: 10,		//페이지당 건수
	sortColumn: "",			//정렬 컬럼
	sortDirection: "desc",	//정렬 방향
	SearchText: '',		//검색어
	WriteYN: 'N',		//작성권한. 기본은 N //TODO: 권한처리
	CategoryGubun: '',	//카테고리(분류) 사용 여부
	CategoryID: '',		//카테고리(분류) 선택 정보
	
	// 페이징을 위한 데이터
	Loading: false,		//데이터 조회 중
	TotalCount: -1,		//전체 건수
	RecentCount: 0,		//현재 보여지는 건수
	EndOfList: false,	//전체 리스트를 다 보여줬는지
	
	//스크롤 위치 고정
	OnBack: false,		//뒤로가기로 왔을 경우
	Scroll: 0,			//스크롤 위치
	
	//커뮤니티
	CU_ID: '',		//커뮤니티 ID
	IsCommunity: 'N',	//커뮤니티용 게시판 여부
	
	//연결문서
	ListMode: "normal"  //문서관리 목록 Mode(normal: 일반 리스트, docLinked: 문서연결 리스트)
	
};

function mobile_board_ListInit(){
	
	// 1. 파라미터 셋팅
	if(mobile_comm_getQueryString('menucode') != 'undefined') {
		_mobile_board_list.MenuCode = mobile_comm_getQueryString('menucode');
	}

	if (mobile_comm_getQueryString('menuid') != 'undefined') {
		_mobile_board_list.MenuID = mobile_comm_getQueryString('menuid');
    } else {
    	if(mobile_comm_getQueryString('menucode') != 'undefined') {
    		_mobile_board_list.MenuID = mobile_comm_getBaseConfig(mobile_comm_getQueryString('menucode'), mobile_comm_getSession("DN_ID"));
    	}
    }
	if (mobile_comm_getQueryString('menucode') != 'undefined' && mobile_comm_getQueryString('menucode').indexOf("Main") > -1) {
		_mobile_board_list.BizSection = mobile_comm_getQueryString('menucode').replace("Main", "");
	} else {
		_mobile_board_list.BizSection = 'Board';
	}
	
	if(window.sessionStorage.getItem("mobileBoardType") != undefined && window.sessionStorage.getItem("mobileBoardType") != "") {
		_mobile_board_list.BoardType = window.sessionStorage.getItem("mobileBoardType");
	} else {
		if (mobile_comm_getQueryString('boardtype') != 'undefined') {
			_mobile_board_list.BoardType = mobile_comm_getQueryString('boardtype');
		} else {
			if(_mobile_board_list.BizSection == "Board")
				_mobile_board_list.BoardType = 'Total';
			else if(_mobile_board_list.BizSection == "Doc")
				_mobile_board_list.BoardType = 'CheckIn';
		}
	}
	
	if (mobile_comm_getQueryString('boxtype') != 'undefined' && mobile_comm_getQueryString('boxtype') != '') {
		_mobile_board_list.BoxType = mobile_comm_getQueryString('boxtype');
	} else {
		_mobile_board_list.BoxType = (['Approval','DocAuth','DistributeDoc'].indexOf(_mobile_board_list.BoardType) > -1) ? 'Receive' : '';
	}
	
	if (mobile_comm_getQueryString('folderid') != 'undefined') {
		_mobile_board_list.FolderID = mobile_comm_getQueryString('folderid');
    } else {
    	if(window.sessionStorage.getItem("mobileBoardSelectedFDID") != undefined && window.sessionStorage.getItem("mobileBoardSelectedFDID") != "") {
    		_mobile_board_list.FolderID = window.sessionStorage.getItem("mobileBoardSelectedFDID");
		} else {
			_mobile_board_list.FolderID = '';
		}
    }
	if (mobile_comm_getQueryString('foldertype') != 'undefined') {
		_mobile_board_list.FolderType = mobile_comm_getQueryString('foldertype');
	} else {
		if(window.sessionStorage.getItem("mobileBoardSelectedFDType") != undefined && window.sessionStorage.getItem("mobileBoardSelectedFDType") != "") {
    		_mobile_board_list.FolderType = window.sessionStorage.getItem("mobileBoardSelectedFDType");
		} else {
			_mobile_board_list.FolderType = '';
		}
	}
	if (mobile_comm_getQueryString('page') != 'undefined') {
		_mobile_board_list.Page = mobile_comm_getQueryString('page');
    } else {
    	_mobile_board_list.Page = 1;
    }
	if (mobile_comm_getQueryString('searchtext') != 'undefined') {
		_mobile_board_list.SearchText = mobile_comm_getQueryString('searchtext');
    } else {
    	if(window.sessionStorage.getItem("mobileBoardSearchText") != undefined && window.sessionStorage.getItem("mobileBoardSearchText") != "") {
    		_mobile_board_list.SearchText = window.sessionStorage.getItem("mobileBoardSearchText");
    		$('#mobile_search_input').val(_mobile_board_list.SearchText)
    		mobile_comm_opensearch();
		} else {
			_mobile_board_list.SearchText = '';
		}
    }
	if (mobile_comm_getQueryString('onback') != 'undefined') {
		_mobile_board_list.OnBack = mobile_comm_getQueryString('onback');
    } else {
    	_mobile_board_list.OnBack = false;
    }
	if (mobile_comm_getQueryString('scroll') != 'undefined') {
		_mobile_board_list.Scroll = mobile_comm_getQueryString('scroll');
    } else {
    	_mobile_board_list.Scroll = 0;
    }
	if (mobile_comm_getQueryString('cuid') != 'undefined') {
		_mobile_board_list.CU_ID = mobile_comm_getQueryString('cuid');
    } else {
    	_mobile_board_list.CU_ID = '';
    }
	if (mobile_comm_getQueryString('iscommunity') != 'undefined') {
		_mobile_board_list.IsCommunity = mobile_comm_getQueryString('iscommunity');
		if(_mobile_board_list.IsCommunity == 'Y'){
			_mobile_board_list.MenuID = _mobile_board_list.CU_ID;
			_mobile_board_list.BizSection = 'Community';
		}
    } else {
    	_mobile_board_list.IsCommunity = 'N';
    }
	if(window.sessionStorage.getItem("doc_isDocLinked") != null && window.sessionStorage.getItem("doc_isDocLinked") != "" && window.sessionStorage.getItem("doc_isDocLinked") == "Y") {
		_mobile_board_list.ListMode = "docSelect";
		_mobile_board_list.BoardType = "Total";
		_mobile_board_list.BizSection = "Doc";
		$("#board_list_header_normal").hide();
		$("#board_list_header_docSelect").show();
		$("#board_list_header").children("a").remove(); //이상한 a 태그가 추가되는 현상 임시 조치
	} else {
		_mobile_board_list.ListMode = "normal";
		$("#board_list_header_normal").show();
		$("#board_list_header_docSelect").hide();
	}
	
	_mobile_board_list.CategoryID = '';
	_mobile_board_list.TotalCount = -1;
	_mobile_board_list.RecentCount = 0;
	_mobile_board_list.EndOfList = false;
	
	if(_mobile_board_list.ListMode == "normal") {
		//TODO: 뒤로가기로 왔을 경우 파라미터 처리
		try {
			var arrHistoryData = new Array();
			try {
		        JSON.parse(window.sessionStorage["mobile_history_data"]).length;
		        arrHistoryData = JSON.parse(window.sessionStorage.getItem("mobile_history_data"));
		    } catch (e) {
		    	arrHistoryData = new Array();
		    }
			if(arrHistoryData.length > 0) {
				
				var prev = arrHistoryData[parseInt(window.sessionStorage["mobile_history_index"])];
				
				var tmpUrl = "/groupware/mobile/" + _mobile_board_list.BizSection.toLowerCase();
				if(prev.indexOf(tmpUrl + "/view.do") > -1 || prev.indexOf(tmpUrl + "/write.do") > -1 || prev.indexOf(tmpUrl + "/auth.do") > -1) {
					(mobile_comm_getQueryStringForUrl(prev, 'boardtype') != "undefined") ? _mobile_board_list.BoardType = mobile_comm_getQueryStringForUrl(prev, 'boardtype'):"";
					(mobile_comm_getQueryStringForUrl(prev, 'folderid') != "undefined") ? _mobile_board_list.FolderID = mobile_comm_getQueryStringForUrl(prev, 'folderid'):"";
					(mobile_comm_getQueryStringForUrl(prev, 'page') != "undefined") ? _mobile_board_list.Page = mobile_comm_getQueryStringForUrl(prev, 'page'):"";
					(mobile_comm_getQueryStringForUrl(prev, 'searchtext') != "undefined") ? _mobile_board_list.SearchText = mobile_comm_getQueryStringForUrl(prev, 'searchtext'):"";
					(mobile_comm_getQueryStringForUrl(prev, 'cuid') != "undefined") ? _mobile_board_list.CU_ID = mobile_comm_getQueryStringForUrl(prev, 'cuid'):"";
					(mobile_comm_getQueryStringForUrl(prev, 'iscommunity') != "undefined") ? _mobile_board_list.IsCommunity = mobile_comm_getQueryStringForUrl(prev, 'iscommunity'):"";
					(mobile_comm_getQueryStringForUrl(prev, 'foldertype') != "undefined") ? _mobile_board_list.FolderType = mobile_comm_getQueryStringForUrl(prev, 'foldertype'):"";
					_mobile_board_list.OnBack = true;
					
					if(mobile_comm_getQueryStringForUrl(prev, 'boardtype') != "undefined" && _mobile_board_list.BoardType.toUpperCase() == "TOTAL") {
						_mobile_board_list.FolderID = "";
					}
					
					if(parseInt(window.sessionStorage["mobile_history_index"]) < arrHistoryData.length) {
						arrHistoryData = arrHistoryData.splice(0, parseInt(window.sessionStorage["mobile_history_index"]));
						window.sessionStorage["mobile_history_data"] = JSON.stringify(arrHistoryData);
					}
				}
			}
		} catch(e) {mobile_comm_log(e);
		}
		
		var menuName; 
		$.each(menudata, function(idx, el){
			if (el.MenuID == _mobile_board_list.MenuID) menuName = CFN_GetDicInfo(el.MultiDisplayName);
		});
		if (menuName != '') $(".LsubTitle").text(menuName);
				
		// 2. 상단메뉴			
		//검색어 초기화
		/*$('#mobile_search_input').val('');
		_mobile_board_list.SearchText = '';*/

		//커뮤니티가 아닌 경우
		if(_mobile_board_list.IsCommunity == "N"){
			
			// 좌측메뉴 표시 (기본 게시&커스텀메뉴 모두 동일하고 트리만 다름)
			//$('#board_list_topmenu').html(mobile_board_getTopMenuHtml(BoardMenu));	//BoardMenu - 서버에서 넘겨주는 좌측메뉴 목록
			$('#board_list_topmenu').html(mobile_board_getTopMenuHtml(BoardMenu));	//BoardMenu - 서버에서 넘겨주는 좌측메뉴 목록
			
			// 게시판 목록 트리 조회 및 표시
			mobile_board_getTreeData(_mobile_board_list, 'LIST');
		} else {
			$('#board_list_topmenu').html(mobile_community_makeHomeTreeList(_mobile_board_list))
			.removeClass().addClass("h_tree_menu_wrap").addClass("comm_menu").attr("style", "");	//BoardMenu - 서버에서 넘겨주는 좌측메뉴 목록			
		}

		// 게시판 환경설정 조회
		mobile_board_getBoardConfig(_mobile_board_list.FolderID);
		
		// Category(분류) 사용 여부 확인 및 값 바인딩
		mobile_board_setBoardCategory(_mobile_board_config.UseCategory, _mobile_board_list.FolderID, 'board_list_category');

		// 3. 글 목록 조회
		mobile_board_getList(_mobile_board_list);

	} else {
		// 3. 글 목록 조회	
		$("#board_list_category").hide();
		mobile_doc_getLinkedList(_mobile_board_list);	 
	}
}

//상단메뉴(PC 좌측메뉴) 그리기
function mobile_board_getTopMenuHtml(boardmenu) {
	var sHtml = "";
	var nSubLength = 0;
	var sALink = "";
	var sLeftMenuID = "";
	var sClass = "";
	
	sHtml += "<ul class=\"h_tree_menu_wrap\">";
	$(boardmenu).each(function (i, data){
		
		nSubLength = data.Sub.length;
		
		sALink = "";
		
		var boardtype = mobile_comm_getQueryStringForUrl(data.MobileURL, 'boardtype');
		
		if(_mobile_board_list.BizSection == "Board"){
			sHtml += "<li boardtype=\"" + boardtype + "\" displayname=\"" + data.DisplayName + "\">";
			sHtml += "    <div class=\"h_tree_menu\">";
			if(nSubLength > 0) {
				sALink = "javascript: mobile_board_openclose('li_sub_" + data.MenuID + "', 'span_menu_" + data.MenuID + "');";
				
				switch(boardtype){
				case "Approval": sClass="t_ico_app"; break;
				case "DocAuth": sClass="t_ico_lock"; break;
				case "DistributeDoc": sClass="t_ico_bapo"; break;
				default: sClass="t_ico_my";break;
				}
				
				sHtml += "    <ul class=\"h_tree_menu_list\">";
				sHtml += "        <li>";
				sHtml += "            <a href=\"" + sALink + "\" class=\"t_link not_tree\">";//TODO: 링크 처리
				sHtml += "                <span id=\"span_menu_" + data.MenuID + "\" class=\"t_ico_open\"></span><span class=\"" + sClass + "\"></span>";//TODO: t_ico_app 클래스 처리
				sHtml += "                " + data.DisplayName;
				sHtml += "            </a>";
				sHtml += "        </li>";
				sHtml += "    </ul>";
			} else {
				sALink = "javascript: mobile_board_ChangeMenu('" + mobile_comm_getQueryStringForUrl(data.MobileURL, 'boardtype') + "');";
				
				sHtml += "    <a href=\"" + sALink + "\" class=\"t_link\">";//TODO: 링크 처리
				sHtml += "        <span class=\"t_ico_doc\"></span>";//TODO: 클래스 처리
				sHtml += "        " + data.DisplayName;
				sHtml += "    </a>";
			}
			sHtml += "    </div>";
			sHtml += "</li>";
			
			if(nSubLength > 0) {
				sHtml += "<li id=\"li_sub_" + data.MenuID + "\">";
				sHtml += "    <ul class=\"sub_list\">";
				$(data.Sub).each(function (j, subdata){
					
					sClass = "t_ico_board";
					sALink = "javascript: mobile_board_ChangeMenu('" + mobile_comm_getQueryStringForUrl(subdata.MobileURL, 'boardtype') + "');";
					
					sHtml += "    <li boardtype=\"" + mobile_comm_getQueryStringForUrl(subdata.MobileURL, 'boardtype') + "\" displayname=\"" + subdata.DisplayName + "\">";
					sHtml += "        <a href=\"" + sALink + "\" class=\"t_link\">";//TODO: 링크 처리
					sHtml += "            <span class=\"" + sClass + "\"></span>";
					sHtml += "            " + subdata.DisplayName;
					sHtml += "        </a>";
					sHtml += "    </li>";
				});
				sHtml += "    </ul>";
				sHtml += "</li>";
			}
			
			//게시 - 승인요청
			if (boardtype == "Approval") {
				sHtml += "<li id=\"li_sub_" + data.MenuID + "\">";
				sHtml += "    <ul class=\"sub_list\">";
				sHtml += "			<li tabtype=\"Receive\" displayname=\"" + mobile_comm_getDic("lbl_doc_approvalBox") + "\">";
				sHtml += "				<a href=\"javascript: mobile_board_ChangeMenu('" + boardtype + "', 'Receive');\" class=\"t_link\">";
				sHtml += "					<span class=\"t_ico_board\"></span> " + mobile_comm_getDic("lbl_doc_approvalBox");
				sHtml += "				</a>";
				sHtml += "			</li>";
				sHtml += "			<li tabtype=\"Request\" displayname=\"" + mobile_comm_getDic("lbl_doc_requestBox") + "\">";
				sHtml += "				<a href=\"javascript: mobile_board_ChangeMenu('" + boardtype + "', 'Request');\" class=\"t_link\">";
				sHtml += "					<span class=\"t_ico_board\"></span> " + mobile_comm_getDic("lbl_doc_requestBox");
				sHtml += "				</a>";
				sHtml += "			</li>";
				sHtml += "    </ul>";
				sHtml += "</li>";
			}
		} else {
			sHtml += "<li boardtype=\"" + boardtype + "\" displayname=\"" + data.DisplayName + "\">";
			
			if(nSubLength > 0) {
				sALink = "javascript: mobile_board_openclose('ul_sub_" + data.MenuID + "', 'span_menu_" + data.MenuID + "');";
				sClass = "t_ico_my";
				
				sHtml += "    <ul class=\"h_tree_menu_list\">";
				sHtml += "        <li>";
				sHtml += "            <a href=\"" + sALink + "\" class=\"t_link not_tree\">";//TODO: 링크 처리
				sHtml += "                <span id=\"span_menu_" + data.MenuID + "\" class=\"t_ico_open\"></span><span class=\"" + sClass + "\"></span>";//TODO: t_ico_app 클래스 처리
				sHtml += "                " + data.DisplayName;
				sHtml += "            </a>";
				sHtml += "            <ul id=\"ul_sub_" + data.MenuID + "\" class=\"sub_list\">";
				$(data.Sub).each(function (j, subdata){
					sClass = "t_ico_docboard";
					sALink = "javascript: mobile_board_ChangeMenu('" + mobile_comm_getQueryStringForUrl(subdata.MobileURL, 'boardtype') + "');";
					
					sHtml += "    <li boardtype=\"" + mobile_comm_getQueryStringForUrl(subdata.MobileURL, 'boardtype') + "\" displayname=\"" + subdata.DisplayName + "\">";
					sHtml += "        <a href=\"" + sALink + "\" class=\"t_link\">";//TODO: 링크 처리
					sHtml += "            <span class=\"" + sClass + "\"></span>";
					sHtml += "            " + subdata.DisplayName;
					sHtml += "        </a>";
					sHtml += "    </li>";
				});
				sHtml += "            </ul>";
				sHtml += "        </li>";
				sHtml += "    </ul>";
			} else {
				
				sALink = "";
				if("|DistributeDoc|Approval|DocAuth|".indexOf(boardtype) < 0) {
					sALink = "javascript: mobile_board_ChangeMenu('" + mobile_comm_getQueryStringForUrl(data.MobileURL, 'boardtype') + "');";
				}
				
				sHtml += "    <a href=\"" + sALink + "\" class=\"t_link\">";//TODO: 링크 처리
				sHtml += "        <span class=\"t_ico_doc\"></span>";//TODO: 클래스 처리
				sHtml += "        " + data.DisplayName;
				sHtml += "    </a>";
			}									
			
			if(boardtype == "DistributeDoc") {
				sHtml += "<li id=\"li_sub_" + data.MenuID + "\">";
				sHtml += "    <ul class=\"sub_list\">";
				sHtml += "		<li tabtype=\"Receive\" displayname=\"" + mobile_comm_getDic("lbl_apv_doc_receive") + "\">"; //수신함
				sHtml += "			<a href=\"javascript: mobile_board_ChangeMenu('" + boardtype + "', 'Receive');\" class=\"t_link\">";
				sHtml += "				<span class=\"t_ico_docboard\"></span> " + mobile_comm_getDic("lbl_apv_doc_receive");
				sHtml += "			</a>";
				sHtml += "		</li>";
				sHtml += "		<li tabtype=\"Distribute\" displayname=\"" + mobile_comm_getDic("lbl_apv_Distribute2") + "\">"; //배포함
				sHtml += "			<a href=\"javascript: mobile_board_ChangeMenu('" + boardtype + "', 'Distribute');\" class=\"t_link\">";
				sHtml += "				<span class=\"t_ico_docboard\"></span> " + mobile_comm_getDic("lbl_apv_Distribute2");
				sHtml += "			</a>";
				sHtml += "		</li>";
				sHtml += "    </ul>";
				sHtml += "</li>";
			} else if (boardtype == "Approval" || boardtype == "DocAuth") {
				sHtml += "<li id=\"li_sub_" + data.MenuID + "\">";
				sHtml += "    <ul class=\"sub_list\">";
				sHtml += "		<li tabtype=\"Receive\" displayname=\"" + mobile_comm_getDic("lbl_doc_approvalBox") + "\">"; //승인함
				sHtml += "			<a href=\"javascript: mobile_board_ChangeMenu('" + boardtype + "', 'Receive');\" class=\"t_link\">";
				sHtml += "				<span class=\"t_ico_docboard\"></span> " + mobile_comm_getDic("lbl_doc_approvalBox");
				sHtml += "			</a>";
				sHtml += "		</li>";
				sHtml += "		<li tabtype=\"Request\" displayname=\"" + mobile_comm_getDic("lbl_doc_requestBox") + "\">"; //요청함
				sHtml += "			<a href=\"javascript: mobile_board_ChangeMenu('" + boardtype + "', 'Request');\" class=\"t_link\">";
				sHtml += "				<span class=\"t_ico_docboard\"></span> " + mobile_comm_getDic("lbl_doc_requestBox");
				sHtml += "			</a>";
				sHtml += "		</li>";
				sHtml += "    </ul>";
				sHtml += "</li>";
			}
			sHtml += "</li>";	
		}
				
	});
	sHtml += "</ul>";
	
	return sHtml;
}

//트리 조회
function mobile_board_getTreeData(params, mode) {
	var bizSection = params.BizSection;
	if(bizSection == undefined) {
		bizSection = location.pathname.split("/")[3];
		bizSection = bizSection.charAt(0).toUpperCase() + bizSection.slice(1);
	}
	
	var url = "/groupware/mobile/board/getTreeData.do";
	if(mode.toUpperCase() == "WRITE") {
		url = "/groupware/mobile/board/selectBoardList.do";
	}
	if(bizSection == "Community"){
		bizSection = "Board";
		$("#board_write_folder").attr("disabled",true);
	}
	var paramdata = {
		communityID : params.CU_ID,
		menuID : params.MenuID,
		bizSection : bizSection,
		menuCode : mobile_comm_getQueryString('menucode')
	};
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		async: false,
		success: function (response) {
			if(response.status == "SUCCESS") {
				if(bizSection == "Board" || bizSection == "Community") {
					if(mode.toUpperCase() == "LIST") {
						$('#board_list_topmenu').find("li").filter(":eq(0)").after(mobile_board_getTopTreeHtml(response.treedata, 'FolderType', 'Root', 'MemberOf', ''));		
					} else if(mode.toUpperCase() == "WRITE") {
						$('#board_write_folder').html(mobile_board_SelFolderBinding(response.treedata, bizSection));
					}
				} else {
					if(mode.toUpperCase() == "LIST") {
						$('#board_list_topmenu').find("li").filter(":eq(0)").after(mobile_board_getTopTreeHtml(response.treedata, 'FolderType', 'Root', 'MemberOf', ''));
					} else if(mode.toUpperCase() == "WRITE") {
						$('#doc_write_folder').html(mobile_board_SelFolderBinding(response.treedata, bizSection));
					}
				}
				
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//트리 그리기
function mobile_board_getTopTreeHtml(pData, pRootNode, pRootValue, pParentNode, pParentValue) {
	
	//pData - 트리 전체 데이터 Array
	//pRootNode - 루트 여부 확인하는 node명
	//pRootValue - pRootNode가 이 값인게 루트
	//pParentNode - 상위 여부 확인하는 node명
	//pParentValue - pParentNode가 이 값임을 확인하여 sub 노드를 조회
	
	//루트를 조회
	var arrRoot = new Array();
	try {
		var cnt = pData.length;
		for(var i = 0; i < cnt; i++) {
			if(pData[i][pRootNode] == pRootValue) {
				arrRoot.push(pData[i]);
			}
		}
	} catch(e) {
		arrRoot = null;
	}
	
	var sHtml = "";
	
	var iDepth = 0;
	var sALink = "";
	sHtml += "<li>";
	sHtml += "    <div class=\"h_tree_menu_list\">";
	$(arrRoot).each(function (j, root) {
		sALink = "javascript: mobile_board_openclose('ul_sub_" + root.FolderID + "', 'span_menu_" + root.FolderID + "');";
		
		sHtml += "<ul class=\"h_tree_menu_list\">";
		sHtml += "    <li>";
		sHtml += "        <a href=\"" + sALink + "\" class=\"t_link\"><span id=\"span_menu_" + root.FolderID + "\" class=\"t_ico_open\"></span>" + root.DisplayName + "</a>";
		sHtml += mobile_board_getTopTreeHtmlRecursive(pData, pParentNode, root.FolderID, iDepth + 1);
		sHtml += "    </li>";
		sHtml += "</ul>";
	});
	sHtml += "    </div>";
	sHtml += "</li>";
	
	return sHtml;
}

function mobile_board_getTopTreeHtmlRecursive(pData, pParentNode, pParentValue, pDepth) {
	
	var sHtml = "";
	
	if(pData == null) {
		return sHtml;
	}
	
	var arrSub = new Array();
	try {
		var cnt = pData.length;
		for(var i = 0; i < cnt; i++) {
			if(pData[i][pParentNode] == pParentValue) {
				arrSub.push(pData[i]);
			}
		}
	} catch(e) {
		arrSub = null;
	}
	
	var sClass = "t_ico_board";
	var sALink = "";
	
	sHtml += "<ul id=\"ul_sub_" + pParentValue + "\" class=\"sub_list\">";
	$(arrSub).each(function (j, sub) {
		
		// TODO : 모바일에서 지원안하는 게시 타입을 기초 설정으로 관리 필요(일정형 게시, 한줄 게시 지원 안함) 
		if(sub.FolderType == "Calendar" || sub.FolderType == "QuickComment")
			return sub.FolderType;
		
		sClass = (_mobile_board_list.BizSection == "Doc" ? "t_ico_docboard" : "t_ico_board");
		sALink = "javascript: mobile_board_ChangeFolder('" + sub.FolderID + "', '" + sub.FolderType + "');";
		
		if(sub.FolderType.toUpperCase() == "FOLDER") {
			sClass = "t_ico_open";
			sALink = "javascript: mobile_board_openclose('ul_sub_" + sub.FolderID + "', 'span_menu_" + sub.FolderID + "');";
		}
		
		sHtml += "    <li folderid=\"" + sub.FolderID + "\" displayname=\"" + sub.DisplayName + "\">";
		sHtml += "        <a href=\"" + sALink + "\" class=\"t_link\"><span id=\"span_menu_" + sub.FolderID + "\" class=\"" + sClass + "\"></span>" + sub.DisplayName + "</a>";
		sHtml += mobile_board_getTopTreeHtmlRecursive(pData, pParentNode, sub.FolderID, pDepth + 1);
		sHtml += "    </li>";
	});
	sHtml += "</ul>";
	
	return sHtml;
	
}

//상단 메뉴명 셋팅
function mobile_board_getTopMenuName() {
	
	var sTopMenu = "";
	
	if(_mobile_board_list.FolderID == "") {
		sTopMenu = $("#board_list_topmenu li[boardtype=" + _mobile_board_list.BoardType + "]").attr("displayname");
		
		if (['Approval','DocAuth','DistributeDoc'].indexOf(_mobile_board_list.BoardType) > -1 && _mobile_board_list.BoxType != "") {
			sTopMenu += ' - ' + $("#board_list_topmenu li[boardtype="+_mobile_board_list.BoardType+"]").next().find(".sub_list li[tabtype="+_mobile_board_list.BoxType+"]").attr("displayname");
		}
	} else {
		sTopMenu = $("#board_list_topmenu").find("li[folderid=" + _mobile_board_list.FolderID + "]").attr("displayname");
	}
	
	$('#board_list_title').html("<span class=\"Tit\">"+ sTopMenu + "</span>");
}

//하위 메뉴/트리 열고 닫기
function mobile_board_openclose(liId, iconId) {
	if($('#' + iconId).hasClass('t_ico_open')){		
		$('#' + iconId).removeClass('t_ico_open').addClass('t_ico_close');				
		$('#' + liId).hide();
	} else {	
		$('#' + iconId).removeClass('t_ico_close').addClass('t_ico_open');
		$('#' + liId).show();
	}
}
function mobile_board_Change(boardType,cuid){	
	var sUrl = "/groupware/mobile/board/list.do";

	if(location.href.indexOf(sUrl) > -1){
		mobile_board_ChangeFolder('', '', boardType);
	}else{
		sUrl += "?menucode=BoardMain";
		sUrl += "&cuid=" + cuid;
		sUrl += "&iscommunity=Y";
		sUrl += "&boardtype="+boardType;
	
		mobile_comm_go(sUrl);
	}
}
//메뉴 변경
function mobile_board_ChangeMenu(boardType, boxType) {	
	if(boardType == undefined || boardType == 'undefined' || boardType == '') {
		boardType = "Total";
	}
	
	mobile_board_ChangeFolder('', '', boardType, boxType);
}

//게시판 변경
function mobile_board_ChangeFolder(folderID, folderType, boardType, boxType) {	
	if(boardType == undefined || boardType == 'undefined' || boardType == '') {
		boardType = "Normal";
	}
	if(boxType == undefined || boxType == 'undefined') {
		boxType = '';
	}
	
	window.sessionStorage.setItem("mobileBoardSelectedFDID", folderID);
	window.sessionStorage.setItem("mobileBoardSelectedFDType", folderType);
	window.sessionStorage.setItem("mobileBoardType", boardType);
	window.sessionStorage.setItem("mobileBoardSearchText", "");
		
	_mobile_board_list.BoardType = boardType;
	_mobile_board_list.BoxType = boxType;
	_mobile_board_list.FolderID = folderID;
	_mobile_board_list.FolderType = folderType;
	_mobile_board_list.SearchText = '';
	_mobile_board_list.Page = 1;
	_mobile_board_list.CategoryID = '';
	_mobile_board_list.EndOfList = false;
	
	if(_mobile_board_list.BizSection == "Doc") {
		_mobile_board_list.sortColumn = "RevisionDate";
		_mobile_board_list.sortDirection = "desc";
		if(_mobile_board_list.BoardType == "Approval") {
			_mobile_board_list.sortColumn = "RegistDate";
			_mobile_board_list.sortDirection = "desc";
		} else if(_mobile_board_list.BoardType == "DocAuth") {
			_mobile_board_list.sortColumn = "RequestDate";
			_mobile_board_list.sortDirection = "desc";
		} else if(_mobile_board_list.BoardType == "DistributeDoc") {
			_mobile_board_list.sortColumn = "DistributeDate";
			_mobile_board_list.sortDirection = "desc";
		}
	} else {
		_mobile_board_list.sortColumn = "";
		_mobile_board_list.sortDirection = "";
	}
	
	$('#mobile_search_input').val('');
	
	//컨텐츠 게시판일 경우
	if(folderType == "Contents"){
		
		var contents = mobile_board_getContentMessage(folderID);
		
		//컨텐츠가 없을 경우 '목록-조회 내용 없음' 페이지로, 있을 경우 '조회' 페이지로 이동
		if(!$.isEmptyObject(contents)){

			_mobile_board_view.Version = contents.Version;
			_mobile_board_view.FolderID = contents.FolderID;
			_mobile_board_view.MessageID = contents.MessageID;
			_mobile_board_view.FolderType = "Contents";
			
			var sUrl = "/groupware/mobile/board/view.do?";
			sUrl += "boardtype=" + _mobile_board_list.BoardType;
			sUrl += "&folderid=" + _mobile_board_view.FolderID;
			sUrl += "&page=" + _mobile_board_list.Page;
			sUrl += "&searchtext=" + _mobile_board_list.SearchText;
			sUrl += "&messageid=" + _mobile_board_view.MessageID;
			sUrl += "&foldertype=" + _mobile_board_view.FolderType;
			
			return mobile_comm_go(sUrl);			
		}		
	}
	
	//값 초기화
	_mobile_board_view.FolderType = "";
	
	// 게시판 환경설정 조회
	mobile_board_getBoardConfig(_mobile_board_list.FolderID);
	
	// Category(분류) 사용 여부 확인 및 값 바인딩
	mobile_board_setBoardCategory(_mobile_board_config.UseCategory, _mobile_board_list.FolderID, 'board_list_category');

	mobile_board_getList(_mobile_board_list);
}

//게시판 환경설정 조회
function mobile_board_getBoardConfig( pFolderID, pMode ){
	$.ajax({
		type:"POST",
		url:"/groupware/mobile/board/selectBoardConfig.do",
		async: false,
		data:{
       		"folderID": pFolderID,
       	},
       	success:function(data){
       		if(pMode == 'WRITE')
       			_mobile_board_write.Config = data.config;
       		else
       			_mobile_board_config = data.config;
       	},
       	error:function(response, status, error){
		     //TODO 추가 오류 처리
		     mobile_comm_ajaxerror("/groupware/mobile/board/selectBoardConfig.do", response, status, error);
   		}
	});
}

//게시 목록 조회
function mobile_board_getList(params) {
	
	//메뉴 및 트리 선택 표시
	if($('#board_list_topmenu a.t_link.selected').length > 0) {
		$('#board_list_topmenu a.t_link.selected').removeClass("selected");
	}
	
	if(_mobile_board_list.FolderID == "") {
		if(_mobile_board_list.BoxType == "") {
			$("#board_list_topmenu li[boardtype=" + _mobile_board_list.BoardType + "] a").addClass("selected");
		} else if(_mobile_board_list.BoxType == "Receive"){//승인함
			$("#board_list_topmenu li[boardtype=" + _mobile_board_list.BoardType + "]").find('a').eq(0).addClass("selected");
			$("#board_list_topmenu li[boardtype=" + _mobile_board_list.BoardType + "] .sub_list li[tabtype=" + _mobile_board_list.BoxType + "] a").addClass("selected");
		}else {
			$("#board_list_topmenu li[boardtype=" + _mobile_board_list.BoardType + "] .sub_list li[tabtype=" + _mobile_board_list.BoxType + "] a").addClass("selected");
		}
	} else {
		$("#board_list_topmenu").find("li[folderid=" + _mobile_board_list.FolderID + "]").find("a").addClass("selected");
	}
	
	if($('#board_list_topmenu a.t_link.selected').length == 0) {
		$('#board_list_topmenu li').eq(0).find('a').addClass("selected");
	}
		
	mobile_comm_TopMenuClick('board_list_topmenu',true);
	
	var sPage = params.Page;
	var sPageSize = params.PageSize;
	
	if(_mobile_board_list.OnBack) {
		sPageSize = sPage * (sPageSize);
        sPage = 1;
	}
	
	if( params.BoardType.toUpperCase() == "TOTAL"){
		params.FolderType = "";
	}
	
	var url = "/groupware/mobile/board/getBoardMessageList.do";
	var paramdata = {
		bizSection: _mobile_board_list.BizSection,
		menuID: _mobile_board_list.MenuID,
		boardType: params.BoardType,
		viewType: (params.FolderType.toUpperCase() == "ALBUM" || params.FolderType.toUpperCase() == "VIDEO")? "Album" : "List",
		folderID: params.FolderID,
		folderType: params.FolderType,
		boxType: params.BoxType,
		searchText: params.SearchText,
		page: sPage,
		pageSize: sPageSize,
		categoryID: params.CategoryID,
		communityID: _mobile_board_list.CU_ID,
		approvalStatus: (params.BoardType.toUpperCase() == "APPROVAL") ? "R" : "",
		UseTopNotice: _mobile_board_config.UseTopNotice,
		menuCode: _mobile_board_list.MenuCode
	};
	
	if(params.sortColumn != "" && params.sortDirection != "") {
		paramdata.sortColumn = params.sortColumn;
		paramdata.sortDirection = params.sortDirection;
	}
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		success: function (response) {
			
			if(response.status == "SUCCESS") {
				
				_mobile_board_list.TotalCount = response.totalcount;

				//앨범 게시판과 비디오 게시판은 일반 목록이 아닌 앨범 목록으로 표현됨
				var sHtml = "";
				$('#board_list_list').removeClass("approval_list");
				if(params.FolderType.toUpperCase() == "ALBUM" || params.FolderType.toUpperCase() == "VIDEO") {
					sHtml = mobile_board_getAlbumListHtml(response.list, params.FolderType.toUpperCase());
					$('#board_list_list').removeClass("g_list").addClass("g_list_album");					
				} else {
					if(params.BizSection == "Board" || params.BizSection == "Community") {
						sHtml = mobile_board_getListHtml(response.list, "Board");
					} else {
						sHtml = mobile_board_getListHtml(response.list, "Doc");
					}
					//sHtml = mobile_board_getListHtml(response.list);
					$('#board_list_list').addClass("g_list").removeClass("g_list_album");					
				}

				if(params.Page == 1 || sHtml.indexOf("no_list") > -1) {
					$('#board_list_list').html(sHtml);
				} else {
					$('#board_list_list').append(sHtml);
				}
				
				if (Math.min((_mobile_board_list.Page) * _mobile_board_list.PageSize, _mobile_board_list.TotalCount) == _mobile_board_list.TotalCount) {
					_mobile_board_list.EndOfList = true;
	                $('#board_list_more').hide();
	            } else {
	                $('#board_list_more').show();
	            }
				
				if(_mobile_board_list.OnBack) {
					_mobile_board_list.OnBack = false;
				}
				
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	// 메뉴명 셋팅
	if(params.CU_ID == ""){
		mobile_board_getTopMenuName();
	} else {
		$("#community_home_myCommunitySel").parent().parent().parent("div.g_list").show();
		mobile_community_makeMyCommunitySelect(params);
		$("#community_home_myCommunitySel").attr("disabled", "disabled");
		mobile_board_getTopMenuName();
	}
}

function mobile_doc_getLinkedList(params) {
	
	//작성버튼 숨김처리
	$('.list_writeBTN').hide();
	
	var sPage = params.Page;
	var sPageSize = params.PageSize;
	
	mobile_comm_showload();
	
	var url = "/groupware/mobile/board/selectSearchMessageGridList.do";
	var paramdata = {
		bizSection: params.BizSection,
		menuID: params.MenuID,
		boardType: "Total",
		viewType: "List",
		searchType: "Mobile",
		searchText: params.SearchText,
		pageNo: sPage,
		pageSize: sPageSize,
		mode: "Link",
		sortBy: "MessageID desc"
	};
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		success: function (response) {
			if(response.status == "SUCCESS") {
				
				_mobile_board_list.TotalCount = response.totalcount;

				var sHtml = "";
				sHtml = mobile_doc_getLinkedListHtml(response.list);
			
				$('#board_list_list').addClass("g_list").addClass("approval_list").removeClass("g_list_album");				

				if(params.Page == 1 || sHtml.indexOf("no_list") > -1) {
					$('#board_list_list').html(sHtml).trigger("create");
				} else {
					$('#board_list_list').append(sHtml).trigger("create");
				}
				
				if (Math.min((_mobile_board_list.Page) * _mobile_board_list.PageSize, _mobile_board_list.TotalCount) == _mobile_board_list.TotalCount) {
					_mobile_board_list.EndOfList = true;
	                $('#board_list_more').hide();
	            } else {
	            	_mobile_board_list.EndOfList = true;
	                $('#board_list_more').show();
	            }
				
				if(_mobile_board_list.OnBack) {
					_mobile_board_list.OnBack = false;
				}
				
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	mobile_comm_hideload();
}

//일반 목록형 그리기
function mobile_board_getListHtml(messagelist, type) {
	var sHtml = "";
	
	var sUrl = "";
	var sTop = "";
	var sFile = "";
	var sCommentLink = "";
	var sPreviewURL = "";
	var sUserName = "";
	var sOwnerName = "";
	var sDate = "";
	var sRe = "";
	var sIsRead = "";
	
	if(messagelist.length > 0) {
		$(messagelist).each(function (i, message){
			if(type == "Board") {
				sUrl = "/groupware/mobile/board/view.do";
				sUrl += "?boardtype=" + _mobile_board_list.BoardType;
				sUrl += "&folderid=" + message.FolderID;
				sUrl += "&page=" + _mobile_board_list.Page;
				sUrl += "&searchtext=" + _mobile_board_list.SearchText;
				sUrl += "&messageid=" + message.MessageID;
				sUrl += "&cuid=" + _mobile_board_list.CU_ID;
				sUrl += "&version=" + message.Version;
				sUrl += "&foldertype=" + type;
				sUrl += "&menucode=" + _mobile_board_list.MenuCode;
				sUrl += "&menuid=" + _mobile_board_list.MenuID;
				sUrl += "&bizSection=" + _mobile_board_list.BizSection;
				
				if(_mobile_board_list.BoardType == "Approval") {
					sUrl += "&boxtype=" + _mobile_board_list.BoxType;
					sUrl += "&processid=" + message.ProcessID;					
				}
				
				sTop = "";
				sFile = "";
				sCommentLink = "";
				sRe = "";
				sIsRead = "read ";
				message.Subject = message.Subject.replace(/</g, '&lt;').replace(/>/g, '&gt;');
				
				if(message.IsTop == "Y" && _mobile_board_list.BoardType != "Total") {
					sTop = "<span class=\"ico_notice\"></span>";
				}
				if(message.FileCnt > 0) {
					sFile = "<span class=\"ico_file_clip\"></span>";
				}
				if(_mobile_board_config.UseComment != "N" && message.CommentCnt > 0) {
					sCommentLink = "javascript: mobile_comment_goCommentList('" + type + "', '" + message.MessageID + "_"  + message.Version + "');";
				}
				if(message.Depth!=undefined && message.Depth!="0"){
					sRe = "re";
				}
				if(message.IsRead != undefined && message.IsRead == "N"){
					sIsRead = "unread ";
				} 
				
				// 섬네일 이미지 처리
				if(message.FileCnt > 0 && message.FileID != undefined && message.FileID != ""){
					// TODO : EnableVideoExtention 기초 설정 검토 필요
					// 동영상인 경우를 구별하는 부분으로, 기초 설정에서 확장자 목록을 가져옴
					if( message.FileExtension  != undefined && message.FileExtension != "" && mobile_comm_getBaseConfig('EnableVideoExtention').indexOf(message.FileExtension) > -1 ){
						sPreviewURL = "<span class=\"thum video\">";
					} else {
						sPreviewURL = "<span class=\"thum\">";
					} 			
					sPreviewURL += "<img alt='' src='" + mobile_comm_getThumbSrc("Board", message.FileID) + "' onerror='this.onerror=null;mobile_comm_imageerror(this);' />";
					sPreviewURL += "</span>"
					sHtml += "<li>";
				} else {
					sPreviewURL = "";
					sHtml += "<li class=\"no_thum\">";
				}
				sHtml += "    <a href=\"javascript: void(0);\" onclick=\"mobile_board_read('" + sUrl + "', this);\" class=\"" + ((_mobile_board_config.UseComment != "N") ? "con_link" : "con_link_full") + "\">";
				sHtml += "        <div class=\"txt_area " + ((_mobile_board_config.UseComment != "N") ? "" : "txt_area_full") + "\">";
				if(message.DeleteDate  != undefined && message.DeleteDate  != null && message.DeleteDate  != ""){ //삭제된 게시글의 경우에는 '취소선' 처리
					sHtml += "        <p class=\"title " + sIsRead + sRe + "\"><strike>" + sTop + message.Subject + sFile + "</strike></p>";
				} else{
				sHtml += "            <p class=\"title " + sIsRead + sRe + "\">" + sTop + message.Subject + sFile + "</p>";
				}
				sHtml += "            <p class=\"list_info\">";
				if(message.FolderName != null && message.FolderName != undefined) {
					sHtml += "                <span class=\"point_cr\">"+ message.FolderName +"</span>"; //폴더명	
				}
				sHtml += "                <span class=\"name\">" + message.CreatorName + "</span>";	//TODO: 홍길등 팀장> 직급?표시해야 함??
				sHtml += "                <span class=\"date\">" + mobile_comm_getDateTimeString2('list', CFN_TransLocalTime(message.RegistDate)) + "</span>";	//TODO: 시간 처리 필요
				sHtml += "                <span class=\"ico_hits\">" + message.ReadCnt + "</span>";
				sHtml += "            </p>";
				sHtml += "        </div>";
				sHtml += 			sPreviewURL;
				sHtml += "    </a>";
				if(_mobile_board_list.BoardType == "Approval") {
					sHtml += "<div class=\"approval_state\">";
					sHtml += "	<div class=\"bar_wrap\">";
					sHtml += "		<span class=\"bar " + ((message.TotalApprovalCnt/message.TotalApproverCnt) == 1 ? "full" : "") + "\" style=\"width:" + ((message.TotalApprovalCnt/message.TotalApproverCnt) * 100) + "%;\"></span>";
					sHtml += "	</div>";
					sHtml += "	<p>" + message.TotalApprovalCnt + "/" + message.TotalApproverCnt + "</p>";
					sHtml += "</div>";
				}
				else if(_mobile_board_config.UseComment != "N") {
					sHtml += "    <a href=\"" + sCommentLink + "\" class=\"num_comment\">";
					sHtml += "        <span><strong>" + message.CommentCnt + "</strong>"+mobile_comm_getDic("lbl_Comments")+"</span>";
					sHtml += "    </a>";
				}
				sHtml += "</li>";
			} else if(type == "Doc") {
				sUrl = "/groupware/mobile/doc/view.do";
				sUrl += "?boardtype=" + _mobile_board_list.BoardType;
				sUrl += "&folderid=" + message.FolderID;
				sUrl += "&page=" + _mobile_board_list.Page;
				sUrl += "&searchtext=" + _mobile_board_list.SearchText;
				sUrl += "&messageid=" + message.MessageID;
				sUrl += "&version=" + message.Version;
				sUrl += "&bizSection=" + _mobile_board_list.BizSection;
				if(_mobile_board_list.BoardType == "DocAuth" && _mobile_board_list.BoxType == "Receive") {
					sUrl += "&requestid=" + message.RequestID;
				} else if(_mobile_board_list.BoardType == "Approval") {
					sUrl += "&boxtype=" + _mobile_board_list.BoxType;
					sUrl += "&processid=" + message.ProcessID;					
				}
				
				var lock_class = "ico_sm_unlock";
				if(message.IsCheckOut == "Y")
					lock_class = "ico_sm_lock";
				
				sFile = "";
				sCommentLink = "";
				sUserName = "";
				sOwnerName = "";
				sDate = "";
				sIsRead = "read ";
				
				if(message.FileCnt > 0) {
					sFile = "<span class=\"ico_file_clip\"></span>";
				}
				if(_mobile_board_config.UseComment != "N" && message.CommentCnt > 0) {
					sCommentLink = "javascript: mobile_comment_goCommentList('" + type + "', '" + message.MessageID + "_"  + message.Version + "');";
				}
				if(_mobile_board_list.BoardType == "Approval") {
					sUserName = message.CreatorName;
					sDate = message.RegistDate;
				}
				else if(_mobile_board_list.BoardType == "DocAuth") {
					sUserName = message.RequestorName;
					sDate = message.RequestDate;
				}
				else if(_mobile_board_list.BoardType == "DistributeDoc") {
					sUserName = message.DistributerName;
					sDate = message.DistributeDate;
				}
				else {
					sUserName = message.CreatorName;
					sOwnerName = message.OwnerName;
					sDate = message.RevisionDate;
				}
				
				if(message.IsRead != undefined && message.IsRead == "N"){
					sIsRead = "unread ";
				}
				
				sHtml += "<li class=\"no_thum\">";
				sHtml += "    <a href=\"javascript: void(0);\" onclick=\"mobile_doc_gotoView(" + message.MessageID + ", " + message.Version + ", '" + sUrl + "', this);\" class=\"con_link\">";	//TODO: 메시지보기로 이동
				sHtml += "        <div class=\"txt_area\">";
				sHtml += "			  <p class=\"title "+ sIsRead +"\">";
				sHtml += "			  	  <span class=\"ico_wrap\"><span class=\"flag_ver\">Ver." + message.Version + "</span><i class=\"" + lock_class + "\"></i></span>";
				if(message.DeleteDate  != undefined && message.DeleteDate  != null && message.DeleteDate  != ""){ //삭제된 게시글의 경우에는 '취소선' 처리
					sHtml += "            <strike>" + message.Subject + sFile + "</strike>";
				} else{
					sHtml += 			  message.Subject + sFile;
				}
				sHtml += "			  </p>";
				sHtml += "            <p class=\"list_info\">";
				if(message.FolderName != null && message.FolderName != undefined) {
					sHtml += "                <span class=\"point_cr\">"+ message.FolderName +"</span>"; //폴더명	
				}				
				//sHtml += "                <span>" + mobile_comm_getDicInfo(sUserName) + ((sOwnerName != "" && sOwnerName != undefined) ? ("(" + sOwnerName + ")") : "") + "</span>";
				sHtml += "                <span>" + ((sOwnerName != "" && sOwnerName != undefined) ? sOwnerName : mobile_comm_getDicInfo(sUserName)) + "</span>";
				if(sOwnerName != "") {
					sHtml += "            <span>" + (message.RegistDeptName == "" ? "-" : message.RegistDeptName) + "</span>";
				}
				sHtml += "                <span>" + mobile_comm_getDateTimeString2('list', CFN_TransLocalTime(sDate)) + "</span>";
				sHtml += "            </p>";
				sHtml += "        </div>";
				sHtml += "    </a>";
				if(_mobile_board_list.BoardType == "Approval") {
					sHtml += "<div class=\"approval_state\">";
					sHtml += "	<div class=\"bar_wrap\">";
					sHtml += "		<span class=\"bar " + ((message.TotalApprovalCnt/message.TotalApproverCnt) == 1 ? "full" : "") + "\" style=\"width:" + ((message.TotalApprovalCnt/message.TotalApproverCnt) * 100) + "%;\"></span>";
					sHtml += "	</div>";
					sHtml += "	<p>" + message.TotalApprovalCnt + "/" + message.TotalApproverCnt + "</p>";
					sHtml += "</div>";
				} else if(_mobile_board_list.BoardType == "DocAuth") {
					var sActType = "";
					switch(message.ActType) {
					case "R": sActType = mobile_comm_getDic("lbl_Request"); break; //요청
					case "A": sActType = mobile_comm_getDic("lbl_Approval"); break; //승인
					case "D": sActType = mobile_comm_getDic("lbl_Reject"); break; //거부
					}
					sHtml += "    <a href=\"\" class=\"num_comment\">";
					sHtml += "        <span>" + sActType + "(" + message.ActType + ")" + "</span>"; //TODO: ( A: 승인, R: 요청, D:거부 ) 다국어
					sHtml += "    </a>";
				} else if(_mobile_board_list.BoardType == "DistributeDoc") {
					if(_mobile_board_list.BoxType == "Receive") {
						if(_mobile_board_config.UseComment != "N") {
							sHtml += "    <a href=\"" + sCommentLink + "\" class=\"num_comment\">";
							sHtml += "        <span><strong>" + message.CommentCnt + "</strong>" + mobile_comm_getDic("lbl_Comments") + "</span>";	//댓글
							sHtml += "    </a>";
						}
					} else if(_mobile_board_list.BoxType == "Distribute") {
						sHtml += "    <a href=\"\" class=\"num_comment\">";
						sHtml += "        <span><strong>" + message.ReadCnt + "/" + message.DisCnt + "</strong>" + mobile_comm_getDic("lbl_State") + "</span>"; //상태
						sHtml += "    </a>";
					}
				} else {
					if(_mobile_board_config.UseComment != "N") {
						sHtml += "    <a href=\"" + sCommentLink + "\" class=\"num_comment\">";
						sHtml += "        <span><strong>" + message.CommentCnt + "</strong>" + mobile_comm_getDic("lbl_Comments") + "</span>";	//댓글
						sHtml += "    </a>";
					}
				}
				sHtml += "</li>";
			}
		});
	} else {
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	return sHtml;
}

//앨범 목록형 그리기
function mobile_board_getAlbumListHtml(messagelist, folderType) {
	
	var sHtml = "";
	
	var sUrl = "";
	var previewURL = "";
	
	if(messagelist.length > 0) {
		$(messagelist).each(function (i, message){
			
			sUrl = "/groupware/mobile/board/view.do";
			sUrl += "?boardtype=" + _mobile_board_list.BoardType;
			sUrl += "&folderid=" + message.FolderID;
			sUrl += "&page=" + _mobile_board_list.Page;
			sUrl += "&searchtext=" + _mobile_board_list.SearchText;
			sUrl += "&messageid=" + message.MessageID;
			sUrl += "&version=" + message.Version;
			sUrl += "&cuid=" + _mobile_board_list.CU_ID;
			sUrl += "&foldertype=" + folderType;
			
			//previewURL = message.FileID==undefined?"/GWStorage/no_image.jpg":("/covicore/common/preview/Board/" + message.FileID + ".do");
			previewURL = mobile_comm_getThumbSrc("Board", message.FileID);
			
			// TODO : EnableVideoExtention 기초 설정 검토 필요
			// 동영상인 경우를 구별하는 부분으로, 기초 설정에서 확장자 목록을 가져옴
			if(folderType == "VIDEO"
					&& mobile_comm_getBaseConfig('EnableVideoExtention').indexOf(mobile_comm_getFileExtensionName(previewURL)) > -1){
				sHtml += "<li class='video'>";
			} else {
				sHtml += "<li>";
			} 			
			sHtml += "    <a href=\"javascript: mobile_comm_go('" + sUrl + "');\" class=\"ui_link\">";	//TODO: 메시지보기로 이동
			sHtml += "        <div class=\"txt_area\">";
			sHtml += "            <img src=\"" + previewURL + "\" alt=\"\" onerror=\"this.onerror=null;mobile_comm_imageerror(this);\">";
			sHtml += "        </div>";
			sHtml += "    </a>";
			sHtml += "</li>";
		});
	} else {
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	return sHtml;
}

function mobile_doc_getLinkedListHtml(messagelist) {
	var sHtml = "";
	
	var sUrl = "";
	var sUserName = "";
	var sOwnerName = "";
	var sDate = "";
	
	if(messagelist.length > 0) {
		sHtml += "<div class=\"all_chk\" id=\"doc_list_div_allchk\" style=\"display: none;\">";
		sHtml += "    <p>";
		sHtml += "        <input type=\"checkbox\" name=\"\" value=\"\" id=\"doc_list_allchk\" onchange=\"mobile_doc_checkAll(this);\">";
		sHtml += "        <label for=\"doc_list_allchk\">" + mobile_comm_getDic("lbl_selectall") + " <strong class=\"point_cr\" id=\"doc_list_chkcnt\"></strong></label>"; //전체선택
		sHtml += "    </p>";
		sHtml += "</div>";
		$(messagelist).each(function (i, message){
			sUrl = "/groupware/mobile/doc/view.do";
			sUrl += "?boardtype=" + _mobile_board_list.BoardType;
			sUrl += "&folderid=" + message.FolderID;
			sUrl += "&page=" + _mobile_board_list.Page;
			sUrl += "&searchtext=" + _mobile_board_list.SearchText;
			sUrl += "&messageid=" + message.MessageID;
			sUrl += "&version=" + message.Version;
			sUrl += "&menucode=" + _mobile_board_list.MenuCode;
			sUrl += "&menuid=" + _mobile_board_list.MenuID;
			
			var lock_class = "ico_sm_unlock";
			if(message.IsCheckOut == "Y")
				lock_class = "ico_sm_lock";
			
			sUserName = "";
			sOwnerName = "";
			sDate = "";

			sUserName = message.CreatorName;
			sOwnerName = message.OwnerName;
			sDate = message.RevisionDate;
			
			var returnItem = {
				MessageID: message.MessageID,
				FolderID: message.FolderID,
				Version: message.Version,
				DisplayName: message.Subject
			};
			
			sHtml += "<li>";
			sHtml += "	  <div class=\"checkbox\">";
			sHtml += "	  	  <input type=\"checkbox\" name=\"doc_list_chkbox\" value='" + JSON.stringify(returnItem) + "' id=\"chk_" + message.MessageID + "_" + message.Version + "\" onchange=\"mobile_doc_showAllChk();\">";
			sHtml += "	  	  <label for=\"chk_" + message.MessageID + "_" + message.Version + "\"></label>";
			sHtml += "	  </div>";
			
			sHtml += "    <div class=\"txt_area\" onclick=\"javascript: mobile_doc_gotoView(" + message.MessageID + ", " + message.Version + ", '" + sUrl + "');\" style=\"padding-left: 10px;\">";
			sHtml += "	      <p class=\"title\">";
			sHtml += "		  	  <span class=\"ico_wrap\"><span class=\"flag_ver\">" + message.FolderName + "</span><span class=\"flag_ver\">Ver." + message.Version + "</span><i class=\"" + lock_class + "\"></i></span>";
			if(message.DeleteDate  != undefined && message.DeleteDate  != null && message.DeleteDate  != ""){ //삭제된 게시글의 경우에는 '취소선' 처리
				//sHtml += "            <strike>[" + message.Number + "] " + message.Subject + "</strike>";
				sHtml += "              <strike>" + message.Subject + "</strike>";
			} else{
				//sHtml += 			  "[" + message.Number + "] " + message.Subject;
				sHtml += 			    message.Subject;
			}
			sHtml += "		  </p>";
			sHtml += "        <p class=\"list_info\">";
			//sHtml += "            <span>" + mobile_comm_getDicInfo(sUserName) + ((sOwnerName != "" && sOwnerName != undefined) ? ("(" + sOwnerName + ")") : "") + "</span>";
			sHtml += "            <span>" + ((sOwnerName != "" && sOwnerName != undefined) ? sOwnerName : mobile_comm_getDicInfo(sUserName)) + "</span>";
			sHtml += "            <span>" + mobile_comm_getDateTimeString2('list', sDate) + "</span>";
			sHtml += "            <span class=\"ico_hits\">" + message.ReadCnt + "</span>";
			sHtml += "        </p>";
			sHtml += "    </div>";
			sHtml += "</li>";
		});
	} else {
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	return sHtml;
}

//게시 조회 시 읽음처리
function mobile_board_read(pUrl, pObj) {
	$(pObj).children('div').children('p.title').removeClass('unread').addClass('read');
	mobile_comm_go(pUrl, 'Y');
}

//전체선택 div show or hide
function mobile_doc_showAllChk() {
	$("#doc_list_div_allchk").hide();
	var cnt = 0;
	var obj = $("input[type=checkbox][name=doc_list_chkbox]");
	var objcnt = obj.length;
	for(var i = 0; i < objcnt; i++) {
		if($(obj).eq(i).is(":checked")) {
			$("#doc_list_div_allchk").show();
			cnt++;
		}
	}
	if(cnt != 0) {
		$("#doc_list_chkcnt").html(cnt);
		if($("#board_list_list").find("input[type=checkbox][name=doc_list_chkbox]:not([disabled=disabled])").length > cnt) {
			$("#doc_list_allchk").prop("checked", false).checkboxradio('refresh');
		} else {
			$("#doc_list_allchk").prop("checked", true).checkboxradio('refresh');
		}
	}
}

//전체선택 checkbox change
function mobile_doc_checkAll(obj) {
	if($(obj).is(":checked")) {
		$("#board_list_list").find("input[type=checkbox][name=doc_list_chkbox]:not([disabled=disabled])").prop("checked", true).checkboxradio('refresh');
	} else {
		$("#board_list_list").find("input[type=checkbox][name=doc_list_chkbox]").prop("checked", false).checkboxradio('refresh');
	}
	mobile_doc_showAllChk();
}

//더보기 클릭
function mobile_board_nextlist(pMode) {
	
	if(pMode == undefined){
		if (!_mobile_board_list.EndOfList) {
			_mobile_board_list.Page++;

			if(_mobile_board_list.ListMode == "normal")
				mobile_board_getList(_mobile_board_list);
			else if(_mobile_board_list.ListMode == "docSelect")
				mobile_doc_getLinkedList(_mobile_board_list);
	    } else {
	        $('#board_list_more').css('display', 'none');
	    }
	} else if(pMode == "viewerlist"){ //viewerlist
		_mobile_board_view.Page++;
		mobile_board_getViewerList();
	}
	
}

//게시 스크롤 더보기
function mobile_board_list_page_ListAddMore(){
	mobile_board_nextlist();
}

// 게시 조회자 목록 더보기
function mobile_board_viewer_page_ListAddMore(){
	mobile_board_nextlist('viewerlist');
}

// 문서관리 스크롤 더보기
function mobile_doc_list_page_ListAddMore(){
	mobile_board_nextlist();
}

//작성 버튼 클릭
function mobile_board_clickwrite() {
	var isTeams = false;
	try {
		if (typeof XFN_TeamsOpenGroupware == "function" && !teams_mobile) {
			isTeams = true;
		}
	} catch(e) { 
		mobile_comm_log(e);
	}
	
	if (isTeams) {
		var url = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&menuID=" + _mobile_board_list.MenuID;
        var popupId = "TeamsBoardWrite";
        //XFN_TeamsOpenWindow(url, popupId, "POPUP", 1200, 800, "both", false);
        XFN_TeamsOpenWindow(url, popupId, "REDIRECT", 0, 0, "", false);
	} else {
		mobile_board_gowrite(_mobile_board_list.MenuID, _mobile_board_list.FolderID, null, null, _mobile_board_list.CU_ID, _mobile_board_list.BoardType, _mobile_board_list.SearchText);
	}
}

//검색 클릭
function mobile_board_clicksearch() {
	_mobile_board_list.Page = 1;
	_mobile_board_list.EndOfList = false;	
	_mobile_board_list.SearchText = $('#mobile_search_input').val();
	window.sessionStorage.setItem("mobileBoardSearchText", $('#mobile_search_input').val());
	if(_mobile_board_list.BoardType == 'Total') _mobile_board_list.FolderType = '';
	if(_mobile_board_list.ListMode == "normal")
		mobile_board_getList(_mobile_board_list);
	else if(_mobile_board_list.ListMode == "docSelect")
		mobile_doc_getLinkedList(_mobile_board_list);
	
}

//검색 닫기
function mobile_board_closesearch() {
	mobile_comm_showload(); 
	_mobile_board_list.SearchText = '';
	_mobile_board_list.Page = 1;
	_mobile_board_list.EndOfList = false;
	$('#mobile_search_input').val('');	
	if(_mobile_board_list.ListMode == "normal") {
		mobile_board_getList(_mobile_board_list);
		mobile_comm_hideload();
	} else if(_mobile_board_list.ListMode == "docSelect") {
		mobile_doc_getLinkedList(_mobile_board_list);
		mobile_comm_hideload();
	}
}

//새로고침 클릭
function mobile_board_clickrefresh() {
	 mobile_comm_showload(); 
	_mobile_board_list.CategoryID = '';
	_mobile_board_list.SearchText = '';
	_mobile_board_list.Page = 1;
	_mobile_board_list.EndOfList = false;
	$('#mobile_search_input').val('');		
	mobile_board_setBoardCategory(_mobile_board_config.UseCategory, _mobile_board_list.FolderID, 'board_list_category');
	mobile_board_getList(_mobile_board_list);
	mobile_comm_hideload();
}

//카테고리 클릭
function mobile_board_clickcategory() {
	
	_mobile_board_list.CategoryID = $('#board_list_category :selected').val();
	_mobile_board_list.Page = 1;
	_mobile_board_list.EndOfList = false;
	mobile_board_getList(_mobile_board_list);
	
}

//게시 목록 끝













/*!
 * 
 * 게시 상세보기
 * 
 */


var _mobile_board_view = {
		
	// 리스트 조회 초기 데이터
	BoardType: '',		//boardType-Total/Approval 등등
	FolderID: '',			//폴더ID-없으면 전체 조회
	Page: 1,				//조회할 페이지
	PageSize: 10,		//페이지별  열 개수
	TotalCount: 0,		//전체 데이터 개수
	SearchText: '',		//검색어
	WriteYN: 'N',		//작성권한. 기본은 N //TODO: 권한처리
	MessageID: '',		//메시지ID
	MenuID: '',			//메뉴ID
	FolderType: '',		//폴더 타입(컨텐츠 게시 식별하기 위함)
	Version: 1,			//메세지 version
	BizSection: 'Board',
	BoxType: '',
	ProcessID: '',
	CU_ID: ''				//커뮤니티 ID
};


function mobile_board_ViewInit(){
	if(parent != undefined && parent.location.pathname.indexOf('portal') > -1 && parent.location.hash == ''){
		_mobile_board_view.isViewPanel = true;
	}
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('boardtype', "board_view_page") != 'undefined') {
		_mobile_board_view.BoardType = mobile_comm_getQueryString('boardtype', "board_view_page");
	} else {
		_mobile_board_view.BoardType = 'Total';
	}
	if (mobile_comm_getQueryString('folderid', "board_view_page") != 'undefined') {
		_mobile_board_view.FolderID = mobile_comm_getQueryString('folderid', "board_view_page");
    } else {
    	_mobile_board_view.FolderID = '';
    }
	if (mobile_comm_getQueryString('page', "board_view_page") != 'undefined') {
		_mobile_board_view.Page = mobile_comm_getQueryString('page', "board_view_page");
    } else {
    	_mobile_board_view.Page = 1;
    }
	if (mobile_comm_getQueryString('searchtext', "board_view_page") != 'undefined') {
		_mobile_board_view.SearchText = mobile_comm_getQueryString('searchtext', "board_view_page");
    } else {
    	_mobile_board_view.SearchText = '';
    }
	if (mobile_comm_getQueryString('messageid', "board_view_page") != 'undefined') {
		_mobile_board_view.MessageID = mobile_comm_getQueryString('messageid', "board_view_page");
    } else {
    	_mobile_board_view.MessageID = 0;
    }
	if (mobile_comm_getQueryString('menuid', "board_view_page") != 'undefined') {
		_mobile_board_view.MenuID = mobile_comm_getQueryString('menuid', "board_view_page");
    } else {
    	_mobile_board_view.MenuID = 0;
    }
	if (mobile_comm_getQueryString('foldertype', "board_view_page") != 'undefined') {
		_mobile_board_view.FolderType = mobile_comm_getQueryString('foldertype', "board_view_page");
    } else {
    	_mobile_board_view.FolderType = '';
    }
	if (mobile_comm_getQueryString('version', "board_view_page") != 'undefined') {
		_mobile_board_view.Version = mobile_comm_getQueryString('version', "board_view_page");
    } else {
    	_mobile_board_view.Version = '1';
    }
	if(mobile_comm_getQueryString('bizSection', "board_view_page") != 'undefined'){
		_mobile_board_view.BizSection = mobile_comm_getQueryString('bizSection', "board_view_page");
	}else{
		var bizSection = "";
		bizSection = location.pathname.split("/")[3];
		bizSection = bizSection.charAt(0).toUpperCase() + bizSection.slice(1);
		
		if(bizSection == "Portal"){
			bizSection = "Board";
		}
		_mobile_board_view.BizSection = bizSection;
	}
	if (mobile_comm_getQueryString('cuid', "board_view_page") != 'undefined') {
		_mobile_board_view.CU_ID = mobile_comm_getQueryString('cuid', "board_view_page");
    } else {
    	_mobile_board_view.CU_ID = '';
    }
	
	if (mobile_comm_getQueryString('boxtype', "board_view_page") != 'undefined') {
		_mobile_board_view.BoxType = mobile_comm_getQueryString('boxtype', "board_view_page");
    } else {
    	_mobile_board_view.BoxType = '';
    }
	
	if (mobile_comm_getQueryString('processid', "board_view_page") != 'undefined') {
		_mobile_board_view.ProcessID = mobile_comm_getQueryString('processid', "board_view_page");
    } else {
    	_mobile_board_view.ProcessID = '';
    }
	
	if(_mobile_board_view.BoardType == "Approval" && _mobile_board_view.BoxType == "Receive") { 
		$("#board_view_btn_approval").show();
	}
	else {
		$("#board_view_btn_approval").hide();
	}	
	
	//조회 권한 확인
	if(_mobile_board_view.MessageID != ""){
		if(!mobile_board_checkReadAuth(_mobile_board_view.BizSection, _mobile_board_view.FolderID, _mobile_board_view.MessageID, _mobile_board_view.Version, _mobile_board_view.CU_ID)){
				alert(mobile_comm_getDic("msg_board_NotReadAuth"), "Warning Dialog", function () { //읽기 권한이 없습니다.
					_mobile_board_view.MessageID = "";
			});
			return mobile_comm_back();
		} else {
			return mobile_board_getView(_mobile_board_view);
		}
	}
		
	return false;
}

//읽기 권한 확인
function mobile_board_checkReadAuth( pBizSection, pFolderID, pMessageID, pVersion, pCommunityID ){
	var bReadFlag = false;
	
	if(mobile_board_getMessageReadAuthCount(pBizSection, pMessageID, pFolderID) > 0){
		return true;
	}
	
	$.ajax({
		type:"POST",
		async: false,
		data: {
			"bizSection": pBizSection
			, "folderID": pFolderID
			, "messageID": pMessageID
			, "version": pVersion
			,"communityID": pCommunityID
		},
		url: "/groupware/mobile/board/checkReadAuth.do",
		success:function(data){
			if(data.status == 'SUCCESS'){
				bReadFlag = data.flag;
			}
		},
	});
	return bReadFlag;
}

//열람권한 정보 조회
function mobile_board_getMessageReadAuthCount(pBizSection, pMessageID, pFolderID) {
	var returnFlag = false;
	$.ajax({
		type:"POST",
		data: {
			"bizSection": pBizSection,
			"messageID": pMessageID,
			"folderID": pFolderID,
		},
		url:"/groupware/mobile/board/selectMessageReadAuthCount.do",
		async: false,
		success:function(data){
			if(data.status == 'SUCCESS'){
				returnFlag = data.count > 0 ? true:false;
			} else {
    			alert(mobile_comm_getDic('msg_apv_030'));//오류가 발생헸습니다.
    		}
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror("/groupware/mobile/board/selectMessageReadAuthCount.do", response, status, error);
		}
	});
	return returnFlag;
}

//상세권한 정보 조회
function mobile_board_getMessageAclList(pBizSection, pVersion, pMessageID, pFolderID) {
	var aclList = null;
	$.ajax({
		type:"POST",
		data: {
			"bizSection": pBizSection,
			"folderID": pFolderID,
			"messageID": pMessageID,
			"version": pVersion,
			"communityID": ""
		},
		url:"/groupware/mobile/board/selectMessageAclList.do",
		async:false,
		success:function(data){
			aclList = data;
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     mobile_comm_ajaxerror("/groupware/mobile/board/selectMessageAclList.do", response, status, error);
		}
	});
	return aclList;
}

//게시 정보 조회해서 표시
function mobile_board_getView(params) {

	var pFolderType = params.FolderType;
	var paramdata = {
		bizSection: params.BizSection,
		boardType: params.BoardType,
		folderID: params.FolderID,
		messageID: params.MessageID,
		version: params.Version,
		searchText: params.SearchText,
		menuID: params.MenuID,
		menuCode: params.MenuCode,
		page: params.Page,
		communityID: params.CU_ID,
		readFlagStr: true	//읽음처리 추가(checkReadAuth.do가 true인 경우에만 호출되서 무조건 true 처리함)
	};
	
	var url = "/groupware/mobile/board/getBoardMessageView.do";
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		async: false,
		success: function (response) {
			
			if(response.status == "SUCCESS") {
				// 삭제 날짜 확인 후 관리자가 아닐 경우, 관리자이면 삭제 게시물 관리 이므로 보여준다.
				if((response.view.DeleteDate != undefined && response.view.DeleteDate.trim() != "") && mobile_comm_getSession("isAdmin") != "Y"){
					alert(mobile_comm_getDic("msg_50")); //삭제된 게시판
					return mobile_comm_back();
				}
				_mobile_board_list.FolderType = response.config.FolderType;
				
				// 1. 글 정보
				$('#board_view_folder').html(CFN_GetDicInfo(response.config.MultiDisplayName));
				
				$('#board_view_subject').html(
					(response.view.IsTop == "Y" ? "<span class=\"ico_notice\"></span>" : "") + response.view.Subject.replace(/</g,'&lt;').replace(/>/g,'&gt;')
				);
				
				if(response.view.UsePubDeptName == "Y"){
					$('#board_view_writer').html(response.view.CreatorDept);	
				} else if(response.view.UseAnonym == "Y") {
					$('#board_view_writer').html(response.view.CreatorName);
				} else {
					$('#board_view_writer').html(response.view.CreatorName);
					$('div.post_title a.thumb').attr('style', 'background-image: url(' + mobile_comm_getimg(response.view.PhotoPath) + '), url(' + mobile_comm_noperson() + ');');
				}
				
				$('#board_view_writedate').html(mobile_comm_getDateTimeString2('view', CFN_TransLocalTime(response.view.RegistDate)));
				
				$('#board_view_readcnt').html(response.view.ReadCnt);
				
				// 2. 첨부처리
				$('#board_view_attach').html(mobile_comm_downloadhtml(response.file));
				
				// 3. 사용자 정의필드 영역
				if(response.view.IsUserForm == "Y"){
					mobile_board_getUserDefField("View", params.FolderID, response.userdef);
					mobile_board_getUserDefFieldValue("View", response.view.Version, response.view.MessageID);
					$("#board_view_userdef").show();
				} else {
					$("#board_view_userdef").html('').hide();
				}
				
				// 3-1. 링크사이트 영역
				if(response.view.FolderType == "LinkSite"){
					var returnStr = String.format("<a href='{0}' target='_new' title='{0}'>{0}</a>", response.view.LinkURL);
					var divLinkSite = $('<div />');
					divLinkSite.append( $('<div class="tit"><span>' + mobile_comm_getDic("lbl_URL") + '<span/></div>'));
					divLinkSite.append( $('<div class="txt h_Line"><span>' + returnStr + '</span></div>'));

					$("#board_view_linksite").append(divLinkSite).show();
				} else {
					$("#board_view_linksite").html('').hide();
				}
				
				// 4. 본문
				$('#board_view_body').html(XSSBoard(mobile_comm_replaceInlinePhotoMig(unescape(response.view.Body))));
				
				setTimeout(function () {
					mobile_comm_replacebodyinlineimg($('#board_view_body'));
					mobile_comm_replacebodylink($('#board_view_body'));
				}, 100);
				
				// 5. 태그
				var sTagHtml = "";
				$(response.tag).each(function (i, taginfo){
					sTagHtml += "<span class=\"tx\">" + taginfo.Tag + "</span>";
				});
				$('#board_view_tag').html(sTagHtml);
				
				
				// 6. 링크
				var sLinkHtml = "";
				if(response.link.length > 0) {
					sLinkHtml = "<span class=\"tit\">" + mobile_comm_getDic("lbl_Link") + "</span>";	//링크
					$(response.link).each(function (i, linkinfo){
						sLinkHtml += "<a href=\"javascript: mobile_comm_openurl('" + linkinfo.Url + "');\"><span>" + linkinfo.Title + "</span></a>";
					});
				}
				$('#board_view_link').html(sLinkHtml);
				
				// 7. 카테고리/만료일
				var sCategoryHtml = "";
				if(response.view.CategoryName != "") {
					sCategoryHtml += "<span class=\"tx\">" + mobile_comm_getDic("lbl_Cate") + " : " + response.view.CategoryName + "</span>";//분류
				} else if(response.view.ExpiredDate != "" && response.view.ExpiredDate.split('.')[0] != "9999") {
					sCategoryHtml += "<span class=\"date\">" + mobile_comm_getDic("lbl_ExpireDate") + " : " + response.view.ExpiredDate + "</span>";//만료일
				}
				$('#board_view_category').html(sCategoryHtml);
				
				// 8. 좋아요
				// 9. 댓글
				if(response.config.UseComment == "Y" && params.BoardType != "OnWriting") {
					mobile_comment_getCommentLike('Board', _mobile_board_view.MessageID + '_'  + _mobile_board_view.Version , 'N');	
				} else {
					mobile_comment_clearCommentLike();
				}
				
				// 10. 이전글/다음글(컨텐츠 게시인 경우 표시하지 않음)
				if(pFolderType != "Contents"){
				
					var sPrevNextHtml = "";
					if(response.prevnext.prev.MessageID != undefined) {
						var sPrevParam = "'" + response.prevnext.prev.FolderID + "', '" + response.prevnext.prev.MessageID + "', '" + response.prevnext.prev.Version + "'";
						
						sPrevNextHtml += "<a href=\"javascript: mobile_board_goPrevNext(" + sPrevParam + ");\" class=\"prev\">";
						sPrevNextHtml += "    <span class=\"bu\">" + mobile_comm_getDic("lbl_PrevMsg2") + "</span>";//이전글
						sPrevNextHtml += "    <span class=\"tx\"><span class=\"ellip\">" + response.prevnext.prev.Subject + "</span></span>";
						//sPrevNextHtml += "    <span class=\"re_num\">(" + response.prevnext.prev.CommentCnt + ")</span>"; //181211 smahn 성능향상을 위해 주석 처리
						sPrevNextHtml += "</a>";
					} else {
						sPrevNextHtml += "<a href=\"#\" class=\"prev\">";
						sPrevNextHtml += "    <span class=\"bu\">" + mobile_comm_getDic("lbl_PrevMsg2") + "</span>";//이전글
						sPrevNextHtml += "    <span class=\"tx\"><span class=\"ellip\">" + mobile_comm_getDic("lbl_noPrevMsg") + "</span></span>";//이전 글이 없습니다.
						sPrevNextHtml += "    <span class=\"re_num\"></span>";
						sPrevNextHtml += "</a>";
					}
					if(response.prevnext.next.MessageID != undefined) {
						var sNextParam = "'" + response.prevnext.next.FolderID + "', '" + response.prevnext.next.MessageID + "', '" + response.prevnext.next.Version + "'";
						
						sPrevNextHtml += "<a href=\"javascript: mobile_board_goPrevNext(" + sNextParam + ");\" class=\"next\">";
						sPrevNextHtml += "    <span class=\"bu\">" + mobile_comm_getDic("lbl_NextMsg2") + "</span>";//다음글
						sPrevNextHtml += "    <span class=\"tx\"><span class=\"ellip\">" + response.prevnext.next.Subject + "</span></span>";
						//sPrevNextHtml += "    <span class=\"re_num\">(" + response.prevnext.next.CommentCnt + ")</span>"; //181211 smahn 성능향상을 위해 주석 처리
						sPrevNextHtml += "</a>";
					} else {
						sPrevNextHtml += "<a href=\"#\" class=\"next\">";
						sPrevNextHtml += "    <span class=\"bu\">" + mobile_comm_getDic("lbl_NextMsg2") + "</span>";//다음글
						sPrevNextHtml += "    <span class=\"tx\"><span class=\"ellip\">" + mobile_comm_getDic("lbl_noNextMsg") + "</span></span>";//다음 글이 없습니다.
						sPrevNextHtml += "    <span class=\"re_num\"></span>";
						sPrevNextHtml += "</a>";
					}
					$('#board_view_prevnext').html(sPrevNextHtml);
				}
				
				//11. 사용자 권한에 따른 확장메뉴 바인딩(수정/삭제/복사/이동/스크랩/신고/조회자 목록)
				mobile_board_setBtnDisplay(response);
				
				//12. 동영상 viewer 추가
				var videoHtml = "";
				if(response.file.length > 0){
					$.each(response.file, function(i, item){
						// 내용에 비디오 추가
						if (item.Extention == 'mp4' || item.Extention == 'mpeg') {
							videoHtml += '<video width="100%" style="margin-top:10px;" controls="true" controlslist="nodownload" playsinline>';
							//videoHtml += '<source src="' +mobile_comm_replaceAll(mobile_comm_getBaseConfig("BackStorage"), "{0}", mobile_comm_getSession("DN_Code"))+item.ServiceType +'/'+ item.FilePath + item.SavedName + '" type="video/'+item.Extention+ '">';
							videoHtml += '<source src="' +mobile_comm_getImgById(item.ServiceType, item.FileID) + '" type="video/'+item.Extention+ '">';
							videoHtml += '</video>';
						}	
					});
				}
				$('#board_view_body').append(videoHtml);
				
				$('#board_folder_list').html(mobile_board_SelFolderBinding(response.treedata, "Board"));
				
				var userCode = mobile_comm_getSession("UR_Code");
				var commentURL = mobile_comm_getGlobalProperties("smart4j.path")+"/groupware/layout/board_BoardView.do?CLSYS=board&CLMD=user&CLBIZ=Board"
					+ "&version=" + response.view.Version + "&folderID=" + response.view.FolderID + "&messageID=" + response.view.MessageID;
				var mobileURL = mobile_comm_getGlobalProperties("smart4j.path")+"/groupware/mobile/board/view.do"
					+ "?version=" + response.view.Version + "&folderID=" + response.view.FolderID + "&messageID=" + response.view.MessageID;
				
				//13. 댓글 정보 세팅
				mobile_commment_messageSetting = {
					SenderCode : userCode,
					RegistererCode : userCode,
					ReceiversCode : (response.view.CreatorCode != userCode) ? response.view.CreatorCode : '',
					GotoURL : commentURL,
					PopupURL : commentURL,
					MobileURL :  mobileURL,
					MessagingSubject : response.view.Subject,
					ReceiverText : response.view.Subject,
					ServiceType : "Board",
					MsgType : "Comment"
				};
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//다음/이전글로 이동
function mobile_board_goPrevNext(pFolderID, pMessageID, pVersion){
	
	//조회 권한 확인
	if(!mobile_board_checkReadAuth(_mobile_board_view.BizSection, pFolderID, pMessageID, pVersion, _mobile_board_view.CU_ID)){
		alert(mobile_comm_getDic("msg_board_NotReadAuth"));
		return;
	} else {
		_mobile_board_view.FolderID = pFolderID;
		_mobile_board_view.MessageID = pMessageID;
		_mobile_board_view.Version = pVersion;
	
		return mobile_board_getView(_mobile_board_view);
	}
}

//권한에 따른 버튼 display 처리
function mobile_board_setBtnDisplay(pConfig){
	
	//1. 버튼 이벤트 연결
    switch (mobile_comm_getBaseConfig("MobileEditorType")) {
	    case "2"://TinyMCE(기본)
			$("#board_view_modify").attr("onclick", "mobile_board_gowrite(" + pConfig.config.MenuID + "," + _mobile_board_view.FolderID + "," + _mobile_board_view.MessageID + "," + _mobile_board_view.Version + ",'" + _mobile_board_view.CU_ID+ "','" + _mobile_board_view.BoardType + "','" + _mobile_board_view.SearchText + "')");
	        break;
		case "1"://textarea
	    default:
			$("#board_view_modify").attr("onclick", "alert(\"" + mobile_comm_getDic("msg_board_donotSaveInlineImage") + "\"); mobile_board_gowrite(" + pConfig.config.MenuID + "," + _mobile_board_view.FolderID + "," + _mobile_board_view.MessageID + "," + _mobile_board_view.Version + ",'" + _mobile_board_view.CU_ID+ "','" + _mobile_board_view.BoardType + "','" + _mobile_board_view.SearchText + "')"); //수정 시 본문의 인라인 이미지는 저장되지 않습니다.
	        break;
	}

	$("#board_view_delete").attr("onclick", "mobile_board_message_delete()");
	$("#board_view_copy").attr("onclick", "mobile_open_folder('copy')");
	$("#board_view_move").attr("onclick", "mobile_open_folder('move')");
	$("#board_view_report").attr("onclick", "mobile_board_message_report()");
	$("#board_view_viewerlist").attr("onclick", "mobile_board_message_viewer()");
	$("#board_view_scrap").attr("onclick", "mobile_board_message_scrap()");
	
	//2. 게시글 권한 체크 및 버튼 컨트롤 checkACL
	if(mobile_comm_getSession("isAdmin") == "Y"
			|| (_mobile_board_view.BizSection !="Doc" && (pConfig.config.OwnerCode.indexOf(mobile_comm_getSession("USERID")+";") != -1) )
			|| (_mobile_board_view.BizSection !="Doc" && pConfig.view.CreatorCode == mobile_comm_getSession("USERID")) 
			|| (_mobile_board_view.BizSection =="Doc" && pConfig.view.OwnerCode == mobile_comm_getSession("USERID"))){
		if(pConfig.view.MsgState == "A" || pConfig.view.MsgState == "R"){	//게시글 승인 상태
			$("#board_view_modify").parent('li').hide();
			$("#board_view_delete").parent('li').hide();
			$("#board_view_move, #board_view_copy").parent('li').hide();
			$("#board_view_report").parent('li').hide();
		} else {
			$("#board_view_modify").parent('li').show();
			$("#board_view_delete").parent('li').show();
			$("#board_view_move, #board_view_copy").parent('li').show();
			$("#board_view_report").parent('li').show();
		}
	} else {
		var readFlag = false;	//읽기 권한
		readFlag = mobile_board_checkReadAuth(_mobile_board_view.BizSection, _mobile_board_view.FolderID, _mobile_board_view.MessageID, _mobile_board_view.Version, _mobile_board_view.CU_ID)
		
		//한줄 게시는 읽기권한 체크 안함
		if(pConfig.config.FolderType == "QuickComment"){
			readFlag = true;
		}
		
		//열람 권한 확인
		if(pConfig.view.UseMessageReadAuth == "Y"){
			//열람권한 테이블에서 조회된 데이터가 없을경우
			if(mobile_board_getMessageReadAuthCount(_mobile_board_view.BizSection, _mobile_board_view.MessageID, _mobile_board_view.FolderID) > 0){
				readFlag = true;
			}
		}
		if(!readFlag){
			alert(mobile_comm_getDic('msg_noViewACL'));
			mobile_comm_back();
		}
		
		var aclList = mobile_board_getMessageAclList(_mobile_board_view.BizSection, _mobile_board_view.Version, _mobile_board_view.MessageID, _mobile_board_view.FolderID);
		$("#board_view_viewerlist").parent('li').hide();
		$("#board_view_modify").parent('li').hide();
		$("#board_view_delete").parent('li').hide();
		$("#board_view_move, #board_view_copy").parent('li').hide();
		$.each(aclList.list,function(i, item){
			if(item.TargetType == "UR"){
				item.Security == "_"?$("#board_view_viewerlist").parent('li').hide():$("#board_view_viewerlist").parent('li').show()	//조회자 목록
				item.Modify == "_"?$("#board_view_modify").parent('li').hide():$("#board_view_modify").parent('li').show();	//수정
				item.Delete == "_"?$("#board_view_delete, #board_view_move, #board_view_copy").parent('li').hide():$("#board_view_delete, #board_view_move, #board_view_copy").parent('li').show();	//삭제
				//item.Create == "_"?$("#ctxReply").hide():$("#ctxReply").show();		//댓글,답글
				return false;
			} else {
				item.Security == "_"?$("#board_view_viewerlist").parent('li').hide():$("#board_view_viewerlist").parent('li').show()	//조회자 목록
				item.Modify == "_"?$("#board_view_modify").parent('li').hide():$("#board_view_modify").parent('li').show();	//수정
				item.Delete == "_"?$("#board_view_delete, #board_view_move, #board_view_copy").parent('li').hide():$("#board_view_delete, #board_view_move, #board_view_copy").parent('li').show();	//삭제
				//item.Create == "_"?$("#ctxReply").hide():$("#ctxReply").show();		//댓글,답글
			}
		});
	}
	
	//3. 환경설정에 따른 display 설정 TODO:관리자 예외?
	if(pConfig.view.UseScrap != "Y"){
		$("#board_view_scrap").parent('li').hide();
	}
	if(pConfig.config.UseCopy != "Y"){
		$("#board_view_copy").parent('li').hide();
		$("#board_view_move").parent('li').hide();
	}
	if(pConfig.config.UseReport != "Y"){
		$("#board_view_report").parent('li').hide();
	}
	if(pConfig.config.UseReaderView != "Y"){
		$("#board_view_viewerlist").parent('li').hide();
	}
	
	//dropdown 버튼 표시 유무
	if(pConfig.view.MsgType == "S"){
		$("div.utill").hide();
	}
	else if($("#board_view_modify").parent('li').css("display") != "none"
			|| $("#board_view_delete").parent('li').css("display") != "none"
			|| $("#board_view_copy").parent('li').css("display") != "none"
			|| $("#board_view_move").parent('li').css("display") != "none"
			|| $("#board_view_scrap").parent('li').css("display") != "none"
			|| $("#board_view_report").parent('li').css("display") != "none"
			|| $("#board_view_viewerlist").parent('li').css("display") != "none") {
		$("div.utill").show();
	}
	
}

//컨텐츠 기본정보 조회
function mobile_board_getContentMessage(pFolderID){
	var contentsData = {};
	$.ajax({
		url:"/groupware/mobile/board/getContentMessage.do",
		type:"POST",
		data:{
			"folderID": pFolderID,
		},
		async:false,
		success:function (data) {
			if(data.status == 'SUCCESS'){
				contentsData = data.data;
			}
		},
		error:function (error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	return contentsData;
}
//게시 상세보기 끝

var g_sUrl = "";
//작성 페이지로 이동
function mobile_board_gowrite(pMenuID, pFolderID, pMessageID, pVersion, pCUID, pBoardType, pSearchText) {
	
	var bizSection = _mobile_board_list.BizSection;
	if(bizSection == undefined || bizSection == "") 
		bizSection = _mobile_board_view.BizSection;
	bizSection = bizSection.toLowerCase();

	var sUrl = "/groupware/mobile/" + bizSection + "/write.do";
	sUrl += "?menuid=" + pMenuID + '&bizSection=' + _mobile_board_view.BizSection;
	sUrl += "&LinkCnt=" + $("#board_view_link").find('a').length;
	if(pFolderID != undefined && pFolderID != '') {
		sUrl += "&folderid=" + pFolderID;	
	}
	if(pMessageID != undefined && pMessageID != '') {
		sUrl += "&messageid=" + pMessageID;	                                                                                                                                                                                
	}
	if(pVersion != undefined && pVersion != '') {
		sUrl += "&version=" + pVersion;	
	}
	if(pCUID != undefined && pCUID != '') {
		sUrl += "&cuid=" + pCUID;	
	}
	if(pBoardType != undefined && pBoardType != '') {
		sUrl += "&boardtype=" + pBoardType;	
	}
	if(pSearchText != undefined && pSearchText != '') {
		sUrl += "&searchtext=" + pSearchText;	
	}
	
	if(pMessageID != undefined && pMessageID != '') {
		if(bizSection == "doc"){
			if((bizSection == "doc" || _mobile_board_config.UseCheckOut == "Y") && _mobile_message_config.IsCheckOut == "Y" && _mobile_message_config.CheckOuterCode != mobile_comm_getSession("USERID")) {
				alert(mobile_comm_getDic("msg_board_alreadyCheckout")); //이미 체크아웃 된 게시글입니다.
			} else {
				if(bizSection == "doc" && _mobile_message_config.IsCheckOut == "N") {
					g_sUrl = sUrl;
					mobile_doc_clickbtn('', 'modify');
				} else {	
					mobile_comm_go(sUrl, "Y");
				}
			}
		} else {
			mobile_comm_go(sUrl, "Y");
		}
	} else {
		mobile_comm_go(sUrl, "Y");
	}
}




/*!
 * 
 * 게시 작성
 * 
 */



var _mobile_board_write = {

	MenuID: '',			//메뉴ID-없으면 BoardMain의 기초설정값에서 조회
	FolderID: '',		//폴더ID
	MessageID: '',		//메시지ID
	
	Mode: 'CREATE',		//새로 작성인지 수정인지 등등(CREATE/REPLY/UPDATE/REVISION/MIGRATE)
	MsgState: 'C',		//메세지 상태(C등록,D반려,A승인,P잠금,R승인요청,T임시저장, BC등록예약,BA예약승인,BR예약승인요청)
	Version: '1',
	
	CU_ID: '',		//커뮤니티ID
	BizSection: '',
	Config: {}
};

function mobile_board_WriteInit () {

	//datepicker 임시
	$(".input_date").attr('class', 'input_date').datepicker({
		dateFormat : 'yy.mm.dd',
		dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
	});
	
	//에디터 로드

    switch (mobile_comm_getBaseConfig("MobileEditorType")) {
	    case "2"://TinyMCE(기본)
			var html = "";
			html += "<iframe id=\"MobileEditorFrame\" src=\"/covicore/resources/script/mobileeditor/mobileeditor.html\" doctype=\"undefined\" marginwidth=\"0\" marginheight=\"0\" frameborder=\"0\" scrolling=\"no\" width=\"100%\" height=\"100%\" ></iframe>";
			$('#editor_wrap').html(html);	        
			break;
		case "1"://textarea
	    default:
	        break;
	}
	
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('menuid', "board_write_page") != 'undefined') {
		_mobile_board_write.MenuID = mobile_comm_getQueryString('menuid', "board_write_page");
	} else {
		_mobile_board_write.MenuID = '';
	}
	if (mobile_comm_getQueryString('folderid', "board_write_page") != 'undefined') {
		_mobile_board_write.FolderID = mobile_comm_getQueryString('folderid', "board_write_page");
    } else {
    	_mobile_board_write.FolderID = '';
    }
	if (mobile_comm_getQueryString('messageid', "board_write_page") != 'undefined') {
		_mobile_board_write.MessageID = mobile_comm_getQueryString('messageid', "board_write_page");
		_mobile_board_write.Mode = "update";
    } else {
    	_mobile_board_write.MessageID = '';
    	_mobile_board_write.Mode = "create";
    }
	if (mobile_comm_getQueryString('msgstate', "board_write_page") != 'undefined') {
		_mobile_board_write.MsgState = mobile_comm_getQueryString('msgstate', "board_write_page");
    } else {
    	_mobile_board_write.MsgState = 'C';
    }
	if (mobile_comm_getQueryString('version', "board_write_page") != 'undefined') {
		_mobile_board_write.Version = mobile_comm_getQueryString('version', "board_write_page");
    } else {
    	_mobile_board_write.Version = '1';
    }
	if (mobile_comm_getQueryString('cuid', "board_write_page") != 'undefined') {
		_mobile_board_write.CU_ID = mobile_comm_getQueryString('cuid', "board_write_page");
    } else {
    	_mobile_board_write.CU_ID = '';
    }
    if (mobile_comm_getQueryString('bizSection', "board_write_page") != 'undefined') {
		_mobile_board_write.BizSection = mobile_comm_getQueryString('bizSection', "board_write_page");
    }

	//게시 작성 select 박스 설정
	mobile_board_setWriteSelectBox();
	
	//수정모드일 경우 기본데이터 셋팅
	//참고 : 사용자 정의 필드의 경우, mobile_board_bindBoardConfig()에서 처리됨
	if(_mobile_board_write.Mode == "update"){
		mobile_board_ModifySet(_mobile_board_write, 'Board');
	} else {
		mobile_comm_uploadhtml();
	}
	
	//게시판 환경설정 조회 (_mobile_board_write.Config에 셋팅)
	mobile_board_getBoardConfig(_mobile_board_write.FolderID, 'WRITE');
	
	//게시 환경설정 바인딩
	if(!mobile_board_bindBoardConfig('N')){
		return false;
	}	
}

//게시 작성 select 박스 설정
function mobile_board_setWriteSelectBox(){
	
	//게시판 목록 조회
	mobile_board_getTreeData(_mobile_board_write, 'WRITE');
	
	//보안구분 조회
	var url = "/groupware/mobile/board/selectSecurityLevelList.do";
	$.ajax({
		type:"POST",
		url: url,
		async:false,
		success:function(data){
			var sHtml = "";
			$.each(data.list, function(i, item){
				sHtml += "<option value='" + item.optionValue + "'>";
				sHtml += "		" + item.optionText;
				sHtml += "</option>";
			});
			$("#board_write_seclevel").html(sHtml).val(mobile_comm_getBaseConfig("DefaultSecurityLevel", mobile_comm_getSession("DN_ID")));			
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	//등록예약
	var iHR, iMIN, sTime = "";
	for (iHR = 0; iHR < 24; iHR++) { 
		for (iMIN = 0; iMIN <= 30; iMIN+=30) { 
			var tmpTime = mobile_comm_AddFrontZero(iHR, 2) + ":" + mobile_comm_AddFrontZero(iMIN, 2);
			sTime += "<option value='" + tmpTime + "'>" + tmpTime + "</option>";
		}
	}
	$("#board_reservation_time").html(sTime);
	
}

//게시 환경설정 바인딩
function mobile_board_bindBoardConfig(pIsChange){
	//$("#board_write_auth, #board_write_readauth").val("");	//권한 설정 초기화
	//$("#board_write_tagarea, #board_write_linkarea").html("");		//태그, 링크 초기화
		
	//폴더 권한 조회
	var folderACLList = mobile_board_getBoardAclList(_mobile_board_write.FolderID);	
	if(_mobile_board_write.FolderID != ""){
		if(!mobile_board_checkWriteAuthPC()){
			alert(mobile_comm_getDic("msg_noWriteAuth"), "Warning Dialog");	//해당 분류에는 쓰기 권한이 없습니다.
			$(".path").html("");
			_mobile_board_write.FolderID = "";
			$("#board_write_folder").val("");
			return false;
		}
	}
	
	//보안등급 사용처리 추가
	if(_mobile_board_write.Config.UseMessageSecurityLevel != "Y") {
		$('#board_write_seclevel').parents('div.detail_config_info').hide();
	}

	//익명게시와 부서명 게시를 모두 사용하지 않을 경우
	if(_mobile_board_write.Config.UseAnony != "Y" && _mobile_board_write.Config.UsePubDeptName != "Y"){
		$('#board_write_anonym').parents('div.detail_config_info').hide();
	} else {
		//익명게시 사용
		if(_mobile_board_write.Config.UseAnony != "Y"){
			$('#board_write_anonym, [for=board_write_anonym]').hide();
			$('#board_write_anonymname').val(CFN_GetDicInfo(mobile_comm_getSession("USERNAME")));
		} else {
			$('#board_write_anonym, [for=board_write_anonym]').show();
			$('#board_write_anonym').parents('div.detail_config_info').show();
			$('#board_write_anonymname').val(mobile_comm_getDic("lbl_Anonymity")).attr("disabled",false);
			$('#board_write_anonym').click();
			if(_mobile_board_write.Config.UsePubDeptName == "Y"){
				_mobile_board_write.Config.UsePubDeptName = "N";
				$('#board_write_dept, [for=board_write_dept]').hide();
			}
		}
		
		//부서명 게시 사용
		if(_mobile_board_write.Config.UsePubDeptName != "Y"){
			$('#board_write_dept, [for=board_write_dept]').hide();
		} else {
			$('#board_write_dept, [for=board_write_dept]').show();
			$('#board_write_anonym').parents('div.detail_config_info').show();
			if($('#board_write_anonymname').val() == ""){
				$('#board_write_anonymname').val(mobile_comm_getSession("GR_Name"));
				$('#board_write_dept').click();
			}
		}
	}
	
	
	//첨부
	//mobile_comm_uploadhtml();
	/*//TODO : Limit 부분 추후 보완
	//Limit 설정 영역
	$("#limitFileSize").text(_mobile_board_write.Config.LimitFileSize);	//업로드 파일 용량 제한
	$("#limitLinkCount").text(_mobile_board_write.Config.LimitLinkCnt);	//링크 설정 개수 제한, 태그의 경우 고정적으로 10개
	 */	
	
	//카테고리 사용여부
	if(_mobile_board_write.Config.UseCategory == "Y"){
		$("#board_write_category").show();
		// Category(분류) 사용 여부 확인 및 값 바인딩
		mobile_board_setBoardCategory(_mobile_board_write.Config.UseCategory, _mobile_board_write.FolderID, 'board_write_category');
	} else {
		$("#board_write_category").hide();
		$("#board_write_category").prev().hide();
	}

	//TODO : 사용자정의 필드 부분 추후 보완
	//사용자정의 필드  초기화, 사용 여부 체크 후 조회
	$("#board_write_userdef").html("");
	if(_mobile_board_write.Config.UseUserForm == "Y" ){
		//게시판 환경설정에 따라 확장필드 조회 및 표시
		$("#board_write_userdef").show();
		$("#board_write_userdef").prev().show();
		$('#board_write_userdef').prev().addClass('show');
		$("#board_write_userdef").next().addClass("post_ex_area");
		mobile_board_getUserDefField("Write", _mobile_board_write.FolderID);
		//수정 모드일 시, 기존 값 바인딩
		if(_mobile_board_write.Mode){
			mobile_board_getUserDefFieldValue("Write", _mobile_board_write.Version, _mobile_board_write.MessageID);
		}
	} else {
		//board_config의 UseUserForm이 N이면 게시글의 사용자정의폼도 N으로 설정
		$("#board_write_userdef").hide();
		$("#board_write_userdef").prev().hide();
		$('#board_write_userdef').prev().removeClass('show');
		$("#board_write_userdef").next().removeClass("post_ex_area");
	}
	
	//게시판 유형이 LinkSite인 경우, url 영역 표시
	if(_mobile_board_write.Config.FolderType == "LinkSite" ){
		$("#board_write_linksite").show();
	} else {
		$("#board_write_linksite").hide();
	}
	
	//TODO : 승인프로세스
	/*//승인프로세스 사용여부
    if (status != "reply" && (_mobile_board_write.Config.UseOwnerProcess == "Y" || _mobile_board_write.Config.UseUserProcess == "Y")) {
        $("#IsApproval").val("Y");
	} else {
		$("#IsApproval").val("N");
	}*/
    
    //열람권한 설정 영역 표시 숨김, 값 설정은 api호출전 별도로 작업
    if(_mobile_board_write.Config.UseMessageReadAuth == "Y"){
    	$("#board_write_readauth").parents("div.detail_config_info").show();
    } else {
    	$("#board_write_readauth").parents("div.detail_config_info").hide();
    }
    
    $("#board_write_auth").val(JSON.stringify(folderACLList));	//폴더 선택,변경시 폴더권한 설정
    //상세권한 설정 표시/숨김
    if(_mobile_board_write.Config.UseMessageAuth == "Y"){
    	$("#board_write_auth").parents("div.detail_config_info").show();
    } else {
    	$("#board_write_auth").parents("div.detail_config_info").hide();
    }
    
    //태그 
    if(_mobile_board_write.Config.UseTag == "Y"){
    	//태그 설정항목 표시
    	$("#board_write_tags").show();
    } else {
    	//태그  설정항목 숨김
    	$("#board_write_tags").hide();
    	
    	$('#board_write_tagarea_wrap > .btn_add_tags').remove();
    	$('#board_write_taginput').val('');
    }
    
    //링크
    if(_mobile_board_write.Config.UseLink == "Y"){
    	//링크 설정항목 표시 
    	$("#board_write_links").show();
		if(mobile_comm_getQueryString('LinkCnt',"board_write_page") >= _mobile_board_write.Config.LimitLinkCnt) {
				$("#board_write_linkname").prop("readonly", true).attr("placeholder", mobile_comm_getDic("lbl_LinkCnt"));
				$("#board_write_linkurl").prop("readonly", true).attr("placeholder", mobile_comm_getDic("CPMail_limitCount").replace("{0}", _mobile_board_write.Config.LimitLinkCnt));
		}
    } else {
    	$("#board_write_links").hide();
    	//링크 설정항목 숨김
    	$("#board_write_linkarea").parent().hide();
		$("#board_write_linkarea").parent().find(".btnSurMove").removeClass("active");
		$("#board_write_linkarea").next().removeClass("active");
    }
    
    //상단공지
    if(_mobile_board_write.Config.UseTopNotice == "Y"){
    	$(".ico_notice_btn").parent().show();
    	$("#board_top").closest('dl').show();
    } else {
    	$(".ico_notice_btn").parent().hide();
    	$("#board_top").closest('dl').hide();
    }

    //팝업공지
    if(_mobile_board_write.Config.UsePopNotice == "Y"){
    	$(".ico_popup_btn").parent().show();
    	$("#board_popup").closest('dl').show();
    } else {
    	$(".ico_popup_btn").parent().hide();
    	$("#board_popup").closest('dl').hide();
    }
    
    //예약 게시, 예약 일시 
    if(_mobile_board_write.Config.UseReservation == "Y"){
    	$("#board_reservation").closest('dl').show();
    } else {
    	$("#board_reservation").closest('dl').hide();
    }
	//개별적으로 체크박스 숨김처리
	//스크랩
    if(_mobile_board_write.Config.UseScrap == "Y") {
    	$("#board_write_scrap").closest("dl").show();
    } else {
    	$("#board_write_scrap").closest("dl").hide();
    }
	
	//비밀글 
	if(_mobile_board_write.Config.UseSecret == "Y") {
    	$("#board_write_security").closest("dl").show();
    } else {
    	$("#board_write_security").closest("dl").hide();
    }
	
	/* 181205/smahn/PC정책에 따라 게시글별 설정이 불가능하도록 수정 
	//답글 사용시 답글 알림 사용여부 표시
	if(_mobile_board_write.Config.UseReply == "Y") {
    	$("#board_write_replynoti").closest("dl").show();
    } else {
    	$("#board_write_replynoti").closest("dl").hide();
    }
	*/
	
	//코멘트 사용시 코멘트 알림 사용여부 표시
	if(_mobile_board_write.Config.UseComment == "Y") {
    	$("#board_write_commnoti").closest("dl").show();
    } else {
    	$("#board_write_commnoti").closest("dl").hide();
    }
	
    //만료일 사용 여부
	if (_mobile_board_write.Config.UseExpiredDate == "Y") {
        $('#board_expired').closest('dl').show();
    } else{
		$('#board_expired').closest('dl').hide();
	}
	
	if (_mobile_board_write.Mode == 'create' && _mobile_board_write.Config.ExpireDay == 0){
		$("#board_expired_date").val("");
	} else if(_mobile_board_write.Mode == 'create'){
        var date = new Date();
        date.setFullYear(date.getFullYear());
        date.setMonth(date.getMonth());
        date.setDate(date.getDate() + parseInt(_mobile_board_write.Config.ExpireDay, 10));
        $("#board_expired_date").val(mobile_comm_replaceAll(mobile_comm_getDateTimeString2('yyyy-MM-dd hh:mm:ss', date).substring(0,10), "-","."));
        $("#board_expired").click();
    }	
	
	//본문사용 체크
	if(_mobile_board_write.Config.UseBody == "N"){
		$("#editor_wrap").hide();
	}else{
		$("#editor_wrap").show();
	}

	// 본문기본 내용
	if(_mobile_board_write.Config.DefaultContents && _mobile_board_write.Mode != "update") {
		switch (mobile_comm_getBaseConfig("MobileEditorType")) {
		case "2":
			$('#MobileEditorFrame').load(function () {
		    	setTimeout(function(){
					mobileEditor.setBody(_mobile_board_write.Config.DefaultContents.replace(/\r\n/g, '<br>'));
				}, 100);
			});
			break;
		case "1":
		default:
			$('#board_write_body').html(_mobile_board_write.Config.DefaultContents.replace(/(<br>|<br\/>|<br \/>)/g, '\r\n'));
			break;
		}
	}	
	
	//본문양식 사용여부
	if(_mobile_board_write.Config.UseBodyForm == "Y" && _mobile_board_write.Mode != "update"){
		if(mobile_comm_getBaseConfig("MobileEditorType") != "1"){
			//표시 및 조회
			$("#board_BodyForm").show();
			//no executable code. => mobile_board_bodyformlist" doesn't return anything.
			//$("#board_BodyFormID").html(mobile_board_bodyformlist(_mobile_board_write.FolderID));
			mobile_board_bodyformlist(_mobile_board_write.FolderID);
			if(pIsChange == "Y"){
				$("#board_BodyFormID").change();
			} 
		}else{
			alert(mobile_comm_getDic('msg_mobileBodyForm01')); //textarea에서는 본문양식을 지원하지 않습니다.
			$("#board_BodyForm").hide();
		}
	}else{
		//숨김처리
		$("#board_BodyForm").hide();
		$("#board_BodyFormID").html("");
	}
		
	//TODO : 알림매체 우선순위 중하 -> 추후 보완
	/*//답글, 댓글, 알림 매체를 사용할 경우
	if((_mobile_board_write.Config.UseReply == "Y" || _mobile_board_write.Config.UseComment == "Y") && g_noticeMedia.length > 0){
		$("#board_write_notification").show();
		$("#board_write_notification").html("");
		var mediaList = "";
		// DB 조회 할때는 sortKey가 0 인 데이터는 제외하고 가져와야함
		// CHECK: CodeGroup에 왜 NotificationMedia가 들어있는지 확인필요
		g_noticeMedia = g_noticeMedia.slice(1,g_noticeMedia.length);
		$.each(g_noticeMedia, function(i, item){
			mediaList += String.format("<div class='alarm type01'><span>{0}</span><a href='#' id='{1}' class='onOffBtn'><span></span></a></div>", item.CodeName, item.Code);
		});
		
		$("#divMediaList").html(mediaList);
		
		//화면에 그려진 알림 매체 리스트 스위치 이벤트 바인딩
		$("#divNoticeMedia .alarm").on('click', function(){
			if($(this).attr('id') == "NotificationMedia"){
				$(this).find('.onOffBtn').hasClass('on') == true?$('#divNoticeMedia .alarm').find('.onOffBtn').removeClass('on'):$('#divNoticeMedia .alarm').find('.onOffBtn').addClass('on');
			} else {
				$(this).find('.onOffBtn').hasClass('on') == true?$(this).find('.onOffBtn').removeClass('on'):$(this).find('.onOffBtn').addClass('on');
			}
		});
	} else {
		$("#divNoticeMedia").hide();
	}
	*/
	$("#board_write_notification").hide();
	
	if($("#board_write_folder").val() == "" || $("#board_write_folder").val() == null || $("#board_write_folder").val() == undefined){
		$("#mobile_write_detail").hide();
		$("#mobile_write_detail").removeClass('show').removeClass("acc_open").addClass('acc_close');
	} else {
		$("#mobile_write_detail").show();
	}
	
	if(_mobile_board_write.Config.UseExpiredDate != 'Y' && _mobile_board_write.Config.useTopNotice != 'Y' 
		&& _mobile_board_write.Config.UsePopNotice != 'Y' && _mobile_board_write.Config.UseReservation != 'Y'){
		$(".detail_config_date_wrap").closest('div').hide();
	} else {
		$(".detail_config_date_wrap").closest('div').show();
	}
}

/* 
* 1. getUserDefField
* 2. renderUserDefFieldView : FieldSize 및 Element, CSS Class 처리를 위한 분기처리 시작 
*    renderUserDefFieldWrite 
* 3. renderControlView		: Span, SelecBox, Checkbox, Radio Element 생성
*    renderControlWrite     : Input, TextArea, DateTime, SelectBox, Checkbox, Radio Element 생성
* 4. getOptionByFieldType   : 체크박스, 라디오버튼, SelectBox생성
* 5. getUserDefFieldValue   : 수정, 상세조회시 기설정값 셋팅
*/
function mobile_board_getUserDefField(pPageType, pFolderID, pFieldList){
	
	var sUrl = "/groupware/mobile/board/selectUserDefFieldList.do";
	$.ajax({
		type:"POST",
		url:sUrl,
		data:{
       		"folderID": pFolderID,
       	},
       	async: false,
       	success:function(data){
       		var fieldList = data.list;
       		if(pPageType == "View"){
       			mobile_board_renderUserDefFieldView(fieldList);
       		} else if(pPageType == "Write") {
       			mobile_board_renderUserDefFieldWrite(fieldList);
       		} 
       	},
       	error:function(response, status, error){
       		mobile_comm_ajaxerror(sUrl, response, status, error);
   		}
	});
}

//pPageType: View, Write
//pFieldObj: UserDefField 테이블 조회 Object, board_userform 테이블 참조
function mobile_board_renderUserDefFieldView(pFieldList){
	$("#board_view_userdef").html('');
	var cnt = pFieldList.length;
	for(var idx = 0; idx < cnt; idx++){
		
		var divWrap = document.createElement("div");		//사용자 정의 폼 최상위
		var item = pFieldList[idx];
		
		$(divWrap).addClass("post_ex");
		$(divWrap).append("<span id='" + item.UserFormID + "' class='th " + (item.IsCheckVal=="Y"?"input_check":"") + "'>" + item.FieldName + "</span>");
		$(divWrap).append("<span id='" + item.UserFormID + "' class='tx'>" + mobile_board_renderControlView(item) + "</span>");

		$("#board_view_userdef").append($(divWrap)).trigger("create");
	}
	$("#board_view_userdef").find("div.ui-radio, div.ui-checkbox").siblings("label").each(function(){
		$(this).remove();
	});
}

//pPageType: View, Write
//pFieldObj: UserDefField 테이블 조회 Object, board_userform 테이블 참조
function mobile_board_renderUserDefFieldWrite(pFieldList){
	var cnt = pFieldList.length;
	for(var idx = 0; idx < cnt; idx++){
		
		var divWrap = document.createElement("div");
		var item = pFieldList[idx];
		
		$(divWrap).addClass("post_ex");
		$(divWrap).append("<span id='" + item.UserFormID + "' class='th " + (item.IsCheckVal=="Y"?"input_check star":"") + "'>" + item.FieldName + "</span>");
		$(divWrap).append("<span id='" + item.UserFormID + "' class='tx'>" + mobile_board_renderControlWrite(item) + "</span>");
		
		$("#board_write_userdef").append($(divWrap)).trigger("create");
	}
	$("#board_write_userdef").find("div.ui-radio, div.ui-checkbox").siblings("label").each(function(){
		$(this).remove();
	});
	
	//datepicker 임시
	$(".input_date").attr('class', 'input_date').datepicker({
		dateFormat : 'yy.mm.dd',
		dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
	});
}

//사용자정의 필드 타입별 HTML return
function mobile_board_renderControlView(pObj){
	switch (pObj.FieldType){
		case "Input":
		case "TextArea":
		case "Date":
			return "<span userformid='" + pObj.UserFormID + "' name='UserForm_" + pObj.UserFormID + "'></span>";
			break;
		case "DropDown":
			return mobile_board_getOptionByFieldType(pObj.UserFormID, pObj.FieldType, pObj.IsCheckVal);
			break;
		case "Radio":
			return mobile_board_getOptionByFieldType(pObj.UserFormID, pObj.FieldType, pObj.IsCheckVal);
			break;
		case "CheckBox":
			return mobile_board_getOptionByFieldType(pObj.UserFormID, pObj.FieldType, pObj.IsCheckVal);
			break;
		default:
	}
}

//사용자정의 필드 타입별 HTML return
function mobile_board_renderControlWrite(pObj){
	switch (pObj.FieldType){
		case "Input":
			return "<input userformid='" + pObj.UserFormID + "' name='UserForm_" + pObj.UserFormID + "' class='post_ex_i_text' type='text' maxlength='" + pObj.FieldLimitCnt + "' isCheck='" + pObj.IsCheckVal + "'/>";
			break;
		case "TextArea": //cols="80"
			return "<textarea userformid='" + pObj.UserFormID + "' name='UserForm_" + pObj.UserFormID + "' class='post_ex_textarea' maxlength='" + pObj.FieldLimitCnt + "' isCheck='" + pObj.IsCheckVal + "'/>";
			break;
		case "Radio":
			return mobile_board_getOptionByFieldType(pObj.UserFormID, pObj.FieldType, pObj.IsCheckVal);
			break;
		case "CheckBox":
			return mobile_board_getOptionByFieldType(pObj.UserFormID, pObj.FieldType, pObj.IsCheckVal);
			break;
		case "Date":
			return "<input userformid='" + pObj.UserFormID + "' name='UserForm_" + pObj.UserFormID + "' isCheck='" + pObj.IsCheckVal + "' date_separator='.' kind='date' type='text' data-axbind='date' class='input_date date_time' style='width: 120px; height: 26px;'>";
			break;
		case "DropDown":
			return mobile_board_getOptionByFieldType(pObj.UserFormID, pObj.FieldType, pObj.IsCheckVal);
			break;
		default:
	}
}

//사용자 정의 필드 옵션 조회 
//checkbox, radio button, selectbox
//status: Create, Update 변수에 따라 설정값 조회 여부를 체크 한다.
function mobile_board_getOptionByFieldType(pUserFormID, pFieldType, pIsCheckVal){
	
	var sUrl = "/groupware/mobile/board/selectUserDefFieldOptionList.do";
	var optionHtml = "";
	
	$.ajax({
		type:"POST",
		url:sUrl,
		data:{
       		"userFormID": pUserFormID,
       	},
       	async: false,
       	success:function(data){
			var isCreate = (mobile_comm_getQueryString('messageid', 'board_write_page') == 'undefined' && mobile_comm_getQueryString('messageid', 'board_view_page') == 'undefined')
       		$(data.list).each(function(i, item){
       			switch (pFieldType)  {
	                case "DropDown":
	                	optionHtml += "<option value='" + item.OptionValue + "' data-dic='"+item.OptionName+"' "+((item.OptionCheck == 'Y' && isCreate) ? 'selected' : '')+">" + mobile_comm_getDicInfo(item.OptionName) + "</option>";
                        break;
	                case "CheckBox":
	                	optionHtml += "<input type='checkbox' id='" + item.OptionID + "' userformid='" + pUserFormID + "' name='UserForm_" + pUserFormID + "' value='" + item.OptionValue + "' isCheck='" + pIsCheckVal + "' data-dic='"+item.OptionName+"' "+((item.OptionCheck == 'Y' && isCreate) ? 'checked' : '')+">";
	                	optionHtml += "<label for='" + item.OptionID + "'>" + mobile_comm_getDicInfo(item.OptionName) + "</label>";
                        break;
	                case "Radio":
	                	optionHtml += "<input type='radio' id='" + item.OptionID + "' userformid='" + pUserFormID + "' name='UserForm_" + pUserFormID + "' value='" + item.OptionValue + "' isCheck='" + pIsCheckVal + "' data-dic='"+item.OptionName+"' "+((item.OptionCheck == 'Y' && isCreate) ? 'checked' : '')+">";
	                	optionHtml += "<label for='" + item.OptionID + "'>" + mobile_comm_getDicInfo(item.OptionName) + "</label>";
                        break;
       			}
       		});
       		
       		var tmpOptionHtml = optionHtml;
       		if(pFieldType == "DropDown"){
       			optionHtml =		"<select userformid='" + pUserFormID + "' name='UserForm_" + pUserFormID + "' isCheck='" + pIsCheckVal + "'>";
       			optionHtml += 	"		<option value=''>" + mobile_comm_getDic("msg_Select") + "</option>";
       			optionHtml += 			tmpOptionHtml;
       			optionHtml += 	"</select>";
       		} else if(pFieldType == "CheckBox"){
       			optionHtml =		"<span class='input_check'>";
       			optionHtml +=			tmpOptionHtml;
       			optionHtml +=	"</span>";
       		} else if(pFieldType == "Radio"){
       			optionHtml =		"<span class='input_radio'>";
       			optionHtml +=			tmpOptionHtml;
       			optionHtml +=	"</span>";
       		}
       	},
       	error:function(response, status, error){
       		mobile_comm_ajaxerror(sUrl, response, status, error);
   		}
	});
	return optionHtml;
}
	
//게시판 권한 조회
function mobile_board_getBoardAclList(pFolderID){	
	var aclList = [];
	$.ajax({
		type:"POST",
		data: {
			"objectID": pFolderID
			,"objectType": "FD"
		},
		url: "/groupware/mobile/board/selectBoardACLData.do",
		async:false,
		success:function(data){
			$.each(data.data, function(i, item){
				var aclObj = new Object;
				var aclShard = "";
				aclShard += item.AclList.indexOf("S")!=-1?"S":"_";
				aclShard += item.AclList.indexOf("C")!=-1?"C":"_";
				aclShard += item.AclList.indexOf("D")!=-1?"D":"_";
				aclShard += item.AclList.indexOf("M")!=-1?"M":"_";
				aclShard += item.AclList.indexOf("E")!=-1?"E":"_";
				aclShard += item.AclList.indexOf("R")!=-1?"R":"_";
				
				aclObj.TargetType = item.SubjectType;
				aclObj.TargetCode = item.SubjectCode;
				aclObj.DisplayName = item.SubjectName;
				aclObj.AclList = aclShard;
				aclList.push(aclObj);
			});
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror("/groupware/mobile/selectBoardACLData.do", response, status, error);
		}
	});
	return aclList;
}

//사용자 정의 필드 정보 조회
//pPageType : "View", "Write"
function mobile_board_getUserDefFieldValue(pPageType, pVersion, pMessageID) {
	var sUrl = "/groupware/mobile/board/selectUserDefFieldValue.do";
	var targetObj = $("#board_" + pPageType.toLowerCase() + "_userdef");
	$.ajax({
		type:"POST",
		data: {
			"messageID": pMessageID,
			"version": pVersion,
		},
		url:sUrl,
		success:function(data){
			var fieldList = data.list;
			$(fieldList).each(function(idx, item){
				var fieldObj = $(targetObj).find("[name=UserForm_"+item.UserFormID+"]");
				
				//체크박스와 라디오 버튼은 UserFormID와 value로 식별
				if(fieldObj.attr("type") == "checkbox"){
					var checkboxVal = item.FieldValue.slice(1, item.FieldValue.length -1);
					if (item.FieldValue && item.FieldValue != '' && item.FieldValue.indexOf(";")!=-1){
						var valueArr = checkboxVal.split(';');
						$.each(valueArr, function(checkBoxIndex, checkedItem){
							$(targetObj).find("[name=UserForm_"+item.UserFormID+"][value=" + checkedItem + "]").prop("checked", true).checkboxradio("refresh");
						});
					} else {
						//단일 체크박스일경우 라디오와 동일하게 처리
						$(targetObj).find("[name=UserForm_"+item.UserFormID+"][value=" + item.FieldValue + "]").prop("checked", true).checkboxradio("refresh");
					}
					if(pPageType == "View"){
						fieldObj.parent().children().attr("style", "pointer-events: none;");
					} else {
						fieldObj.parent().children().attr("style", "");
					}
				} else if (fieldObj.attr("type") == "radio"){
					$(targetObj).find("[name=UserForm_"+item.UserFormID+"][value=" + item.FieldValue + "]").prop("checked", true).checkboxradio("refresh");
					if(pPageType == "View"){
						fieldObj.parent().children().attr("style", "pointer-events: none;");
					} else {
						fieldObj.parent().children().attr("style", "");
					}
				} else if(pPageType == "View" && !fieldObj.is("select")){
					fieldObj.text(item.FieldValue);
				} else if(pPageType == "View" && fieldObj.is("select")){
					fieldObj.val(item.FieldValue).attr("style", "pointer-events: none;");
				} else {
					fieldObj.val(item.FieldValue);
				}
			});
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(sUrl, response, status, error);
		}
	});
}

//본문양식 리스트
function mobile_board_bodyformlist(pFolderID){
	var optionHtml = "";
	var tmpOptionHtml = optionHtml;

	var url = "/groupware/board/selectBodyFormList.do";
	$.ajax({
		type:"POST",
		url: url,
		async:false,
		data:{
			"folderID": pFolderID
		},
		success:function(data){
			var sHtml = "";
			$.each(data.list, function(i, item){
				sHtml += "<option value='" + item.optionValue + "'>";
				sHtml += "		" + item.optionText;
				sHtml += "</option>";
			});
			$("#board_BodyFormID").html(sHtml);
			mobile_board_bodyformdata($("#board_BodyFormID").val(), "N");
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

function mobile_setEditor(g_editorBody){
	$('#MobileEditorFrame').load(function () {
    	setTimeout(function(){
			mobileEditor.setBody(unescape(g_editorBody));
		},100);
	});
}

//pBodyFormID - 본문양식ID
//editorBind - 에디터 바인딩 여부 (에디터 바인딩  후에 바인딩되어야하므로 초기양식은 바로 바인딩되면 X) 
function mobile_board_bodyformdata(pBodyFormID, editorBind){
	var g_formExtention = ""; //본문양식 확장자
	$.ajax({
 		type:"POST",
 		async:false,
 		data: {
 			"bodyFormID": pBodyFormID
 		},
 		url:"/groupware/board/selectBodyFormData.do",
 		success:function(data){
 			if(data.status=='SUCCESS'){
				g_formExtention = (data.formExtention).toLowerCase();
				if(g_formExtention == "html"){
 					g_editorBody = data.bodyForm;
				}else if(g_formExtention == "txt"){
					var EditBodyForm = data.bodyForm;
					EditBodyForm = EditBodyForm.split(' ').join('&nbsp;');	//공백 
					EditBodyForm = EditBodyForm.replace(/(\r\n|\n|\n\n)/gi, '<br />');	//줄바꿈
	 				g_editorBody = EditBodyForm;
				}
 				
 				if(editorBind == 'Y'){
 					mobileEditor.setBody(g_editorBody);
 				}else{
					mobile_setEditor(g_editorBody);
				}
 				
 			} else {
				alert(mobile_comm_getDic('msg_apv_030'));//오류가 발생헸습니다.
 			}
 		},
 		error:function(response, status, error){
			mobile_comm_ajaxerror("/groupware/board/selectBodyFormData.do", response, status, error);
 		}
 	});
}

//게시판 작성 권한
function mobile_board_checkWriteAuth(pAclList){	
	var bWriteFlag = false;
	$.each(pAclList, function(i, item){
		if(item.TargetType == "UR"){
			bWriteFlag = item.AclList.indexOf("C")!=-1?true:false;
			return false;
		} else {
			bWriteFlag = item.AclList.indexOf("C")!=-1?true:false;
		}
	});
	return bWriteFlag;
}

//게시판 작성 권한
function mobile_board_checkWriteAuthPC(){//TODO: 컨텐츠게시 처리 필요
	var bWriteFlag = false;
	var bizSection = _mobile_board_list.BizSection;
	if(bizSection == undefined || bizSection == "") 
		bizSection = _mobile_board_view.BizSection;
	var serviceType = _mobile_board_write.CU_ID != "" ? "Community" : bizSection;
	$.ajax({
		type:"POST",
		data: {
			"objectID": _mobile_board_write.FolderID
			,"objectType": "FD"
			,"serviceType" : serviceType
		},
		url: "/groupware/board/checkWriteAuth.do",
		async:false,
		success:function(data){
			if(data.status == 'SUCCESS'){
				bWriteFlag = data.flag;
			} else {
				bWriteFlag = false;
			}
		},
	});
	return bWriteFlag;
}

//카테고리 바인딩
function mobile_board_setBoardCategory(pUseCategory, pFolderID, pTarget){
	
	$('#' + pTarget).find('option').remove();
	$('#' + pTarget).append($('<option>', {
	        value: '',
	        text : mobile_comm_getDic("lbl_CategorySelect") /*분류선택*/
	 }));
	
	if(pUseCategory == "Y"){

		var url = "/groupware/mobile/board/selectCategoryList.do";
		$.ajax({
			url: url,
			data: {
				"folderID": pFolderID,
	 		},
			type: "post",
			async: false,
			success: function (response) {
				if(response.status == "SUCCESS") {
					for(var num in response.list){
						$('#' + pTarget).append($('<option>', { 
					        value: response.list[num].optionValue,
					        text : response.list[num].optionText
						}));
					}//for
				}
			},
			error: function (response, status, error){
				mobile_comm_ajaxerror(url, response, status, error);
			}
		});
	
		$('#' + pTarget).show();
	} else {
		$('#' + pTarget).hide();
	}
}

//게시판 목록 selectbox 바인딩
function mobile_board_SelFolderBinding(data, bizSection) {
	
	var sHtml = "";
	
	var selected = "";
	
	if(bizSection == "Board")
		sHtml += "<option value=\"\">" + mobile_comm_getDic("lbl_SelectBoard") + "</option>";//게시판 선택
	else if(bizSection == "Doc")
		sHtml += "<option value=\"\">" + mobile_comm_getDic("lbl_DocCate") + "</option>";//문서분류
	
	$(data).each(function (i, folder) {
		if(folder.FolderType.toUpperCase() != "ROOT" && folder.FolderType.toUpperCase() != "FOLDER") {
			
			//모바일에서 일정게시, 한줄게시 지원안함
			if(folder.FolderType.toUpperCase() == "CALENDAR" || folder.FolderType.toUpperCase() == "QUICKCOMMENT") {
				return true;
			}
			
			selected = "";
			if(folder.FolderID == _mobile_board_write.FolderID) {
				selected = " selected ";
			}
			
			sHtml += "<option value=\"" + folder.FolderID + "\"" + selected + ">" + ((folder.ParentFolderName == undefined) ? "" : folder.ParentFolderName + '-') + folder.DisplayName + "</option>";
			
			//TODO: 게시판 변경 시 권한체크 추가
		}
	});
	
	return sHtml;
}

//게시판 조회 바인딩
function mobile_board_ModifySet(params, bizSection) {
	
	//TODO : 다국어 처리
	$("#" + bizSection.toLowerCase() + "_write_mode").text(mobile_comm_getDic("lbl_Modify")); //수정
	if(bizSection.toLowerCase() == "board") {
		$("#board_write_tempsave").html("<span class='Hicon'>"+mobile_comm_getDic("lbl_Confirm")+"</span>"); //확인
	} else if(bizSection.toLowerCase() == "doc") {
		$("#doc_write_save").hide();
		$("#doc_write_saveRevision").show();
		$("#doc_write_confirm").show();
	}

	var paramdata = {
		bizSection: bizSection, 
		boardType: 'Normal',
		folderID: params.FolderID,
		messageID: params.MessageID,
		version: params.Version,
		communityID : params.CU_ID,
		searchText: '',
		page: 1
	};		
	
	var url = "/groupware/mobile/board/getBoardMessageView.do";
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		async: false,
		success: function (response) {
			if(response.status == "SUCCESS") {
				if(bizSection == "Board") {
					
					// 0. 버튼 설정
					if(response.view.MsgState == "C"){
						$("#board_write_tempsave").hide();
					}
						
					// 1. 글 정보
					$('#board_write_folder').val(response.view.FolderID);
					$('#board_write_title').val(response.view.Subject);
					
					// 2. 첨부처리 (TODO:)
					mobile_comm_uploadhtml(response.file);
					
					// 3. 사용자 정의필드 영역
					
					// 3.1 링크 영역
					if (response.view.FolderType == "LinkSite" && response.view.LinkURL != '') {
						$('#board_write_linksite_input').val(response.view.LinkURL);
					}
					
					// 4. 본문
					switch (mobile_comm_getBaseConfig("MobileEditorType")) {
						case "2"://TinyMCE(기본)
							$('#MobileEditorFrame').load(function () {
						    	setTimeout(function(){
									mobileEditor.setBody(unescape(response.view.Body));
								},100);
							});
							break;
						case "1"://textarea
						default:
							$('#board_write_body').html(response.view.BodyText.replace(/(<br>|<br\/>|<br \/>)/g, '\r\n'));
							break;
					}
					
					// 5. 태그
					if(response.tag.length > 0) {
						var sTagHtml = "";
						$(response.tag).each(function (i, taginfo){
							sTagHtml += "<a href=\"javascript: mobile_board_deletetag('" + taginfo.Tag + "');\" class=\"btn_add_tags\">" + taginfo.Tag + "</a>";
						});
						$('#board_write_taginput').parent().before(sTagHtml);
						$('#board_write_taginput').show();
					}
					
					// 6. 링크
					if(response.link.length > 0) {
						var sLinkHtml = "";
						$(response.link).each(function (i, linkinfo){
							sLinkHtml += "<a href=\"javascript: mobile_board_deletelink('" + linkinfo.Title + "','" + linkinfo.Url + "');\" class=\"btn_add_links ui-link\" title=\"" + linkinfo.Title + "\" link=\"" + linkinfo.Url + "\">";
							sLinkHtml += linkinfo.Title
							sLinkHtml += "</a>";
						});
						$('#board_write_linkarea').html(sLinkHtml).parent().show();
					}
					
					// 7. 카테고리
					var sCategoryHtml = "";
					if(response.view.CategoryName != "") {
						sCategoryHtml += "<span class=\"tx\">" + mobile_comm_getDic("lbl_Cate") + " : " + response.view.CategoryName + "</span>";//분류
					}
					if(sCategoryHtml != "") {
						$('#board_write_category').html(sCategoryHtml);
						setTimeout(function(){ $('#board_write_category').val(response.view.CategoryID); }, 300);
					}
					
					// 8. 상세설정
					if(response.view.UseSecret == "Y") { //비밀글
						$('#board_write_security').show();
					}
					if(response.view.UseScrap == "Y") { //스크랩
						$('#board_write_scrap').click();
					}
					if(response.view.UseAnonym == "Y") { //익명
						$('#board_write_anonym').click();
						$('#board_write_anonymname').val(response.view.CreatorName).css('background-color', '').show();						
					}
					if(response.view.UsePubDeptName == "Y") { //부서
						$('#board_write_dept').click();
						$('#board_write_anonymname').val(response.view.CreatorDept).css('background-color', '').show();						
					}
					if(response.view.UseReplyNotice == "Y") { //답글알림
						$('#board_write_replynoti').click();
					}
					if(response.view.UseCommNotice == "Y") { //댓글알림
						$('#board_write_commnoti').click();
					}
					if(response.view.SecurityLevel != null) { //보안등급
						$('#board_write_seclevel').val(response.view.SecurityLevel);
					}
					if(response.view.NoticeMedia != null) { //알림
						var targetTxt = (response.view.NoticeMedia).toString();
						$('#board_write_notification div.opt_setting').each(function (){
							var divValue = $(this).attr("value") + ";";
							if( targetTxt.indexOf(divValue) > -1){
								$(this).click();
							}
						});
					}
					if(response.view.ExpiredDate != "") { //만료일
						$('#board_expired').click();
						$("#board_expired_date").val(mobile_comm_replaceAll(response.view.ExpiredDate, ".", "-"));
					}
					if(response.view.IsTop == "Y") { //상단공지
						if(response.view.TopStartDate != undefined && response.view.TopEndDate != undefined){
							$('.ico_notice_btn').click();
							$("#board_top_start").val(mobile_comm_replaceAll(response.view.TopStartDate, ".", "-"));
							$("#board_top_end").val(mobile_comm_replaceAll(response.view.TopEndDate, ".", "-"));
						}
					}
					if(response.view.IsPopup == "Y") { //팝업공지
						if(response.view.PopupStartDate != undefined && response.view.PopupEndDate != undefined){
							$('.ico_popup_btn').click();
							$("#board_popup_start").val(mobile_comm_replaceAll(response.view.PopupStartDate, ".", "-"));
							$("#board_popup_end").val(mobile_comm_replaceAll(response.view.PopupEndDate, ".", "-"));
						}
					}
					if(response.view.ReservationDate != undefined) { //등록예약
						$('#board_reservation').click();
						$("#board_reservation_date").val(mobile_comm_replaceAll(response.view.ReservationDate.substring(0,10), ".", "-"));
						$("#board_reservation_time").val(response.view.ReservationDate.substring(11,13) + ":" + response.view.ReservationDate.substring(14,16));
					}
					if(response.readauth != null && response.readauth != undefined && response.readauth.length > 0 ) { //열람권한
						var sReadAuthHtml = "";
						$(response.readauth).each(function (i, authInfo){
							sReadAuthHtml += "	<a onclick=\"mobile_board_delUser(this, 'readauth');\" class=\"btn_add_person\" objectcode=\"" + authInfo.TargetCode + "\" objecttype_a=\"" + authInfo.TargetType + "\" value=\"" + authInfo.DisplayName + "\">" + mobile_comm_getDicInfo(authInfo.DisplayName) + "</a>"
						});
						$('#board_write_readauth').html(sReadAuthHtml).show();
					}
					if(response.auth != null && response.auth != undefined && response.auth.length > 0 ) { //상세권한
						var sAuthHtml = "";
						$(response.auth).each(function (i, authInfo){
							sAuthHtml += "<div class=\"btn_add_person_wrap\">";
							sAuthHtml += "	<a onclick=\"mobile_board_getSelectedAclData(this);\" class=\"btn_add_person\" style=\"background-image: none;\" aclList=\"" + authInfo.AclList + "\" objectcode=\"" + authInfo.TargetCode + "\" objecttype_a=\"" + authInfo.TargetType + "\" displayname=\"" + authInfo.DisplayName + "\" issubinclude=\"" + authInfo.IsSubInclude + "\">" + authInfo.DisplayName + "</a>";
							sAuthHtml += "	<a onclick=\"mobile_board_delUser(this, 'auth');\" class=\"btn_close\"></a>";
							sAuthHtml += "</div>";
						});
						$('#board_write_auth').html(sAuthHtml).show();
						$('#board_write_switchList').show();
						
						$("#board_write_auth").find('div.btn_add_person_wrap').first().addClass("selected");
							var aclList = $("#board_write_auth").find('div.btn_add_person_wrap a').first().attr('aclList');
							var aclShard = aclList.split("");
							selectedACL = $("#board_write_auth").find('div.btn_add_person_wrap a').first();
							
							aclShard[0] != "_"?$("#board_write_btnSecurity").addClass("on"):$("#board_write_btnSecurity").removeClass("on");
							aclShard[1] != "_"?$("#board_write_btnCreate").addClass("on"):$("#board_write_btnCreate").removeClass("on");
							aclShard[2] != "_"?$("#board_write_btnDelete").addClass("on"):$("#board_write_btnDelete").removeClass("on");
							aclShard[3] != "_"?$("#board_write_btnModify").addClass("on"):$("#board_write_btnModify").removeClass("on");
							aclShard[4] != "_"?$("#board_write_btnExecute").addClass("on"):$("#board_write_btnExecute").removeClass("on");
							aclShard[5] != "_"?$("#board_write_btnRead").addClass("on"):$("#board_write_btnRead").removeClass("on");
							
							var IsSubInclude = $("#board_write_auth").find('div.btn_add_person_wrap a').first().attr('issubinclude');
							IsSubInclude == "Y" ? $("#board_write_btnIsSubInclude").addClass("on") : $("#board_write_btnIsSubInclude").removeClass("on");
							
							// 사용자 일때 하위포함 스위치를 표시하지 않는다.
							var ObjectType_A = $("#board_write_auth").find('div.btn_add_person_wrap a').first().attr('objecttype_a');
							ObjectType_A == "UR" ? $("#IsSubInclude_SwitchArea").hide() : $("#IsSubInclude_SwitchArea").show();
					}
				} else if(bizSection == "Doc") {
					// 1. 글 정보
					$('#doc_write_folder').val(response.view.FolderID);
					$('#doc_write_title').val(response.view.Subject);						
					$('#doc_write_docNumber').val(response.view.Number).prop("disabled", true).trigger("create");					
					
					// 2. 첨부처리 (TODO:)
					if(response.view.MsgType != 'B'){
						mobile_comm_uploadhtml(response.file); 
					}
					
					// 3. 본문
					$('#doc_write_body').html(response.view.BodyText.replace(/(<br>|<br\/>|<br \/>)/g, '\r\n'));
					
					// 4. 상세설정
					// 등록자
					$('#doc_write_creatorName').html(response.view.CreatorName);
					
					// 등록부서
					mobile_doc_setCreatorDept();
					$('#doc_write_registDept option:contains(' + response.view.CreatorDept + ')').attr("selected", "selected");
					
					// 소유자
					if(response.view.OwnerCode.length > 0) {
						var ownerCode = response.view.OwnerCode.split(";");
						var ownerName = response.view.OwnerName.split(";");
						
						for(var i = 0; i < ownerCode.length; i++) {
							if($("#doc_write_owner").find("a[value='" + ownerCode[i] + "']").length == 0) {
								$("#doc_write_owner").append("<a onclick=\"mobile_doc_delUser(this, 'owner');\" class=\"btn_add_person\" value=\"" + ownerCode[i] + "\">" + ownerName[i] + "</a>");
							}
						}
						
						$("#doc_write_owner").show();
					}
					
					// 보존기한
					if(response.view.KeepYear != "" && response.view.KeepYear != undefined) {
						$('#doc_write_selectKeepyear').val(response.view.KeepYear);
					} else if(response.view.ExpiredDate != "" && response.view.ExpiredDate != undefined) {
						var expireYear = CFN_TransLocalTime(response.view.ExpiredDate).split(".")[0];
						var registYear = CFN_TransLocalTime(response.view.RegistDate).split(".")[0];
						$('#doc_write_selectKeepyear').val(expireYear - registYear);
						
					} else {
						$('#doc_write_selectKeepyear').val(3);
					}
					if(response.view.SecurityLevel != null) { //보안등급
						$('#doc_write_seclevel').val(response.view.SecurityLevel);
					}
					mobile_doc_changeKeepYear($("#doc_write_selectKeepyear"));
					
					// 상세권한
					//mobile_doc_getMessageAuth();
					if(response.auth != null && response.auth != undefined && response.auth.length > 0 ) { //상세권한
						var sAuthHtml = "";
						$(response.auth).each(function (i, authInfo){
							sAuthHtml += "<div class=\"btn_add_person_wrap\">";
							sAuthHtml += "	<a onclick=\"mobile_doc_getSelectedAclData(this);\" class=\"btn_add_person\" style=\"background-image: none;\" aclList=\"" + authInfo.AclList + "\" objectcode=\"" + authInfo.TargetCode + "\" objecttype_a=\"" + authInfo.TargetType + "\" displayname=\"" + authInfo.DisplayName + "\" issubinclude=\"" + authInfo.IsSubInclude + "\">" + authInfo.DisplayName + "</a>";
							sAuthHtml += "	<a onclick=\"mobile_doc_delUser(this, 'auth');\" class=\"btn_close\"></a>";
							sAuthHtml += "</div>";
						});
						
						$('#doc_write_auth').html(sAuthHtml).show();
						$('#doc_write_switchList').show();
						
						$("#doc_write_auth").find('div.btn_add_person_wrap').first().addClass("selected");
						var aclList = $("#doc_write_auth").find('div.btn_add_person_wrap a').first().attr('aclList');
						var aclShard = aclList.split("");
						selectedACL = $("#doc_write_auth").find('div.btn_add_person_wrap a').first();
						
						aclShard[0] != "_"?$("#doc_write_btnSecurity").addClass("on"):$("#doc_write_btnSecurity").removeClass("on");
						aclShard[1] != "_"?$("#doc_write_btnCreate").addClass("on"):$("#doc_write_btnCreate").removeClass("on");
						aclShard[2] != "_"?$("#doc_write_btnDelete").addClass("on"):$("#doc_write_btnDelete").removeClass("on");
						aclShard[3] != "_"?$("#doc_write_btnModify").addClass("on"):$("#doc_write_btnModify").removeClass("on");
						aclShard[4] != "_"?$("#doc_write_btnExecute").addClass("on"):$("#doc_write_btnExecute").removeClass("on");
						aclShard[5] != "_"?$("#doc_write_btnRead").addClass("on"):$("#doc_write_btnRead").removeClass("on");
						
						var IsSubInclude = $("#doc_write_auth").find('div.btn_add_person_wrap a').first().attr('issubinclude');
						IsSubInclude == "Y" ? $("#doc_write_btnIsSubInclude").addClass("on") : $("#doc_write_btnIsSubInclude").removeClass("on");
						
						// 사용자 일때 하위포함 스위치를 표시하지 않는다.
						var ObjectType_A = $("#doc_write_auth").find('div.btn_add_person_wrap a').first().attr('objecttype_a');
						ObjectType_A == "UR" ? $("#IsSubInclude_SwitchArea").hide() : $("#IsSubInclude_SwitchArea").show();
					}
					
					// 연결문서
					var sLinkedHtml = "";
					var sLinkedHidden = "";
					
					sLinkedHidden += "[";
					$(response.linked).each(function (i, linkedinfo) {
						sLinkedHtml += "<a onclick='mobile_doc_delLinkedDoc(this);' class='btn_add_person' targetid='" + linkedinfo.MessageID + "' version='" + linkedinfo.Version + "' value='" + JSON.stringify(linkedinfo) + "'>" + linkedinfo.DisplayName + "</a>";
						sLinkedHidden += JSON.stringify(linkedinfo);
						if(response.linked.length - 1 != i){
							sLinkedHidden += ",";
						}
					});
					sLinkedHidden += "]";
					
					$("#doc_write_linkedDocList").append(sLinkedHtml);
					if(response.linked.length > 0) $("#doc_write_linkedDocList").show();
					
					$("#doc_write_hiddenLinkedDocList").val(sLinkedHidden);
				}	
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

function mobile_doc_getMessageAuth() {
	$.ajax({
		type:"POST",
		data: {
			"messageID": _mobile_board_write.MessageID,
			"version": _mobile_board_write.Version,
		},
		url:"/groupware/mobile/board/selectMessageAuthList.do",
		success:function(data){
			var sHtml = "";
			if(JSON.stringify(data.list) != "") {
				var acl = JSON.parse(JSON.stringify(data.list));
				var isAdded = false;
				$(acl).each(function(i, item){
					isAdded = false;
					$("#doc_write_auth").find("div>a.btn_add_person").each(function(i, person) {
						if($(person).attr("objectcode") == item.TargetCode && $(person).attr("objecttype_a") == item.TargetType) isAdded = true;
					});
					if(!isAdded) {
						sHtml += "<div class=\"btn_add_person_wrap\">";
						sHtml += "	<a onclick=\"mobile_doc_getSelectedAclData(this);\" class=\"btn_add_person\" aclList=\"" + item.AclList + "\" objectcode=\"" + item.TargetCode + "\" objecttype_a=\"" + item.TargetType + "\" displayname=\"" + mobile_comm_getDicInfo(item.DisplayName) + "\" issubinclude=\"" + authInfo.IsSubInclude + "\">" + mobile_comm_getDicInfo(item.DisplayName) + "</a>";
						sHtml += "	<a onclick=\"mobile_doc_delUser(this, 'auth');\" class=\"btn_close\"></a>";
						sHtml += "</div>";
					}
				});
				
				$('#doc_write_auth').append(sHtml).show();				
				$('#doc_write_switchList').show();
			}
		},
		error:function(response, status, error){
		     //TODO 추가 오류 처리
		     mobile_comm_ajaxerror("/groupware/mobile/board/selectMessageAuthList.do", response, status, error);
		}
	});
}

//게시글 임시저장
function mobile_board_tempsave() {	
	mobile_board_save("T");
}

//게시글 저장
function mobile_board_save(pMsgState) {
	
	if(pMsgState != undefined){
		_mobile_board_write.MsgState = pMsgState;
	}
	
	if(!mobile_board_savevalidation()) {
		return;
	}
	
	//Multipart 업로드를 위한 formdata객체 사용 
	var formData = new FormData();
	
	formData.append("bizSection", "Board");
	formData.append("mode", _mobile_board_write.Mode);
	formData.append("folderID", _mobile_board_write.FolderID);
	
	if(_mobile_board_write.Config.UseCategory == "Y") {
		formData.append("categoryID", $('#board_write_category').val());
	}
	
	if(_mobile_board_write.Config.FolderType == "LinkSite") {
		formData.append("LinkURL", $('#board_write_linksite_input').val());
	}
		
	formData.append("subject", $('#board_write_title').val());
	
	//상단공지
	if($('.ico_notice_btn').hasClass('on')) {
		formData.append("isTop", "Y");
		formData.append("topStartDate", $("#board_top_start").val() + " 00:00:00");
		formData.append("topEndDate", $("#board_top_end").val() + " 23:59:59");
	} else {
		formData.append("isTop", "N");
	}
	
	//팝업공지
	if($('.ico_popup_btn').hasClass('on')) {
		formData.append("isPopup", "Y");
		formData.append("popupStartDate", $("#board_popup_start").val() + " 00:00:00");
		formData.append("popupEndDate", $("#board_popup_end").val() + " 23:59:59");
	} else {
		formData.append("isPopup", "N");
	}

	//파일
	formData.append("fileInfos", JSON.stringify(mobile_comm_uploadfilesObj.fileInfos));
	var filescnt = mobile_comm_uploadfilesObj.files.length;
	for (var i = 0; i < filescnt; i++) {
    	if (typeof mobile_comm_uploadfilesObj.files[i] == 'object') {
    		formData.append("files", mobile_comm_uploadfilesObj.files[i]);
        }
    }
	formData.append("fileCnt", mobile_comm_uploadfilesObj.fileInfos.length);
	
	//본문
	switch (mobile_comm_getBaseConfig("MobileEditorType")) {//TinyMCE(기본)
		case "2":
			formData.append("body", escape(mobileEditor.getBody()));
			formData.append("bodyText", mobileEditor.getBodyText());
			formData.append("bodySize", mobileEditor.getBodyText().length);
			formData.append("bodyInlineImage", escape(mobileEditor.getImages()));
			formData.append("bodyBackgroundImage", escape(mobileEditor.getBackgroundImage()));
			if(AwsS3.isActive()){
				formData.append("frontStorageURL", escape(mobile_comm_getGlobalProperties("mobile.smart4j.path")+"/covicore/common/photo/photo.do?img="+mobile_comm_getGlobalProperties("frontAwsS3.path")));
			}else{
				formData.append("frontStorageURL", escape(mobile_comm_getGlobalProperties("mobile.smart4j.path")+ mobile_comm_getBaseConfig("FrontStorage")));
			}
			break;
		case "1"://textarea
		default:
			formData.append("body", $('#board_write_body').val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />'));
			formData.append("bodyText", $('#board_write_body').val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />'));
			formData.append("bodySize", $('#board_write_body').val().length);
			break;
	}
	
	//태그
	if($('#board_write_tagarea > div > a').length > 0) {
		var tagArray = [];
		$('#board_write_tagarea > div > a').each(function (){
			var tagObj = new Object();
			tagObj.Tag = $(this).text();
        	tagArray.push(tagObj);
		});
		
		formData.append("tagList", encodeURIComponent(JSON.stringify(tagArray)));
	}
	
	//링크
	if($('#board_write_linkarea > a').length > 0) {
		var linkArray = [];
		$('#board_write_linkarea > a').each(function (){
			var linkObj = new Object();
			linkObj.Title = $(this).attr("title");
			linkObj.Link = $(this).attr("link");
			linkArray.push(linkObj);
		});
		
		formData.append("linkList", encodeURIComponent(JSON.stringify(linkArray)));
	}
	

	formData.append("useSecurity", ($('#board_write_security').hasClass('on') ? "Y":"N"));
	formData.append("useScrap", ($('#board_write_scrap').hasClass('on') ? "Y":"N"));
	formData.append("useReplyNotice", ($('#board_write_replynoti').hasClass('on') ? "Y":"N"));
	formData.append("useCommNotice", ($('#board_write_commnoti').hasClass('on') ? "Y":"N"));
	
	formData.append("useAnonym", ($('#board_write_anonym').is(":checked") ? "Y":"N"));
	formData.append("usePubDeptName", ($('#board_write_dept').is(":checked") ? "Y":"N"));

	formData.append("securityLevel", $('#board_write_seclevel').val() == null ? "" : $('#board_write_seclevel').val());
	
	//열람권한
	if(_mobile_board_write.Config.UseMessageReadAuth == "Y") {
		if($('#board_write_readauth a.btn_add_person').length > 0) {
			var sReadAuth = "";
			$('#board_write_readauth a.btn_add_person').each(function (){
				sReadAuth += ";" + $(this).attr("objectcode") + "|" + $(this).attr("objecttype_a") + "|" + $(this).text();
			});
			formData.append("messageReadAuth", sReadAuth.substring(1));
		}
	}
	
	formData.append("useMessageReadAuth", _mobile_board_write.Config.UseMessageReadAuth); // 추가
	
	//상세권한
	if(_mobile_board_write.Config.UseMessageAuth == "Y") {
		if($('#board_write_auth a.btn_add_person').length > 0) {
			var authArray = [];
			$('#board_write_auth a.btn_add_person').each(function (){
				var authObj = new Object();
				authObj.TargetType = $(this).attr("objecttype_a");
				authObj.TargetCode = $(this).attr("objectcode");
				authObj.DisplayName = $(this).attr("displayname");
				authObj.AclList = $(this).attr("acllist");
				authObj.IsSubInclude = $(this).attr("issubinclude");
				authObj.InheritedObjectID = "0";				
				authArray.push(authObj);
			});
			
			formData.append("aclList", encodeURIComponent(JSON.stringify(authArray)));
		}
	}
	
	//알림
	if($('#board_write_notification div.opt_setting').length > 0) {
		var noticeMedia = "";
		$('#board_write_notification div.opt_setting').each(function (){
			if($(this).hasClass("on")){
				noticeMedia += $(this).attr("value") + ";";
			}
		});
		formData.append("noticeMedia", noticeMedia);	
	}
	
	//만료일
	if($('#board_expired').is(":checked") && $('#board_expired_date').val() != "") {
		var expiredDate = mobile_comm_replaceAll($('#board_expired_date').val(), '.', '-');
		formData.append("expiredDate", expiredDate);	
	} else {
		formData.append("expiredDate", "2999-12-31");
	}
	
	//예약게시 설정
	if($('#board_reservation').is(":checked") 
		&& ($('#board_reservation_date').val() != "" && $('#board_reservation_time').val() != "")) {
		var reservationDateTime = $('#board_reservation_date').val() + " " + $('#board_reservation_time').val() + ":00";
		formData.append("reservationDate", reservationDateTime);	
	}
	
	//생성자
	formData.append("userName", $("#board_write_anonymname").val());
	
	//사용자 정의필드
	if(_mobile_board_write.Config.UseUserForm == "Y"){
		formData.append("fieldList", encodeURIComponent(mobile_board_setUserDefFieldData()));
	}
	
	formData.append("msgType", "O");	//O: 원본, S: 스크랩
	formData.append("version", _mobile_board_write.Version);	//TODO: 버전처리
	formData.append("msgState", _mobile_board_write.MsgState);
	formData.append("depth", "0");		//TODO: 답글처리
	formData.append("seq", "0");		//TODO: seq 처리
	formData.append("step", "0");		//TODO: step 처리
	
	//커뮤니티 파라미터 추가
	if(_mobile_board_write.CU_ID != '') {
		formData.append("CSMU", "C");		//커뮤니티 여부 추가
		formData.append("communityId", _mobile_board_write.CU_ID);		//커뮤니티 여부 추가
	}
	
	//기타 ownercode, 승인프로세스 별도처리 ??
	
	var url = "/groupware/mobile/board/createMessage.do";
	if(_mobile_board_write.Mode.toUpperCase() == "UPDATE") {
		url = "/groupware/mobile/board/updateMessage.do";
		formData.append("messageID", _mobile_board_write.MessageID);
	}
	else {
		 try {
	    	var msgTarget = JSON.parse(_mobile_board_write.Config.MessageTarget);
		    formData.append("Receivers", msgTarget.Receivers.code);
		    formData.append("Excepters", msgTarget.Excepters.code + ';' + mobile_comm_getSession("UR_Code"));
	    }
	    catch(e) {mobile_comm_log(e);}
	}
	
	// 작성중인 게시(임시저장)에서 작성중인 글을 임시 저장이 아닌 일반 게시글로 등록 시, 게시글 등록 일자를 현재로 변경.
	// 임시저장으로 저장할 시, pMsgState = T , 게시물을 수정할 시에는 pMsgState = C.
	// 게시글 수정 시는 _mobile_board_write.Mode === "update" 로 진행.
	// 작성중인 게시(임시저장)에서 작성된 내용은 _mobile_board_view.BoardType === "OnWriting"
	// 따라서 작성중인 게시물(임시저장)에서 임시저장 아닌 일반 게시글을 등록할 때 위 조건을 모두 판별하여 boardtype 지정.
	if (_mobile_board_list.BizSection === "Board" && _mobile_board_view.BoardType === "OnWriting" && _mobile_board_write.Mode ==="update" && pMsgState === "C") {
		formData.append("boardtype", "OnWriting");	
	}
	
	$.ajax({
		url: url,
		data: formData,
		type: "post",
		dataType: 'json',
		processData : false,
        contentType : false,
		success: function (response) {
			if(response.status == "SUCCESS") {
				mobile_comm_back();
				if (!_mobile_board_view.isViewPanel){
					if(_mobile_board_write.Mode.toUpperCase() == "UPDATE") {
						// 저장 후 조회 창도 닫기(수정시)
						setTimeout("mobile_comm_back()", 1000);	
					}
					setTimeout("mobile_board_clickrefresh()", 1200);
				}
				
			} else {
				alert(response.message);
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
}

//사용자 정의 필드 parameter 데이터
function mobile_board_setUserDefFieldData(){
	var fieldArray = [];
	var prevFieldID = "";
	//Element Name이 UserForm을 사용할 경우 ID와 설정된 값을 추출, checkbox, radio버튼의 설정된 값만 추출
	$("#board_write_userdef [name^=UserForm]:not([type=checkbox], [type=radio]), #board_write_userdef [name^=UserForm]:checked").each(function(i, item){
		var userDefField = {};
		
		//이전에 추가된 FieldArray의 UserFormID가 현재 추가하려는 ID와 동일하고 타입도 체크박스일때
		if(prevFieldID == $(this).attr("userformid") && $(this).attr("type") == "checkbox"){
			fieldArray[fieldArray.length-1].FieldValue += ";" + $(this).val();	//1;2;3;4 이런식으로 추가
			fieldArray[fieldArray.length-1].FieldText += "@@" + $(this).attr('data-dic');
			return true;	//fieldArray에 추가하지 않고 다음 index로 넘어감
		} else {
			//object내부 UserFormID, FieldValue 설정 후 id 동일여부 체크를 위해 변수값 갱신
			prevFieldID = $(this).attr("userformid");
			userDefField.UserFormID = $(this).attr("userformid");
	        userDefField.FieldValue = $(this).val();
	        if( $(this).attr("type") == "radio" || $(this).attr("type") == "checkbox"){
				userDefField.FieldText = $(this).attr('data-dic');
	        } else if ( $(this).is("select")){
	        	userDefField.FieldText = $(this).find(":selected").text();
	        } else {
	        	userDefField.FieldText = $(this).val();
	        }
			userDefField.FieldType = (item.tagName == 'INPUT') ? $(this).attr("type") : item.tagName.toLowerCase();
		}
    	fieldArray.push(userDefField);
	});

	$.each(fieldArray, function(idx, el){
		if (el.FieldType == 'checkbox') {
			if (el.FieldValue.right(1) != ';') el.FieldValue = el.FieldValue + ';';
			if (el.FieldValue.left(1) != ';') el.FieldValue = ';' + el.FieldValue;
			var tempArr = ['','','','','','','','','',''];
			var fieldTextArr = el.FieldText.split('@@');
			$.each(fieldTextArr, function(index, textItem){
				var langArr = textItem.split(';');
				$.each(langArr, function(langIdx, langItem){
					if(langIdx < langArr.length - 1) tempArr[langIdx] += langItem != '' ? ((tempArr[langIdx] != '') ? ',' : '') + langItem : '';
				});
			});
			el.FieldText = tempArr.join(';')+';';
		} 
	});
	
	return JSON.stringify(fieldArray); 
}

function mobile_board_validationRadio(pRadioName){
	var radioObj = $("input[name=" + pRadioName + "]");
	for (var i = 0; i < radioObj.length; i++){
		if (radioObj[i].checked) return true;
	}

    return false;
}

//validation 체크
function mobile_board_savevalidation() {
	
	if ($("#board_write_title").val() == "") {
        alert(mobile_comm_getDic("msg_board_enterTitle")); //제목을 입력해주세요.
        return false;
    }
		
	if ($("#board_write_folder").val() == "" || $.isEmptyObject(_mobile_board_write.Config)){
		alert(mobile_comm_getDic("msg_board_selectFolder"));  //게시판을 선택해주세요.
		return false;
	}
	
//	if ($("#board_write_body").val() == ""){
//		alert(mobile_comm_getDic("msg_board_enterBody"));  //본문 내용을 입력해주세요.
//		return false;
//	}
	
	if(_mobile_board_write.Config.UseCategory == "Y" && $("#board_write_category").val() == ""){
		alert(mobile_comm_getDic("msg_selCategory")); //분류를 선택해주세요.
		return false;
	}

	// 파일정보
    if(mobile_comm_uploadfilesObj.fileInfos.length > _mobile_board_write.Config.LimitFileCnt){
	    //게시판에서 설정한 첨부파일 개수 제한에 걸림
    	alert(mobile_comm_getDic("msg_ExceededNumberOfUpload"));
    	return false;
	}
	
  	if($("#board_top").is(":checked")){
		if($("#board_top_start").val() == "" || $("#board_top_end").val() == ""){
			alert(mobile_comm_getDic("msg_board_setTopNoticeDate")); //상단 공지 일자를 설정해주세요.
			return false;
		} else if($("#board_top_start").val() > $("#board_top_end").val()){
			alert(mobile_comm_getDic("lbl_NoticeTop") + " " + mobile_comm_getDic("msg_StartDateCannotAfterEndDate"));
			return false;
		}
	}
	
	if( $("#board_popup").is(":checked") && ($("#board_popup_start").val() == "" || $("#board_popup_end").val() == "")){
		alert(mobile_comm_getDic("msg_EnterPopNoticeDate")); //팝업 공지 일자를 설정해주세요.
		return false;
	}
	
    if( $("#board_top").is(":checked") && ($("#board_top_start").val() == "" || $("#board_top_end").val() == "")){
		alert(mobile_comm_getDic("msg_board_setTopNoticeDate")); //상단 공지 일자를 설정해주세요.
		return false;
	}

    if(_mobile_board_write.Config.UseAnony == "Y" && $('#board_write_anonym').is(":checked") && $("#board_write_anonymname").val() == ""){
		$('#board_write_anonymname').val(mobile_comm_getDic("lbl_Anonymity"));
	}
	
	if(_mobile_board_write.Config.UseUserForm == "Y" || mobile_comm_getBaseConfig("use" + _mobile_board_write.BizSection + "MultiCategory") == "Y"){ //사용자 정의 필드 필수값 체크
		var isUserForm = true;
		var userFormName = "";
		
		for(var ti = 0; ti < $('[name^=UserForm_][ischeck=Y]').length; ti++) {
			var $userFormObj = $('[name^=UserForm_][ischeck=Y]').eq(ti);
			var userFormType = $userFormObj.attr("type");

			if($userFormObj.val() == "" && (userFormType != "checkbox" || userFormType != "radio")){
				if($userFormObj.is('select')){
					userFormName = $userFormObj.parent().parent().parent().prev().text().split(" ").join("");
				}else if($userFormObj.is('textarea')){
					userFormName = $userFormObj.parent().prev().text().split(" ").join("");
				}else{
					userFormName = $userFormObj.parent().parent().prev().text().split(" ").join(""); 
				}

				isUserForm = false;
			} else if(userFormType == "radio" || userFormType == "checkbox"){
				if(!mobile_board_validationRadio($userFormObj.attr("name"))){
					userFormName = $userFormObj.parent().parent().parent().prev().text();
					
					isUserForm = false;
				}
			}

			if(!isUserForm){
				alert(userFormName + " " + mobile_comm_getDic("msg_EnterFieldValue"));  //필드값을 설정해주세요.
				$userFormObj.focus();
				
				return false;
			}
		}
	}
	return true;
}

//조직도 추가
function mobile_board_openOrg(pTarget) {
	
	var sUrl = "/covicore/mobile/org/list.do";
	sUrl += "?mode=Select";
	sUrl += "&addto=BoardWrite" + pTarget;
	
	window.sessionStorage["mode"] = "Select";
	window.sessionStorage["multi"] = "Y";
	window.sessionStorage["callback"] = "mobile_board_set" + pTarget + "List();";
	
	mobile_comm_go(sUrl, 'Y');
}

//조직도 콜백 함수 - 열람권한
function mobile_board_setReadAuthList() {
	$("#board_write_readauth").show();
	
	var sObjectType = "";
	var sObjectType_A = "";
	var userinfo = JSON.parse("[" + window.sessionStorage["userinfo"] + "]");
	$(userinfo).each(function(i, user) {
		sObjectType = user.itemType
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			sObjectType_A = "UR";
  		}else{ //그룹
  			switch(user.GroupType.toUpperCase()){
	  			 case "COMPANY":
	                 sObjectType_A = "CM";
	                 break;
	             case "JOBLEVEL":
	                 sObjectType_A = "JL";
	                 break;
	             case "JOBPOSITION":
	                 sObjectType_A = "JP";
	                 break;
	             case "JOBTITLE":
	                 sObjectType_A = "JT";
	                 break;
	             case "MANAGE":
	                 sObjectType_A = "MN";
	                 break;
	             case "OFFICER":
	                 sObjectType_A = "OF";
	                 break;
	             case "DEPT":
	                 sObjectType_A = "GR";
	                 break;
         	}
  		}
		$("#board_write_readauth").append("<a onclick=\"mobile_board_delUser(this, 'readauth');\" class=\"btn_add_person\" objectcode=\"" + user.AN + "\" objecttype_a=\"" + sObjectType_A + "\" value=\"" + user.AN + "\">" + mobile_comm_getDicInfo(user.DN) + "</a>");
	});
}

//조직도 콜백 함수 - 상세권한
function mobile_board_setAuthList() {
	$("#board_write_auth").show();
	$("#board_write_switchList").show();
	
    var sObjectType = "";
    var sObjectType_A = "";
    //var sObjectTypeText = "";
    var sCode = "";
    //var sDNCode = "";
    var sDisplayName = "";
    var bCheck = false;
    var sAclList = "_C__ER";
	var lang = mobile_comm_getSession("lang");
	var userinfo = JSON.parse("[" + window.sessionStorage["userinfo"] + "]");
	
	$(userinfo).each(function(i, item) {
		sObjectType = item.itemType
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			//sObjectTypeText = "사용자"; // 사용자
  			sObjectType_A = "UR";
  			sCode = item.AN;//UR_Code
	  		sDisplayName  = mobile_comm_getDicInfo(item.DN, lang);
	  		//sDNCode = item.ETID;; //DN_Code
  		}else{ //그룹
  			switch(item.GroupType.toUpperCase()){
	  			 case "COMPANY":
	                 //sObjectTypeText = mobile_comm_getDic("lbl_Company"); // 회사
	                 sObjectType_A = "CM";
	                 break;
	             case "JOBLEVEL":
	                 //sObjectTypeText = mobile_comm_getDic("lbl_JobLevel"); //직급
	                 sObjectType_A = "JL";
	                 break;
	             case "JOBPOSITION":
	                 //sObjectTypeText = mobile_comm_getDic("lbl_JobPosition"); //직위
	                 sObjectType_A = "JP";
	                 break;
	             case "JOBTITLE":
	                 //sObjectTypeText = mobile_comm_getDic("lbl_JobTitle"); //직책
	                 sObjectType_A = "JT";
	                 break;
	             case "MANAGE":
	                 //sObjectTypeText = mobile_comm_getDic("lbl_board_manage"); //관리
	                 sObjectType_A = "MN";
	                 break;
	             case "OFFICER":
	                 //sObjectTypeText = mobile_comm_getDic("lbl_vip"); //임원
	                 sObjectType_A = "OF";
	                 break;
	             case "DEPT":
	                 //sObjectTypeText = mobile_comm_getDic("lbl_dept"); // 부서
	                 sObjectType_A = "GR";
	                 break;
         	}
  		
  			sCode = item.AN
            sDisplayName = mobile_comm_getDicInfo(item.GroupName, lang);
            //sDNCode = item.DN_Code;
  		}
		
		bCheck = false;
		
 		//중복 체크 이후 sHTML로 TR 데이터 그려줌
        $('#board_write_auth').children().each(function () {
            if (($(this).children().eq(0).attr("objecttype_a").toUpperCase() == sObjectType_A.toUpperCase()) &&
                ($(this).children().eq(0).attr("objectcode") == sCode)) {
                bCheck = true;
            }
        });
        
        if(!bCheck) {
			$("#board_write_auth").append(
					   "<div class=\"btn_add_person_wrap\">"
					+ "	<a onclick=\"mobile_board_getSelectedAclData(this);\" class=\"btn_add_person\" style=\"background-image: none;\" aclList=\"" + sAclList + "\" objectcode=\"" + sCode + "\" objecttype_a=\"" + sObjectType_A + "\" displayname=\"" + sDisplayName + "\" issubinclude=\"Y\">" + sDisplayName + "</a>"
					+ "	<a onclick=\"mobile_board_delUser(this, 'auth');\" class=\"btn_close\"></a>"
					+ "</div>"
			);
        }
	});
	
	$("#board_write_auth").find('div.btn_add_person_wrap').first().addClass("selected");
	var aclList = $("#board_write_auth").find('div.btn_add_person_wrap a').first().attr('aclList');
	var aclShard = aclList.split("");
	selectedACL = $("#board_write_auth").find('div.btn_add_person_wrap a').first();
	
	aclShard[0] != "_"?$("#board_write_btnSecurity").addClass("on"):$("#board_write_btnSecurity").removeClass("on");
	aclShard[1] != "_"?$("#board_write_btnCreate").addClass("on"):$("#board_write_btnCreate").removeClass("on");
	aclShard[2] != "_"?$("#board_write_btnDelete").addClass("on"):$("#board_write_btnDelete").removeClass("on");
	aclShard[3] != "_"?$("#board_write_btnModify").addClass("on"):$("#board_write_btnModify").removeClass("on");
	aclShard[4] != "_"?$("#board_write_btnExecute").addClass("on"):$("#board_write_btnExecute").removeClass("on");
	aclShard[5] != "_"?$("#board_write_btnRead").addClass("on"):$("#board_write_btnRead").removeClass("on");
	
	var IsSubInclude = $("#board_write_auth").find('div.btn_add_person_wrap a').first().attr('issubinclude');
	IsSubInclude == "Y" ? $("#board_write_btnIsSubInclude").addClass("on") : $("#board_write_btnIsSubInclude").removeClass("on");
	
	// 사용자 일때 하위포함 스위치를 표시하지 않는다.
	var ObjectType_A = $("#board_write_auth").find('div.btn_add_person_wrap a').first().attr('objecttype_a');
	ObjectType_A == "UR" ? $("#IsSubInclude_SwitchArea").hide() : $("#IsSubInclude_SwitchArea").show();

}

//소유자/상세권한 - 사용자/부서 삭제
function mobile_board_delUser(obj, target) {
	if(target == "auth") {
		if($(obj).hasClass('on')) {
			selectedACL = null;
			$('#board_write_switchList div.opt_setting').removeClass('on');
		}
		$(obj).parent().remove();
	} else {
		$(obj).remove();
	}
	
	if($("#board_write_" + target).find("a").length == 0) {
		$("#board_write_" + target).hide();
		if(target == "auth")
			$("#board_write_switchList").hide();
	}
}

//추가된 사용자, 그룹 선택시 해당하는 권한정보를 switch에 표시한다.
function mobile_board_getSelectedAclData(pObj) {
	//이전에 선택된 항목 selected class remove 후 선택한 object의 parent에 selected class add
	$(pObj).parent().parent().find("div.btn_add_person_wrap").removeClass("selected");
	$(pObj).parent().addClass("selected");
	
	var aclList = $(pObj).attr('aclList');
	var aclShard = aclList.split("");
	selectedACL = $(pObj);
	
	aclShard[0] != "_" ? $("#board_write_btnSecurity").addClass("on") :$("#board_write_btnSecurity").removeClass("on");
	aclShard[1] != "_" ? $("#board_write_btnCreate").addClass("on") : $("#board_write_btnCreate").removeClass("on");
	aclShard[2] != "_" ? $("#board_write_btnDelete").addClass("on") : $("#board_write_btnDelete").removeClass("on");
	aclShard[3] != "_" ? $("#board_write_btnModify").addClass("on") : $("#board_write_btnModify").removeClass("on");
	aclShard[4] != "_" ? $("#board_write_btnExecute").addClass("on") : $("#board_write_btnExecute").removeClass("on");
	aclShard[5] != "_" ? $("#board_write_btnRead").addClass("on") : $("#board_write_btnRead").removeClass("on");
	
	var IsSubInclude = $(pObj).attr('issubinclude');
	IsSubInclude == "Y" ? $("#board_write_btnIsSubInclude").addClass("on") : $("#board_write_btnIsSubInclude").removeClass("on");
	
	// 사용자 일때 하위포함 스위치를 표시하지 않는다.
	var ObjectType_A = $(pObj).attr('objecttype_a');
	ObjectType_A == "UR" ? $("#IsSubInclude_SwitchArea").hide() : $("#IsSubInclude_SwitchArea").show();
}

//스위치를 사용하여 ACL설정이 변경될경우 ACL List 값 변경
function mobile_board_setSwitchACLList(pObj, index){	
	if(selectedACL != null){
		$(pObj).toggleClass("on");
		if(index != null) {
			var initAclList = "SCDMER";		
			var aclList = selectedACL.attr('aclList');
			
			var newAclList = '';
			
			for(var i = 0; i < aclList.length; i++) {
				if(i == index) {
					newAclList += aclList.charAt(i) == "_" ? initAclList.charAt(i) : "_";
				} else {
					newAclList += aclList.charAt(i);
				}
			}
			
			selectedACL.attr("aclList", newAclList);	//ACL 추출
		} else {
			// 하위포함
			var IsSubInclude = selectedACL.attr("issubinclude");
			selectedACL.attr("issubinclude", IsSubInclude == "Y" ? "N" : "Y");
		}		
	}
}

//제목 굵게
function mobile_board_titlebold() {	
	if($('.ico_bold').hasClass('on')) {
		$('#board_write_title').css('font-weight', '');
		$('.ico_bold').removeClass('on');
	} else {
		$('#board_write_title').css('font-weight', 'bold');
		$('.ico_bold').addClass('on');
	}
}

//제목 색상변경
function mobile_board_titlecolor() {
	
	if($('.setting_tit').hasClass('show')) {
		$('.setting_tit').removeClass('show');
	} else {
		$('.setting_tit').addClass('show');
	}
}
function mobile_board_titlecolor2(color) {
	$("ul.font_color_layer_list > li > a[class*='selected']").removeClass('selected');
	$("ul.font_color_layer_list > li > a[class*='" + color + "']").addClass('selected');
	
	$('.setting_tit').removeClass('show');
	
	$('#board_write_title').css('color', color);
}


//태그 추가
function mobile_board_addtag(tag) {
	if(tag == undefined) {
		tag = $('#board_write_taginput').val();
	}
	$('#board_write_taginput').val('');
	
	//빈값이면 추가안함
	if(tag == "") {
		return;
	}
	
	var sHtml = "<a href=\"javascript: mobile_board_deletetag('" + tag + "');\" class=\"btn_add_tags\">" + tag + "</a>";
	
	//동일한 값이면 추가안함
	if($('#board_write_tagarea').html().indexOf(sHtml) > -1) {
		return;
	}
	
	$('#board_write_taginput').parent().before(sHtml).show();
	
}

//태그 삭제
function mobile_board_deletetag(tag) {
	$('#board_write_tagarea > div > a').each(function (){
	   if($(this).text() == tag) {
		   $(this).remove();
	   }
	});
}

//링크 추가
function mobile_board_addlink(name, link) {
	if(name == undefined) {
		name = $('#board_write_linkname').val();
		link = $('#board_write_linkurl').val();
	}
	
	//빈값이면 추가안함
	if(name == "" || link == "") {
		alert(mobile_comm_getDic("msg_board_enterLinkURL")); //링크명과 URL을 모두 입력해주십시오.
		return;
	}
	
	var sHtml = "<a href=\"javascript: mobile_board_deletelink('" + name + "', '" + link + "');\" class=\"btn_add_links ui-link\" title=\"" + name + "\" link=\"" + link + "\">" + name + "</a>";
	
	//동일한 값이면 추가안함
	if($('#board_write_linkarea').html().indexOf(sHtml) > -1) {
		alert(mobile_comm_getDic("msg_board_alreadyAdded")); //이미 추가된 값 입니다.
		return;
	}
	
	$('#board_write_linkname').val('');
	$('#board_write_linkurl').val('');
	
	if($("#board_write_linkarea").find('a').length+1 >= _mobile_board_write.Config.LimitLinkCnt){
		$("#board_write_linkname").prop("readonly", true).attr("placeholder", mobile_comm_getDic("lbl_LinkCnt"));
		$("#board_write_linkurl").prop("readonly", true).attr("placeholder", mobile_comm_getDic("CPMail_limitCount").replace("{0}", _mobile_board_write.Config.LimitLinkCnt));
	}
	
	$('#board_write_linkarea').append(sHtml).parent().show();
	
}

//링크 삭제
function mobile_board_deletelink(name, link) {
	$('#board_write_linkarea > a').each(function (){
	   if($(this).text() == name && $(this).attr('link') == link) {
		   $(this).remove();
	   }
	});
	
	if($("#board_write_linkarea").find('a').length+1 <= _mobile_board_write.Config.LimitLinkCnt){
		$("#board_write_linkname").prop("readonly", false).attr("placeholder", mobile_comm_getDic("lbl_LinkNm"));
		$("#board_write_linkurl").prop("readonly", false).attr("placeholder", mobile_comm_getDic("msg_EnterLinkURL"));
	}
	
	if($('#board_write_linkarea').html() == '') {
		$('#board_write_linkarea').parent().hide();
	}
}

//UI 이벤트 처리
//상단공지(ico_notice_btn)의 경우, 상세설정 내의 설정도 처리 필요
function mobile_board_clickUiSetting(pObj, pClass){
	if($(pObj).hasClass(pClass)) {
		$(pObj).removeClass(pClass);
	} else {
		$(pObj).addClass(pClass);
	}
	
	//상단공지 버튼일 경우
	if($(pObj).hasClass("ico_notice_btn")){
		$("#board_top").click();
	}
	
	//팝업공지 버튼일 경우
	if($(pObj).hasClass("ico_popup_btn")){
		$("#board_popup").click();
	}
}

//사용자 정의 필드 열고/닫기
function mobile_board_opencloseuserdef() {
	if($('#board_write_userdef').prev().hasClass('show')) {
		$('#board_write_userdef').prev().removeClass('show');
		$("#board_write_userdef").hide();
	} else {
		$('#board_write_userdef').prev().addClass('show');
		$("#board_write_userdef").show();
	}
}

//상세설정 열고/닫기
function mobile_board_openclosedetail() {
	if($('#mobile_write_detail').hasClass('show')) {
		$('#mobile_write_detail').removeClass('show').removeClass("acc_open").addClass('acc_close');
	} else {
		$('#mobile_write_detail').addClass('show').removeClass("acc_close").addClass('acc_open');
	}
}

//폴더 변경
function mobile_board_changefolder(pIsChange){
	
	//folderid 값 세팅
	_mobile_board_write.FolderID = $("#board_write_folder").val();
	if(_mobile_board_write.FolderID == undefined){
		_mobile_board_write.FolderID = $("#doc_write_folder").val();
	}
	
	//환경설정 정보 조회
	mobile_board_getBoardConfig(_mobile_board_write.FolderID, 'WRITE');

	//본문 초기화
	var defaultContents = "";
	if(pIsChange == "Y"){
		if(_mobile_board_write.Config.DefaultContents) {
			g_editorBody = _mobile_board_write.Config.DefaultContents.replace(/\r\n/g, '<br>');
		} else {
			g_editorBody = defaultContents;
		}
		
		if(mobile_comm_getBaseConfig("MobileEditorType") == "2") {
			mobileEditor.setBody(g_editorBody);
		} else {
			$('#board_write_body').html(g_editorBody);
		}
	}
	
	$.mobile.activePage.attr( "id" )
	//환경설정 바인딩
	if($.mobile.activePage.attr( "data-url" ).indexOf("mobile/board/write") > -1){ //통합게시
		if(!mobile_board_bindBoardConfig('Y')) return false;
	}
	else if($.mobile.activePage.attr( "data-url" ).indexOf("mobile/doc/write") > -1){ //문서
		if(!mobile_doc_bindBoardConfig()) return false;
	}

}

//익명/부서명 게시 작성 crtl
function mobile_board_ctrlAnonymWrite(pType){
	//체크 시,
	if($("div.writerinfo input[type=checkbox][value='" + pType + "'").is(':checked') == true){
		$("div.writerinfo input[type=checkbox]").prop("checked",false).checkboxradio("refresh");
		$("div.writerinfo input[type=checkbox][value='" + pType + "'").prop("checked",true).checkboxradio("refresh");
	}
	
	var chkObj = $("div.writerinfo input[type=checkbox]:checked");
	if(chkObj.length > 0){
		if($(chkObj).attr("value") == "user"){ //익명을 체크하였을 경우
			$("#board_write_anonymname").prop('disabled', false).css('background-color', '').val(mobile_comm_getDic("lbl_Anonymity"));		
		} else { //부서명을 체크하였을 경우
			$("#board_write_anonymname").prop('disabled', true).css('background-color', '#d9d9d9').val(mobile_comm_getSession("GR_Name"));			
		}
	} else {
		if(pType == "user"){
			$("#board_write_anonymname").prop('disabled', true).css('background-color', '#d9d9d9').val(mobile_comm_getSession("USERNAME"));
		}else{
			$("#board_write_anonymname").prop('disabled', true).css('background-color', '#d9d9d9').val(mobile_comm_getSession("USERNAME"));		
		}
	}
}


//게시 작성 끝

/*!
 * 
 * 게시 상세보기
 * 
 */



function mobile_board_ViewerInit()
{	
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('messageid', "board_viewer_page") != 'undefined') {
		_mobile_board_view.MessageID = mobile_comm_getQueryString('messageid', "board_viewer_page");
    } else {
    	_mobile_board_view.MessageID = 0;
    }
	if (mobile_comm_getQueryString('page', "board_viewer_page") != 'undefined') {
		_mobile_board_view.Page = mobile_comm_getQueryString('page', "board_viewer_page");
    } else {
    	_mobile_board_view.Page = 1;
    }
	if (mobile_comm_getQueryString('pageSize', "board_viewer_page") != 'undefined') {
		_mobile_board_view.PageSize = mobile_comm_getQueryString('pageSize', "board_viewer_page");
    } else {
    	_mobile_board_view.PageSize = 10;
    }
	if (mobile_comm_getQueryString('pageSize', "board_viewer_page") != 'undefined') {
		_mobile_board_view.TotalCount = mobile_comm_getQueryString('pageSize', "board_viewer_page");
    } else {
    	_mobile_board_view.TotalCount = 0;
    }	
	mobile_board_getViewerList();	
}

//게시 상세보기 - 조회자 조회 팝업
function mobile_board_getViewerList() {
	var url = "/groupware/mobile/board/selectMessageViewerGridList.do";
	
	var paramdata = {
		messageID : _mobile_board_view.MessageID,
		page: _mobile_board_view.Page,
		pageSize: _mobile_board_view.PageSize,
		sortColumn: 'ReadDate',
		sortDirection: 'desc',
		folderID: _mobile_board_view.FolderID
	};
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		success: function (response) {
			if(response.status == "SUCCESS") {
				var sHtml = "";
				sHtml = mobile_board_getViewerListHtml(response.list);
				
				//총 데이터 개수
				var lTotalCnt =  response.totalcnt;
				_mobile_board_view.TotalCount = lTotalCnt;
				$("#board_viewer_count").text(mobile_comm_getDic("lbl_total") + " " + _mobile_board_view.TotalCount + mobile_comm_getDic("lbl_personCnt")); // 총 n명
				
				if(response.page.pageNo == 1 || sHtml.indexOf("no_list") > -1) {
					$('#board_viewer_list').html(sHtml);
				} else {
					$('#board_viewer_list').append(sHtml);
				}

				if (Math.min((paramdata.page) * paramdata.pageSize, lTotalCnt) == lTotalCnt) {
	                $('#board_viewer_more').hide();
	            } else {
	                $('#board_viewer_more').show();
	            }
				
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});	
}

function mobile_board_getViewerListHtml(boardviewerlist) {
	var sHtml = "";
	if(boardviewerlist.length > 0) {
		$(boardviewerlist).each(function (i, boardviewer){
			sHtml += "<li class=\"staff\" style=\"border-bottom: 0;\">";
			sHtml += "	<a href=\"#\" class=\"con_link\">";
			sHtml += "	<span class=\"photo\" style=\"background-image: url('" + mobile_comm_getimg(boardviewer.ReaderPhoto) + "'), url('" + mobile_comm_noperson() + "');\"></span>";
			sHtml += "		<div class=\"info\">";
			sHtml += "			<p class=\"name\">" + boardviewer.DisplayName + "</p>";
			sHtml += "			<p class=\"detail\">";
			sHtml += "				<span class=\"team\">" + boardviewer.DeptName + "</span>";
			sHtml += "				<span>" + boardviewer.JobPositionName + "</span>";
			sHtml += "			</p>";
			sHtml += "		</div>";
			sHtml += "		<div class=\"date\" style=\"color: #909090;\">";
			sHtml += "			<span>" + CFN_TransLocalTime(boardviewer.ReadDate) + "</span>";
			sHtml += "		</div>";
			sHtml += "	</a>";
			sHtml += "</li>";
		});
	}
	return sHtml;
}

//조회자
function mobile_board_message_viewer() {
	if($("#board_viewer_page").length > 0) {
		$("#board_viewer_page").remove();
	}
	
	var url = "/groupware/mobile/board/viewerlist.do";
	url += "?messageid=" + _mobile_board_view.MessageID;

	mobile_comm_go(url, "Y");
}

//게시물 삭제
function mobile_board_message_delete() {
	
	if(confirm(mobile_comm_getDic("msg_AreYouDelete"))){
		
		var url = "/groupware/mobile/board/deleteMessage.do";
	
		var paramdata = {
			messageID : _mobile_board_view.MessageID
			,version : _mobile_board_view.Version
			,bizSection : _mobile_board_view.BizSection
			,folderID: _mobile_board_view.FolderID
		};
		
		$.ajax({
			url: url,
			data: paramdata,
			type: "post",
			success: function (response) {
				if(response.status == "SUCCESS") {
					alert(mobile_comm_getDic("msg_deleteSuccess")); //성공적으로 삭제하였습니다.
					mobile_comm_back();
					mobile_board_clickrefresh();
				}
			},
			error: function (response, status, error){
				mobile_comm_ajaxerror(url, response, status, error);
			}
		});	
	}
}

//게시물 신고
function mobile_board_message_report() {
	var url = "/groupware/mobile/board/reportMessage.do";
	
	var paramdata = {
		messageID : _mobile_board_view.MessageID
	};
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		success: function (response) {
			if(response.status == "SUCCESS") {
				alert(response.message);
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});	
}

//게시물 스크랩
function mobile_board_message_scrap() {	
	var formData = new FormData();
	var filescnt = mobile_comm_uploadfilesObj.files.length;
	formData.append("bizSection", _mobile_board_view.BizSection);
	formData.append("mode", _mobile_board_view.Mode);
	formData.append("folderID", _mobile_board_view.FolderID);
	formData.append("messageID", _mobile_board_view.MessageID);
	formData.append("orgMessageID", _mobile_board_view.MessageID);
	formData.append("version", _mobile_board_view.Version);
	formData.append("fileInfos", JSON.stringify(mobile_comm_uploadfilesObj.fileInfos));
	
	for (var i = 0; i < filescnt; i++) {
    	if (typeof mobile_comm_uploadfilesObj.files[i] == 'object') {
    		formData.append("files", mobile_comm_uploadfilesObj.files[i]);
        }
    }
	
	formData.append("fileCnt", mobile_comm_uploadfilesObj.fileInfos.length);	
	
	var url = "/groupware/mobile/board/scrapMessage.do";
	
	$.ajax({
		url: url,
		data: formData,
		type: "post",
		dataType: 'json',
		processData : false,
        contentType : false,
		success: function (response) {
			if(response.status == "SUCCESS") {
				alert(mobile_comm_getDic("msg_ScrapCheckMsg") + " " + mobile_comm_getDic("msg_board_doScrap")); // 본문과 첨부 파일만 스크랩됩니다. 스크랩 하였습니다.
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
			alert("ERROR");
		}
	});	
}

//게시물 복사
function mobile_board_message_copy (){
	var folderID = $('#board_folder_list').val();
	var paramdata = {
		bizSection : _mobile_board_view.BizSection,
		messageID : _mobile_board_view.MessageID,
		orgFolderID : _mobile_board_view.FolderID,
		folderID : folderID,
		comment : "",
		version : _mobile_board_view.Version
	};
	
    $.ajax({
    	type:"POST",
    	url:"/groupware/mobile/board/copyMessage.do",
    	data: paramdata,
    	success:function(response){
			if(response.status == "SUCCESS") {
				alert(mobile_comm_getDic("msg_CopyCheckMsg") + " " + mobile_comm_getDic("msg_task_completeCopy")); //복사 되었습니다.
				mobile_comm_back();
				mobile_board_clickrefresh();
			}
    	},
    	error:function(response, status, error){
    		mobile_comm_ajaxerror(url, response, status, error);
			alert("ERROR");
    	}
    });
}

//게시물 이동
function mobile_board_message_move() {
	var folderID = $('#board_folder_list').val();
	var paramdata = {
		bizSection : _mobile_board_view.BizSection,
		messageID : _mobile_board_view.MessageID,
		orgFolderID : _mobile_board_view.FolderID,
		folderID : folderID,
		comment : "",
		version : _mobile_board_view.Version
	};
	
    $.ajax({
    	type:"POST",
    	url:"/groupware/mobile/board/moveMessage.do",
    	data:paramdata,
    	success:function(response){
			if(response.status == "SUCCESS") {
				alert(mobile_comm_getDic("msg_task_completeMove")); //이동 되었습니다.
				mobile_comm_back();
				mobile_board_clickrefresh();
			}
    	},
    	error:function(response, status, error){
    		mobile_comm_ajaxerror(url, response, status, error);
			alert("ERROR");
    	}
    });
}

// 폴더 복사/이동 show
function mobile_open_folder(pMode)
{
	$('.btn_exmenu').trigger("click");
	$('#board_folder_list option[value="' + _mobile_board_view.FolderID + '"]').remove(); //현 위치 폴더 숨김 처리
	$('#board_folder').show();
	$('#board_view_change').val(pMode);
	
	if(pMode == 'copy') 
	{		
		$('#board_view_change').html(mobile_comm_getDic("btn_Copy")); //복사		
	}
	else
	{	
		$('#board_view_change').html(mobile_comm_getDic("btn_Move")); //이동
	}
	
	$( 'html, body' ).animate( { scrollTop : 0 }, 400 );
	
	$('.dropMenu').removeClass("show");
}

// 복사/이동 함수 호출
function mobile_board_message_change()
{
	var sMode = $('#board_view_change').val();
	
	if($('#board_folder_list').val() == '')
	{
		alert(mobile_comm_getDic("msg_board_selectFolder")); //게시판을 선택해주세요.
		return;
	}
	
	if(sMode == 'copy')
	{
		mobile_board_message_copy();
	}
	else if(sMode == 'move')
	{
		mobile_board_message_move();
	}
}

var board_view_process_type = "";
//처리사유 창 열고 닫기
function mobile_board_clickbtn(obj, type) {
	$('.btn_exmenu').trigger("click");
	board_view_process_type = type;
	
	if(obj == undefined || obj === '') 
		obj = $(".approval_comment");
	
	if(type != 'toggle') {
		if(type == "request") {
			mobile_board_doBtnClick('Y');
		} else {
			$(obj).parents().addClass('open');
			$('.approval_comment').animate({height:"156px"});
		}
	} else {
		$(".approval_comment").animate(
			{height:"0"},
			{complete : function(){$(obj).parents().removeClass('open');}}
		);
	}
}

//처리사유 창에서 확인/취소 눌렀을 때
function mobile_board_doBtnClick(type) {
	if(type == "Y") { //확인
		switch(board_view_process_type) {		
		case "accept":
			mobile_board_acceptMessage();
			break;
		case "reject":
			mobile_board_rejectMessage();
			break;
		default:
			return;	
		}		
	} else { //취소
		$("#board_view_commentarea").val("");
		mobile_board_clickbtn('', 'toggle');
	}
}

//게시글 승인
function mobile_board_acceptMessage (){
	var messageIDs = '';
	var processIDs = '';

	messageIDs = _mobile_board_view.MessageID;
	processIDs = _mobile_board_view.ProcessID;
	
    $.ajax({
    	type:"POST",
    	url:"/groupware/mobile/board/acceptMessage.do",
    	data:{
    		"bizSection": _mobile_board_view.BizSection
    		,"messageID": messageIDs
    		,"processID": processIDs
    		,"comment": $("#board_view_inputcomment").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />')
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			alert(data.message);
    			mobile_comm_back();
    			mobile_board_clickrefresh();
    		}else{
    			alert(mobile_comm_getDic('msg_apv_030'));//오류가 발생헸습니다.
    		}
    	},
    	error:function(response, status, error){
    	     //TODO 추가 오류 처리
    	     mobile_comm_ajaxerror("/groupware/mobile/board/acceptMessage.do", response, status, error);
    	}
    });
}

//게시글 승인 거부
function mobile_board_rejectMessage (){
	var messageIDs = '';
	var processIDs = '';

	messageIDs = _mobile_board_view.MessageID;
	processIDs = _mobile_board_view.ProcessID;
	
    $.ajax({
    	type:"POST",
    	url:"/groupware/mobile/board/rejectMessage.do",
    	data:{
    		"bizSection": _mobile_board_view.BizSection
    		,"messageID": messageIDs
    		,"processID": processIDs
    		,"comment": $("#board_view_inputcomment").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />')
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			alert(data.message);
    			mobile_comm_back();
    			mobile_board_clickrefresh();
    		}else{
    			alert(mobile_comm_getDic('msg_apv_030'));//오류가 발생헸습니다.
    		}
    	},
    	error:function(response, status, error){
    	     //TODO 추가 오류 처리
    		mobile_comm_ajaxerror("/groupware/mobile/board/rejectMessage.do", response, status, error);
    	}
    });
}



//게시 상세보기 - 조회자 페이지 끝












// 문서관리 별도 함수 시작

/*
 * 
 * 문서관리 목록 시작
 * 
 */

function mobile_doc_gotoView(pMessageID, pVersion, pUrl, pObj) {
	
	var folderID = _mobile_board_list.FolderID;
	if(folderID == undefined || folderID == ""){
		if(pUrl != undefined && mobile_comm_getQueryStringForUrl(pUrl, "folderid") != "") {
			folderID = mobile_comm_getQueryStringForUrl(pUrl, "folderid");
		}
	}
	
	var readFlag = false;	//읽기 권한
	readFlag = mobile_board_checkReadAuth(_mobile_board_list.BizSection, folderID, pMessageID, pVersion);
	
	mobile_doc_selectMessageDetail("View", _mobile_board_list.BizSection, pVersion, pMessageID, folderID);
	
	//열람 권한 확인
	if(_mobile_message_config.UseMessageReadAuth == "Y"){
		//열람권한 테이블에서 조회된 데이터가 없을경우
		if(mobile_board_getMessageReadAuthCount(_mobile_board_list.BizSection, pMessageID, folderID) > 0){
			readFlag = true;
		}
	}
	
	if(!readFlag){
		if(_mobile_board_list.BoardType == "Normal") {
			if(confirm(mobile_comm_getDic("lbl_doc_donotReadAuthRequestAuth").replace("\\n", "\n"))) { //읽기 권한이 없습니다.\n권한을 요청하시겠습니까?
				var params = {
					BoardType: _mobile_board_list.BoardType,
					FolderID: folderID,
					MessageID: pMessageID,
					Version: pVersion
				};
				return mobile_doc_requestAuth('request', params);
			} else {
				return false;
			}
		} else {
			alert(mobile_comm_getDic("msg_noViewACL")); //읽기 권한이 없습니다.
			return false;
		}
	} else {
		if(pObj != undefined) {
			return mobile_board_read(pUrl, pObj);
		} else {
			return mobile_comm_go(pUrl, "Y");
		}
	}
}

/*
 * 
 * 문서관리 목록 끝
 * 
 */



/*
 * 
 * 문서관리 작성 시작
 * 
 */

var selectedACL = null; //상세권한에서 선택된 항목(사용자/부서/회사 등등)

//문서관리-작성 초기화
function mobile_doc_WriteInit () {
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('menuid', "doc_write_page") != 'undefined') {
		_mobile_board_write.MenuID = mobile_comm_getQueryString('menuid', "doc_write_page");
	} else {
		_mobile_board_write.MenuID = '';
	}
	if (mobile_comm_getQueryString('folderid', "doc_write_page") != 'undefined') {
		_mobile_board_write.FolderID = mobile_comm_getQueryString('folderid', "doc_write_page");
    } else {
    	_mobile_board_write.FolderID = '';
    }
	if (mobile_comm_getQueryString('messageid', "doc_write_page") != 'undefined') {
		_mobile_board_write.MessageID = mobile_comm_getQueryString('messageid', "doc_write_page");
		_mobile_board_write.Mode = "update";
    } else {
    	_mobile_board_write.MessageID = '';
    	_mobile_board_write.Mode = "create";
    }
	if (mobile_comm_getQueryString('msgstate', "doc_write_page") != 'undefined') {
		_mobile_board_write.MsgState = mobile_comm_getQueryString('msgstate', "doc_write_page");
    } else {
    	_mobile_board_write.MsgState = 'C';
    }
	if (mobile_comm_getQueryString('version', "doc_write_page") != 'undefined') {
		_mobile_board_write.Version = mobile_comm_getQueryString('version', "doc_write_page");
    } else {
    	_mobile_board_write.Version = '1';
    }
	_mobile_board_write.BizSection = 'Doc';

	//보안구분 조회
	var url = "/groupware/mobile/board/selectSecurityLevelList.do";
	$.ajax({
		type:"POST",
		url: url,
		async:false,
		success:function(data){
			var sHtml = "";
			$.each(data.list, function(i, item){
				sHtml += "<option value='" + item.optionValue + "'>";
				sHtml += "		" + item.optionText;
				sHtml += "</option>";
			});
			$("#doc_write_seclevel").html(sHtml).val(mobile_comm_getBaseConfig("DefaultSecurityLevel", mobile_comm_getSession("DN_ID")));			
		},
		error:function(response, status, error){
		     mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	//문서관리 문서 분류 목록 조회 (selectbox용)
	mobile_board_getTreeData(_mobile_board_write, 'WRITE');
	
	//수정모드일 경우 기본데이터 셋팅
	if(_mobile_board_write.Mode == "update"){
		mobile_board_ModifySet(_mobile_board_write, "Doc");
	} else {
		$("#doc_write_creatorName").html(mobile_comm_getSession("USERNAME"));		
		mobile_doc_setCreatorDept();
		mobile_doc_changeKeepYear($("#doc_write_selectKeepyear"));
		mobile_comm_uploadhtml();
	}
	
	//문서관리 환경설정 조회 (_mobile_board_write.Config에 셋팅)
	mobile_board_getBoardConfig(_mobile_board_write.FolderID, 'WRITE');
	
	//문서관리 환경설정 바인딩
	if(!mobile_doc_bindBoardConfig()){
		return false;
	}
	
	//datepicker 임시
	$(".input_date").attr('class', 'input_date').datepicker({
		dateFormat : 'yy.mm.dd',
		dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
	});
}

//문서관리 환경설정 바인딩
function mobile_doc_bindBoardConfig(){
	
	//폴더 권한 조회
	var folderACLList = mobile_board_getBoardAclList(_mobile_board_write.FolderID);	
	if(_mobile_board_write.FolderID != ""){
		if(!mobile_board_checkWriteAuthPC()){
			alert(mobile_comm_getDic("msg_noWriteAuth")); //해당 분류에는 쓰기 권한이 없습니다.
			_mobile_board_write.FolderID = "";
		
			return mobile_comm_back();
		}
	}
	
	if(_mobile_board_write.Config.UseAutoDocNumber == "Y"){
		//문서 번호 자동 발번 옵션 사용
		$('#doc_write_docNumber').val("");
		$('#doc_write_docNumber').attr({placeholder: mobile_comm_getDic('lbl_DocNo') + ' ' + mobile_comm_getDic('lbl_AutoNumberCreation'), readonly:'readonly'});
	} else {
		if($('#doc_write_docNumber').is('[readonly]')) {
			$('#doc_write_docNumber').val("");
			$('#doc_write_docNumber').attr({placeholder: mobile_comm_getDic('lbl_DocNo')}).removeAttr('readonly');
		}
	}
	
	//승인프로세스 사용여부
    if (_mobile_board_write.Config.UseOwnerProcess == "Y" || _mobile_board_write.Config.UseUserProcess == "Y") {
        $("#doc_write_IsApproval").val("Y");
	} else {
		$("#doc_write_IsApproval").val("N");
	}
	
    $("#doc_write_hidAuth").val(JSON.stringify(folderACLList));	//폴더 선택,변경시 폴더권한 설정
    //상세권한 설정 표시/숨김
    /*if(_mobile_board_write.Config.UseMessageAuth == "Y"){
    	$("#doc_write_auth").show();
    } else {
    	$("#doc_write_auth").hide();
    }*/
    
    //만료일 사용 여부
	if (_mobile_board_write.Config.UseExpiredDate == "Y") {
        if (_mobile_board_write.Config.ExpireDay == 0) {		//0은 만료일을 사용 안함 상태
            $('#doc_write_expiredDate').attr('disabled', true);
            //만료일 설정 disable처리 혹은 숨겨야됨
        }
    }
}

//작성부서 select box setting
function mobile_doc_setCreatorDept() {
	$.ajax({
		url: "/groupware/mobile/board/selectRegistDeptList.do",
		data: '',
		type: "post",
		async: false,
		success: function (response) {
			var cnt= response.list.length;
			for(var i = 0; i < cnt; i++)
				$('#doc_write_registDept').append("<option value=\"" + response.list[i].optionValue + "\">" + response.list[i].optionText + "</option>");
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//문서관리 내부 보존 기간 설정이 만료일로 자동 적용
function mobile_doc_changeKeepYear( pObj ){
	var year = $(pObj).val()
	
	var date = new Date();
    date.setFullYear(date.getFullYear()+parseInt(year));
    date.setMonth(date.getMonth());
    date.setDate(date.getDate());
    $("#doc_write_expiredDate").val(mobile_doc_dateString(date).substring(0, 10));
}

//date format처리 YYYY-MM-DD hh:mm:ss
function mobile_doc_dateString( pDate ){
	var year = pDate.getFullYear();
	if (year < 1000){
	     year+=1900;
	}
	var day = pDate.getDate();
	var month=(pDate.getMonth()+1);
	var hour = pDate.getHours();
	var min = pDate.getMinutes();
	var sec = pDate.getSeconds();

	day = (day<10 ? '0'+day : day);
	month = (month<10 ? '0'+month : month);
	hour = (hour<10 ? '0'+hour : hour);
	min = (min<10 ? '0'+min : min);
	sec = (sec<10 ? '0'+sec : sec);
	
	var currentTime = year + "-" + month + "-" + day + " " + hour + ":" + min + ":" + sec;
	return currentTime;
}

//게시글 수정 - 개정
function mobile_doc_saveRevision() {
	_mobile_board_write.Mode = "revision";
	_mobile_board_write.MsgState = "RV";
	mobile_doc_save();
}

//게시글 수정 - 확인
function mobile_doc_confirm() {
	_mobile_board_write.MsgState = "";
	mobile_doc_save();
}

//게시글 임시저장
function mobile_doc_tempsave() {
	_mobile_board_write.MsgState = "T";
	mobile_doc_save();
}

//게시글 저장
function mobile_doc_save() {	
	if(!mobile_doc_savevalidation()) {
		return;
	}
	
	//Multipart 업로드를 위한 formdata객체 사용 
	var formData = new FormData();	
	var filescnt = mobile_comm_uploadfilesObj.files.length;
	formData.append("bizSection", "Doc");
	formData.append("mode", _mobile_board_write.Mode);
	formData.append("folderID", _mobile_board_write.FolderID);
	
	// 제목, 문서번호
	formData.append("subject", $('#doc_write_title').val());
	formData.append("number", $('#doc_write_docNumber').val());
	
	// 파일
	formData.append("fileInfos", JSON.stringify(mobile_comm_uploadfilesObj.fileInfos));
	for (var i = 0; i < filescnt; i++) {
    	if (typeof mobile_comm_uploadfilesObj.files[i] == 'object') {
    		formData.append("files", mobile_comm_uploadfilesObj.files[i]);
        }
    }
	formData.append("fileCnt", mobile_comm_uploadfilesObj.fileInfos.length);
	
	// 본문
	formData.append("bodyText", $('#doc_write_body').val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />'));
	formData.append("bodySize", $('#doc_write_body').val().length);
	
	//등록부서
	formData.append("registDept", $('#doc_write_registDept').val());
	
	// 소유자
	if($('#doc_write_owner > a').length > 0) {
		var ownerList = "";
		/*
		$('#doc_write_owner > a').each(function (){
			ownerList += $(this).attr("value") + ";";
		});
		*/
		ownerList += $('#doc_write_owner > a').last().attr("value"); //TODO: 가장 마지막에 추가된 사람만 저장됨(PC 기준) - 추후 변경 필요
		
		formData.append("ownerCode", ownerList);
	}
	
	if($('#doc_write_auth a.btn_add_person').length > 0) {
		var authArray = [];
		$('#doc_write_auth a.btn_add_person').each(function (){
			var authObj = new Object();
			authObj.TargetType = $(this).attr("objecttype_a");
			authObj.TargetCode = $(this).attr("objectcode");
			authObj.DisplayName = $(this).attr("displayname");
			authObj.AclList = $(this).attr("acllist");
			authObj.IsSubInclude = $(this).attr("issubinclude");
			authObj.InheritedObjectID = "0";				
			authArray.push(authObj);
		});
		
		formData.append("aclList", encodeURIComponent(JSON.stringify(authArray)));
	}
	
	//보존기한(만료일도 같이 세팅 필요)
	if($("#doc_write_expiredDate").attr("disabled") != "disabled")
		formData.append("expiredDate", $('#doc_write_expiredDate').val());
	
	formData.append("keepyear", $('#doc_write_selectKeepyear').val());
	
	var url = "/groupware/mobile/board/createMessage.do";
	if(_mobile_board_write.Mode == "update" && _mobile_board_write.Mode != "revision") {
		url = "/groupware/mobile/board/updateMessage.do";
		formData.append("messageID", _mobile_board_write.MessageID);
	}
	if(_mobile_board_write.MsgState == "RV") {
		formData.append("messageID", _mobile_board_write.MessageID);
		_mobile_board_write.MsgState = "C";	//등록 상태
	}
    if($("#doc_write_IsApproval").val() == "Y"){
    	_mobile_board_write.MsgState = "R";	//승인 요청 상태 
	}
	
	if(_mobile_board_write.Mode == "binder"){
		formData.append("msgType", "B");
	} else {
		formData.append("msgType", "N");
	}

	formData.append("userName", "");
	formData.append("securityLevel", $('#doc_write_seclevel').val() == null ? "" : $('#doc_write_seclevel').val());
	
	formData.append("linkedMessage", $("#doc_write_hiddenLinkedDocList").val());
	formData.append("version", _mobile_board_write.Version);	//TODO: 버전처리
	formData.append("isAutoDocNumber", _mobile_board_write.Config.UseAutoDocNumber);
	formData.append("msgState", _mobile_board_write.MsgState);
	formData.append("depth", "0");
	formData.append("seq", "0");
	formData.append("step", "0");
	
	
	$.ajax({
		url: url,
		data: formData,
		type: "post",
		dataType: 'json',
		processData : false,
        contentType : false,
		success: function (response) {
			if(response.status == "SUCCESS") {
				if(_mobile_board_write.Mode == "revision" || _mobile_board_write.Mode == "update") {					
					mobile_comm_back();
					
					if($("#doc_view_page").attr("IsLoad") == "Y"){
						mobile_doc_ViewInit();
		    		}			
					
					$("#doc_view_page").remove();
				} else {
					mobile_comm_back();
				}
				
				mobile_board_clickrefresh();
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//validation 체크 //TODO : 다국어 처리
function mobile_doc_savevalidation() {	
	if ($("#doc_write_title").val() == "") {
        alert(mobile_comm_getDic("msg_board_enterTitle")); //제목을 입력해주세요.
        return false;
    }
		
	if ($("#doc_write_folder").val() == "" || $.isEmptyObject(_mobile_board_write.Config)){
		alert(mobile_comm_getDic("msg_doc_selectDocCate"));  //문서분류를 선택해주세요.
		return false;
	}
	
	if ($("#doc_write_body").val() == "") {
        alert(mobile_comm_getDic("msg_EnterContents")); //내용을 입력하세요.
        return false;		
	}

	// TODO : 첨부 파일 개수 제한
	/*// 파일정보
    if(coviFile.fileInfos.length > _mobile_board_write.Config.LimitFileCnt){
	    //게시판에서 설정한 첨부파일 개수 제한에 걸림
    	alert("파일 첨부 개수를 초과했습니다.", "Warning Dialog", function () {     //분류명 입력
        });
    	return false;
	}*/
	
	return true;
}

//조직도 호출
function mobile_doc_openOrg(target) {
	var sUrl = "/covicore/mobile/org/list.do";

	if(target == "Owner") {
		window.sessionStorage["mode"] = "SelectUser";
		window.sessionStorage["multi"] = "N";
	} else {
		window.sessionStorage["mode"] = "Select";
		window.sessionStorage["multi"] = "Y";
	}
	
	window.sessionStorage["callback"] = "mobile_doc_set" + target + "List();";
	
	mobile_comm_go(sUrl, 'Y');
}

//조직도 콜백 함수 - 소유자 (1명만 추가됨)
function mobile_doc_setOwnerList() {
	$("#doc_write_owner").show();
	
	var userinfo = JSON.parse("[" + window.sessionStorage["userinfo"] + "]");
	var bCheck = false;
	$(userinfo).each(function(i, user) {
		bCheck = false;
 		//중복 체크 이후 sHTML로 TR 데이터 그려줌
		$("#doc_write_owner").find("a").each(function (i, owner) {
			if($(owner).attr("value") == user.AN) bCheck = true;
		});
        if(!bCheck) {
        	$("#doc_write_owner").html("<a onclick=\"mobile_doc_delUser(this, 'owner');\" class=\"btn_add_person\" value=\"" + user.AN + "\">" + mobile_comm_getDicInfo(user.DN) + "</a>");
        }
	});
}

//조직도 콜백 함수 - 상세권한
function mobile_doc_setAuthList() {
	$("#doc_write_auth").show();
	$("#doc_write_switchList").show();
	
    var sObjectType = "";
    var sObjectType_A = "";
    //var sObjectTypeText = "";
    var sCode = "";
    //var sDNCode = "";
    var sDisplayName = "";
    var bCheck = false;
    var sAclList = "_C__ER";
	var lang = mobile_comm_getSession("lang");
	var userinfo = JSON.parse("[" + window.sessionStorage["userinfo"] + "]");
	
	$(userinfo).each(function(i, item) {
		sObjectType = item.itemType
  		if(sObjectType.toUpperCase() == "USER"){ //사용자
  			//sObjectTypeText = mobile_comm_getDic("lbl_User"); // 사용자
  			sObjectType_A = "UR";
  			sCode = item.AN;//UR_Code
	  		sDisplayName  = mobile_comm_getDicInfo(item.DN, lang);
	  		//sDNCode = item.ETID;; //DN_Code
  		}else{ //그룹
  			switch(item.GroupType.toUpperCase()){
	  			case "COMPANY":
	                //sObjectTypeText = mobile_comm_getDic("lbl_Company"); // 회사
	                sObjectType_A = "CM";
	                break;
	            case "JOBLEVEL":
	                //sObjectTypeText = mobile_comm_getDic("lbl_JobLevel"); //직급
	                sObjectType_A = "JL";
	                break;
	            case "JOBPOSITION":
	                //sObjectTypeText = mobile_comm_getDic("lbl_JobPosition"); //직위
	                sObjectType_A = "JP";
	                break;
	            case "JOBTITLE":
	                //sObjectTypeText = mobile_comm_getDic("lbl_JobTitle"); //직책
	                sObjectType_A = "JT";
	                break;
	            case "MANAGE":
	                //sObjectTypeText = mobile_comm_getDic("lbl_board_manage"); //관리
	                sObjectType_A = "MN";
	                break;
	            case "OFFICER":
	                //sObjectTypeText = mobile_comm_getDic("lbl_vip"); //임원
	                sObjectType_A = "OF";
	                break;
	            case "DEPT":
	                //sObjectTypeText = mobile_comm_getDic("lbl_dept"); // 부서
	                sObjectType_A = "GR";
         	}
  		
  			sCode = item.AN
            sDisplayName = mobile_comm_getDicInfo(item.GroupName, lang);
            //sDNCode = item.DN_Code;
  		}
		
		bCheck = false;    
        //중복 체크 이후 sHTML로 TR 데이터 그려줌
        $('#doc_write_auth').children().each(function () {
            if (($(this).children().eq(0).attr("objecttype_a").toUpperCase() == sObjectType_A.toUpperCase()) &&
                ($(this).children().eq(0).attr("objectcode") == sCode)) {
                bCheck = true;
            }
        });
        
        if(!bCheck) {
			$("#doc_write_auth").append(
					  "<div class=\"btn_add_person_wrap\">"
					+ "	<a onclick=\"mobile_doc_getSelectedAclData(this);\" class=\"btn_add_person\" aclList=\"" + sAclList + "\" objectcode=\"" + sCode + "\" objecttype_a=\"" + sObjectType_A + "\" displayname=\"" + sDisplayName + "\" issubinclude=\"Y\" style=\"background-image: none;\">" + sDisplayName + "</a>"
					+ "	<a onclick=\"mobile_doc_delUser(this, 'auth');\" class=\"btn_close\"></a>"
					+ "</div>");
        }
	});
	
	$("#doc_write_auth").find('div.btn_add_person_wrap').first().addClass("selected");
	var aclList = $("#doc_write_auth").find('div.btn_add_person_wrap a').first().attr('aclList');
	var aclShard = aclList.split("");
	selectedACL = $("#doc_write_auth").find('div.btn_add_person_wrap a').first();
	
	aclShard[0] != "_"?$("#doc_write_btnSecurity").addClass("on"):$("#doc_write_btnSecurity").removeClass("on");
	aclShard[1] != "_"?$("#doc_write_btnCreate").addClass("on"):$("#doc_write_btnCreate").removeClass("on");
	aclShard[2] != "_"?$("#doc_write_btnDelete").addClass("on"):$("#doc_write_btnDelete").removeClass("on");
	aclShard[3] != "_"?$("#doc_write_btnModify").addClass("on"):$("#doc_write_btnModify").removeClass("on");
	aclShard[4] != "_"?$("#doc_write_btnExecute").addClass("on"):$("#doc_write_btnExecute").removeClass("on");
	aclShard[5] != "_"?$("#doc_write_btnRead").addClass("on"):$("#doc_write_btnRead").removeClass("on");
	
	var IsSubInclude = $("#doc_write_auth").find('div.btn_add_person_wrap a').first().attr('issubinclude');
	IsSubInclude == "Y" ? $("#doc_write_btnIsSubInclude").addClass("on") : $("#doc_write_btnIsSubInclude").removeClass("on");
	
	// 사용자 일때 하위포함 스위치를 표시하지 않는다.
	var ObjectType_A = $("#doc_write_auth").find('div.btn_add_person_wrap a').first().attr('objecttype_a');
	ObjectType_A == "UR" ? $("#IsSubInclude_SwitchArea").hide() : $("#IsSubInclude_SwitchArea").show();
}

//조직도 콜백 함수 - 배포
function mobile_doc_setDistributeList() {
	var userinfo = JSON.parse("[" + window.sessionStorage["userinfo"] + "]");
	
	$.ajax({
    	type:"POST",
    	url: "/groupware/mobile/board/distributeDoc.do",
    	data: {
	    	'messageID' : _mobile_board_view.MessageID
	    	,'version'	: _mobile_board_view.Version
	    	,'targetList' : mobile_doc_getACLDataForDistribute(userinfo)
	    	,'comment'	: $('#doc_view_inputcomment').val()
	    },
    	dataType : 'json',
    	success:function(data){
    		if(data.status=='SUCCESS'){
	    		alert(mobile_comm_getDic("msg_doc_distributionSuccess")); //성공적으로 배포하였습니다.
				mobile_comm_back();
    			mobile_board_clickrefresh();
    		}else{
    			alert(mobile_comm_getDic("msg_ErrorOccurred")); //오류가 발생하였습니다.
    		}
    	}, 
  		error:function(error){
  			mobile_comm_ajaxerror(url, response, status, error);
  		}
    });
}

function mobile_doc_getACLDataForDistribute(userinfo) {
	var aclArray = [];
	
	//subject 추출
	$(userinfo).each(function (i, user) {
        var ACL = new Object();
        var targetType = "";
        if(user.itemType == "user") {
        	targetType = "UR";
        } else {
        	if(user.GroupType == "Dept") targetType = "GR";
        	else targetType = "CM";
        }
        
        ACL.TargetType = targetType;
    	ACL.TargetCode = user.AN;
    	aclArray.push(ACL);
    });
    
	return JSON.stringify(aclArray);
}

// 소유자/상세권한 - 사용자/부서 삭제
function mobile_doc_delUser(obj, target) {
	if(target == "auth")
		$(obj).parent().remove();
	else
		$(obj).remove();
	
	if($("#doc_write_" + target).find("a").length == 0) {
		$("#doc_write_" + target).hide();
		if(target == "auth")
			$("#doc_write_switchList").hide();
	}
}

//추가된 사용자, 그룹 선택시 해당하는 권한정보를 switch에 표시한다.
function mobile_doc_getSelectedAclData(pObj) {
	//이전에 선택된 항목 selected class remove 후 선택한 object의 parent에 selected class add
	$(pObj).parent().parent().find("div.btn_add_person_wrap").removeClass("selected");
	$(pObj).parent().addClass("selected");
	
	var aclList = $(pObj).attr('aclList');
	var aclShard = aclList.split("");
	selectedACL = $(pObj);
	
	aclShard[0] != "_"?$("#doc_write_btnSecurity").addClass("on"):$("#doc_write_btnSecurity").removeClass("on");
	aclShard[1] != "_"?$("#doc_write_btnCreate").addClass("on"):$("#doc_write_btnCreate").removeClass("on");
	aclShard[2] != "_"?$("#doc_write_btnDelete").addClass("on"):$("#doc_write_btnDelete").removeClass("on");
	aclShard[3] != "_"?$("#doc_write_btnModify").addClass("on"):$("#doc_write_btnModify").removeClass("on");
	aclShard[4] != "_"?$("#doc_write_btnExecute").addClass("on"):$("#doc_write_btnExecute").removeClass("on");
	aclShard[5] != "_"?$("#doc_write_btnRead").addClass("on"):$("#doc_write_btnRead").removeClass("on");
	
	var IsSubInclude = $(pObj).attr('issubinclude');
	IsSubInclude == "Y" ? $("#doc_write_btnIsSubInclude").addClass("on") : $("#doc_write_btnIsSubInclude").removeClass("on");
	
	// 사용자 일때 하위포함 스위치를 표시하지 않는다.
	var ObjectType_A = $(pObj).attr('objecttype_a');
	ObjectType_A == "UR" ? $("#IsSubInclude_SwitchArea").hide() : $("#IsSubInclude_SwitchArea").show();
}

//스위치를 사용하여 ACL설정이 변경될경우 ACL List 값 변경
function mobile_doc_setSwitchACLList(pObj, index){
	if(selectedACL != null){
		$(pObj).toggleClass("on");
		if(index != null) {
			var initAclList = "SCDMER";		
			var aclList = selectedACL.attr('aclList');
			
			var newAclList = '';
			
			for(var i = 0; i < aclList.length; i++) {
				if(i == index) {
					newAclList += aclList.charAt(i) == "_" ? initAclList.charAt(i) : "_";
				} else {
					newAclList += aclList.charAt(i);
				}
			}
			
			selectedACL.attr("aclList", newAclList);	//ACL 추출
		} else {
			// 하위포함
			var IsSubInclude = selectedACL.attr("issubinclude");
			selectedACL.attr("issubinclude", IsSubInclude == "Y" ? "N" : "Y");
		}		
	}
}

//연결문서 추가
function mobile_doc_addLinkedDoc() {
	window.sessionStorage["doc_isDocLinked"] = "Y";
	$("#doc_list_page").remove();
	mobile_comm_go("/groupware/mobile/doc/list.do", 'Y');	
}

//연결문서 닫기
function mobile_doc_closeLinkedDoc() {
	window.sessionStorage["doc_isDocLinked"] = "N";
	mobile_comm_back();	
}

//연결문서 선택
function mobile_doc_saveSelectLinkedDoc() {
	var param = "";
	$("input[type=checkbox][name=doc_list_chkbox]:checked").each(function(i, obj) {
		param += $(obj).val();
		if($("input[type=checkbox][name=doc_list_chkbox]:checked").length-1 != i){
			param += ",";
		}
	});
	param = "[" + param + "]";
	
	mobile_doc_setLinkedDoc(param);
	mobile_doc_closeLinkedDoc();
}

//연결문서 세팅(html)
function mobile_doc_setLinkedDoc(param) {
	if(param != "") {
		var sHtml = "";
		
		var docs = JSON.parse(param);
		var cnt = docs.length;
		for(var i = 0; i < cnt; i++) {
			var doc = docs[i];
			var messageID = doc.MessageID;
			var version = doc.Version;
			var displayName = doc.DisplayName;
			
			if($("#doc_write_linkedDocList").find("a[targetid='" + messageID + "'][version='" + version + "']").length == 0) {
				sHtml += "<a onclick='mobile_doc_delLinkedDoc(this);' class='btn_add_person' targetid='" + messageID + "' version='" + version + "' value='" + JSON.stringify(doc) + "'>" + displayName + "</a>";			
				mobile_doc_setLinkedDocHidden(JSON.stringify(doc));
			}
		}
		
		$("#doc_write_linkedDocList").append(sHtml).show();		
	}
}

//연결문서 세팅(hidden)
function mobile_doc_setLinkedDocHidden(pDoc) {
	var docList = [];
	if($("#doc_write_hiddenLinkedDocList").val() != "")
		docList = JSON.parse($("#doc_write_hiddenLinkedDocList").val());
	var doc = JSON.parse(pDoc);
	
	docList.push(doc);
	$("#doc_write_hiddenLinkedDocList").val(JSON.stringify(docList));
}

//연결문서 삭제
function mobile_doc_delLinkedDoc(pObj) {
	var docList = JSON.parse($("#doc_write_hiddenLinkedDocList").val());
	var remove_index = null;
	$(docList).each(function(i, doc) {
		if(JSON.stringify(doc) == $(pObj).attr("value"))
			remove_index = i;
	});
	
	if(remove_index != null)
		docList.splice(remove_index, 1);
	
	$("#doc_write_hiddenLinkedDocList").val(JSON.stringify(docList));
	
	$(pObj).remove();
	if($("#doc_write_linkedDocList").html().trim() == "") $("#doc_write_linkedDocList").hide();
}

/*
 * 
 * 문서관리 작성 끝
 * 
 */


/*
 * 
 * 문서관리 상세 시작
 * 
 */

//문서관리-상세 초기화
function mobile_doc_ViewInit(){
	
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('boardtype', "doc_view_page") != 'undefined') {
		_mobile_board_view.BoardType = mobile_comm_getQueryString('boardtype', "doc_view_page");
	} else {
		_mobile_board_view.BoardType = 'Normal';
	}
	if (mobile_comm_getQueryString('folderid', "doc_view_page") != 'undefined') {
		_mobile_board_view.FolderID = mobile_comm_getQueryString('folderid', "doc_view_page");
    } else {
    	_mobile_board_view.FolderID = '';
    }
	if (mobile_comm_getQueryString('page', "doc_view_page") != 'undefined') {
		_mobile_board_view.Page = mobile_comm_getQueryString('page', "doc_view_page");
    } else {
    	_mobile_board_view.Page = 1;
    }
	if (mobile_comm_getQueryString('searchtext', "doc_view_page") != 'undefined') {
		_mobile_board_view.SearchText = mobile_comm_getQueryString('searchtext', "doc_view_page");
    } else {
    	_mobile_board_view.SearchText = '';
    }
	if (mobile_comm_getQueryString('messageid', "doc_view_page") != 'undefined') {
		_mobile_board_view.MessageID = mobile_comm_getQueryString('messageid', "doc_view_page");
    } else {
    	_mobile_board_view.MessageID = 0;
    }
	if (mobile_comm_getQueryString('menuid', "doc_view_page") != 'undefined') {
		_mobile_board_view.MenuID = mobile_comm_getQueryString('menuid', "doc_view_page");
    } else {
    	_mobile_board_view.MenuID = 0;
    }
	if (mobile_comm_getQueryString('foldertype', "doc_view_page") != 'undefined') {
		_mobile_board_view.FolderType = mobile_comm_getQueryString('foldertype', "doc_view_page");
    } else {
    	_mobile_board_view.FolderType = '';
    }
	if (mobile_comm_getQueryString('version', "doc_view_page") != 'undefined') {
		_mobile_board_view.Version = mobile_comm_getQueryString('version', "doc_view_page");
    } else {
    	_mobile_board_view.Version = '1';
    }
	if (mobile_comm_getQueryString('bizSection', "doc_view_page") != 'undefined') {
		_mobile_board_view.BizSection = mobile_comm_getQueryString('bizSection', "doc_view_page");
	} else {
		var bizSection = "";
		bizSection = location.pathname.split("/")[3];
		bizSection = bizSection.charAt(0).toUpperCase() + bizSection.slice(1);
		_mobile_board_view.BizSection = bizSection;
	}
	if (mobile_comm_getQueryString('boxtype', "doc_view_page") != 'undefined') {
		_mobile_board_view.BoxType = mobile_comm_getQueryString('boxtype', "doc_view_page");
    } else {
    	_mobile_board_view.BoxType = '';
    }
	if (mobile_comm_getQueryString('processid', "doc_view_page") != 'undefined') {
		_mobile_board_view.ProcessID = mobile_comm_getQueryString('processid', "doc_view_page");
    } else {
    	_mobile_board_view.ProcessID = '';
    }
	
	if(_mobile_board_view.BoardType == "Approval" && _mobile_board_view.BoxType == "Receive") 
		$("#doc_view_btn_approval").show();
	else
		$("#doc_view_btn_approval").hide();
	
	mobile_board_getBoardConfig(_mobile_board_view.FolderID);
	if(_mobile_message_config == null 
		|| (_mobile_message_config != null && _mobile_message_config.MessageID != _mobile_board_view.MessageID)) {
		mobile_doc_selectMessageDetail("View", _mobile_board_view.BizSection, _mobile_board_view.Version, _mobile_board_view.MessageID, _mobile_board_view.FolderID);
	}
		
	/*
	<i class="ico_person"></i>조회자 목록, 
	<i class="ico_read"></i>읽기, 
	<i class="ico_edit"></i>수정, 
	<i class="ico_delete"></i>삭제, 
	<i class="ico_reply"></i>답글/댓글
	*/
	
	//조회 권한 확인
	if(mobile_comm_getSession("isAdmin") == "Y"
			|| (_mobile_board_view.BizSection != "Doc" && _mobile_message_config.CreatorCode == mobile_comm_getSession("USERID")) 
			|| (_mobile_board_view.BizSection == "Doc" && _mobile_message_config.OwnerCode == mobile_comm_getSession("USERID"))){
		$("#doc_view_detailAuth").find("span").append('<i class="ico_person"></i>' + mobile_comm_getDic("btn_Viewer") + " " + mobile_comm_getDic("btn_List") + ', '); //조회자 목록
		$("#doc_view_detailAuth").find("span").append('<i class="ico_read"></i>'+ mobile_comm_getDic("lbl_Read") + ', '); //읽기
		
		mobile_doc_getView(_mobile_board_view);
		
		if(_mobile_message_config.MsgState == "A" || _mobile_message_config.MsgState == "R"){	//게시글 승인 상태
			$("#doc_view_modify, #doc_view_delete, #doc_view_move").hide(); //smahn 190402 #doc_view_copy 사용 안함 처리
		} else {
			$("#doc_view_modify, #doc_view_delete, #doc_view_move").show(); //smahn 190402 #doc_view_copy 사용 안함 처리
			$("#doc_view_detailAuth").find("span").append('<i class="ico_edit"></i>'+ mobile_comm_getDic("lbl_Modify") + ', '); //수정
			$("#doc_view_detailAuth").find("span").append('<i class="ico_delete"></i>'+ mobile_comm_getDic("lbl_delete") + ', '); //삭제
			$("#doc_view_detailAuth").find("span").append('<i class="ico_edit"></i>'+ mobile_comm_getDic("lbl_Execute") + ', '); //실행
		}
		
		//체크아웃/체크인/체크아웃 취소
		if(_mobile_message_config.IsCheckOut == "Y"){
			//체크아웃한 유저일 경우 체크인 표시
			if(_mobile_message_config.CheckOuterCode == mobile_comm_getSession("USERID")){
				$("#doc_view_checkin").show();
				$("#doc_view_checkoutCancel").show();
			} else if(_mobile_message_config.OwnerCode == mobile_comm_getSession("USERID")){	//게시판 관리자의 경우 체크아웃 취소를 할 수 있음 
				$("#doc_view_checkoutCancel").show();
			}
		} else {
			$("#doc_view_checkout").show();
		}
		
		//권한 확인
		if(_mobile_board_view.BoardType == "DocAuth" && mobile_comm_getQueryString('requestid', "doc_view_page") != 'undefined') {
			$("#doc_view_approvalAuth").show();
		}
		
		//배포
		if(_mobile_message_config.OwnerCode != mobile_comm_getSession("USERID")) {
			$("#doc_view_distribution").hide();
		} else {
			$("#doc_view_requestAuth").hide();
		}
		
		//dropdown 버튼 표시 유무
		if($("#doc_view_modify").css("display") != "none"
				|| $("#doc_view_delete").css("display") != "none"
				|| $("#doc_view_copy").css("display") != "none"
				|| $("#doc_view_move").css("display") != "none"
				|| $("#doc_viewer_list").css("display") != "none"
				|| $("#doc_view_distribution").css("display") != "none"
				|| $("#doc_view_requestAuth").css("display") != "none"
				|| $("#doc_view_approvalAuth").css("display") != "none"
				|| $("#doc_view_checkout").css("display") != "none"
				|| $("#doc_view_checkoutCancel").css("display") != "none"
				|| $("#doc_view_checkin").css("display") != "none") {
			$("div.utill").show();
		}
		
		return true;
	} else {
		if(_mobile_board_view.MessageID != ""){
				
			mobile_doc_getView(_mobile_board_view);
			
			var aclList = mobile_board_getMessageAclList(_mobile_board_view.BizSection, _mobile_board_view.Version, _mobile_board_view.MessageID, _mobile_board_view.FolderID);
			$('#doc_viewer_list, #doc_view_modify, #doc_view_delete, #doc_view_move').hide(); //smahn 190402 #doc_view_copy 사용 안함 처리
			$.each(aclList.list,function(i, item){
				
				if(item.Security != "_") $("#doc_view_detailAuth").find("span").append('<i class="ico_person"></i>' + mobile_comm_getDic("btn_Viewer") + " " + mobile_comm_getDic("btn_List") + ', '); //조회자 목록
				$("#doc_view_detailAuth").find("span").append('<i class="ico_read"></i>'+ mobile_comm_getDic("lbl_Read") + ', '); //읽기
				if(item.Modify != "_") $("#doc_view_detailAuth").find("span").append('<i class="ico_edit"></i>'+ mobile_comm_getDic("lbl_Modify") + ', '); //수정
				if(item.Delete != "_") $("#doc_view_detailAuth").find("span").append('<i class="ico_delete"></i>'+ mobile_comm_getDic("lbl_delete") + ', '); //삭제
				if(item.Execute != "_") $("#doc_view_detailAuth").find("span").append('<i class="ico_edit"></i>'+ mobile_comm_getDic("lbl_Execute") + ', '); //실행
				
				if(item.TargetType == "UR"){
					item.Security == "_"?$("#doc_viewer_list").hide():$("#doc_viewer_list").show();	//조회자 목록
					item.Modify == "_"?$("#doc_view_modify").hide():$("#doc_view_modify").show();	//수정
					item.Delete == "_"?$("#doc_view_delete, #doc_view_move").hide():$("#doc_view_delete, #doc_view_move").show();	//삭제, 복사, 이동   //smahn 190402 #doc_view_copy 사용 안함 처리
					//item.Create == "_"?$("#ctxReply").hide():$("#ctxReply").show();		//댓글,답글
					return false;
				} else {
					item.Security == "_"?$("#doc_viewer_list").hide():$("#doc_viewer_list").show();	//조회자 목록
					item.Modify == "_"?$("#doc_view_modify").hide():$("#doc_view_modify").show();	//수정
					item.Delete == "_"?$("#doc_view_delete, #doc_view_move").hide():$("#doc_view_delete, #doc_view_move").show();	//삭제, 복사, 이동  //smahn 190402 #doc_view_copy 사용 안함 처리
					//item.Create == "_"?$("#ctxReply").hide():$("#ctxReply").show();		//댓글,답글
				}
			});
			
			if(_mobile_message_config.IsCheckOut == "Y"){	//체크아웃 여부 체크
				//체크아웃한 유저일 경우 체크인 표시
				if(_mobile_message_config.CheckOuterCode == mobile_comm_getSession("USERID")){
					$("#doc_view_checkin").show();
					$("#doc_view_checkoutCancel").show();
				} else if(_mobile_message_config.OwnerCode == mobile_comm_getSession("USERID")){	//게시판 관리자의 경우 체크아웃 취소를 할 수 있음 
					$("#doc_view_checkoutCancel").show();
				}
			} else {
				$("#doc_view_checkout").show();
			}
			
			if(_mobile_message_config.OwnerCode != mobile_comm_getSession("USERID")) {
				$("#doc_view_distribution").hide();
			}
			
			//dropdown 버튼 표시 유무
			if($("#doc_view_modify").css("display") != "none"
					|| $("#doc_view_delete").css("display") != "none"
					//|| $("#doc_view_copy").css("display") != "none" //smahn 190402 #doc_view_copy 사용 안함 처리
					|| $("#doc_view_move").css("display") != "none"
					|| $("#doc_viewer_list").css("display") != "none"
					|| $("#doc_view_distribution").css("display") != "none"
					|| $("#doc_view_requestAuth").css("display") != "none"
					|| $("#doc_view_approvalAuth").css("display") != "none"
					|| $("#doc_view_checkout").css("display") != "none"
					|| $("#doc_view_checkoutCancel").css("display") != "none"
					|| $("#doc_view_checkin").css("display") != "none") {
				$("div.utill").show();
			}
			
			return true;
		}
		return false;
	}
}

//폴더 경로 가져오기
function mobile_doc_getFolderPath ( pFolderPath ){
	var pathList = null;
	$.ajax({
 		type:"POST",
 		data: {
 			"folderPath": pFolderPath
 		},
 		url:"/groupware/mobile/board/selectFolderPath.do",
 		async: false,
 		success:function(data){
 			pathList = data.list;
 		},
 		error:function(response, status, error){
 		     mobile_comm_ajaxerror("/groupware/board/selectFolderPath.do", response, status, error);
 		}
 	});
	return pathList;
}

//폴더 경로 렌더링
function mobile_doc_renderFolderPath (){
	var pathList = mobile_doc_getFolderPath(_mobile_board_config.FolderPath);
	var outerHTML = "";
	if(typeof pathList != 'undefined' && pathList.length > 0){
		$.each(pathList, function(i, item){
			outerHTML += "<li>" + item.DisplayName + "</li>";
		});
		outerHTML += "<li><strong>" + _mobile_board_config.DisplayName + "</strong></li>";
	}
	return outerHTML;
}

//message config binding
function mobile_doc_selectMessageDetail(pPageType, pBizSection, pVersion, pMessageID, pFolderID){
 	$.ajax({
 		type:"POST",
 		data: {
 			"bizSection": pBizSection,
 			"version": pVersion,
 			"messageID": pMessageID,	
 			"folderID": pFolderID
 		},
 		url:"/groupware/mobile/board/selectMessageDetail.do",
 		async: false,
 		success:function(data){
 			_mobile_message_config = data.list;
 			_mobile_message_config.fileList = data.fileList;
 		},
 		error:function(response, status, error){
 		     mobile_comm_ajaxerror("/groupware/mobile/board/selectMessageDetail.do", response, status, error);
 		}
 	});
}

function mobile_doc_selectVersionDetail(pPageType, pBizSection, pVersion, pMessageID, pFolderID, pObj){
	
	var readFlag = false;	//읽기 권한
	readFlag = mobile_board_checkReadAuth(pBizSection, pFolderID, pMessageID, pVersion);

	//message config binding
	mobile_doc_selectMessageDetail(pPageType, pBizSection, pVersion, pMessageID, pFolderID);
	
	//열람 권한 확인
	if(_mobile_message_config.UseMessageReadAuth == "Y"){
		//열람권한 테이블에서 조회된 데이터가 없을경우
		if(mobile_board_getMessageReadAuthCount(_mobile_board_list.BizSection, pMessageID, folderID) > 0){
			readFlag = true;
		}
	}
	
	if(!readFlag){
		if(_mobile_board_list.BoardType == "Normal") {
			if(confirm(mobile_comm_getDic("lbl_doc_donotReadAuthRequestAuth").replace("\\n", "\n"))) { //읽기 권한이 없습니다.\n권한을 요청하시겠습니까?
				var params = {
					BoardType: _mobile_board_list.BoardType,
					FolderID: folderID,
					MessageID: pMessageID,
					Version: pVersion
				};
				return mobile_doc_requestAuth('request', params);
			} else {
				return false;
			}
		} else {
			alert(mobile_comm_getDic("msg_noViewACL")); //읽기 권한이 없습니다.
			return false;
		}
	} else {
		_mobile_board_view.Version = pVersion;
		_mobile_board_view.FolderID = pFolderID;
		_mobile_board_view.MessageID = pMessageID;
		_mobile_board_view.FolderType = "Contents";
		
		//조회 권한 확인
		$("#doc_view_detailAuth").find("span").empty().append("<strong>" + mobile_comm_getDic("lbl_MessageDetailAuth") + " : </strong>");
		
		if(mobile_comm_getSession("isAdmin") == "Y"
				|| (_mobile_board_view.BizSection != "Doc" && _mobile_message_config.CreatorCode == mobile_comm_getSession("USERID")) 
				|| (_mobile_board_view.BizSection == "Doc" && _mobile_message_config.OwnerCode == mobile_comm_getSession("USERID"))){
			$("#doc_view_detailAuth").find("span").append('<i class="ico_person"></i>' + mobile_comm_getDic("btn_Viewer") + " " + mobile_comm_getDic("btn_List") + ', '); //조회자 목록
			$("#doc_view_detailAuth").find("span").append('<i class="ico_read"></i>'+ mobile_comm_getDic("lbl_Read") + ', '); //읽기
			
			mobile_doc_getView(_mobile_board_view);
			
			if(_mobile_message_config.MsgState == "A" || _mobile_message_config.MsgState == "R"){	//게시글 승인 상태
				$("#doc_view_modify, #doc_view_delete, #doc_view_move").hide(); //smahn 190402 #doc_view_copy 사용 안함 처리
			} else {
				$("#doc_view_modify, #doc_view_delete, #doc_view_move").show(); //smahn 190402 #doc_view_copy 사용 안함 처리
				$("#doc_view_detailAuth").find("span").append('<i class="ico_edit"></i>'+ mobile_comm_getDic("lbl_Modify") + ', '); //수정
				$("#doc_view_detailAuth").find("span").append('<i class="ico_delete"></i>'+ mobile_comm_getDic("lbl_delete") + ', '); //삭제
				$("#doc_view_detailAuth").find("span").append('<i class="ico_edit"></i>'+ mobile_comm_getDic("lbl_Execute") + ', '); //실행
			}
			
			//체크아웃/체크인/체크아웃 취소
			if(_mobile_message_config.IsCheckOut == "Y"){
				//체크아웃한 유저일 경우 체크인 표시
				if(_mobile_message_config.CheckOuterCode == mobile_comm_getSession("USERID")){
					$("#doc_view_checkin").show();
					$("#doc_view_checkoutCancel").show();
				} else if(_mobile_message_config.OwnerCode == mobile_comm_getSession("USERID")){	//게시판 관리자의 경우 체크아웃 취소를 할 수 있음 
					$("#doc_view_checkoutCancel").show();
				}
			} else {
				$("#doc_view_checkout").show();
			}
			
			//권한 확인
			if(_mobile_board_view.BoardType == "DocAuth" && mobile_comm_getQueryString('requestid', "doc_view_page") != 'undefined') {
				$("#doc_view_approvalAuth").show();
			}
			
			//배포
			if(_mobile_message_config.OwnerCode != mobile_comm_getSession("USERID")) {
				$("#doc_view_distribution").hide();
			} else {
				$("#doc_view_requestAuth").hide();
			}
			
			//dropdown 버튼 표시 유무
			if($("#doc_view_modify").css("display") != "none"
					|| $("#doc_view_delete").css("display") != "none"
					|| $("#doc_view_copy").css("display") != "none"
					|| $("#doc_view_move").css("display") != "none"
					|| $("#doc_viewer_list").css("display") != "none"
					|| $("#doc_view_distribution").css("display") != "none"
					|| $("#doc_view_requestAuth").css("display") != "none"
					|| $("#doc_view_approvalAuth").css("display") != "none"
					|| $("#doc_view_checkout").css("display") != "none"
					|| $("#doc_view_checkoutCancel").css("display") != "none"
					|| $("#doc_view_checkin").css("display") != "none") {
				$("div.utill").show();
			}
			
			return true;
		} else {
			if(_mobile_board_view.MessageID != ""){
					
				mobile_doc_getView(_mobile_board_view);
				
				var aclList = mobile_board_getMessageAclList(_mobile_board_view.BizSection, _mobile_board_view.Version, _mobile_board_view.MessageID, _mobile_board_view.FolderID);
				$('#doc_viewer_list, #doc_view_modify, #doc_view_delete, #doc_view_move').hide(); //smahn 190402 #doc_view_copy 사용 안함 처리
				$.each(aclList.list,function(i, item){
					
					if(item.Security != "_") $("#doc_view_detailAuth").find("span").empty().append('<i class="ico_person"></i>' + mobile_comm_getDic("btn_Viewer") + " " + mobile_comm_getDic("btn_List") + ', '); //조회자 목록
					$("#doc_view_detailAuth").find("span").append('<i class="ico_read"></i>'+ mobile_comm_getDic("lbl_Read") + ', '); //읽기
					if(item.Modify != "_") $("#doc_view_detailAuth").find("span").empty().append('<i class="ico_edit"></i>'+ mobile_comm_getDic("lbl_Modify") + ', '); //수정
					if(item.Delete != "_") $("#doc_view_detailAuth").find("span").empty().append('<i class="ico_delete"></i>'+ mobile_comm_getDic("lbl_delete") + ', '); //삭제
					if(item.Execute != "_") $("#doc_view_detailAuth").find("span").empty().append('<i class="ico_edit"></i>'+ mobile_comm_getDic("lbl_Execute") + ', '); //실행
					
					if(item.TargetType == "UR"){
						item.Security == "_"?$("#doc_viewer_list").hide():$("#doc_viewer_list").show();	//조회자 목록
						item.Modify == "_"?$("#doc_view_modify").hide():$("#doc_view_modify").show();	//수정
						item.Delete == "_"?$("#doc_view_delete, #doc_view_move").hide():$("#doc_view_delete, #doc_view_move").show();	//삭제, 복사, 이동   //smahn 190402 #doc_view_copy 사용 안함 처리
						//item.Create == "_"?$("#ctxReply").hide():$("#ctxReply").show();		//댓글,답글
						return false;
					} else {
						item.Security == "_"?$("#doc_viewer_list").hide():$("#doc_viewer_list").show();	//조회자 목록
						item.Modify == "_"?$("#doc_view_modify").hide():$("#doc_view_modify").show();	//수정
						item.Delete == "_"?$("#doc_view_delete, #doc_view_move").hide():$("#doc_view_delete, #doc_view_move").show();	//삭제, 복사, 이동  //smahn 190402 #doc_view_copy 사용 안함 처리
						//item.Create == "_"?$("#ctxReply").hide():$("#ctxReply").show();		//댓글,답글
					}
				});
				
				if(_mobile_message_config.IsCheckOut == "Y"){	//체크아웃 여부 체크
					//체크아웃한 유저일 경우 체크인 표시
					if(_mobile_message_config.CheckOuterCode == mobile_comm_getSession("USERID")){
						$("#doc_view_checkin").show();
						$("#doc_view_checkoutCancel").show();
					} else if(_mobile_message_config.OwnerCode == mobile_comm_getSession("USERID")){	//게시판 관리자의 경우 체크아웃 취소를 할 수 있음 
						$("#doc_view_checkoutCancel").show();
					}
				} else {
					$("#doc_view_checkout").show();
				}
				
				if(_mobile_message_config.OwnerCode != mobile_comm_getSession("USERID")) {
					$("#doc_view_distribution").hide();
				}
				
				//dropdown 버튼 표시 유무
				if($("#doc_view_modify").css("display") != "none"
						|| $("#doc_view_delete").css("display") != "none"
						//|| $("#doc_view_copy").css("display") != "none" //smahn 190402 #doc_view_copy 사용 안함 처리
						|| $("#doc_view_move").css("display") != "none"
						|| $("#doc_viewer_list").css("display") != "none"
						|| $("#doc_view_distribution").css("display") != "none"
						|| $("#doc_view_requestAuth").css("display") != "none"
						|| $("#doc_view_approvalAuth").css("display") != "none"
						|| $("#doc_view_checkout").css("display") != "none"
						|| $("#doc_view_checkoutCancel").css("display") != "none"
						|| $("#doc_view_checkin").css("display") != "none") {
					$("div.utill").show();
				}
				
				return true;
			}
			return false;
		}
	}
}

//문서관리 상세 조회
function mobile_doc_getView(params) {

	var readFlagStr = mobile_board_checkReadAuth(_mobile_board_view.BizSection, _mobile_board_view.FolderID, _mobile_board_view.MessageID, _mobile_board_view.Version);
	var paramdata = {
		bizSection: params.BizSection,
		boardType: params.BoardType,
		folderID: params.FolderID,
		messageID: params.MessageID,
		version: params.Version,
		searchText: params.SearchText,
		menuID: params.MenuID,
		page: params.Page,
		readFlagStr: readFlagStr
	};
	
	var url = "/groupware/mobile/board/getBoardMessageView.do";
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		async: false,
		success: function (response) {
			
			if(response.status == "SUCCESS") {
				
				// 1. 글 정보				
				$('#doc_view_folder').empty().html(response.config.DisplayName);				
				$('#doc_view_subject').empty().html(
					(response.view.IsCheckOut == 'Y' ? '<i class="ico_lock"></i>' : '<i class="ico_unlock"></i>') + response.view.Subject
				);
				$('#doc_view_folderpath').empty().append(mobile_doc_renderFolderPath());
				$('#doc_view_writer').empty().html(response.view.CreatorName);
				$('div.post_title a.thumb').attr('style', 'background-image: url("' + mobile_comm_getimg(response.view.PhotoPath) + '"), url("' + mobile_comm_noperson() + '");');			
				$('#doc_view_writedate').empty().html(mobile_comm_getDateTimeString2('view', CFN_TransLocalTime(response.view.RegistDate)));
				$('#doc_view_readcnt').empty().html(response.view.ReadCnt);
				
				$('#doc_view_docNumber').empty().append(response.view.Number);
				$('#doc_view_revisionName').empty().append(response.view.RevisionName);
				$('#doc_view_ownerName').empty().append(response.view.OwnerName);
				$('#doc_view_revisionDate').empty().append( CFN_TransLocalTime(response.view.RevisionDate));
				
				if(response.view.KeepYear != "" && response.view.KeepYear != undefined) {
					$('#doc_view_keepYear').empty().append(response.view.KeepYear + mobile_comm_getDic("lbl_year"));
				} else if(response.view.ExpiredDate != "" && response.view.ExpiredDate != undefined) {
					var expireYear = CFN_TransLocalTime(response.view.ExpiredDate).split(".")[0];
					var registYear = CFN_TransLocalTime(response.view.RegistDate).split(".")[0];
					var keepYear = expireYear - registYear;
					if(keepYear >= 99) keepYear = mobile_comm_getDic("lbl_permanence"); //영구
					else keepYear = keepYear + mobile_comm_getDic("lbl_year");
					$('#doc_view_keepYear').empty().append(keepYear);
					
				}
				
				$('#doc_view_expiredDate').empty().append(CFN_TransLocalTime(response.view.ExpiredDate));
				
				// 2. 첨부처리
				$('#doc_view_attach').empty().html(mobile_comm_downloadhtml(response.file));
				
				// 4. 본문
				$('#doc_view_body').empty().html(XSSBoard(unescape(response.view.Body)));
				setTimeout(function () {
					mobile_comm_replacebodyinlineimg($('#doc_view_body'));
					mobile_comm_replacebodylink($('#doc_view_body'));
				}, 100);
				
				// 5. 태그
				var sTagHtml = "";
				$(response.tag).each(function (i, taginfo){
					sTagHtml += "<span class=\"tx\">" + taginfo.Tag + "</span>";
				});
				$('#doc_view_tag').empty().html(sTagHtml);

				// TODO: 6. 연결문서 - doc_view_linkedDoc
				var sLinkedHtml = "";
				$(response.linked).each(function (i, linkedinfo) {
					var sUrl = "/groupware/mobile/doc/view.do?boardtype=Normal&page=1";
					sUrl += "&folderid=" + linkedinfo.FolderID;
					sUrl += "&messageid=" + linkedinfo.MessageID;
					sUrl += "&version=" + linkedinfo.Version;
					
					sLinkedHtml += "<a href=\"javascript: mobile_comm_go('" + sUrl + "');\"><span class=\"\">" + linkedinfo.DisplayName + "</span></a>";
				});
				$("#doc_view_linkedDoc").empty().append(sLinkedHtml);
				// TODO: 7. 상세권한 - doc_view_detailAuth (ViewInit에서 처리)
				
				// 8. 좋아요
				// 9. 댓글
				mobile_comment_getCommentLike('Doc', params.MessageID + '_'  + params.Version , 'N');

				// 10. 개정정보				
				mobile_doc_getRevisionHistory();
				
				// 11. 이전글/다음글(컨텐츠 게시인 경우 표시하지 않음)
				/*if(pFolderType != "Contents"){				
					var sPrevNextHtml = "";
					if(response.prevnext.prev.MessageID != undefined) {
						var sUrl = "/groupware/mobile/" + params.BizSection.toLowerCase() + "/view.do?";
						sUrl += "boardtype=Normal";
						sUrl += "&folderid=" + response.prevnext.prev.FolderID;
						sUrl += "&page=" + params.Page;
						sUrl += "&searchtext=" + params.SearchText;
						sUrl += "&messageid=" + response.prevnext.prev.MessageID;
						
						sPrevNextHtml += "<a href=\"javascript: mobile_comm_go('" + sUrl + "');\" class=\"prev\">";
						sPrevNextHtml += "    <span class=\"bu\">이전글</span>";//TODO: 다국어처리
						sPrevNextHtml += "    <span class=\"tx\"><span class=\"ellip\">" + response.prevnext.prev.Subject + "</span></span>";
						sPrevNextHtml += "    <span class=\"re_num\">(" + response.prevnext.prev.CommentCnt + ")</span>";
						sPrevNextHtml += "</a>";
					} else {
						sPrevNextHtml += "<a href=\"#\" class=\"prev\">";
						sPrevNextHtml += "    <span class=\"bu\">이전글</span>";//TODO: 다국어처리
						sPrevNextHtml += "    <span class=\"tx\"><span class=\"ellip\">이전 글이 없습니다.</span></span>";//TODO: 다국어처리
						sPrevNextHtml += "    <span class=\"re_num\"></span>";
						sPrevNextHtml += "</a>";
					}
					if(response.prevnext.next.MessageID != undefined) {
						var sUrl = "/groupware/mobile/" + params.BizSection.toLowerCase() + "/view.do?";
						sUrl += "boardtype=Normal";
						sUrl += "&folderid=" + response.prevnext.next.FolderID;
						sUrl += "&page=" + params.Page;
						sUrl += "&searchtext=" + params.SearchText;
						sUrl += "&messageid=" + response.prevnext.next.MessageID;
						
						sPrevNextHtml += "<a href=\"javascript: mobile_comm_go('" + sUrl + "');\" class=\"next\">";
						sPrevNextHtml += "    <span class=\"bu\">다음글</span>";//TODO: 다국어처리
						sPrevNextHtml += "    <span class=\"tx\"><span class=\"ellip\">" + response.prevnext.next.Subject + "</span></span>";
						sPrevNextHtml += "    <span class=\"re_num\">(" + response.prevnext.next.CommentCnt + ")</span>";
						sPrevNextHtml += "</a>";
					} else {
						sPrevNextHtml += "<a href=\"#\" class=\"next\">";
						sPrevNextHtml += "    <span class=\"bu\">다음글</span>";//TODO: 다국어처리
						sPrevNextHtml += "    <span class=\"tx\"><span class=\"ellip\">다음 글이 없습니다.</span></span>";//TODO: 다국어처리
						sPrevNextHtml += "    <span class=\"re_num\"></span>";
						sPrevNextHtml += "</a>";
					}
					$('#doc_view_prevnext').html(sPrevNextHtml);
				}*/
				
				// 12. 사용자 권한에 따른 확장메뉴 바인딩(수정/삭제/복사/이동/조회자 목록)
				$("#doc_view_modify").show();
				$("#doc_view_modify").find("a").attr("onclick", "alert(\"" + mobile_comm_getDic("msg_board_donotSaveInlineImage") + "\"); mobile_board_gowrite(" + response.config.MenuID + "," + params.FolderID + "," + params.MessageID + "," + params.Version + ",'" + params.CU_ID + "','" + params.BoardType + "','" + params.SearchText + "')"); //수정 시 본문의 인라인 이미지는 저장되지 않습니다.
				$("#doc_view_delete").show();
				$("#doc_view_delete").find("a").attr("onclick", "mobile_doc_clickbtn('', 'delete')");
				//$("#doc_view_copy").show(); //smahn 190402 #doc_view_copy 사용 안함 처리
				//$("#doc_view_copy").find("a").attr("onclick", "mobile_open_folder('copy')"); //smahn 190402 #doc_view_copy 사용 안함 처리
				$("#doc_view_move").show();
				$("#doc_view_move").find("a").attr("onclick", "mobile_open_folder('move')");
				$("#doc_viewer_list").show();
				$("#doc_viewer_list").find("a").attr("onclick", "mobile_board_message_viewer()");
				$("#doc_view_distribution").show();
				$("#doc_view_distribution").find("a").attr("onclick", "mobile_doc_clickbtn('', 'distribute')");
				$("#doc_view_requestAuth").show();
				$("#doc_view_requestAuth").find("a").attr("onclick", "mobile_doc_requestAuth('request')");
				$("#doc_view_approvalAuth").hide();
				$("#doc_view_approvalAuth").find("a").attr("onclick", "mobile_doc_requestAuth('approval')");
				$("#doc_view_checkout").hide();
				$("#doc_view_checkout").find("a").attr("onclick", "mobile_doc_clickbtn('', 'checkout')");
				$("#doc_view_checkoutCancel").hide();
				$("#doc_view_checkoutCancel").find("a").attr("onclick", "mobile_doc_clickbtn('', 'cancel')");
				$("#doc_view_checkin").hide();
				$("#doc_view_checkin").find("a").attr("onclick", "mobile_doc_clickbtn('', 'checkin')");
				
				$('#board_folder_list').empty().html(mobile_board_SelFolderBinding(response.treedata, "Doc"));
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//확장메뉴 show or hide
function mobile_doc_showORhide(obj) {
	if($(obj).parent().hasClass("show")) {
		$(obj).parent().removeClass("show");
	} else {
		$(obj).parent().addClass("show");
	}
}

//게시 버전별 이력 조회
function mobile_doc_getRevisionHistory() {
	var sHtml = "";
	
	$.ajax({
 		type:"POST",
		async: false,
 		data: {
 			"messageID": _mobile_board_view.MessageID,
 			"version" : _mobile_board_view.Version
 		},
 		url:"/groupware/mobile/board/selectRevisionHistory.do",
 		success:function(data){
 			if(data.status=='SUCCESS'){
 				$("#doc_view_revisionInfo").html($('<p class="tit" />').text(mobile_comm_getDic("lbl_RevisionInfo"))); //개정정보
 				
 				$.each(data.list, function(i, item){
 					sHtml += '<dl class="' + (item.IsCurrent == "Y" ? 'new' : '') + '" onclick="javascript:mobile_doc_selectVersionDetail(\'View\', \'' + 'Doc' + '\', ' + item.Version + ', ' + item.MessageID + ', ' + _mobile_board_view.FolderID + ', this);">';
 					sHtml += '	<dt>' + item.Subject + '</dt>';
 					sHtml += '	<dd class="version">Ver.' + item.Version + '</dd>';
 					sHtml += '	<dd>' + (item.Version > 1 ? mobile_comm_getDicInfo(item.RevisionName) : "") + '</dd>';
 					sHtml += '	<dd>' + CFN_TransLocalTime(item.RevisionDate+" "+item.RevisionTime).split(' ')[0] + '</dd>';
 					sHtml += '</dl>';
 				});
 				
 				$("#doc_view_revisionInfo").append(sHtml);
 				
 			} else {
 				alert(mobile_comm_getDic('msg_apv_030'));//오류가 발생헸습니다.
 			}
 		},
 		error:function(response, status, error){
 		     mobile_comm_ajaxerror("/groupware/mobile/board/selectCheckInOutHistory.do", response, status, error);
 		}
 	});
}

var doc_view_process_type = "";
//처리사유 창 열고 닫기
function mobile_doc_clickbtn(obj, type) {
	$('.btn_exmenu').trigger("click");
	doc_view_process_type = type;
	
	if(obj == undefined || obj === '') 
		obj = $(".approval_comment");
	
	if(type != 'toggle') {
		if(type == "request") {
			mobile_doc_doBtnClick('Y');
		} else {
			$(obj).parents().addClass('open');
			$('.approval_comment').animate({height:"156px"});
		}
	} else {
		$(".approval_comment").animate(
			{height:"0"},
			{complete : function(){$(obj).parents().removeClass('open');}}
		);
	}
}

//처리사유 창에서 확인/취소 눌렀을 때
function mobile_doc_doBtnClick(type) {
	if(type == "Y") { //확인
		switch(doc_view_process_type) {
		case "checkout":
		case "modify":
			mobile_doc_updateCheckOutMessage("Out");
			break;
		case "checkin":
			mobile_doc_updateCheckOutMessage("In");
			break;
		case "cancel":
			mobile_doc_updateCheckOutMessage("Cancel");
			break;
		case "delete":
			mobile_board_message_delete();
			break;
		case "allow":
			mobile_doc_allowMessage();
			break;
		case "deny":
			mobile_doc_denyMessage();
			break;
		case "request":
			mobile_doc_saveAclRequest();
			break;
		case "accept":
			mobile_doc_acceptMessage();
			break;
		case "reject":
			mobile_doc_rejectMessage();
			break;
		case "distribute":
			mobile_doc_openOrg("Distribute");
			break;
		default:
			return;	
		}
	
	} else { 		  //취소
		$("#doc_view_inputcomment").val("");
		mobile_doc_clickbtn('', 'toggle');
	}
}

//체크인/체크아웃/체크아웃 취소/수정 시
function mobile_doc_updateCheckOutMessage(pActType){
    $.ajax({
    	type:"POST",
    	url:"/groupware/mobile/board/updateCheckOutState.do",
    	data:{
    		"bizSection": _mobile_board_view.BizSection
    		,"messageID": _mobile_board_view.MessageID
    		,"version": _mobile_board_view.Version
    		,"actType": pActType
    		,"comment": $("#doc_view_inputcomment").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />')
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){			//성공시 수정페이지로 이동
    			alert(mobile_comm_getDic("msg_com_processSuccess")); // 성공적으로 처리되었습니다.
    			if (doc_view_process_type == "modify") {
    				mobile_comm_go(g_sUrl, "Y");
    			} else {
    				mobile_comm_back();
    				mobile_board_clickrefresh();
    			}
    		}else{
    			alert(mobile_comm_getDic('msg_apv_030'));//오류가 발생헸습니다.
    		}
    	},
    	error:function(response, status, error){
    	     mobile_comm_ajaxerror("/groupware/mobile/board/updateCheckOutState.do", response, status, error);
    	}
    });
}

//권한 요청
function mobile_doc_requestAuth(pType, pParameter) { // pType : 승인(approval) / 요청(request)
	var sUrl = "";
	sUrl = "/groupware/mobile/doc/auth.do";
	sUrl += "?acttype=" + pType;
	if(pParameter == undefined) {
		sUrl += "&messageid=" + _mobile_board_view.MessageID;
		sUrl += "&folderid=" + _mobile_board_view.FolderID;
		sUrl += "&version=" + _mobile_board_view.Version;
		sUrl += "&boardtype=" + _mobile_board_view.BoardType;
	} else {
		sUrl += "&messageid=" + pParameter.MessageID;
		sUrl += "&folderid=" + pParameter.FolderID;
		sUrl += "&version=" + pParameter.Version;
		sUrl += "&boardtype=" + pParameter.BoardType;
	}
	if (mobile_comm_getQueryString('requestid') != 'undefined') {
		sUrl += "&requestid=" + mobile_comm_getQueryString('requestid');
	} else if (mobile_comm_getQueryString('requestid', 'doc_view_page') != 'undefined') {
		sUrl += "&requestid=" + mobile_comm_getQueryString('requestid', 'doc_view_page');
	}
	
	mobile_comm_go(sUrl, 'Y');
}

/*
 * 
 * 문서관리 상세 끝
 * 
 */


/*
 * 
 * 문서관리 권한 요청/승인 시작
 * 
 */

var _mobile_board_auth = {
		
	// 리스트 조회 초기 데이터
	BoardType: '',		//boardType-Total/Approval 등등
	FolderID: '',		//폴더ID-없으면 전체 조회
	Page: 1,			//조회할 페이지
	PageSize: 10,		//페이지별  열 개수
	MessageID: '',		//메시지ID
	MenuID: '',			//메뉴ID
	FolderType: '',		//폴더 타입(컨텐츠 게시 식별하기 위함)
	Version: 1,			//메세지 version
	ActType: '',		//액션 타입
	RequestID: '',		//요청ID
	BizSection: 'Board'
};

//문서관리-권한 초기화
function mobile_doc_AuthInit() {
	
	//close 버튼 제거
	$("div.sub_header").siblings("a.ui-icon-delete").remove();

	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('boardtype', 'doc_auth_page') != 'undefined') {
		_mobile_board_auth.BoardType = mobile_comm_getQueryString('boardtype', 'doc_auth_page');
	} else {
		_mobile_board_auth.BoardType = 'Normal';
	}
	if (mobile_comm_getQueryString('folderid', 'doc_auth_page') != 'undefined') {
		_mobile_board_auth.FolderID = mobile_comm_getQueryString('folderid', 'doc_auth_page');
    } else {
    	_mobile_board_auth.FolderID = '';
    }
	if (mobile_comm_getQueryString('page', 'doc_auth_page') != 'undefined') {
		_mobile_board_auth.Page = mobile_comm_getQueryString('page', 'doc_auth_page');
    } else {
    	_mobile_board_auth.Page = 1;
    }
	if (mobile_comm_getQueryString('searchtext', 'doc_auth_page') != 'undefined') {
		_mobile_board_auth.SearchText = mobile_comm_getQueryString('searchtext', 'doc_auth_page');
    } else {
    	_mobile_board_auth.SearchText = '';
    }
	if (mobile_comm_getQueryString('messageid', 'doc_auth_page') != 'undefined') {
		_mobile_board_auth.MessageID = mobile_comm_getQueryString('messageid', 'doc_auth_page');
    } else {
    	_mobile_board_auth.MessageID = 0;
    }
	if (mobile_comm_getQueryString('menuid', 'doc_auth_page') != 'undefined') {
		_mobile_board_auth.MenuID = mobile_comm_getQueryString('menuid', 'doc_auth_page');
    } else {
    	_mobile_board_auth.MenuID = 0;
    }
	if (mobile_comm_getQueryString('foldertype', 'doc_auth_page') != 'undefined') {
		_mobile_board_auth.FolderType = mobile_comm_getQueryString('foldertype', 'doc_auth_page');
    } else {
    	_mobile_board_auth.FolderType = '';
    }
	if (mobile_comm_getQueryString('version', 'doc_auth_page') != 'undefined') {
		_mobile_board_auth.Version = mobile_comm_getQueryString('version', 'doc_auth_page');
    } else {
    	_mobile_board_auth.Version = '1';
    }
	if (mobile_comm_getQueryString('acttype', 'doc_auth_page') != 'undefined') {
		_mobile_board_auth.ActType = mobile_comm_getQueryString('acttype', 'doc_auth_page');
    } else {
    	_mobile_board_auth.ActType = 'request';
    }
	if (mobile_comm_getQueryString('requestid', 'doc_auth_page') != 'undefined') {
		_mobile_board_auth.RequestID = mobile_comm_getQueryString('requestid', 'doc_auth_page');
    } else {
    	_mobile_board_auth.RequestID = '';
    }
	if (mobile_comm_getQueryString('menucode', 'doc_auth_page') != 'undefined') {
		_mobile_board_auth.BizSection = mobile_comm_getQueryString('menucode', 'doc_auth_page').replace("Main", "");
	} else {
		var bizSection = "";
		bizSection = location.pathname.split("/")[3];
		bizSection = bizSection.charAt(0).toUpperCase() + bizSection.slice(1);
		_mobile_board_auth.BizSection = bizSection;
	}
	
	mobile_board_getBoardConfig(_mobile_board_auth.FolderID);
	mobile_doc_selectMessageDetail("View", _mobile_board_auth.BizSection, _mobile_board_auth.Version, _mobile_board_auth.MessageID, _mobile_board_auth.FolderID);
	
	$('#doc_auth_subject').html((_mobile_message_config.IsCheckOut == 'Y' ? '<i class="ico_lock"></i>' : '<i class="ico_unlock"></i>') + _mobile_message_config.Subject);
	$('#doc_auth_folderpath').append(mobile_doc_renderFolderPath());
	$('#doc_auth_hidOwnerCode').val(_mobile_message_config.OwnerCode);
	
	if(_mobile_board_auth.ActType == "request") {
		mobile_doc_getCurrentAcl('R');
		$('#doc_auth_requester').html(mobile_comm_getSession("USERNAME"));
		$('#doc_auth_thumb').attr('style', 'background-image: url("' + mobile_comm_getimg(mobile_comm_getSession("PhotoPath")) + '"), url("' + mobile_comm_noperson() + '");');
		$('#doc_auth_requestdate').html(CFN_TransLocalTime(_mobile_message_config.RegistDate));
		
		//$("#doc_auth_div_current").show();
		$("#doc_auth_div_request").show();
		$("#doc_auth_inputreason").show();
		$("#doc_auth_btn_request").show();
		//$("#doc_auth_backBtn").attr("onclick", "mobile_comm_go('/groupware/mobile/" + _mobile_board_auth.BizSection.toLowerCase() + "/list.do?menucode=" + _mobile_board_auth.BizSection + "Main');");
		$("#doc_auth_backBtn").attr("onclick", "mobile_comm_back();");
	} else {
		mobile_doc_getCurrentAcl();
		mobile_doc_getRequestAcl();
		
		$("#doc_auth_div_current").show();
		$("#doc_auth_div_request").show();
		$("#doc_auth_txtreason").show();
		$("#doc_auth_backBtn").attr("onclick", "mobile_comm_back();");
	}
	
	return false;
}

//권한 요청정보 설정
function mobile_doc_getRequestAcl(){
	$.ajax({
    	type:"POST",
    	url: "/groupware/mobile/board/selectRequestAclDetail.do",
    	data: {
	    	'requestID': _mobile_board_auth.RequestID
	    },
    	dataType : 'json',
    	success:function(res){
    		if(res.status=='SUCCESS'){
	    		var data = res.data;
	    		$('#doc_auth_requester').html(data.RequestorName);
	    		$('div.post_title a.thumb').attr('style', 'background-image: url(' + data.PhotoPath + ');');			
	    		$('#doc_auth_requestdate').html(CFN_TransLocalTime(data.RequestDate));
	    		$('#doc_auth_txtreason').html(data.RequestMessage);
	    		
	    		var aclList = data.RequestAclList;
	    		aclList.indexOf("S")!=-1?$('#doc_auth_secretAuth_R').addClass('on'):"";
	    		aclList.indexOf("D")!=-1?$('#doc_auth_deleteAuth_R').addClass('on'):"";
	    		aclList.indexOf("M")!=-1?$('#doc_auth_modifyAuth_R').addClass('on'):"";
	    		aclList.indexOf("E")!=-1?$('#doc_auth_executeAuth_R').addClass('on'):"";
	    		aclList.indexOf("R")!=-1?$('#doc_auth_readAuth_R').addClass('on'):"";

	    		if(data.ActType != "R"){
		    		$('#doc_auth_btn_approval').hide();
		    	} else {
		    		$('#doc_auth_btn_approval').show();
		    	}
    		}else{
    			alert(mobile_comm_getDic("msg_ErrorOccurred")); //오류가 발생하였습니다.
    		}
    	}, 
  		error:function(error){
  			mobile_comm_ajaxerror("/groupware/mobile/board/selectRequestAclDetail.do", response, status, error);
  		}
    });
}

//권한 현재정보 설정
function mobile_doc_getCurrentAcl(requestType){
	//requestType: 기본 C, 권한요청 시 R
	if(requestType == undefined) {
		requestType = "C"
	}
	var bSecurityFlag = false;
	var bReadFlag = false;
	var bModifyFlag = false;
	var bDeleteFlag = false;
	var bExecuteFlag = false;
	
	var aclList = mobile_board_getMessageAclList( "Doc", _mobile_board_auth.Version, _mobile_board_auth.MessageID, _mobile_board_auth.FolderID );
	$.each(aclList.list,function(i, item){
		if(item.TargetType == "UR"){
			bSecurityFlag = item.Security == "_"?false:true;
			bReadFlag = item.Read == "_"?false:true;
			bModifyFlag = item.Modify == "_"?false:true;
			bDeleteFlag = item.Delete == "_"?false:true;
			bExecuteFlag = item.Execute == "_"?false:true;
			return false;
		} else {
			bSecurityFlag = item.Security == "_"?false:true;
			bReadFlag = item.Read == "_"?false:true;
			bModifyFlag = item.Modify == "_"?false:true;
			bDeleteFlag = item.Delete == "_"?false:true;
			bExecuteFlag = item.Execute == "_"?false:true;
		}
	});

	if(bSecurityFlag){ $('#doc_auth_secretAuth_' + requestType).addClass('on'); }
	if(bReadFlag){ $('#doc_auth_readAuth_' + requestType).addClass('on'); }
	if(bModifyFlag){ $('#doc_auth_modifyAuth_' + requestType).addClass('on'); }
	if(bDeleteFlag){ $('#doc_auth_deleteAuth_' + requestType).addClass('on'); }
	if(bExecuteFlag){ $('#doc_auth_executeAuth_' + requestType).addClass('on'); }
}

//설정한 권한정보 반환
function mobile_doc_setAclList(){
	var aclList = '';
	var mode = "R";//_mobile_board_auth.ActType == "request" ? "C" : "R";
	aclList += $('#doc_auth_secretAuth_' + mode).hasClass('on')?"S":"_";
	aclList += "_";	//C : 생성
	aclList += $('#doc_auth_deleteAuth_' + mode).hasClass('on')?"D":"_";
	aclList += $('#doc_auth_modifyAuth_' + mode).hasClass('on')?"M":"_";
	aclList += $('#doc_auth_executeAuth_' + mode).hasClass('on')?"E":"_";
	aclList += $('#doc_auth_readAuth_' + mode).hasClass('on')?"R":"_";
	return aclList;
}

//권한 승인 요청
function mobile_doc_saveAclRequest(){
	if($("#doc_auth_inputreason").val()==""){
		alert(mobile_comm_getDic("msg_doc_inputRequestReason")); //요청 사유를 입력해주세요.
		$("#doc_auth_inputreason").focus();
		return;
	}

	$.ajax({
    	type:"POST",
    	url: "/groupware/mobile/board/createRequestAuth.do",
    	data: {
	    	'messageID': _mobile_board_auth.MessageID
	    	,'folderID': _mobile_board_auth.FolderID
	    	,'version': _mobile_board_auth.Version
	    	,'aclList': mobile_doc_setAclList()
	    	,'requestMsg': $('#doc_auth_inputreason').val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />')
	    	,'ownerCode':$('#doc_auth_hidOwnerCode').val()
	    },
    	dataType : 'json',
    	success:function(data){
    		if(data.status=='SUCCESS'){
	    		alert(data.message);
	    		//mobile_comm_go("/groupware/mobile/" + _mobile_board_auth.BizSection.toLowerCase() + "/list.do?menucode=" + _mobile_board_auth.BizSection + "Main" );
	    		mobile_comm_back();
    		}else{
    			alert(mobile_comm_getDic("msg_ErrorOccurred")); //오류가 발생하였습니다.
    		}
    	}, 
  		error:function(error){
  			mobile_comm_ajaxerror("/groupware/mobile/board/createRequestAuth.do", response, status, error);
  		}
    });
}

//권한 요청 승인
function mobile_doc_allowMessage (){
	var messageIDs = '';
	var requestIDs = '';
	var versions = '';
	var comments = '';
	var customAcl = '';
	
	messageIDs = _mobile_board_auth.MessageID;
	requestIDs = _mobile_board_auth.RequestID;
	versions = _mobile_board_auth.Version;
	comments = $('#doc_auth_inputcomment').val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />');
	customAcl = mobile_doc_setAclList();
	
    $.ajax({
    	type:"POST",
    	url:"/groupware/mobile/board/allowMessage.do",
    	data:{
    		"bizSection": "Doc"
    		,"messageID": messageIDs
    		,"requestID": requestIDs
    		,"version"	: versions
    		,"comment"	: comments
    		,"customAcl": customAcl
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
	    		alert(data.message);
	    		mobile_comm_back();
    		}else{
    			alert(mobile_comm_getDic("msg_ErrorOccurred")); //오류가 발생하였습니다.
    		}
    	},
    	error:function(response, status, error){
    		mobile_comm_ajaxerror("/groupware/mobile/board/allowMessage.do", response, status, error);
    	}
    });
}

//권한 요청 거부
function mobile_doc_denyMessage (){
	if($("#doc_auth_inputcomment").val()==""){
		alert(mobile_comm_getDic("msg_doc_inputProcessReason")); //처리 사유를 입력해주세요.
		$("#doc_auth_inputcomment").focus();
		return;
	}
	
	var messageIDs = '';
	var requestIDs = '';
	var versions = '';
	var comments = '';

	messageIDs = _mobile_board_auth.MessageID;
	requestIDs = _mobile_board_auth.RequestID;
	versions = _mobile_board_auth.Version;
	comments = $('#doc_auth_inputcomment').val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />');
	
    $.ajax({
    	type:"POST",
    	url:"/groupware/mobile/board/denieMessage.do",
    	data:{
    		"bizSection": "Doc"
    		,"messageID": messageIDs
    		,"requestID": requestIDs
    		,"version"	: versions
    		,"comment": comments
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
	    		alert(data.message);
	    		mobile_comm_back();
    		}else{
    			alert(mobile_comm_getDic("msg_ErrorOccurred")); //오류가 발생하였습니다.
    		}
    	},
    	error:function(response, status, error){
    		mobile_comm_ajaxerror("/groupware/mobile/board/denieMessage.do", response, status, error);
    	}
    });
}


/*
 * 
 * 문서관리 권한 요청/승인 끝
 * 
 */


//게시글 승인
function mobile_doc_acceptMessage (){
	var messageIDs = '';
	var processIDs = '';

	messageIDs = _mobile_board_view.MessageID;
	processIDs = _mobile_board_view.ProcessID;
	
    $.ajax({
    	type:"POST",
    	url:"/groupware/mobile/board/acceptMessage.do",
    	data:{
    		"bizSection": _mobile_board_view.BizSection
    		,"messageID": messageIDs
    		,"processID": processIDs
    		,"comment": $("#doc_view_inputcomment").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />')
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			alert(data.message);
    			mobile_comm_back();
    			mobile_board_clickrefresh();
    		}else{
    			alert(mobile_comm_getDic('msg_apv_030'));//오류가 발생헸습니다.
    		}
    	},
    	error:function(response, status, error){
    	     //TODO 추가 오류 처리
    	     mobile_comm_ajaxerror("/groupware/mobile/board/acceptMessage.do", response, status, error);
    	}
    });
}

//게시글 승인 거부
function mobile_doc_rejectMessage (){
	var messageIDs = '';
	var processIDs = '';

	messageIDs = _mobile_board_view.MessageID;
	processIDs = _mobile_board_view.ProcessID;
	
    $.ajax({
    	type:"POST",
    	url:"/groupware/mobile/board/rejectMessage.do",
    	data:{
    		"bizSection": _mobile_board_view.BizSection
    		,"messageID": messageIDs
    		,"processID": processIDs
    		,"comment": $("#doc_view_inputcomment").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />')
    	},
    	success:function(data){
    		if(data.status=='SUCCESS'){
    			alert(data.message);
    			mobile_comm_back();
    			mobile_board_clickrefresh();
    		}else{
    			alert(mobile_comm_getDic('msg_apv_030'));//오류가 발생헸습니다.
    		}
    	},
    	error:function(response, status, error){
    	     //TODO 추가 오류 처리
    		mobile_comm_ajaxerror("/groupware/mobile/board/rejectMessage.do", response, status, error);
    	}
    });
}


// 문서관리 별도 함수 종료

//상단공지 버튼&체크박스 이벤트 적용
function mobile_board_ctrlNotice() {
	if($('#board_top').prop("checked")) {
		$('.ico_notice_btn').addClass('on');
	} else {
		$('.ico_notice_btn').removeClass('on');
	}
	
	if($('#board_popup').prop("checked")) {
		$('.ico_popup_btn').addClass('on');
	} else {
		$('.ico_popup_btn').removeClass('on');
	}
}

//조직도 호출
function mobile_board_openWebhard() {
	var sUrl = "/webhard/mobile/webhard/list.do";
	window.sessionStorage["webhardopentype"] = "common";	
	window.sessionStorage["callback"] = "mobile_board_webhardcallback();";
	
	mobile_comm_go(sUrl, 'Y');
}

//
function mobile_board_webhardcallback() {
	var sHtml = "";
	var dataObj = window.sessionStorage["webhardfileinfo"];
	var sExt = "";
	mobile_comm_changewebhardupload(dataObj);
	/*
	$(".btn_add_person").each(function(i,obj){
		sExt = $(this).attr("data-value").split("|")[0]+"|"+sExt;
	});
	
	$(dataObj).each(function(i){
		var userCode = $$(this).attr("AN");
		var userName = mobile_comm_getDicInfo($$(this).attr("DN"));
		
		var dataJson = "data-json=\'" + JSON.stringify({"UserCode":userCode,"UserName":userName, "MailAddress":$(this).attr("EM"),"label":userName,"value":userCode}) + "\'";
		var dataValue = "data-value=\"" + userCode + "|NEW\"";
		if(sExt.indexOf(userCode+"|") > -1)
			return;
		
		sHtml += "<a onclick=\"mobile_schedule_delUser(this);\" class=\"btn_add_person\" " + dataJson + " " + dataValue + ">";
		sHtml += 		userName;
		sHtml += "</a>";
	});
	
    $("dl.attendant dd.name_list_wrap").append(sHtml);
	$("dl.attendant dd.name_list_wrap").show();
	*/
}

function XSSBoard(body){
	var defaultFilterKey = "oncontextmenu,onmousemovexx,innerHTML,onmousewheel,onactive,onfocusxxout,expression,charset,ondataavailable,oncut,onkeyup,applet,onafteripudate,onclickxx,onkeypress,meta,string,onmousedownxx,onchange,onloadxx,xml,create,onbeforeactivate,onbeforecut,onbounce,blink,append,onbeforecopy,ondbclick,onmouseenter,link,binding,onbeforedeactivate,ondeactivate,onmouseout,ondatasetchaged,ondrag,onmouseoverxx,script,msgbox,cnbeforeprint,ondragendxx,onsubmit,embed,refresh,cnbeforepaste,ondragenter,onmouseend,object,void,onbeforeeditfocus,ondragleave,onresizexxstart,iframe,cookie,onbeforeuload,ondragover,onuload,frame,onbeforeupdate,ondragstart,onselectstart,frameset,onpaste,onpropertychange,ondrop,onreset,ilayer,onresize,ondatasetcomplete,onerrorxx,onmove,layer,onselect,oncellchange,onfinish,onstop,bgsound,base,onlayoutcomplete,onfocus,onrowexit,onblurxx,onselectionchange,vbscript,onerrorupdate,onbefore,onstart,onrowsinserted,onkeydownxx,onfilterchage,onmouseupxx,onfocusin,oncontrolselected,onrowsdelete,onlosecapture,onrowenter,onhelp,onreadystatechange,onmouseleave,onmousemove";
	var XSSFilterKey = mobile_comm_getBaseConfig("XSSFilterKey") ? mobile_comm_getBaseConfig("XSSFilterKey") : defaultFilterKey; // 기초설정 값 추가
	XSSFilterKey = XSSFilterKey + "," + "script,eval";
	XSSFilterKey = XSSFilterKey.replace(/\s/g, ""); // 공백 제거
	var XSSText = XSSFilterKey.split(",");				

	$.each(XSSText, function(idx, item){
		if(item){
			var regexAllCase = new RegExp("(</?[^>]*)"+ item +"([^>]*?>)", "gi");
			body = body.replace(regexAllCase, "$1x$2");
		}
	});
	
	return body;
}
