/*!
 * 
 * 
 * SmartS4j / MobileOffice / 모바일 자원예약 js 파일
 * 함수명 : mobile_resource_...
 * 
 * 
 */


/*!
 * 
 * 페이지별 init 함수
 * 
 */

//자원예약 목록 - 자원예약 자원 선택 페이지
$(document).on('pageinit', '#resource_select_page', function () {
	if($("#resource_select_page").attr("IsLoad") != "Y"){
		$("#resource_select_page").attr("IsLoad", "Y");
		setTimeout("mobile_resource_SelectInit()", 10);	
	}
});

//자원예약 목록 - 자원예약 일간/주간/월간/My/승인반납 페이지
$(document).on('pageinit', '#resource_list_page', function () {
	if($("#resource_list_page").attr("IsLoad") != "Y"){
		$("#resource_list_page").attr("IsLoad", "Y");
		setTimeout("mobile_resource_ListInit()", 10);
		// 터치 이전/다음 이벤트
		mobile_resource_bindTouch("resource_list_content");
		// 새로고침 이벤트 막기
		if(mobile_comm_isAndroidApp()) {
			window.covimoapp.SetPullToRefresh(false);
		}
	} else {
		mobile_resource_bindTouch("resource_list_content");
	}
});

//자원예약 작성
$(document).on('pageinit', '#resource_write_page', function () {
	if($("#resource_write_page").attr("IsLoad") != "Y"){
		$("#resource_write_page").attr("IsLoad", "Y");
		setTimeout("mobile_resource_WriteInit()", 10);	
	}
});

//자원예약 자원정보
$(document).on('pageinit', '#resource_info_page', function () {
	if($("#resource_info_page").attr("IsLoad") != "Y"){
		$("#resource_info_page").attr("IsLoad", "Y");
		setTimeout("mobile_resource_InfoInit()", 10);		
	}
});

//자원예약 상세
$(document).on('pageinit', '#resource_view_page', function () {
	if($("#resource_view_page").attr("IsLoad") != "Y"){
		$("#resource_view_page").attr("IsLoad", "Y");
		setTimeout("mobile_resource_ViewInit()", 10);	
	}
});

// 자원 이전/다음 터치
var resTouchX = 0;
var resTouchPosX = 0;
var resTouchDirection = "";
var resTouchMoveWidth = 0;
var isresUpdate = false;
function mobile_resource_bindTouch(pTargetID){
	$("#"+pTargetID).off("touchstart,touchmove,touchend")
	.on('touchstart', function(e) {    	 		     	 
		resTouchPosX = e.originalEvent.targetTouches[0].pageX;
		resTouchX = 0;
		if(mobile_comm_isAndroidApp()) {
			window.covimoapp.SetPullToRefresh(false);
		}
	})
	.on('touchmove', function(e) {         	 
		resTouchX = e.originalEvent.targetTouches[0].pageX;
		resTouchDirection = "Right";
		mobile_comm_disablescroll();
		resTouchMoveWidth = parseInt(resTouchPosX - resTouchX);
		if(resTouchMoveWidth < 0) {
			resTouchDirection = "Left";
		}
		if(parseInt(resTouchMoveWidth) > parseInt(winW/2)){
			resTouchMoveWidth = parseInt(winW/2);
		}
		$("#sSlide_bar").css("margin-left", -(parseInt(resTouchMoveWidth)));
	})
	.on('touchend', function(e) {    	 
	 var left = parseInt(resTouchPosX - resTouchX);
	 var width = parseInt($("body").width())*0.3;
	 if(resTouchX != 0) {
		 if(left < 0 ){
			if (-left >= width) {
				mobile_resource_changeViewType('PREV');
			 } 
		 }else{
			if (left >= width) {
				mobile_resource_changeViewType('NEXT');
			 }
		 }
	 }	
	 $("#sSlide_bar").css("margin-left","");
	 mobile_comm_enablescroll();
	});
}


/*!
 * 
 * 자원예약 공통 시작
 * 
 */

var _mobile_resource_common = {		
	EventID : '',	
	ResourceID : '',
	DateID : '',
	RepeatID : '',
	IsRepeat : '',	
	ViewType : 'D',				//뷰 타입 설정(월간:M/주간:W/일간:D/목록:L/나의 자원예약:P/승인,반납요청:R),
	FolderCheckList : '',		//선택된 사업장 목록
	StartDate : '',				//시작일
	EndDate : '',				//종료일
	StartTime : '',				//시작시간
	EndTime : '',				//시작시간	
	Year : '',					//년도
	Month : '', 				//월
	Day : '',					//일
	Week : '',					//주
	FolderID : '',
	FolderType : '',
		
	ArrSunday : new Array(),	//일요일 정보 담는 배열
	CurrentTime : new Date(CFN_GetLocalCurrentDate()),
	resAclArray : new Array(),
	
	lang : mobile_comm_getSession("lang"),
	userCode : mobile_comm_getSession("USERID"),
	
	IsScheduleMode : 'N'	//일정에서 넘어왔을 경우
};

var updateBookingDataObj;

//초기화 및 파라미터 세팅
function mobile_resource_InitJS(pageId){
	
	// 자원예약 조회 타입
	if(location.href.indexOf("list.do") > -1) {
		if(_mobile_resource_common.ViewType == "") {
			_mobile_resource_common.ViewType = mobile_comm_getQueryString("viewtype", pageId);
			if(_mobile_resource_common.ViewType == "undefined" || _mobile_resource_common.ViewType == "" || _mobile_resource_common.ViewType == null){
				_mobile_resource_common.ViewType = "D";
			}
		}
	}
	
	// 자원예약 시작일
	if(_mobile_resource_common.StartDate == "") {
		_mobile_resource_common.StartDate = mobile_comm_getQueryString("startdate", pageId);
		if(_mobile_resource_common.StartDate == "undefined" || _mobile_resource_common.StartDate == "" || _mobile_resource_common.StartDate == null){
			_mobile_resource_common.StartDate = mobile_resource_SetDateFormat(_mobile_resource_common.CurrentTime, '.');
		}
	}
	
	// 자원예약 종료일
	if(_mobile_resource_common.EndDate == "") {
		_mobile_resource_common.EndDate = mobile_comm_getQueryString("enddate", pageId);
		if(_mobile_resource_common.EndDate == "undefined" || _mobile_resource_common.EndDate == "" || _mobile_resource_common.EndDate == null){
			_mobile_resource_common.EndDate = _mobile_resource_common.StartDate;
		}
	}
	
	if(_mobile_resource_common.ViewType == "W" && mobile_comm_getQueryString("startdate", pageId) != "undefined" && mobile_comm_getQueryString("startdate", pageId) != _mobile_resource_common.StartDate) {
		_mobile_resource_common.StartDate = mobile_comm_getQueryString("startdate", pageId);
		_mobile_resource_common.EndDate = mobile_comm_getQueryString("startdate", pageId);
	}
	
	_mobile_resource_common.Year = _mobile_resource_common.StartDate.split(".")[0];
	_mobile_resource_common.Month = _mobile_resource_common.StartDate.split(".")[1];
	_mobile_resource_common.Day = _mobile_resource_common.StartDate.split(".")[2];
	
	// 기존에 선택된 자원들 Checkbox Checked (PC 와 Mobile 에서 동일한 체크값을 공유 하기 위해서 Redis 부터 조회한다)
	var redisData = getChkFolderListRedis();
	if(redisData != undefined && redisData != "" && redisData != ";"){
		_mobile_resource_common.FolderCheckList = redisData;
	} else {
		if(window.sessionStorage.getItem("ResourceCheckBox_"+mobile_comm_getSession("UR_Code")) != null){
			_mobile_resource_common.FolderCheckList = window.sessionStorage.getItem("ResourceCheckBox_"+mobile_comm_getSession("UR_Code"));
		} else {
			mobile_resource_setAclEventFolderData();		
			_mobile_resource_common.FolderCheckList = ';';
			
			var readAclcnt = _mobile_resource_common.resAclArray.read.length;
			for(var i = 0; i < readAclcnt; i++) {
				_mobile_resource_common.FolderCheckList += _mobile_resource_common.resAclArray.read[i].FolderID + ";";
			}
		}
	}
	
	// 자원예약 Start Time
	_mobile_resource_common.StartTime = mobile_comm_getQueryString("starttime", pageId);
	if(_mobile_resource_common.StartTime == "undefined" || _mobile_resource_common.StartTime == "" || _mobile_resource_common.StartTime == null){
		_mobile_resource_common.StartTime = '00:00';
	}
	
	// 자원예약 End Time
	var temp = new Date(mobile_resource_ReplaceDate(_mobile_resource_common.StartDate + " " + _mobile_resource_common.StartTime + ":00"));
	temp.setMinutes(temp.getMinutes() + 30);
	_mobile_resource_common.EndTime = mobile_resource_AddFrontZero(temp.getHours(), 2) + ":" + mobile_resource_AddFrontZero(temp.getMinutes(), 2);
		
	// 자원예약 Event ID
	_mobile_resource_common.EventID = mobile_comm_getQueryString("eventid", pageId);
	if(_mobile_resource_common.EventID == "undefined" || _mobile_resource_common.EventID == null){
		_mobile_resource_common.EventID = '';
	}
	
	// 자원예약 Resource ID
	_mobile_resource_common.ResourceID = mobile_comm_getQueryString("resourceid", pageId);
	if(_mobile_resource_common.ResourceID == "undefined" || _mobile_resource_common.ResourceID == "" || _mobile_resource_common.ResourceID == null){
		_mobile_resource_common.ResourceID = '';
	}
	
	// 자원예약 Resource Name
	_mobile_resource_common.ResourceName = decodeURI(mobile_comm_getQueryString("resourcename", pageId));
	if(_mobile_resource_common.ResourceName == "undefined" || _mobile_resource_common.ResourceName == "" || _mobile_resource_common.ResourceName == null){
		_mobile_resource_common.ResourceName = '';
	}
	
	// 자원예약 Date ID
	_mobile_resource_common.DateID = mobile_comm_getQueryString("dateid", pageId);
	if(_mobile_resource_common.DateID == "undefined" || _mobile_resource_common.DateID == null){
		_mobile_resource_common.DateID = '';
	}
	
	// 자원예약 Repeat ID
	_mobile_resource_common.RepeatID = mobile_comm_getQueryString("repeatid", pageId);
	if(_mobile_resource_common.RepeatID == "undefined" || _mobile_resource_common.RepeatID == null){
		_mobile_resource_common.RepeatID = '';
	}
	
	// 자원예약 Is Repeat
	_mobile_resource_common.IsRepeat = mobile_comm_getQueryString("isrepeat", pageId);
	if(_mobile_resource_common.IsRepeat == "undefined" || _mobile_resource_common.IsRepeat == null){
		_mobile_resource_common.IsRepeat = '';
	}
	
	//일정에서 넘어왔을 경우
	_mobile_resource_common.IsScheduleMode = "N";
	if(window.sessionStorage.getItem("isschedulemode_"+mobile_comm_getSession("UR_Code").toLowerCase()) != null){
		_mobile_resource_common.IsScheduleMode = window.sessionStorage.getItem("isschedulemode_"+mobile_comm_getSession("UR_Code").toLowerCase());
		window.sessionStorage.removeItem("isschedulemode_"+mobile_comm_getSession("UR_Code").toLowerCase());
	}	
}

//권한이 있는 폴더
function mobile_resource_setAclEventFolderData() {
	$.ajax({
	    url: "/groupware/mobile/resource/getACLFolder.do",
	    type: "POST",
	    data: {},
	    async: false,
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		_mobile_resource_common.resAclArray = res;
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
        },
        error:function(response, status, error){
			mobile_comm_ajaxerror("/groupware/mobile/resource/getACLFolder.do", response, status, error);
		}
	});
}

//오늘로 이동
function mobile_resource_movetoToday(){
	_mobile_resource_common.StartDate = mobile_resource_SetDateFormat(_mobile_resource_common.CurrentTime, ".");
	_mobile_resource_common.Year = _mobile_resource_common.StartDate.split(".")[0];			// 전역변수 세팅
	_mobile_resource_common.Month = _mobile_resource_common.StartDate.split(".")[1];			// 전역변수 세팅
	_mobile_resource_common.Day = _mobile_resource_common.StartDate.split(".")[2];			// 전역변수 세팅

	mobile_resource_changeViewType(_mobile_resource_common.ViewType);
}

//달력 컨트롤 show
function mobile_resource_clickcalendar(){
}

//사업장 선택
function mobile_resource_clickbizplace(mode){ //mode : list, write
	var sUrl = "/groupware/mobile/resource/select.do";
	window.sessionStorage["open_mode"] = mode;	
	mobile_comm_go(sUrl, 'Y');
}

//작성창으로 이동
function mobile_resource_clickwrite(date, time, resourceID, resourceName){
	var isTeams = false;
	try {
		if (typeof XFN_TeamsOpenGroupware == "function" && !teams_mobile) {
			isTeams = true;
		}
	} catch(e) { 
		mobile_comm_log(e);
	}
	
	if (isTeams) {
		var url = "/groupware/layout/resource_DetailWrite.do?CLSYS=resource&CLMD=user&CLBIZ=Resource";
        var popupId = "TeamsResourceWrite";
        //XFN_TeamsOpenWindow(url, popupId, "POPUP", 1200, 800, "both", false);
        XFN_TeamsOpenWindow(url, popupId, "REDIRECT", 0, 0, "", false);
	} else {
		var sUrl = "";
		
		sUrl = "/groupware/mobile/resource/write.do";
		if(date != undefined) {
			sUrl += "?startdate=" + date;
		} else if (_mobile_resource_common.ViewType == 'D' || _mobile_resource_common.ViewType == 'W') {
			var firstDate = $("#resource_list_datetitle").text();
			if (_mobile_resource_common.ViewType == 'W') firstDate = firstDate.split(' ~ ')[0];
			if (mobile_resource_GetDiffDates(new Date(CFN_GetLocalCurrentDate()).getTime(), new Date(firstDate).getTime(), 'day') < 0) {
				firstDate = CFN_GetLocalCurrentDate('yyyy.MM.dd');	
				time = CFN_GetLocalCurrentDate('HH:mm')
			}
			sUrl += "?startdate=" + firstDate;
		}
		if(time != undefined)
			sUrl += "&starttime=" + time;
		if(resourceID != undefined)
			sUrl += "&resourceid=" + resourceID;
		if(resourceName != undefined)
			sUrl += "&resourcename=" + encodeURI(resourceName);
		if(date != undefined && time != undefined && resourceID != undefined && resourceName != undefined) {
			if(confirm(mobile_comm_getDic("msg_resource_gotoReservationRegist1").replace("\\n", "\n") + " " + resourceName + mobile_comm_getDic("msg_resource_gotoReservationRegist2").replace("\\n", "\n") + " " + date + " " + time)) { //예약 신청 페이지로 이동하시겠습니까?\n- 자원명 : \n- 예약시작시간 : 
				mobile_comm_go(sUrl,'Y');
			}
		} else {
			mobile_comm_go(sUrl,'Y');
		}
	}
}

//자원 정보 show
function mobile_resource_clickResourceInfo(folderID) {
	var sUrl = "";
		
	if(_mobile_resource_common.ResourceID == "" && (folderID == "" || folderID == undefined)) {
		alert(mobile_comm_getDic("msg_resource_notSelectedResource")); //선택된 자원이 없습니다.
	} else {
		sUrl = "/groupware/mobile/resource/info.do";
		
		if(folderID != undefined && folderID != "") {
			window.sessionStorage["resourceid"] = folderID;
		} else {
			window.sessionStorage["resourceid"] = _mobile_resource_common.ResourceID;
		}
		
		mobile_comm_go(sUrl, 'Y'); 
	}
}

//상세보기 show or hide
function mobile_resource_showORhide(obj, mode) {
	if(mode != undefined && mode == "self") {
		if($(obj).hasClass("show")) {
			$(obj).removeClass("show");
		} else {
			$(obj).addClass("show");
		}
	} else {
		if($(obj).parent().hasClass("show")) {
			$(obj).parent().removeClass("show");
		} else {
			$(obj).parent().addClass("show");
		}
	}
}

var more_temp;
//자원 검색 버튼 click
function mobile_resource_searchInput() {
	$("#resource_div_search").css("display", "block");
	if($('#resource_list_more').css("display") == "none")
		more_temp = false;
	else
		more_temp = true;
}

// 자원 검색 enter key press
function mobile_resource_searchEnter(e) {
	if(e.keyCode === 13) {
		mobile_resource_search();
	}
	return false;
}

// 자원 검색
function mobile_resource_search() {
	if($("#resource_search_input").val() == "") {
		alert(mobile_comm_getDic("msg_EnterSearchword"));
	} else if($("#resource_search_input").val().length < 2) {
		alert(mobile_comm_getDic("msg_resource_inputTwoMore")); //2자리 이상 입력하세요.
	} else {
		$("#resource_list_list").css("display", "none");
		$("#resource_list_searchlist").css("display", "block");
		
		window.sessionStorage.setItem("mobileResourceSearchText",  $("#resource_search_input").val());
		_mobile_resource_list.SearchText = $("#resource_search_input").val();
		_mobile_resource_list.Page = 1;
		_mobile_resource_list.TotalCount = -1;
		_mobile_resource_list.RecentCount = 0;
		_mobile_resource_list.EndOfList = false;
		
		$("#resource_list_searchlist").html("");
		mobile_resource_MakeResourceList();
	}
}

// 자원 검색 닫기
function mobile_resource_changeDisplay() {
	$("#resource_list_searchlist").css("display", "none");
	$("#resource_list_list").css("display", "block");
	
	if(_mobile_resource_common.ViewType == "D" || _mobile_resource_common.ViewType == "W" || _mobile_resource_common.ViewType == "M" || _mobile_resource_common.ViewType == "L") {
		$(".calendar_wrap").show();
		$(".slide_bar").show();
	}
	
	if(more_temp) $('#resource_list_more').show();
	else $('#resource_list_more').hide();
	
	mobile_resource_resetSearchInput();
	
	mobile_resource_ListInit();
	
}

// 자원 검색 input reset
function mobile_resource_resetSearchInput() {
	$("#resource_search_input").val("");
	window.sessionStorage.setItem("mobileResourceSearchText", "");
	_mobile_resource_list.SearchText = "";
	$("#resource_search_input").focus();
}

/*!
 * 
 * 자원예약 공통 끝
 * 
 */





/*!
 * 
 * 자원예약 목록 - 자원 선택 시작
 * 
 */

var _resource_select_placeOfBusiness = '';
var _resource_select_mode = '';

function mobile_resource_SelectInit() {
	// 자원예약 조회 타입
	_resource_select_mode = mobile_comm_getQueryString("mode");
	if(_resource_select_mode == "undefined" || _resource_select_mode == "" || _resource_select_mode == null) {
		_resource_select_mode = window.sessionStorage.getItem("open_mode");
		if(_resource_select_mode == "undefined" || _resource_select_mode == "" || _resource_select_mode == null) 
			_resource_select_mode = "list";
	}
	
	//mobile_resource_InitJS();
	// 사업장 사용 여부
    if((mobile_comm_getBaseConfig("IsUsePlaceOfBusinessSel") === "N")){
        $("#resource_select_placeOfBusiness").hide();
    }else{
		$("#resource_select_placeOfBusiness").show();
		mobile_resource_setPlaceOfBusiness();
    }

	mobile_resource_setResourceList();
	
	$("#resource_select_header").children("a").remove(); //이상한 a 태그가 추가되는 현상 임시 조치
}

//사업장 Select Box 세팅
function mobile_resource_setPlaceOfBusiness(pType){
	$.ajax({
		type:"POST",
		data:{
			"codeGroups" : "PlaceOfBusiness"
		},
		url:"/covicore/basecode/get.do",
		success:function (data) {
			if(data.result == "ok"){
				var List = data.list[0].PlaceOfBusiness;
				var cnt = List.length;
				var target = "resource_select_placeOfBusiness";
				var value = _resource_select_placeOfBusiness;
				if(pType == "list"){
					target = "resource_list_placeOfBusiness";
					value = _resource_list_placeOfBusiness;
				}
									
				for(var i = 0; i < cnt; i++) {
					$("#"+target).append("<option value=\"" + List[i].Code + "\">" + mobile_comm_getDicInfo(List[i].MultiCodeName, _mobile_resource_common.lang) + "</option>");
				}
				if(value != "")
					$("#"+target).val(value);
				else
					$("#"+target).val("PlaceOfBusiness");
			}
		},
		error:function (error){
			alert(error.message);
		}
	});
}

// 사업장 Select Box 변경시
function mobile_resource_changePlaceOfBusiness(pType){
	var value = "";
	if(pType == "list"){		
		value = $("#resource_list_placeOfBusiness").val();
		_resource_list_placeOfBusiness = (value == "PlaceOfBusiness") ? "" : value;
	}else{		
		value = $("#resource_select_placeOfBusiness").val();
		_resource_select_placeOfBusiness = (value == "PlaceOfBusiness") ? "" : value;
	}	
	
	mobile_resource_setResourceList(pType);
}

