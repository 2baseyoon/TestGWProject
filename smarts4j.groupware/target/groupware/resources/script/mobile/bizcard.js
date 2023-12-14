
// TODO: 임시 작성함


/*!
 * 
 * 
 * SmartS4j / MobileOffice / 모바일 인명관리 js 파일
 * 함수명 : mobile_bizcard_...
 * 
 * 
 */


/*!
 * 
 * 페이지별 init 함수
 * 
 */

//인명관리 목록 페이지
$(document).on('pageinit', '#bizcard_list_page', function () {	
	if($("#bizcard_list_page").attr("IsLoad") != "Y"){
		$("#bizcard_list_page").attr("IsLoad", "Y");
		setTimeout("mobile_bizcard_ListInit()", 10);
	}
});

//인명관리 목록 - 전체 연락처 페이지
$(document).on('pageinit', '#bizcard_alllist_page', function () {
	if($("#bizcard_alllist_page").attr("IsLoad") != "Y"){
		$("#bizcard_alllist_page").attr("IsLoad", "Y");
		setTimeout("mobile_bizcard_AllListInit()", 10);
	}
});

//인명관리 목록 - 개인 연락처 페이지
$(document).on('pageinit', '#bizcard_personlist_page', function () {
	if($("#bizcard_personlist_page").attr("IsLoad") != "Y"){
		$("#bizcard_personlist_page").attr("IsLoad", "Y");
		setTimeout("mobile_bizcard_PersonListInit()", 10);
	}
});

//인명관리 목록 - 부서 연락처 페이지
$(document).on('pageinit', '#bizcard_deptlist_page', function () {
	if($("#bizcard_deptlist_page").attr("IsLoad") != "Y"){
		$("#bizcard_deptlist_page").attr("IsLoad", "Y");
		setTimeout("mobile_bizcard_DeptListInit()", 10);
	}
});

//인명관리 목록 - 회사 연락처 페이지
$(document).on('pageinit', '#bizcard_unitlist_page', function () {
	if($("#bizcard_unitlist_page").attr("IsLoad") != "Y"){
		$("#bizcard_unitlist_page").attr("IsLoad", "Y");
		setTimeout("mobile_bizcard_UnitListInit()", 10);
	}
});

//인명관리 목록 - 업체 연락처 페이지
$(document).on('pageinit', '#bizcard_companylist_page', function () {
	if($("#bizcard_companylist_page").attr("IsLoad") != "Y"){
		$("#bizcard_companylist_page").attr("IsLoad", "Y");
		setTimeout("mobile_bizcard_CompanyListInit()", 10);
	}
});

//인명관리 목록 - 즐겨찾기 연락처 페이지
$(document).on('pageinit', '#bizcard_favlist_page', function () {
	if($("#bizcard_favlist_page").attr("IsLoad") != "Y"){
		$("#bizcard_favlist_page").attr("IsLoad", "Y");
		setTimeout("mobile_bizcard_FavListInit()", 10);
	}
});

//인명관리 - 그룹 선택 페이지
$(document).on('pageinit', '#bizcard_select_page', function () {
	if($("#bizcard_select_page").attr("IsLoad") != "Y"){
		$("#bizcard_select_page").attr("IsLoad", "Y");
		setTimeout("mobile_bizcard_SelectInit()", 10);
	}
});

//인명관리 - 작성 페이지
$(document).on('pageinit', '#bizcard_write_page', function () {
	if($("#bizcard_write_page").attr("IsLoad") != "Y"){
		$("#bizcard_write_page").attr("IsLoad", "Y");
		setTimeout("mobile_bizcard_WriteInit()", 10);
	}
});

//인명관리 - 상세보기 페이지
$(document).on('pageinit', '#bizcard_view_page', function () {
	if($("#bizcard_view_page").attr("IsLoad") != "Y"){
		$("#bizcard_view_page").attr("IsLoad", "Y");
		setTimeout("mobile_bizcard_ViewInit()", 10);
	}
});

//인명관리 - 우편번호 조회 페이지
$(document).on('pageinit', '#bizcard_zipcode_page', function () {
	if($("#bizcard_zipcode_page").attr("IsLoad") != "Y"){
		$("#bizcard_zipcode_page").attr("IsLoad", "Y");
		setTimeout("mobile_bizcard_ZipcodeInit()", 10);
	}
});

// 직접입력전화 항목
$(document).on("change", "#selPhoneType",function(){
	if($(this).val() == "D") {
		$("#phonetxt_1").empty();
		$("#phonetxt_2").empty();		
		$("#phonetxt_1").append("<div class=\"ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset\"><input name=\"bizcard_write_phonename\" class=\"bizcard_tx_input HtmlCheckXSS ScriptCheckXSS\" type=\"text\" style=\"margin-left: 4px;\" placeholder=\""+mobile_comm_getDic("lbl_DirectPhone")+"\"></div>");	
		$("#phonetxt_2").append("<div class=\"ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset\"><input name=\"bizcard_write_phonetxt\" class=\"bizcard_tx_input HtmlCheckXSS ScriptCheckXSS\" type=\"text\" style=\"margin-left: 4px;\" placeholder=\""+mobile_comm_getDic("btn_bizcard_EnterNum")+"\"></div>");
		$(".bizcard_direct").show();
	 } else {		  
		$(".bizcard_direct").hide();		
		$("#phonetxt_1").empty();
		$("#phonetxt_2").empty();		
		$("#phonetxt_1").append("<div class=\"ui-input-text ui-body-inherit ui-corner-all ui-shadow-inset\"><input name=\"bizcard_write_phonetxt\" class=\"bizcard_tx_input HtmlCheckXSS ScriptCheckXSS\" type=\"text\" style=\"margin-left: 4px;\" placeholder=\""+mobile_comm_getDic("btn_bizcard_EnterNum")+"\"></div>");				
	 }
});




/*!
 * 
 * 인명관리 목록 공통
 * 
 */

var _mobile_bizcard_list = {
		
		//기본 설정값
		ViewType : 'A',			//뷰 타입 설정(전체/개인/부서/회사/업체/즐겨찾는 연락처)
		GroupID : '',			//선택한 그룹
		Page: 1,					//페이지 번호
		PageSize: 10,			//페이지당 건수
		SearchText: '',			//검색어
		SearchType: 'Multi', 	//검색타입
		
		// 페이징을 위한 데이터
		Loading: false,			//데이터 조회 중
		TotalCount: -1,		//전체 건수
		RecentCount: 0,		//현재 보여지는 건수
		EndOfList: false,		//전체 리스트를 다 보여줬는지 여부	
		
		//스크롤 위치 고정
		OnBack: false,			//뒤로가기로 왔을 경우
		Scroll: 0,					//스크롤 위치
		
		//선택 모드
		IsSelectMode: false,	//선택 모드인지 확인(업체/우편번호)
};

//인명관리 목록
function mobile_bizcard_ListInit() {
	// 1. 파라미터 셋팅
	if(window.sessionStorage.getItem("mobileBizcardType") != undefined && window.sessionStorage.getItem("mobileBizcardType") != "") {
		_mobile_bizcard_list.ViewType = window.sessionStorage.getItem("mobileBizcardType");
	} else {
		if (mobile_comm_getQueryString('ViewType') != 'undefined') {
			_mobile_bizcard_list.ViewType = mobile_comm_getQueryString('ViewType');
		} else {
			_mobile_bizcard_list.ViewType = 'A';
		}
	}
		
	
	_mobile_bizcard_list.GroupID = '';			//선택한 그룹
	_mobile_bizcard_list.Page = 1;				//현재 페이지
	_mobile_bizcard_list.SearchText = '';			//검색어
	_mobile_bizcard_list.TotalCount = -1;			//전체 건수
	_mobile_bizcard_list.RecentCount = 0;		//현재 보여지는 건수
	_mobile_bizcard_list.EndOfList =  false;		//전체 리스트를 다 보여줬는지 여부	
	$('#mobile_search_input').val('');
	if (localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != null && localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != "") {
		_mobile_bizcard_list.GroupID = localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code"));
	} else {
		_mobile_bizcard_list.GroupID = '';
	}
	
	// 2. 상단메뉴
	// 좌측메뉴 표시 (기본 게시&커스텀메뉴 모두 동일하고 트리만 다름)
	$('#bizcard_list_topmenu').html(mobile_bizcard_getTopMenuHtml(BizcardMenu));	//BizcardMenu - 서버에서 넘겨주는 좌측메뉴 목록
	
	
	// 3. 목록 조회
	mobile_bizcard_getList(_mobile_bizcard_list);
}

//상단메뉴(PC 좌측메뉴) 그리기
function mobile_bizcard_getTopMenuHtml(bizcardmenu) {
	var sHtml = "";
	var nSubLength = 0;
	var sALink = "";
	var sLeftMenuID = "";
	var sViewType = "A";
	
	sHtml += "<ul class=\"h_tree_menu_wrap\">";
	$(bizcardmenu).each(function (i, data){
		
		if(data.URL != null && data.URL != undefined && data.URL.toUpperCase().indexOf("IMPORT") < 1 && data.URL.toUpperCase().indexOf("EXPORT") < 1 && data.URL.toUpperCase().indexOf("ORGANIZE") < 1 ){

			if(data.URL.toUpperCase().indexOf("FORP") > -1){
				sViewType = "P";
			} else if(data.URL.toUpperCase().indexOf("FORD") > -1){
				sViewType = "D";
			} else if(data.URL.toUpperCase().indexOf("FORU") > -1){
				sViewType = "U";
			} else if(data.URL.toUpperCase().indexOf("COMPANY") > -1){
				sViewType = "C";
			}  else if(data.URL.toUpperCase().indexOf("FAV") > -1){
				sViewType = "F";
			} else {
				sViewType = "A";
			}
			
			nSubLength = (data.Sub == null || data.Sub == undefined) ? 0 : data.Sub.length;
			
			sALink = "";
			
			sHtml += "<li viewtype=\"" + sViewType + "\" displayname=\"" + data.DisplayName + "\">";
			sHtml += "    <div class=\"h_tree_menu\">";
			
			if(nSubLength > 0) {
				sALink = "javascript: mobile_bizcard_ChangeMenu('" + sViewType + "');";
				
				sHtml += "    <a href=\"\" class=\"t_link not_tree\">";
				sHtml += "	  	  <span onclick=\"javascript: mobile_bizcard_openclose('li_sub_" + data.MenuID + "', 'span_menu_" + data.MenuID + "');\">";
				sHtml += "        	  <span id=\"span_menu_" + data.MenuID + "\" class=\"t_ico_open\"></span><span class=\"t_ico_call\"></span>";//TODO: t_ico_app 클래스 처리
				sHtml += "	  	  </span>"
				sHtml += "    	  <span onclick=\"" + sALink + "\">";//TODO: 링크 처리
				sHtml += "        	  " + data.DisplayName;
				sHtml += "    	  </span>";	
				sHtml += "    </a>";
				
				sHtml += "    <ul class=\"sub_list\" id=\"li_sub_" + data.MenuID + "\">";
				$(data.Sub).each(function (j, subdata){
					
					if(subdata.URL.toUpperCase().indexOf("FORP") > -1){
						sViewType = "P";
					} else if(subdata.URL.toUpperCase().indexOf("FORD") > -1){
						sViewType = "D";
					} else if(subdata.URL.toUpperCase().indexOf("FORU") > -1){
						sViewType = "U";
					} else if(subdata.URL.toUpperCase().indexOf("COMPANY") > -1){
						sViewType = "C";
					}  else if(data.URL.toUpperCase().indexOf("FAV") > -1){
						sViewType = "F";
					} else {
						sViewType = "A";
					}
					
					sALink = "javascript: mobile_bizcard_ChangeMenu('" + sViewType + "');";
					
					sHtml += "    <li viewtype=\"" + sViewType + "\" displayname=\"" + subdata.DisplayName + "\">";
					sHtml += "        <a href=\"" + sALink + "\" class=\"t_link\">";//TODO: 링크 처리
					sHtml += "            <span class=\"t_ico_board\"></span>";
					sHtml += "            " + subdata.DisplayName;
					sHtml += "        </a>";
					sHtml += "    </li>";
				});
				sHtml += "    </ul>";
				
			} else {
				sALink = "javascript: mobile_bizcard_ChangeMenu('" + sViewType + "');";
				
				sHtml += "    <a href=\"" + sALink + "\" class=\"t_link not_tree\">";//TODO: 링크 처리
				
				if(sViewType == "F") {
					sHtml += "        <span class=\"t_ico_important\"></span>";//TODO: 클래스 처리
				} else {
					sHtml += "        <span class=\"t_ico_app\"></span>";//TODO: 클래스 처리
				}				
				sHtml += "        " + data.DisplayName;
				sHtml += "    </a>";
			}			
			
			sHtml += "    </div>";
			sHtml += "</li>";
		}
		
	});
	sHtml += "</ul>";
	
	return sHtml;
}

