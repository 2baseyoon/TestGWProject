
/*!
 * 
 * 
 * SmartS4j / MobileOffice / 모바일 커뮤니티 js 파일
 * 함수명 : mobile_community_...
 * 
 * 
 */



/*!
 * 
 * 페이지별 init 함수
 * 
 */

//커뮤니티 포탈 페이지
$(document).on('pageinit', '#community_portal_page', function () {
	if($("#community_portal_page").attr("IsLoad") != "Y"){
		$("#community_portal_page").attr("IsLoad", "Y");
		setTimeout("mobile_community_PortalInit()", 10);
	}
});

//커뮤니티 리스트 페이지
$(document).on('pageinit', '#community_list_page', function () {
	if($("#community_list_page").attr("IsLoad") != "Y"){
		$("#community_list_page").attr("IsLoad", "Y");
		setTimeout("mobile_community_ListInit()", 10);
	}
});

//커뮤니티 홈 페이지(커뮤니티 개별)
$(document).on('pageinit', '#community_home_page', function () {
	if($("#community_home_page").attr("IsLoad") != "Y"){
		$("#community_home_page").attr("IsLoad", "Y");
		setTimeout("mobile_community_HomeInit()", 10);
	}
});

//커뮤니티 가입신청
$(document).on('pageinit', '#community_apply_page', function () {
	if($("#community_apply_page").attr("IsLoad") != "Y"){
		$("#community_apply_page").attr("IsLoad", "Y");
		setTimeout("mobile_community_ApplyInit()", 10);	
	}
});

//커뮤니티 탈퇴신청
$(document).on('pageinit', '#community_withdrawal_page', function () {
	if($("#community_withdrawal_page").attr("IsLoad") != "Y"){
		$("#community_withdrawal_page").attr("IsLoad", "Y");
		setTimeout("mobile_community_WithdrawalInit()", 10);	
	}
});

//커뮤니티 상세정보
$(document).on('pageinit', '#community_homeinfo_page', function () {
	if($("#community_homeinfo_page").attr("IsLoad") != "Y"){
		$("#community_homeinfo_page").attr("IsLoad", "Y");
		setTimeout("mobile_community_HomeinfoInit()", 10);
	}
});

//커뮤니티 회원정보
$(document).on('pageinit', '#community_memberjoininfo_page', function () {
	if($("#community_memberjoininfo_page").attr("IsLoad") != "Y"){
		$("#community_memberjoininfo_page").attr("IsLoad", "Y");
		setTimeout("mobile_community_MemberJoinInfoInit()", 10);
	}
});

//커뮤니티 - 페이지별 init 함수 끝








/*!
 * 
 * 커뮤니티 포탈
 * 
 */
var _mobile_community_portal = {
	// 리스트 조회 초기 데이터
	Page: 1,					//조회할 페이지
	PageSize: 3,			//페이지당 건수
	SearchText: '',			//검색어
	SearchType: 'All',		//검색타입
	
	// 페이징을 위한 데이터
	Loading: false,			//데이터 조회 중
	TotalCount: -1,		//전체 건수
	RecentCount: 0,		//현재 보여지는 건수
	EndOfList: false,		//전체 리스트를 다 보여줬는지
	
	//스크롤 위치 고정
	OnBack: false,			//뒤로가기로 왔을 경우
	Scroll: 0					//스크롤 위치		
};

function mobile_community_PortalInit(){	
		
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('folderid') != 'undefined') {
		_mobile_community_portal.FolderID = mobile_comm_getQueryString('folderid');
	} else {
		_mobile_community_portal.FolderID = '0';
	}
	if (mobile_comm_getQueryString('page') != 'undefined') {
		_mobile_community_portal.Page = mobile_comm_getQueryString('page');
	} else {
		_mobile_community_portal.Page = 1;
	}
	_mobile_community_portal.TotalCount = -1;
	_mobile_community_portal.EndOfList = false;

	// 2. 상단메뉴
	mobile_community_makeTreeList('portal');

	// 3. 글 목록 조회
	//내가 가입한 커뮤니티
	mobile_community_makeMyCommunityList(); 
	//가입한 커뮤니티 공지사항
	mobile_community_makePortalNoticeList(); 
}