//자원 목록 세팅
function mobile_resource_setResourceList(pType) {
	var target = "resource_select_resourceList";
	var value = _resource_select_placeOfBusiness;
	if(pType == "list"){
		target = "resource_list_resourceList";
		value = _resource_list_placeOfBusiness;
	}
	
	var i = 0;
	var displayName = "";
	var arrChecklist;
	var checkcnt;
	var bDisabled = false;
	
	$("#"+target).html("");
	$.ajax({
			url:"/groupware/mobile/resource/getResourceTreeList.do",
			type:"POST",
			data:{
				"placeOfBusiness": value
			},
			success:function (data) {
				var List = data.list;
				var cnt = List.length;
				var sHtml = "";
				var rootFolderID = "";
				if(pType == "list"){				
					if(cnt <= 0 || (cnt == 1 && List[0].FolderType == "Root" && List[0].MemberOf != '0')) {
						// sHtml += "<div class=\"no_list\">";
						// sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
						// sHtml += "</div>";
					} else {						
						for(i = 0; i < cnt; i++) {
							displayName = mobile_comm_getDicInfo(List[i].MultiDisplayName, _mobile_resource_common.lang);
							
							if(List[i].FolderType == "Root" && List[i].MemberOf == '0'){
								sHtml += "<li class=\"all_chk chk_item\">";
								sHtml += 	"<input type=\"checkbox\" id=\"resource_list_treechk_" + List[i].FolderID + "\" onchange=\"mobile_resource_chkResource(this,'ALL');\" value=\"" + List[i].FolderID + "\"><label for=\"resource_list_treechk_" + List[i].FolderID + "\">" + mobile_comm_getDic("lbl_resource_viewAllRes") + "</label>";								
								sHtml += "</li>";
								rootFolderID += List[i].FolderID + ";";	
							}else if(List[i].FolderType == "Root") {
								sHtml += "<li class=\"all_chk chk_item\">";
								sHtml += 	"<input type=\"checkbox\" id=\"resource_list_treechk_" + List[i].FolderID + "\" onchange=\"mobile_resource_chkResource(this,'ALL');\" value=\"" + List[i].FolderID + "\"><label for=\"resource_list_treechk_" + List[i].FolderID + "\">" + displayName + "</label><button type=\"button\" class=\"btnTblSearch\" onclick=\"mobile_resource_clickResourceInfo(" + List[i].FolderID + ");\">검색</button>";								
								sHtml += "</li>";
								rootFolderID += List[i].FolderID + ";";								
							} else if(List[i].FolderType == "Folder") {
								sHtml += "<li class=\"chk_item sub_tit\">";
								sHtml += "	<p class=\"cate_tit\">" + displayName + "</p>";
								sHtml += "	<ul class=\"sub_item\" id=\"resource_list_ul_" + List[i].FolderID + "\">";
								sHtml += "	</ul>";
								sHtml += "</li>";
							} else if(List[i].FolderType.indexOf("Resource") > -1) { //Root 밑 자원
								if(rootFolderID.indexOf(List[i].MemberOf) > -1) {
									sHtml += "<li class=\"chk_item\"><input type=\"checkbox\" id=\"resource_list_treechk_" + List[i].FolderID + "\" onchange=\"mobile_resource_chkResource(this);\" value=\"" + List[i].FolderID + "\"><label for=\"resource_list_treechk_" + List[i].FolderID + "\">" + displayName + "</label><button type=\"button\" class=\"btnTblSearch\" onclick=\"mobile_resource_clickResourceInfo(" + List[i].FolderID + ");\">검색</button></li>";
								}
							}
						}
					}						
					
					$("#resource_list_resourceList").append(sHtml).trigger("create");
						
					for(i = 0; i < cnt; i++) {
						displayName = mobile_comm_getDicInfo(List[i].MultiDisplayName, _mobile_resource_common.lang);
						
						if(List[i].FolderType.indexOf("Resource") > -1) { //Folder 밑 자원
							sHtml = "<li><input type=\"checkbox\" id=\"resource_list_treechk_" + List[i].FolderID + "\" onchange=\"mobile_resource_chkResource(this);\" value=\"" + List[i].FolderID + "\"><label for=\"resource_list_treechk_" + List[i].FolderID + "\">" + displayName + "</label><button type=\"button\" class=\"btnTblSearch\" onclick=\"mobile_resource_clickResourceInfo(" + List[i].FolderID + ");\">검색</button></li>";
							$("#resource_list_ul_" + List[i].MemberOf).append(sHtml).trigger("create");
						}
					}
					
					// 기존에 선택된 자원들 Checkbox Checked
					var redisData = getChkFolderListRedis();					
					if(redisData != undefined && redisData != "" && redisData != ";"){
						arrChecklist = redisData.split(";");
					} else {
						arrChecklist = _mobile_resource_common.FolderCheckList.split(";");
					}
					
					checkcnt = arrChecklist.length;
					for(i = 1; i < checkcnt; i++) {
						$("#resource_list_treechk_" + arrChecklist[i]).prop("checked", true).checkboxradio('refresh');
					}
					
					var checkedAll = true;
					$("#resource_list_resourceList li:not(.all_chk)").find("input[type=checkbox]:not(:checked)").each(function() {
						checkedAll = false;
					});
					
					if(checkedAll) {
						$("#resource_list_resourceList li.all_chk").find("input[type=checkbox]").prop("checked", true).checkboxradio('refresh');
					} else {
						$("#resource_list_resourceList li.all_chk").find("input[type=checkbox]").prop("checked", false).checkboxradio('refresh');
					}
				}else{
					if(_resource_select_mode == "list") {
						if(cnt <= 0 || (cnt == 1 && List[0].FolderType == "Root" && List[0].MemberOf != '0')) {
							sHtml += "<div class=\"no_list\">";
							sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
							sHtml += "</div>";
						}
						else {						
							for(i = 0; i < cnt; i++) {
								displayName = mobile_comm_getDicInfo(List[i].MultiDisplayName, _mobile_resource_common.lang);
								
								if(List[i].FolderType == "Root" && List[i].MemberOf != '0' && List[i].DomainID != '0') {
									sHtml += "<li class=\"all_chk chk_item\">";
									sHtml += "	<input type=\"checkbox\" id=\"resource_select_chk_" + List[i].FolderID + "\" onchange=\"mobile_resource_chkAllResource(this);\" value=\"" + List[i].FolderID + "\"><label for=\"resource_select_chk_" + List[i].FolderID + "\">" + displayName + "</label>";
									sHtml += "</li>";
									rootFolderID += List[i].FolderID + ";";
									
								} else if(List[i].FolderType == "Folder") {
									sHtml += "<li class=\"chk_item\">";
									sHtml += "	<p class=\"cate_tit\">" + displayName + "</p>";
									sHtml += "	<ul class=\"sub_item\" id=\"resource_select_ul_" + List[i].FolderID + "\">";
									sHtml += "	</ul>";
									sHtml += "</li>";
								} else if(List[i].FolderType.indexOf("Resource") > -1) { //Root 밑 자원
									if(rootFolderID.indexOf(List[i].MemberOf) > -1) {
										sHtml += "<li class=\"chk_item\"><input type=\"checkbox\" id=\"resource_select_chk_" + List[i].FolderID + "\" value=\"" + List[i].FolderID + "\"><label for=\"resource_select_chk_" + List[i].FolderID + "\">" + displayName + "</label></li>";
									}
								}
							}
						}	
						
						$("#resource_select_resourceList").append(sHtml).trigger("create");
							
						for(i = 0; i < cnt; i++) {
							displayName = mobile_comm_getDicInfo(List[i].MultiDisplayName, _mobile_resource_common.lang);
							
							if(List[i].FolderType.indexOf("Resource") > -1) { //Folder 밑 자원
								sHtml = "<li><input type=\"checkbox\" id=\"resource_select_chk_" + List[i].FolderID + "\" value=\"" + List[i].FolderID + "\"><label for=\"resource_select_chk_" + List[i].FolderID + "\">" + displayName + "</label></li>";
								$("#resource_select_ul_" + List[i].MemberOf).append(sHtml).trigger("create");
							}
						}
						
						// 기존에 선택된 자원들 checkbox checked true로
						arrChecklist = _mobile_resource_common.FolderCheckList.split(";");
						checkcnt = arrChecklist.length;
						for(i = 1; i < checkcnt; i++) {
							$("#resource_select_chk_" + arrChecklist[i]).prop("checked", true).checkboxradio('refresh');
						}
					} else if(_resource_select_mode == "write") {
						if(cnt <= 0 || (cnt == 1 && List[0].FolderType == "Root" && List[0].MemberOf != '0')) {
							sHtml += "<div class=\"no_list\">";
							sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
							sHtml += "</div>";
						}
						else {
							for(i = 0; i < cnt; i++) {
								displayName = mobile_comm_getDicInfo(List[i].MultiDisplayName, _mobile_resource_common.lang);
								
								bDisabled = List[i].BookingType == "ApprovalProhibit" ? true : false;
								if(List[i].FolderType == "Root") {
									rootFolderID += List[i].FolderID + ";";
								} else if(List[i].FolderType == "Folder") {
									sHtml += "<li class=\"chk_item\">";
									sHtml += "	<p class=\"cate_tit\">" + displayName + "</p>";
									sHtml += "	<ul class=\"sub_item\" id=\"resource_select_ul_" + List[i].FolderID + "\">";
									sHtml += "	</ul>";
									sHtml += "</li>";
								} else if(List[i].FolderType.indexOf("Resource") > -1) { //Root 밑 자원
									if(rootFolderID.indexOf(List[i].MemberOf) > -1) {
										sHtml += "<li class=\"chk_item\"><input type=\"radio\" name=\"resource_select_rdo\" id=\"resource_select_rdo_" + List[i].FolderID + "\" value=\"" + List[i].FolderID + "\""+((bDisabled)?"disabled=\"disabled\"":"")+"><label for=\"resource_select_rdo_" + List[i].FolderID + "\">" + displayName + "</label></li>";
									}
								}
							}
						}	
						
						$("#resource_select_resourceList").append(sHtml).trigger("create");
							
						for(i = 0; i < cnt; i++) {
							displayName = mobile_comm_getDicInfo(List[i].MultiDisplayName, _mobile_resource_common.lang);
							
							bDisabled = List[i].BookingType == "ApprovalProhibit" ? true : false;
							if(List[i].FolderType.indexOf("Resource") > -1) { //Folder 밑 자원
								sHtml = "<li><input type=\"radio\" name=\"resource_select_rdo\" id=\"resource_select_rdo_" + List[i].FolderID + "\" value=\"" + List[i].FolderID+ "\""+((bDisabled)?"disabled=\"disabled\"":"")+"><label for=\"resource_select_rdo_" + List[i].FolderID + "\">" + displayName + "</label></li>";
								$("#resource_select_ul_" + List[i].MemberOf).append(sHtml).trigger("create");
							}
						}
						
						$("#resource_select_rdo_" + _mobile_resource_common.ResourceID).prop("checked", true).checkboxradio('refresh');
					}
					
					//작성창에서 열었을 때는 하나만 선택할 수 있도록
					/*if(_resource_select_mode == "write") {
						$("#resource_select_resourceList li.all_chk").remove();
						$("#resource_select_resourceList li").find("input[type=checkbox]").prop("checked", false);
						$("#resource_select_resourceList li").find("input[type=checkbox]").click(function() {
							if($(this).prop("checked")) {
								$("#resource_select_resourceList li").find("input[type=checkbox]").prop("checked", false);
								$(this).prop("checked", true);
							}
						});
					}*/
				}				
				
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror("/groupware/mobile/resource/getResourceTreeList.do", response, status, error);
			}
		});
}

// 메뉴 닫기
function mobile_ResourceMenuClose() {
	mobile_comm_TopMenuClick('resource_list_topmenu',true);
	mobile_resource_changeViewType(_mobile_resource_common.ViewType);	
}

//자원 전체 선택
function mobile_resource_chkAllResource(obj) {
	if($(obj).is(":checked")) {
		$(".chk_item").find("input[type=checkbox]").prop('checked', true).checkboxradio('refresh');
	} else {
		$(".chk_item").find("input[type=checkbox]").prop('checked', false).checkboxradio('refresh');
	}
}

//자원 선택
function mobile_resource_chkResource(obj,type){
	if(type =="ALL"){
		if($(obj).is(":checked")) {
			$(".chk_item").find("input[type=checkbox]").prop('checked', true).checkboxradio('refresh');			
		} else {
			$(".chk_item").find("input[type=checkbox]").prop('checked', false).checkboxradio('refresh');			
		}
	}
	
	//값 초기화
	if($("#resource_list_placeOfBusiness").val() == "PlaceOfBusiness") {
		_mobile_resource_common.FolderCheckList = ";";
		
		//선택 목록 추출 및 값 바인딩
		$("#resource_list_resourceList li:not(.all_chk)").find("input[type=checkbox]:checked").each(function() {
			if($(this).attr("value") != undefined){
				_mobile_resource_common.FolderCheckList += $(this).attr("value") + ";";
			}
		});
	} else {
		if($(obj).is(":checked")) {
			//선택 목록 추출 및 값 바인딩
			$("#resource_list_resourceList li:not(.all_chk)").find("input[type=checkbox]:checked").each(function() {
				if($(this).attr("value") != undefined){
					if(_mobile_resource_common.FolderCheckList.indexOf($(this).attr("value")) == -1){
						_mobile_resource_common.FolderCheckList += $(this).attr("value") + ";";
					}
				}
			});
		} else {
			$("#resource_list_resourceList li:not(.all_chk)").find("input[type=checkbox]:not(:checked)").each(function() {
				if($(this).attr("value") != undefined){
					_mobile_resource_common.FolderCheckList = _mobile_resource_common.FolderCheckList.replace($(this).attr("value") + ";", "");
				}
			});		
		}
	}
	
	var checkedAll = true;
	$("#resource_list_resourceList li:not(.all_chk)").find("input[type=checkbox]:not(:checked)").each(function() {
		checkedAll = false;
	});
	
	if(checkedAll) {
		$("#resource_list_resourceList li.all_chk").find("input[type=checkbox]").prop("checked", true).checkboxradio('refresh');
	} else {
		$("#resource_list_resourceList li.all_chk").find("input[type=checkbox]").prop("checked", false).checkboxradio('refresh');
	}
	
	//세션에 저장
	window.sessionStorage.setItem("ResourceCheckBox_"+mobile_comm_getSession("UR_Code"), _mobile_resource_common.FolderCheckList);
	saveChkFolderListRedis(_mobile_resource_common.FolderCheckList);
	
	if(_mobile_resource_common.ViewType == "P" || _mobile_resource_common.ViewType == "R")
		return false;
		
	var useTeamsAddIn = $("#useTeamsAddIn").val();
	var isMobile = $("#isMobile").val();
	if(useTeamsAddIn == "Y" && isMobile == "false"){
		mobile_resource_changeViewType(_mobile_resource_common.ViewType);
	}
}

function getChkFolderListRedis() {
	var redisData = "";
	
	$.ajax({
		url:"/groupware/mobile/resource/getChkFolderListRedis.do",
	    type: "POST",
	    async:false,
		success: function (res) {
			if(res.redisData != null) {
				redisData = res.redisData;
			}
		},
	    error:function(response, status, error){
	    	
	    }
	});
	
	return redisData;
}

function saveChkFolderListRedis(chkList) {
	$.ajax({
	    url: "/groupware/resource/saveChkFolderListRedis.do",
	    type: "POST",
	    data: {
	    	"checkList": chkList,
	    	"userCode": mobile_comm_getSession("UR_Code")
		},
		success: function (res) {
			if(res.status == "FAIL"){
				alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
			}
		},
	    error:function(response, status, error){
			mobile_comm_ajaxerror("/groupware/resource/saveChkFolderListRedis.do", response, status, error);
	    }
	});
}

//선택한 폴더 목록 저장 후 이전 페이지로 돌아감
function mobile_select_saveSelectedResource(){
	if(_resource_select_mode == "list") {
		//값 초기화
		_mobile_resource_common.FolderCheckList = ";";
		
		//선택한 목록이 없으면... 재 설정 필요
		if($("#resource_select_resourceList li:not(.all_chk)").find("input[type=checkbox]:checked").length < 1) {
			alert(mobile_comm_getDic("msg_resource_notSelectedResource")); //선택된 자원이 없습니다.
			return false;
		}
		
		//선택 목록 추출 및 값 바인딩
		$("#resource_select_resourceList li:not(.all_chk)").find("input[type=checkbox]:checked").each(function() {
			if($(this).attr("value") != undefined){
				_mobile_resource_common.FolderCheckList += $(this).attr("value") + ";";
			}
		});
		
		//세션에 저장
		window.sessionStorage.setItem("ResourceCheckBox_"+mobile_comm_getSession("UR_Code"), _mobile_resource_common.FolderCheckList);
		saveChkFolderListRedis(_mobile_resource_common.FolderCheckList);
		
		//이전 페이지로 되돌아감
		$('.ui-dialog').dialog('close');
		mobile_resource_ListInit();
	} else if(_resource_select_mode == "write") {
		var resourceID = $("#resource_select_resourceList li").find("input[type=radio]:checked").attr("value");
		if (_mobile_resource_common.ResourceID != resourceID){
			_mobile_resource_common.oldResourceID = _mobile_resource_common.ResourceID;
		}
		_mobile_resource_common.ResourceID = $("#resource_select_resourceList li").find("input[type=radio]:checked").attr("value");
		_mobile_resource_common.ResourceName = $("#resource_select_resourceList li").find("input[type=radio]:checked").siblings("label").html();
		
		$("#resource_write_resourceID").val(_mobile_resource_common.ResourceID);
		//$("#resource_write_resourceName").html(_mobile_resource_common.ResourceName);
		
		//세션에 저장
		window.sessionStorage.setItem("ResourceWrite_SelectResource_ID_" + mobile_comm_getSession("UR_Code"), _mobile_resource_common.ResourceID);
		window.sessionStorage.setItem("ResourceWrite_SelectResource_Name_" + mobile_comm_getSession("UR_Code"), _mobile_resource_common.ResourceName);
		
		//선택 자원 전역에 저장
		$.ajax({
		    url: "/groupware/mobile/resource/getResourceData.do",
		    type: "POST",
		    data: {
		    	"FolderID" : resourceID
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS") {
		    		if(res.data.resourceData && _mobile_resource_common.resourceArr[resourceID] == undefined) {
		    			_mobile_resource_common.resourceArr[resourceID] = res.data.resourceData;
		    		}
		    	}
		    },
		    error:function(response, status, error){
				mobile_comm_ajaxerror("/groupware/mobile/resource/getResourceData.do", response, status, error);
			}
	    });

		
		//이전 페이지로 되돌아감
		//$('.ui-dialog').dialog('close');
		mobile_comm_back();
		
		//전화면에서 소스를 컨트롤 하는 경우 화면이 닫히는 현상이 있어 뒤로뺌
		setTimeout($("#resource_write_resourceName").html(_mobile_resource_common.ResourceName),400);
	}
}

/*!
 * 
 * 자원예약 목록 - 자원 선택 끝
 * 
 */





/*!
 * 
 * 자원예약 목록 시작
 * 
 */

var _mobile_resource_list = {
	TotalCount: -1,		//전체 건수
	RecentCount: 0,		//현재 보여지는 건수
	EndOfList: false,	//전체 리스트를 다 보여줬는지
	
	Page: 1,			//조회할 페이지
	PageSize: 10,		//페이지당 건수
	SearchText: ''		//검색어		
};
var _resource_list_placeOfBusiness = '';

//자원예약 목록 페이지 초기화
function mobile_resource_ListInit(){
	if(window.sessionStorage["resource_writeinit"] == "Y")
		window.sessionStorage.removeItem('resource_writeinit');
	
	//초기화 및 파라미터 세팅
	mobile_resource_InitJS();
	
	if(window.sessionStorage.getItem("mobileResourceSearchText") != undefined && window.sessionStorage.getItem("mobileResourceSearchText") != "") {
		_mobile_resource_list.SearchText = window.sessionStorage.getItem("mobileResourceSearchText");
		
		$("#resource_list_list").css("display", "none");
		$("#resource_list_searchlist").css("display", "block");
		mobile_resource_searchInput();
		$("#resource_search_input").val(_mobile_resource_list.SearchText);
	}
	
	if(window.sessionStorage.getItem("mobileResourceViewType") != undefined && window.sessionStorage.getItem("mobileResourceViewType") != "") {
		_mobile_resource_common.ViewType = window.sessionStorage.getItem("mobileResourceViewType");
	}
	//상단 조회 타입 변경
	mobile_resource_changeViewType(_mobile_resource_common.ViewType);
	
	//일정에서 넘어왔을 경우, ui 디자인 설정
	if (_mobile_resource_common.IsScheduleMode == "Y"){
		// 좌측메뉴 표시 (기본 게시&커스텀메뉴 모두 동일하고 트리만 다름)
		setTimeout(function () {
			$("[name='resourcemenu']").each(function (){
				var sType = $(this).attr("type");
				if(sType == undefined || !(sType == "W" || sType == "D")){ //sType 값이 없거나, W나 D값이 아닌 경우
					$(this).hide();
				} 
			});
		}, 100);
		
		//좌측 상단 버튼 중 "확인" 버튼을 제외한 나머지 버튼 숨기기
		$("div.utill a:not(#schedule_write_save)").hide();
		$("#resource_list_btnSaveResource").show();
		$("#btnResourceSelectBack").show();
		$("#resource_list_page").find(".list_writeBTN").hide();
		
		//상단에 close 버튼 생기는 부분 방지
		$("div.sub_header").siblings("a.ui-icon-delete").remove();
	}
	
    // 사업장 사용 여부
    if((mobile_comm_getBaseConfig("IsUsePlaceOfBusinessSel") === "N")){
        $("#resource_list_placeOfBusiness").hide();
    }else{
        $("#resource_list_placeOfBusiness").show();
		mobile_resource_setPlaceOfBusiness('list');
    }

	
	mobile_resource_setResourceList('list');
}

//상단 조회 타입명 셋팅
function mobile_resource_getTopMenuName() {	
	var omenu = $("[name='resourcemenu']");
	var sTopMenu = omenu.filter(":eq(0)").text();
	omenu.removeClass("selected");
	omenu.each(function (){		
		if($(this).attr('type') == _mobile_resource_common.ViewType) {
			sTopMenu = $(this).text();
			$(this).addClass("selected");
			return false;
		}
	});
	
	if(_mobile_resource_common.IsScheduleMode == "Y"){
		$("#resource_list_title").html(mobile_comm_getDic("lbl_resource_selectRes") + " (" + sTopMenu.replace((" " + mobile_comm_getDic("lbl_view")), "") + ")" + "<i class=\"arr_menu\"></i>");
		//좌측 상단 버튼 중 "확인" 버튼을 제외한 나머지 버튼 숨기기
		$("div.utill a:not(#schedule_write_save)").hide();
		$("#resource_list_btnSaveResource").show();
	} else {
		$('#resource_list_title').html(sTopMenu + mobile_comm_getDic("lbl_view"));
	}
}

//상단 조회 타입 변경
function mobile_resource_changeViewType(type) {

	_mobile_resource_list.TotalCount = -1;
	_mobile_resource_list.RecentCount = 0;
	_mobile_resource_list.EndOfList = false;
	_mobile_resource_list.Page = 1;
	window.sessionStorage.setItem("mobileResourceSearchText",  "");
	
	if(type != "PREV" && type != "NEXT")
		window.sessionStorage.setItem("mobileResourceViewType",  type);
	
	//상단 조회 타입 hide
	mobile_comm_TopMenuClick('resource_list_topmenu',true);
	
	if(type == "P" || type == "R") { //나의 자원예약, 승인/반납 요청
		//사업장(자원) 선택 버튼 숨기기
		if($("#resource_list_header .utill .btn_place").css("display") != "none")
			$("#resource_list_header .utill .btn_place").hide();
	} else {
		//사업장(자원) 선택 버튼 보이기
		if($("#resource_list_header .utill .btn_place").css("display") == "none")
			$("#resource_list_header .utill .btn_place").show();
	}
	
	var g_startDate = _mobile_resource_common.StartDate;
	var g_endDate = _mobile_resource_common.EndDate;
	var g_year = _mobile_resource_common.Year;
	var g_month = _mobile_resource_common.Month;
	var g_viewType = _mobile_resource_common.ViewType;
	
	if(type != g_viewType)
		_mobile_resource_list.Page = 1; //페이지 초기화
	
	var sun = "";
	var sDate = "";
	var eDate = "";
	
	var startDateObj = new Date(mobile_resource_ReplaceDate(g_startDate));
	
	if(type == "D"){		//일간 보기
		if(g_startDate == "" || g_startDate == undefined || ((g_viewType == "W" || g_viewType == "L") && (Number(g_month)-1) == _mobile_resource_common.CurrentTime.getMonth())
				|| (g_viewType == "W" && (new Date(mobile_resource_ReplaceDate(g_startDate)).getTime() <= _mobile_resource_common.CurrentTime.getTime() && new Date(mobile_resource_ReplaceDate(g_endDate)).getTime() >= _mobile_resource_common.CurrentTime.getTime()))){
			if(_mobile_resource_common.IsScheduleMode == "Y"){
				sDate = _mobile_resource_common.IsScheduleStartDate;
			} else {
				sDate = mobile_resource_SetDateFormat(_mobile_resource_common.CurrentTime, '.');
			}
			eDate = sDate;
		}else{
			sDate = g_startDate;
			eDate = sDate;
		}
	} else if(type == "W"){		//주간 보기
		if((g_viewType == "D" || g_viewType == "L"|| g_viewType == "W") && (Number(g_month)-1) == _mobile_resource_common.CurrentTime.getMonth()){
			if(_mobile_resource_common.IsScheduleMode == "Y"){
				sun = mobile_resource_GetSunday(_mobile_resource_common.IsScheduleStartDate);
			} else {
				sun = mobile_resource_GetSunday(_mobile_resource_common.CurrentTime);
			}
			sDate = mobile_resource_SetDateFormat(sun, '.');
			eDate = mobile_resource_SetDateFormat(mobile_resource_AddDays(sDate, 6), '.');
		}else{
			sun = mobile_resource_GetSunday(new Date(mobile_resource_ReplaceDate(g_startDate)));
			sDate = mobile_resource_SetDateFormat(sun, '.');
			eDate = mobile_resource_SetDateFormat(mobile_resource_AddDays(sDate, 6), '.');
		    
		    // 일 -> 주 -> 월을 변경시 달이 바뀌는 것 처리를 위해
            if (sDate.replace(/\//gi, "").replace(/\./gi, "").substring(0, 6) != g_startDate.replace(/\//gi, "").replace(/\./gi, "").substring(0, 6))
            {
            	sDate = g_startDate.substring(0, 7) + ".01";
            }
		}
	} else if(type == "W" || type == "L"){ 		//월간 및 목록보기
		sDate = mobile_resource_SetDateFormat(new Date(g_year, (g_month - 1), 1), '.');
		eDate = mobile_resource_SetDateFormat(new Date(g_year, g_month, 0), '.')
//		if(g_viewType == "M" || g_viewType == "L"){
//			sDate = g_startDate;
//			eDate = g_endDate;
//		}else{
//			
//		}
	} else if(type == "P" || type == "R") { //나의 자원예약
		var today = mobile_resource_SetDateFormat(_mobile_resource_common.CurrentTime, '.');
		sDate = mobile_resource_SetDateFormat(mobile_resource_AddDays(today, 0), '.');
		eDate = mobile_resource_SetDateFormat(mobile_resource_AddDays(today, 30), '.');
	} else if(type == "PREV"){		// 이전
		if(g_viewType == "D"){
			sDate = mobile_resource_SetDateFormat(mobile_resource_AddDays(startDateObj, -1), '.');
			eDate = sDate;
		}else if(g_viewType == "W"){
			sDate = mobile_resource_SetDateFormat(mobile_resource_AddDays(startDateObj, -7), '.');
			eDate = mobile_resource_SetDateFormat(mobile_resource_AddDays(startDateObj, -1), '.');
		}else if(g_viewType == "M" || g_viewType == "L"){
			eDate = mobile_resource_SetDateFormat(mobile_resource_AddDays(startDateObj.setDate(1), -1), '.');
			sDate = mobile_resource_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()-1)).setDate(1), '.');
		}
		type = g_viewType;
	} else if(type == "NEXT"){		// 다음
		if(g_viewType == "D"){
			sDate = mobile_resource_SetDateFormat(mobile_resource_AddDays(startDateObj, 1), '.');
			eDate = sDate;
		}else if(g_viewType == "W"){
			sDate = mobile_resource_SetDateFormat(mobile_resource_AddDays(startDateObj, 7), '.');
			eDate = mobile_resource_SetDateFormat(mobile_resource_AddDays(startDateObj, 13), '.');
		}else if(g_viewType == "M" || g_viewType == "L"){
			sDate = mobile_resource_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+1)).setDate(1), '.');
			eDate = mobile_resource_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+1)).setDate(0), '.');
		}
		type = g_viewType;
	}
	
	_mobile_resource_common.StartDate = sDate;
	_mobile_resource_common.EndDate = eDate;
	
	if(type != undefined) {
		_mobile_resource_common.ViewType = type;
	}
	
	//자원 목록 생성 데이터 조회
	mobile_resource_MakeResourceList();

	//상단 조회 타입명 셋팅
	mobile_resource_getTopMenuName();
}