//상단 메뉴명 셋팅
function mobile_bizcard_getTopMenuName() {
	
	var sTopMenu = $('#bizcard_list_topmenu').find("li:eq(0)").text();
	$('#bizcard_list_topmenu').find("li[displayname]").each(function (){
		if($(this).attr('viewtype') == _mobile_bizcard_list.ViewType) {
			sTopMenu = $(this).attr('displayname');
		}		
	});
	
	if(_mobile_bizcard_list.ViewType == "P" || _mobile_bizcard_list.ViewType == "D" || _mobile_bizcard_list.ViewType == "U"){
		sTopMenu += " " + mobile_comm_getDic("lbl_bizcard_Contact");
	}
	
	//$('#bizcard_list_title').html("<span class=\"Tit_ellip\">"+ sTopMenu + "</span><i class=\"arr_menu\"></i>");
	$('#bizcard_list_title').html(sTopMenu + "<i class=\"arr_menu\"></i>");
}

//하위 메뉴/트리 열고 닫기
function mobile_bizcard_openclose(liId, iconId) {
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

//메뉴 변경
function mobile_bizcard_ChangeMenu(bizcardType) {	
	if(bizcardType == undefined || bizcardType == 'undefined' || bizcardType == '') {
		bizcardType = "A";
	}

	window.sessionStorage.setItem("mobileBizcardType", bizcardType);
	
	_mobile_bizcard_list.ViewType = bizcardType;
	_mobile_bizcard_list.SearchText = '';
	_mobile_bizcard_list.Page = 1;
	_mobile_bizcard_list.EndOfList = false;
	
	$('#mobile_search_input').val('');
	
	mobile_bizcard_getList(_mobile_bizcard_list);
	
}
    
//인명관리 목록 조회
function mobile_bizcard_getList(params){
	var sPage = params.Page;
	var sPageSize = params.PageSize;
	
	if(params.OnBack) {
		sPageSize = sPage * (sPageSize);
        sPage = 1;
	}
	
	mobile_comm_TopMenuClick('bizcard_list_topmenu', true);
	
	var url = "/groupware/mobile/bizcard/getBizCardAllList.do";
	if(params.ViewType=="F"){
		url = "/groupware/mobile/bizcard/getBizCardFavoriteList.do"; 
	} else {
		url = "/groupware/mobile/bizcard/getBizCardAllList.do";
	}
	
	params.GroupID = "";
	
	var paramdata = {
		shareType: params.ViewType,
		tabFilter: 'ALL',
		searchWord: params.SearchText,
		searchType: params.SearchType,
		startDate : null,
		endDate : null,
		pageNo: sPage,
		pageSize: sPageSize,
		groupIDs : params.GroupID
	};
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		async: false,
		success: function (response) {
			if(response.status == "SUCCESS") {
				
				_mobile_bizcard_list.TotalCount = response.page.listCount;

				//목록별 데이터 처리
				var sHtml = "";
				if(params.ViewType == "C"){
					sHtml = mobile_bizcard_getCompanyListHtml(response.list);
				} else {
					sHtml = mobile_bizcard_getPersonListHtml(response.list);
				}
				
				if(params.Page == 1 || sHtml.indexOf("no_list") > -1) {
					$('#bizcard_list_data').html(sHtml);
				} else {
					$('#bizcard_list_data').append(sHtml);
				}
				
				if (Math.min((_mobile_bizcard_list.Page) * _mobile_bizcard_list.PageSize, _mobile_bizcard_list.TotalCount) == _mobile_bizcard_list.TotalCount) {
					_mobile_bizcard_list.EndOfList = true;
	                $('#bizcard_list_more').hide();
	            } else {
	                $('#bizcard_list_more').show();
	            }
				
				if(_mobile_bizcard_list.OnBack) {
					_mobile_bizcard_list.OnBack = false;
				}
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	mobile_bizcard_getTopMenuName();
}



//인명관리 - 전체/개인/부서/회사/즐겨찾기 목록 html
function mobile_bizcard_getPersonListHtml(eventData){

	var sHtml = "";
	
	if($(eventData).length > 0){
		$(eventData).each(function(j){
			
			//이미지 정보
			var sImg = mobile_comm_getimg(mobile_comm_getBaseConfig("BackStorage").replace("{0}", mobile_comm_getSession("DN_Code")) + this.ImagePath);
			var sNoImg = mobile_comm_noperson();
			if(this.BizCardType == "Group"){
				sImg = mobile_comm_nogroup();
				sNoImg = mobile_comm_nogroup();
			}
			
			//이름 정보
			var sTitle = "<strong>" + this.Name + "</strong> " + this.JobTitle;
			if(this.ComName != ""){
				sTitle += " <span class=\"team\">" + this.ComName + "</span>";
			}
			
			//분류 정보
			var sTypeTag = "";
			if(this.ShareType == "P"){
				sTypeTag += "<span class=\"flag01\">" + mobile_comm_getDic("lbl_ShareType_Personal") + "</span>"; //개인
			} else if(this.ShareType == "D"){
				sTypeTag += "<span class=\"flag02\">" + mobile_comm_getDic("lbl_ShareType_Dept") + "</span>"; //부서
			} else if(this.ShareType == "U"){
				sTypeTag += "<span class=\"flag03\">" + mobile_comm_getDic("lbl_Company") + "</span>"; //회사
			}
			
			//즐겨찾기 정보
			var sFavClass = "bookmark";
			if(this.IsFavorite == "Y"){
				sFavClass += " active";
			}
			
			//상세보기 url 정보
			var sUrl = "/groupware/mobile/bizcard/view.do";
			sUrl += "?bizcardid=" + this.BizCardID;
			if(this.BizCardType != "Group"){
				sUrl += "&viewtype=P";
			} else {
				sUrl += "&viewtype=G";
			}
			
			sHtml += "<li id=\"bizcard_" + this.BizCardID + "\">";
			sHtml += "		<a href=\"javascript: mobile_comm_go('" + sUrl + "','Y');\" class=\"con_link\">"; 
			sHtml += "			<span class=\"photo\" style=\"overflow: hidden\">";
			sHtml += "				<img style=\"width: 100%; height: 100%;\" onerror='this.src=\""+sNoImg+"\"' src=\"" + sImg + "\">";
			sHtml += "			</span>";
			if(this.BizCardType != "Group"){
				sHtml += "			<dl>";
				sHtml += "				<dt>" + sTitle + "</dt>";
				sHtml += "				<dd class=\"cate\">" + sTypeTag + "</dd>";
				sHtml += "				<dd class=\"mobile\">" + (this.PhoneNum == ""? "-" : this.PhoneNum) + "</dd>";
				sHtml += "				<dd class=\"email\">" +(this.EMAIL == ""? "-" : this.EMAIL) + "</dd>";
				sHtml += "			</dl>";
				sHtml += "		</a>";
				sHtml += "		<a href=\"javascript: mobile_bizcard_changeFavoriteStatus(" + this.BizCardID + ");\" class=\"" + sFavClass + "\"></a>";
			} else {
				sHtml += "			<dl>";
				sHtml += "				<dt style='margin:4px 0px 0px;'>" + sTitle + "("+ this.MemberCnt +")</dt>";
				sHtml += "				<dd class=\"cate\">" + sTypeTag + "</dd>";
				sHtml += "			</dl>";
				sHtml += "		</a>";
			}
			sHtml += "</li>";
		});
	} else {
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
		sHtml += "</div>";
	}

	return sHtml;
	
}

//인명관리 - 업체 목록 html
function mobile_bizcard_getCompanyListHtml(eventData){

	//선택 모드일 시, 추가적인 css 처리
	if (_mobile_bizcard_list.IsSelectMode == true){
		
		//명칭 변경
		$("#bizcard_list_topmenu_" + _mobile_bizcard_list.ViewType).siblings("a").text(mobile_comm_getDic("lbl_bizcard_selectCompany")); //업체 선택
		
		//타 메뉴 이동 방지
		$("#bizcard_list_topmenu_" + _mobile_bizcard_list.ViewType).siblings("a").removeClass("ui-link");
		$("#bizcard_list_topmenu_" + _mobile_bizcard_list.ViewType).siblings("a").children("i").remove();
		
		//검색 외에 기타 버튼 숨기기
		$("div.utill a:not(.btn_search):not([id='bizcard_write_save'])").remove();
		
		//상단에 close 버튼 생기는 부분 방지
		$("div.sub_header").siblings("a.ui-icon-delete").remove();
		
	}
	
	var sHtml = "";
	
	if($(eventData).length > 0){
		$(eventData).each(function(j){

			//사진 정보
			var sImg = this.ImagePath=="" ? "/covicore/resources/images/no_image.jpg" : this.ImagePath;
			
			//ClickEvent 처리 - 상세보기/선택 업체 저장
			var sClickEvent = "";
			if (_mobile_bizcard_list.IsSelectMode == true){
				sClickEvent += "mobile_bizcard_setSelectedComInfo('" + this.BizCardID + "', '" + this.ComName + "');";
			} else {	
				sClickEvent += "mobile_comm_go('/groupware/mobile/bizcard/view.do?bizcardid=" + this.BizCardID + "&viewtype=C','Y');"; 
			}
			
			sHtml += "<li id=\"bizcard_" + this.BizCardID + "\">";
			sHtml += "		<a href=\"javascript: " + sClickEvent + "\">"; 
			sHtml += "			<span class=\"card_img\" style=\"background-image:url('" + sImg + "');\"></span>";
			sHtml += "			<dl>";
			sHtml += "				<dt>" + this.ComName + "</dt>";
			sHtml += "				<dd class=\"ceo_name\">" + this.ComRepName + "</dd>";
			sHtml += "				<dd class=\"tel\">" + (this.PhoneNum == ""? "-" : this.PhoneNum) + "</dd>";
			sHtml += "				<dd class=\"email\">" +(this.EMAIL == ""? "-" : this.EMAIL) + "</dd>";
			sHtml += "			</dl>";
			sHtml += "		</a>";
			sHtml += "</li>";
	        
		});
	} else {
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
		sHtml += "</div>";
	}

	return sHtml;
	
}

//업체 선택 시, 값 넣기
function mobile_bizcard_setSelectedComInfo(pBizID, pBizName){
	
	//선택 모드 해제
	sessionStorage.removeItem("isselectmode");
	
	//write 화면에 값 저장
	$("#bizcard_write_personcompany").val(pBizName);
	$("#bizcard_write_personcompany").attr("comID", pBizID)
	
	//dialog 창 닫기
	$.mobile.back(); 
}

//즐겨찾기 여부 변경
function mobile_bizcard_changeFavoriteStatus(pBizID){
	
	var url = "/groupware/mobile/bizcard/changeFavoriteStatus.do";
	var BizCardID = pBizID;
	var StatusToBe = '';
	var pObj = $("li[id='bizcard_" + pBizID + "'] a.bookmark");
	
	if($(pObj).hasClass('active')){
		$(pObj).removeClass('active');
		StatusToBe = "N";
	}
	else{
		$(pObj).addClass('active');
		StatusToBe = "Y";
	}

	$.ajax({
		url:url,
		type:"post",
		data:{
				"BizCardID":BizCardID,
				"StatusToBe":StatusToBe
			},
		async:false,
		success:function (res) {
			if(StatusToBe == "Y") $(pObj).addClass("active");
			else $(pObj).removeClass("active");
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
}

//더보기 클릭
function mobile_bizcard_nextlist() {	
	if (!_mobile_bizcard_list.EndOfList) {
		_mobile_bizcard_list.Page++;
		mobile_bizcard_getList(_mobile_bizcard_list);
    } else {
        $('#bizcard_list_more_' + _mobile_bizcard_list.ViewType).css('display', 'none');
    }
}

//스크롤 더보기
function mobile_bizcard_list_page_ListAddMore(){
	mobile_bizcard_nextlist();
}

//검색 버튼 클릭
function mobile_bizcard_clicksearch(){
	//검색어 초기화
	_mobile_bizcard_list.SearchText = $('#mobile_search_input').val();
	_mobile_bizcard_list.Page = 1;
	_mobile_bizcard_list.PageSize = 10;
	
	//목록 재조회
	mobile_bizcard_getList(_mobile_bizcard_list);
	//$('#mobile_loading').hide();
}


//새로고침
function mobile_bizcard_clickrefresh() {
	//초기화
	_mobile_bizcard_list.GroupID = '';			//선택한 그룹
	_mobile_bizcard_list.Page = 1;				//현재 페이지
	_mobile_bizcard_list.SearchText = '';			//검색어
	_mobile_bizcard_list.TotalCount = -1;			//전체 건수
	_mobile_bizcard_list.RecentCount = 0;		//현재 보여지는 건수
	_mobile_bizcard_list.EndOfList =  false;		//전체 리스트를 다 보여줬는지 여부	
	$('#mobile_search_input').val('');
	
	mobile_bizcard_getList(_mobile_bizcard_list);
}

//작성 클릭
function mobile_bizcard_clickwrite(){
	var sUrl = "/groupware/mobile/bizcard/write.do";
	sUrl += "?viewtype=" + _mobile_bizcard_list.ViewType;
		
	mobile_comm_go(sUrl,'Y');
}

//인명관리 공통 끝









/*!
 * 
 * 인명관리 목록 - 전체 연락처
 * 
 */

//전체 연락처 페이지 초기화
function mobile_bizcard_AllListInit(){
	// 1. 파라미터 셋팅
	_mobile_bizcard_list.ViewType = 'A';
	_mobile_bizcard_list.GroupID = '';			//선택한 그룹
	_mobile_bizcard_list.Page = 1;				//현재 페이지
	_mobile_bizcard_list.SearchText = '';			//검색어
	_mobile_bizcard_list.TotalCount = -1;			//전체 건수
	_mobile_bizcard_list.RecentCount = 0;		//현재 보여지는 건수
	_mobile_bizcard_list.EndOfList =  false;		//전체 리스트를 다 보여줬는지 여부	
	$('#mobile_search_input').val('');
	if (localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != null && localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != "") {
		_mobile_bizcard_list.GroupID = localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code"));
	} else {
		_mobile_bizcard_list.GroupID = '';
	}
	
	// 2. 상단메뉴
	// 좌측메뉴 표시 (기본 게시&커스텀메뉴 모두 동일하고 트리만 다름)
	$('#bizcard_list_topmenu_' + _mobile_bizcard_list.ViewType).html(mobile_bizcard_getTopMenuHtml(BizcardMenu));	//BizcardMenu - 서버에서 넘겨주는 좌측메뉴 목록
	
	
	// 3. 목록 조회
	mobile_bizcard_getList(_mobile_bizcard_list);

}

//인명관리 전체 연락처 끝







/*!
 * 
 * 인명관리 목록 - 개인 연락처
 * 
 */

//개인 연락처 페이지 초기화
function mobile_bizcard_PersonListInit(){
	// 1. 파라미터 셋팅
	_mobile_bizcard_list.ViewType = 'P';
	_mobile_bizcard_list.GroupID = '';			//선택한 그룹
	_mobile_bizcard_list.Page = 1;				//현재 페이지
	_mobile_bizcard_list.SearchText = '';			//검색어
	_mobile_bizcard_list.TotalCount = -1;			//전체 건수
	_mobile_bizcard_list.RecentCount = 0;		//현재 보여지는 건수
	_mobile_bizcard_list.EndOfList =  false;		//전체 리스트를 다 보여줬는지 여부	
	$('#mobile_search_input').val('');
	if (localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != null && localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != "") {
		_mobile_bizcard_list.GroupID = localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code"));
	} else {
		_mobile_bizcard_list.GroupID = '';
	}
	
	// 2. 상단메뉴
	// 좌측메뉴 표시 (기본 게시&커스텀메뉴 모두 동일하고 트리만 다름)
	$('#bizcard_list_topmenu_' + _mobile_bizcard_list.ViewType).html(mobile_bizcard_getTopMenuHtml(BizcardMenu));	//BizcardMenu - 서버에서 넘겨주는 좌측메뉴 목록
	
	
	// 3. 목록 조회
	mobile_bizcard_getList(_mobile_bizcard_list);

}

//인명관리 개인 연락처 끝







/*!
 * 
 * 인명관리 목록 - 부서 연락처
 * 
 */

//부서 연락처 페이지 초기화
function mobile_bizcard_DeptListInit(){
	// 1. 파라미터 셋팅
	_mobile_bizcard_list.ViewType = 'D';
	_mobile_bizcard_list.GroupID = '';			//선택한 그룹
	_mobile_bizcard_list.Page = 1;				//현재 페이지
	_mobile_bizcard_list.SearchText = '';			//검색어
	_mobile_bizcard_list.TotalCount = -1;			//전체 건수
	_mobile_bizcard_list.RecentCount = 0;		//현재 보여지는 건수
	_mobile_bizcard_list.EndOfList =  false;		//전체 리스트를 다 보여줬는지 여부	
	$('#mobile_search_input').val('');
	if (localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != null && localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != "") {
		_mobile_bizcard_list.GroupID = localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code"));
	} else {
		_mobile_bizcard_list.GroupID = '';
	}
	
	// 2. 상단메뉴
	// 좌측메뉴 표시 (기본 게시&커스텀메뉴 모두 동일하고 트리만 다름)
	$('#bizcard_list_topmenu_' + _mobile_bizcard_list.ViewType).html(mobile_bizcard_getTopMenuHtml(BizcardMenu));	//BizcardMenu - 서버에서 넘겨주는 좌측메뉴 목록
	
	
	// 3. 목록 조회
	mobile_bizcard_getList(_mobile_bizcard_list);

}

//인명관리 부서 연락처 끝







/*!
 * 
 * 인명관리 목록 - 회사 연락처
 * 
 */

//회사 연락처 페이지 초기화
function mobile_bizcard_UnitListInit(){
	// 1. 파라미터 셋팅
	_mobile_bizcard_list.ViewType = 'U';
	_mobile_bizcard_list.GroupID = '';			//선택한 그룹
	_mobile_bizcard_list.Page = 1;				//현재 페이지
	_mobile_bizcard_list.SearchText = '';			//검색어
	_mobile_bizcard_list.TotalCount = -1;			//전체 건수
	_mobile_bizcard_list.RecentCount = 0;		//현재 보여지는 건수
	_mobile_bizcard_list.EndOfList =  false;		//전체 리스트를 다 보여줬는지 여부	
	$('#mobile_search_input').val('');
	if (localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != null && localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != "") {
		_mobile_bizcard_list.GroupID = localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code"));
	} else {
		_mobile_bizcard_list.GroupID = '';
	}
	
	// 2. 상단메뉴
	// 좌측메뉴 표시 (기본 게시&커스텀메뉴 모두 동일하고 트리만 다름)
	$('#bizcard_list_topmenu_' + _mobile_bizcard_list.ViewType).html(mobile_bizcard_getTopMenuHtml(BizcardMenu));	//BizcardMenu - 서버에서 넘겨주는 좌측메뉴 목록
	
	
	// 3. 목록 조회
	mobile_bizcard_getList(_mobile_bizcard_list);

}

//인명관리 회사 연락처 끝







/*!
 * 
 * 인명관리 목록 - 업체 연락처
 * 
 */

//업체 연락처 페이지 초기화
function mobile_bizcard_CompanyListInit(){
	// 1. 파라미터 셋팅
	_mobile_bizcard_list.ViewType = 'C';
	_mobile_bizcard_list.GroupID = '';			//선택한 그룹
	_mobile_bizcard_list.Page = 1;				//현재 페이지
	_mobile_bizcard_list.SearchText = '';			//검색어
	_mobile_bizcard_list.TotalCount = -1;			//전체 건수
	_mobile_bizcard_list.RecentCount = 0;		//현재 보여지는 건수
	_mobile_bizcard_list.EndOfList =  false;		//전체 리스트를 다 보여줬는지 여부	
	$('#mobile_search_input').val('');
	if (sessionStorage.getItem('isselectmode') != null && sessionStorage.getItem('isselectmode') == "true" ) {
		_mobile_bizcard_list.IsSelectMode =true;
	} else {
		_mobile_bizcard_list.IsSelectMode = false;
	}
	if (_mobile_bizcard_list.IsSelectMode == false && localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != null && localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != "") {
		_mobile_bizcard_list.GroupID = localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code"));
	} else {
		_mobile_bizcard_list.GroupID = '';
	}
	
	// 2. 상단메뉴(선택 모드일때에는 필요 없음)
	if (_mobile_bizcard_list.IsSelectMode == false){
		// 좌측메뉴 표시 (기본 게시&커스텀메뉴 모두 동일하고 트리만 다름)
		$('#bizcard_list_topmenu_' + _mobile_bizcard_list.ViewType).html(mobile_bizcard_getTopMenuHtml(BizcardMenu));	//BizcardMenu - 서버에서 넘겨주는 좌측메뉴 목록
	}
	
	
	// 3. 목록 조회
	mobile_bizcard_getList(_mobile_bizcard_list);

}

//인명관리 업체 연락처 끝







/*!
 * 
 * 인명관리 목록 - 즐겨찾기 연락처
 * 
 */

//즐겨찾기 연락처 페이지 초기화
function mobile_bizcard_FavListInit(){
	// 1. 파라미터 셋팅
	_mobile_bizcard_list.ViewType = 'F';
	_mobile_bizcard_list.GroupID = '';			//선택한 그룹
	_mobile_bizcard_list.Page = 1;				//현재 페이지
	_mobile_bizcard_list.SearchText = '';			//검색어
	_mobile_bizcard_list.TotalCount = -1;			//전체 건수
	_mobile_bizcard_list.RecentCount = 0;		//현재 보여지는 건수
	_mobile_bizcard_list.EndOfList =  false;		//전체 리스트를 다 보여줬는지 여부	
	$('#mobile_search_input').val('');
	if (localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != null && localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != "") {
		_mobile_bizcard_list.GroupID = localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code"));
	} else {
		_mobile_bizcard_list.GroupID = '';
	}
	
	// 2. 상단메뉴
	// 좌측메뉴 표시 (기본 게시&커스텀메뉴 모두 동일하고 트리만 다름)
	$('#bizcard_list_topmenu_' + _mobile_bizcard_list.ViewType).html(mobile_bizcard_getTopMenuHtml(BizcardMenu));	//BizcardMenu - 서버에서 넘겨주는 좌측메뉴 목록
	
	
	// 3. 목록 조회
	mobile_bizcard_getList(_mobile_bizcard_list);

}

//인명관리 즐겨찾기 연락처 끝







/*!
 * 
 * 인명관리 - 그룹 선택
 * 
 */

//그룹 선택 페이지 초기화
function mobile_bizcard_SelectInit(){
	// 1. 파라미터 셋팅
	/*_mobile_bizcard_list.ViewType = 'F';
	if (localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code")) != null) {
		_mobile_bizcard_list.GroupID = localStorage.getItem("BizcardGroup_"+mobile_comm_getSession("UR_Code"));
	} else {
		_mobile_bizcard_list.GroupID = '';
	}*/
	
	// 2. Display 조절
	$("#bizcard_select_checklistperson").hide();
	$("#bizcard_select_checklistdept").hide();
	$("#bizcard_select_checklistunit").hide();
	$("#bizcard_select_checklistcompany").hide();
	
	if(_mobile_bizcard_list.ViewType == "A" || _mobile_bizcard_list.ViewType == "F"){
		$("#bizcard_select_checklistperson").show();
		$("#bizcard_select_checklistdept").show();
		$("#bizcard_select_checklistunit").show();
	} else if(_mobile_bizcard_list.ViewType == "P"){
		$("#bizcard_select_checklistperson").show();
	} else if(_mobile_bizcard_list.ViewType == "D"){
		$("#bizcard_select_checklistdept").show();
	} else if(_mobile_bizcard_list.ViewType == "U"){
		$("#bizcard_select_checklistunit").show();
	} else if(_mobile_bizcard_list.ViewType == "C"){
		$("#bizcard_select_checklistcompany").show();
	}

	// 3. 목록 가져오기
	mobile_bizcard_getGroup(_mobile_bizcard_list);

}

//그룹 목록 가져오기
function mobile_bizcard_getGroup(params){
	var sPersonHtml = "<ul><li class=\"cate_tit\">" + mobile_comm_getDic("lbl_ShareType_Personal") + "</li>"; //개인
	var sDeptHtml = "<ul><li class=\"cate_tit\">" + mobile_comm_getDic("lbl_ShareType_Dept") + "</li>"; //부서
	var sUnitHtml = "<ul><li class=\"cate_tit\">" + mobile_comm_getDic("lbl_Company") + "</li>"; //회사
	var sCompanyHtml = "<ul><li class=\"cate_tit\">" + mobile_comm_getDic("lbl_Company2") + "</li>"; //업체
	
	var url = "/groupware/mobile/bizcard/getBizCardGroupList.do";
	
	//업체일 경우만 C로 넘기고, 그 외에는 A로 넘김
	var paramdata = {
		shareType: params.ViewType == "C" ? "C" : "A",
		pageNo: null,
		pageSize: null
	};
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		async: false,
		success: function (response) {
			if(response.status == "SUCCESS") {
				
				if(response.list.length > 0){
	     			$(response.list).each(function(){
	     				
	     				var shareType = this.ShareType;
	     				
	     				if(shareType == "P"){
	     					sPersonHtml += "<li class=\"chk_item\" value=\"" + this.GroupID + "\">";
	     					sPersonHtml += "		<a href=\"javascript: mobile_bizcard_selectGroupAction('" + this.GroupID + "')\"><span class=\"rd_chk\"></span>" + this.Groupname + "</a>";
	     					sPersonHtml += "</li>";
	     				} else if(shareType == "D"){
	     					sDeptHtml += "<li class=\"chk_item\" value=\"" + this.GroupID + "\">";
	     					sDeptHtml += "		<a href=\"javascript: mobile_bizcard_selectGroupAction('" + this.GroupID + "')\"><span class=\"rd_chk\"></span>" + this.Groupname + "</a>";
	     					sDeptHtml += "</li>";
	     				} else if(shareType == "U"){
	     					sUnitHtml += "<li class=\"chk_item\" value=\"" + this.GroupID + "\">";
	     					sUnitHtml += "		<a href=\"javascript: mobile_bizcard_selectGroupAction('" + this.GroupID + "')\"><span class=\"rd_chk\"></span>" + this.Groupname + "</a>";
	     					sUnitHtml += "</li>";
	     				} else if(shareType == "C"){
	     					sCompanyHtml += "<li class=\"chk_item\" value=\"" + this.GroupID + "\">";
	     					sCompanyHtml += "		<a href=\"javascript: mobile_bizcard_selectGroupAction('" + this.GroupID + "')\"><span class=\"rd_chk\"></span>" + this.Groupname + "</a>";
	     					sCompanyHtml += "</li>";
	     				}
	     				
	     			});		
				}
				
				$("#bizcard_select_checklistperson").html(sPersonHtml + "</ul>");
				$("#bizcard_select_checklistdept").html(sDeptHtml + "</ul>");
				$("#bizcard_select_checklistunit").html(sUnitHtml + "</ul>");
				$("#bizcard_select_checklistcompany").html(sCompanyHtml + "</ul>");
				
				//기존에 선택된 groupid 체크하기
				mobile_bizcard_bindGroupChecked();	
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
}

//기존에 선택된 groupid 체크하기
function mobile_bizcard_bindGroupChecked(){
	var sGroupID = _mobile_bizcard_list.GroupID.split(';');
	if(sGroupID.length > 1){
		sGroupID.forEach(function(target){
			$("li[value='" + target + "']").addClass("checked");
		});
	}
}

//그룹 선택 시, ui 처리
function mobile_bizcard_selectGroupAction(pGroupID){
	
	if(pGroupID == undefined){ //전체 선택
		if($("li.all_chk").hasClass("checked")){
			$("li:not(:has(>ul))").removeClass("checked");
		} else {
			$("li:not(:has(>ul))").addClass("checked");
		}
	} else { //개별 선택
		var oGroup = $("li[value='" + pGroupID + "']");
		if(oGroup.hasClass("checked")) {
			oGroup.removeClass("checked");
			$("li.all_chk").removeClass("checked");
		} else {
			oGroup.addClass("checked");
		}
	}
	
}

//선택한 폴더 목록 저장 후 이전 페이지로 돌아감
function mobile_bizcard_saveGroupSelected(){
	
	//값 초기화
	_mobile_bizcard_list.GroupID = "";
	
	//선택 목록 추출 및 값 바인딩
	$("#bizcard_select_checklist li.checked:not(.all_chk)").each(function() {
		if($(this).attr("value") != undefined){
			_mobile_bizcard_list.GroupID += $(this).attr("value") + ";";
		}
	});
	
	//세션에 저장
	localStorage.setItem("BizcardGroup_"+mobile_comm_getSession("UR_Code"), _mobile_bizcard_list.GroupID);
	
	//이전 페이지로 되돌아감
	mobile_comm_back();
	mobile_bizcard_getList(_mobile_bizcard_list);
}

//인명관리 - 그룹 선택 끝








/*!
 * 
 * 인명관리 - 작성
 * 
 */


var _mobile_bizcard_write = {
	
	BizCardID : '',			//수정시에 사용되는 ID값
	ViewType : '' 			//수정시에 사용되는 ViewType(개인-P/부서-D/회사-U/업체-C)

};


//작성 페이지 초기화
function mobile_bizcard_WriteInit(){
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('bizcardid','bizcard_write_page') != 'undefined') {
		_mobile_bizcard_write.BizCardID = mobile_comm_getQueryString('bizcardid','bizcard_write_page');
	} else {
		_mobile_bizcard_write.BizCardID = '';
	}
	if (mobile_comm_getQueryString('viewtype','bizcard_write_page') != 'undefined') {
		_mobile_bizcard_write.ViewType = mobile_comm_getQueryString('viewtype','bizcard_write_page');
	} else {
		_mobile_bizcard_write.ViewType = 'P';
	}
	
	// 전체보기/즐겨찾기에서 넘어온 경우 개인으로 일단 셋팅
	if(_mobile_bizcard_write.ViewType == "A" || _mobile_bizcard_write.ViewType == "F" ){
		_mobile_bizcard_write.ViewType = 'P';
	}
	
	// 2. Tab Display 설정
	$("div.tab_wrap").each(function(){
		$(this).children('.g_tab').find('li').first().addClass('on');
		$(this).children('.tab_cont_wrap').find('.tab_cont').first().addClass('on');
	});
	
	// 3. 유형별 그룹 바인딩
	if(_mobile_bizcard_write.ViewType == "C"){ //업체일 경우
		$("#bizcard_write_tabtype li[value=company] a").trigger('click');
		mobile_bizcard_changecompanytype();
	} else { //명함일 경우, 필요
		$('#bizcard_write_persontype a').each(function(){
			if($(this).attr("value") == _mobile_bizcard_write.ViewType) {
				$(this).addClass("on");
			}
		});
		_mobile_bizcard_write.ViewType = "P"; //P로 초기화
		mobile_bizcard_changepersontype($('#bizcard_write_persontype').find("a.on"));
		mobile_bizcard_changecompanytype();
	}
	
	// 4. 수정 모드일시, 값 바인딩
	if(_mobile_bizcard_write.BizCardID != ''){
		/*if(_mobile_bizcard_write.ViewType == "P") {
			$("#bizcard_write_tabtype > li[value='person']").show();
			$("#bizcard_write_tabtype > li[value='company']").hide();
		} else {
			$("#bizcard_write_tabtype > li[value='person']").hide();
			$("#bizcard_write_tabtype > li[value='company']").show();
		}*/
		
		mobile_bizcard_setModifyData();
	}
	
	// 5. datepicker
	$( ".input_date" ).attr('class', 'input_date').datepicker({
		dateFormat : 'yy/mm/dd',
		dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
	});

}

//수정 모드일시, 값 바인딩
function mobile_bizcard_setModifyData(){
	
	$("#bizcard_write_save").hide();
	$("#bizcard_write_modify").show();
	$("#bizcard_write_title").html(mobile_comm_getDic("btn_Modify"));
	
	if(_mobile_bizcard_write.ViewType == "P") {
		 $.ajaxSetup({
		      async: true
		 }); 
		 
		 $.ajax({
			url:'/groupware/mobile/bizcard/getBizCardPerson.do',
			type:"post",
			async:true,
			data:{
					"BizCardID":_mobile_bizcard_write.BizCardID
			},
			success:function (d) {
				d = d.person[0];
				if(d.ImagePath != "" && d.ImagePath != undefined) {
					$("#bizcard_write_divperson a[name='bizcard_write_img']").attr("style", "background-image:url('" + mobile_comm_getimg(mobile_comm_getBaseConfig("BackStorage").replace("{0}", mobile_comm_getSession("DN_Code"))+d.ImagePath) + "\');");
					$("#bizcard_write_divperson a[name='bizcard_write_img']").css("background-size", "cover");
				}
				$("#bizcard_write_personname").val(d.Name);
				$("#bizcard_write_persontype a").removeClass("on");
				$("#bizcard_write_persontype a[value="+ d.ShareType +"]").addClass("on");
				
				mobile_bizcard_changepersontype($('#bizcard_write_persontype a.on'));
				if($("#bizcard_write_persongroup option[value='" + d.GroupID + "']").length > 0) {
					$("#bizcard_write_persongroup").val(d.GroupID);
				} else {
					$("#bizcard_write_persongroup").val('none');
				}
				
				$("#bizcard_write_personanniversary").val(d.AnniversaryText);
				$("#bizcard_write_personmessenger").val(d.MessengerID);
				$("#bizcard_write_personcompany").attr('comID', d.CompanyId);
				$("#bizcard_write_personcompany").val(d.CompanyName);
				$("#bizcard_write_persondept").val(d.DeptName);
				$("#bizcard_write_personjobtitle").val(d.JobTitle);
				$("#bizcard_write_personmemo").val(mobile_comm_replaceAll(d.Memo, "&nbsp;", " ").replaceAll("<br />","\r\n"));
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizCardPerson.do', response, status, error);
			}
		});
		
		 $.ajax({
			url:'/groupware/mobile/bizcard/getBizCardPhone.do',
			type:"post",
			data:{
					"BizCardID":_mobile_bizcard_write.BizCardID,
					'TypeCode' : 'P'
			},
			async:false,
			success:function (d) {
				d.list.forEach(function(d) {
					var sHtml = "";
					var sPhoneType = d.PhoneType;
					var sPhoneTxt = d.PhoneNumber;
					
					sHtml += "<a id='" + sPhoneType + "_" + sPhoneTxt + "' onclick=\"javascript: mobile_bizcard_clickdellphone(this);\">";
					sHtml += "		<i class=\"" + (sPhoneType == "C" ? "ico_mobile" : "ico_phone") + "\"></i>" + sPhoneTxt; 
					sHtml += "</a>";

					$("#bizcard_write_divperson div[name=bizcard_write_phonelist]").append(sHtml);
					$("#bizcard_write_divperson div[name=bizcard_write_phonelist]").show();
				});
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizCardPhone.do', response, status, error);
			}
		});
		 
		 $.ajax({
			url:'/groupware/mobile/bizcard/getBizCardEmail.do',
			type:"post",
			data:{
					"BizCardID":_mobile_bizcard_write.BizCardID,
					'TypeCode' : 'P'
			},
			async:false,
			success:function (d) {
				d.list.forEach(function(d) {
					var sHtml = "";
					var sEmailTxt = d.Email;
					
					sHtml += "<a id='" + sEmailTxt + "' onclick=\"javascript: mobile_bizcard_clickdellemail(this);\">";
					sHtml += 		sEmailTxt; 
					sHtml += "</a>";
					
					$("#bizcard_write_divperson div[name=bizcard_write_emaillist]").append(sHtml);
					$("#bizcard_write_divperson div[name=bizcard_write_emaillist]").show();
				});
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizCardEmail.do', response, status, error);
			}
		});
		
	}
	else if(_mobile_bizcard_write.ViewType == "C") {
		$("#bizcard_write_tabtype li[value=company] a").trigger('click');
		
		 $.ajaxSetup({
		      async: true
		 }); 
		 
		 $.ajax({
				url:'/groupware/mobile/bizcard/getBizCardCompany.do',
				type:"post",
				data:{
						"BizCardID":_mobile_bizcard_write.BizCardID
				},
				async:true,
				success:function (d) {
					d = d.company[0];
					if(d.ImagePath != ""&& d.ImagePath != undefined) {
						$("#bizcard_write_divcompany a[name='bizcard_write_img']").attr("style", "background-image:url('" + mobile_comm_replaceAll(mobile_comm_getBaseConfig("BackStorage"), "{0}", mobile_comm_getSession("DN_Code")) + d.ImagePath + "\');");
						$("#bizcard_write_divcompany a[name='bizcard_write_img']").css("background-size", "cover");
					}
					$("#bizcard_write_companyname").val(d.ComName);
					$("#bizcard_write_companyrep").val(d.ComRepName);
					
					$("#bizcard_write_companygroup").val(d.GroupID == undefined || d.GroupID == "" ? 'none' : d.GroupID);
					
					$("#bizcard_write_companyanniversary").val(d.AnniversaryText);
					$("#bizcard_write_companywebsite").val(d.ComWebSite);
					$("#bizcard_write_companyzipcode").val(d.ComZipCode);
					$("#bizcard_write_companyaddress").val(d.ComAddress);
					$("#bizcard_write_companymemo").val(mobile_comm_replaceAll(d.Memo, "\\r\\n", "\r\n"));
				},
				error:function(response, status, error){
					mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizCardCompany.do', response, status, error);
				}
			});
		 
		$.ajax({
			url:'/groupware/mobile/bizcard/getBizCardPhone.do',
			type:"post",
			data:{
					"BizCardID":_mobile_bizcard_write.BizCardID,
					'TypeCode' : 'C'
			},
			async:false,
			success:function (d) {
				d.list.forEach(function(d) {
					var sHtml = "";
					var sPhoneType = d.PhoneType;
					var sPhoneTxt = d.PhoneNumber;
					
					sHtml += "<a id='" + sPhoneType + "_" + sPhoneTxt + "' onclick=\"javascript: mobile_bizcard_clickdellphone(this);\">";
					sHtml += "		<i class=\"" + (sPhoneType == "C" ? "ico_mobile" : "ico_phone") + "\"></i>" + sPhoneTxt; 
					sHtml += "</a>";

					$("#bizcard_write_divcompany li[name=bizcard_write_phonelist]").append(sHtml);
				});
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizCardPhone.do', response, status, error);
			}
		});
		
		$.ajax({
			url:'/groupware/mobile/bizcard/getBizCardEmail.do',
			type:"post",
			data:{
					"BizCardID":_mobile_bizcard_write.BizCardID,
					'TypeCode' : 'C'
			},
			async:false,
			success:function (d) {
				d.list.forEach(function(d) {
					var sHtml = "";
					var sEmailTxt = d.Email;
					
					sHtml += "<a id='" + sEmailTxt + "' onclick=\"javascript: mobile_bizcard_clickdellemail(this);\">";
					sHtml += 		sEmailTxt; 
					sHtml += "</a>";
					
					$("#bizcard_write_divcompany li[name=bizcard_write_emaillist]").append(sHtml);
				});
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizCardEmail.do', response, status, error);
			}
		});
		 
		if($("#bizcard_write_companygroup").val() == null) {
			$("#bizcard_write_companygroup").val("");
		}
	}
}


// 전화번호 추가
function mobile_bizcard_clickaddphone(obj){
	obj = $(obj).parent().parent();
	
	var sHtml = "";
	var sPhoneType = $(obj).find("select[name=bizcard_write_phonetype]").val();
	var sPhoneTxt = $(obj).find("input[name=bizcard_write_phonetxt]").val();
	var sPhoneName = $(obj).find("input[name=bizcard_write_phonename]").val();
	
	if(sPhoneTxt != ""){
		if(sPhoneType == "D") {
			sHtml += "<a id='" + sPhoneType + "_" + "(" + sPhoneName + ") " + sPhoneTxt + "' onclick=\"javascript: mobile_bizcard_clickdellphone(this);\" style=\"background: none !important;\">";
		} else {
			sHtml += "<a id='" + sPhoneType + "_" + sPhoneTxt + "' onclick=\"javascript: mobile_bizcard_clickdellphone(this);\" style=\"background: none !important;\">";
		}
		
		if(sPhoneType == "D") {
			sHtml += "		<i class=\"" + (sPhoneType == "C" ? "ico_mobile" : "ico_phone") + "\"></i>" + "(" + sPhoneName + ") " + sPhoneTxt;
		} else {
			sHtml += "		<i class=\"" + (sPhoneType == "C" ? "ico_mobile" : "ico_phone") + "\"></i>" + sPhoneTxt;
		}
		
		sHtml += "</a>";

		$(obj).find("div[name=bizcard_write_phonelist]").append(sHtml);
		$(obj).find("input[name=bizcard_write_phonetxt]").val('');
		$(obj).find("input[name=bizcard_write_phonename]").val('');
		$(obj).find("div[name=bizcard_write_phonelist]").show();
	}
	
}

//전화번호 삭제
function mobile_bizcard_clickdellphone(obj){
	$(obj).remove();
	if($(obj).parent().parent().find("div[name=bizcard_write_emaillist]").html() == "") {
		$(obj).parent().parent().find("div[name=bizcard_write_emaillist]").hide();
	}
}

//이메일 추가
function mobile_bizcard_clickaddemail(obj){
	
	obj = $(obj).parent().parent();
	
	var sHtml = "";
	var sEmailTxt = $(obj).find("input[name=bizcard_write_emailtxt]").val();
	
	if(sEmailTxt != ""){
		sHtml += "<a id='" + sEmailTxt + "' onclick=\"javascript: mobile_bizcard_clickdellemail(this);\" style=\"background: none !important;\">";
		sHtml += 		sEmailTxt; 
		sHtml += "</a>";
		
		$(obj).find("div[name=bizcard_write_emaillist]").append(sHtml);
		$(obj).find("input[name=bizcard_write_emailtxt]").val('');
		$(obj).find("div[name=bizcard_write_emaillist]").show();
	}
	
}

//이메일 삭제
function mobile_bizcard_clickdellemail(obj){
	$(obj).remove();
	if($(obj).parent().parent().find("div[name=bizcard_write_emaillist]").html() == "") {
		$(obj).parent().parent().find("div[name=bizcard_write_emaillist]").hide();
	}
}

//유형 변경시 그룹 바인딩
function mobile_bizcard_changepersontype(obj) {
	
	$("#bizcard_write_persontype").find("a").removeClass("on");
	$(obj).addClass("on");
	
	$("#bizcard_write_persongroup").find("option").remove();
	$("#bizcard_write_persongroup").append('<option value="none">' + mobile_comm_getDic("lbl_NoGroup") + '</option>'); //그룹 없음
	$("#bizcard_write_persongroup").append('<option value="new">' + mobile_comm_getDic("lbl_newGroup") + '</option>'); //새 그룹
	
	$('#bizcard_write_persongroupname').val('').attr("disabled", "disabled");
	//bizcard_write_persongroupname
	
	var url = "/groupware/mobile/bizcard/getGroupList.do";
	var ShareType = $(obj).attr("value");
	$.ajax({
		url: url,
		data: {ShareType : ShareType},
		async: false,
		type: "post",
		success: function (response) {
			if(response.status == "SUCCESS") {
				if(response.list.length > 0){
	     			$(response.list).each(function(){
	     				$("#bizcard_write_persongroup").append('<option value="' + this.GroupID + '">' + this.GroupName + '</option>');
	     			});		
				}
			}
		}, error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
}

//업체 그룹 바인딩
function mobile_bizcard_changecompanytype(obj) {
	var ShareType = 'C';
	
	$("#bizcard_write_companygroup").find("option").remove();
	$("#bizcard_write_companygroup").append('<option value="new">' + mobile_comm_getDic("lbl_newGroup") + '</option>'); //새 그룹
	$("#bizcard_write_companygroup").append('<option value="none">' + mobile_comm_getDic("lbl_NoGroup") + '</option>'); //그룹 없음
	
	$.ajaxSetup({
	     async: true
	});

	var url = "/groupware/mobile/bizcard/getGroupList.do";
	$.ajax({
		url: url,
		data: {ShareType : ShareType},
		type: "post",
		success: function (response) {
			if(response.status == "SUCCESS") {
				if(response.list.length > 0){
	     			$(response.list).each(function(){
	     				$("#bizcard_write_companygroup").append('<option value="' + this.GroupID + '">' + this.GroupName + '</option>');
	     			});		
				}
			}
		}, error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
}

function mobile_bizcard_changegroup(obj) {
	var target = "#" + $(obj).attr("id") + "name";
	if($(obj).val() == "new") {
		$(target).removeAttr("disabled");
	} else {
		$(target).attr("disabled", "disabled");
	}
}

//이미지 변경 시, 처리 작업
function mobile_bizcard_changeimage(obj) {
	var ext = $(obj).val().split('.').pop().toLowerCase();
	if($.inArray(ext, ['gif','png','jpg','jpeg']) == -1) {
		alert(mobile_comm_getDic('msg_bizcard_onlyUploadJPGFiles')); //jpg, jpeg, png, gif 파일만 업로드 할수 있습니다.	
		return;
	}
	mobile_bizcard_setThumbnail($(obj) ,$(obj).closest("a[name='bizcard_write_img']"));
}

//섬네일 이미지 설정
function mobile_bizcard_setThumbnail(html, target) {
    if (html[0].files && html[0].files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
        	$(target).attr("style", "background-image:url('" + e.target.result + "\');");
            $(target).css("background-size", "cover");
        }
        reader.readAsDataURL(html[0].files[0]);
       // $(html).siblings('input[type=text]').val(html[0].value);
        //"C:\fakepath\8a7b31dcd69b9cbfcd199bb5bdb39c69.png"
    }
}

//수정
function mobile_bizcard_modify(){
	mobile_bizcard_save();
}

//저장
function mobile_bizcard_save(){
	
	var TypeCode = "";
	if($("#bizcard_write_tabtype li.on").attr('value') == "person"){
		TypeCode = "P";
	} else {
		TypeCode = "C";
	}
	
	var bReturn = mobile_bizcard_checkValidation(TypeCode);
    if(!bReturn) return false;
	
	$.ajaxSetup({
	     async: true
	});

	var PhoneType = "";
	var PhoneNumber = "";
	var Email = "";
	var formData;
	var url = "";
	
	if(TypeCode == "P") {
		$("#bizcard_write_divperson div[name=bizcard_write_phonelist] a").each(function(i){
			var phoneInfo = $(this).attr("id").split("_");
			PhoneType += phoneInfo[0] + ";";
			PhoneNumber += phoneInfo[1] + ";";
		});
		
		if($("input[name=bizcard_write_phonetxt]").val() != ''){ // 입력창에 남아있는 연락처 정보 추가
			PhoneType += $("#selPhoneType").val() + ";";
			PhoneNumber += $("input[name=bizcard_write_phonetxt]").val()  + ";";
		}
		
		$("#bizcard_write_divperson div[name=bizcard_write_emaillist] a").each(function(i){
			Email += $(this).attr("id") + ";";
		});

		if($("input[name=bizcard_write_emailtxt]").val() != ''){ // 입력창에 남아있는 이메일 정보 추가
			Email +=$("input[name=bizcard_write_emailtxt]").val() + ";";
		}
		
		formData = new FormData();
		
		formData.append("TypeCode", TypeCode);
		formData.append("ShareType", $("#bizcard_write_persontype a.on").attr("value"));
		formData.append("GroupID", $("#bizcard_write_persongroup").val() == "none" ? "" : $("#bizcard_write_persongroup").val() );
		formData.append("GroupName", $("#bizcard_write_persongroupname").val());
		formData.append("Name", $("#bizcard_write_personname").val());
		formData.append("MessengerID", $("#bizcard_write_personmessenger").val());
		formData.append("CompanyID", $("#bizcard_write_personcompany").attr("comID"));
		formData.append("CompanyName", $("#bizcard_write_personcompany").val());
		formData.append("DeptName", $("#bizcard_write_persondept").val());
		formData.append("JobTitle", $("#bizcard_write_personjobtitle").val());
		formData.append("Memo", $("#bizcard_write_personmemo").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />'));
		formData.append("ImagePath", $("#bizcard_write_divperson input[name=addFile]").val());
		formData.append("FileInfo", $("#bizcard_write_divperson input[name=addFile]")[0].files[0]);
		formData.append("PhoneType", PhoneType.slice(0, -1));
		formData.append("PhoneNumber", PhoneNumber.slice(0, -1));
		formData.append("Email", Email.slice(0, -1));
		formData.append("AnniversaryText", $("#bizcard_write_personanniversary").val());				
		
		url = "/groupware/mobile/bizcard/RegistBizCardPerson.do";
		if(_mobile_bizcard_write.BizCardID != '') {
			url = "/groupware/mobile/bizcard/ModifyBizCardPerson.do";
			
			formData.append("BizCardID", _mobile_bizcard_write.BizCardID);
		}
	} else if(TypeCode == "C") {
		$("#bizcard_write_divcompany li[name=bizcard_write_phonelist] a").each(function(i){
			var phoneInfo = $(this).attr("id").split("_");
			PhoneType += phoneInfo[0] + ";";
			PhoneNumber += phoneInfo[1] + ";";
		});
		$("#bizcard_write_divcompany li[name=bizcard_write_emaillist] a").each(function(i){
			Email += $(this).attr("id") + ";";
		});
		
		formData = new FormData();
		
		formData.append("TypeCode", TypeCode);
		formData.append("GroupID", ($("#bizcard_write_companygroup").val() == "none" || $("#bizcard_write_companygroup").val() == null) ? "" : $("#bizcard_write_companygroup").val() );
		formData.append("GroupName", $("#bizcard_write_companygroupname").val());
		formData.append("ComName", $("#bizcard_write_companyname").val());
		formData.append("ComRepName", $("#bizcard_write_companyrep").val());
		formData.append("ComWebsite", $("#bizcard_write_companywebsite").val());
		formData.append("ComZipCode", $("#bizcard_write_companyzipcode").val());
		formData.append("ComAddress", $("#bizcard_write_companyaddress").val() + $("#bizcard_write_companyaddressfull").val());
		formData.append("Memo", $("#bizcard_write_companymemo").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />'));
		formData.append("ImagePath", $("#bizcard_write_divcompany input[name=addFile]").val());
		formData.append("FileInfo", $("#bizcard_write_divcompany input[name=addFile]")[0].files[0]);
		formData.append("PhoneType", PhoneType.slice(0, -1));
		formData.append("PhoneNumber", PhoneNumber.slice(0, -1));
		formData.append("Email", Email.slice(0, -1));
		formData.append("AnniversaryText", $("#bizcard_write_companyanniversary").val());			
		
		url = "/groupware/mobile/bizcard/RegistBizCardCompany.do";
		if(_mobile_bizcard_write.BizCardID != '') {
			url = "/groupware/mobile/bizcard/ModifyBizCardCompany.do";
			
			formData.append("BizCardID", _mobile_bizcard_write.BizCardID);
		}
	}
	
	$.ajax({
		url : url,
		type : "POST",
		data : formData,
		dataType : 'json',
        processData : false,
        contentType : false,
		success : function(d) {
			try {
				if(d.result == "OK") {
					mobile_comm_back();
					// 저장 후 조회 창도 닫기(수정시)
					if(_mobile_bizcard_write.BizCardID != "") {
						setTimeout("mobile_comm_back()", 1000);	
					}
					setTimeout("mobile_bizcard_clickrefresh()", 1200);
					
				} else if(d.result == "FAIL") {
					alert(mobile_comm_getDic("msg_ErrorRegistBizCard")); //연락처 등록 오류가 발생했습니다.
				}
			} catch(e) {
				mobile_comm_log(e);
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//유효성 검사
function mobile_bizcard_checkValidation(TypeCode) {
	var bReturn = true;
	var type = (TypeCode == "P" ? "person" : "company");
	var array = "";
	var array1 = "";
	
	var l_HtmlCheckValue = false;
	var l_ScriptCheckValue = false;
	var l_oTarget;
	
	// Html 태그 입력 불가
	$(".HtmlCheckXSS").each(function () {
		if (!l_HtmlCheckValue) {
			if (XFN_CheckHTMLinText($(this).val())) {
				l_HtmlCheckValue = true;
				l_oTarget = $(this);
			}
		}
	});
	
	// <script>, <style> 입력 불가
	if (!l_HtmlCheckValue) {
		$(".ScriptCheckXSS").each(function () {
			if (!l_ScriptCheckValue) {
				if (XFN_CheckInputLimit($(this).val())) {
					l_ScriptCheckValue = true;
					l_oTarget = $(this);
				}
			}
		});
	}

	// <script> 입력 불가
	if (!l_HtmlCheckValue) {
		$(".ScriptCheckXSSOnlyScript").each(function () {
			if (!l_ScriptCheckValue) {
				if (XFN_CheckInputLimitOnlyScript($(this).val())) {
					l_ScriptCheckValue = true;
					l_oTarget = $(this);
				}
			}
		});
	}
	
	// 메시지 반환
	if (l_ScriptCheckValue || l_HtmlCheckValue) {
		var l_WarningMsg = "";		
		
		// 히든 필드에 입력 불가 값 존재로 Focus 넘길 수 없음
		if ($(l_oTarget).attr("type") == "hidden" || $(l_oTarget).css("display") == "none") {
			if (l_ScriptCheckValue) { // 스크립트 입력불가
				l_WarningMsg = mobile_comm_getDic("msg_ThisPageLimitedScript");
			} else {  // HTML 테그 입력 불가
				l_WarningMsg = mobile_comm_getDic("msg_ThisPageLimitedHTMLTag");
			}
			
			alert(l_WarningMsg, "", function() {
		        $(l_oTarget).focus();
	        });

			return false;
		} else {
			if (l_ScriptCheckValue) { // 스크립트 입력불가
				l_WarningMsg = mobile_comm_getDic("msg_ThisPageLimitedScript");
			} else {  // HTML 테그 입력 불가
				l_WarningMsg = mobile_comm_getDic("msg_ThisPageLimitedHTMLTag");
			}
			
			alert(l_WarningMsg, "", function() {
		        $(l_oTarget).focus();
	        });

			return false;
		}
	}
	
    if (TypeCode == "P" && $("#bizcard_write_personname").val() == "") {
        alert(mobile_comm_getDic("msg_EnterName"), "", function() {
	        $("#bizcard_write_personname").focus();
        }); //이름을 입력하세요
        bReturn = false;

	/*    
	} else if (TypeCode == "C" && $("#bizcard_write_companyname").val() == "") {
        alert(mobile_comm_getDic("msg_EnterCompName"), "", function() {
	        $("#bizcard_write_companyname").focus();
        }); //회사명을 입력하세요
        bReturn = false;
    } else if (TypeCode == "C" && $("#bizcard_write_companyrep").val() == "") {
        alert(mobile_comm_getDic("msg_EnterRepName"), "", function() {
	        $("#bizcard_write_companyrep").focus();
        }); //대표자명을 입력하세요
        bReturn = false;
	*/

    } else if (TypeCode == "P" && $("#bizcard_write_persontype a.on").attr("value") == "") {
        alert(mobile_comm_getDic("msg_SelectDivision"), "", function() {
	        $("#bizcard_write_persontype").focus();
        }); //분류를 지정하세요
        bReturn = false;
    } else if($("#bizcard_write_" + type + "group").val() == "new" && $("#bizcard_write_" + type + "groupname").val() == "") {
    	alert(mobile_comm_getDic("msg_EnterNewGroupName"), "", function() {
    		$("#bizcard_write_" + type + "groupname").focus();
    	}); //새 그룹명을 입력하세요
        bReturn = false;
    } else if($("#bizcard_write_" + type + "group").val() == "") {
    	alert(mobile_comm_getDic("msg_SelectGroup"), "", function() {
    		$("#bizcard_write_" + type + "group").focus();
    	}); //그룹을 선택하세요
        bReturn = false;
    } else { 
    	if(bReturn == true) {
    		$("#bizcard_write_div" + type + " div[name=bizcard_write_emaillist] a").each(function(i) {
				//이메일 형식 체크
				var regex=/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/;
				if(regex.test($(this).attr('id')) === false) {  
				    alert(mobile_comm_getDic("msg_bizcard_invalidEmailFormat"));  //잘못된 이메일 형식입니다.
				    bReturn = false;
				}
	    	});
	    }
    }
    
    return bReturn;
}

//html 태그 및 스크립트 방지
function XFN_CheckHTMLinText(pValue) {
    var newPValue = pValue.replace(/<[^<가-힣]+?>/gi, '');
    if (pValue != newPValue) {
        //pValue = newPValue;
        return true;
    }
    else {
        return false;
    }
}

//문자열 중에 스크립트가 있는지 체크하는 함수 ex) "<script>aa </script>" 있는지 체크함.
function XFN_CheckInputLimit(pValue) {
    var rx =/<\s*script.+?<\/\s*script\s*>/gi;
    if (pValue.match(rx)) {
        return true;
    } else {
        rx = /<\s*style.+?<\/\s*style\s*>/gi;
        if (pValue.match(rx)) {
            return true;
        } else {
            return false;
        }
    }
}

//문자열 중에 스크립트가 있는지 스크립트만 체크하는 함수 ex) "<script>aa </script>" 있는지 체크함.
function XFN_CheckInputLimitOnlyScript(pValue) {
    var rx = /<\s*script.+?<\/\s*script\s*>/gi;
    if (pValue.match(rx)) {
        return true;
    } else {
        return false;
    }
}

//업체 선택
function mobile_bizcard_selectcompany(){
	var sUrl = "/groupware/mobile/bizcard/companylist.do";
	sessionStorage.setItem('isselectmode', true);
	
	mobile_comm_go(sUrl, 'Y');
}

//우편번호 선택
function mobile_bizcard_selectzipcode(){
	var sUrl = "/groupware/mobile/bizcard/zipcode.do";
	sessionStorage.setItem('isselectmode', true);
	
	mobile_comm_go(sUrl, 'Y');
}

//아코디언 메뉴
function mobile_bizcard_clickAccLink(pObj){
	if($(pObj).hasClass('show')){
		$(pObj).removeClass('show');
	}else{
		$(pObj).addClass('show');
	} 	
}

//탭 이동
function mobile_bizcard_clickTabWrap(pObj){
	var target = $(pObj).parent().index();
	
	$(pObj).parent().siblings().removeClass('on');
	$(pObj).parent().addClass('on');
	$(pObj).parent().parent().siblings('.tab_cont_wrap').children('.tab_cont').removeClass('on');
	$(pObj).parent().parent().siblings('.tab_cont_wrap').children('.tab_cont').eq(target).addClass('on');
	
}

//인명관리 - 작성 끝









/*!
 * 
 * 인명관리 - 상세보기
 * 
 */


var _mobile_bizcard_view = {
	
	BizCardID : '',			//수정시에 사용되는 ID값
	ViewType : '' 			//수정시에 사용되는 ViewType(개인-P/부서-D/회사-U/업체-C)

};


//상세보기 페이지 초기화
function mobile_bizcard_ViewInit(){
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('bizcardid','bizcard_view_page') != 'undefined') {
		_mobile_bizcard_view.BizCardID = mobile_comm_getQueryString('bizcardid','bizcard_view_page');
	} else {
		_mobile_bizcard_view.BizCardID = '';
	}
	if (mobile_comm_getQueryString('viewtype','bizcard_view_page') != 'undefined') {
		_mobile_bizcard_view.ViewType = mobile_comm_getQueryString('viewtype','bizcard_view_page');
	} else {
		_mobile_bizcard_view.ViewType = 'P';
	}
	
	//2. 유형별 display 세팅
	if(_mobile_bizcard_view.ViewType == 'P'){
		$("#bizcard_view_divperson").show();
	} else {
		$("#bizcard_view_divcompany").show();
	}
	
	// 3. 데이터 조회
	mobile_bizcard_getBizcardViewData();
	
	// 4. 버튼 세팅(수정/삭제)
	var sUrl = "/groupware/mobile/bizcard/write.do";
	sUrl += "?bizcardid=" + _mobile_bizcard_view.BizCardID;
	sUrl += "&viewtype=" + mobile_comm_getQueryString('viewtype','bizcard_view_page'); //view에서는 P/C 값만 사용하여, url에서 가져오도록 함
	$("#bizcard_view_modify").attr("href", "javascript: mobile_comm_go('" + sUrl + "','Y');");
	$("#bizcard_view_delete").attr("href", "javascript: mobile_bizcard_clickdelete('" + _mobile_bizcard_view.BizCardID + "', '" + _mobile_bizcard_view.ViewType + "');");
	if(_mobile_bizcard_view.ViewType != "G") {
		$("#bizcard_view_modify").show();
	} else {
		$("#bizcard_view_title").html("그룹정보 조회");
	}
	$("#bizcard_view_delete").show();
}

//명함 상세보기 데이터 조회
function mobile_bizcard_getBizcardViewData(){
	
	var sProfile = "";
	var sProImage = "";

	var userLoaded =  $.Deferred();
	if(_mobile_bizcard_view.ViewType == "P") {
		 $.ajaxSetup({
		      async: true
		 }); 
		 
		 $.ajax({
			url:'/groupware/mobile/bizcard/getBizCardPerson.do',
			type:"post",
			data:{
					"BizCardID":_mobile_bizcard_view.BizCardID
			},
			success:function (d) {
				d = d.person[0];
				
				sProImage += "<img style=\"width: 100%; height: 100%;\" onerror='this.src=\"" + mobile_comm_noperson() + "\"' src=\"" + mobile_comm_getimg(mobile_comm_getBaseConfig("BackStorage").replace("{0}", mobile_comm_getSession("DN_Code"))+d.ImagePath) + "\">"
				
				sProfile += "<p class=\"name\">";
				sProfile += 	d.Name;
				sProfile += "	<span class=\"sm\">";
				sProfile += 		d.JobTitle;
				sProfile += "	</span>";
				sProfile += "</p>";
				sProfile += "<p class=\"company\">";
				if(d.CompanyName != undefined && d.CompanyName !=""){
					sProfile += "<span>" + d.CompanyName + "</span>";
				}
				if(d.DeptName != undefined && d.DeptName !=""){
					sProfile += "	<span>" + d.DeptName + "</span>";
				}
				sProfile += "</p>";
				$("#bizcard_view_personimg").html(sProImage);
				$("#bizcard_view_personprofile").html(sProfile);
				$("#bizcard_view_personanniversary dd").remove();
				$("#bizcard_view_personanniversary").append("<dd>" + (d.AnniversaryText == undefined ? "" : d.AnniversaryText) + "</dd>");
				$("#bizcard_view_personmessenger dd").remove();
				$("#bizcard_view_personmessenger").append("<dd>" + (d.MessengerID == undefined ? "" : d.MessengerID)  + "</dd>");
				$("#bizcard_view_personmemo p").text(mobile_comm_replaceAll(d.Memo, "&nbsp;", " ").replaceAll("<br />","\r\n"));
				userLoaded.resolve(d.Name);
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizCardPerson.do', response, status, error);
			}
		});
		
		 $.ajax({
			url:'/groupware/mobile/bizcard/getBizCardPhone.do',
			type:"post",
			data:{
					"BizCardID":_mobile_bizcard_view.BizCardID,
					'TypeCode' : 'P'
			},
			async:false,
			success:function (d) {
				var sPhoneMobile = "<dd>";
				var sPhoneOffice = "<dd>";
				var sPhoneFax = "<dd>";
				var sPhoneEtc = "<dd>";				
				var sPhoneHome = "<dd>";
				var sPhoneDirect = "<dd>";
				
				$("#bizcard_view_personphonemobile dd").remove();
				$("#bizcard_view_personphoneoffice dd").remove();
				$("#bizcard_view_personphonefax dd").remove();
				$("#bizcard_view_personphoneetc dd").remove();
				$("#bizcard_view_personphonehome dd").remove();
				$("#bizcard_view_personphonedirect dd").remove();
				
				d.list.forEach(function(d) {
					if(d.PhoneType == "C"){ 		//핸드폰
						sPhoneMobile += "<a href='tel:"+d.PhoneNumber+"'>"+d.PhoneNumber + "</a><br>";
					} else if (d.PhoneType == "T"){ //사무실전화
						sPhoneOffice +=  "<a href='tel:"+d.PhoneNumber+"'>"+d.PhoneNumber + "</a><br>";
					} else if (d.PhoneType == "F"){ //사무실팩스
						sPhoneFax +=  "<a href='tel:"+d.PhoneNumber+"'>"+d.PhoneNumber + "</a><br>";
					} else if (d.PhoneType == "E"){ //기타
						sPhoneEtc +=  "<a href='tel:"+d.PhoneNumber+"'>"+d.PhoneNumber + "</a><br>";
					} else if (d.PhoneType == "H"){ //자택전화
						sPhoneHome +=  "<a href='tel:"+d.PhoneNumber+"'>"+d.PhoneNumber + "</a><br>";
					} else if (d.PhoneType == "D"){ //직접입력
						sPhoneDirect +=  "<a href='tel:"+d.PhoneNumber+"'>"+d.PhoneNumber + "</a><br>";
					}
				});
				
				sPhoneMobile += "</dd>";
				sPhoneOffice += "</dd>";
				sPhoneFax += "</dd>";
				sPhoneEtc += "</dd>";				
				sPhoneHome += "</dd>";
				sPhoneDirect += "</dd>";
				
				$("#bizcard_view_personphonemobile").append(sPhoneMobile);
				$("#bizcard_view_personphoneoffice").append(sPhoneOffice);
				$("#bizcard_view_personphonefax").append(sPhoneFax);
				$("#bizcard_view_personphoneetc").append(sPhoneEtc);
				$("#bizcard_view_personphonehome").append(sPhoneHome);
				$("#bizcard_view_personphonedirect").append(sPhoneDirect);
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizCardPhone.do', response, status, error);
			}
		});
		 
		 $.ajax({
			url:'/groupware/mobile/bizcard/getBizCardEmail.do',
			type:"post",
			data:{
					"BizCardID":_mobile_bizcard_view.BizCardID,
					'TypeCode' : 'P'
			},
			async:false,
			success:function (d) {
				var sEmail = "<dd>";
				$("#bizcard_view_personemail dd").remove();
				userLoaded.then(function (userName) {
					d.list.forEach(function(d) {
						if(mobile_comm_getBaseConfig("isUseMail") == "Y"){
							sEmail += "<a href=\"javascript:mobile_org_sendmail('"+d.Email+"','"+userName+"');\">"+ d.Email + "</a><br>";
						}else{
							sEmail += "<a href=mailto:"+d.Email+">"+ d.Email + "</a><br>";
						}
					});
					sEmail += "	</dd>";
					$("#bizcard_view_personemail").append(sEmail);
				 });
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizCardEmail.do', response, status, error);
			}
		});
		
	}
	else if(_mobile_bizcard_view.ViewType == "C") {
		$("#bizcard_write_tabtype li[value=company] a").trigger('click');
		
		 $.ajaxSetup({
		      async: true
		 }); 
		 
		 $.ajax({
				url:'/groupware/mobile/bizcard/getBizCardCompany.do',
				type:"post",
				data:{
						"BizCardID":_mobile_bizcard_view.BizCardID
				},
				async:false,
				success:function (d) {
					d = d.company[0];
					
					if(d.ImagePath != "" && d.ImagePath != undefined) {
						sImgUrl = mobile_comm_replaceAll(mobile_comm_getBaseConfig("BackStorage"), "{0}", mobile_comm_getSession("DN_Code")) + d.ImagePath;
					}
					$("#bizcard_view_companyimg").attr("style", "background-image:url('" + sImgUrl + "\');");
					$("#bizcard_view_companyimg").css("background-size", "cover");
					
					sProfile += "<p class=\"name\">";
					sProfile += 	d.ComName;
					sProfile += "</p>";
					sProfile += "<p class=\"ceo_name\">";
					if(d.ComRepName != undefined && d.ComRepName != ""){
						sProfile += "	" + mobile_comm_getDic("lbl_Ceo") + ": " + d.ComRepName; //대표
					}
					sProfile += "</p>";
					sProfile += "<p class=\"name\">";
					if(d.ComAddress != undefined && d.ComAddress != ""){
						sProfile += "<span style=\"overflow-x: scroll; white-space: nowrap;\">";
						sProfile += 	d.ComAddress;
						sProfile += "</span>";
					}
					sProfile += "</p>";
					$("#bizcard_view_companyprofile").html(sProfile);
					
					$("#bizcard_view_companyanniversary").append("<dd>" + (d.AnniversaryText == undefined ? "" : d.AnniversaryText) + "</dd>");
					$("#bizcard_view_companyhomepage").append("<dd><a href='" + d.ComWebSite + "' target='_blank'>" + (d.ComWebSite == undefined ? "" : d.ComWebSite)  + "</a></dd>");
					$("#bizcard_view_companymemo p").text(mobile_comm_replaceAll(d.Memo, "\\r\\n", "\r\n"));
				},
				error:function(response, status, error){
					mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizCardCompany.do', response, status, error);
				}
			});
		 
		$.ajax({
			url:'/groupware/mobile/bizcard/getBizCardPhone.do',
			type:"post",
			data:{
					"BizCardID":_mobile_bizcard_view.BizCardID,
					'TypeCode' : 'C'
			},
			async:false,
			success:function (d) {
				var sPhoneOffice = "<dd>";
				var sPhoneFax = "<dd>";
				
				d.list.forEach(function(d) {
					if(d.PhoneType == "T"){ //사무실
						sPhoneOffice += d.PhoneNumber + "<br>";
					} else if (d.PhoneType == "F"){ //Fax
						sPhoneFax += d.PhoneNumber + "<br>";
					} 
				});
				
				sPhoneOffice += "</dd>";
				sPhoneFax += "</dd>";
				$("#bizcard_view_companyphoneoffice").append(sPhoneOffice);
				$("#bizcard_view_companyphonefax").append(sPhoneFax);
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizCardPhone.do', response, status, error);
			}
		});
		
		$.ajax({
			url:'/groupware/mobile/bizcard/getBizCardEmail.do',
			type:"post",
			data:{
					"BizCardID":_mobile_bizcard_view.BizCardID,
					'TypeCode' : 'C'
			},
			async:false,
			success:function (d) {
				var sEmail = "<dd>";
				d.list.forEach(function(d) {
					sEmail += 			d.Email + "<br>";
				});
				sEmail += "	</dd>";
				$("#bizcard_view_companyemail").append(sEmail);
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizCardEmail.do', response, status, error);
			}
		});
		 
		if($("#bizcard_write_companygroup").val() == null) {
			$("#bizcard_write_companygroup").val("");
		}
	// 그룹정보 조회
	} else if(_mobile_bizcard_view.ViewType == "G") {
		 $.ajaxSetup({
		      async: true
		 }); 
		 
		 $.ajax({
				url:'/groupware/mobile/bizcard/getBizcardGroup.do',
				type:"post",
				data:{
						"GroupID":_mobile_bizcard_view.BizCardID,
						"ShareType": "A"
				},
				async:false,
				success:function (d) {
					var list = d.list[0];
					var bizCardList = d.bizcardlist;
					var sProfile = "";
					
					$("#bizcard_view_companyimg").attr("style", "background-image:url('/covicore/resources/images/common/noGroupImg.png');");
					$("#bizcard_view_companyimg").css("background-size", "cover");
					
					sProfile += "<p class=\"name\">";
					sProfile += list.GroupName;
					sProfile += " <br />(";
					switch(list.ShareType) {
	               	  case 'P' : sProfile += mobile_comm_getDic("lbl_ShareType_Personal"); break; //개인
	               	  case 'D' : sProfile += mobile_comm_getDic("lbl_ShareType_Dept"); break; //부서
	               	  case 'U' : sProfile += mobile_comm_getDic("lbl_ShareType_Comp"); break; //회사
					}
	               	sProfile += ")";
					sProfile += "</p>";
					$("#bizcard_view_companyprofile").html(sProfile);
					// 맴버 목록
					var strMemberList = "";
					var len = bizCardList.length;
					for (var i = 0; i < len; i++) {
						strMemberList += "<dl> "+ bizCardList[i].Name + "(" + bizCardList[i].Email+ ")</dl>";
					}
					$("#bizcard_view_groupMemberList").html(strMemberList);
				},
				error:function(response, status, error){
					mobile_comm_ajaxerror('/groupware/mobile/bizcard/getBizcardGroup.do', response, status, error);
				}
			});
		 
		
		 
		if($("#bizcard_write_companygroup").val() == null) {
			$("#bizcard_write_companygroup").val("");
		}
	}
	
}

//연락처 삭제
function mobile_bizcard_clickdelete(pBizID, pBizType) {
	
	if(confirm(mobile_comm_getDic("msg_bizcard_deleteContact"))){ //해당 연락처 정보를 삭제하시겠습니까?
		var sUrl = "/groupware/mobile/bizcard/DeleteBizCard.do";
		// 그룹 삭제
		if(pBizType == "G") {
			sUrl = "/groupware/bizcard/deleteBizCardAllList.do";
			$.ajaxSetup({
			     async: true
			});
			$.ajax({
				url : sUrl,
				type : "POST",
				data : {
					"BizCardID" :  pBizID,
					"TypeCode" :  "A",
					"BizCardTypeCode" :  "Group"
				},
				success : function(d) {
					mobile_comm_back();
					mobile_bizcard_clickrefresh();
				},
				error:function(response, status, error){
					mobile_comm_ajaxerror(sUrl, response, status, error);
				}
			});
		// 비즈카드 삭제
		} else {
			$.ajaxSetup({
			     async: true
			});
			$.ajax({
				url : sUrl,
				type : "POST",
				data : {
					"BizCardID" :  pBizID,
					"TypeCode" :  pBizType
				},
				success : function(d) {
					mobile_comm_back();
					mobile_bizcard_clickrefresh();
				},
				error:function(response, status, error){
					mobile_comm_ajaxerror(sUrl, response, status, error);
				}
			});
		}
		
	}
}

//확장메뉴 show or hide
function mobile_bizcard_showORhide(obj) {
	if($(obj).parent().hasClass("show")) {
		$(obj).parent().removeClass("show");
	} else {
		$(obj).parent().addClass("show");
	}
}

//인명관리 - 상세보기 끝













/*!
 * 
 * 인명관리 - 우편번호
 * 
 */

var _mobile_bizcard_zipcode = {
		
		callback : '',
		
		CurrentPage : 0,		//현재 페이지
		TotalCount : 0,		//총 개수
		SearchKey : ""			//검색어
};

function mobile_bizcard_ZipcodeInit(){
	// 1. 변수 및 파라미터 초기화
	_mobile_bizcard_zipcode.CurrentPage = 0;
	_mobile_bizcard_zipcode.TotalCount = 0;
	_mobile_bizcard_zipcode.SearchKey = "1"; //최초 검색값을 입력하지 않으면 에러남
	if (sessionStorage.getItem('isselectmode') != null && sessionStorage.getItem('isselectmode') == "true" ) {
		_mobile_bizcard_list.IsSelectMode =true;
	} else {
		_mobile_bizcard_list.IsSelectMode = false;
	}
	
	// 2. 선택 모드일시, css 조절
	if (_mobile_bizcard_list.IsSelectMode == true){
		//상단에 close 버튼 생기는 부분 방지
		$("div.sub_header").siblings("a.ui-icon-delete").remove();
	}
	
	// 3. 데이터 조회 및 그리기
	mobile_bizcard_getZipCodeApi();
	
}

//주소 데이터 가져오기
function mobile_bizcard_getZipCodeApi(){
	
	var sUrl = "/groupware/mobile/bizcard/getAddrAPI.do";
	$.ajax({
		url : sUrl,
		type : "post",
		data : {
			currentPage : _mobile_bizcard_zipcode.CurrentPage,
			countPerPage : "10",
			keyword : _mobile_bizcard_zipcode.SearchKey
		},
		dataType : "json",
		success : function(res){
			var jsonStr = res.list;
			var sHtml = "";
			
			if(jsonStr!= null && Number(jsonStr.results.common.totalCount) > 0){ //데이터가 존재하면
				//현재 페이지 및 전체 count 재설정
				_mobile_bizcard_zipcode.CurrentPage = Number(jsonStr.results.common.currentPage);
				_mobile_bizcard_zipcode.TotalCount = Number(jsonStr.results.common.totalCount);
				
				//리스트 html 가져오기
				sHtml = mobile_bizcard_getAddrRowsHtml(jsonStr);
			}
			else { //데이터가 존재하지 않으면
				sHtml += "<div class=\"no_list\">";
				sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
				sHtml += "</div>";
			}
			
			//html 적용
			if(_mobile_bizcard_zipcode.CurrentPage == 1 || sHtml.indexOf("no_list") > -1) {
				$('#bizcard_zipcode_list').html(sHtml);
			} else {
				$('#bizcard_zipcode_list').append(sHtml);
			}
			
			//더보기 버튼 display 설정
			if(_mobile_bizcard_zipcode.CurrentPage >= _mobile_bizcard_zipcode.TotalCount){
				$("#bizcard_zipcode_btnnextlist").hide();
			} else {
				$("#bizcard_zipcode_btnnextlist").show();
			}
		 },
		 error:function(response, status, error){
			mobile_comm_ajaxerror(sUrl, response, status, error);
		}
	});
	
}

//주소 데이터 html로 가공
function mobile_bizcard_getAddrRowsHtml(data){
	var html = '';
	var jusoData = data.results.juso;
	var len = jusoData.length;
	for (var i = 0; i < len; i++) {
		html += "<li class=\"addr_link\">";
		html += "	<a href=\"javascript: mobile_bizcard_setSelectedZipCodeInfo('" + jusoData[i].zipNo + "', '" + jusoData[i].roadAddrPart1 + "','" + jusoData[i].roadAddrPart2 + "')\">";
		html += "		<p><span class=\"point\">" + jusoData[i].zipNo + "</span> (" + jusoData[i].lnbrMnnm + "-" + jusoData[i].lnbrSlno + ")</p>";
		html += "		<ul>";
		html += "			<li><span>" + mobile_comm_getDic("lbl_BizCard_06") + "</span>" + jusoData[i].roadAddrPart1 + "</li>"; //도로명
		html += "			<li><span>" + mobile_comm_getDic("lbl_BizCard_07") + "</span>" + jusoData[i].jibunAddr + "</li>"; //지번
		html += "		</ul>";
		html += "	</a>";
		html += "</li>";
	}
	return html;
}

//검색버튼 클릭
function mobile_zipcode_clicksearch(){
	
	$("#bizcard_zipcode_list li").remove();

	var text = $('#mobile_search_input').val();	
	if(text != ""){
		_mobile_bizcard_zipcode.SearchKey = text;
		_mobile_bizcard_zipcode.CurrentPage = 0;
		_mobile_bizcard_zipcode.TotalCount = 0;

		mobile_bizcard_getZipCodeApi();
	} else {
		var sHtml = "";
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
		sHtml += "</div>";
		$('#bizcard_zipcode_list').html(sHtml);
	}
	
}

//더보기 클릭
function mobile_zipcode_nextlist(){
	_mobile_bizcard_zipcode.CurrentPage += 1;
	mobile_bizcard_getZipCodeApi();	
}

//우편 선택 시, 값 넣기
function mobile_bizcard_setSelectedZipCodeInfo(pZipCode, pAddr1, pAddr2){
	
	//선택 모드 해제
	sessionStorage.removeItem("isselectmode");
	//write 화면에 값 저장
	$("#bizcard_write_companyzipcode").val(pZipCode);
	$("#bizcard_write_companyaddress").val(pAddr1);
	$("#bizcard_write_companyaddressfull").val(pAddr2);
	//dialog 창 닫기
	$.mobile.back(); 
}

//인명관리 - 우편번호 끝