//내가 가입한 커뮤니티 목록 생성
function mobile_community_makeMyCommunityList(){
	var myCommunity = mobile_community_getMyCommunityList();
	var sHtml = "";

	if(myCommunity != null && myCommunity.length >0){
		sHtml += "<ul>";
		$.each(myCommunity, function(idx, obj){
			sHtml += "<li communityid='" + obj.optionValue + "'>";
			sHtml += "		<a href='javascript: mobile_community_clickCommunity(" + obj.optionValue + ");'>";
			sHtml += "			<span class='thum'><img src='" + mobile_comm_getThumbSrc("Community", obj.FileID) + "' alt='' onerror='mobile_community_imageerror(this);'></span>";
			sHtml += "			<p>" + obj.optionText + "</p>";
			sHtml += "		</a>";
			sHtml += "	</li>";
		});
		sHtml += "</ul>";
	} else {
		sHtml += "<div class=\"no_list\" style=\"padding: 10px !important\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	$("#community_portal_listMyCommunity").html(sHtml);
}

//내가 가입한 커뮤니티 목록 조회
function mobile_community_getMyCommunityList(){
	
	var url = "/groupware/mobile/community/selectUserJoinCommunity.do";
	var myCommunity = null;
	
	$.ajax({
		url: url,
		data:	{},
		type:"POST",
		async: false,
		success: function(response){
			myCommunity = response.list;
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
 		}
	});
	
	return myCommunity;
}

//가입한 커뮤니티 공지사항 목록 생성
function mobile_community_makePortalNoticeList(){
	var myNotice = mobile_community_getNoticeList();
	var sHtml = "";
	var sImg = "";
	var sCreator = "";
	var sFileClip = "";
	var sCls = "";
	var sLink = "";
	
	_mobile_community_portal.TotalCount = myNotice.cnt;
	if(_mobile_community_portal.TotalCount == undefined){
		_mobile_community_portal.TotalCount = 0;
	}

	if(_mobile_community_portal.TotalCount > 0 && myNotice.list.length > 0){
		
		_mobile_community_portal.TotalCount = myNotice.list.length;
		
		$.each(myNotice.list, function(idx, obj){
			
			sImg = "";
			sCls = "";
			sCreator = obj.CreatorName;
			
			if(obj.CreaterLevel != undefined){
				sCreator += ' ';
				sCreator += obj.CreaterLevel.split(';')[0];
			}
			
			if(Number(obj.FileCnt) > 0){
				//파일 존재 유무 표시
				sFileClip = '<span class="ico_file_clip"></span>';
				
				//대표이미지 설정
				if(obj.FileID != undefined && obj.FileID != ""){
					// TODO : EnableVideoExtention 기초 설정 검토 필요
					// 동영상인 경우를 구별하는 부분으로, 기초 설정에서 확장자 목록을 가져옴
					if( obj.FileExtension  != undefined && mobile_comm_getBaseConfig('EnableVideoExtention').indexOf(obj.FileExtension) > -1 ){
						sImg = '<span class="thum video">';
					} else {
						sImg = '<span class="thum">';
					} 	
					sImg += '<img src="' + mobile_comm_getThumbSrc('Board', obj.FileID) + '" alt="" onerror="mobile_comm_imageerror(this);"></span>';
				}
			} else {
				sFileClip = '';
				sCls += "no_thum ";				
			}
			
			if(obj.IsRead == "Y"){
				sCls += "read  ";				
			}
			
			sLink = "/groupware/mobile/board/view.do";
			sLink += "?boardtype=Normal";
			sLink += "&folderid=" + obj.FolderID;
			sLink += "&page=1";
			sLink += "&searchtext=";
			sLink += "&messageid=" + obj.MessageID;
			sLink += "&cuid=" + _mobile_community_home.CU_ID;
			sLink += "&version=" + obj.Version;
			
			sHtml += '	<li class="' + sCls + '">';
			sHtml += 		'<a href="javascript: mobile_comm_go(\'' + sLink + '\')" class="con_link">';
			sHtml += '			<div class="txt_area">';
			sHtml += '				<p class="title"><span class="ico_notice"></span>[' + obj.CommunityName + '] ' + obj.Subject + sFileClip + '</p>';
			sHtml += '				<p class="list_info">';
			/*sHtml += '					<span class="name">' + sCreator + '</span>';*/ //181210 smahn 주석처리
			sHtml += '					<span class="date">' + CFN_TransLocalTime(obj.RegistDate) + '</span>';
			sHtml += '					<span class="ico_hits">' + obj.ReadCnt + '</span>';
			sHtml += '				</p>';
			sHtml += '			</div>';
			sHtml += 			sImg;
			sHtml += '		</a>';
			/*sHtml += '	<a href="#" class="num_comment">';
			sHtml += '			<span><strong>' + obj.CommentCnt + '</strong>' + mobile_comm_getDic("lbl_Comments") + '</span>'; //댓글
			sHtml += '		</a>';*/
			sHtml += '</li>';
			
		});
	} else {
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	//html 적용
	if(_mobile_community_portal.Page == 1 || sHtml.indexOf("no_list") > -1) {
		$("#community_portal_listNotice").html(sHtml);
	} else {
		$("#community_portal_listNotice").append(sHtml);
	}
	
	//더보기
	if (Math.min((_mobile_community_portal.Page) * _mobile_community_portal.PageSize, _mobile_community_portal.TotalCount) == _mobile_community_portal.TotalCount) {
		_mobile_community_portal.EndOfList = true;
        $('#community_portal_btnNoticeMore').hide();
    } else {
        $('#community_portal_btnNoticeMore').show();
    }
	
}

//가입한 커뮤니티 공지사항 목록 조회
function mobile_community_getNoticeList(){
	
	var myNotice = null;
	var url = "/groupware/mobile/community/communityNotice.do";
	var params = {
			page: _mobile_community_portal.Page,
			pageSize: _mobile_community_portal.PageSize,
			bizSection : 'Board'
	}
	$.ajax({
		url: url,
		data:	params,
		type:"POST",
		async: false,
		success: function(response){
			myNotice = response;
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	return myNotice;
}

//트리 목록 조회
function mobile_community_getTreeList(){
	var url = "/groupware/mobile/community/selectCommunityTreeData.do";
	var treeList = null;
	
	$.ajax({
		url: url,
		data:	{},
		type:"POST",
		async: false,
		success: function(response){
			treeList = response.list;
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	return treeList;
}

//트리 목록 생성
function mobile_community_makeTreeList(pPage){
	
	var sHtml = mobile_community_getTopTreeHtml(pPage, mobile_community_getTreeList(), 'FolderType', 'Root', 'MemberOf');
	$("#community_" + pPage + "_treeCategory").html(sHtml).trigger("create");
}

//트리 그리기
function mobile_community_getTopTreeHtml(pPage, pData, pRootNode, pRootValue, pParentNode) {
	
	//pPage - 페이지 종류(list, move 등)
	//pData - 트리 전체 데이터 Array
	//pRootNode - 루트 여부 확인하는 node명
	//pRootValue - pRootNode가 이 값인게 루트
	//pParentNode - 상위 여부 확인하는 node명
		
	var sHtml = "";
	
	//루트를 조회
	var arrRoot = new Array();
	try {
		var len = pData.length;
		for(var i = 0; i < len; i++) {
			if(pData[i][pRootNode] == pRootValue) {
				arrRoot.push(pData[i]);
			}
		}
	} catch(e) {
		arrRoot = null;
	}
			
	var iDepth = 0;
	var sArrow = "";	 //폴더 열기/닫기 화살표
	var sALink = "";	 //폴더 열기/닫기 링크
	var sFLink = ""; 	 //폴더 이동 링크
	var sRadio = ""; 	 //폴더 선택 라디오
	
	sHtml += "<li>";
	sHtml += "		<a id=\"community_\" href=\"javascript: mobile_community_openclose('', '', 'Category');\" class=\"t_link\"><span class=\"t_ico_open\"></span><span class=\"t_ico_doc\"></span>" + mobile_comm_getDic("lbl_CuCategory") + "</a>"; //커뮤니티 분류

	$(arrRoot).each(function (j, root) {

		if(root.childCnt > 0){
			sArrow = "<span class='t_ico_open'></span>";
		} else {
			sArrow = "" ;
		}
		
		sALink = "javascript: mobile_community_openclose('ul_sub_" + root.FolderID + "', 'span_menu_" + root.FolderID + "', '');";
		sFLink = "javascript: mobile_community_changeFolder('" + root.FolderID + "');"; //폴더로 이동 가능
			
		sHtml += "<ul class=\"sub_list\">";
		sHtml += "    <li folderid=\"" + root.FolderID + "\" displayname=\"" + root.DisplayName + "\">";
		sHtml += "        <a href=\"\" class=\"t_link\">";
		sHtml += "				<span onclick=\"" + sALink + "\">";
		sHtml += 					sArrow;
		sHtml += "					<span id=\"span_menu_" + root.FolderID + "\" class=\"t_ico_board\"></span>";
		sHtml += "				</span>";
		sHtml += "				<span onclick=\"" + sFLink + "\">";
		sHtml += 					root.DisplayName;
		sHtml += "				</span>";
		sHtml += "			</a>";
		sHtml += 			mobile_community_getTopTreeHtmlRecursive(pPage, pData, pParentNode, root.FolderID, iDepth + 1);
		sHtml += "    </li>";
		sHtml += "</ul>";
	});
	sHtml += "</li>";
	
	return sHtml;
}

//하위 트리 폴더 그리기
function mobile_community_getTopTreeHtmlRecursive(pPage, pData, pParentNode, pParentValue, pDepth) {
	
	var sHtml = "";
	
	if(pData == null) {
		return sHtml;
	}
	
	var arrSub = new Array();
	try {
		var len = pData.length;
		for(var i = 0; i < len; i++) {
			if(pData[i][pParentNode] == pParentValue) {
				arrSub.push(pData[i]);
			}
		}
	} catch(e) {
		arrSub = null;
	}
	
	var sArrow = "";	 //폴더 열기/닫기 화살표
	var sALink = "";	 //폴더 열기/닫기 링크
	var sFLink = ""; 	 //폴더 이동 링크
	var sRadio = ""; 	 //폴더 선택 라디오
	
	if(arrSub.length > 0){
		
		sHtml += "<ul id=\"ul_sub_" + pParentValue + "\" class=\"sub_list\">";
		$(arrSub).each(function (j, sub) {
			
			if(sub.childCnt > 0){
				sArrow = "<span class='t_ico_open'></span>";
			} else {
				sArrow = "" ;
			}
			
			sALink = "javascript: mobile_community_openclose('ul_sub_" + sub.FolderID + "', 'span_menu_" + sub.FolderID + "', '');";
			sFLink = "javascript: mobile_community_changeFolder('" + sub.FolderID + "');"; //폴더로 이동 가능
			
			sHtml += "    <li folderid=\"" + sub.FolderID + "\" displayname=\"" + sub.DisplayName + "\">";
			sHtml += "        <a href=\"\" class=\"t_link\">";
			sHtml += "				<span onclick=\"" + sALink + "\">";
			sHtml += 					sArrow;
			sHtml += "					<span id=\"span_menu_" + sub.FolderID + "\" class=\"t_ico_board\"></span>";
			sHtml += "				</span>";
			sHtml += "				<span onclick=\"" + sFLink + "\">";
			sHtml += 					sub.DisplayName;
			sHtml += "				</span>";
			sHtml += "			</a>";
			sHtml += 			mobile_community_getTopTreeHtmlRecursive(pPage, pData, pParentNode, sub.FolderID, pDepth + 1);
			sHtml += "    </li>";
		});
		sHtml += "</ul>";
		
	}
	
	return sHtml;
	
}

//더보기 클릭
function mobile_community_noticeNextlist (pMode) {
	if(pMode == "portal"){
		if (!_mobile_community_portal.EndOfList) {
			_mobile_community_portal.Page++;

			mobile_community_makePortalNoticeList();
		} else {
			$('#community_portal_btnNoticeMore').css('display', 'none');
		}
	} else {
		if (!_mobile_community_home.EndOfList) {
			_mobile_community_home.Page++;

			mobile_community_makeNoticeList();
		} else {
			$('#community_home_btnNoticeMore').css('display', 'none');
		}
	}
}

//새로고침 클릭
function mobile_community_clickrefresh(pMode) {
	if(pMode != undefined && pMode == 'list'){
		_mobile_community_list.Page = 1;
		_mobile_community_list.SearchText = '';
		_mobile_community_portal.EndOfList = false;
		$('#mobile_search_input').val('');
		
		mobile_community_makeCommunityList(); 
	} else {
		_mobile_community_portal.Page = 1;
		_mobile_community_portal.SearchText = '';
		_mobile_community_portal.EndOfList = false;
		$('#mobile_search_input').val('');
		
		//내가 가입한 커뮤니티
		mobile_community_makeMyCommunityList(); 
		//가입한 커뮤니티 공지사항
		mobile_community_makePortalNoticeList();
	}
}

//하위 메뉴/트리 열고 닫기
function mobile_community_openclose(liId, iconId, rootName) {
	if(rootName != '' && rootName != undefined){
		var rootObj = $("ul.h_tree_menu_list[id$='" + rootName + "']").find("span:eq(0)");
		if($(rootObj).hasClass('t_ico_open')){
			
			$(rootObj).removeClass('t_ico_open');
			$(rootObj).addClass('t_ico_close');
			
			$(rootObj).parent('a').siblings('ul.sub_list').hide();
		} else {
			
			$(rootObj).removeClass('t_ico_close');
			$(rootObj).addClass('t_ico_open');
			
			$(rootObj).parent('a').siblings('ul.sub_list').show();
		}
	} else {	
		if($('#' + iconId).hasClass('t_ico_open')){
			
			$('#' + iconId).removeClass('t_ico_open');
			$('#' + iconId).addClass('t_ico_close');
			
			$('#' + liId).hide();
		} else {
			
			$('#' + iconId).removeClass('t_ico_close');
			$('#' + iconId).addClass('t_ico_open');
			
			$('#' + liId).show();
		}
	}
}

//확장메뉴 show or hide
function mobile_community_showORhide(obj) {
	if($(obj).parent().hasClass("show")) {
		$(obj).parent().removeClass("show");
	} else {
		$(obj).parent().addClass("show");
	}
}

//커뮤니티 대표이미지 에러처리
function mobile_community_imageerror(pObj) {
    $(pObj).attr("src", mobile_community_noimg());
}

//커뮤니티 대표이미지 기본이미지 
function mobile_community_noimg() {
	return mobile_comm_getGlobalProperties("css.path") + '/mobile/resources/images/noCummImage.png';
}

//커뮤니티 - 포탈 끝









/*!
 * 
 * 커뮤니티 목록
 * 
 */
var _mobile_community_list = {
	// 리스트 조회 초기 데이터
	FolderID: '0',			//폴더ID
	Page: 1,					//조회할 페이지
	PageSize: 10,			//페이지당 건수
	SearchText: '',			//검색어
	SearchType: 'A',		//검색타입
	
	//제휴 커뮤니티
	CU_ID: '',					//제휴 커뮤니티 조회 용도
	
	// 페이징을 위한 데이터
	Loading: false,			//데이터 조회 중
	TotalCount: -1,		//전체 건수
	RecentCount: 0,		//현재 보여지는 건수
	EndOfList: false,		//전체 리스트를 다 보여줬는지
	
	//스크롤 위치 고정
	OnBack: false,			//뒤로가기로 왔을 경우
	Scroll: 0					//스크롤 위치		
};

function mobile_community_ListInit(){	
		
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('folderid') != 'undefined') {
		_mobile_community_list.FolderID = mobile_comm_getQueryString('folderid');
	} else {
		_mobile_community_list.FolderID = '';
	}
	if (mobile_comm_getQueryString('page') != 'undefined') {
		_mobile_community_list.Page = mobile_comm_getQueryString('page');
	} else {
		_mobile_community_list.Page = 1;
	}
	if (mobile_comm_getQueryString('searchtext') != 'undefined') {
		_mobile_community_list.SearchText = decodeURIComponent(mobile_comm_getQueryString('searchtext'));
		$('#community_list_page').find('#mobile_search_input').val(_mobile_community_list.SearchText);
		mobile_comm_opensearch();
    } else {
    	_mobile_community_list.SearchText = '';
    }
	if (mobile_comm_getQueryString('cuid') != 'undefined') {
		_mobile_community_list.CU_ID = decodeURIComponent(mobile_comm_getQueryString('cuid'));
    } else {
    	_mobile_community_list.CU_ID = '';
    }
	_mobile_community_list.TotalCount = -1;
	_mobile_community_list.EndOfList = false;

	// 2. 상단메뉴
	if(_mobile_community_list.CU_ID == ''){
		mobile_community_makeTreeList('list');
	}

	// 3. 글 목록 조회
	mobile_community_makeCommunityList();	
}

//커뮤니티 목록 생성
function mobile_community_makeCommunityList(){
	var communityList = null; //리스트 생성용 커뮤니티
	var myListS = "";		//내가 가입한 커뮤니티 ID
	var sHtml = "";			//html 생성용
	var sDate = "";			//날짜 표시용
	var sRegistBtn = "";	//가입 버튼 표시용
	var sLink = "";			//클릭 이벤트 처리용
	var allianceID = ""; //제휴 커뮤니티 ID
	
	if(_mobile_community_list.CU_ID == ''){ //커뮤니티 목록
		communityList = mobile_community_getCommunityList();	
	} else { //제휴 커뮤니티 목록
		communityList = mobile_community_getAllianceCommunityList();
			
		$.each(communityList.list, function(idx, obj){
			allianceID += obj.CU_ID + ";";
		});
	}

	$.each(mobile_community_getMyCommunityList(), function(idx, obj){
		myListS += obj.optionValue + ";";
	});
	
	if(communityList.list != null && communityList.list.length > 0){
		//총 개수 설정
		_mobile_community_list.TotalCount = communityList.cnt;
		//html 생성
		$.each(communityList.list, function(idx, obj){
			if(myListS.indexOf(obj.CU_ID) > -1 || allianceID.indexOf(obj.CU_ID) > -1){ //가입된 커뮤니티 목록에 있을시, 제휴 커뮤니티 목록 조회 시 링크 생성
				sDate = "<span>" + mobile_comm_getDic("lbl_Join_Day") + ": " + CFN_TransLocalTime(obj.RegProcessDate, "yyyy-MM-dd") + "</span>"; //가입일
				sLink = "onclick=\"javascript: mobile_comm_go('/groupware/mobile/community/home.do?cuid=" + obj.CU_ID + "');\""
				sRegistBtn = "";
			} else if(obj.MemberLevel != null && obj.MemberLevel != undefined && obj.MemberLevel == '0') {
				sDate = "<span>" + mobile_comm_getDic("lbl_Establishment_Day") + ": " + CFN_TransLocalTime(obj.RegProcessDate, "yyyy-MM-dd") + "</span>"; //개설일
				sLink = "";
				sRegistBtn = mobile_comm_getDic("lbl_WaitingCommunity"); //승인 대기 중
			} else {
				sDate = "<span>" + mobile_comm_getDic("lbl_Establishment_Day") + ": " + CFN_TransLocalTime(obj.RegProcessDate, "yyyy-MM-dd") + "</span>"; //개설일
				sLink = "";
				if(_mobile_community_list.CU_ID == '' && (obj.AppStatus == "RV" || obj.AppStatus == "UD" || obj.AppStatus == "RS")){
					sRegistBtn = "	<a href=\"javascript: mogile_community_clickJoin('" + obj.CU_ID + "');\" class=\"g_btn05\">" + mobile_comm_getDic("lbl_community_joinup") + "</a>"; //가입하기
				} else {
					sRegistBtn = "";
				}
			}
			sHtml += "<li " + sLink + " cuid='" + obj.CU_ID + "' cucode='" + obj.CU_Code + "'>";
			sHtml += "		<div class=\"txt_area\">";
			sHtml += "			<p class=\"tit\">" + obj.CommunityName + "</p>";
			sHtml += "			<p class=\"info\">";
			sHtml += "				<span>" + obj.DisplayName + "</span>"; //운영자
			sHtml += 				sDate;
			if(obj.MembersCount != undefined) {
				sHtml += "				<span class=\"member\">" + obj.MembersCount + "</span>";
			} else {
				sHtml += "				<span class=\"member\">" + obj.MemberCount + "</span>";
			}
			sHtml += "			<p class=\"desc\">" + obj.SearchTitle + "</p>";
			sHtml += "		</div>";
			sHtml += "		<div class=\"thum\">";
			sHtml += "			<span class='img'><img src='" + mobile_comm_getThumbSrc("Community", obj.FileID) + "' alt='' onerror='mobile_community_imageerror(this);'></span>";
			sHtml += 			sRegistBtn;
			sHtml += "		</div>";
			sHtml += "	</li>";
		});
	} else {
		
		//총 개수 설정
		_mobile_community_list.TotalCount = 0;
		
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	//html 적용
	if(_mobile_community_list.Page == 1 || sHtml.indexOf("no_list") > -1) {
		$("#community_list_ulList").html(sHtml);
	} else {
		$("#community_list_ulList").append(sHtml);
	}
	
	//더보기
	if (Math.min((_mobile_community_list.Page) * _mobile_community_list.PageSize, _mobile_community_list.TotalCount) == _mobile_community_list.TotalCount) {
		_mobile_community_list.EndOfList = true;
        $('#community_list_btnListMore').hide();
    } else {
        $('#community_list_btnListMore').show();
    }
	
	// 메뉴명 셋팅
	mobile_community_getTopMenuName();
}

//커뮤니티 목록 조회
function mobile_community_getCommunityList(){
	
	var url = "/groupware/mobile/community/selectUserCommunityGridList.do";
	var communityList = null;
	var params = {
		"CategoryID" : _mobile_community_list.FolderID,
		"searchWord" : _mobile_community_list.SearchText,
		"searchType" : _mobile_community_list.SearchType,
		"pageNo" : _mobile_community_list.Page,
		"pageSize" : _mobile_community_list.PageSize
	};
	
	$.ajax({
		url: url,
		data:	params,
		type:"POST",
		async: false,
		success: function(response){
			communityList = response;
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	return communityList;
}

//제휴 커뮤니티 목록 조회
function mobile_community_getAllianceCommunityList(){
	
	var url = "/groupware/mobile/community/selectCommunityAllianceGridList.do";
	var communityList = null;
	var params = {
			"pageNo" : _mobile_community_list.Page,
			"pageSize" : _mobile_community_list.PageSize,
			"CU_ID" : _mobile_community_list.CU_ID,
			"Status" : 'A',	//승인된 제휴 목록만 조회
			"DN_ID" : mobile_comm_getSession("DN_ID")
	};
	
	$.ajax({
		url: url,
		data:	params,
		type:"POST",
		async: false,
		success: function(response){
			communityList = response;
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	return communityList;
}

//상단 메뉴명 셋팅
function mobile_community_getTopMenuName() {
	
	var sTopMenu = "";
	if(_mobile_community_list.CU_ID != '') {
		sTopMenu = mobile_comm_getDic("lbl_AffiliateCommunity"); //제휴 커뮤니티
		$("a.topH_search").hide();
		$("#aBtnBack").show();
		$("#aTopMenu").hide();
	} else	if (_mobile_community_list.FolderID == ''){
		sTopMenu = mobile_comm_getDic("lbl_Community"); //커뮤니티
	} else {
		sTopMenu = $('#community_list_topmenu').find("li[displayname]:eq(0)").text();
	}
	
	$('#community_list_topmenu').find("li[displayname]").each(function (){
		if($(this).attr('folderid') == _mobile_community_list.FolderID) {
			sTopMenu = $(this).attr('displayname');
			return false;
		}
	});
	
	$('#community_list_title').html(sTopMenu);
}


//폴더 트리 클릭
function mobile_community_changeFolder(pFolderID) {
	
	//현 위치가 리스트일 경우 
	if(location.href.indexOf("list") > -1){
		_mobile_community_list.FolderID = pFolderID;
		
		_mobile_community_list.Page = 1;
		_mobile_community_list.SearchText = '';
		$('#mobile_search_input').val('');
		
		mobile_community_makeCommunityList();		
		mobile_comm_TopMenuClick('community_list_topmenu',true);
		$('.cont_wrap').css("position", "");
		$("div.bg_dim").hide();
	} else {
		var sUrl = "/groupware/mobile/community/list.do";
		sUrl += "?folderid=" + pFolderID;
			
		mobile_comm_go(sUrl);
	}
	
}

//TODO : 소개, 키워드 검색 안됨
//검색 클릭
function mobile_community_clicksearch() {
	//현 위치가 리스트일 경우 
	if(location.href.indexOf("list") > -1){
		_mobile_community_list.SearchText = $('#mobile_search_input').val();
		
		_mobile_community_list.Page = 1;
		_mobile_community_list.EndOfList = false;
		
		mobile_community_makeCommunityList();
	} else {
		var sUrl = "/groupware/mobile/community/list.do";
		sUrl += "?searchtext=" + encodeURIComponent($("#mobile_search_input").val());
			
		mobile_comm_go(sUrl);
	}	
}

//가입하기 클릭
function mogile_community_clickJoin(pCUID){
	var sUrl = "/groupware/mobile/community/apply.do";
	sUrl += "?cuid=" + pCUID;
		
	mobile_comm_go(sUrl);
}

//커뮤니티 클릭
function mobile_community_clickCommunity(pCUID){
	var sUrl = "/groupware/mobile/community/home.do";
	sUrl += "?cuid=" + pCUID;
		
	mobile_comm_go(sUrl);
}

//다음 커뮤니티 리스트 정보 조회
function mobile_community_listNextlist(){
	if (!_mobile_community_list.EndOfList) {
		_mobile_community_list.Page++;

		mobile_community_makeCommunityList();
	} else {
		$('#community_list_btnListMore').css('display', 'none');
	}
}

//스크롤 더보기
function mobile_community_list_page_ListAddMore(){
	mobile_community_listNextlist();
}

//커뮤니티 - 목록 끝

















/*!
 * 
 * 커뮤니티 홈
 * 
 */
var _mobile_community_home = {
	// 리스트 조회 초기 데이터
	CU_ID: '0',				//커뮤니티ID
	FolderID: '0',			//폴더ID
	Page: 1,					//조회할 페이지
	PageSize: 10,			//페이지당 건수
	SearchText: '',			//검색어
	SearchType: 'A',		//검색타입
	SchFolderID: '',		//일정 폴더 ID
	IsAdmin: 'N', 			//운영자 여부
	
	// 페이징을 위한 데이터
	Loading: false,			//데이터 조회 중
	TotalCount: -1,		//전체 건수
	RecentCount: 0,		//현재 보여지는 건수
	EndOfList: false,		//전체 리스트를 다 보여줬는지
	
	//스크롤 위치 고정
	OnBack: false,			//뒤로가기로 왔을 경우
	Scroll: 0					//스크롤 위치		
};

function mobile_community_HomeInit(){	
		
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('cuid') != 'undefined') {
		_mobile_community_home.CU_ID = mobile_comm_getQueryString('cuid');
	} else {
		_mobile_community_home.CU_ID = '0';
	}
	if (mobile_comm_getQueryString('page') != 'undefined') {
		_mobile_community_home.Page = mobile_comm_getQueryString('page');
	} else {
		_mobile_community_home.Page = 1;
	}
	/*if (mobile_comm_getQueryString('searchtext') != 'undefined') {
		_mobile_community_home.SearchText = decodeURIComponent(mobile_comm_getQueryString('searchtext'));
    } else {
    	_mobile_community_home.SearchText = '';
    }
	_mobile_community_home.TotalCount = -1;
	_mobile_community_home.EndOfhome = false;
	 */
	
	// 2. 상단메뉴
	$("#community_home_topmenu").html(mobile_community_makeHomeTreeList(_mobile_community_home));
	mobile_community_makeHomeRightMenu(_mobile_community_home);
	
	// 3. 헤더 영역
	mobile_community_makeHeader();
	
	// 4. 내가 가입한 커뮤니티
	mobile_community_makeMyCommunitySelect(_mobile_community_home);

	// 5. 글 목록 조회
	mobile_community_makeNoticeList();	
}

//홈 전용 좌측 트리 메뉴 구성
function mobile_community_makeHomeTreeList(pParams){
	var sHtml = "";
	var url = "/groupware/mobile/community/communityLeft.do";
	var params = {
			CU_ID : pParams.CU_ID
	};
	
	$.ajax({
		url: url,
		type:"POST",
		async:false,
		data: params,
		success:function (response) {
			if (typeof response.communityName == 'string' && response.communityName != ''){
				$("header .LsubTitle").text(response.communityName);	// 커뮤니티 이름 좌측메뉴에 셋팅
			}
			
			var sALink = "";
			
			if(response.memberLevel != null &&  response.memberLevel !="" &&  response.memberLevel == "9"){
				pParams.IsAdmin = "Y";
			} else {
				pParams.IsAdmin = "N";
			}
			sHtml +="<ul class=\"h_tree_menu_wrap comm_menu\">";
			sHtml += "<li>";
			sHtml += "		<div class='h_tree_menu'>";
			sHtml += "			<ul id='community_home_treeCategory' class='h_tree_menu_list'>";
			sHtml += "				<li>";
			sHtml += "					<a href=\"javascript: mobile_comm_go('/groupware/mobile/community/home.do?cuid=" + params.CU_ID + "');\" class='t_link'><span class='t_com_home'></span>" + mobile_comm_getDic("lbl_community_home") + "</a>"; //커뮤니티 홈
			sHtml += "				</li>";
			//회원정보
			sHtml += "				<li id='community_home_memberList'>";
			sHtml += "					<a href='javascript: mobile_community_clickMemberJoinInfo(" + params.CU_ID + ");' class='t_link'><span class='t_com_myinfo'></span>" + mobile_comm_getDic("lbl_User_Info") + "</a>"; //회원정보
			sHtml += "				</li>";
			//게시
			if(response.flag || 
					(response.memberLevel != null &&  response.memberLevel !="" &&  response.memberLevel !="0")){
				if(response.list.length > 0){
					sHtml += 					mobile_community_getTopBoardTreeHtml(response.list, 'itemType', 'Root', 'pno', 'no');		
				}
			}
			//나의 메뉴
			if(response.flag || 
					(response.memberLevel != null &&  response.memberLevel !="" &&  response.memberLevel !="0")){
				sALink = "javascript: mobile_community_openclose('ul_my_menu', 'span_my_menu');";
				
				sHtml += "				<li>";
				sHtml += "					<a href=\"" + sALink + "\" class='t_link'><span id=\"span_my_menu\" class=\"t_ico_open\"></span><span class='t_com_board'></span>" + mobile_comm_getDic("lbl_MyMenu") + "</a>"; 
				sHtml += "					<ul id='ul_my_menu' class='sub_list'>";
				sHtml += "						<li boardtype='MyOwnWrite' displayname='" + mobile_comm_getDic("lbl_MyWriteMsg") + "'>"; //내가 작성한 게시
				sHtml += "							<a href=\"javascript: mobile_board_Change('MyOwnWrite',"+params.CU_ID+");\" class='t_link'><span class='t_ico_board'></span>" + mobile_comm_getDic("lbl_MyWriteMsg") + "</a>"; 
				sHtml += "						</li>";
				sHtml += "						<li boardtype='OnWriting' displayname='" + mobile_comm_getDic("lbl_OnWritingBoard") + "'>"; //작성중인 게시
				sHtml += "							<a href=\"javascript: mobile_board_Change('OnWriting',"+params.CU_ID+");\" class='t_link'><span class='t_ico_board'></span>" + mobile_comm_getDic("lbl_OnWritingBoard") + "</a>"; 
				sHtml += "						</li>";
				sHtml += "						<li boardtype='MyBooking' displayname='" + mobile_comm_getDic("lbl_MyBookingList") + "'>"; //예약 게시
				sHtml += "							<a href=\"javascript: mobile_board_Change('MyBooking',"+params.CU_ID+");\" class='t_link'><span class='t_ico_board'></span>" + mobile_comm_getDic("lbl_MyBookingList") + "</a>"; 
				sHtml += "						</li>";
				sHtml += "						<li boardtype='Scrap' displayname='" + mobile_comm_getDic("lbl_ScrapBoard") + "'>"; //스크랩
				sHtml += "							<a href=\"javascript: mobile_board_Change('Scrap',"+params.CU_ID+");\" class='t_link'><span class='t_ico_board'></span>" + mobile_comm_getDic("lbl_ScrapBoard") + "</a>"; 
				sHtml += "						</li>";
				sHtml += "					</ul>";
				sHtml += "				</li>";
			}
			//설문
			if(response.flag || 
					(response.memberLevel != null &&  response.memberLevel !="" &&  response.memberLevel !="0")){
				sALink = "javascript: mobile_community_openclose('ul_sub_survey', 'span_menu_survey');";
				
				sHtml += "				<li>";
				sHtml += "					<a href=\"" + sALink + "\" class='t_link'><span id=\"span_menu_survey\" class=\"t_ico_open\"></span><span class='t_com_survey'></span>" + mobile_comm_getDic("lbl_Profile_Questions") + "</a>"; //설문
				sHtml += "					<ul id='ul_sub_survey' class='sub_list'>";
				sHtml += "						<li surveytype='proceed' displayname='" + mobile_comm_getDic("lbl_title_surveyName_02") + "'>"; //진행중인 설문
				sHtml += "							<a href=\"javascript: mobile_comm_go('/groupware/mobile/survey/list.do?cuid=" + params.CU_ID + "');\" class='t_link'><span class='t_ico_board'></span>" + mobile_comm_getDic("lbl_title_surveyName_02") + "</a>"; //진행중인 설문
				sHtml += "						</li>";
				sHtml += "						<li surveytype='complete' displayname='" + mobile_comm_getDic("lbl_title_surveyName_03") + "'>"; //완료된 설문
				sHtml += "							<a href=\"javascript: mobile_comm_go('/groupware/mobile/survey/list.do?cuid=" + params.CU_ID + "&surveytype=complete');\" class='t_link'><span class='t_ico_board'></span>" + mobile_comm_getDic("lbl_title_surveyName_03") + "</a>"; //완료된 설문
				sHtml += "						</li>";
				sHtml += "					</ul>";
				sHtml += "				</li>";
			}
			//일정
			if(response.headerList != undefined && response.headerList.length > 0){
				var schFolderID = "";
				//데이터 중 Schedule 폴더가 존재하는지 확인
				$(response.headerList).each(function(i,obj){
					if(obj.FolderType == "Schedule"){
						schFolderID = obj.FolderID;
						return false;
					}
				});
				//Schedule 폴더가 존재하면
				if(schFolderID != ""){
					sALink = "javascript: mobile_community_openclose('ul_sub_schedule', 'span_menu_schedule');";
					
					sHtml += "		<li>";
					sHtml += "			<a href=\"" + sALink + "\" class='t_link'><span id=\"span_menu_schedule\" class=\"t_ico_open\"></span><span class='t_com_schedule'></span>" + mobile_comm_getDic("lbl_Schedule") + "</a>"; //일정
					sHtml += "			<ul id='ul_sub_schedule' class='sub_list'>";
					sHtml += "				<li viewtype='D'>";
					sHtml += "					<a href=\"javascript: mobile_comm_go('/groupware/mobile/schedule/day.do?viewtype=D&cuid=" + params.CU_ID + "&schfd=" + schFolderID + "');\" class='t_link'><span class='t_ico_board'></span>" + mobile_comm_getDic("lbl_Daily") + "</a>"; //일간
					sHtml += "				</li>";
					sHtml += "				<li viewtype='W'>";
					sHtml += "					<a href=\"javascript: mobile_comm_go('/groupware/mobile/schedule/week.do?viewtype=W&cuid=" + params.CU_ID + "&schfd=" + schFolderID + "');\" class='t_link'><span class='t_ico_board'></span>" + mobile_comm_getDic("lbl_Weekly") + "</a>"; //주간
					sHtml += "				</li>";
					sHtml += "				<li viewtype='M'>";
					sHtml += "					<a href=\"javascript: mobile_comm_go('/groupware/mobile/schedule/month.do?viewtype=M&cuid=" + params.CU_ID + "&schfd=" + schFolderID + "');\" class='t_link'><span class='t_ico_board'></span>" + mobile_comm_getDic("lbl_Monthly") + "</a>"; //월간
					sHtml += "				</li>";
					sHtml += "				<li viewtype='L'>";
					sHtml += "					<a href=\"javascript: mobile_comm_go('/groupware/mobile/schedule/list.do?viewtype=L&cuid=" + params.CU_ID + "&schfd=" + schFolderID + "');\" class='t_link'><span class='t_ico_board'></span>" + mobile_comm_getDic("btn_List") + "</a>"; //목록
					sHtml += "				</li>";
					sHtml += "			</ul>";
					sHtml += "		</li>";
				}
			}
			/*//운영메뉴
			if(response.memberLevel == "9" || 
					(response.memberLevel != null &&  response.memberLevel !="" &&  response.memberLevel !="0")){
				sHtml += "			<li id='community_home_adminMenu'>";
				sHtml += "				<a href='#' class='t_link'><span class='t_com_manage'></span>운영메뉴</a>";
				sHtml += "				<ul class='sub_list'>";
				sHtml += "					<li>";
				sHtml += "						<a href='#' class='t_link'><span class='t_com_manage01'></span>회원관리</a>";
				sHtml += "					</li>";
				sHtml += "					<li>";
				sHtml += "						<a href='#' class='t_link'><span class='t_com_manage02'></span>정보관리</a>";
				sHtml += "					</li>";
				sHtml += "					<li>";
				sHtml += "						<a href='#' class='t_link'><span class='t_com_manage03'></span>제휴관리</a>";
				sHtml += "					</li>";
				sHtml += "					<li>";
				sHtml += "						<a href='#' class='t_link'><span class='t_com_manage04'></span>폐쇄신청</a>";
				sHtml += "					</li>";
				sHtml += "				</ul>";
				sHtml += "			</li>";
			}*/
			
			sHtml += "			</ul>";
			sHtml += "		</div>";
			sHtml += "</li>";
			sHtml += "</ul>";
			
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);  
		}
	}); 
	
	
	return sHtml;
}

//트리 그리기
function mobile_community_getTopBoardTreeHtml(pData, pRootNode, pRootValue, pParentNode, pParentValue) {
	
	//pData - 트리 전체 데이터 Array
	//pRootNode - 루트 여부 확인하는 node명
	//pRootValue - pRootNode가 이 값인게 루트
	//pParentNode - 상위 여부 확인하는 node명
	//pParentValue - pParentNode가 이 값임을 확인하여 sub 노드를 조회
	
	//루트를 조회
	var arrRoot = new Array();
	try {
		var len = pData.length;
		for(var i = 0; i < len; i++) {
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
	
	$(arrRoot).each(function (j, root) {

		sALink = "javascript: mobile_community_openclose('ul_sub_" + root.no + "', 'span_menu_" + root.no + "');";
		
		sHtml += "		<li>";
		sHtml += "        <a href=\"" + sALink + "\" class=\"t_link\"><span id=\"span_menu_" + root.no + "\" class=\"t_ico_open\"></span><span id=\"span_menu_" + root.no + "\" class=\"t_com_board\"></span>" + mobile_comm_getDic("lbl_Boards") + "</a>"; //게시판
		sHtml += 			mobile_community_getTopBoardTreeHtmlRecursive(pData, pParentNode, root.no, iDepth + 1);
		sHtml += "		</li>";
	});
	
	return sHtml;
}

function mobile_community_getTopBoardTreeHtmlRecursive(pData, pParentNode, pParentValue, pDepth) {
	
	var sHtml = "";
	
	if(pData == null) {
		return sHtml;
	}
	
	var arrSub = new Array();
	try {
		var len = pData.length;
		for(var i = 0; i < len; i++) {
			if(pData[i][pParentNode] == pParentValue) {
				arrSub.push(pData[i]);
			}
		}
	} catch(e) {
		arrSub = null;
	}
	
	var sClass = "t_ico_board";
	var sALink = "";
	
	if($(arrSub).length>0){
		sHtml += "<ul id=\"ul_sub_" + pParentValue + "\" class=\"sub_list\">";
		$(arrSub).each(function (j, sub) {
			
			// TODO : 모바일에서 지원안하는 게시 타입을 기초 설정으로 관리 필요(일정형 게시, 한줄 게시 지원 안함) 
			if(sub.FolderType == "Calendar" || sub.FolderType == "QuickComment")
				return sub.FolderType;
			
			sClass = "t_ico_board";
			sALink = "javascript: mobile_community_gotoBoard('" + sub.FolderID + "', '" + sub.FolderType + "', '" + sub.MenuID + "');";
			
			if(sub.FolderType.toUpperCase() == "FOLDER") {
				sClass = "t_ico_open";
				sALink = "javascript: mobile_community_openclose('ul_sub_" + sub.no + "', 'span_menu_" + sub.no + "');";
			}
			
			sHtml += "    <li folderid=\"" + sub.FolderID + "\" displayname=\"" + sub.DisplayName + "\">";
			sHtml += "        <a href=\"" + sALink + "\" class=\"t_link\"><span id=\"span_menu_" + sub.no + "\" class=\"" + sClass + "\"></span>" + sub.DisplayName + "</a>";
			sHtml += 			mobile_community_getTopBoardTreeHtmlRecursive(pData, pParentNode, sub.no, pDepth + 1);
			sHtml += "    </li>";
		});
		sHtml += "</ul>";
	}
	
	return sHtml;
	
}

function mobile_community_gotoBoard(pFolderID, pFolderType, pMenuID){
	
	var sUrl = "/groupware/mobile/board/list.do";
	
	if(location.href.indexOf(sUrl) > -1){
		mobile_board_ChangeFolder(pFolderID, pFolderType);
	} else {
		sUrl += "?menucode=BoardMain";
		sUrl += "&cuid=" + _mobile_community_home.CU_ID;
		sUrl += "&iscommunity=Y";
		sUrl += "&menuid=" + pMenuID;
		sUrl += "&boardtype=Normal";
		sUrl += "&folderid=" + pFolderID;
		sUrl += "&foldertype=" + pFolderType;

		mobile_comm_go(sUrl);
	}	

}

// 헤더 영역(이미지, 명칭, 개설일, 회원)
function mobile_community_makeHeader(){
	
	var sHtml = "";
	var url = "/groupware/mobile/community/communityHeaderSetting.do";
	var params = {
			communityID : _mobile_community_home.CU_ID
	};
	
	$.ajax({
		url: url,
		type:"POST",
		async:false,
		data: params,
		success:function (response) {
			
			if(response.headlist.length > 0 && response.sublist.length > 0){
				
				var sImg = "";
				var sFileID = "";
				var sCommunityName = "";
				$(response.headlist).each(function(i, obj){
					if(obj.FilePath != '' && obj.FilePath != null && obj.FileCheck == "true"){
						sImg = obj.FilePath;
						sFileID = obj.FileID;
					} else {
						sFileID = mobile_community_nobanner();
					}
					sCommunityName = obj.CommunityName;
				});
				
				var thum_title = mobile_comm_getThumbSrc("Community", sFileID);
				var sRegProcessDate = response.sublist[0].RegProcessDate;
				var sMemberCnt = response.sublist[0].MemberCNT;
				
				sHtml += "		<div class=\"txt_area\">";
				sHtml += "			<p class=\"name\">" + sCommunityName + "</p>";
				sHtml += "			<p class=\"opening\">";
				sHtml += 				mobile_comm_getDic("lbl_Establishment_Day") + " : " + CFN_TransLocalTime(sRegProcessDate, "yyyy-MM-dd"); //개설일
				sHtml += "				<span>" + mobile_comm_getDic("CuMemberStatus_R") + " : " + sMemberCnt + mobile_comm_getDic("lbl_CountMan") + "</span>"; //회원,  명
				sHtml += "			</p>";
				sHtml += "		</div>";
				
				$("div.community_img").attr("style", "background-image: url('" + thum_title + "'), url('" + mobile_community_nobanner() + "')");
				$("div.community_img").attr("onclick", "javascript: mobile_community_clickHomeInfo(" + _mobile_community_home.CU_ID + ");");
				$("div.community_img").html(sHtml);
				
				$("#community_home_title").html(sCommunityName + "<i class=\"arr_menu\"></i>");
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);  
		}
	}); 
}

//커뮤니티 배너 기본이미지 
function mobile_community_nobanner() {
	return mobile_comm_getGlobalProperties("css.path") + '/mobile/resources/images/noCummBanner.jpg';
}

//내가 가입한 커뮤니티 Select 생성
function mobile_community_makeMyCommunitySelect(params){
	var myCommunity = mobile_community_getMyCommunityList();
	var sHtml = "";
	var sImg = "";

	if(myCommunity != null){
		$.each(myCommunity, function(idx, obj){
			sHtml += "<option value='" + obj.optionValue + "'>";
			sHtml +=		obj.optionText;
			sHtml += "	</option>";
		});
	}
	
	$("#community_home_myCommunitySel").html(sHtml);
	$("#community_home_myCommunitySel").val(params.CU_ID);
}

//공지사항 리스트 생성
function mobile_community_makeNoticeList(){
	
	var sHtml = "";
	var sCreator = "";
	var sCls = "";
	var sLink = "";
	var sImg = "";
	var sFileClip = "";
	
	var url = "/groupware/mobile/community/communitySelectNotice.do";
	var params = 	{
				CU_ID : _mobile_community_home.CU_ID,
				pageNo : _mobile_community_home.Page,
				pageSize : _mobile_community_home.PageSize,
				bizSection : 'Board',
				FolderType : 'Notice'
			};
	
	$.ajax({
		url: url,
		type:"POST",
		async:true,
		data: params,
		success:function (n) {
			
			_mobile_community_home.TotalCount = n.cnt;
			
			if(n.list.length > 0){
				$(n.list).each(function(i,obj){
					
					sCls = "";
					sImg = "";
					sFileClip = "";
					sCreator = obj.CreatorName;
					
					if(obj.CreaterLevel != undefined){
						sCreator += ' ';
						sCreator += obj.CreaterLevel.split(';')[0];
					}
					
					if(Number(obj.FileCnt) > 0){
						//파일 존재 유무 표시
						sFileClip = '<span class="ico_file_clip"></span>';
						
						//대표이미지 설정
						if(obj.FileID != undefined && obj.FileID != ""){
							// TODO : EnableVideoExtention 기초 설정 검토 필요
							// 동영상인 경우를 구별하는 부분으로, 기초 설정에서 확장자 목록을 가져옴
							if( obj.FileExtension  != undefined && mobile_comm_getBaseConfig('EnableVideoExtention').indexOf(obj.FileExtension) > -1 ){
								sImg = '<span class="thum video">';
							} else {
								sImg = '<span class="thum">';
							} 	
							sImg += '<img src="' + mobile_comm_getThumbSrc('Board', obj.FileID) + '" alt="" onerror="mobile_comm_imageerror(this);"></span>';
						}
					} else {
						sFileClip = '';
						sCls += "no_thum ";				
					}
					
					if(obj.IsRead == "Y"){
						sCls += "read  ";				
					}
					
					sLink = "/groupware/mobile/board/view.do";
					sLink += "?boardtype=Normal";
					sLink += "&folderid=" + obj.FolderID;
					sLink += "&page=1";
					sLink += "&searchtext=";
					sLink += "&messageid=" + obj.MessageID;
					sLink += "&cuid=" + _mobile_community_home.CU_ID;
					sLink += "&version=" + obj.Version;
					
					sHtml += '	<li class="' + sCls + '">';
					sHtml += 		'<a href="javascript: mobile_comm_go(\'' + sLink + '\')" class="con_link">';
					sHtml += '			<div class="txt_area">';
					sHtml += '				<p class="title"><span class="ico_notice"></span>' + obj.Subject + sFileClip + '</p>';
					sHtml += '				<p class="list_info">';
					sHtml += '					<span class="name">' + sCreator + '</span>';
					sHtml += '					<span class="date">' + CFN_TransLocalTime(obj.RegistDate) + '</span>';
					sHtml += '					<span class="ico_hits">' + obj.ReadCnt + '</span>';
					sHtml += '				</p>';
					sHtml += '			</div>';
					sHtml += 			sImg;
					sHtml += '		</a>';
					/*sHtml += '	<a href="#" class="num_comment">';
					sHtml += '			<span><strong>' + obj.CommentCnt + '</strong>' + mobile_comm_getDic("lbl_Comments") + '</span>'; //댓글
					sHtml += '		</a>';*/
					sHtml += '</li>';
					
				});
			} else {
				sHtml += "<div class=\"no_list\">";
				sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
				sHtml += "</div>";
			}
			
			//html 적용
			if(_mobile_community_home.Page == 1 || sHtml.indexOf("no_list") > -1) {
				$("#community_home_listNotice").html(sHtml);
			} else {
				$("#community_home_listNotice").append(sHtml);
			}
			
			//더보기
			if (Math.min((_mobile_community_home.Page) * _mobile_community_home.PageSize, _mobile_community_home.TotalCount) == _mobile_community_home.TotalCount) {
				_mobile_community_home.EndOfList = true;
		        $('#community_home_btnNoticeMore').hide();
		    } else {
		        $('#community_home_btnNoticeMore').show();
		    }
			
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error); 
		}
	}); 	
}

//내가 가입한 커뮤니티 select 변경
function mobile_community_clickCommunitySel(){
	//mobile_community_clickCommunity($("#community_home_myCommunitySel").val());
	
	// 1. 변수 셋팅
	_mobile_community_home.CU_ID = $("#community_home_myCommunitySel").val()
	_mobile_community_home.Page = 1;
	
	// 2. 상단메뉴
	$("#community_home_topmenu").html(mobile_community_makeHomeTreeList(_mobile_community_home));
	mobile_community_makeHomeRightMenu(_mobile_community_home);
	
	// 3. 헤더 영역
	mobile_community_makeHeader();
	
	// 4. 내가 가입한 커뮤니티
	mobile_community_makeMyCommunitySelect(_mobile_community_home);

	// 5. 글 목록 조회
	mobile_community_makeNoticeList();
}

//탈퇴하기 클릭
function mobile_community_clickWithdrawal(pCUID){
	var sUrl = "/groupware/mobile/community/withdrawal.do";
	sUrl += "?cuid=" + pCUID;
		
	mobile_comm_go(sUrl);
}

//제휴 커뮤니티 클릭
function mobile_community_clickAllianceList(pCUID){
	var sUrl = "/groupware/mobile/community/list.do";
	sUrl += "?cuid=" + pCUID;
		
	mobile_comm_go(sUrl);
}

//홈 정보 클릭
function mobile_community_clickHomeInfo(pCUID){
	var sUrl = "/groupware/mobile/community/homeinfo.do";
	sUrl += "?cuid=" + pCUID;
		
	mobile_comm_go(sUrl);
}

//회원정보 정보 클릭
function mobile_community_clickMemberJoinInfo(pCUID){
	var sUrl = "/groupware/mobile/community/memberjoininfo.do";
	sUrl += "?cuid=" + pCUID;
		
	mobile_comm_go(sUrl);
}

//홈 우측 옵션 메뉴 만들기
function mobile_community_makeHomeRightMenu(params){
	var sHtml = "";
	//sHtml += "<li><a href=\"#\" class=\"btn\">초대</a></li>";
	sHtml += "<li><a href=\"javascript: mobile_community_clickAllianceList(" + params.CU_ID + ");\" class=\"btn\">" + mobile_comm_getDic("lbl_AffiliateCommunity") + "</a></li>"; //제휴 커뮤니티
	//sHtml += "<li><a href=\"#\" class=\"btn\">최근 다녀간 회원</a></li>";
	if(params.IsAdmin != null && params.IsAdmin != undefined && params.IsAdmin == 'N') {
		sHtml += "<li><a href=\"javascript: mobile_community_clickWithdrawal(" + params.CU_ID + ");\" class=\"btn\">" + mobile_comm_getDic("lbl_CommunityWithdrawal") + "</a></li>"; //커뮤니티 탈퇴
	}
	
	$("ul.exmenu_list").html(sHtml);
	
}

//커뮤니티 - 홈 끝












/*!
 * 
 * 커뮤니티 가입신청
 * 
 */
var _mobile_community_apply = {
	CU_ID: '',			//커뮤니티 ID
	CType: ''			//가입 옵션
};

function mobile_community_ApplyInit(){	
		
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('cuid') != 'undefined') {
		_mobile_community_apply.CU_ID = mobile_comm_getQueryString('cuid');
	} else {
		_mobile_community_apply.CU_ID = '';
	}

	// 2. 사용자 정보
	mobile_community_setJoinInfo();
	
}

//사용자 정보 조회
function mobile_community_setJoinInfo(){
	
	var url = "/groupware/mobile/community/communityJoinInfo.do";
	var params = {
			CU_ID : _mobile_community_apply.CU_ID
	};
	
	$.ajax({
		url: url,
		data:	params,
		type:"POST",
		async: false,
		success: function(response){
			
			//사용자 정보
			if(response.userInfo.length > 0){
				$(response.userInfo).each(function(i,obj){
					$("#community_apply_userName").html(obj.DisplayName);
					$("#community_apply_userMail").html(obj.MailAddress != null && obj.MailAddress != ""  ? obj.MailAddress : "&nbsp;" );
					_mobile_community_apply.CType = obj.JoinOption;
				});
			}else{
				mobile_comm_back();
			}
			//커뮤니티 정보
			if(response.communityInfo.length > 0){
				var obj = response.communityInfo[0];
				$("#community_apply_cuName").text(obj.CommunityName)
				if (typeof obj.ProvisionEditor == 'string' && obj.ProvisionEditor != ''){
					$("#community_apply_provision").html( obj.ProvisionEditor.replace(/(\r\n|\n|\n\n)/gi, '<br />'));
					$("#div_community_terms").show();
				} else {
					$("#div_community_terms").hide();
				}
			}else{
				mobile_comm_back();
			}
			
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
}

//커뮤니티 가입
function mobile_community_joinCommunity(){
	
	//약관 동의에 체크하지 않았을 경우
	if($("#div_community_terms").css("display") == 'block' && $("#community_apply_userAgree").siblings('label').hasClass("ui-checkbox-off") == true){
		alert(mobile_comm_getDic("msg_community_userAgree")); //약관에 동의하셔야 회원가입 신청이 완료됩니다.
		return false;
	}
	
	var url = "/groupware/mobile/community/communityUserJoin.do";
	var strRegMessage = $("#community_apply_userRegMsg").val().split(" ").join("&nbsp;").replace(/(\r\n|\n|\n\n)/gi, "<br />");
	var params = {
			CU_ID : _mobile_community_apply.CU_ID,
			RegMessage : strRegMessage,
			MailAddress : $("#community_apply_userMail").text(),
			NickName : $("#community_apply_userName").text(),
			JoinOption : _mobile_community_apply.CType
	};
	
	$.ajax({
		url: url,
		type:"post",
		data: params,
		success:function (data) {
			if(data.status == "SUCCESS"){
				alert(mobile_comm_getDic("msg_CommunityJoinMsg_05")); //회원가입 신청이 완료되었습니다.
				mobile_comm_back();
			}else{ 
				alert(mobile_comm_getDic("msg_CommunityJoinMsg_07")); //회원가입 신청에 실패하였습니다.
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error); 
		}
	}); 
}

//커뮤니티 - 가입신청 끝











/*!
 * 
 * 커뮤니티 탈퇴신청
 * 
 */
var _mobile_community_withdrawal = {
	CU_ID: '',			//커뮤니티 ID
	CType: ''			//가입 옵션
};

function mobile_community_WithdrawalInit(){	
		
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('cuid') != 'undefined') {
		_mobile_community_withdrawal.CU_ID = mobile_comm_getQueryString('cuid');
	} else {
		_mobile_community_withdrawal.CU_ID = '';
	}

	// 2. 탈퇴 정보
	mobile_community_setWithdrawalInfo();
	
}

//탈퇴 정보 조회
function mobile_community_setWithdrawalInfo(){
	
	var url = "/groupware/mobile/community/selectCommunityLeaveInfo.do";
	var params = {
			CU_ID : _mobile_community_withdrawal.CU_ID
	};
	
	$.ajax({
		url: url,
		data:	params,
		type:"POST",
		async: false,
		success: function(response){
			//사용자 정보
			if(response.list.length > 0){
				$(response.list).each(function(i,obj){
					$("#community_withdrawal_cuName").text(obj.CommunityName);
					$("#community_withdrawal_userName").text(obj.DisplayName);
					$("#community_withdrawal_userRegistDate").text(CFN_TransLocalTime(obj.RegProcessDate, "yyyy-MM-dd"));
					if(obj.CuMemberLevel != undefined){
						$("#community_withdrawal_userLevel").text(obj.CuMemberLevel);
					} else {
						$("#community_withdrawal_userLevel").parents("dl").hide();						
					}
					$("#community_withdrawal_userWithdrawDate").text(obj.now_date);
					$("#community_withdrawal_userMail").text(obj.MailAddress);
					$("#community_withdrawal_cuName").text(obj.CommunityName);
				});
			}else{
				mobile_comm_back();
			}
			
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
}

//탈퇴하기
function mobile_community_withdrawCommunity(){
	var url = "/groupware/mobile/community/communityMemberLeave.do";
	var params = {
			CU_ID : _mobile_community_withdrawal.CU_ID,
			LeaveMessage : $("#community_withdrawal_userReason").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />')
	};
	
	$.ajax({
		url: url,
		type:"post",
		data: params,
		success:function (data) {
			if(data.status == "SUCCESS"){
				alert(mobile_comm_getDic("msg_MemberWithdraw")); //커뮤니티 회원에서 탈퇴되었습니다.
				mobile_comm_go("/groupware/mobile/community/portal.do?menucode=CommunityMain"); //커뮤니티 포탈로 이동
			}else{ 
				alert(mobile_comm_getDic("msg_ErrorWithdrawalRequest")); //탈퇴 신청 중 오류가 발생했습니다.
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error); 
		}
	}); 
}

//커뮤니티 - 탈퇴신청 끝








/*!
 * 
 * 커뮤니티 상세보기
 * 
 */
var _mobile_community_homeinfo = {
	CU_ID: ''			//커뮤니티 ID
};

function mobile_community_HomeinfoInit(){	
		
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('cuid') != 'undefined') {
		_mobile_community_homeinfo.CU_ID = mobile_comm_getQueryString('cuid');
	} else {
		_mobile_community_homeinfo.CU_ID = '';
	}

	// 2. 상세 정보 가져오기
	mobile_community_setHomeInfo();
	
}

//상세 정보 조회
function mobile_community_setHomeInfo(){
	
	var url = "/groupware/mobile/community/selectCommunityInfo.do";
	var params = {
			CU_ID : _mobile_community_homeinfo.CU_ID
	};
	
	$.ajax({
		url: url,
		data:	params,
		type:"POST",
		async: false,
		success: function(response){
			
			if(response.list.length > 0){
				$(response.list).each(function(i,obj){
					$("#community_homeinfo_name").html(obj.CommunityName);
					$("#community_homeinfo_createDate").html("<span>" + mobile_comm_getDic("lbl_Establishment_Day") + ":</span> " + CFN_TransLocalTime(obj.RegProcessDate, "yyyy-MM-dd")); //개설일
					$("#community_homeinfo_type").html("<span>" + mobile_comm_getDic("lbl_type") + ":</span>  " +  obj.CommunityType); //유형
					$("#community_homeinfo_userCnt").html(obj.MemberCount);
					$("#community_homeinfo_msgCnt").html(obj.MsgCount);
					$("#community_homeinfo_memory").html(obj.LimitFileSize);
					$("#community_homeinfo_memoryUsed").html(obj.FileSize);
					$("#community_homeinfo_oneTitle").html(obj.SearchTitle);
					
					
					$("#community_homeinfo_img").html("<img src='" + mobile_comm_getThumbSrc("Community", obj.FileID) + "' alt='' onerror='mobile_community_imageerror(this);' style='width:100%;height:100%'>");
					
					if(obj.opDeptName != null && obj.opDeptName != "" && obj.opJobPositionName != null && obj.opJobPositionName != ""){
						$("#community_homeinfo_admin").html(obj.opName+"("+obj.opDeptName+"/"+obj.opJobPositionName+")");
					}else if(obj.opName != null && obj.opName != ""){
						$("#community_homeinfo_admin").html(obj.opName);
					}else{
						$("#community_homeinfo_admin").html("&nbsp;");
					}
					
					if(obj.crDeptName == undefined || obj.crDeptName == null ){
						$("#community_homeinfo_creator").html("<span>" + mobile_comm_getDic("lbl_Establishment_Man") + ":</span> -"); //개설자
					}else if(obj.crDeptName != "" && obj.crDeptName != null && obj.crJobPositionName != "" && obj.crJobPositionName != null){
						$("#community_homeinfo_creator").html("<span>" + mobile_comm_getDic("lbl_Establishment_Man") + ":</span> " + obj.crName+"("+obj.crDeptName+"/"+obj.crJobPositionName+")"); //개설자
					}else{
						$("#community_homeinfo_creator").html("<span>" + mobile_comm_getDic("lbl_Establishment_Man") + ":</span> " + obj.crName); //개설자
					}
					
					$("#community_homeinfo_provision").html( obj.ProvisionEditor);
 					
 					mobile_community_setCurrentLocation(obj.CategoryID);
				});
			}else{
				mobile_comm_back();
			}
			
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
}

//현 위치 정보 설정
function mobile_community_setCurrentLocation(pCategoryID){
	
	var locationText= "";
	var url = "/groupware/mobile/community/setCurrentLocation.do";
	var params = {
			CategoryID : pCategoryID
	};
	
	$.ajax({
		url: url,
		type:"post",
		data: params,
		success:function (data) {
			if(data.list.length > 0){
				$(data.list).each(function(i,obj){
					if(obj.num == '1'){
						locationText += obj.DisplayName;
					}else{
						if(data.list.length == 1){
							locationText += obj.DisplayName;
						}else{
							locationText += obj.DisplayName+" <i class=\"location\"></i> ";
						}
					}
    			});
				$("#community_homeinfo_category").html(locationText);
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error); 
		}
	}); 
}

//아코디언 메뉴
function mobile_community_clickAccLink(pObj){
	if($(pObj).hasClass('show')){
		$(pObj).removeClass('show');
	}else{
		$(pObj).addClass('show');
	} 	
}

//커뮤니티 - 상세보기 끝









/*!
 * 
 * 커뮤니티 회원정보
 * 
 */
var _mobile_community_memberjoininfo = {
	Page: 1,				//조회할 페이지
	PageSize: 10,		//페이지당 건수
	CU_ID: '',				//커뮤니티 ID
	IsAdmin: 'N',			//운영자 여부
		
	// 페이징을 위한 데이터
	Loading: false,			//데이터 조회 중
	TotalCount: -1,		//전체 건수
	RecentCount: 0,		//현재 보여지는 건수
	EndOfList: false,		//전체 리스트를 다 보여줬는지
};

function mobile_community_MemberJoinInfoInit(){	
		
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('cuid') != 'undefined') {
		_mobile_community_memberjoininfo.CU_ID = mobile_comm_getQueryString('cuid');
	} else {
		_mobile_community_memberjoininfo.CU_ID = '';
	}
	if (mobile_comm_getQueryString('page') != 'undefined') {
		_mobile_community_memberjoininfo.Page = mobile_comm_getQueryString('page');
	} else {
		_mobile_community_memberjoininfo.Page = 1;
	}
	_mobile_community_memberjoininfo.TotalCount = -1;
	_mobile_community_memberjoininfo.EndOfList = false;
	
	// 2. 상단메뉴
	$("#community_memberjoininfo_topmenu").html(mobile_community_makeHomeTreeList(_mobile_community_memberjoininfo));
	mobile_community_makeHomeRightMenu(_mobile_community_memberjoininfo);
	
	// 3. Tab Display 설정
	$("div.tab_wrap").each(function(){
		$(this).children('.g_tab').find('li').first().addClass('on');
		$(this).children('.tab_cont_wrap').find('.tab_cont').first().addClass('on');
	});
	
	// 4. 상세 정보 가져오기
	mobile_community_setMemberJoinInfo();	
}

//상세 정보 조회
function mobile_community_setMemberJoinInfo(){
	
	var url = "/groupware/mobile/community/selectCommunityMemberInfo.do";
	var params = {
			page: _mobile_community_memberjoininfo.Page,
			pageSize: _mobile_community_memberjoininfo.PageSize,
			CU_ID : _mobile_community_memberjoininfo.CU_ID
	};
	
	$.ajax({
		url: url,
		data:	params,
		type:"POST",
		async: false,
		success: function(response){
			
			var sMemberInfoHtml = "";
			var sBoardRankHtml = "";
			var sVisitRankHtml = "";
			
			//회원정보 그리기
			if(response.memberInfo.length > 0){
				//총 개수
				_mobile_community_memberjoininfo.TotalCount = response.cnt;
				//html 생성
				$(response.memberInfo).each(function(i,obj){
					//회원 상세 정보
					var sDetail = "";
					if(obj.CuMemberLevel != null && obj.CuMemberLevel != ''){
						sDetail = "<span class=\"team\">" + obj.CuMemberLevel + "</span>";
					}
					sDetail += "<span class=\"team\">" + obj.opDeptName + "</span><span>" + obj.opJobPositionName + "</span>";
					
					//TODO : 이름(별명)
					sMemberInfoHtml+= "<li class=\"staff\">";
					sMemberInfoHtml+= "		<a href=\"\" class=\"con_link\">";
					sMemberInfoHtml+= "			<span class=\"photo\" style=\"background-image: url('" + mobile_comm_getimg(obj.PhotoPath) + "'), url('" + mobile_comm_noperson() + "')\"></span>";
					sMemberInfoHtml+= "			<div class=\"info\">";
					sMemberInfoHtml+= "				<p class=\"name\">" + obj.opName + "</p>";
					sMemberInfoHtml+= "				<p class=\"detail\">" + sDetail + "</p>";
					sMemberInfoHtml+= "			</div>";
					sMemberInfoHtml+= "		</a>";
					sMemberInfoHtml+= "</li>";
				});
			}else{
				sMemberInfoHtml += "<div class=\"no_list\">";
				sMemberInfoHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
				sMemberInfoHtml += "</div>";
			}
			
			//회원랭킹-게시물등록 그리기
			if(response.boardRankInfo.length > 0){
				//html 생성
				$(response.boardRankInfo).each(function(i,obj){
					sBoardRankHtml+= "<li>";
					sBoardRankHtml+= "		<span class=\"num\">" + obj.num + "</span>";
					sBoardRankHtml+= "			<span class=\"photo\" style=\"background-image: url('" + mobile_comm_getimg(obj.PhotoPath) + "'), url('" + mobile_comm_noperson() + "')\"></span>";
					sBoardRankHtml+= "			<div class=\"info\">";
					sBoardRankHtml+= "				<p class=\"name\">" + obj.opName + "</p>";
					sBoardRankHtml+= "				<p class=\"score\">" + obj.MsgCount + mobile_comm_getDic("lbl_Point") + "</p>"; //점
					sBoardRankHtml+= "			</div>";
					sBoardRankHtml+= "		</a>";
					sBoardRankHtml+= "</li>";
				});
			}else{
				sBoardRankHtml += "<div class=\"no_list\">";
				sBoardRankHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
				sBoardRankHtml += "</div>";
			}
			
			//회원랭킹-방문 그리기
			if(response.visitRankInfo.length > 0){
				//html 생성
				$(response.visitRankInfo).each(function(i,obj){
					sVisitRankHtml+= "<li>";
					sVisitRankHtml+= "		<span class=\"num\">" + obj.num + "</span>";
					sVisitRankHtml+= "			<span class=\"photo\" style=\"background-image: url('" + mobile_comm_getimg(obj.PhotoPath) + "'), url('" + mobile_comm_noperson() + "')\"></span>";
					sVisitRankHtml+= "			<div class=\"info\">";
					sVisitRankHtml+= "				<p class=\"name\">" + obj.opName + "</p>";
					sVisitRankHtml+= "				<p class=\"score\">" + obj.VisitCount + mobile_comm_getDic("lbl_Point") + "</p>";
					sVisitRankHtml+= "			</div>";
					sVisitRankHtml+= "		</a>";
					sVisitRankHtml+= "</li>";
				});
			}else{
				sVisitRankHtml += "<div class=\"no_list\">";
				sVisitRankHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
				sVisitRankHtml += "</div>";
			}
			
			//html 적용
			if(_mobile_community_memberjoininfo.Page == 1 || sMemberInfoHtml.indexOf("no_list") > -1) {
				$("#community_memberjoininfo_memberJoinList").html(sMemberInfoHtml);
			} else {
				$("#community_memberjoininfo_memberJoinList").append(sMemberInfoHtml);
			}
			$("#community_memberjoininfo_boardRankList").html(sBoardRankHtml);
			$("#community_memberjoininfo_visitRankList").html(sVisitRankHtml);
			
			//더보기
			if (Math.min((_mobile_community_memberjoininfo.Page) * _mobile_community_memberjoininfo.PageSize, _mobile_community_memberjoininfo.TotalCount) == _mobile_community_memberjoininfo.TotalCount) {
				_mobile_community_memberjoininfo.EndOfList = true;
		        $('#community_memberjoininfo_btnMemberJoinListMore').hide();
		    } else {
		        $('#community_memberjoininfo_btnMemberJoinListMore').show();
		    }
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
}

//다음 회원정보 조회
function mobile_community_memberJoinNextlist(){
	if (!_mobile_community_memberjoininfo.EndOfList) {
		_mobile_community_memberjoininfo.Page++;

		mobile_community_setMemberJoinInfo();
	} else {
		$('#community_memberjoininfo_btnMemberJoinListMore').css('display', 'none');
	}
}

//탭 이동
function mobile_community_clickTabWrap(pObj){
	var target = $(pObj).parent().index();
	
	$(pObj).parent().siblings().removeClass('on');
	$(pObj).parent().addClass('on');
	$(pObj).parent().parent().siblings('.tab_cont_wrap').children('.tab_cont').removeClass('on');
	$(pObj).parent().parent().siblings('.tab_cont_wrap').children('.tab_cont').eq(target).addClass('on');
	
}

//커뮤니티 - 회원정보 끝