//자원 목록 생성 데이터 조회
function mobile_resource_MakeResourceList(){	
	var folderID = _mobile_resource_common.FolderCheckList;
	
	if($("#resource_list_placeOfBusiness").val() != null) {
		folderID = "";
		$("#resource_list_resourceList").find("input[type=checkbox]:checked").each(function() {
			folderID += $(this).val() + ";";
		});
	}
	
	if(folderID == ";") folderID = "";
	
	mobile_comm_showload();
	
	var approvalState = "Approval;ApprovalCancel;ApprovalDeny;ApprovalRequest;AutoCancel;Reject;ReturnComplete;ReturnRequest";
	var requestFolderList = ";";
	var mode = "";
	var params = [];
	if(_mobile_resource_list.SearchText != "") { // 검색
		mode = "List";
		params = {
			"mode" : "List",
			"StartDate": CFN_TransServerTime(mobile_resource_SetDateFormat(mobile_resource_AddDays(_mobile_resource_common.CurrentTime, -30), '-') + ' 00:00'),
			"EndDate": CFN_TransServerTime(mobile_resource_SetDateFormat(mobile_resource_AddDays(_mobile_resource_common.CurrentTime, 31),'-') + ' 00:00'),
			"ApprovalState" : approvalState,
			"searchDateType" : "BookingDate",
			"SearchText" : _mobile_resource_list.SearchText,
			"pageNo" : _mobile_resource_list.Page,
			"pageSize" : _mobile_resource_list.PageSize
		};
	} else if(_mobile_resource_common.ViewType == "P") { // 나의 자원예약
		mode = "List";
		var dStartDate = new Date(_mobile_resource_common.CurrentTime);
		var dEndDate = new Date(_mobile_resource_common.CurrentTime);
		dEndDate.setDate(dEndDate.getDate() + 30);					
		
		params = {
			"mode" : "List",
			"userID" : _mobile_resource_common.userCode,
			"StartDate": CFN_TransServerTime(mobile_resource_SetDateFormat(dStartDate, '-') + ' 00:00'),
			"EndDate": CFN_TransServerTime(mobile_resource_SetDateFormat(mobile_resource_AddDays(dEndDate, 1),'-') + ' 00:00'),
			"searchDateType" : "BookingDate",
			"ApprovalState" : approvalState,
			"pageNo" : _mobile_resource_list.Page,
			"pageSize" : _mobile_resource_list.PageSize
		};
		
		$("div").removeClass("resource_pro_wrap");
		$("#resource_list_list").removeClass("resource_pro_container");
		$("#resource_list_list").addClass("resource_list");
	} else if(_mobile_resource_common.ViewType == "R") { // 승인/반납 요청
		$.ajax({
		    url: "/groupware/mobile/resource/getManageInfo.do",
		    type: "POST",
		    async:false,
		    data: {},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		$(res.list).each(function(){
		    			requestFolderList += this.FolderID + ";";
		    		});
		    	} else {
		    		alert(mobile_comm_getDic("msg_apv_030"));
		    	}
		    },
		    error:function(response, status, error){
		    	mobile_comm_ajaxerror("/groupware/mobile/resource/getManageInfo.do", response, status, error);
		    }
		});
		mode = "List";
		params = {
			"mode" : "List",
			"FolderID" : requestFolderList,
			"ApprovalState" : approvalState,
			"pageNo" : _mobile_resource_list.Page,
			"pageSize" : _mobile_resource_list.PageSize
		};
		$("div").removeClass("resource_pro_wrap");
		$("#resource_list_list").removeClass("resource_pro_container");
		$("#resource_list_list").addClass("resource_list");
	} else if(_mobile_resource_common.ViewType == "L") { //목록보기
		mode = "List";
		params = {
			"mode" : "List",
	    	"FolderID" : folderID,
	    	"StartDate": CFN_TransServerTime(mobile_resource_SetDateFormat(_mobile_resource_common.StartDate, '-') + ' 00:00'),
			"EndDate": CFN_TransServerTime(mobile_resource_SetDateFormat(mobile_resource_AddDays(_mobile_resource_common.EndDate, 1),'-') + ' 00:00'),
			"searchDateType" : "BookingDate",
			"pageNo" : _mobile_resource_list.Page,
			"pageSize" : _mobile_resource_list.PageSize
		}
		$("#resource_list_list").css("padding-bottom", "96px");
		$(".resource_pro_topselect").css("display","none");
		$("div").removeClass("resource_pro_wrap");
		$("#resource_list_list").removeClass("resource_pro_container");
		$("#resource_list_list").addClass("resource_list");
		$(".calendar_wrap").show();
		$(".slide_bar").show();
	} else { // 월간, 주간, 일간		
		params = {
			"mode" : _mobile_resource_common.ViewType,
	    	"FolderID" : folderID,
			"StartDate": CFN_TransServerTime(mobile_resource_SetDateFormat(_mobile_resource_common.StartDate, '-') + ' 00:00'),
			"EndDate": CFN_TransServerTime(mobile_resource_SetDateFormat(mobile_resource_AddDays(_mobile_resource_common.EndDate, 1),'-') + ' 00:00')
		};
		$("#resource_list_list").addClass("resource_pro_container");
		$("#resource_pro_wrap_list").addClass("resource_pro_wrap");
		$("#resource_list_list").removeClass("resource_list");
		$("#resource_list_list").removeClass("my_list").css("padding-bottom", "96px");
		$(".resource_pro_topselect").css("display","block");		
		$(".calendar_wrap").show();
		$(".slide_bar").show();
        $('#resource_list_more').hide();
	} 
	
	$.ajax({
	    url: "/groupware/mobile/resource/getBookingList.do",
	    type: "POST",
	    data: params,
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		_mobile_resource_common.resourceArr = {};
				_mobile_resource_common.bookingresourceArr = {};

	    		if(typeof(res.data) != "undefined" && typeof(res.data.folderList) != "undefined") {
	    			$.each(res.data.folderList, function(_idx, el){
						_mobile_resource_common.resourceArr[el.FolderID] = el;
					});
	    		}

				if(typeof(res.list) != "undefined") {
					$.each(res.list, function(_idx, el){
						_mobile_resource_common.bookingresourceArr[el.FolderID] = el;
					});
				}
				
	    		mobile_comm_hideload();
	    		
	    		if(_mobile_resource_common.ViewType == "M"){
					$.each(res.data.bookingList, function(idx, el){
						el.StartDateTime = CFN_TransLocalTime(el.StartDateTime, 'yyyy-MM-dd HH:mm');
						el.StartDate = el.StartDateTime.split(' ')[0];
						el.StartTime = el.StartDateTime.split(' ')[1];
						el.EndDateTime = CFN_TransLocalTime(el.EndDateTime, 'yyyy-MM-dd HH:mm');
						el.EndDate = el.EndDateTime.split(' ')[0];
						el.EndTime = el.EndDateTime.split(' ')[1];
					});
							
    				if(res.data.bookingList.length > 0)
    					mobile_resource_MakeMonthResourceListHtml(res.data.bookingList);
	    		} else if(mode == "List") { //목록보기, 나의 자원예약, 승인/반납 요청, 검색
	    			if(_mobile_resource_common.ViewType != "L") {
	    				$(".calendar_wrap").hide();
	    				$(".slide_bar").hide();
	    			} else {
	    				$("#resource_list_datetitle").html(_mobile_resource_common.StartDate.split(".")[0] + "." + _mobile_resource_common.StartDate.split(".")[1]);
	    			}

					$.each(res.list, function(idx, el){
						el.StartDateTime = CFN_TransLocalTime(el.StartDateTime, 'yyyy-MM-dd HH:mm');
						el.StartDate = el.StartDateTime.split(' ')[0];
						el.StartTime = el.StartDateTime.split(' ')[1];
						el.EndDateTime = CFN_TransLocalTime(el.EndDateTime, 'yyyy-MM-dd HH:mm');
						el.EndDate = el.EndDateTime.split(' ')[0];
						el.EndTime = el.EndDateTime.split(' ')[1];
					});
	    			
	    			if(res.list.length > 0) {
	    				_mobile_resource_list.TotalCount = res.page.listCount;
	    				
	    				mobile_resource_MakeListResourceListHtml(res.list);
		    			
		    			if (Math.min((_mobile_resource_list.Page) * _mobile_resource_list.PageSize, _mobile_resource_list.TotalCount) == _mobile_resource_list.TotalCount) {
		    				_mobile_resource_list.EndOfList = true;
			                $('#resource_list_more').hide();
			            } else {
			                $('#resource_list_more').show();
			            }
		    			
	    			} else if(res.page.listCount == 0) {	    				
	    				var sHtml = "";
	    				sHtml += "<div class=\"no_list\">";
	    				sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>"; //조회할 목록이 없습니다.
	    				sHtml += "</div>";
	    				
	    				if(_mobile_resource_list.SearchText == "")
	    					$('#resource_list_list').html(sHtml);
	    				else
	    					$('#resource_list_searchlist').html(sHtml);
	    				
	    				$("#resource_list_more").hide();
	    			}
	    		} else{
	    			if(typeof(res.data.folderList) != "undefined") {
	    				$.each(res.data.folderList, function(folderIdx, folderEl){
							$.each(folderEl.bookingList, function(idx, el){
								el.StartDateTime = CFN_TransLocalTime(el.StartDateTime, 'yyyy-MM-dd HH:mm');
								el.StartDate = el.StartDateTime.split(' ')[0];
								el.StartTime = el.StartDateTime.split(' ')[1];
								el.EndDateTime = CFN_TransLocalTime(el.EndDateTime, 'yyyy-MM-dd HH:mm');
								el.EndDate = el.EndDateTime.split(' ')[0];
								el.EndTime = el.EndDateTime.split(' ')[1];
							});
						});
	    			}
							
	    			if(_mobile_resource_common.ViewType == "D"){
	    				mobile_resource_MakeDayResourceListHtml(res.data);
	    			} else if(_mobile_resource_common.ViewType == "W"){
	    				mobile_resource_MakeWeekResourceListHtml(res.data);
	    			}
	    			
	    			//일정에서 넘어왔을 경우, ui 디자인 설정
	    			if (_mobile_resource_common.IsScheduleMode == "Y"){
	    				//a 태그 클릭시, 반응 없도록 처리
	    				$("table.tb_week a").removeAttr("href");
	    				//선택되었던 목록 체크
	    				var selResource = window.sessionStorage["selectedres_" + mobile_comm_getSession("UR_Code").toLowerCase()];
	    				if(selResource != undefined && selResource != ";"){
	    					var arrRes = selResource.split(";");
	    					$.each(arrRes, function(idx, v){
	    						$("input[type=checkbox][name=resource_list_chkbox][value='" + v + "'").click();
	    					});
	    				}
	    			}
	    		}
	    	} else {
				alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
			}
        },
        error:function(response, status, error){
        	mobile_comm_ajaxerror("/groupware/mobile/resource/getBookingList.do", response, status, error);
		}
	});
}

//일간보기 자원 영역 HTML
function mobile_resource_MakeDayResourceListHtml(data){
	$("#resource_list_datetitle").html(_mobile_resource_common.StartDate.replace(/-/gi, "."));
	
	var timeStart = 0;
    var timeEnd = 24;
	
	var folderList = data.folderList;
	
	var sHtml = "";
	var tHtml = "";
	var class_name = "";
	var flag_state = "";
	
			tHtml += "		<div class=\"tb_desc\">";
			tHtml += "			<select id=\"resource_list_timeselect_\" onchange=\"mobile_resource_changeTimeSelect(this);\" class=\"resource_pro_title_select\">";
			tHtml += "				<option value=\"seltime_before\">00 ~ 09</option>";
			tHtml += "				<option value=\"seltime_working\" selected>09 ~ 18</option>";
			tHtml += "				<option value=\"seltime_after\">14 ~ 23</option>";
			tHtml += "			</select> " + mobile_comm_getDic("lbl_Hour");;
			tHtml += "			<div class=\"resource_pro_view\">";
			tHtml += "			<p class=\"resource_pro_reserv1\">" + mobile_comm_getDic("lbl_resource_bookingHalf") + "</p>"; //부분예약
			tHtml += "			<p class=\"resource_pro_reserv2\">" + mobile_comm_getDic("lbl_resource_bookingComlete") + "</p>"; //예약완료
			tHtml += "			<p class=\"resource_pro_reserv3\">" + mobile_comm_getDic("lbl_resource_MyBooking") + "</p>"; //나의예약
			tHtml += "		</div>";
			tHtml += "		</div>";
	$(folderList).each(function(x, folder){
		
		var resource_list_trBefore1 = "";
		var resource_list_trBefore2 = "";
		var resource_list_trWorking1 = "";
		var resource_list_trWorking2 = "";
		var resource_list_trAfter1 = "";
		var resource_list_trAfter2 = "";
		flag_state = "N";
		
		var bookingList = this.bookingList;
		if(folder.FolderType.indexOf("Resource") > -1) {
			class_name = mobile_resource_getClassName(folder.FolderType.replace("Resource.", ""));
			
			for(var i = timeStart; i<(timeEnd); i++){
				var g_startDate = _mobile_resource_common.StartDate.replace(/-/gi, '.');
				var tempDate = new Date(new Date(mobile_resource_ReplaceDate(g_startDate)).getTime() + (i*60*60000));
				var timezone = 0; //tempDate.getTimezoneOffset() / 60;
		    	var hour = mobile_resource_AddFrontZero(Number(tempDate.getHours()+timezone), 2);

		    	var min = mobile_resource_AddFrontZero(tempDate.getMinutes(), 2);
		    	var time = hour + ":" + min;
				
		        var sDefaultDate = g_startDate;   				// Cell의 날짜
		        var nTargetStart = 0;       // Cell의 시작 값(분)
		        var nTargetEnd = 0;         // Cell의 종료 값(분)
		        var nTimeStep = 60;         // 1개 Cell별 기본 값(분)

		        var sDateIDs_All = "";   // 전체 Cell의 예약 ID(;으로 구분)
		        var sDateIDs_My = "";    // 나의 Cell의 예약 ID(;으로 구분)
		        var sPossible_All = "N";  // 전체 Cell의 상태(F=예약불가/H=부분예약가능/N=예약가능)
		        var sPossible_My = "N";   // 나의 Cell의 상태(Y=예약가능/N=예약가능)
		        var isDecide_All = false;  // 전체 Cell의 상태 결정 여부
		        var isNextSame = false;    // 나의 Cell의 상태 결정 여부
		        
		        var sEventIDs_All = "";
		        var sRepeatIDs_All = "";
		        var sIsRepeats_All = "";
				var sMyRegisterCode = "";

		        var nStart = 0;             // 예약별 시작 값(분)
		        var nEnd = 0;               // 예약별 종료 값(분)
				
		        var pStrBookingType = folder.BookingType;		//TODO
		        
	            nTargetStart = i * nTimeStep;
	            nTargetEnd = (i + 1) * nTimeStep;
	            
	            var bookingListLen = bookingList.length;
	            
	            var nTemp = 0;
				
				$(bookingList).each(function(j, book){
					if (!isNextSame)
	                {
	                    nStart = 0;
	                    if (sDefaultDate == this.StartDate.replace(/-/gi, '.')){
	                        nStart = (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getMinutes());
	                    }
	                    if (sDefaultDate == this.EndDate.replace(/-/gi, '.')){
	                        nEnd = (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes());
	                    }else{
	                        nEnd = 1440;			//TODO
	                    }
	                }

					var thisStartTime = (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getMinutes());//예약 시작 시간
					var thisEndTime = (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes());//예약 끝나는 시간
					//nTargetStart = cell의 시작 시간
					//nTargetEnd = cell의 끝나는 시간
					if(!(thisEndTime <= nTargetStart || thisStartTime >= nTargetEnd)){
		                sEventIDs_All += this.EventID + ";";
	                	sDateIDs_All += this.DateID + ";";
	                	sRepeatIDs_All += this.RepeatID + ";";
	                	sIsRepeats_All += this.IsRepeat + ";";
						sMyRegisterCode += this.RegisterCode + ";"; 
					};
 	
	            	// 조회 영역 밖
	                if (!((nEnd <= nTargetStart) || (nTargetEnd <= nStart))) {
						for (var i = 0; i < sMyRegisterCode.split(';').length; i++) {
							var RegisterCode = sMyRegisterCode.split(';')[i];
						    if (RegisterCode == _mobile_resource_common.userCode) {
						    	sPossible_My = "Y";
						     }
						 };
	                        
	                    if (!isDecide_All){
	                    	if (nStart <= nTargetStart){
	                            // 진행중
	                            if (nTargetEnd <= nEnd){
	                                // 아직 끝나지 않음
	                                sPossible_All = "F";
	                                isDecide_All = true;
	                                isNextSame = false;
	                            }
	                            else{
	                                // 중간에 끝나서 다음 예약 확인
	                                nTemp = j + 1;
	                                do{
	                                    if (nTemp < bookingListLen){
	                                        if (((new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getMinutes()) <= nEnd) &&
	                                            (nEnd <= (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes())))
	                                        {
	                                            isNextSame = true;
	                                            if (sDefaultDate == this.EndDate.replace(/-/gi, '.'))
	                                            {
	                                                nEnd = (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes());
	                                            }
	                                            else
	                                            {
	                                                nEnd = 1440;
	                                            }
	                                            nTemp++;
	                                        }
	                                        else{
	                                            sPossible_All = "H";
	                                            isDecide_All = true;
	                                            isNextSame = false;
	                                            break;
	                                        }
	                                    }
	                                    else{
	                                        sPossible_All = "H";
	                                        isDecide_All = true;
	                                        isNextSame = false;
	                                        break;
	                                    }
	                                }while (((new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getMinutes()) <= nEnd) &&
	                                        (nEnd < (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes())));
	                            }
	                        }
	                        else if (nTargetStart < nStart){
	                            // 중간에 시작
	                            if (nTargetEnd <= nEnd){
	                                // 아직 끝나지 않음
	                                sPossible_All = "H";
	                                isDecide_All = true;
	                                isNextSame = false;
	                            }
	                            else{
	                                // 중간에 끝나서 다음 예약 확인
	                                nTemp = j + 1;
	                                do{
	                                    if (nTemp < bookingListLen){
	                                        if (((new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getMinutes()) <= nEnd) &&
	                                            (nEnd <= (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes())))
	                                        {
	                                            isNextSame = true;
	                                            if (sDefaultDate == this.EndDate.replace(/-/gi, '.')){
	                                                nEnd = (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes());
	                                            }
	                                            else{
	                                                nEnd = 1440;
	                                            }
	                                            nTemp++;
	                                        }
	                                        else{
	                                            sPossible_All = "H";
	                                            isDecide_All = true;
	                                            isNextSame = false;
	                                            break;
	                                        }
	                                    }
	                                    else{
	                                        sPossible_All = "H";
	                                        isDecide_All = true;
	                                        isNextSame = false;
	                                        break;
	                                    }
	                                }while (((new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getMinutes()) <= nEnd) &&
	                                        (nEnd < (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes())));
	                            }
	                        }
	                    	
	                    	// 최소 부분예약 가능 체크
	                    	// 220712 최소부분예약은 사용하지 않고 있어 로직 주석처리
	                    /*	if(sPossible_All == "H"){
	                    		var diffTargetStart = Math.abs(nTargetStart - nStart);
	                    		var diffTargetEnd = Math.abs(nTargetEnd - nEnd);
	                        	var partRentalTime = folder.LeastPartRentalTime == "0" ? "30" : folder.LeastPartRentalTime;

	                        	if(diffTargetStart <= partRentalTime || diffTargetEnd <= partRentalTime)
	                        		sPossible_All = "F";
	                    	}*/
	                    }
	                }
				});
				
				var resourceListHTML = "";
				
				/*if(i%2 == 0)
					resourceListHTML += '<td>';*/
				
				var className = "resource_pro_part_r";
				var className2 = "resource_pro_part_b";
				
	        	//나의예약 부분예약
	        	if(sPossible_My == "Y" && sPossible_All == "H"){
	        		//className = "resource_pro_part_r";
					resourceListHTML += '<td time="'+time+'" class="'+className+'" onclick="showBookingList(\'' + folder.FolderID +'\', \'' + sEventIDs_All + '\');">';
					resourceListHTML += '<div class="resource_pro_my_r"></div>';
				}//부분예약
				else if (sPossible_All == "H"){
						resourceListHTML += '<td time="'+time+'" class="'+className+'" onclick="showBookingList(\'' + folder.FolderID +'\', \'' + sEventIDs_All + '\');">';
						resourceListHTML += '<a eventid="'+sEventIDs_All+'" dateid="'+sDateIDs_All+'" repeatid="'+sRepeatIDs_All+'" isrepeat="'+sIsRepeats_All+'"></a>';
				}
				//나의예약 예약불가
				else if(sPossible_My == "Y" && sPossible_All == "F"){
	            		resourceListHTML += '<td onclick="showBookingList(\'' + folder.FolderID +'\', \'' + sEventIDs_All + '\');">';
	            		resourceListHTML += '<div class="'+className2+'" style="width:100%; height:100%;"></div>';
						resourceListHTML += '<div class="resource_pro_my_r"></div>';
				}
				//예약불가
				else if(sPossible_All == "F"){
	            		resourceListHTML += '<td onclick="showBookingList(\'' + folder.FolderID +'\', \'' + sEventIDs_All + '\');">';
	            		resourceListHTML += '<div class="'+className2+'" style="width:100%; height:100%;"></div>';
				}//예약가능
				else{
					//예약 불가 상태의 자원일 경우
	                if (pStrBookingType == "ApprovalProhibit"){
						resourceListHTML += '<td style="background:#f4f4f4"></td>'
	                } else {
	                	if(_mobile_resource_common.IsScheduleMode == "Y"){
	                		resourceListHTML += '<td time="'+time+'">';
	                	} else {
	                		resourceListHTML += '<td time="'+time+'" onclick="javascript: mobile_resource_clickwrite(\'' + g_startDate + '\', \'' + time + '\', \'' + folder.FolderID + '\', \'' + folder.DisplayName + '\');">';
	                	}
						resourceListHTML += '<div style="width:100%; height: 100%; background-color: transparent;"><div>';
	                }
	                flag_state = "Y";
				}
	            resourceListHTML += "</td>";
				//if(i%2 == 1)
					
	            if(i >= 0 && i <= 4)
	            	resource_list_trBefore1 += resourceListHTML; 
	            if(i >= 5 && i <= 9)
	            	resource_list_trBefore2 += resourceListHTML;
	            if(i >= 9 && i <= 13)
	            	resource_list_trWorking1 += resourceListHTML;
	            if(i >= 14 && i <= 18) {
	            	resource_list_trWorking2 += resourceListHTML;
	            	resource_list_trAfter1 += resourceListHTML;
	            }
	            if(i >= 19 && i <= 24) 
	            	resource_list_trAfter2 += resourceListHTML;
			}
			
			sHtml += "<li class=\"resource_pro_list\">";
			sHtml += "	<div class=\"detail\" id=\"resource_list_detail_" + folder.FolderID + "\" style=\"display:block;\">";
			
			if (pStrBookingType == "ApprovalProhibit"){
				sHtml += "	<a onclick=\"javascript: alert('"+mobile_comm_getDic("msg_cannotpossiblereservationresource")+"');\">";
				flag_state = "N";
			}else{
				//sHtml += "	<a onclick=\"javascript: mobile_resource_showORhide(this);\">";		
			}
			
			sHtml += "		<div class=\"resource_pro_title\">";
			if(_mobile_resource_common.IsScheduleMode == "Y"){
				sHtml += "		<input id='resource_list_chk" + folder.FolderID + "' type='checkbox' name='resource_list_chkbox' value='" + folder.FolderID +"' label='" + folder.DisplayName + "' data-least-rental-time='"+folder.LeastRentalTime+"' "+(flag_state == "N" ? "disabled=\"disabled\"" : "")+">";
				sHtml += "		<label for='resource_list_chk" + folder.FolderID + "'>";
			}
			
			sHtml += "			<span class=\"resource_pro_bigtitle\">";
			sHtml += "				<span class=\"" + class_name + "\"></span>";
			sHtml += 				folder.DisplayName;
			sHtml += "			</span>";
			sHtml += "			<span class=\"resource_pro_smalltitle\">";
			sHtml += 				folder.ParentFolderName;
			sHtml += "			</span>";
			
			//sHtml += "			<span>" + folder.DisplayName + "</span>";
			if(_mobile_resource_common.IsScheduleMode == "Y"){
				sHtml += "		</label>";
			}
			sHtml += "		</div>";
			//sHtml += "		<span class=\"flag_state " + (flag_state == "N" ? "disable" : "") + "\">" + (flag_state == "Y" ? mobile_comm_getDic("lbl_Possible") : mobile_comm_getDic("lbl_Impossible")) + "</span>"; //예약가능, 예약불가
			sHtml += "	</a>";
			
			
			sHtml += "		<table class=\"tb_week tb_time resource_pro_table\" id=\"resource_list_tblBefore_\" style=\"display:none;\">";
			sHtml += "			<caption>" + mobile_comm_getDic("lbl_TodayBooking") + "</caption>"; //예약현황
			sHtml += "			<tbody>";
			sHtml += "				<tr>" + resource_list_trBefore1 + resource_list_trBefore2 +"</tr>"; //(<td>(<a></a>)*4</td>)*5 
			sHtml += "				<tr>";
			sHtml += "					<td scope=\"col\">00</td><td scope=\"col\">01</td><td scope=\"col\">02</td><td scope=\"col\">03</td><td scope=\"col\">04</td><td scope=\"col\">05</td><td scope=\"col\">06</td><td scope=\"col\">07</td><td scope=\"col\">08</td><td scope=\"col\">09</td>";
			sHtml += "				</tr>";
			sHtml += "			</tbody>";
			sHtml += "		</table>";
			sHtml += "		<table class=\"tb_week tb_time resource_pro_table\" id=\"resource_list_tblWorking_\">";
			sHtml += "			<caption>" + mobile_comm_getDic("lbl_TodayBooking") + "</caption>";
			sHtml += "			<tbody>";
			sHtml += "				<tr>" + resource_list_trWorking1 + resource_list_trWorking2 +"</tr>";
			sHtml += "				<tr>";
			sHtml += "					<td scope=\"col\">09</td><td scope=\"col\">10</td><td scope=\"col\">11</td><td scope=\"col\">12</td><td scope=\"col\">13</td><td scope=\"col\">14</td><td scope=\"col\">15</td><td scope=\"col\">16</td><td scope=\"col\">17</td><td scope=\"col\">18</td>";
			sHtml += "				</tr>";
			sHtml += "				<tr>" +  "</tr>";
			sHtml += "			</tbody>";
			sHtml += "		</table>";
			sHtml += "		<table class=\"tb_week tb_time resource_pro_table\" id=\"resource_list_tblAfter_\" style=\"display:none;\">";
			sHtml += "			<caption>" + mobile_comm_getDic("lbl_TodayBooking") + "</caption>";
			sHtml += "			<tbody>";
			sHtml += "				<tr>" + resource_list_trAfter1 + resource_list_trAfter2 +"</tr>";
			sHtml += "				<tr>";
			sHtml += "					<td scope=\"col\">14</td><td scope=\"col\">15</td><td scope=\"col\">16</td><td scope=\"col\">17</td><td scope=\"col\">18</td><td scope=\"col\">19</td><td scope=\"col\">20</td><td scope=\"col\">21</td><td scope=\"col\">22</td><td scope=\"col\">23</td>";
			sHtml += "				</tr>";
			sHtml += "			</tbody>";
			sHtml += "		</table>";
			sHtml += 		mobile_resource_getBookingList(bookingList);
			sHtml += "	</div>";			
			sHtml += "</li>";
		}
	});
	
	if(sHtml.trim().length == 0) {
		sHtml = "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	$("#resource_list_list").html(sHtml).trigger("create");
	$(".resource_pro_timeselect").html(tHtml);
}

//주간보기 자원 영역 HTML
function mobile_resource_MakeWeekResourceListHtml(data) {
	
	var month = mobile_comm_getDic("lbl_Month_" + parseInt(_mobile_resource_common.StartDate.split('.')[1]));
	var week = mobile_resource_getWeek().toString();
	switch(week) {
		case "1" : week = mobile_comm_getDic("lbl_First"); break;
		case "2" : week = mobile_comm_getDic("lbl_Second"); break;
		case "3" : week = mobile_comm_getDic("lbl_Third"); break;
		case "4" : week = mobile_comm_getDic("lbl_Forth"); break;
		case "5" : week = mobile_comm_getDic("lbl_Fifth"); break;
		default: break;
	}
	
	if(_mobile_resource_common.lang == "en") {
		//$("#resource_list_datetitle").html(month + ", " + (_mobile_resource_common.StartDate.split(".")[0]) + " " + ("The " + week + " week"));
		$("#resource_list_datetitle").html((_mobile_resource_common.StartDate.replace(/-/gi, ".")) + " ~ " + (_mobile_resource_common.EndDate.split(".")[1])+ "." + (_mobile_resource_common.EndDate.split(".")[2]));
	} else if(_mobile_resource_common.lang == "ko") {
		$("#resource_list_datetitle").html((_mobile_resource_common.StartDate.replace(/-/gi, ".")) + " ~ " + (_mobile_resource_common.EndDate.split(".")[1])+ "." + (_mobile_resource_common.EndDate.split(".")[2]));
	}
  
	var folderList = data.folderList;
	
	var sDefaultDate = "";   // Cell의 날짜
	var nTargetStart = 0;       // Cell의 시작 값(분)
	var nTargetEnd = 0;         // Cell의 종료 값(분)
	
	var sDateIDs_All = "";   // 전체 Cell의 예약 ID(;으로 구분)
	var sDateIDs_My = "";    // 나의 Cell의 예약 ID(;으로 구분)
	var sPossible_All = "";  // 전체 Cell의 상태(F=예약불가/H=부분예약가능/N=예약가능)
	var sPossible_My = "";   // 나의 Cell의 상태(Y=예약가능/N=예약가능)
	var isDecide_All = false;  // 전체 Cell의 상태 결정 여부
	var isNextSame = false;    // 나의 Cell의 상태 결정 여부
	
	var sEventIDs_All = "";
    var sRepeatIDs_All = "";
    var sIsRepeats_All = "";

	var nStart = 0;             // 예약별 시작 값(분)
  	var nEnd = 0;               // 예약별 종료 값(분)
	
	var sHtml = "";
	var tHtml = "";
	var class_name = "";
	var flag_state = "";
	var g_startDate = _mobile_resource_common.StartDate.replace(/-/gi, '.');
	
			tHtml += "		<div class=\"resource_pro_view\">";
			tHtml += "			<p class=\"resource_pro_reserv1\">" + mobile_comm_getDic("lbl_resource_bookingHalf") + "</p>"; //부분예약
			tHtml += "			<p class=\"resource_pro_reserv2\">" + mobile_comm_getDic("lbl_resource_bookingComlete") + "</p>"; //예약완료
			tHtml += "			<p class=\"resource_pro_reserv3\">" + mobile_comm_getDic("lbl_resource_MyBooking") + "</p>"; //나의예약
			tHtml += "		</div>";
	
	$(folderList).each(function(x, folder){
		
		var resource_list_trWeek = "";
		
		flag_state = "N";
		
		var bookingList = this.bookingList;
	    var nBookingLength = bookingList.length;
		var pStrBookingType = this.BookingType;
		
		if(folder.FolderType.indexOf("Resource") > -1) {
			class_name = mobile_resource_getClassName(folder.FolderType.replace("Resource.", ""));
			
			for(var k=0; k<7; k++){
				
				sDefaultDate = mobile_resource_SetDateFormat(mobile_resource_AddDays(g_startDate, k), '.');
				
	        	sEventIDs_All = "";
	            sRepeatIDs_All = "";
	            sDateIDs_All = "";
	            sIsRepeats_All = "";
	            
	            sPossible_All = "N";
	            sPossible_My = "N";
	            isDecide_All = false;
	            isNextSame = false;

	            nTargetStart = 0;
	            nTargetEnd = 1440;
			
	            $(bookingList).each(function(j){
	                if (!((new Date(mobile_resource_ReplaceDate(this.EndDateTime)) <= mobile_resource_AddDays(g_startDate, k)) 
	                		|| (mobile_resource_AddDays(g_startDate, k+1) <= new Date(mobile_resource_ReplaceDate(this.StartDateTime))))) {
	                	if (!isNextSame){
		                    nStart = 0;
		                    if (sDefaultDate == this.StartDate.replace(/-/gi, ".")){
		                        nStart = (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getMinutes());
		                    }
		                    if (sDefaultDate == this.EndDate.replace(/-/gi, ".")){
		                        nEnd = (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes());
		                    }
		                    else{
		                        nEnd = 1440;
		                    }
		                }

		                if (!((nEnd <= nTargetStart) || (nTargetEnd <= nStart))) {
		                	sDateIDs_All += this.DateID + ";";
		                	sEventIDs_All += this.EventID + ";";
		                	sRepeatIDs_All += this.RepeatID + ";";
		                	sIsRepeats_All += this.IsRepeat + ";";
		                	
			                if (this.RegisterCode == _mobile_resource_common.userCode)
			                	sPossible_My = "Y";
		                	
			                if (!isDecide_All){
			                	if (nStart <= nTargetStart){
				                    // 진행중
				                    if (nTargetEnd <= nEnd){
				                        // 아직 끝나지 않음
				                        sPossible_All = "F";
				                        isDecide_All = true;
				                        isNextSame = false;
				                    }
				                    else{
				                        // 중간에 끝나서 다음 예약 확인
				                        var nTemp = j + 1;
				                        do{
				                            if (nTemp < nBookingLength){
				                                if ((new Date(mobile_resource_ReplaceDate(this.EndDateTime)) <= mobile_resource_AddDays(g_startDate, k)) ||
				                                    (mobile_resource_AddDays(g_startDate, k+1) <= new Date(mobile_resource_ReplaceDate(this.StartDateTime))))
				                                {
				                                    sPossible_All = "H";
				                                    isDecide_All = true;
				                                    isNextSame = false;
				                                    break;
				                                }
				                                else{
				                                    if (((new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getMinutes()) <= nEnd) &&
				                                        (nEnd <= (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes())))
				                                    {
				                                        isNextSame = true;
				                                        if (sDefaultDate == this.EndDate.replace(/-/gi, ".")){
				                                            nEnd = (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes());
				                                        }
				                                        else{
				                                            nEnd = 1440;
				                                        }
				                                        nTemp++;
				                                    }
				                                    else{
				                                        sPossible_All = "H";
				                                        isDecide_All = true;
				                                        isNextSame = false;
				                                        break;
				                                    }
				                                }
				                            }
				                            else{
				                                sPossible_All = "H";
				                                isDecide_All = true;
				                                isNextSame = false;
				                                break;
				                            }
				                        }while (((new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getMinutes()) <= nEnd) &&
				                                (nEnd <= (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes())));
				                    }
				                }
				                else if (nTargetStart < nStart){
				                    // 중간에 시작
				                    if (nTargetEnd <= nEnd){
				                        // 아직 끝나지 않음
				                        sPossible_All = "H";
				                        isDecide_All = true;
				                        isNextSame = false;
				                    }
				                    else{
				                        // 중간에 끝나서 다음 예약 확인
				                        nTemp = j + 1;
				                        do{
				                            if (nTemp < nBookingLength){
				                                if ((new Date(mobile_resource_ReplaceDate(this.EndDateTime)) <= mobile_resource_AddDays(g_startDate, k)) ||
				                                    (mobile_resource_AddDays(g_startDate, k+1) <= new Date(mobile_resource_ReplaceDate(this.StartDateTime))))
				                                {
				                                    sPossible_All = "H";
				                                    isDecide_All = true;
				                                    isNextSame = false;
				                                    break;
				                                }
				                                else{
				                                    if (((new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getMinutes()) <= nEnd) &&
				                                        (nEnd <= (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndTime)).getMinutes())))
				                                    {
				                                        isNextSame = true;
				                                        if (sDefaultDate == this.EndDate.replace(/-/gi, ".")){
				                                            nEnd = (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes());
				                                        }
				                                        else{
				                                            nEnd = 1440;
				                                        }
				                                        nTemp++;
				                                    }
				                                    else{
				                                        sPossible_All = "H";
				                                        isDecide_All = true;
				                                        isNextSame = false;
				                                        break;
				                                    }
				                                }
				                            }
				                            else{
				                                sPossible_All = "H";
				                                isDecide_All = true;
				                                isNextSame = false;
				                                break;
				                            }
				                        }while (((new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.StartDateTime)).getMinutes()) <= nEnd) &&
				                                (nEnd < (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes())));
				                    }
				                }
			                }
			                if((new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getHours() * 60) + (new Date(mobile_resource_ReplaceDate(this.EndDateTime)).getMinutes()) > 1410) { // 최소 예약시간 30분
			                	sPossible_All = "F";
			                }
		                }
	                }
	            });
				
				//resourceListHTML += "<td>";
				var resourceListHTML = "";
				var className = "resource_pro_part_r";
				var className2 = "resource_pro_part_b";
				
	        	//나의예약 부분예약
	        	if(sPossible_My == "Y" && sPossible_All == "H"){
					resourceListHTML += '<td onclick="showBookingList(\'' + folder.FolderID +'\', \'' + sEventIDs_All + '\');" class="'+className+'">';
					resourceListHTML += '<div class="resource_pro_my_r"></div>';
	            }
				//부분예약
				else if(sPossible_All == "H"){
					resourceListHTML += '<td onclick="showBookingList(\'' + folder.FolderID +'\', \'' + sEventIDs_All + '\');" class="'+className+'">';
					resourceListHTML += '<a eventid="'+sEventIDs_All+'" dateid="'+sDateIDs_All+'" repeatid="'+sRepeatIDs_All+'" isrepeat="'+sIsRepeats_All+'" ></a>';
	                	
	                flag_state = "Y";
				}
				//나의예약 예약불가
				else if(sPossible_My == "Y" && sPossible_All == "F"){
					resourceListHTML += '<td onclick="showBookingList(\'' + folder.FolderID +'\', \'' + sEventIDs_All + '\');">';
	            	resourceListHTML += '<div class="'+className2+'" style="width:100%; height:100%;"><div>';
					resourceListHTML += '<div class="resource_pro_my_r"></div>';
				}
				//예약불가
				else if(sPossible_All == "F"){
					resourceListHTML += '<td onclick="showBookingList(\'' + folder.FolderID +'\', \'' + sEventIDs_All + '\');">';
	            	resourceListHTML += '<div class="'+className2+'" style="width:100%; height:100%;"><div>';
				}
	            // 예약가능
	            else{
	            	//예약 불가 상태의 자원일 경우
	                if (pStrBookingType == "ApprovalProhibit"){
						resourceListHTML += '<td style="background:#f4f4f4"></td>';
					}
	                else
	                	if(_mobile_resource_common.IsScheduleMode == "Y"){
	                		resourceListHTML += '<td>';
	                	} else {
	                		resourceListHTML += '<td onclick="javascript: mobile_resource_clickwrite(\'' + sDefaultDate + '\', \'\', \'' + folder.FolderID + '\', \'' + folder.DisplayName + '\');">';
	                	}
	                	
	               		flag_state = "Y";
	            }
	            
	            resourceListHTML += "</td>";

          		resource_list_trWeek += resourceListHTML; 
			}
			
			var startDateObj = new Date(mobile_resource_ReplaceDate(g_startDate));
			
			//select day가 속한 주를 가져오기
		    var sun = mobile_resource_GetSunday(startDateObj);
		    var strSun = mobile_resource_SetDateFormat(sun, '/');
		    var mon = mobile_resource_AddDays(strSun, 1).getDate();
		    var tue = mobile_resource_AddDays(strSun, 2).getDate();
		    var wed = mobile_resource_AddDays(strSun, 3).getDate();
		    var thr = mobile_resource_AddDays(strSun, 4).getDate();
		    var fri = mobile_resource_AddDays(strSun, 5).getDate();
		    var sat = mobile_resource_AddDays(strSun, 6).getDate();
		    sun = sun.getDate();
			
		    var headerDateHTML = "<tr><td class=\"sun\" style=\"color:#e73333;\">" + sun + "(일)</td><td>" + mon + "(월)</td><td>" + tue + "(화)</td><td>" + wed + "(수)</td><td>" + thr + "(목)</td><td>" + fri + "(금)</td><td style=\"color:#1986e0;\">" + sat + "(토)</td></td>";
		    
			sHtml += "<li class=\"resource_pro_list\">";
			if (pStrBookingType == "ApprovalProhibit"){
				sHtml += "	<a onclick=\"javascript: alert('"+mobile_comm_getDic("msg_cannotpossiblereservationresource")+"');\">";
				flag_state = "N";
			}else{
				//sHtml += "	<a onclick=\"javascript: mobile_resource_showORhide(this);\">";	
			}
			
			sHtml += "		<div class=\"resource_pro_title\">";
			if(_mobile_resource_common.IsScheduleMode == "Y"){
				sHtml += "		<input id='resource_list_chk" + folder.FolderID + "' type='checkbox' name='resource_list_chkbox' value='" + folder.FolderID +"' label='" + folder.DisplayName + "'"+(flag_state == "N" ? "disabled=\"disabled\"" : "")+">";
				sHtml += "		<label for='resource_list_chk" + folder.FolderID + "'>";
			}
			
			sHtml += "			<span class=\"resource_pro_bigtitle\">";
			sHtml += "				<span class=\"" + class_name + "\"></span>";
			sHtml += 				folder.DisplayName;
			sHtml += "			</span>";
			sHtml += "			<span class=\"resource_pro_smalltitle\">";
			sHtml += 				folder.ParentFolderName;
			sHtml += "			</span>";
			if(_mobile_resource_common.IsScheduleMode == "Y"){
				sHtml += "		</label>";
			}
			sHtml += "		</div>";
			//sHtml += "		<span class=\"flag_state " + (flag_state == "N" ? "disable" : "") + "\">" + (flag_state == "Y" ? "예약가능" : "예약불가") + "</span>";
			sHtml += "	</a>";
			sHtml += "	<div class=\"detail\" id=\"resource_list_detail_" + folder.FolderID + "\">";		
			sHtml += "		<table class=\"tb_week resource_pro_table\" id=\"resource_list_tblWeek_" + folder.FolderID +"\">";
			sHtml += "			<caption>" + mobile_comm_getDic("lbl_TodayBooking") + "</caption>"; //예약현황	
			sHtml += "			<tbody>";
			sHtml += "				<tr>" + resource_list_trWeek + "</tr>";
			sHtml += 			headerDateHTML;
			sHtml += "			</tbody>";
			sHtml += "		</table>";
			sHtml +=		mobile_resource_getBookingList(bookingList);
			sHtml += "	</div>";			
			sHtml += "</li>";
		}
	});
	
	if(sHtml.trim().length == 0) {
		sHtml = "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	$("#resource_list_list").html(sHtml).trigger("create");
	$(".resource_pro_timeselect").html(tHtml);
}

//목록보기, 나의 자원예약, 승인/반납 요청, 검색 영역 HTML
function mobile_resource_MakeListResourceListHtml(bookingList) {
	var sHtml = "";
	var sUrl = "";
	var class_name = "";
	var isSearch = (_mobile_resource_list.SearchText != "" ? true : false);

	var listID = "resource_list_list";
	if(isSearch)
		listID = "resource_list_searchlist";
	
	$(bookingList).each(function(j, book){
		sUrl = "/groupware/mobile/resource/view.do";
		sUrl += "?eventid=" + book.EventID;
		sUrl += "&dateid=" + book.DateID;
		sUrl += "&repeatid=" + book.RepeatID;
		sUrl += "&isrepeat=" + book.IsRepeat;
		sUrl += "&resourceid=" + book.ResourceID;
		
		class_name = mobile_resource_getClassName(book.FolderType.replace("Resource.", ""));
		
		sHtml += "<li>";
		sHtml += "	<div class=\"my_detail\">";
		sHtml += "		<a onclick=\"mobile_comm_go('" + sUrl + "','Y')\" class=\"con_link\">";
		sHtml += "			<i class=\"" + class_name + "\"></i>";
		sHtml += "			<div class=\"txt_are\">";
		sHtml += "				<span class=\"flag_state\">" + book.ApprovalState + "</span>";
		sHtml += "				<dl>";
		sHtml += "					<dt>" + book.ResourceName + "</dt>";
		sHtml += "					<dd class=\"date\">" + book.StartDateTime.replace(/-/gi, ".") + " ~ " + book.EndDateTime.replace(/-/gi, ".") + "</dd>";
		if(_mobile_resource_common.ViewType != "P")
			sHtml += "				<dd class=\"name\">" + book.RegisterName + "</dd>";
		sHtml += "					<dd class=\"desc\">" + book.Subject + "</dd>";
		sHtml += "					<dd class=\"repeat\">" + (book.IsRepeat == "N" ? mobile_comm_getDic("lbl_noRepeat") : mobile_comm_getDic("lbl_Repeate")) + "</dd>"; //반복없음, 반복
		sHtml += "				</dl>";
		sHtml += "			</div>";
		sHtml += "		</a>";
		if(_mobile_resource_common.ViewType == "P") {
			if(book.ApprovalStateCode.toUpperCase() == "APPROVAL") {
				if(book.ReturnTypeCode == "ChargeConfirm" && (_mobile_resource_common.CurrentTime >= new Date(mobile_resource_ReplaceDate(book.StartDateTime))))
					sHtml += "<a onclick=\"mobile_resource_modifyBookingState(" + book.DateID + ", \'ReturnRequest\')\" class=\"btn\">" + mobile_comm_getDic("lbl_ReturnRequest") + "</a>"; //반납요청
				else
					sHtml += "<a onclick=\"mobile_resource_modifyBookingState(" + book.DateID + ", \'ApprovalCancel\')\" class=\"btn\">" + mobile_comm_getDic("lbl_ApplicationWithdrawn") + "</a>"; //신청철회
			} else if(book.ApprovalStateCode.toUpperCase() == "APPROVALREQUEST") {
				sHtml += "<a onclick=\"mobile_resource_modifyBookingState(" + book.DateID + ", \'ApprovalCancel\')\" class=\"btn\">" + mobile_comm_getDic("lbl_ApplicationWithdrawn") + "</a>"; //신청철회
			}
		} else if(_mobile_resource_common.ViewType == "R") {
			if(book.ApprovalStateCode.toUpperCase() == "APPROVALREQUEST") 
				sHtml += "<a onclick=\"mobile_resource_modifyBookingState(" + book.DateID + ", \'Approval\')\" class=\"btn\" style=\"margin-right: 45px;\">" + mobile_comm_getDic("lbl_Approval") + "</a><a onclick=\"mobile_resource_modifyBookingState(" + book.DateID + ", \'Reject\')\" class=\"btn\">" + mobile_comm_getDic("lbl_Deny") + "</a>"; //승인, 거부
			else if(book.ApprovalStateCode.toUpperCase() == "RETURNREQUEST")
				sHtml += "<a onclick=\"mobile_resource_modifyBookingState(" + book.DateID + ", \'ReturnComplete\')\" class=\"btn\">" + mobile_comm_getDic("lbl_CheckReturn") + "</a>"; //반납확인
			else if(book.ApprovalStateCode.toUpperCase() == "APPROVAL")
				sHtml += "<a onclick=\"mobile_resource_modifyBookingState(" + book.DateID + ", \'ApprovalDeny\')\" class=\"btn\">" + mobile_comm_getDic("lbl_CancelApproval") + "</a>"; //승인취소
		}
		sHtml += "	</div>";
		sHtml += "</li>";
	});

	$("#" + listID).addClass("my_list").css("padding-bottom", "0px");	
	
	if(_mobile_resource_list.Page == 1 || sHtml.indexOf("no_list") > -1)
		$("#" + listID).html(sHtml);
	else
		$("#" + listID).append(sHtml);
	
}

// 자원 Class명 가져오기
function mobile_resource_getClassName(foldertype) {
	var class_name = "";
	
	switch(foldertype) {
		case "MeetingRoom": class_name = "ico_room"; break;
		case "CamCorder": class_name = "ico_camcorder"; break;
		case "Camera": class_name = "ico_camera"; break;
		case "Car": class_name = "ico_car"; break;
		case "Clock": class_name = "ico_clock"; break;
		case "Lens": class_name = "ico_lens"; break;
		case "Monitor": class_name = "ico_monitor"; break;
		case "Navigation": class_name = "ico_navigation"; break;
		case "Projector": class_name = "ico_projector"; break;
		case "Speaker": class_name = "ico_speaker"; break;
		case "TriPod": class_name = "ico_tripod"; break;
		case "ETC": class_name = "ico_etc"; break;
	}
	return class_name;
}

// 시간 Select box에 따라 테이블 show 변경
function mobile_resource_changeTimeSelect(obj) {
	$("#resource_list_tblBefore_").hide();
	$("#resource_list_tblWorking_").hide();
	$("#resource_list_tblAfter_").hide();
	$(".BookingList").hide();
	
	if($(obj).val() == "seltime_before") {
		$(".detail #resource_list_tblBefore_").show();
		$(".detail #resource_list_tblWorking_").hide();
		$(".detail #resource_list_tblAfter_").hide();
		
	} else if($(obj).val() == "seltime_working") {
		$(".detail #resource_list_tblBefore_").hide();
		$(".detail #resource_list_tblWorking_").show();
		$(".detail #resource_list_tblAfter_").hide();
		
	} else if($(obj).val() == "seltime_after") {
		$(".detail #resource_list_tblBefore_").hide();
		$(".detail #resource_list_tblWorking_").hide();
		$(".detail #resource_list_tblAfter_").show();
	}
}


// 자원 별 예약 정보 가져오기
function mobile_resource_getBookingList(bookingList) {
	var sHtml = "";
	
	$(bookingList).each(function(j, book){
		//var temp_stime = temp_time = $("#resource_list_timeselect_" + folder.FolderID).val().split("~")[0];
		//var temp_etime = $("#resource_list_timeselect_" + folder.FolderID).val().split("~")[1];
		var selectedStartDateTime = new Date(mobile_resource_ReplaceDate(_mobile_resource_common.StartDate) + " 00:00:00");
		var selectedEndDateTime = new Date(mobile_resource_ReplaceDate(_mobile_resource_common.EndDate) + " 23:59:59");
		var bookingStartDateTime = new Date(mobile_resource_ReplaceDate(book.StartDateTime));
		var bookingEndDateTime = new Date(mobile_resource_ReplaceDate(book.EndDateTime));
		
		var diff_start_condition = false;
		var diff_end_condition = false;
		if(new Date(mobile_resource_ReplaceDate(book.StartDate)).getTime() < new Date(mobile_resource_ReplaceDate(_mobile_resource_common.StartDate)).getTime()) {
			diff_start_condeventidtion = selectedStartDateTime.getTime() >= bookingStartDateTime.getTime();
		} else if(new Date(mobile_resource_ReplaceDate(book.StartDate)).getTime() >= new Date(mobile_resource_ReplaceDate(_mobile_resource_common.StartDate)).getTime()){
			diff_start_condition = selectedStartDateTime.getTime() <= bookingStartDateTime.getTime();
		}
		if(new Date(mobile_resource_ReplaceDate(book.EndDate)).getTime() > new Date(mobile_resource_ReplaceDate(_mobile_resource_common.EndDate)).getTime()) {
			diff_end_condition = selectedEndDateTime.getTime() <= bookingEndDateTime.getTime();
		} else if(new Date(mobile_resource_ReplaceDate(book.EndDate)).getTime() <= new Date(mobile_resource_ReplaceDate(_mobile_resource_common.EndDate)).getTime()){
			diff_end_condition = selectedEndDateTime.getTime() >= bookingEndDateTime.getTime();
		}
		
		if((diff_start_condition || diff_end_condition) && bookingStartDateTime.getTime() <= bookingEndDateTime.getTime()) {	

			var sUrl = "";
			sUrl = "/groupware/mobile/resource/view.do";
			sUrl += "?eventid=" + book.EventID;
			sUrl += "&dateid=" + book.DateID;
			sUrl += "&repeatid=" + book.RepeatID;
			sUrl += "&isrepeat=" + book.IsRepeat;
			sUrl += "&resourceid=" + book.ResourceID;
			//eventID=290&dateID=281&repeatID=233&isRepeat=N&resourceID=92
			
			var state_class = "";
			if(book.ApprovalState == mobile_comm_getDic("lbl_ApprovalReq") || book.ApprovalState == mobile_comm_getDic("lbl_ReturnRequest")) { //승인요청, 반납요청
				state_class = "ask";
			} else if(book.ApprovalState == mobile_comm_getDic("lbl_Approved")) { //승인
				state_class = "app";
			} else if(book.ApprovalState == mobile_comm_getDic("lbl_res_ReturnComplete")) { //반납완료
				state_class = "appretrunreq";
			} else if(book.ApprovalState == mobile_comm_getDic("lbl_ApplicationWithdrawn")) { //신청철회
				state_class = "returncomp";
			}
			
			sHtml += "		<div class=\"divBookingListDetail_" + book.ResourceID + " BookingList\" id=\"resource_list_info_" + book.ResourceID + "\" >";
			sHtml += "			<div id=\"divBookinginfo_"+book.ResourceID+ "_" + book.EventID +"\" style=\"display:none\" eventid='" + book.EventID + "'>";
			sHtml += "				<a onclick=\"ShowBookingDetailInfo("+book.EventID+")\" class=\"resource_pro_link\">";
			sHtml += "					<span>" + book.StartDateTime.split("-")[1] + "." + book.StartDateTime.split("-")[2] + " ~ " + book.EndDateTime.split("-")[1] + "." + book.EndDateTime.split("-")[2] + "</span>";
			sHtml += "					<span>" + book.RegisterName + "</span>";
			sHtml += "					<span class=\"tx_color_g\">" + book.ApprovalState + "</span>";
			sHtml += "				</a>";
			sHtml += "			</div>";
			sHtml += "		<div class=\"resource_list info_list\" id=\"divBookingDetail_"+book.EventID+"\" style=\"display:none\">";
			sHtml += "			<a onclick=\"javascript: mobile_comm_go('" + sUrl + "','Y');\">";
			//sHtml += "			<a href=\"#\">";
			sHtml += "				<dl>";
			sHtml += "					<dt class=\"resource_pro_subtitle\" style=\"width:100%\">" + book.StartDateTime.split("-")[1] + "." + book.StartDateTime.split("-")[2] + " ~ " + book.EndDateTime.split("-")[1] + "." + book.EndDateTime.split("-")[2] + "</dt>";
			sHtml += "					<dd class=\"source_pro_subname name\">" + book.RegisterName + "</dd>";
			sHtml += "					<dd class=\"source_pro_subname place\">" + book.FolderName + "</dd>";
			sHtml += "					<dd class=\"source_pro_subname desc\">" + book.Subject + "</dd>";
			sHtml += "					<dd class=\"source_pro_subname repeat\">" + (book.IsRepeat == "N" ? mobile_comm_getDic("lbl_noRepeat") : mobile_comm_getDic("lbl_Repeate")) + "</dd>"; //반복없음, 반복
			sHtml += "					<dd class=\"state " + state_class + " source_pro_subname\">" + book.ApprovalState + "</dd>";
			sHtml += "				</dl>";
			sHtml += "			</a>";
			sHtml += "		</div>";
			sHtml += "		</div>";
		}
	});
	
	return sHtml;
}

//선택한 시간의 예약목록 보여주기
function showBookingList(ResourceID, EventID){
	$("#resource_list_info_" + ResourceID + " > div").each(function () {
        $(this).hide();
    });

    $("#resource_list_info_" + ResourceID).show();
	$("#resource_list_info_" + ResourceID + " > div > div").each(function () {
        $(this).hide();
    });

	for (var i = 0; i < EventID.split(';').length; i++) {
        var sBookingidSplit = EventID.split(';')[i];
        if (sBookingidSplit != "") {
            if ($("#divBookinginfo_" + ResourceID + "_" + sBookingidSplit).css("display") == "none") {
                $("#divBookinginfo_" + ResourceID + "_" + sBookingidSplit).show();
				$(".divBookingListDetail_" + ResourceID).show();
            }
        }
    };
}

//자원예약 상세부킹 정보 표시
function ShowBookingDetailInfo(EventID){
	if ($("#divBookingDetail_" + EventID).css("display") == "none") {
        $("#divBookingDetail_" + EventID).show();
    } else {
        $("#divBookingDetail_" + EventID).hide();
    }
}

// 자원예약 상태 변경
function mobile_resource_modifyBookingState(dateID, approvalState) {
	$.ajax({
	    url: "/groupware/mobile/resource/modifyBookingState.do",
	    type: "POST",
	    data: {
	    	"DateID" : dateID,
	    	"ApprovalState" : approvalState
		},
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		alert(mobile_comm_getDic("msg_com_processSuccess")); //성공적으로 처리되었습니다.
				if (_mobile_resource_common.ViewType == 'D'){
					mobile_comm_back();
					mobile_resource_ListInit();
				}else {
					mobile_resource_changeViewType(_mobile_resource_common.ViewType);
				}
	    	} else {
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
	    },
	    error:function(response, status, error){
	    	mobile_comm_ajaxerror("/groupware/mobile/resource/modifyBookingState.do", response, status, error);
	    }
	});
}

//더보기 클릭
function mobile_resource_nextlist () {
	
	if (!_mobile_resource_list.EndOfList) {
		_mobile_resource_list.Page++;

		mobile_resource_MakeResourceList();
    } else {
        $('#resource_list_more').hide();
    }
}

//스크롤 더보기
function mobile_resource_list_page_ListAddMore(){
	mobile_resource_nextlist();
}

//일정에서 넘어왔을 경우, "확인" 버튼 클릭 시 선택 값 바인딩
function mobile_resource_saveSelectedResource() {
	var sSelResourceHtml = "";
	
	$("input[type=checkbox][name=resource_list_chkbox]:checked").each(function(i, obj) {
		var resID = $(obj).val();
		var resName = $(obj).attr("label");
		var resLeastRentalTime = $(obj).attr("data-least-rental-time");

		var dataJson = "data-json=\'" + JSON.stringify({"label":resName,"value":resID,"leastRentalTime":resLeastRentalTime}) + "\'";
		var dataValue = "data-value=\"" + resID + "\"";
		
		sSelResourceHtml += "<a onclick=\"mobile_schedule_delUser(this);\" class=\"btn_add_resources\" " + dataJson + " " + dataValue + ">";
		sSelResourceHtml += 		resName;
		sSelResourceHtml += "</a>";
	});
	
	if(sSelResourceHtml != ""){
		$("#resourcesSelect_wrapArea").html(sSelResourceHtml).show();
		$("#resourceSelectTitle").hide();
		$("#resourcesSelect_wrapArea").parent().addClass("active");
	}
	
	mobile_comm_back()	
}

/*!
 * 
 * 자원예약 목록 끝
 * 
 */





/*!
 * 
 * 자원예약 작성 시작
 * 
 */

function mobile_resource_WriteInit() {
	if(window.sessionStorage["resource_writeinit"] == undefined)
		window.sessionStorage["resource_writeinit"] = "Y";
	
	//초기화 및 파라미터 세팅
	mobile_resource_InitJS("resource_write_page");
	
	//선택한 자원값 셋팅
	if(window.sessionStorage.getItem("ResourceWrite_SelectResource_ID_" + mobile_comm_getSession("UR_Code")) != undefined 
			&& window.sessionStorage.getItem("ResourceWrite_SelectResource_ID_" + mobile_comm_getSession("UR_Code")) != null ) {
		_mobile_resource_common.ResourceID = window.sessionStorage.getItem("ResourceWrite_SelectResource_ID_" + mobile_comm_getSession("UR_Code"));
		_mobile_resource_common.ResourceName = window.sessionStorage.getItem("ResourceWrite_SelectResource_Name_" + mobile_comm_getSession("UR_Code"));
		
		window.sessionStorage.removeItem("ResourceWrite_SelectResource_ID_" + mobile_comm_getSession("UR_Code"));
		window.sessionStorage.removeItem("ResourceWrite_SelectResource_Name_" + mobile_comm_getSession("UR_Code"));
	}
	
	//datepicker 임시
	$(".dates_date").datepicker({
		dateFormat : 'yy.mm.dd',
		dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
	});

	//시간 select box 세팅
	for(var i = 0; i < 48; i++) {
		var time = mobile_resource_AddFrontZero(parseInt(i/2), 2) + ":" + (i%2==0 ? "00" : "30");
		$("#resource_write_starttime").append("<option value='" + time + "'>" + time + "</option>");
		$("#resource_write_endtime").append("<option value='" + time + "'>" + time + "</option>");
	} 
	$("#resource_write_endtime").append("<option value='23:59'>23:59</option>");
	
	//자원 ID 및 이름 세팅
	if(_mobile_resource_common.ResourceName != "" && _mobile_resource_common.ResourceID != ""){
		$("#resource_write_resourceID").val(_mobile_resource_common.ResourceID);
		$("#resource_write_resourceName").html(_mobile_resource_common.ResourceName).css("font-size", "1em").css("color", "#222");		
	}else{
		$("#resource_write_resourceName").html(mobile_comm_getDic('msg_mustSelectRes')); //자원을 선택해주세요.
	}
	
	//예약 시작일 및 종료일 세팅 (모바일에서는 기간 범위 지정이 되지 않음)
	var pStartDate = (mobile_comm_getQueryString("startdate", "resource_write_page") != 'undefined') ? mobile_comm_getQueryString("startdate", "resource_write_page") : mobile_resource_SetDateFormat(_mobile_resource_common.CurrentTime, '.');
	var pStartTime = (mobile_comm_getQueryString("starttime", "resource_write_page") != 'undefined' && mobile_comm_getQueryString("starttime", "resource_write_page") != '') ? mobile_comm_getQueryString("starttime", "resource_write_page") : '00:00';
	var eventStartDate = new Date((pStartDate != 'undefined') ? pStartDate + ' ' +  pStartTime : CFN_GetLocalCurrentDate());
	var eventStartTime = '';
	var eventEndTime = '';

	var startMin = mobile_comm_AddFrontZero(Math.ceil((eventStartDate.getMinutes())/30)*30, 2);		
	if(startMin >= 60) {
		eventStartDate.setHours(eventStartDate.getHours() + 1);	
		startMin = mobile_comm_AddFrontZero(0, 2);
	}
		
	var startHour = mobile_comm_AddFrontZero(eventStartDate.getHours(), 2);
	
	eventStartDate.setHours(eventStartDate.getHours() + 1);
	var endHour = mobile_comm_AddFrontZero(eventStartDate.getHours(), 2);
	
	eventStartTime = (eventStartTime != '') ? eventStartTime : startHour + ':' + startMin;
	eventEndTime = endHour + ':' + startMin;
	
	$("#resource_write_startdate").val(pStartDate);
	$("#resource_write_enddate").val(pStartDate);
	$("#resource_write_starttime").val(eventStartTime);
	$("#resource_write_endtime").val(eventEndTime);
	
	//반복설정 항목 세팅
	mobile_resource_repeatSetting();

	if(_mobile_resource_common.EventID != "") {
		//수정 데이터 가져오기
		mobile_resource_getViewData("DU");
		$("#resource_write_btn_regist").hide();
		$("#resource_write_btn_modify").show();
		$("#resource_write_title").html(mobile_comm_getDic("lbl_Modify"));
	}	
}

//조직도 호출
function mobile_resource_openOrg(){
	var sUrl = "/covicore/mobile/org/list.do";
	
	window.sessionStorage["mode"] = "Select";
	window.sessionStorage["multi"] = "Y";
	window.sessionStorage["callback"] = "mobile_resource_setAttendeeAtOrgMap();";
	
	mobile_comm_go(sUrl, 'Y');
}

//조직도 콜백 함수 - 참석자
function mobile_resource_setAttendeeAtOrgMap() {
	var sHtml = "";
	var dataObj = JSON.parse("[" + window.sessionStorage["userinfo"] + "]");
	var sUserMail = mobile_comm_getSession("UR_Mail");
	for(var i=0; i<dataObj.length; i++){
		if(sUserMail.toUpperCase() == dataObj[i].EM.toUpperCase()){
			alert(mobile_comm_getDic("msg_no_self_attendant"));
			dataObj.splice(i,1);
		}
	}
	var sExt = "";
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
		
		sHtml += "<a onclick=\"mobile_resource_delUser(this);\" class=\"btn_add_person\" " + dataJson + " " + dataValue + ">";
		sHtml += 		userName;
		sHtml += "</a>";
	});
	
	$("#joins_wrapArea").append(sHtml);
	$("#joins_wrapArea").show();
}

//참석자 삭제
function mobile_resource_delUser(obj, target) {
	var ddObj = $(obj).parents("dd");
	$(obj).detach();
	if($(ddObj).find("a").length == 0) {
		$(ddObj).hide();
	}
	if($("#joins_wrapArea").find('a').length == 0) {
		$("#joins_wrapArea").hide();
	}
}

//반복설정 항목 세팅
function mobile_resource_repeatSetting() {
	//반복설정 - 요일 세팅(시작일 기준) 
	var day_label = mobile_resource_getDayLabel();
	$("#resource_write_divDayOfWeekBtn").find("a").each(function (i, obj) {
		if($(obj).html() == day_label) {
			mobile_resource_changeDayBtn(obj);
		}
	});
	$("#resource_write_month_selectdayofweek").val(day_label);
	$("#resource_write_year_selectdayofweek").val(day_label);
	
	//반복설정 - 주차수 세팅(시작일 기준)
	$("#resource_write_month_selectseq").val(mobile_resource_getWeek());
	$("#resource_write_year_selectseq").val(mobile_resource_getWeek());
	
	//반복설정 - 월 세팅(시작일 기준)
	$("#resource_write_year_selectmonth").val(Number(_mobile_resource_common.Month));
	
	//반복설정 - 일 세팅(시작일 기준)
	$("#resource_write_month_inputday").val(Number(_mobile_resource_common.Day));
	$("#resource_write_year_inputday").val(Number(_mobile_resource_common.Day));
}

//주차수 구하기
function mobile_resource_getWeek() {
	var date;
	if(mobile_comm_isAndroidApp()) {
		date = new Date(_mobile_resource_common.StartDate);
	} else {
		date = new Date(_mobile_resource_common.StartDate.replace(/\-/gi, "/").replace(/\./gi, "/"));
	}
	return Math.ceil((date.getDate()+1)/7);
} 

//요일 구하기
function mobile_resource_getDayLabel() { 
	var week = mobile_comm_getDic("lbl_apv_Days"); 
	var today = new Date(_mobile_resource_common.StartDate).getDay(); 
	var todayLabel = week[today]; 
	return todayLabel; 
} 

// No Data 처리
function checkNoData(value,pFlag){
	if(pFlag == undefined)
		pFlag = false;
	if(pFlag){
		if(value == "" || value == undefined)
			return true;		//없음
		else
			return false;
	}else{
		if(value == "" || value == undefined)
			return mobile_comm_getDic("lbl_noexists");		//없음
		else
			return value;
	}
	
}

// 반복 type 탭 변경
function mobile_resource_changeTab(tabType) {
	$("#resource_write_repeatTab").find("li").removeClass("on");
	$("#resource_write_tab"+tabType).addClass("on");
	
	$("#resource_write_repeatDiv").find("div.tab_cont").hide();
	$("#resource_write_div"+tabType).show();
	$("#resource_write_repeat").html($("#resource_write_tab"+tabType).html());
	
	if(tabType == "No") {
		$("#resource_write_IsRepeat").val("N");
	} else {
		$("#resource_write_IsRepeat").val("Y");
	}
}

// 요일 변경
function mobile_resource_changeDayBtn(obj) {
	if($(obj).hasClass("on")) {
		$(obj).removeClass("on");
	} else {
		$(obj).addClass("on");
	}
}

// 종일 설정
function mobile_resource_chkAllDay() {
	
	var sStartDate = "";
    var sStartTime = "";
    var sEndDate = "";
    var sEndTime = "";
	
	if($("#resource_write_chkAllDay").is(":checked")) {
		//00:00 ~ 23:59분으로 설정
		sStartDate = $("#resource_write_startdate").val();
        sStartTime = $("#resource_write_starttime").val();
        sEndDate = $("#resource_write_enddate").val();
        sEndTime = $("#resource_write_endtime").val();

        $("#resource_write_hidstartdate").val(sStartDate);
        $("#resource_write_hidstarttime").val(sStartTime);
        $("#resource_write_hidenddate").val(sEndDate);
        $("#resource_write_hidendtime").val(sEndTime);
        
        $("#resource_write_startdate").val(sStartDate);
        $("#resource_write_enddate").val(sStartDate);
        $("#resource_write_starttime").val("00:00");
        $("#resource_write_endtime").val("23:59");
        
		//disabled true
		$("#resource_write_startdate").attr("disabled", true);
		$("#resource_write_starttime").attr("disabled", true);
		$("#resource_write_enddate").attr("disabled", true);
		$("#resource_write_endtime").attr("disabled", true);
        
	} else {
		//기존에 있던 값으로 재설정
        sStartDate = $("#resource_write_hidstartdate").val();
        sStartTime = $("#resource_write_hidstarttime").val();
        sEndDate = $("#resource_write_hidenddate").val();
        sEndTime = $("#resource_write_hidendtime").val();

        $("#resource_write_startdate").val(sStartDate);
        $("#resource_write_starttime").val(sStartTime);
        $("#resource_write_enddate").val(sEndDate);
        $("#resource_write_endtime").val(sEndTime);
        
		//disabled true
		$("#resource_write_startdate").attr("disabled", false);
		$("#resource_write_starttime").attr("disabled", false);
		$("#resource_write_enddate").attr("disabled", false);
		$("#resource_write_endtime").attr("disabled", false);
	}
}

// 시작일시/종료일시 Validation Check
function mobile_resource_chkDateValidation(from) {
	//날짜 입력값 유효성 검사 추가
	if(from == "SD" || from == "ED") {
		try {
			var	dtCheck = new Date($("#resource_write_startdate").val().substring(5,7)+'/'+$("#resource_write_startdate").val().substring(8,10)+'/'+$("#resource_write_startdate").val().substring(0,4)+' 00:00:00');
			if(from == "ED") {
				dtCheck = new Date($("#resource_write_enddate").val().substring(5,7)+'/'+$("#resource_write_enddate").val().substring(8,10)+'/'+$("#resource_write_enddate").val().substring(0,4)+' 00:00:00');
			}
			if((dtCheck.getDate() + "") == "NaN") {
				alert(mobile_comm_getDic("msg_InValidDateInput"));		//날짜 입력값이 잘못 되었습니다.
				
				if(from == "SD") {
					var date = new Date();
					if (mobile_comm_getQueryString('date', 'resource_write_page') != 'undefined') {
						date = new Date(mobile_resource_ReplaceDate(mobile_comm_getQueryString('date', 'resource_write_page')));
					}
					$("#resource_write_startdate").val(mobile_resource_SetDateFormat(date, '.'));
				} else if(from == "ED") {
					$("#resource_write_enddate").val($("#resource_write_startdate").val());
				}
				
				return false;
			}
		} catch (e) {
			alert(mobile_comm_getDic("msg_InValidDateInput"));		//날짜 입력값이 잘못 되었습니다.
			return false;
		}
	}
	
	//날짜 변경 시 validation
	if(from == "SD"){
		if($("#resource_write_startdate").val() > $("#resource_write_enddate").val()){
			$("#resource_write_enddate").val($("#resource_write_startdate").val());
		}
		
		if($("#resource_write_startdate").val() == $("#resource_write_enddate").val() && $("#resource_write_starttime").val() > $("#resource_write_endtime").val()) {
			$("#resource_write_endtime").val($("#resource_write_starttime").val());
		}
	} else if(from == "ED"){
		if($("#resource_write_startdate").val() > $("#resource_write_enddate").val()){
			$("#resource_write_startdate").val($("#resource_write_enddate").val());
		}
		
		if($("#resource_write_startdate").val() == $("#resource_write_enddate").val() && $("#resource_write_starttime").val() > $("#resource_write_endtime").val()) {
			$("#resource_write_starttime").val($("#resource_write_endtime").val());
		}
	} else if(from == "ST"){
		if($("#resource_write_startdate").val() >= $("#resource_write_enddate").val()){
			if($("#resource_write_starttime").val() > $("#resource_write_endtime").val()){
				$("#resource_write_endtime").val($("#resource_write_starttime").val());
			}
		}
	} else if(from == "ET"){
		if($("#resource_write_startdate").val() >= $("#resource_write_enddate").val()){
			if($("#resource_write_starttime").val() > $("#resource_write_endtime").val()){
				$("#resource_write_starttime").val($("#resource_write_endtime").val());
			}
		}
	}
	
	/*if(Math.round(Math.abs((start_date.getTime() - now_date.getTime())/(oneDay))) >= 30){ //시작일이 오늘+30일 이후인 경우
		//alert(mobile_comm_getDic("msg_resource_CannotReserve30DayAfter"));
		$("#resource_write_startdate").val(mobile_comm_getDateTimeString("yyyy.MM.dd", new Date(now_date.setDate(now_date.getDate() + 29))));
		$("#resource_write_enddate").val($("#resource_write_startdate").val());
	}
	
	if(Math.round(Math.abs((end_date.getTime() - now_date.getTime())/(oneDay))) >= 30){ //종료일이 오늘+30일 이후인 경우
		//alert(mobile_comm_getDic("msg_resource_CannotReserve30DayAfter"));
		now_date = new Date();
		$("#resource_write_enddate").val(mobile_comm_getDateTimeString("yyyy.MM.dd", new Date(now_date.setDate(now_date.getDate() + 29))));
	}*/
		
}

// 자원예약 등록
function mobile_resource_regist(mode) { // I : 등록, U : 수정 
	
	//자원선택값 초기화
	window.sessionStorage.removeItem("ResourceWrite_SelectResource_ID_" + mobile_comm_getSession("UR_Code"));
	window.sessionStorage.removeItem("ResourceWrite_SelectResource_Name_" + mobile_comm_getSession("UR_Code"));
	
	var eventObj = {};
	
	eventObj.IsSchedule = $("#resource_write_interlockYN").hasClass("on") ? "Y" : "N";
	eventObj.ResourceID = $("#resource_write_resourceID").val();
	
	var event = {};
	var date = {};
	var repeat = {};
	var notification = {};
	var userForm = new Array();
	var attendee = new Array();
	
	event.FolderID = $("#resource_write_resourceID").val();
	event.FolderType = "Resource";
	
	event.Subject = $("#resource_write_subject").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />');
	event.Description = $("#resource_write_subject").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />');
	
	event.RegisterCode = _mobile_resource_common.userCode;
	event.MultiRegisterName = mobile_comm_getSession("USERNAME");

	if(!$("#resource_write_repeatChk").hasClass("on") || $("#resource_write_IsRepeat").val() == "N"){
		date.StartDate = $("#resource_write_startdate").val().replace(/\./gi, "-");
		date.EndDate = $("#resource_write_enddate").val().replace(/\./gi, "-");
		date.StartTime = $("#resource_write_starttime").val().replace(/\./gi, "-");
		date.EndTime = $("#resource_write_endtime").val().replace(/\./gi, "-");
		date.IsRepeat = "N";
		mobile_resource_changeTab('No');
		
		repeat = {};
	} else {
		date.StartDate = $("#resource_write_startdate").val().replace(/\./gi, "-");
		date.EndDate = $("#resource_write_enddate").val().replace(/\./gi, "-");
		date.StartTime = $("#resource_write_starttime").val().replace(/\./gi, "-");
		date.EndTime = $("#resource_write_endtime").val().replace(/\./gi, "-");
		date.IsRepeat = $("#resource_write_IsRepeat").val();
		
		// TODO 반복
		var tempRepeat = mobile_resource_getRepeatData(); 
		repeat = tempRepeat.ResourceRepeat; //$.parseJSON(mobile_resource_getRepeatData());
	}
	date.IsAllDay = $("#resource_write_chkAllDay").is(":checked") ? "Y" : "N";
	
	if($("#resource_write_notice").hasClass("on")){
		notification.IsNotification = "Y";
		notification.IsReminder = $("#resource_write_notice_reminderYN").hasClass("on") ? "Y" : "N";
		notification.ReminderTime = $("#resource_write_notice_remindertime option:selected").val();
		notification.IsCommentNotification = $("#resource_write_notice_commentYN").hasClass("on") ? "Y" : "N";
		notification.MediumKind = "";
	}else{
		notification.IsNotification = "N";
		notification.IsReminder = "N";
		notification.ReminderTime = $("#resource_write_notice_remindertime option:selected").val();
		notification.IsCommentNotification = "N";
		notification.MediumKind = "";
	}
	
	//attendee
	var selectAttendee = $("#joins_wrapArea a");
	$(selectAttendee).each(function(){
		var attendeeObj = {};
		var attendeeInfo = $.parseJSON($(this).attr("data-json"));
		
		attendeeObj.UserName = attendeeInfo.label;
		if(this.value == "undefined" || attendeeInfo.value == ""){
			attendeeObj.UserCode = "";
			attendeeObj.IsOutSider = "Y";
			attendeeObj.IsAllow = "N";
		}else{
			attendeeObj.UserCode = attendeeInfo.value.split("|")[0];
			attendeeObj.IsAllow = attendeeInfo.value.split("|")[1] == undefined ? "" : attendeeInfo.value.split("|")[1];
			attendeeObj.IsOutsider = "N";
		}
		attendeeObj.dataType = "NEW";
		attendee.push(attendeeObj);
	});
	
	// UserForm Data
	/*$("#userFormOption").find(">div").each(function(){
		var userFormObj = {};
		
		userFormObj.UserFormID = $(this).attr("id");
		userFormObj.FolderID = $("#ResourceID").val();
		userFormObj.FieldValue = resourceUser.getUserFormOptionValue($(this).find("[name=content]"));
		
		userForm.push(userFormObj);
	});*/
	
	eventObj.Event = event;
	eventObj.Date = date;
	eventObj.Repeat = repeat;
	eventObj.Notification = notification;
	eventObj.Attendee = attendee;
	eventObj.UserForm = userForm;

	var validationObj = JSON.parse(JSON.stringify(eventObj));
	
	if(mode == "U"){
		var tempObj = {};
		var tempEvent = {};
		var tempDate = {};
		var tempNotification = {};
		var tempUserForm = new Array;
		
		tempEvent = {
				"FolderID": $$(updateBookingDataObj).find("bookingData").attr("ResourceID"),
				"FolderType": "Resource",
				"Subject": $$(updateBookingDataObj).find("bookingData").attr("Subject"),
				"Description": $$(updateBookingDataObj).find("bookingData").attr("Description"),
				"RegisterCode": event.RegisterCode,
				"MultiRegisterName": event.MultiRegisterName
		};
		
		tempDate = {
				"StartDate": $$(updateBookingDataObj).find("bookingData").attr("StartDateTime").split(" ")[0],
			    "EndDate": $$(updateBookingDataObj).find("bookingData").attr("EndDateTime").split(" ")[0],
			    "StartTime": $$(updateBookingDataObj).find("bookingData").attr("StartDateTime").split(" ")[1],
			    "EndTime": $$(updateBookingDataObj).find("bookingData").attr("EndDateTime").split(" ")[1],
			    "IsAllDay": $$(updateBookingDataObj).find("bookingData").attr("IsAllDay"),
			    "IsRepeat": $$(updateBookingDataObj).find("bookingData").attr("IsRepeat")
		};
		
		tempNotification = $$(updateBookingDataObj).find("notification").json();
		
		$$(updateBookingDataObj).find("userDefValue").concat().each(function(i, obj){
			tempUserForm.push({
				"UserFormID": $$(obj).attr("UserFormID"),
				"FolderID": $$(updateBookingDataObj).find("bookingData").attr("ResourceID"),
				"FieldValue": $$(obj).attr("FieldValue")
			});
		});
		
		tempObj.IsSchedule = $$(updateBookingDataObj).find("bookingData").attr("LinkScheduleID") == "" ? "N" : "Y";
		tempObj.ResourceID = $$(updateBookingDataObj).find("bookingData").attr("ResourceID");
		
		tempObj.Event = tempEvent;
		tempObj.Date = tempDate;
		tempObj.Repeat = $$(updateBookingDataObj).find("repeat").json();
		tempObj.Repeat.RepeatAppointType = tempObj.Repeat.RepeatAppointType == '0' ? 'A' : 'B';
		tempObj.Notification= tempNotification;
		tempObj.UserForm = tempUserForm;
		tempObj.Attendee = updateBookingDataObj.bookAtdData;
		
		/*//180621 PC와 상이해서 주석처리함
		if($$(updateBookingDataObj).find("bookingData").attr("Description") == "" && $$(updateBookingDataObj).find("bookingData").attr("Subject") == event.Description){
			$$(eventObj).find("Event").attr("Description", "");
		}
		*/
		
		//TODO 반복 관련 추가 개발 필요
		// 반복이 바뀌어도 Repeat 데이터로 가능할 경우
		if($$(tempObj).find("Date").attr("IsRepeat") == "Y" && $$(eventObj).find("Date").attr("IsRepeat") == "Y"){
			$$(tempObj).find("Date").remove();
			$$(eventObj).find("Date").remove();
		}
		//$$(tempObj).find("Repeat").remove();
		//$$(eventObj).find("Repeat").remove();
		//var resourceRepeat = {"ResourceRepeat" : {}};
		//$$(resourceRepeat).find("ResourceRepeat").append($$(tempObj).find("Repeat").json());
		//$$(tempObj).find("Repeat").remove();
		//$$(tempObj).append("Repeat", $$(resourceRepeat).json()).json();
		
		// eventObj와 updateScheduleDataObj 비교
		eventObj = mobile_resource_compareEventObject(eventObj,tempObj);
		
		//추가 참석자 데이터 별도 비교 필요
		if(eventObj.Attendee != undefined){
			var oldData = tempObj.Attendee;
			var newData = attendee;
			var delArray = new Array();
			var isModify = false;
			var isAdd = false;
			
			$(oldData).each(function(i, oObj){
				isAdd = false;
				$(newData).each(function(j, nObj){
					if(oObj.dataType == "OLD" && oObj.UserCode == nObj.UserCode && oObj.UserName == nObj.UserName){
						nObj.dataType = "OLD";
						isAdd = true;
						return false;
					}
				});
				if(!isAdd){
					oObj.dataType = "DEL";
					delArray.push(oObj);
				}
			});
			
			newData = newData.concat(delArray);
			$(newData).each(function(){
				if(this.dataType == "NEW" || this.dataType == "DEL"){
					isModify = true;
					return false;
				}
			});
			
			if(isModify)
				eventObj.Attendee = newData;
			else
				$$(eventObj).remove("Attendee");
		}
		
		eventObj.EventID = _mobile_resource_common.EventID;
		eventObj.DateID = _mobile_resource_common.DateID;
		eventObj.RepeatID = _mobile_resource_common.RepeatID;
		eventObj.IsSchedule = $("#resource_write_interlockYN").hasClass("on") ? "Y" : "N";
		eventObj.ResourceID = event.FolderID;
		eventObj.oldResourceID = (_mobile_resource_common.oldResourceID) ? _mobile_resource_common.oldResourceID :_mobile_resource_common.ResourceID;
		eventObj.RegisterCode = event.RegisterCode;
		eventObj.Attendee = attendee;

		// 미리알림을 위한 데이터
		eventObj.Subject = eventObj.Subject == undefined ? updateBookingDataObj.bookingData.Subject : eventObj.Event.Subject;
		eventObj.FolderID = eventObj.FolderID == undefined ? updateBookingDataObj.bookingData.FolderID : eventObj.Event.FolderID;
		eventObj.IsRepeat = eventObj.IsRepeat == undefined ? updateBookingDataObj.bookingData.IsRepeat : eventObj.Event.IsRepeat;
		
		eventObj.IsRepeat = $("#resource_write_IsRepeat").val();
		
		// 반복의 개별자원 수정인 경우, 반복정보 제거
		if (mobile_comm_getQueryString('isrepeat', 'resource_write_page') == 'Y' && mobile_comm_getQueryString('isrepeatall', 'resource_write_page') != 'Y') {
			if (eventObj.Repeat) delete eventObj.Repeat;
			if (eventObj.RepeatID) delete eventObj.RepeatID;
			mode = "RU";		
			eventObj.Event = event;
		}
	}
		
	if(JSON.stringify(eventObj) != "{}"){
		// Validation 체크
		if(mobile_resource_checkValidationResource(validationObj)){
			$.ajax({
			    url: "/groupware/mobile/resource/saveBookingData.do",
			    type: "POST",
			    data: {
			    	"mode" : mode,
			    	"eventStr" : JSON.stringify(eventObj),
			    	"isChangeDate" : eventObj.isChangeDate,
			    	"isChangeRes" : eventObj.isChangeResource
				},
			    success: function (res) {
			    	if(res.status == "SUCCESS" && res.result == "OK"){
			    		alert(res.message);
			    		window.sessionStorage.removeItem('resource_writeinit');

			    		//목록으로 되돌아감
			    		if(mode == "U" || mode == "RU") {
							var newUrl = $("#resource_view_page").attr("data-url").replace('resourceid='+eventObj.oldResourceID, 'resourceid='+eventObj.ResourceID);
							$("#resource_view_page").attr("data-url", newUrl);
	
				    		mobile_comm_back();
				    		
				    		if($("#resource_view_page").attr("IsLoad") == "Y"){
				    			mobile_resource_ViewInit();
				    		}
				    		
				    		$("#resource_view_page").remove();				    						    						    						    						
				    		
				    		mobile_resource_clickrefresh();
			    		} else {
			    			mobile_comm_back();
			    		}
			    		mobile_resource_changeViewType(_mobile_resource_common.ViewType);
			    	}
			    	else if(res.status == "SUCCESS" && res.result == "DUPLICATION"){
			    		alert(res.message.replace(/<br\/>/gi, "\n").replace(/<br \/>/gi, "\n"));
			    	}
			    	else {
			    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
			    	}
			    },
				error : function (response, status, error) {
				    mobile_comm_ajaxerror("/groupware/mobile/resource/saveBookingData.do", response, status, error);
			    }
			});
		}
	} else{
		alert(mobile_comm_getDic("msg_117")); //성공적으로 저장하였습니다.
		//이전 페이지로 되돌아감
		mobile_comm_go("/groupware/mobile/resource/list.do");
		mobile_resource_changeViewType(_mobile_resource_common.ViewType);
	}
}

// 등록/수정 시 Validation Check
function mobile_resource_checkValidationResource(eventObj) {
	var returnVal = true;
	var startDateTime = "";
	var endDateTime = "";
	
	// 자원 선택 여부 체크
	var folder = eventObj.ResourceID;
	if(folder == undefined || folder == ""){
		alert(mobile_comm_getDic("msg_mustSelectRes")); //자원을 선택해주세요.
		return false;
	}
	
	// 이전날짜 및 시간 체크
	if(eventObj.Date != undefined || eventObj.Repeat != undefined) {
		if(eventObj.Date.StartDate != "") startDateTime = eventObj.Date.StartDate + " " + eventObj.Date.StartTime;
		else startDateTime = eventObj.Repeat.RepeatStartDate + " " + eventObj.Repeat.AppointmentStartTime;
		
		if(eventObj.Date.EndDate != "") endDateTime = eventObj.Date.EndDate + " " + eventObj.Date.EndTime;
		else endDateTime = eventObj.Repeat.RepeatEndDate + " " + eventObj.Repeat.AppointmentEndTime;
		
		if (mobile_comm_getBaseConfig('IsPastSave') == '' || mobile_comm_getBaseConfig('IsPastSave') == 'N'){
			if(parseInt(_mobile_resource_common.CurrentTime.getTime() / 1000 / 60) > parseInt(new Date(mobile_resource_ReplaceDate(startDateTime)).getTime() / 1000 / 60)){
				alert(mobile_comm_getDic("msg_cannotBookingBefore")); //현재보다 이전 시간에 대해서 예약할 수 없습니다.
				return false;
			}
			
			if(eventObj.Repeat != undefined && Object.keys(eventObj.Repeat).length > 0){
				var repeatStartDateTime = eventObj.Repeat.RepeatStartDate + " " + eventObj.Repeat.AppointmentStartTime;
				if(parseInt(_mobile_resource_common.CurrentTime.getTime() / 1000 / 60) > parseInt(new Date(mobile_resource_ReplaceDate(repeatStartDateTime)).getTime() / 1000 / 60)){
					alert(mobile_comm_getDic("msg_cannotBookingBefore")); //현재보다 이전 시간에 대해서 예약할 수 없습니다.
					return false;
				}
			}
		}
		
		if($("#resource_write_startdate").val() > $("#resource_write_enddate").val()){
			alert(mobile_comm_getDic("msg_StartDateCannotAfterEndDate"));	//시작일은 종료일보다 이후일 수 없습니다.
			return false;
		} else if($("#resource_write_startdate").val() == $("#resource_write_enddate").val()){
			if($("#resource_write_starttime").val() > $("#resource_write_endtime").val()){
				alert(mobile_comm_getDic("msg_Mobile_InvalidStartTime"));	//시작시간이 종료시간보다 클 수 없습니다.
				return false;
			}
		}
		
		// 최소 대여기간 체크
		if (eventObj.Date.IsRepeat == 'Y'){
			startDateTime = CFN_GetLocalCurrentDate(_ServerDateSimpleFormat) + " " + eventObj.Repeat.AppointmentStartTime;
			if (eventObj.Repeat.AppointmentStartTime > eventObj.Repeat.AppointmentEndTime){
				endDateTime = schedule_SetDateFormat(mobile_schedule_AddDays(CFN_GetLocalCurrentDate(_ServerDateSimpleFormat), 1),'-') + " " + eventObj.Repeat.AppointmentEndTime;
			} else {
				endDateTime = CFN_GetLocalCurrentDate(_ServerDateSimpleFormat) + " " + eventObj.Repeat.AppointmentEndTime;
			}
			
			var limitRepeatCount = Number(mobile_comm_getBaseConfig("RepeatCount"));	// 반복 제한 횟수
			limitRepeatCount = limitRepeatCount ? limitRepeatCount : 100;
			var eventRepeatCount = eventObj.Repeat.RepeatCount;
			
			if(eventRepeatCount > limitRepeatCount){
				alert(mobile_comm_getDic("msg_ValidRepeatCount").replace("{0}", limitRepeatCount).replaceAll('</br>', '\n'));	// 설정된 최대 반복 횟수를 초과했습니다. </br> 반복 횟수를 확인하여 주십시오. </br> 최대 반복 횟수: {0}
				return false;
			}
		}
		var rentalTime = parseInt(new Date(mobile_resource_ReplaceDate(endDateTime)).getTime() / 1000 / 60) - parseInt(new Date(mobile_resource_ReplaceDate(startDateTime)).getTime() / 1000 / 60);
		var leastRentalTime;
		if(Object.keys(_mobile_resource_common.resourceArr).length > 0){
			leastRentalTime = _mobile_resource_common.resourceArr[eventObj.ResourceID].LeastRentalTime;
		} else {
			leastRentalTime = _mobile_resource_common.bookingresourceArr[eventObj.ResourceID].LeastRentalTime;
		} 
		if(rentalTime < leastRentalTime){
			var leastRentalTimeStr;
			if(leastRentalTime < 60){
				leastRentalTimeStr = leastRentalTime + mobile_comm_getDic("lbl_Minutes"); // 분
			}else{
				leastRentalTimeStr = Math.floor(leastRentalTime/60) + mobile_comm_getDic("lbl_Time"); // 시간
				if(leastRentalTime % 60 != 0){
					leastRentalTimeStr += " " + (leastRentalTime % 60) + mobile_comm_getDic("lbl_Minutes"); // 분
				}
			}
			alert(mobile_comm_getDic("msg_cannotLeastRentalTimeBefore").replace("{0}", leastRentalTimeStr).replace('<br/>', '\n')); // 최소 대여기간보다 적게 예약할 수 없습니다.<br/>{0} 이상 예약해주세요.
			return false;
		}
		/*if(parseInt(new Date(mobile_resource_ReplaceDate(startDateTime)).getTime() / 1000 / 60) >= parseInt(new Date(mobile_resource_ReplaceDate(endDateTime)).getTime() / 1000 / 60)){
			alert(mobile_comm_getDic("msg_bad_period")); //시작일은 종료일보다 클 수 없습니다.
			return false;
		}
		
		var oneDay = 24*60*60*1000;
		if(Math.round(Math.abs((new Date(mobile_resource_ReplaceDate(startDateTime)).getTime() - new Date().getTime())/(oneDay))) >= 30 || Math.round(Math.abs((new Date(mobile_resource_ReplaceDate(endDateTime)).getTime() - new Date().getTime())/(oneDay))) >= 30){ //시작일 혹은 종료일이 오늘+30일 이후인 경우
			alert(mobile_comm_getDic("msg_resource_CannotReserve30DayAfter"));
			return false;
		}*/
	}
	
	// 끝 날짜 체크
	if($("#resource_write_repeatTab").find("li[class=on]").length > 0){
		var repeatType = $("#resource_write_repeatTab").find("li[class=on]").attr("id").replace("resource_write_tab", "").toLowerCase();
		var repeatEndDate = $("#resource_write_" + repeatType + "_inputend").val() + " " + "23:59:59";
		if(parseInt(new Date(mobile_resource_ReplaceDate(startDateTime)).getTime() / 1000 / 60) > parseInt(new Date(mobile_resource_ReplaceDate(repeatEndDate)).getTime() / 1000 / 60)){
			alert(mobile_comm_getDic("msg_RepeatSetting_08")); //반복범위 설정이 잘 못 되었습니다. 시작/끝 날짜를 확인하여 주십시오.
			return false;
		}
	}
	
	// 반복 매주 요일 여부 체크
	if($("#resource_write_repeatTab").find("li[class=on]").length > 0){
		if ($('#resource_write_divDayOfWeekBtn').find('a.day.ui-link.on').length <= 0 && ($("#resource_write_tabWeek").attr('class') == "on")) {
			alert(mobile_comm_getDic("msg_RepeatSetting_05")); //반복설정의 반복 요일을 선택하여 주십시오.
			return false;							
		}
	}
	
	// 제목 입력 여부 체크
	var subject = eventObj.Event.Subject;
	if(subject == undefined || subject == ""){
		alert(mobile_comm_getDic("msg_ReservationWrite_01")); //용도를 입력해주세요.
		return false;
	}
	
	return returnVal;
}

// 반복 데이터 반환
function mobile_resource_getRepeatData(){
	var sTemp = "";
	var sAppointmentStartTime = $("#resource_write_starttime").val();
	var sAppointmentEndTime = $("#resource_write_endtime").val();
	var sAppointmentDuring = "0";
	var sRepeatType = "D";
	var sRepeatYear = "0";
	var sRepeatMonth = "0";
	var sRepeatWeek = "0";
	var sRepeatDay = "1";
	var sRepeatMonday = "N";
	var sRepeatTuesday = "N";
	var sRepeatWednseday = "N";
	var sRepeatThursday = "N";
	var sRepeatFriday = "N";
	var sRepeatSaturday = "N";
	var sRepeatSunday = "N";
	var sRepeatStartDate = $("#resource_write_startdate").val().replace(/\./gi, "-");
	var sRepeatEndType = "";
	var sRepeatEndDate = $("#resource_write_enddate").val().replace(/\./gi, "-");
	var sRepeatCount = "0";
	
	var sRepeatAppointType = "";
	var sRepetitionPerAtt = 0;
	
	$("#resource_write_repeatTab>li").each(function () {
		if ($(this).hasClass("on")) {
			sRepeatType = $(this).attr("id").replace("resource_write_tab", "");
		}
	});
	
	switch (sRepeatType.toUpperCase()) {
	case "D":
	case "DAY":
		if ($("input[type=radio][name=resource_write_day_date]:checked").val() == "set") {
			sRepeatDay = $("#resource_write_day_inputday").val();
			sRepeatAppointType = "A";
		}
		else {
			sRepeatDay = "0";
			sRepeatMonday = "Y";
			sRepeatTuesday = "Y";
			sRepeatWednseday = "Y";
			sRepeatThursday = "Y";
			sRepeatFriday = "Y";
			sRepeatAppointType = "B";
		}
		//sRepetitionPerAtt = $("#resource_write_day_inputday").val();
		
		break;
	case "W":
	case "WEEK":
		sRepeatWeek = $("#resource_write_week_inputweek").val();
		//sRepetitionPerAtt = $("#resource_write_week_inputweek").val();
		$("#resource_write_divDayOfWeekBtn").find("a").each(function() {
			if($(this).hasClass("on")) {
				switch($(this).html()) {
				case mobile_comm_getDic("lbl_sch_sun"): sRepeatSunday = "Y"; break;
				case mobile_comm_getDic("lbl_sch_mon"): sRepeatMonday = "Y"; break;
				case mobile_comm_getDic("lbl_sch_tue"): sRepeatTuesday = "Y"; break;
				case mobile_comm_getDic("lbl_sch_wed"): sRepeatWednseday = "Y"; break;
				case mobile_comm_getDic("lbl_sch_thr"): sRepeatThursday = "Y"; break;
				case mobile_comm_getDic("lbl_sch_fri"): sRepeatFriday = "Y"; break;
				case mobile_comm_getDic( "lbl_sch_sat"): sRepeatSaturday = "Y"; break;
				}
			}
		});
		break;
	case "M":
	case "MONTH":
		sRepeatMonth = $("#resource_write_month_inputmonth").val();
		
		if ($("input[type=radio][name=resource_write_month_date]:checked").val() == "day") {
			sRepeatDay = $("#resource_write_month_inputday").val();
			sRepeatAppointType = "A";
		}
		else {
			sRepeatDay = "0";
			sRepeatWeek = $("#resource_write_month_selectseq option:selected").val();
			
			sTemp = $("#resource_write_month_selectdayofweek option:selected").val();
			switch(sTemp) {
			case mobile_comm_getDic("lbl_sch_sun"): sRepeatSunday = "Y"; break;
			case mobile_comm_getDic("lbl_sch_mon"): sRepeatMonday = "Y"; break;
			case mobile_comm_getDic("lbl_sch_tue"): sRepeatTuesday = "Y"; break;
			case mobile_comm_getDic("lbl_sch_wed"): sRepeatWednseday = "Y"; break;
			case mobile_comm_getDic("lbl_sch_thr"): sRepeatThursday = "Y"; break;
			case mobile_comm_getDic("lbl_sch_fri"): sRepeatFriday = "Y"; break;
			case mobile_comm_getDic( "lbl_sch_sat"): sRepeatSaturday = "Y"; break;
			}
			sRepeatAppointType = "B";
		}
		break;
	case "Y":
	case "YEAR":
		sRepeatYear = $("#resource_write_year_inputyear").val();
		//sRepetitionPerAtt = $("#resource_write_year_inputyear").val();
		sRepeatMonth = $("#resource_write_year_selectmonth option:selected").val();
		
		if ($("input[type=radio][name=resource_write_year_date]:checked").val() == "day") {
			sRepeatWeek = "0";
			sRepeatDay = $("#resource_write_year_inputday").val();
			sRepeatAppointType = "A";
		}
		else {
			sRepeatWeek = $("#resource_write_year_selectseq option:selected").val();
			sRepeatDay = "0";
			
			sTemp = $("#resource_write_year_selectdayofweek option:selected").val();
			switch(sTemp) {
			case mobile_comm_getDic("lbl_sch_sun"): sRepeatSunday = "Y"; break;
			case mobile_comm_getDic("lbl_sch_mon"): sRepeatMonday = "Y"; break;
			case mobile_comm_getDic("lbl_sch_tue"): sRepeatTuesday = "Y"; break;
			case mobile_comm_getDic("lbl_sch_wed"): sRepeatWednseday = "Y"; break;
			case mobile_comm_getDic("lbl_sch_thr"): sRepeatThursday = "Y"; break;
			case mobile_comm_getDic("lbl_sch_fri"): sRepeatFriday = "Y"; break;
			case mobile_comm_getDic( "lbl_sch_sat"): sRepeatSaturday = "Y"; break;
			}
			
			sRepeatAppointType = "B";
		}
		break;
	}
	
	if ($("input[type=radio][name=resource_write_" + sRepeatType.toLowerCase() + "_repeat]:checked").val() == "end") {
		sRepeatEndType = "I";
		sRepeatEndDate = $("#resource_write_" + sRepeatType.toLowerCase() + "_inputend").val();
	} else if ($("input[type=radio][name=resource_write_" + sRepeatType.toLowerCase() + "_repeat]:checked").val() == "repeat") {
		sRepeatEndType = "R";
		sRepeatCount = $("#resource_write_" + sRepeatType.toLowerCase() + "_inputrepeat").val();
	}
	
	var returnObj = {};
	var resourceRepeatObj = {};
	
	resourceRepeatObj.AppointmentStartTime = sAppointmentStartTime;
	resourceRepeatObj.AppointmentEndTime = sAppointmentEndTime;
	resourceRepeatObj.AppointmentDuring = sAppointmentDuring;
	
	resourceRepeatObj.RepeatType = sRepeatType.charAt(0);
	resourceRepeatObj.RepeatYear = sRepeatYear;
	resourceRepeatObj.RepeatMonth = sRepeatMonth;
	resourceRepeatObj.RepeatWeek = sRepeatWeek;
	resourceRepeatObj.RepeatDay = sRepeatDay;
	
	resourceRepeatObj.RepeatMonday = sRepeatMonday;
	resourceRepeatObj.RepeatTuesday = sRepeatTuesday;
	resourceRepeatObj.RepeatWednseday = sRepeatWednseday;
	resourceRepeatObj.RepeatThursday = sRepeatThursday;
	resourceRepeatObj.RepeatFriday = sRepeatFriday;
	resourceRepeatObj.RepeatSaturday = sRepeatSaturday;
	resourceRepeatObj.RepeatSunday = sRepeatSunday;
	
	resourceRepeatObj.RepeatStartDate = sRepeatStartDate;
	resourceRepeatObj.RepeatEndType = sRepeatEndType;
	resourceRepeatObj.RepeatEndDate = sRepeatEndDate;
	resourceRepeatObj.RepeatCount = sRepeatCount;
	
	resourceRepeatObj.RepeatAppointType = sRepeatAppointType;
	//resourceRepeatObj.RepetitionPerAtt = sRepetitionPerAtt;
	
	returnObj.ResourceRepeat = resourceRepeatObj;
	
	return returnObj;
}

//수정시 데이터 비교
function mobile_resource_compareEventObject(eventObj, updateObj){
	var updateReturnObj = {};
	var tempEventObj = {};
	var tempUpdateObj = {};
	var tempArr;
	
	Object.keys(eventObj).forEach(function(key1) {
		tempEventObj[key1] = {};
		tempUpdateObj[key1] = {};
		
		if(eventObj[key1][0] != undefined){
			tempArr = new Array();
			
			if(typeof eventObj[key1] == "object"){
				$$(eventObj[key1]).concat().each(function(i){
					var tempArrObj = {};
					Object.keys(eventObj[key1][i]).sort().forEach(function(key2) {
						$$(tempArrObj).attr(key2, $$(eventObj[key1][i]).attr(key2));
					});
					tempArr.push(tempArrObj);
				});
				tempEventObj[key1] = tempArr;
			}else{
				tempEventObj[key1] = eventObj[key1];
			}
			
		}else{
			Object.keys(eventObj[key1]).sort().forEach(function(key2) {
				$$(tempEventObj[key1]).attr(key2, $$(eventObj[key1]).attr(key2));
			});
		}
		
			if(updateObj[key1][0] != undefined){
				tempArr = new Array();
				
				if(typeof updateObj[key1] == "object"){
					$$(updateObj[key1]).concat().each(function(i){
						var tempArrObj = {};
						Object.keys(updateObj[key1][i]).sort().forEach(function(key2) {
							$$(tempArrObj).attr(key2, $$(updateObj[key1][i]).attr(key2));
						});
						tempArr.push(tempArrObj);
					});
					tempUpdateObj[key1] = tempArr;
				}else{
					tempUpdateObj[key1] = updateObj[key1];
				}
			}else{
				Object.keys(updateObj[key1]).sort().forEach(function(key2) {
					$$(tempUpdateObj[key1]).attr(key2, $$(updateObj[key1]).attr(key2));
				});
			}
			
			if(JSON.stringify(tempUpdateObj[key1]) != JSON.stringify(tempEventObj[key1])){
				updateReturnObj[key1] = tempEventObj[key1];
			}
	});
	
	return updateReturnObj;
}

/*!
 * 
 * 자원예약 작성 끝
 * 
 */





/*!
 * 
 * 자원예약 상세 시작
 * 
 */

function mobile_resource_ViewInit() {
	//초기화 및 파라미터 세팅
	mobile_resource_InitJS("resource_view_page");

	//상세보기 데이터 가져오기
	mobile_resource_getViewData("D");
	
	//알림 컨트롤러 표시 => 미사용
	/* if(_mobile_resource_common.IsRepeat == "Y"){
		 $("#resource_view_isnotificationtotaldiv").show();
	 }else{
		 $("#resource_view_isnotificationtotaldiv").hide();
	 }*/
	
}

//자원예약 상세보기/수정 Data 
function mobile_resource_getViewData(mode) {
	$.ajax({
	    url: "/groupware/mobile/resource/getBookingData.do",
	    type: "POST",
	    data: {
	    	"mode" : mode,
	    	"EventID" : _mobile_resource_common.EventID,
	    	"DateID" : _mobile_resource_common.DateID,
	    	"FolderID" : _mobile_resource_common.ResourceID,
	    	"RepeatID" : _mobile_resource_common.RepeatID
		},
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		if(res.data && JSON.stringify(res.data) != "{}" && res.data.bookingData && JSON.stringify(res.data.bookingData) != "{}"){	    			
					res.data.bookingData.StartDateTime = CFN_TransLocalTime(res.data.bookingData.StartDateTime, 'yyyy-MM-dd HH:mm');
					res.data.bookingData.EndDateTime = CFN_TransLocalTime(res.data.bookingData.EndDateTime, 'yyyy-MM-dd HH:mm');
	    			mobile_resource_getViewDataHtml(mode, res.data);
	    		} else if(isresUpdate){
					isresUpdate = false;
					mobile_comm_back();
				} else {
					alert(mobile_comm_getDic("msg_changedResourceBooking")); // 수정 및 삭제된 자원 예약입니다.
					mobile_comm_back();
				}
	    	} else {
				alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
			}
	       },
	       error:function(response, status, error){
			mobile_comm_ajaxerror("/groupware/mobile/resource/getBookingData.do", response, status, error);
		}
	});
}

//자원예약 Data Html
function mobile_resource_getViewDataHtml(mode, data) {
	var bookingData = data.bookingData;
	var repeatData = data.repeat;
	var notification = data.notification;
	var userDefValue = data.userDefValue;
	var attendee = data.bookAtdData;
	var userCode = mobile_comm_getSession("UR_Code");
	
	if(mode == "D") { //상세보기
		
		var resourceID = _mobile_resource_common.ResourceID;
		var temp = false;
		
		// 작성자,  Owner 권한 체크, 폴더 권한 체크
		if(_mobile_resource_common.resAclArray.length == 0) 
			mobile_resource_setAclEventFolderData();
		var modifyAclCnt =_mobile_resource_common.resAclArray.modify.length;
		for(var i = 0; i < modifyAclCnt; i++) {
			if(_mobile_resource_common.resAclArray.modify[i].FolderID == resourceID) {
				temp = true; break;
			}
		}
		
		_mobile_resource_common.FolderType =  bookingData.FolderType;
		
		if((bookingData.RegisterCode == _mobile_resource_common.userCode || bookingData.OwnerCode == _mobile_resource_common.userCode  || temp)
			&& (bookingData.ApprovalStateCode == "ApprovalRequest" || (bookingData.ApprovalStateCode == "Approval" && bookingData.BookingTypeCode == "DirectApproval"))){	
			// 수정 권한 체크
			var sHtml = "";
			
			if(_mobile_resource_common.IsRepeat == "Y"){
				sHtml += "<li><a id=\"resource_view_modify\" onclick=\"mobile_resource_clickExmenuBtn(this);\" class=\"btn\">" + mobile_comm_getDic('lbl_schedule_modify_one') + "</a></li>";
				sHtml += "<li><a id=\"resource_view_modifyAll\" href=\"#\" onclick=\"javascript: mobile_resource_clickExmenuBtn(this);\" class=\"btn\">"+mobile_comm_getDic('lbl_schedule_modify_all')+"</a></li>"
			} else{
				sHtml += "<li><a id=\"resource_view_modify\" onclick=\"mobile_resource_clickExmenuBtn(this);\" class=\"btn\">" + mobile_comm_getDic("btn_Modify") + "</a></li>";	
			}
			
			/*<li><a id="resource_view_delete" onclick="mobile_resource_clickExmenuBtn(this);" class="btn" style="display: none;">삭제</a></li>
			<li><a id="resource_view_approval" onclick="mobile_resource_clickExmenuBtn(this);" class="btn" style="display: none;">승인</a></li>
			<li><a id="resource_view_reject" onclick="mobile_resource_clickExmenuBtn(this);" class="btn" style="display: none;">거부</a></li>
			<li><a id="resource_view_return" onclick="mobile_resource_clickExmenuBtn(this);" class="btn" style="display: none;">반납확인</a></li>
			<li><a id="resource_view_appcancel" onclick="mobile_resource_clickExmenuBtn(this);" class="btn" style="display: none;">승인취소</a></li>
			<li><a id="resource_viewer_reqcancel" onclick="mobile_resource_clickExmenuBtn(this);" class="btn" style="display: none;">신청철회</a></li>*/
			if (bookingData.RegisterCode == _mobile_resource_common.userCode){
				if (bookingData.ApprovalStateCode == "Approval"){
					if(bookingData.ReturnTypeCode == "ChargeConfirm" && (_mobile_resource_common.CurrentTime >= new Date(mobile_resource_ReplaceDate(bookingData.StartDateTime))))
						sHtml += "<li><a id=\"resource_viewer_returnrequest\" onclick=\"mobile_resource_modifyBookingState(" + book.DateID + ", \'ReturnRequest\')\" class=\"btn\">" + mobile_comm_getDic("lbl_ReturnRequest") + "</a></li>"; //반납요청
					else
						sHtml += "<li><a id=\"resource_viewer_reqcancel\" onclick=\"mobile_resource_modifyBookingState(" + bookingData.DateID + ", \'ApprovalCancel\')\" class=\"btn\">" + mobile_comm_getDic("lbl_ApplicationWithdrawn") + "</a></li>";
				} else if (bookingData.ApprovalStateCode == "ApprovalRequest"){
					sHtml += "<li><a id=\"resource_viewer_reqcancel\" onclick=\"mobile_resource_modifyBookingState(" + bookingData.DateID + ", \'ApprovalCancel\')\" class=\"btn\">" + mobile_comm_getDic("lbl_ApplicationWithdrawn") + "</a></li>";
				}
			}
			
			$("#resource_view_exmenu_list").html(sHtml);
			
			$('div.utill').show();
		} else {
			$('div.utill').hide();
		}
		
		$("#resource_view_subject").html(bookingData.Subject);
	
		$("#resource_view_datetime").html(mobile_resource_display(bookingData.StartDateTime,bookingData.EndDateTime,bookingData.IsAllDay,bookingData.IsRepeat));		
		
		if(bookingData.IsRepeat == "Y" && _mobile_resource_common.IsRepeat == "Y"){
			var startEndDateTime = mobile_resource_getRepeatViewMessage(repeatData);
			
			$("#resource_view_repeatInfo").html(startEndDateTime);
		}else{
			$("#resource_view_repeatInfo").html(mobile_comm_getDic("lbl_noRepeat")); //반복없음
		}
		
		//$("#RegisterPhoto").attr("src", bookingData.RegisterPhoto);
		$("#resource_view_registerName").html(bookingData.RegisterName+" "+bookingData.UserPositionName+" "+( (bookingData.UserDeptName == "" || bookingData.UserDeptName == undefined) ? "" : "("+bookingData.UserDeptName+")"));
		
		//참석자
		if(attendee.length > 0 && attendee[0].UserCode != undefined){
			var attendeeHTML = "<dt>" + mobile_comm_getDic("lbl_schedule_attendant") + "</dt>"; //참석자
			$(attendee).each(function(){
				
				attendeeHTML += '<dd>';	
				
				if (bookingData.LinkScheduleID.length > 0 && bookingData.LinkScheduleID != undefined){
					if(this.IsAllow == "Y")
						attendeeHTML += '<span class="flag_cr02">' + mobile_comm_getDic("lbl_schedule_participation") + '</span>'; //참여
					else if(this.IsAllow == "N")
						attendeeHTML += '<span class="flag_cr01">' + mobile_comm_getDic("lbl_schedule_Nonparticipation") + '</span>'; //비참여
					else
						attendeeHTML += '<span class="flag_cr03">' + mobile_comm_getDic("lbl_schedule_standBy") + '</span>'; //대기중
				}
							
				attendeeHTML += this.UserName+ ((this.IsOutsider == 'Y') ? ' ('+mobile_comm_getDic("ACC_lbl_outsideAttendant")+')' : this.DeptName == undefined ? "" : ' ('+this.DeptName+')' )+'&nbsp;</dd>'; 
			});
			$("#resource_view_attendee").html(attendeeHTML);
		}else{
			$("#resource_view_attendee").html("<dt>" + mobile_comm_getDic("lbl_schedule_attendant") + "</dt><span>" + mobile_comm_getDic("lbl_noexists") + "</span>"); //참석자 없음			
		}
		
		// 알림은 등록자와 참석자만 변경할 수 있음
//		if($.isEmptyObject(notification)){
//			$("#resource_view_isnotificationdiv").hide();
//		}else{
//			$("#resource_view_remindertime").val(notification.ReminderTime);
//			if(notification.IsNotification == "Y"){
//				if($("#resource_view_isnotificationdiv").hasClass('on') == false){
//					$("#resource_view_isnotificationdiv").show();
//				}
//				else{
//					$("#resource_view_isnotificationdiv").hide();
//				}
//			}
//			if(notification.IsReminder == "Y"){
//				$("#resource_view_isremindera").parent().addClass('on');
//				$('#resource_view_notice_divReminderTime').css('visibility', 'visible');
//			} else {
//				$("#resource_view_isremindera").parent().removeClass('on');
//				$('#resource_view_notice_divReminderTime').css('visibility', 'hidden');
//			}
//			if(notification.IsCommentNotification == "Y"){
//				$("#resource_view_isrcommenta").parent().addClass('on');
//			} else {
//				$("#resource_view_isrcommenta").parent().removeClass('on');
//			}
//		}
		
		if($("#resource_view_folderName").text().indexOf(bookingData.ResourceName) == -1)
			$("#resource_view_folderName").prepend(bookingData.ResourceName);
		
		$("#resource_view_approvalState").html(bookingData.ApprovalState);
		var state_class = "";
		if(bookingData.ApprovalState == mobile_comm_getDic("lbl_ApprovalReq") || bookingData.ApprovalState == mobile_comm_getDic("lbl_ReturnRequest")) { //승인요청, 반납요청
			state_class = "ask";
		} else if(bookingData.ApprovalState == mobile_comm_getDic("lbl_Approved")) { //승인
			state_class = "app";
		} else if(bookingData.ApprovalState == mobile_comm_getDic("lbl_res_ReturnComplete")) { //반납완료
			state_class = "appretrunreq";
		} else if(bookingData.ApprovalState == mobile_comm_getDic("lbl_ApplicationWithdrawn")) { //신청철회
			state_class = "returncomp";
		}
		$("#resource_view_approvalState").addClass(state_class);
		
		if(bookingData.LinkScheduleID != ""){
			$("#resource_view_schedule").attr("eventID", bookingData.LinkScheduleID);
			if($("#resource_view_schedule").text().indexOf(bookingData.Subject) == -1)
				$("#resource_view_schedule").html('<span class="label">' + mobile_comm_getDic("lbl_resource_linkedSchedule") + '</span>' + bookingData.Subject);
			
			var sUrl = "/groupware/mobile/schedule/view.do";
			sUrl += "?eventid=" + bookingData.LinkScheduleID;
			sUrl += "&dateid=" + bookingData.DateID;
			sUrl += "&isrepeat=" + bookingData.IsRepeat;
			sUrl += "&isrepeatall=" + bookingData.IsRepeat;
			sUrl += "&folderid=" + bookingData.FolderID;
			
			$("#resource_view_schedule").attr("onclick", 'mobile_comm_go(\'' + sUrl + '\',\'Y\');');
		}else{
			//$("#resource_view_schedule").html('<span class="label">' + mobile_comm_getDic("lbl_resource_linkedSchedule") + '</span>' + mobile_comm_getDic("lbl_noexists"));
			$("#resource_view_schedule").html('<span class="label">' + mobile_comm_getDic("lbl_resource_linkedSchedule") + '</span>&nbsp;');
		}
		
		//댓글
		mobile_comment_getCommentLike('Resource'
				, _mobile_resource_common.EventID + '_'  + _mobile_resource_common.DateID, 'N'); // + '_'  + _mobile_resource_common.ResourceID + '_'  + _mobile_resource_common.RepeatID
				
		//var strIsRepeat = (mobile_comm_getQueryString('isrepeat', 'schedule_view_page') != 'undefined') ? mobile_comm_getQueryString('isrepeat', 'schedule_view_page') : '';
		var strRepeatID = (mobile_comm_getQueryString('repeatid', 'schedule_view_page') != 'undefined') ? mobile_comm_getQueryString('repeatid', 'schedule_view_page') : '';
		var strIsRepeatAll = (mobile_comm_getQueryString('isrepeatall', 'schedule_view_page') != 'undefined') ? mobile_comm_getQueryString('isrepeatall', 'schedule_view_page') : '';
		var strResourceID = (mobile_comm_getQueryString('resourceid', 'schedule_view_page') != 'undefined') ? mobile_comm_getQueryString('resourceid', 'schedule_view_page') : '';
		var commentURL = mobile_comm_getGlobalProperties("smart4j.path")+"/groupware/layout/resource_DetailView.do?CLSYS=resource&CLMD=user&CLBIZ=Resource"
			+ "&eventID=" + _mobile_resource_common.EventID + "&dateID=" + _mobile_resource_common.DateID + "&isRepeat=" + bookingData.IsRepeat + "&repeatID=" + strRepeatID + "&isrepeatall=" + strIsRepeatAll + "&resourceID=" + strResourceID;
		var mobileURL = mobile_comm_getGlobalProperties("smart4j.path")+"/groupware/mobile/resource/view.do"
			+ "?eventid=" + _mobile_resource_common.EventID + "&dateid=" + _mobile_resource_common.DateID + "&isrepeat=" + bookingData.IsRepeat + "&repeatid=" + strRepeatID + "&isrepeatall=" + strIsRepeatAll + "&resourceid=" + strResourceID;

		mobile_commment_messageSetting = {
			SenderCode : userCode,
			RegistererCode : userCode,
			ReceiversCode : (bookingData.RegisterCode != userCode) ? bookingData.RegisterCode : '',
			GotoURL: commentURL, 
			PopupURL: commentURL, 
			MobileURL: mobileURL,
			MessagingSubject: bookingData.Subject,
			ReceiverText: bookingData.Subject,
			ServiceType: "Resource",
			MsgType: "ResourceComment"
		};
		
	} else if(mode == "DU") { //수정
		updateBookingDataObj = data;
		
		$(updateBookingDataObj.bookAtData).each(function(){
			this.dataType = "OLD";
		});
		
		$("#resource_write_resourceID").val(bookingData.ResourceID);
		$("#resource_write_resourceName").html(bookingData.ResourceName).css("font-size", "1em").css("color", "#222");		
		_mobile_resource_common.ResourceName = bookingData.ResourceName;
		
		$("#resource_write_startdate").val(mobile_resource_SetDateFormat(bookingData.StartDateTime.split(" ")[0], '.'));
		$("#resource_write_enddate").val(mobile_resource_SetDateFormat(bookingData.EndDateTime.split(" ")[0], '.'));
		
		var startTime = bookingData.StartDateTime.split(" ")[1];
		var endTime = bookingData.EndDateTime.split(" ")[1];
		
		$("#resource_write_starttime").val(startTime);
		$("#resource_write_endtime").val(endTime);

		if(bookingData.IsAllDay == "Y") {
			$("#resource_write_chkAllDay").prop("checked", true).checkboxradio('refresh');
	        $("#resource_write_hidstartdate").val($("#resource_write_startdate").val());
	        $("#resource_write_hidstarttime").val($("#resource_write_starttime").val());
	        $("#resource_write_hidenddate").val($("#resource_write_enddate").val());
	        $("#resource_write_hidendtime").val($("#resource_write_endtime").val());
		}
		
		var tempRepeatType = "";
		switch(repeatData.RepeatType) {
		case "D":
			tempRepeatType = "Day"; break;
		case "W":
			tempRepeatType = "Week"; break;
		case "M":
			tempRepeatType = "Month"; break;
		case "Y":
			tempRepeatType = "Year"; break;
		default:
			tempRepeatType = "No"; break;	
		}
		mobile_resource_changeTab(tempRepeatType);
		$("#resource_write_repeat").addClass("show");
		
		if(tempRepeatType != "No") {
			if(tempRepeatType == "Day") {
				if(repeatData.RepeatDay == "0") {
					$("#resource_write_day_everyday").prop("checked", true).checkboxradio('refresh');
				} else {
					$("#resource_write_day_setday").prop("checked", true).checkboxradio('refresh');
					$("#resource_write_day_inputday").val(repeatData.RepeatDay);
				}
			} else if(tempRepeatType == "Week") {
				$("#resource_write_week_inputweek").val(repeatData.RepeatWeek);
				if(repeatData.RepeatMonday == "Y") $("#resource_write_week_mon").addClass("on");
				if(repeatData.RepeatTuesday == "Y") $("#resource_write_week_tue").addClass("on");
				if(repeatData.RepeatWednseday == "Y") $("#resource_write_week_wed").addClass("on");
				if(repeatData.RepeatThursday == "Y") $("#resource_write_week_thu").addClass("on");
				if(repeatData.RepeatFriday == "Y") $("#resource_write_week_fri").addClass("on");
				if(repeatData.RepeatSaturday == "Y") $("#resource_write_week_sat").addClass("on");
				if(repeatData.RepeatSunday == "Y") $("#resource_write_week_sun").addClass("on");
			} else if(tempRepeatType == "Month") {
				$("#resource_write_month_inputmonth").val(repeatData.RepeatMonth);
				if(repeatData.RepeatDay == "0") {
					$("#resource_write_month_setdayofweek").prop("checked", true).checkboxradio('refresh');
					$("#resource_write_month_selectseq").val(repeatData.RepeatWeek);
					if(repeatData.RepeatMonday == "Y") $("#resource_write_month_selectdayofweek").val(mobile_comm_getDic("lbl_sch_mon"));
					else if(repeatData.RepeatTuesday == "Y") $("#resource_write_month_selectdayofweek").val(mobile_comm_getDic("lbl_sch_tue"));
					else if(repeatData.RepeatWednseday == "Y") $("#resource_write_month_selectdayofweek").val(mobile_comm_getDic("lbl_sch_wed"));
					else if(repeatData.RepeatThursday == "Y") $("#resource_write_month_selectdayofweek").val(mobile_comm_getDic("lbl_sch_thr"));
					else if(repeatData.RepeatFriday == "Y") $("#resource_write_month_selectdayofweek").val(mobile_comm_getDic("lbl_sch_fri"));
					else if(repeatData.RepeatSaturday == "Y") $("#resource_write_month_selectdayofweek").val(mobile_comm_getDic("lbl_sch_sat"));
					else if(repeatData.RepeatSunday == "Y") $("#resource_write_month_selectdayofweek").val(mobile_comm_getDic("lbl_sch_sun"));
				} else {
					$("#resource_write_month_setday").prop("checked", true).checkboxradio('refresh');
					$("#resource_write_month_inputday").val(repeatData.RepeatDay);
				}
			} else if(tempRepeatType == "Year") {
				$("#resource_write_year_inputyear").val(repeatData.RepeatYear);
				$("#resource_write_year_selectmonth").val(repeatData.RepeatMonth);
				if(repeatData.RepeatDay == "0") {
					$("#resource_write_year_setdayofweek").prop("checked", true).checkboxradio('refresh');
					$("#resource_write_year_selectseq").val(repeatData.RepeatWeek);
					if(repeatData.RepeatMonday == "Y") $("#resource_write_year_selectdayofweek").val(mobile_comm_getDic("lbl_sch_mon"));
					else if(repeatData.RepeatTuesday == "Y") $("#resource_write_year_selectdayofweek").val(mobile_comm_getDic("lbl_sch_tue"));
					else if(repeatData.RepeatWednseday == "Y") $("#resource_write_year_selectdayofweek").val(mobile_comm_getDic("lbl_sch_wed"));
					else if(repeatData.RepeatThursday == "Y") $("#resource_write_year_selectdayofweek").val(mobile_comm_getDic("lbl_sch_thr"));
					else if(repeatData.RepeatFriday == "Y") $("#resource_write_year_selectdayofweek").val(mobile_comm_getDic("lbl_sch_fri"));
					else if(repeatData.RepeatSaturday == "Y") $("#resource_write_year_selectdayofweek").val(mobile_comm_getDic("lbl_sch_sat"));
					else if(repeatData.RepeatSunday == "Y") $("#resource_write_year_selectdayofweek").val(mobile_comm_getDic("lbl_sch_sun"));
				} else {
					$("#resource_write_year_setday").prop("checked", true).checkboxradio('refresh');
					$("#resource_write_year_inputday").val(repeatData.RepeatDay);
				}
			}
			
			if(repeatData.RepeatEndType == "R") {
				$("#resource_write_" + tempRepeatType.toLowerCase() + "_inputrepeat").val(repeatData.RepeatCount);
				$("#resource_write_" + tempRepeatType.toLowerCase() + "_setrepeat").prop("checked", true).checkboxradio('refresh');
			} else if(repeatData.RepeatEndType == "I") {
				$("#resource_write_" + tempRepeatType.toLowerCase() + "_inputend").val(repeatData.RepeatEndDate);
				$("#resource_write_" + tempRepeatType.toLowerCase() + "_setend").prop("checked", true).checkboxradio('refresh');
				
			}
	        if (mobile_comm_getQueryString('isrepeat', 'resource_write_page') == 'Y' && mobile_comm_getQueryString('isrepeatall', 'resource_write_page')== 'Y') {
	        	$("#resource_write_repeatChk").trigger("click");
	        } else{
	        	$(".repeats_wrap").hide();
	        }
		}
		
		if(bookingData.LinkScheduleID != ""){
			$("#resource_write_interlockYN").addClass("on");
			$("#resource_write_interlockYN").parent().addClass("active");
		}
		
		// 알림은 등록자와 참석자만 변경할 수 있음
		if($.isEmptyObject(notification)){
			$("#resource_write_prealarm").hide();
			$("#resource_write_commentalarm").hide();
		}else{
			if(notification.IsNotification == "Y"){
				$('#resource_write_notice').trigger('click');
				$("#resource_write_notice_remindertime").val(notification.ReminderTime);
				if(notification.IsReminder == "Y"){
					$("#resource_write_notice_reminderYN").addClass("on");
					$("#resource_write_notice_divReminderTime").css("visibility", "visible");
				}
				if(notification.IsCommentNotification == "Y"){
					$("#resource_write_notice_commentYN").addClass("on");
				}
			}	
		}
		
		// Subject
		$("#resource_write_subject").val(bookingData.Subject.split('&nbsp;').join(' ').split('<br />').join('\n'));
		
		// UserForm
		$(userDefValue).each(function(){
			var obj = "[name=option_"+this.UserFormID+"]";
			
			switch (this.FieldType) {
			case "Input": case "TextArea": case "Date":
				$(obj).val(this.FieldValue);
				break;
			case "Radio": case "CheckBox":
				$(obj+"[value="+this.FieldValue+"]").prop("checked", true).checkboxradio('refresh');
				break;
			case "DropDown":
				$(obj).find("option[value="+this.FieldValue+"]").attr("selected", "selected");
				break;
			default:
				break;
			}
		});
		
		//attendee
		var attendeeListHTML = "";
		if(attendee.length > 0){
			$(attendee).each(function(){
				var userCode = $$(this).attr("UserCode");
				var userName = $$(this).attr("UserName");
				
				var dataJson = "data-json=\'" + JSON.stringify({"UserCode":userCode,"UserName":userName, "label":userName,"value":userCode}) + "\'";
				var dataValue = "data-value=\"" + userCode + "|" + this.IsAllow + "\"";
				
				attendeeListHTML += "<a onclick=\"mobile_schedule_delUser(this);\" class=\"btn_add_person\" " + dataJson + " " + dataValue + ">";
				attendeeListHTML += userName;
				attendeeListHTML += "</a>";
			});
			$("#joins_wrapArea").append(attendeeListHTML).show();
		}
		
		//$("#resource_write_prealarm").hide();
		//$("#resource_write_commentalarm").hide();		
	}
}

//시간 출력 Format Setting
function mobile_resource_setTimeFormat(time) {
	if(time < 60) {
		return time + mobile_comm_getDic("lbl_before_m");
	} else if(time < 60*24) { //1440
		return (time/60) + mobile_comm_getDic("lbl_before_h");
	} else {
		return (time/(60*24)) + mobile_comm_getDic("lbl_before_d");
	}
}

//조회 화면에서 반복에 대한 메시지
function mobile_resource_getRepeatViewMessage(repeatInfo){
	var returnMessage = "";
	
	var sAppointmentStartTime = $$(repeatInfo).attr("AppointmentStartTime");
    var sAppointmentEndTime = $$(repeatInfo).attr("AppointmentEndTime");
    
	var sRepeatType = $$(repeatInfo).attr("RepeatType");
	var sRepeatStartDate = $$(repeatInfo).attr("RepeatStartDate");
	var sRepeatEndDate = $$(repeatInfo).attr("RepeatEndDate");
	var sRepeatEndType = $$(repeatInfo).attr("RepeatEndType");
	var sRepeatCount = $$(repeatInfo).attr("RepeatCount");
	var sRepeatAppointType = $$(repeatInfo).attr("RepeatAppointType");
	
    var sRepeatYear = $$(repeatInfo).attr("RepeatYear");
    var sRepeatMonth = $$(repeatInfo).attr("RepeatMonth");
    var sRepeatWeek = $$(repeatInfo).attr("RepeatWeek");
    var sRepeatDay = $$(repeatInfo).attr("RepeatDay");
	
    var sRepeatMonday = $$(repeatInfo).attr("RepeatMonday");
    var sRepeatTuesday = $$(repeatInfo).attr("RepeatTuesday");
    var sRepeatWednseday = $$(repeatInfo).attr("RepeatWednseday");
    var sRepeatThursday = $$(repeatInfo).attr("RepeatThursday");
    var sRepeatFriday = $$(repeatInfo).attr("RepeatFriday");
    var sRepeatSaturday = $$(repeatInfo).attr("RepeatSaturday");
    var sRepeatSunday = $$(repeatInfo).attr("RepeatSunday");
    
    var l_DateString = "";
    
	returnMessage += mobile_comm_getDic("lbl_From0").replace("{0}", mobile_resource_SetDateFormat(sRepeatStartDate, '.')) + " ";			// {0}부터
	
	if(sRepeatEndType == "R"){
		returnMessage += mobile_comm_getDic("lbl_Atimes").replace("{0}", sRepeatCount) + " ";			//	{0} 회
	}else{
		returnMessage += mobile_comm_getDic("lbl_To0").replace("{0}", mobile_resource_SetDateFormat(sRepeatEndDate, '.')) + " ";			// 	{0}까지
	}
    
	switch (sRepeatType){
		case "D":
			if(sRepeatAppointType == "A"){
				returnMessage += mobile_comm_getDic("lbl__EveryDays0").replace("{0}", sRepeatDay) + " ";		//	매 {0}일마다
			}else{
				returnMessage += mobile_comm_getDic("lbl_SchEveryday") + " ";		//	매일(평일)에
			}
			break;
		case "W":
			returnMessage += mobile_comm_getDic("lbl_EveryNumWeek").replace("{0}", sRepeatWeek) + " ";	//  매{0}주
			break;
		case "M": 
		case "Y":
			if(sRepeatAppointType == "A"){
				if(sRepeatType == "M")
					returnMessage += mobile_comm_getDic("lbl_EveryMonthsDays01").replace("{0}", sRepeatMonth).replace("{1}", sRepeatDay) + " ";			// {0}개월마다 {1}일에
				else if(sRepeatType == "Y")
					returnMessage += mobile_comm_getDic("lbl_EveryYearOn").replace("{0}", sRepeatYear).replace("{1}", sRepeatMonth).replace("{2}", sRepeatDay);	//	{0}년마다 {1}월 {2}에
			}else{
				switch (sRepeatWeek) {
					case "1":
						l_DateString = mobile_comm_getDic("lbl_FirstWeek") + " ";		//첫번째 주
						break;
					case "2":
						l_DateString = mobile_comm_getDic("lbl_SecondWeek") + " ";	//두번째주
						break;
					case "3":
						l_DateString = mobile_comm_getDic("lbl_ThirdWeek") + " ";		//세번째주
						break;
					case "4":
						l_DateString = mobile_comm_getDic("lbl_FourthWeek") + " ";	//네번째주
						break;
					case "5":
						l_DateString = mobile_comm_getDic("lbl_FifthWeek") + " ";		//다섯번째주
						break;
					default:
						break;
				}
				if(sRepeatDay != "0"){
					switch (sRepeatDay) {
						case "1":
							l_DateString = mobile_comm_getDic("lbl_Sunday0") + " ";			//일요
							break;
						case "2":
							l_DateString = mobile_comm_getDic("lbl_Monday0") + " ";		//월요
							break;
						case "3":
							l_DateString = mobile_comm_getDic("lbl_Tuesday0") + " ";		//화요
							break;
						case "4":
							l_DateString = mobile_comm_getDic("lbl_Wednesday0") + " ";	//수요
							break;
						case "5":
							l_DateString = mobile_comm_getDic("lbl_Thursday0") + " ";		//목요
							break;
						case "6":
							l_DateString = mobile_comm_getDic("lbl_Friday0") + " ";			//금요
							break;
						case "7":
							l_DateString = mobile_comm_getDic("lbl_Saturday0") + " ";		//토요
							break;
						default:
							break;
					}
				}else{
					if (sRepeatSunday == "Y") l_DateString += mobile_comm_getDic("lbl_Sunday0");
					if (sRepeatMonday == "Y") l_DateString += mobile_comm_getDic("lbl_Monday0");
					if (sRepeatTuesday == "Y") l_DateString += mobile_comm_getDic("lbl_Tuesday0");
					if (sRepeatWednseday == "Y") l_DateString += mobile_comm_getDic("lbl_Wednesday0");
					if (sRepeatThursday == "Y") l_DateString += mobile_comm_getDic("lbl_Thursday0");
					if (sRepeatFriday == "Y") l_DateString += mobile_comm_getDic("lbl_Friday0");
					if (sRepeatSaturday == "Y") l_DateString += mobile_comm_getDic("lbl_Saturday0");
				}
				if(sRepeatType == "M")
					returnMessage += mobile_comm_getDic("lbl_EveryMonthsDays01").replace("{0}", sRepeatMonth).replace("{1}", l_DateString) + " ";			// {0}개월마다 {1}일에
				else if(sRepeatType == "Y")
					returnMessage += mobile_comm_getDic("lbl_EveryYearOn").replace("{0}", sRepeatYear).replace("{1}", sRepeatMonth).replace("{2}", l_DateString);	//	{0}년마다 {1}월 {2}에
			}
			break;
	}
	returnMessage += mobile_comm_getDic("lbl_RepeteSettingAtoB").replace("{0}", sAppointmentStartTime).replace("{1}", sAppointmentEndTime) + " ";			// {0}부터 {1}까지 반복 설정
	
	return returnMessage;
}

//확장메뉴 클릭 시
function mobile_resource_clickExmenuBtn(obj) {
	var mode = $(obj).attr("id").replace("resource_view_", "");
	
	isresUpdate = true;
	
	switch (mode) {
	case "modify":
		var sUrl = "";
		sUrl += "/groupware/mobile/resource/write.do";
		sUrl += "?eventid=" + _mobile_resource_common.EventID;
		sUrl += "&dateid=" + _mobile_resource_common.DateID;
		sUrl += "&isrepeat=" + _mobile_resource_common.IsRepeat;
		sUrl += "&repeatid=" + _mobile_resource_common.RepeatID;
		sUrl += "&resourceid=" + _mobile_resource_common.ResourceID;
		sUrl += "&isrepeatall=" + "N";
		
		mobile_comm_go(sUrl, 'Y');
		
		break;
	case "modifyAll":
		var sUrl = "";
		sUrl += "/groupware/mobile/resource/write.do";
		sUrl += "?eventid=" + _mobile_resource_common.EventID;
		sUrl += "&dateid=" + _mobile_resource_common.DateID;
		sUrl += "&isrepeat=" + _mobile_resource_common.IsRepeat;
		sUrl += "&repeatid=" + _mobile_resource_common.RepeatID;
		sUrl += "&resourceid=" + _mobile_resource_common.ResourceID;
		sUrl += "&isrepeatall=" + "Y";
		
		mobile_comm_go(sUrl, 'Y');
		break;
	}
}

//조회화면에서 알림 개별 설정
function mobile_resource_saveAlarm(pObj){

	var eventID = _mobile_resource_common.EventID;
	var isNotification = "Y";
	var isReminder = $("#resource_view_isremindera").parent().hasClass('on') ? "Y" : "N";
	var reminderTime = $("#resource_view_remindertime option:selected").val();
	var isComment = $("#resource_view_isrcommenta").parent().hasClass('on') ? "Y" : "N";
	var dateID = _mobile_resource_common.DateID;
	var updateType = "";
	var folderID = _mobile_resource_common.FolderID;
	var folderType = _mobile_resource_common.FolderType;	
	var subject = $("#resource_view_subject").text();
	
	//ui 변화가 먼저 발생하지 않기 때문에, 변경하고자 하는 값에 대한 추가 처리 필요
	if(pObj != undefined && $(pObj).find('span').length > 0) {
		if($(pObj).find('span').attr('id') == "resource_view_isremindera") {
			isReminder = (isReminder == "Y" ? "N" : "Y");
			$('#resource_view_notice_divReminderTime').css('visibility', (isReminder == "Y" ? 'visible' : 'hidden'));
			updateType = "Reminder";
		} else if($(pObj).find('span').attr('id') == "resource_view_isrcommenta") {
			isComment = (isComment == "Y" ? "N" : "Y");
			updateType = "Comment";
		}
	}
	
	if($(pObj).hasClass('on')){
		$(pObj).removeClass('on');
	} else {
		$(pObj).addClass('on');
	}
	
	var url = "/groupware/mobile/schedule/setNotification.do";
	$.ajax({
	    url: url,
	    type: "POST",
	    data: {
	    	"UpdateType" : updateType,  //All or Comment or Reminder
	    	"EventID" : eventID,
			"DateID" : dateID,
	    	"RegisterCode" : mobile_comm_getSession("UR_Code"),
	    	"IsNotification" : isNotification,
	    	"IsReminder" : isReminder,
	    	"ReminderTime" : reminderTime,
	    	"IsCommentNotification" : isComment,
			"FoderID" : folderID,
	    	"FolderType": folderType,
	    	"Subject" : subject
	    },
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		alert(mobile_comm_getDic("msg_changeAlarmSetting")); //알림 설정을 수정하였습니다.
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
	    	}
	    },
	    error:function(response, status, error){
	    	mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}


//전체 미리알림 체크박스 변경 이벤트
function mobile_resource_changeTotalReminder(obj) {
	$("#resource_view_totalremindertime").prop("disabled", !$(obj).prop("checked"));
}

//전체 알림 수정
function mobile_resource_modifyAllNoti() {
	var eventID = _mobile_resource_common.EventID;
	var notiInfo = {};
	
	notiInfo.reminder = $("#resource_view_totalisremindera").prop("checked") ? "Y" : "N";
	notiInfo.reminderTime = $("#resource_view_totalremindertime").val();
	notiInfo.comment = $("#resource_view_totalisrcomment").prop("checked") ? "Y" : "N";
	
	// eventID 기준으로 현재 사용자의 모든 알림 수정 (데이터가 기본적으로 입력되있는 상태는 아니므로 Delete -> Insert)
	$.ajax({
	    url: "/groupware/mobile/schedule/modifyAllNoti.do",
	    type: "POST",
	    data: {EventID : eventID, NotiInfo : JSON.stringify(notiInfo)},
	    async: false,
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		alert(mobile_comm_getDic("msg_SuccessModify"));
	    		mobile_resource_ViewInit();   		
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));
	    	}
      },
      error:function(response, status, error){
      	mobile_comm_ajaxerror(url, response, status, error);			
		}
	});
}

//전체 알림 삭제
function mobile_resource_deleteAllNoti() {
	var eventID = _mobile_resource_common.EventID;
		
	// eventID 기준으로 현재 사용자의 모든 알림 제거
	$.ajax({
	    url: "/groupware/mobile/schedule/deleteAllNoti.do",
	    type: "POST",
	    data: {EventID : eventID},
	    async: false,
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
	    		alert(mobile_comm_getDic("msg_SuccessModify"));
	    		mobile_resource_ViewInit();   		
	    	}else{
	    		alert(mobile_comm_getDic("msg_apv_030"));
	    	}
      },
      error:function(response, status, error){
      	mobile_comm_ajaxerror(url, response, status, error);			
		}
	});
}


/*!
 * 
 * 자원예약 상세 끝
 * 
 */





/*!
 * 
 * 자원예약 자원정보 시작
 * 
 */

function mobile_resource_InfoInit() {
	$("#resource_info_header").children("a").remove();
	
	mobile_resource_InitJS();
	_mobile_resource_common.ResourceID = window.sessionStorage.getItem("resourceid");
	
	mobile_resource_setResourceInfo(_mobile_resource_common.ResourceID);
}

//자원 정보 세팅
function mobile_resource_setResourceInfo(folderID){
	// 자원 정보
	// 사업장 사용 여부
    if((mobile_comm_getBaseConfig("IsUsePlaceOfBusinessSel") === "N")){
        $("#resource_info_placeOfBusiness").hide();
    }else{
        $("#resource_info_placeOfBusiness").show();

    }
	$.ajax({
	    url: "/groupware/mobile/resource/getResourceData.do",
	    type: "POST",
	    data: {
	    	"FolderID" : folderID
		},
	    success: function (res) {
	    	if(res.status == "SUCCESS") {
	    		// Folder Data
	    		if(res.data.folderData) {
	    			var folderData = res.data.folderData;

	    			var resourceName = folderData.ResourceName;

	    			if(folderData.PlaceOfBusiness != "" && folderData.PlaceOfBusiness != undefined){
	    				var placeOfBusinessStr = "";
	    				var placeOfBusinessArr = folderData.PlaceOfBusiness.split(";");
	    				
	    				$("#resource_info_placeOfBusiness").append('<span class="locIcon02"></span>');
	    				var cnt = placeOfBusinessArr.length;
	    				for(var i=0; i<cnt-1; i++){
	    					placeOfBusinessStr = mobile_comm_getDicInfo($$(mobile_comm_getBaseCode("PlaceOfBusiness")).find("CacheData[Code="+placeOfBusinessArr[i]+"]").attr("MultiCodeName"), parent.lang);
	    					$("#resource_info_placeOfBusiness").append(placeOfBusinessStr);
	    					
	    					if(placeOfBusinessArr.length-2 != i)
	    						$("#resource_info_placeOfBusiness").append(", ");
	    				}
	    			}else{
	    				//$("#resource_info_placeOfBusiness").append(mobile_comm_getDic("lbl_noexists"));	    				
	    				$("#resource_info_placeOfBusiness").append("&nbsp;");
	    			}
	    			
	    			$("#resource_info_parentFolderName").append(checkNoData(folderData.ParentFolderName) + "<strong>" + resourceName + "</strong>");
	    			
	    			$("#resource_info_description").append(checkNoData(folderData.Description));
	    			$("#resource_info_ParentName").append(checkNoData(folderData.ParentFolderName));
	    			
	    			$("#resource_info_resourceImage").attr("style", "width:104px; height:88px;");
	    			$("#resource_info_resourceImage").attr("src", "/covicore/common/view/Resource/"+folderData.ResourceImage+".do");

	    			if(folderData.ResourceImage != null && folderData.ResourceImage != undefined && folderData.ResourceImage != ''){
	    				$("#resource_info_resourceImage").parent('span').css("background","#f2f2f2");
	    			}
	    			
	    		}
	    		
	    		// Resource Data
	    		if(res.data.resourceData){
	    			var resourceData = res.data.resourceData;
	    			
	    			$("#resource_info_bookingType").append(checkNoData(resourceData.BookingType));
	    			$("#resource_info_returnType").append(checkNoData(resourceData.ReturnType));
	    			
	    			if(checkNoData(resourceData.DescriptionURL,true))
	    				$("#resource_info_descriptionURL").hide();
	    			else
	    				$("#resource_info_descriptionURL").append(resourceData.DescriptionURL);
	    			
	    			var leastRentalTime = resourceData.LeastRentalTime;
	    			if(leastRentalTime == undefined || leastRentalTime == '') {
	    				//leastRentalTime = mobile_comm_getDic("lbl_noexists");	    				
	    				leastRentalTime = "&nbsp;";
	    			} else {
	    				leastRentalTime = mobile_comm_getDic("lbl_resource_leastMin").replace("{0}", leastRentalTime);		//최소 n분 이상
	    			}
	    			$("#resource_info_leastRentalTime").append(leastRentalTime);
	    		}
	    		
	    		// Manager List
	    		if(res.data.managerList.length > 0){
	    			$(res.data.managerList).each(function(i){
	    				var managerStr = "";
	    				var subjectName = this.SubjectName;
	    				
	    				if(this.UserType == "User"){
	    					managerStr += '<span class="photo" style="background-image: url(\'' + mobile_comm_getimg(this.PhotoPath) + '\'), url(\'' + mobile_comm_noperson() + '\')">';
	    					subjectName = subjectName + " " + this.UserPositionName + " (" + this.UserDeptName + ")";
	    				}
	    				managerStr += "</span>";
	    				
	    				managerStr += subjectName;
					
	    				if(i == 0) {
	    					$("#resource_info_managerList").append(managerStr);
	    				} else {
	    					$("#resource_info_managerList").append(", " + managerStr);
	    				}
	    			});
	    		}else{
	    			//$("#resource_info_managerList").append(mobile_comm_getDic("lbl_noexists"));		//없음	    			
	    			$("#resource_info_managerList").append("&nbsp;");		//없음
	    		}
	    		
	    		// Attribute List
	    		if(res.data.attributeList.length > 0){
	    			var attributeStr = "";
	    			$(res.data.attributeList).each(function(i){
	    				if((i+1)%2 != 0)
	    					attributeStr += '<div>';
	    				attributeStr += '<div class="tit">'+this.AttributeName+'</div>';
	    				attributeStr += '<div class="txt"><p>'+this.AttributeValue+'</p></div>';
	    				
	    				if((i+1)%2 == 0 || (res.data.attributeList.length%2 != 0 && res.data.attributeList.length==(i+1)))
	    					attributeStr += '</div>';
	    			});
	    			$("#resource_info_attrAfter").append(attributeStr);
	    		}
	    		
	    		// Equipment List
	    		if(res.data.equipmentList.length>0){
	    			$(res.data.equipmentList).each(function(){
	    				$("#resource_info_equipmentList").append('<span class="eq">'+this.EquipmentName+'</span>');
	    			});
	    		}else{
	    			//$("#resource_info_equipmentList").append(mobile_comm_getDic("lbl_noexists"));		//없음	    			
	    			$("#resource_info_equipmentList").append("&nbsp;");		//없음
	    		}
		    	
	    	} else {
				alert(mobile_comm_getDic("msg_apv_030"));		// 오류가 발생했습니다.
			}
	    },
	    error:function(response, status, error){
			mobile_comm_ajaxerror("/groupware/mobile/resource/getResourceData.do", response, status, error);
		}
	});
}

/*!
 * 
 * 자원예약 자원정보 끝
 * 
 */





/*!
 * 
 * 자원예약 컨트롤 시작
 * 
 */

//지정한 만큼 이전 일
function mobile_resource_SubtractDays(strDate, days) {
    var date = new Date(mobile_resource_ReplaceDate(strDate));
    var d = date.getDate() - days;
    date.setDate(d);
    return date;
}
//지정한 만큼 이후 일
function mobile_resource_AddDays(strDate, days) {
    var date = new Date(mobile_resource_ReplaceDate(strDate));
    var d = date.getDate() + days;
    date.setDate(d);
    return date;
}
//날짜 비교
function mobile_resource_GetDiffDates(date1, date2, type) {
    //날짜 비교
    var ret = '';
    //소수점 발생
    var num_days = ((((date2 - date1) / 1000) / 60) / 60) / 24;
    var num_hours = ((((date2 - date1) / 1000) / 60) / 60);
    var num_minutes = (((date2 - date1) / 1000) / 60);

    switch (type) {
        case 'day': ret = num_days;
            break;
        case 'hour': ret = num_hours;
            break;
        case 'min': ret = num_minutes;
            break;
    }

    return ret;
}
//해당 달의 일요일 배열객체 생성
function mobile_resource_MakeSunArray(selDate) {
 var sun = [];
 var firstSun = mobile_resource_GetFirstSunOfMonth(selDate);
 var strFirstSun = mobile_resource_SetDateFormat(firstSun, '/');
 var lastSun = mobile_resource_GetLastSunOfMonth(selDate);
 for (var i = 0; i < 6; i++) {
     var sDay = mobile_resource_AddDays(strFirstSun, i * 7);
     sun.push(sDay);
     if (mobile_resource_GetDiffDates(sDay, lastSun, 'day') == 0) {
         break;
     }
 }
 return sun;
}
//특정일이 속한 일요일
function mobile_resource_GetSunday(d) {
	var date = new Date(d);
	var day = date.getDay();
	var diff = date.getDate() - day;
	return new Date(mobile_resource_ReplaceDate(date.setDate(diff)));
}
//날짜 포멧 변환
function mobile_resource_SetDateFormat(pDate, pType) {
  var formattedDate = '';
  var date = new Date(mobile_resource_ReplaceDate(pDate));
  var year = date.getFullYear();
  var month = date.getMonth() + 1;
  var day = date.getDate();
  if (month < 10) {
      month = '0' + month;
  }
  if (day < 10) {
      day = '0' + day;
  }

  switch (pType) {
      case '.': formattedDate = year + '.' + month + '.' + day;
          break;
      case '/': formattedDate = year + '/' + month + '/' + day;
          break;
      case '-': formattedDate = year + '-' + month + '-' + day;
          break;
      case '': formattedDate = year.toString() + month.toString() + day.toString();
          break;
  }
  return formattedDate;
}

//해당 달의 첫번째 일요일 조회
function mobile_resource_GetFirstSunOfMonth(selDate) {
    var arrSelDate = selDate.split('.');
    //이달의 첫째 날
    var firstDay = new Date(arrSelDate[0], Number(arrSelDate[1]) - 1, 1);
    //이달의 첫째 날의 일요일
    var firstSun = mobile_resource_GetSunday(firstDay);
    return firstSun;
}

//해당 달의 마지막 일요일 조회
function mobile_resource_GetLastSunOfMonth(selDate) {
    var arrSelDate = selDate.split('.');
    //이달의 첫째 날
    var strNextFirstDay = arrSelDate[0] + '/' + (Number(arrSelDate[1]) + 1) + '/' + 1;
    var lastDay = mobile_resource_SubtractDays(strNextFirstDay, 1);
    var lastSun = mobile_resource_GetSunday(lastDay);
    return lastSun;
}

//ie, firefox 오류 방지
function mobile_resource_ReplaceDate(dateStr){

    var regexp = /\./g;

    if (typeof dateStr == "string") {
    	if (dateStr.indexOf("-") > -1) {
            regexp = /-/g;
        } else if (dateStr.indexOf(".") > -1) {
            regexp = /\./g;
        } else if (dateStr.indexOf("/") > -1) {
            regexp = /\//g;
        }
        
        return dateStr.replace(regexp, "/");
    } else {
        var tempDate = new Date(dateStr);
        
        dateStr = tempDate.getFullYear() + "/" + (tempDate.getMonth() + 1) + "/" + tempDate.getDate() + " " + mobile_comm_AddFrontZero(tempDate.getHours(), 2) + ":" + mobile_comm_AddFrontZero(tempDate.getMinutes(), 2);
        
        return dateStr;
    }
}

//입력값 앞에 '0'을 붙여서 입력받는 자리수의 문자열을 반환한다.
function mobile_resource_AddFrontZero(inValue, digits) {
	var result = '';
	var inputlength;
	inValue = inValue.toString();
	inputlength = inValue.length;
	if (inputlength < digits) {
		for (var i = 0; i < digits - inputlength; i++)
			result += '0';
	}
	result += inValue;
	return result;
}

//
function mobile_resource_display(pStartDateTime, pEndDateTime, pIsAllday, pIsRepeat){
	var sDateHtml = "";
	var dStartDateTime =new Date(mobile_resource_ReplaceDate(pStartDateTime));
	var dEndDateTime =new Date(mobile_resource_ReplaceDate(pEndDateTime));
	var sStartDate = mobile_resource_SetDateFormat(pStartDateTime, '.');
	var sEndDate = mobile_resource_SetDateFormat(pEndDateTime, '.');
	var sStartTime = mobile_resource_AddFrontZero(dStartDateTime.getHours(), 2)+":"+mobile_resource_AddFrontZero(dStartDateTime.getMinutes(), 2);
	var sEndTime = mobile_resource_AddFrontZero(dEndDateTime.getHours(), 2)+":"+mobile_resource_AddFrontZero(dEndDateTime.getMinutes(), 2);
	if(pIsAllday == undefined)
		pIsAllday = "N";
	if(pIsRepeat == undefined)
		pIsRepeat = "N";
	
	if (sStartDate == sEndDate && pIsAllday == "Y") 
		sDateHtml = sStartDate + " (" + mobile_comm_getDic("lbl_AllDay")+")";
	else if (sStartDate == sEndDate && pIsAllday != "Y") 
		sDateHtml = sStartDate + " " + sStartTime + " ~ " + sEndTime
	else
		sDateHtml = sStartDate + " " + sStartTime + " ~ " + sEndDate+" "+ sEndTime;
	return sDateHtml;	
}

//UI 이벤트 처리
function mobile_resource_clickUiSetting(pObj, pClass){
	if($(pObj).hasClass(pClass)) {
		$(pObj).removeClass(pClass);
		if($(pObj).parent().attr("adata") == "active") {
			$(pObj).parent().removeClass("active");
		}
		
		if($(pObj).attr("sdata") != undefined && $(pObj).attr("sdata") != ""){
			$("#"+$(pObj).attr("sdata")).hide(); 
		} else if($(pObj).attr("adata") != undefined && $(pObj).attr("adata") != ""){
			$("#"+$(pObj).attr("adata")).click(); 
		}
	} else {
		$(pObj).addClass(pClass);
		if($(pObj).parent().attr("adata") == "active") {
			$(pObj).parent().addClass("active");
		}
		
		if($(pObj).attr("sdata") != undefined && $(pObj).attr("sdata") != ""){
			$("#"+$(pObj).attr("sdata")).show(); 
		} else if($(pObj).attr("adata") != undefined && $(pObj).attr("adata") != ""){
			$("#"+$(pObj).attr("adata")).click(); 
		}
	}
}

//새로고침 클릭
function mobile_resource_clickrefresh() {
	 mobile_comm_showload();
	 
	 _mobile_resource_common.EventID = '';
	 _mobile_resource_common.ResourceID = '';
	 _mobile_resource_common.DateID = '';
	 _mobile_resource_common.RepeatID = '';
	 _mobile_resource_common.IsRepeat = '';
	 
	 mobile_resource_MakeResourceList();	

	 $("#resource_view_page").attr("IsLoad", "N");	 
	 
	 mobile_comm_hideload();
}

/*!
 * 
 * 자원예약 컨트롤 끝
 * 
 */

