/*!
 * 
 * 
 * SmartS4j / MobileOffice / 모바일 설문 js 파일
 * 함수명 : mobile_survey_...
 * 
 * 
 */



/*!
 * 
 * 페이지별 init 함수
 * 
 */

//설문 목록 페이지
$(document).on('pageinit', '#survey_list_page', function () {
	if($("#survey_list_page").attr("IsLoad") != "Y"){
		$("#survey_list_page").attr("IsLoad", "Y");
		setTimeout("mobile_survey_ListInit()", 10);
	}
});

//설문 조회 페이지
$(document).on('pageinit', '#survey_view_page', function () {
	if($("#survey_view_page").attr("IsLoad") != "Y"){
		$("#survey_view_page").attr("IsLoad", "Y");
		setTimeout("mobile_survey_ViewInit()", 10);
	}
});

//설문 미리보기 페이지
$(document).on('pageinit', '#survey_preview_page', function () {
	if($("#survey_preview_page").attr("IsLoad") != "Y"){
		$("#survey_preview_page").attr("IsLoad", "Y");
		setTimeout("mobile_survey_PreViewInit()", 10);	
	}
});

//설문 결과보기 페이지
$(document).on('pageinit', '#survey_result_page', function () {
	if($("#survey_result_page").attr("IsLoad") != "Y"){
		$("#survey_result_page").attr("IsLoad", "Y");
		setTimeout("mobile_survey_ResultInit()", 10);	
	}
});


//신규 추가 순위 입력 숫자 및 중복 체크
$(document).on("change", "input[class='choice_num_input']", function(e) {
	var val = Number($(this).val().replace(/[^0-9\.]/g,''));
	var type5 = $(this).closest('.survey_wrap.type5');
	var tar = type5.find("input[class='choice_num_input']");
	
	var tempOrderArrStr = type5.attr("orderArr");
	if(!tempOrderArrStr){
		tempOrderArrStr = "";
	}
	var tempOrderArr = tempOrderArrStr.split(',');
	
	if(!val || val > tar.length || $.inArray(String(val), tempOrderArr) != -1) {
		$(this).val('');
	} else {
		$(this).val(val);
	}
	
	tempOrderArrStr = "";
	tar.each(function(ci, cObj){
		tempOrderArrStr += "," + $(cObj).val();
	});
	type5.attr("ordeArr", tempOrderArrStr);
});

//설문 - 페이지별 init 함수 끝








/*!
 * 
 * 설문 목록
 * 
 */
var _mobile_survey_list = {
	// 리스트 조회 초기 데이터
	SurveyID: '',		//설문ID
	SurveyType: '',		//설문 타입(proceed : 진행중인 설문 / complete : 완료된 설문 / reqApproval : 승인 및 검토요청)
	Page: 1,			//조회할 페이지
	PageSize: 10,		//페이지당 건수
	SearchText: '',		//검색어
	SearchType: '', 	//검색타입
	MySel: "written",	//나의 설문의 메뉴 (written-내가 작성한 설문, participated-내가 참여한 설문)
	
	//커뮤니티용 데이터
	CU_ID: '0',
	
	// 페이징을 위한 데이터
	Loading: false,		//데이터 조회 중
	TotalCount: -1,		//전체 건수
	RecentCount: 0,		//현재 보여지는 건수
	EndOfList: false,	//전체 리스트를 다 보여줬는지
	
	//스크롤 위치 고정
	OnBack: false,		//뒤로가기로 왔을 경우
	Scroll: 0			//스크롤 위치		
};

function mobile_survey_ListInit(){	
	
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('surveytype') != 'undefined') {
		_mobile_survey_list.SurveyType = mobile_comm_getQueryString('surveytype');
	} else {
		if(window.sessionStorage.getItem("mobileSurveyType") != undefined && window.sessionStorage.getItem("mobileSurveyType") != "") {
			_mobile_survey_list.SurveyType = window.sessionStorage.getItem("mobileSurveyType");
		} else {
			_mobile_survey_list.SurveyType = 'proceed';	
		}		
	}
	
	if (mobile_comm_getQueryString('page') != 'undefined') {
		_mobile_survey_list.Page = mobile_comm_getQueryString('page');
	} else {
		_mobile_survey_list.Page = 1;
	}
	
	if (mobile_comm_getQueryString('pagesize') != 'undefined') {
		_mobile_survey_list.PageSize = mobile_comm_getQueryString('pagesize');
	} else {
		_mobile_survey_list.PageSize = 10;
	}
	
	if (mobile_comm_getQueryString('searchtext') != 'undefined') {
		_mobile_survey_list.SearchText = mobile_comm_getQueryString('searchtext');
	} else {
		if(window.sessionStorage.getItem("mobileSurveySearchText") != undefined && window.sessionStorage.getItem("mobileSurveySearchText") != "") {
			_mobile_survey_list.SearchText = window.sessionStorage.getItem("mobileSurveySearchText");
			mobile_comm_opensearch();
			$('#mobile_search_input').val(_mobile_survey_list.SearchText);
		} else {
			_mobile_survey_list.SearchText = '';
			//검색어 초기화
			$('#mobile_search_input').val('');
		}		
	}
	
	if (mobile_comm_getQueryString('searchtype') != 'undefined') {
		_mobile_survey_list.SearchType = mobile_comm_getQueryString('searchtype');
	} else {
		_mobile_survey_list.SearchType = '';
	}
	
	if (mobile_comm_getQueryString('onback') != 'undefined') {
		_mobile_survey_list.OnBack = mobile_comm_getQueryString('onback');
    } else {
    	_mobile_survey_list.OnBack = false;
    }
	
	if (mobile_comm_getQueryString('scroll') != 'undefined') {
		_mobile_survey_list.Scroll = mobile_comm_getQueryString('scroll');
    } else {
    	_mobile_survey_list.Scroll = 0;
    }
	
	if (mobile_comm_getQueryString('cuid') != 'undefined') {
		_mobile_survey_list.CU_ID = mobile_comm_getQueryString('cuid');
    } else {
    	_mobile_survey_list.CU_ID = '0';
    }
	
	if (mobile_comm_getQueryString('mysel') != 'undefined') {
		_mobile_survey_list.MySel = mobile_comm_getQueryString('mysel');
    } else {
    	if(window.sessionStorage.getItem("mobileSurveymySel") != undefined && window.sessionStorage.getItem("mobileSurveymySel") != "") {
			_mobile_survey_list.MySel = window.sessionStorage.getItem("mobileSurveymySel");
		} else {
			_mobile_survey_list.MySel = 'written';
		}
    }
	
	_mobile_survey_list.TotalCount = -1;
	_mobile_survey_list.RecentCount = 0;
	_mobile_survey_list.EndOfList = false;
	

	//뒤로가기로 왔을 경우 파라미터 처리
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
			
			if(prev.indexOf("/preview.do") > -1 || prev.indexOf("/result.do") > -1 || prev.indexOf("/survey.do") > -1) {
				(mobile_comm_getQueryStringForUrl(prev, 'stype') != "undefined") ? _mobile_survey_list.SurveyType = mobile_comm_getQueryStringForUrl(prev, 'stype'):"";
				(mobile_comm_getQueryStringForUrl(prev, 'mysel') != "undefined") ? _mobile_survey_list.MySel = mobile_comm_getQueryStringForUrl(prev, 'mysel'):"";
				
				_mobile_survey_list.OnBack = true;
				
				if(parseInt(window.sessionStorage["mobile_history_index"]) < arrHistoryData.length) {
					arrHistoryData = arrHistoryData.splice(0, parseInt(window.sessionStorage["mobile_history_index"]));
					window.sessionStorage["mobile_history_data"] = JSON.stringify(arrHistoryData);
				}
			}
		}
	} catch(e) {mobile_comm_log(e);
	}
	
	
	// 2. 상단메뉴
	// 좌측메뉴 표시 (기본 게시&커스텀메뉴 모두 동일하고 트리만 다름)
	if(_mobile_survey_list.CU_ID == '0'){
		$("#survey_list_topmenu").html(mobile_survey_getTopMenuHtml(SurveyMenu));	//BoardMenu - 서버에서 넘겨주는 좌측메뉴 목록
	} else {
		$("#survey_list_topmenu").html(mobile_community_makeHomeTreeList(_mobile_survey_list));
		$("#survey_list_topmenu").removeClass();
		$("#survey_list_topmenu").addClass("h_tree_menu_wrap");
		$("#survey_list_topmenu").addClass("comm_menu");
	}
	
	// 3. 글 목록 조회
	//설문 목록 가져오기
	mobile_survey_getList(_mobile_survey_list);
}

//설문 리스트 조회
function mobile_survey_getList(params)
{
	mobile_comm_TopMenuClick('survey_list_topmenu',true);
	
	$("#survey_list_topmenu li a").removeClass("selected");
	
	if(_mobile_survey_list.SurveyType == "mySurvey"){
		$("#survey_list_topmenu li[mysel=" + _mobile_survey_list.MySel + "] a").addClass("selected");		
	}else{
		$("#survey_list_topmenu li[surveytype=" + _mobile_survey_list.SurveyType + "] a").addClass("selected");
	}	
	
	var paramdata = {
		pageSize: params.PageSize,
		pageNo: params.Page,
		sortBy : 'RegistDate DESC',
		reqType: params.SurveyType,
		schContentType: params.SearchType,
		schMySel: params.MySel,
		schTxt: params.SearchText,
		communityId: params.CU_ID,
		notReadFg: ''
	};
	var url = "/groupware/mobile/survey/getSurveyList.do";
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		async: false,
		success: function (response) {
			if(response.status == "SUCCESS") {
				
				_mobile_survey_list.TotalCount = response.page.listCount;
				var sHtml = "";
				sHtml = mobile_survey_getListHtml(response.list);
	
				if(params.Page == 1 || sHtml.indexOf("no_list") > -1) {
					$('#survey_list_list').html(sHtml);
				} else {
					$('#survey_list_list').append(sHtml);
				}
				
				if (Math.min((_mobile_survey_list.Page) * _mobile_survey_list.PageSize, _mobile_survey_list.TotalCount) == _mobile_survey_list.TotalCount) {
					_mobile_survey_list.EndOfList = true;
	                $('#survey_list_more').hide();
	            } else {
	                $('#survey_list_more').show();
	            }
			}
		}
	});
	
	// 메뉴명 셋팅
	if(params.CU_ID == "0"){
		mobile_survey_getTopMenuName();
	} else {
		$("#community_home_myCommunitySel").parent().parent().parent("div.g_list").show();
		mobile_community_makeMyCommunitySelect(params);
		$("#community_home_myCommunitySel").attr("disabled", "disabled");
		mobile_survey_getTopMenuName();
	}
}

//설문 리스트 Html로 조회
function mobile_survey_getListHtml(surveylist) {
	var sHtml = "";
	
	var sUrl = "";
	
	var sImportance = ""; //긴급여부
	var sIsJoin = ""; //참여여부
	var sState = ""; //상태
	
	if(surveylist.length > 0) {
		$(surveylist).each(function (i, survey){
			if(_mobile_survey_list.SurveyType == "mySurvey" && _mobile_survey_list.MySel == "written") {
				switch(survey.State){
				case 'B': //검토 대기
				case 'C': //승인 대기
				case 'D': //검토 거부
				case 'X': //승인거부
					sUrl = "/groupware/mobile/survey/preview.do?";
					break;
				case 'F': //진행 중
					if(survey.IsTargetRespondent == "Y") {
						if(survey.joinFg == "Y") {
							sUrl = "/groupware/mobile/survey/result.do?";
						} else if(survey.joinFg != "Y") {
							sUrl = "/groupware/mobile/survey/survey.do?";
						}
					} else {
						sUrl = "/groupware/mobile/survey/result.do?";
					}
					break;
				case 'G': //완료
					sUrl = "/groupware/mobile/survey/result.do?";
					break;
				}
				sUrl += "surveyid=" + survey.SurveyID;
			} else if((_mobile_survey_list.SurveyType == "mySurvey" && _mobile_survey_list.MySel == "participated")
					|| _mobile_survey_list.SurveyType == "complete") {
				//updateSurveyRead(surveyId);	// 읽음 업데이트
				sUrl = "/groupware/mobile/survey/result.do?";
				sUrl += "surveyid=" + survey.SurveyID;
			} else if(_mobile_survey_list.SurveyType == "proceed") {
				//TODO : updateSurveyRead(surveyId);
				if(survey.IsTargetRespondent == "Y") {
					if(survey.joinFg == "Y") {
						sUrl = "/groupware/mobile/survey/result.do?";
					} else if(survey.joinFg != "Y") {
						sUrl = "/groupware/mobile/survey/survey.do?";
					}
				} else {
					sUrl = "/groupware/mobile/survey/result.do?";
				}
				sUrl += "surveyid=" + survey.SurveyID;
			} else if(_mobile_survey_list.SurveyType == "reqApproval") {
				sUrl = "/groupware/mobile/survey/preview.do?";
				sUrl += "surveyid=" + survey.SurveyID;
			}
			sUrl +="&stype=" + _mobile_survey_list.SurveyType;
			sUrl +="&mysel=" + _mobile_survey_list.MySel;
			sUrl +="&mysel=" + _mobile_survey_list.MySel;
			
			if(_mobile_survey_list.SurveyType == "mySurvey"){ //진행 상태를 알려줌
				sState = "<span class=\"join\">" + mobile_survey_getStateName(survey.State) + "</span>";
			}
			else { //참여대상인 경우, 참여/미참여 여부를 알려줌
				if(survey.IsTargetRespondent == "Y"){
					if(survey.joinFg == "Y") {
						sIsJoin = "<span class=\"join\">" + mobile_comm_getDic("lbl_survey_participation") + "</span>"; //참여
					} else if(survey.joinFg != "Y") {
						sIsJoin = "<span class=\"not_join\">" + mobile_comm_getDic("lbl_Nonparticipation") + "</span>"; //미참여
					}
				}
			}

			sImportance = "";
			if(survey.IsImportance == "Y")
			{
				sImportance = "<span class=\"flag_cr01\">" + mobile_comm_getDic("lbl_surveyUrgency") + "</span>"; //긴급
			}
			
			if(_mobile_survey_list.SurveyType == "mySurvey")
			{
				sHtml += "<li>";
				sHtml += "    <a href=\"javascript: mobile_comm_go('" + sUrl + "','Y');\" class=\"con_link\">";	//TODO: 메시지보기로 이동
				sHtml += "			<div class=\"txt_area\">";
				sHtml += "				<p class=\"title\">" + sImportance + survey.Subject + "</p>";
				sHtml += "				<p class=\"list_info\" style='width: 100%;'>";
				sHtml += 					sState;
				sHtml += "					<span class=\"date\">" + survey.SurveyStartDate + "~ " + survey.SurveyEndDate + "</span>";
				sHtml += "					<span class=\"name\">" + survey.RegisterName.split(";")[0] + "</span>"; //TODO : 이름 다국어 처리 및 직급 표시
				sHtml += "				</p>";
				sHtml += "			</div>";
				sHtml += "		</a>";
				sHtml += "</li>";
			}
			else if(_mobile_survey_list.SurveyType != "reqApproval")
			{
				var rate = Math.ceil(survey.joinRate);
				
				sHtml += "<li>";
				sHtml += "    <a href=\"javascript: mobile_comm_go('" + sUrl + "','Y');\" class=\"con_link\">";	//TODO: 메시지보기로 이동
				sHtml += "			<div class=\"txt_area\">";
				sHtml += "				<p class=\"title\">" + sImportance + survey.Subject + "</p>";
				sHtml += "				<p class=\"list_info\">";
				sHtml += 					sIsJoin;
				sHtml += "					<span class=\"date\">" + CFN_TransLocalTime(survey.SurveyStartDate,'yyyy.MM.dd') + "~ " + CFN_TransLocalTime(survey.SurveyEndDate,'yyyy.MM.dd') + "</span>";
				sHtml += "					<span class=\"name\">" + survey.RegisterName.split(";")[0] + "</span>"; //TODO : 이름 다국어 처리 및 직급 표시
				sHtml += "				</p>";
				sHtml += "			</div>";
				sHtml += "			<div class=\"list_graph\">";
				sHtml += "				<span class=\"graph_wrap\"><span class=\"graph_bar\" style=\"width:" + rate + "%;\"></span></span>";		
				sHtml += "				<span class=\"graph_txt\">" + rate + "%</span>";
				sHtml += "			</div>";
				sHtml += "		</a>";
				sHtml += "</li>";
			}
			else
			{
				sHtml += "<li>";
				sHtml += "    <a href=\"javascript: mobile_comm_go('" + sUrl + "','Y');\" class=\"con_link\">";	//TODO: 메시지보기로 이동
				sHtml += "			<div class=\"txt_area\">";
				sHtml += "				<p class=\"title\">" + sImportance + survey.Subject + "</p>";
				sHtml += "				<p class=\"list_info\" style='width: 100%;'>";
				sHtml += "					<span class=\"name\">" + survey.RegisterName.split(";")[0] + "</span>"; //TODO : 이름 다국어 처리 및 직급 표시
				sHtml += "					<span class=\"date\">" + CFN_TransLocalTime(survey.SurveyStartDate,'yyyy.MM.dd') + " ~ " + CFN_TransLocalTime(survey.SurveyEndDate,'yyyy.MM.dd') + "</span>";	
				sHtml += "				</p>";
				sHtml += "			</div>";
				sHtml += "		</a>";
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

//설문 상태 다국어 처리
function mobile_survey_getStateName(state){
		// 설문상태(A:작성중, B:검토대기, D:검토거부, C:승인대기, X:승인거부, F:진행중, G:설문종료)
		var name = '';  
		
		switch(state){
		case 'A':
			name = mobile_comm_getDic('lbl_SurveyWriting');
			break;
		case 'B':
			name = mobile_comm_getDic('lbl_review1');
			break;
		case 'C':
			name = mobile_comm_getDic('lbl_adstandby');
			break;
		case 'D':
			name = mobile_comm_getDic('lbl_ReviewRejected');
			break;
		case 'F':
			name = mobile_comm_getDic('lbl_Progressing');
			break;
		case 'G':
			name = mobile_comm_getDic('lbl_SurveyEnd');
			break;
		case 'X':
			name = mobile_comm_getDic('lbl_ApprovalDeny');
			break;
		}
		
		return name; 
	}

//더보기 클릭
function mobile_survey_nextlist () {
	if (!_mobile_survey_list.EndOfList) {
		_mobile_survey_list.Page++;

		mobile_survey_getList(_mobile_survey_list);
    } else {
        $('#survey_list_more').css('display', 'none');
    }
}

//스크롤 더보기
function mobile_survey_list_page_ListAddMore() {
	mobile_survey_nextlist();
}

//검색 클릭
function mobile_survey_clicksearch() {
	_mobile_survey_list.SearchText = $('#mobile_search_input').val();
	window.sessionStorage.setItem("mobileSurveySearchText", $('#mobile_search_input').val());
	mobile_survey_getList(_mobile_survey_list);
}

//새로고침 클릭
function mobile_survey_clickrefresh() {
	_mobile_survey_list.SearchText = '';
	_mobile_survey_list.Page = 1;
	$('#mobile_search_input').val('');
	
	mobile_survey_getList(_mobile_survey_list);
}

//확장메뉴 show or hide
function mobile_survey_showORhide(obj) {
	if($(obj).parent().hasClass("show")) {
		$(obj).parent().removeClass("show");
	} else {
		$(obj).parent().addClass("show");
	}
}

//설문 - 목록 끝










/*!
 * 
 * 설문 상세보기
 * 
 */

var _mobile_survey_view = {
	// 리스트 조회 초기 데이터
	ReqType: 'join',		//설문 보기 타입 - join(설문참여), preview(미리보기), result(결과보기)
	HtmlTarget: 'view',			//html 적용 부분 구분자 - view(설문참여), preview(미리보기), result(결과보기)
		
	SurveyID: '',				//설문ID
	SurveyInfo : '',			//설문 정보
	
	QuestionNo : 0,		//현재 문제 번호
	GroupingNo : 0,		//그룹 번호
	PrevNo : 0,				//이전 문제 번호
	NextNo : 99,			//다음 문제 번호
	
	QuestionSortArr : new Array(),	//이동 내역 정보 저장
	AnswerArr : new Array()			//답변 정보 저장
};

function mobile_survey_ViewInit(){	
	// 1. 파라미터 셋팅
	_mobile_survey_view.ReqType = 'join';
	_mobile_survey_view.HtmlTarget = 'view';
	if (mobile_comm_getQueryString('surveyid', 'survey_view_page') != 'undefined') {
		_mobile_survey_view.SurveyID = mobile_comm_getQueryString('surveyid', 'survey_view_page');
	} else {
		_mobile_survey_view.SurveyID = '';
	}
	
	//답변/이동내역 정보  초기화
	_mobile_survey_view.AnswerArr = new Array();
	_mobile_survey_view.QuestionSortArr = new Array();
	
	mobile_survey_getView(_mobile_survey_view);
}

//설문 정보 가져오기
function mobile_survey_getView(params) {
	var paramdata = {
		surveyId: params.SurveyID
	};
	
	var url = "/groupware/mobile/survey/getSurveyData.do";
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		async: false,
		success: function (response) {			
			if(response.status == "SUCCESS") {
				_mobile_survey_view.SurveyInfo = $.extend(true, {}, response.data);
				
				//설문 정보 설정
				mobile_survey_setSurveyInfo();
				
				//제목
				mobile_survey_view_getTitleHtml();
				
				//첨부 추가
				$('#survey_' + _mobile_survey_view.HtmlTarget + '_attach').html(mobile_comm_downloadhtml(response.fileList, "Survey"));
				var surveyAttach = $('#survey_' + _mobile_survey_view.HtmlTarget + '_attach');
				if(response.fileList.length != 0){
					surveyAttach.css('padding-bottom','15px');
				}else{
					surveyAttach.css('display','none');
				}
				
				if(_mobile_survey_view.ReqType == "preview"){
					//preview 의 경우, prev/next 버튼의 위치가 상단에 있으며 페이지 표기가 필요함
					var sPreviewBtn = "<span class='pg'>1</span>";
					sPreviewBtn += "/";
					sPreviewBtn += mobile_survey_getPageCnt(_mobile_survey_view.SurveyInfo.isGrouping, _mobile_survey_view.SurveyInfo.questions);
					$("#survey_view_preview_pageCnt").html(sPreviewBtn);		
					
					//승인 거부 버튼 처리
					$("#survey_view_preview_approvebtn").attr("href", "javascript: mobile_survey_updateSurveyState('" + _mobile_survey_view.SurveyInfo.state + "', 'accept', '" + _mobile_survey_view.SurveyID + "')");
					$("#survey_view_preview_cancelbtn").attr("href", "javascript: mobile_survey_updateSurveyState('" + _mobile_survey_view.SurveyInfo.state + "', 'refuse', '" + _mobile_survey_view.SurveyID + "')");
				} else {
					$("div.utill").show(); //설문대상, 결과공개대상 조회 버튼 표시 
				}
				
				//질문 데이터 세팅
				mobile_survey_view_getQuestionData("init");
				
			}
		}
	});
}

//설문  상세 페이지 title 설정
function mobile_survey_view_getTitleHtml()
{
	var sTitleHtml = ""; //설문 제목
	var sPeriodHtml = ""; //설문 기간
	
	if(_mobile_survey_view.SurveyInfo.isImportance == "Y") //설문 긴급여부
	{
		sTitleHtml += "<span class=\"flag_cr01\">" + mobile_comm_getDic("lbl_surveyUrgency") + "</span>"; //긴급
	}
	sTitleHtml += _mobile_survey_view.SurveyInfo.subjectHtml;

	sPeriodHtml += "<span>" + CFN_TransLocalTime(_mobile_survey_view.SurveyInfo.surveyStartDate,'yyyy.MM.dd') + "</span>";
	sPeriodHtml += "~";
	sPeriodHtml += "<span>" + CFN_TransLocalTime(_mobile_survey_view.SurveyInfo.surveyEndDate,'yyyy.MM.dd') + "</span>";
	
	$('#survey_' + _mobile_survey_view.HtmlTarget + '_title').html(sTitleHtml);
	$('#survey_' + _mobile_survey_view.HtmlTarget + '_period').html(sPeriodHtml);
	$('#survey_' + _mobile_survey_view.HtmlTarget + '_description').html(_mobile_survey_view.SurveyInfo.description);
	setTimeout(function () {
		mobile_comm_replacebodyinlineimg($('#survey_' + _mobile_survey_view.HtmlTarget + '_description'));
		mobile_comm_replacebodylink($('#survey_' + _mobile_survey_view.HtmlTarget + '_description'));
	}, 100);
}

//설문 설정 show or hide
function mobile_survey_showContSetting(){
	var mParent = $(".survey_title");
	if($(mParent).hasClass("hide")) {
		$(mParent).removeClass("hide");
	} else {
		$(mParent).addClass("hide");
	}
}

//상단메뉴(PC 좌측메뉴) 그리기
function mobile_survey_getTopMenuHtml(surveymenu) {
	
	var sHtml = "";
	var sALink = "";
	var surveyType = "";

	sHtml += "<ul class=\"h_tree_menu_wrap\">";
	$(surveymenu).each(function (i, data){				
		surveyType = mobile_comm_getQueryStringForUrl(data.URL, 'reqType');
		if(surveyType == "tempSave") {
			return true;
		} else if(surveyType == "mySurvey"){
			sALink = "javascript: mobile_survey_ChangeFolder('" + surveyType + "', ";
			
			sHtml += "<li surveytype=\"" + surveyType + "\">";
			sHtml += "    <div class=\"h_tree_menu\">";
			sHtml += "    	<a href=\"javascript: mobile_survey_openclose('li_sub_mySel', 'span_menu_mySel');\" class=\"t_link not_tree\">";//TODO: 링크 처리
			sHtml += "        	<span id='span_menu_mySel' class=\"t_ico_open\"></span>";
			sHtml += "        	<span class=\"t_ico_my\"></span>";//TODO: 클래스 처리
			sHtml += 				data.DisplayName;
			sHtml += "    	</a>";
			sHtml += "		<ul class=\"sub_list\" id=\"li_sub_mySel\">";
			sHtml += "			<li surveytype=\"" + surveyType + "\" displayname=\"" + mobile_comm_getDic("lbl_CompletedQuestionnaire") + "\" mysel=\"written\">"; //내가 작성한 설문
			sHtml += "      	  	<a href=\"" + sALink + "'written');" + "\" class=\"t_link\">";
			sHtml += "					<span class=\"t_ico_board\"></span>";
			sHtml +=						mobile_comm_getDic("lbl_CompletedQuestionnaire"); //내가 작성한 설문
			sHtml += "				</a>";
			sHtml += "    		</li>";
			sHtml += "			<li surveytype=\"" + surveyType + "\" displayname=\"" + mobile_comm_getDic("lbl_SurveyedParty") + "\" mysel=\"participated\">"; //내가 참여한 설문
			sHtml += "      	  	<a href=\"" + sALink + "'participated');" + "\" class=\"t_link\">";
			sHtml += "					<span class=\"t_ico_board\"></span>";
			sHtml +=						mobile_comm_getDic("lbl_SurveyedParty"); //내가 참여한 설문
			sHtml += "				</a>";
			sHtml += "    		</li>";
			sHtml += "		</ul>";
			sHtml += "    </div>";
			sHtml += "</li>";
			
		} else {
			sALink = "javascript: mobile_survey_ChangeFolder('" + surveyType + "');";
			
			sHtml += "<li surveytype=\"" + surveyType + "\" displayname=\"" + data.DisplayName + "\">";
			sHtml += "    <div class=\"h_tree_menu\">";
			sHtml += "    	<a href=\"" + sALink + "\" class=\"t_link not_tree\">";//TODO: 링크 처리
			
			if(surveyType == "reqApproval") {
			sHtml += "        	<span class=\"t_ico_app\"></span>";//TODO: 클래스 처리
			} else {
				sHtml += "        	<span class=\"t_ico_with\"></span>";//TODO: 클래스 처리
			}
			
			sHtml += 			data.DisplayName;			
			sHtml += "    	</a>";
			sHtml += "    </div>";
			sHtml += "</li>";
		}
	});
	sHtml += "</ul>";
	
	return sHtml;
}

//하위 메뉴/트리 열고 닫기
function mobile_survey_openclose(liId, iconId) {
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

//상단 메뉴명 셋팅
function mobile_survey_getTopMenuName() {
	
	var sTopMenu = $('#survey_list_topmenu').find("li:eq(0)").text();
	$('#survey_list_topmenu').find("li[displayname]").each(function (){
		
		if($(this).attr('surveytype') == _mobile_survey_list.SurveyType) {
			if(_mobile_survey_list.SurveyType == "mySurvey"){
				if($(this).attr('mysel') == _mobile_survey_list.MySel) {
					sTopMenu = $(this).attr('displayname');
					return false;
				} else {
					return true;
				}
			} else {
				sTopMenu = $(this).attr('displayname');
				return false;
			}
		}
	});
	
	$('#survey_list_title').html("<span class=\"Tit\">"+ sTopMenu + "</span>");
}

//설문 게시판 변경
function mobile_survey_ChangeFolder(surveyType, mySel) {
	
	if(surveyType == undefined || surveyType == 'undefined' || surveyType == '') {
		surveyType = "proceed";
	}
	if(mySel == undefined || mySel == 'undefined' || mySel == '') {
		mySel = "written";
	}
	
	window.sessionStorage.setItem("mobileSurveyType", surveyType);
	window.sessionStorage.setItem("mobileSurveymySel", mySel);
	window.sessionStorage.setItem("mobileSurveySearchText", "");
	
	_mobile_survey_list.SurveyType = surveyType;
	_mobile_survey_list.SearchText = '';
	_mobile_survey_list.Page = 1;
	_mobile_survey_list.EndOfList = false;
	_mobile_survey_list.MySel = mySel;
	
	$('#mobile_search_input').val('');
	
	mobile_survey_getList(_mobile_survey_list);
}

//설문 정보 세팅
function mobile_survey_setSurveyInfo() {
	var answerObj = null;
	var sQuestions = _mobile_survey_view.SurveyInfo.questions; //문항 개수
	
	$.each(sQuestions, function(i, v) {
		answerObj = new Object();
		answerObj.surveyID = _mobile_survey_view.SurveyID;
		answerObj.questionID = v.questionID;
		answerObj.questionNO = v.questionNO;
		answerObj.questionNO = v.questionNO;
		answerObj.groupingNo = v.groupingNo;
		answerObj.itemID = "";
		answerObj.answerItem = "";
		answerObj.etcOpinion = "";
		answerObj.weighting = "";
		
		_mobile_survey_view.AnswerArr.push(answerObj);
	}); 
}

//페이지 개수 구하기
function mobile_survey_getPageCnt(isGrouping, surveyArr){
	if(isGrouping == "Y"){
		var groupArr = new Array();
		$.each(surveyArr, function(i,v){
	           groupArr.push(v.groupingNo);
		});
		var tempArr = [];
		$.each(groupArr, function(i,v){
	           if ($.inArray(v, tempArr) == -1) tempArr.push(v);
		});
		return tempArr.length;
	}
	else{
		return surveyArr.length;
	}
}

//질문 데이터 가져오기 및 페이지 이동 처리
function mobile_survey_view_getQuestionData(type) {	
	if(!mobile_survey_view_checkRequired()){ // 필수 체크
		return ;
	}
	if(!mobile_survey_validation_Check()){
		alert(mobile_comm_getDic("msg_survey_errorRanking")); // 입력하신 순위를 다시 확인 해 주시기 바랍니다.
		return
	}
	
	var sIsGrouping = _mobile_survey_view.SurveyInfo.isGrouping; //그룹핑 여부
	var sQuestions = _mobile_survey_view.SurveyInfo.questions; //문항 개수
	var sTempQuestion = null;
	
	var idx;
	// 그룹 분기
/*	if (sIsGrouping == "Y") {
		if (type == "init") {
			$("#survey_view_preview_pageCnt span").text(1);

			_mobile_survey_view.GroupingNo = 1;
			
			sTempQuestion = new Array();
    		$.each(sQuestions, function(i, v) {
	    		if (1 == v.groupingNo) {
	    			sTempQuestion.push(v);
	    			_mobile_survey_view.QuestionSortArr.push(v);
	    		}
   			});
    		
    		_mobile_survey_view.PrevNo = -1;
    		_mobile_survey_view.NextNo = sTempQuestion[0].nextGroupingNo;
    		
    		mobile_survey_view_getContentHtml(sTempQuestion);
    		mobile_survey_view_getQuestionHtml(sTempQuestion);
		}
		else if(type == "prev")	{
			mobile_survey_view_setAnswer();
			
			if(_mobile_survey_view.PrevNo != -1 && _mobile_survey_view.GroupingNo > 1) {
				$("#survey_view_preview_pageCnt span").text(Number($("#survey_view_preview_pageCnt span").text()) -1);
				
				_mobile_survey_view.GroupingNo = _mobile_survey_view.PrevNo;
				
				sTempQuestion = new Array();
	    		$.each(sQuestions, function(i, v) {
		    		if (_mobile_survey_view.GroupingNo == v.groupingNo) {
		    			sTempQuestion.push(v);
		    		}
	   			});
	    		
	    		idx = mobile_survey_chkPrevExist(_mobile_survey_view.QuestionSortArr, sTempQuestion[0]);
	    		if(idx != -1){
	    			_mobile_survey_view.QuestionSortArr.splice(++idx, 1);
	    		}
	    		
	    		_mobile_survey_view.PrevNo = idx;
	    		_mobile_survey_view.NextNo = sTempQuestion[0].nextGroupingNo;
	    		
	    		mobile_survey_view_getContentHtml(sTempQuestion);
	    		mobile_survey_view_getQuestionHtml(sTempQuestion);
			}
			else
			{
				alert(mobile_comm_getDic("msg_survey_noexistPrevious")); //이전 문항이 없습니다.
			}
		}
		else if(type == "next")
		{
			mobile_survey_view_setAnswer();
				
			if(_mobile_survey_view.NextNo != 99) {
				_mobile_survey_view.PrevNo = _mobile_survey_view.GroupingNo;
				
				_mobile_survey_view.GroupingNo = _mobile_survey_view.NextNo;
				
				$("#survey_view_preview_pageCnt span").text(Number($("#survey_view_preview_pageCnt span").text()) +1);
				
				sTempQuestion = new Array();
	    		$.each(sQuestions, function(i, v) {
		    		if (_mobile_survey_view.GroupingNo == v.groupingNo) {
		    			sTempQuestion.push(v);
		    			_mobile_survey_view.QuestionSortArr.push(v);
		    		}
	   			});
	    		
	    		_mobile_survey_view.NextNo = sTempQuestion[0].nextGroupingNo;
	    		
	    		mobile_survey_view_getContentHtml(sTempQuestion);
	    		mobile_survey_view_getQuestionHtml(sTempQuestion);
			}
			else
			{
				alert(mobile_comm_getDic("msg_survey_noexistNext")); //다음 문항이 없습니다.
			}
		}
	}
	else
	{*/
		if (type == "init") {
			$("#survey_view_preview_pageCnt span").text(1);
			
			_mobile_survey_view.QuestionNo = 1;
			
			sTempQuestion = new Array();
			sTempQuestion.push(sQuestions[0]);
			
			_mobile_survey_view.QuestionSortArr.push(sQuestions[0]);
			
			_mobile_survey_view.PrevNo = -1;
    		_mobile_survey_view.NextNo = sTempQuestion[0].nextDefaultQuestionNO;
			
    		mobile_survey_view_getContentHtml(sTempQuestion);
    		mobile_survey_view_getQuestionHtml(sTempQuestion);
		}
		else if(type == "prev")
		{
			mobile_survey_view_setAnswer();
			
			if(_mobile_survey_view.PrevNo != -1 && _mobile_survey_view.QuestionNo > 1) {
				$("#survey_view_preview_pageCnt span").text(Number($("#survey_view_preview_pageCnt span").text()) -1);
				
				_mobile_survey_view.QuestionNo = _mobile_survey_view.PrevNo;
				
				sTempQuestion = new Array();
	    		$.each(sQuestions, function(i, v) {
		    		if (_mobile_survey_view.QuestionNo == v.questionNO) {
		    			sTempQuestion.push(v);
		    		}
	   			});
	    		
	    		idx = mobile_survey_chkPrevExist(_mobile_survey_view.QuestionSortArr, sTempQuestion[0]);
	    		
	    		_mobile_survey_view.PrevNo = idx;
	    		_mobile_survey_view.NextNo = sTempQuestion[0].nextDefaultQuestionNO;
	    		
	    		if(idx != -1){
	    			_mobile_survey_view.QuestionSortArr.splice((idx + 1), 1);
	    		}
	    		
	    		mobile_survey_view_getContentHtml(sTempQuestion);
	    		mobile_survey_view_getQuestionHtml(sTempQuestion);
			}
			else
			{
				alert(mobile_comm_getDic("msg_survey_noexistPrevious")); //이전 문항이 없습니다.
			}
		}
		else if(type == "next")
		{
			mobile_survey_view_setAnswer();
			
			if(_mobile_survey_view.NextNo != 99) {
				
				_mobile_survey_view.PrevNo = _mobile_survey_view.QuestionNo;
				_mobile_survey_view.QuestionNo = _mobile_survey_view.NextNo;
				
				var curQInfo = _mobile_survey_view.SurveyInfo.questions[parseInt(_mobile_survey_view.QuestionNo)-1];
				if (curQInfo.questionType == 'S') {	// 객관식
					var checked = $('.survey_wrap input[type=radio]:checked').eq(0).val();
					if (checked != undefined) {
						_mobile_survey_view.QuestionNo = $('.survey_wrap input[type=radio]:checked').parent().siblings('input[type=hidden]:eq(1)').val();
					}
				}
				
				$("#survey_view_preview_pageCnt span").text(Number($("#survey_view_preview_pageCnt span").text()) +1);
				sTempQuestion = new Array();
				$.each(sQuestions, function(i, v) {
					if (_mobile_survey_view.QuestionNo == v.questionNO) {
						sTempQuestion.push(v);
						_mobile_survey_view.QuestionSortArr.push(v);
					}
				});
				
				_mobile_survey_view.NextNo = sTempQuestion[0].nextDefaultQuestionNO;
			
				mobile_survey_view_getContentHtml(sTempQuestion);
				mobile_survey_view_getQuestionHtml(sTempQuestion);
			}
			else
			{
				alert(mobile_comm_getDic("msg_survey_noexistNext")); //다음 문항이 없습니다.
			}
		}
	//}
}

//설문 본문 Html
function mobile_survey_view_getContentHtml(surveyInfo) {	
	var sContentHtml = "";
	var sRequiredHtml = "";
	var sIsGrouping = _mobile_survey_view.SurveyInfo.isGrouping; //그룹핑 여부

	if(surveyInfo.length > 0)
	{
		if(sIsGrouping == "Y")
		{
			sContentHtml += "<div class=\"survey_wrap group type6\">";
			sContentHtml += 	"<h3 class=\"g_tit\">" + surveyInfo[0].groupName + "</h3>";
		}
		
		$.each(surveyInfo, function(i, q) {
			
			sRequiredHtml = "";
			if(q.isRequired == "Y")
			{
				sRequiredHtml += "<span class=\"hd\">[" + mobile_comm_getDic("lbl_Require") + "]</span>"; //필수
			}
	
			sContentHtml += "<div class=\"survey_wrap\" id=\"survey_question" + (Number(i) + 1) + "\">";
			sContentHtml += "	<input type='hidden' value=" + q.questionID + ">";
			sContentHtml += "	<input type='hidden' value='" + q.questionType + "'>";
			sContentHtml += "	<input type='hidden' value='" + q.isEtc + "'>";
			sContentHtml += "	<input type='hidden' value='" + q.isRequired + "'>"; 
			
			sContentHtml += "	<h4 class=\"tit\">";
			sContentHtml += "		<span class=\"num\">" + q.questionNO + "</span>";
			sContentHtml += "		<span class=\"tit_tx\">";
			sContentHtml += 			sRequiredHtml;
			sContentHtml += 			q.question;
			sContentHtml += "		</span>";
			sContentHtml += "	</h4>";
			sContentHtml += "</div>";
		});
		
		sContentHtml += "<div class=\"survey_btn align\">";		
		if(_mobile_survey_view.ReqType == "join"){
			sContentHtml += 	"	<a href=\"javascript: mobile_survey_view_getQuestionData('prev');\" class=\"prev\"><span class=\"tx\">" + mobile_comm_getDic("lbl_previous") + "</span></a>"; //이전	
			if(_mobile_survey_view.NextNo == 99){
				sContentHtml += "	<a href=\"javascript: mobile_survey_view_submitSurvey();\" class=\"next\"><span class=\"tx\">" + mobile_comm_getDic("lbl_Completed") + "</span></a>"; //완료
			}
			else{
				sContentHtml += "	<a href=\"javascript: mobile_survey_view_getQuestionData('next');\" class=\"next\"><span class=\"tx\">" + mobile_comm_getDic("lbl_next") + "</span></a>"; //다음
			}
		}
		sContentHtml += "</div>";
		
		if(sIsGrouping == "Y")
		{
			sContentHtml += "</div>";
		}
	}
	$('#survey_' + _mobile_survey_view.HtmlTarget + '_body').html(sContentHtml);
}

//이미지 조회
function mobile_survey_view_getImg(item) {
	
	var sImgHtml = "";
	
	var fileIds;
	if(item.updateFileIds != "" && item.updateFileIds != undefined){	 // back 이미지
		fileIds = item.updateFileIds.split(';');
		$.each(fileIds, function(i, v) {
			var src = "/covicore/common/view/Survey/" + v + ".do";
			sImgHtml += "<span class='survey_img'>";
			sImgHtml += "	<img src='" + src + "' alt='' style='width:106px;height:104px;' >";
			sImgHtml += "</span>";
		});
	}
	if(item.fileIds != "" && item.fileIds != undefined){	 // front 이미지
		fileIds = item.fileIds.split(',');
		$.each(fileIds, function(i, v) {
			var src = "/covicore/common/preview/Survey/" + v + ".do"; //TODO: 경로
			sImgHtml += "<span class='survey_img'>";
			sImgHtml += "	<img src='" + src + "' alt='' style='width:106px;height:104px;' >";
			sImgHtml += "</span>";
			//TODO : 미리보기
				/*if (reqType == 'preview') {
					fileIds = JSON.parse(v.fileIds);
				$.each(fileIds, function(i, v) {
					var src = coviCmn.commonVariables.frontPath + v.SavedName;
					var thumbSrc = src.split('.')[0] + '_thumb.jpg';
					
					html += "<div class='chkPhotoView'>";
					html += "<img src=\"" + thumbSrc + "\" alt='' orgSrc=\"" + src + "\" style='width:106px;height:104px;' >";
					html += "</div>";
				});
				} else {
				fileIds = v.fileIds.split(',');
				$.each(fileIds, function(i, v) {
					html += "<div class='chkPhotoView'>";
					html += "<img src=\"/covicore/common/preview/Survey/" + v + ".do\" alt='' style='width:106px;height:104px;'>";
					html += "</div>";
				});
				}*/
		});
	}
	
	return sImgHtml;
}

//문항별 html 처리
function mobile_survey_view_getQuestionHtml(surveyInfo) {
	var sQuestionHtml = "";
	var sChecked = "";
	var sIsEtc = ""; 					//기타
	var sEtcOpinion = mobile_comm_getDic("lbl_Etc"); 	//기타 의견 글
	var sAnswerItem = ''; 			//기존 답변 세팅 - 답
	var sQuestionItem = ''; 		//기존 답변 세팅 - 문제 번호
	var sParagraph = "";				//지문 표시용
	
	var sAnswerItemArr;
	
	if(surveyInfo.length > 0)
	{
		$.each(surveyInfo, function(i, q) {
			$.each(_mobile_survey_view.AnswerArr, function(i, v) {
				if (q.groupingNo == v.groupingNo && q.questionNO == v.questionNO) {
					if (q.questionType == 'N') {
						sAnswerItem = v.weighting;
						sQuestionItem = v.itemID;
					} else if(q.questionType == 'S' || q.questionType=='M'){
						sAnswerItem = v.itemID;
						sEtcOpinion = v.etcOpinion=='' ? mobile_comm_getDic("lbl_Etc") : v.etcOpinion;
					} else if(q.questionType == 'D'){
						sAnswerItem = v.answerItem;
					}
						
					return false;
				}
			});
			
			sQuestionHtml = "";
			sIsEtc = q.isEtc;
			
			//지문
			var hasParagraph = false;
			var hasDescription = false;
			
			if (typeof(q.paragraph) != "undefined" && q.paragraph != "") {
				hasParagraph = true;
			}
			if (typeof(q.description) != "undefined" && q.description != ""){
				hasDescription = true;
			}
			if(hasParagraph || hasDescription){
				sParagraph   = "<p class='tx'>";
				if(hasParagraph){
					sParagraph += "	<b>" + 	q.paragraph + "</b>";	//지문 제목
				}
				if(hasParagraph && hasDescription){
					sParagraph += "	<br />";
				}
				if(hasDescription){
					sParagraph += 	q.description;							//지문 설명
				}
				sParagraph += "</p>";
			}
			$("#survey_question" + (Number(i) + 1)).prepend(sParagraph);
			
			if(q.questionType == "S")
			{
				$("#survey_question" + (Number(i) + 1)).addClass('type4'); //원래 type1이나 이미지 추가시 css 지원이 미흡하여 임의로 변경
			}
			else if(q.questionType == "D")
			{
				$("#survey_question" + (Number(i) + 1)).addClass('type2');
			}
			else if(q.questionType == "M")
			{
				$("#survey_question" + (Number(i) + 1)).addClass('type4'); //원래 type3이나 이미지 추가시 css 지원이 미흡하여 임의로 변경
			}
			else if(q.questionType == "N")
			{
				$("#survey_question" + (Number(i) + 1)).addClass('type5');
			}
			
			if(q.questionType == "D")
			{
				sQuestionHtml += "<div class=\"choice_tx full\">";
			}
			else
			{
				sQuestionHtml += "<div class=\"choice_wrap\">";
			}		
			
			$.each(q.items, function(j, item) {		
				sChecked = "";
				
				if(q.questionType == "S")
				{
					if (sAnswerItem != '' && sAnswerItem != undefined && sAnswerItem == item.itemID) 
					{
						sChecked = "checked";
					}
					
					if (j == (q.items.length -1) && sIsEtc == 'Y')
					{
						sQuestionHtml += "<div class=\"choice_tx\">";
						sQuestionHtml += "		<input type=\"radio\" name=\"survey_question" + (Number(i) + 1) + "_item\" value=\"\" id=\"survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "\"" + sChecked + ">";
						sQuestionHtml += "			<label for=\"survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "\">";
						sQuestionHtml += "			<span class=\"etc\">" + mobile_comm_getDic("lbl_Etc") + "</span>"; //기타
						sQuestionHtml += "			<input type=\"text\" value=\"" + sEtcOpinion + "\" class=\"survey_type1_input\">";
						sQuestionHtml += "		</label>";
						sQuestionHtml += "		<input type='hidden' value='" + item.itemID + "'>";
						sQuestionHtml += "</div>";
					}
					else
					{
						sQuestionHtml += "<div>";
						sQuestionHtml += "<input type=\"radio\" name=\"survey_question" + (Number(i) + 1) + "_item\" value=\"" + item.item + "\" id=\"survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "\" " + sChecked + " onclick=\"javascript:mobile_survey_view_changeRadio(this);\">";
						sQuestionHtml += "<label for=\"survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "\">" + item.item + mobile_survey_view_getImg(item) + "</label>";
						sQuestionHtml += "<input type='hidden' value='" + item.itemID + "'>";
						sQuestionHtml += "<input type='hidden' value='" + item.nextQuestionNO+ "'>";
						sQuestionHtml += "</div>";
					}
				}
				else if(q.questionType == "D")
				{
					sQuestionHtml += "<input type='hidden' value='" + item.itemID + "'>";
					sQuestionHtml += "<input type=\"text\" id=\"survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "\" value=\"" + sAnswerItem + "\" class=\"survey_type2_input\">";
				}
				else if(q.questionType == "M")
				{
					if(sAnswerItem != undefined){
						sAnswerItemArr = sAnswerItem.split(';');
	    			}
					if(typeof sAnswerItemArr == "object" && sAnswerItemArr.length > 0 && sAnswerItemArr.includes(item.itemID)) {
						sChecked = "checked";
					}
					
					sQuestionHtml += "<div>";
					sQuestionHtml += "		<input type=\"checkbox\" name=\"survey_question" + (Number(i) + 1) + "_item\" value=\"\" id=\"survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "\" " + sChecked + ">";
					sQuestionHtml += "		<label for=\"survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "\">" + item.item  + mobile_survey_view_getImg(item) + "</label>";
					sQuestionHtml += "		<input type='hidden' value='" + item.itemID + "'>";
					sQuestionHtml += "</div>";
				}
				else if(q.questionType == "N")
				{
					var tempAnswer = "";
					var sQuestionItemArr;
					if(sAnswerItem != undefined && sAnswerItem !="" && sQuestionItem != undefined){
						sAnswerItemArr = sAnswerItem.split(';');
						sQuestionItemArr = sQuestionItem.split(';');
						
						tempAnswer = sAnswerItemArr[jQuery.inArray( item.itemID, sQuestionItemArr)];
	    			}
					
					var sDDHtml = mobile_survey_view_getImg(item);
					if(sDDHtml != "")
					{
						sDDHtml = "<dd class='thum'>" + sDDHtml + "</dd>";
					}
					
					sQuestionHtml += "<dl class=\"choice_dl\">";
					sQuestionHtml += "		<dt>";
					sQuestionHtml += "			<input type='hidden' value='" + item.itemID + "'>";
					sQuestionHtml += "			<input type=\"text\" value=\"" + tempAnswer + "\" id=\"survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "\" class=\"choice_num_input\">";
					sQuestionHtml += "		</dt>";
					sQuestionHtml += "		<dd>" + item.item + "</dd>";
					sQuestionHtml += 		sDDHtml;
					sQuestionHtml += "</dl>";
				}
			});	
			
			sQuestionHtml += "</div>";
			$("#survey_question" + (Number(i) + 1)).append(sQuestionHtml).trigger("create");
		});		
	}
}

//순서 데이터 포함 여부 확인(없음 : -1, 있음  : 이전 index)
function mobile_survey_chkPrevExist(questions, obj) {
	var rtnIdx = -1;

	$.each(questions, function(i, v) {
		// 그룹 분기
		if (_mobile_survey_view.SurveyInfo.isGrouping == "Y") {
	   		if (obj.groupingNo == v.groupingNo) {
					if (questions[i] != null && typeof(questions[i]) != "undefined") {
						rtnIdx = i;
					}
	   			return false;
	   		}
		} else {
	   		if (obj.questionNO == v.questionNO) {
					if (questions[i] != null && typeof(questions[i]) != "undefined") {
						rtnIdx = i;
					}
	   			return false;
	   		}
		}
	});
   	
	return rtnIdx;
}

function mobile_survey_view_setAnswer()
{	
	$("div.survey_cont").find(".survey_wrap").not(".group").each(function (i, v) {
		var questionDiv = $(this);
		var questionId = questionDiv.find('input[type=hidden]:eq(0)').val();
		var questionType = questionDiv.find('input[type=hidden]:eq(1)').val();
		var isEtc = questionDiv.find('input[type=hidden]:eq(2)').val();
		
		var selVal = "";
		var itemVal = "";
		var etcVal = "";
		var weightVal = "";
		var selTempArr = new Array();
		var itemTempArr = new Array();
		var weightTempArr = new Array();
		
		if (questionType == 'S') {	// 객관식
			var checked = questionDiv.find('input[type=radio]:checked');
			selVal = checked.parent('div').next('input[type=hidden]:eq(0)').val();
			
			if (checked.parent().parent().hasClass('result_tx')) {
				etcVal = questionDiv.find("input:text").val();
			} else {
				itemVal = checked.prev().text();
			}
		} else if (questionType == 'D') {	// 주관식
			var inputText = questionDiv.find("input:text");
			if (inputText.val() != '') {
				selVal = inputText.parent().siblings('input[type=hidden]:eq(0)').val();
				itemVal = inputText.val();
			}
		} else if (questionType == 'M') {	// 복수응답
			$.each(questionDiv.find("input[type=checkbox]:checked"), function() {
				selTempArr.push($(this).parent().siblings('input[type=hidden]:eq(0)').val());
				itemTempArr.push($(this).prev().text());
			})
			selVal = selTempArr.join(';');
			itemVal = itemTempArr.join(';');			
		} else if (questionType == 'N') {	// 순위선택
			$.each(questionDiv.find("dl.choice_dl"), function() { //questionDiv.find("input[type=text].result_num_input")
				if ($(this).find('input:text').val() != '') {
					selTempArr.push($(this).find('input[type=hidden]:eq(0)').val());
					itemTempArr.push($(this).find('dd').text());
					weightTempArr.push($(this).find('input:text').val());
				}
			})
			selVal = selTempArr.join(';');
			itemVal = itemTempArr.join(';');
			weightVal = weightTempArr.join(';');
		}
		if (typeof(selVal) == "undefined") selVal = "";
		
		$(_mobile_survey_view.AnswerArr).each(function (i, v) {
			if (questionId == v.questionID) {
				v.itemID = selVal;
				v.answerItem = itemVal;
        		if (questionType == 'S' && isEtc == 'Y') 
        		{
        			v.etcOpinion = etcVal;
        		}
        		if (questionType == 'N') v.weighting = weightVal;
        		v.questionType = questionType;
			
				return false;
			}
		});
	});
}

function mobile_survey_view_submitSurvey()
{	
	if(!mobile_survey_view_checkRequired()){ // 필수 체크
		return ;
	}
	if(!mobile_survey_validation_Check()){
		alert(mobile_comm_getDic("msg_survey_errorRanking")); // 입력하신 순위를 다시 확인 해 주시기 바랍니다.
		return
	}
	
	mobile_survey_view_setAnswer();
	
	var oSurveyInfo = new Object();
	
	oSurveyInfo.surveyID = _mobile_survey_view.SurveyID;
	oSurveyInfo.answers = _mobile_survey_view.AnswerArr;
	
	var url = "/groupware/mobile/survey/insertQuestionItemAnswer.do";
	
	$.ajax({
		url: url,
		contentType : 'application/json; charset=utf-8',
		data: JSON.stringify(oSurveyInfo),
		type: "post",
		success: function (response) {			
			if(response.result == "ok") {
				mobile_comm_back();
				mobile_survey_clickrefresh();
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});	
}

function mobile_survey_view_checkRequired()
{
	var chkRequired = true; // true : 필수 항목에 모두 응답 , false: 필수 항목에 모두 응답 X
	 
	$("div.survey_cont").find(".survey_wrap").not(".group").each(function (i, v) {
		var questionDiv = $(this);
		var questionType = questionDiv.find('input[type=hidden]:eq(1)').val();
		var isRequired = questionDiv.find('input[type=hidden]:eq(3)').val();

		if(isRequired == "N"){
			return true;
		}
		
		//미리보기일 경우 체크하지 않음
		if(_mobile_survey_view.ReqType == "preview") {
			return true;
		}
		
		if (questionType == 'S') {	// 객관식
			if( questionDiv.find('input[type=radio]:checked').length <= 0){
				chkRequired = false;
				return false;
			}
		} 
		else if (questionType == 'D') {	// 주관식
			if( questionDiv.find("input:text").val() == "" || questionDiv.find("input:text").val() == undefined ){
				chkRequired = false;
				return false;
			}
		} 
		else if (questionType == 'M') {	// 복수응답
			if( questionDiv.find("input:checkbox:checked").length <= 0 ){
				chkRequired = false;
				return false;
			}
		} 
		else if (questionType == 'N') {	// 순위선택
			$.each(questionDiv.find(".type5"), function() {
				if ($(this).find('input:text').val() == '') {
					chkRequired = false;
					return false
				}
			});
		}	
	});
	 	 
	if(!chkRequired) {
		alert(mobile_comm_getDic("msg_survey_respondRequired")); //필수항목에 응답해주세요.
	}
	
	return chkRequired;
}

//설문 - 상세보기 끝








/*!
 * 
 * 설문 미리보기
 * 
 */


function mobile_survey_PreViewInit(){	
	// 1. 파라미터 셋팅
	_mobile_survey_view.ReqType = 'preview';
	_mobile_survey_view.HtmlTarget = 'preview';
	if (mobile_comm_getQueryString('surveyid', 'survey_preview_page') != 'undefined') {
		_mobile_survey_view.SurveyID = mobile_comm_getQueryString('surveyid', 'survey_preview_page');
	} else {
		_mobile_survey_view.SurveyID = '';
	}
	
	mobile_survey_getView(_mobile_survey_view);
}

//설문 상태 변경(승인, 거부)
function mobile_survey_updateSurveyState(state, type, surveyId) {
	var params = new Object();
	// 설문상태(A:작성중, B:검토대기, D:검토거부, C:승인대기, X:승인거부, F:진행중, G:설문종료)
	if (state == 'B') {	// 검토대기
		params.state = (type == 'accept') ? 'C' : 'D';
	} else {
		params.state = (type == 'accept') ? 'F' : 'X';
	}
	var surveyIdArr = new Array();
	surveyIdArr.push(surveyId);
	params.surveyIdArr = surveyIdArr;
	
	$.ajax({
		type : "POST",
		data : params,
		url : "/groupware/mobile/survey/updateSurveyState.do",
		success:function (data) {
			if(data.result == "ok") {
				if(data.status == 'SUCCESS') {
					mobile_comm_back();
					mobile_survey_clickrefresh();
          		} else {
          			alert(mobile_comm_getDic("msg_ErrorOccurred")); //오류가 발생 하였습니다.
          		}
			}
		},
		error:function(response, status, error) {
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//설문 - 미리보기 끝











/*!
 * 
 * 설문 결과보기
 * 
 */


function mobile_survey_ResultInit(){	
	// 1. 파라미터 셋팅
	_mobile_survey_view.ReqType = 'result';
	_mobile_survey_view.HtmlTarget = 'result';
	if (mobile_comm_getQueryString('surveyid', 'survey_result_page') != 'undefined') {
		_mobile_survey_view.SurveyID = mobile_comm_getQueryString('surveyid', 'survey_result_page');
	} else {
		_mobile_survey_view.SurveyID = '';
	}
	
	// 2. 글 목록 조회
	//설문 목록 가져오기
	mobile_survey_getResultView();	
}

// 초기화
function mobile_survey_getResultView() {
	
	var url = "/groupware/survey/getSurveyAnswerData.do";
	$.ajax({
		type : "POST",
		data : {
			surveyId : _mobile_survey_view.SurveyID,
			viewType : 'myResult'
		},
		async: false,
		url : url,
		success:function (response) {
			
			_mobile_survey_view.SurveyInfo = response.data;
			
			//설문 정보 설정
			mobile_survey_setSurveyInfo();
			
			//제목
			mobile_survey_view_getTitleHtml();
			
			//첨부 추가
			$('#survey_result_attach').html(mobile_comm_downloadhtml(response.fileList, "Survey"));
			var ResultAttach = $('#survey_result_attach');
			if(response.fileList.length != 0){
				ResultAttach.css('padding-bottom','15px');
			}else{
				ResultAttach.css('display','none');
			}
			
			//질문 데이터 세팅
			mobile_survey_view_getResultQuestionData();
		},
		error:function(response, status, error) {
			alert(url, response, status, error);
		}
	});
}

//질문 데이터 세팅
function mobile_survey_view_getResultQuestionData(){
	
	var sTempQuestion = new Array();
	$.each(_mobile_survey_view.SurveyInfo.questions, function(i, v) {
		sTempQuestion.push(v);
	});

	mobile_survey_view_getResultContentHtml(sTempQuestion);
	mobile_survey_view_getResultQuestionHtml(sTempQuestion);
	
}

//결과보기 설문 본문 Html
function mobile_survey_view_getResultContentHtml(surveyInfo) {	
	var sContentHtml = "";
	var sRequiredHtml = "";
	var sIsGrouping = _mobile_survey_view.SurveyInfo.isGrouping; //그룹핑 여부

	if(surveyInfo.length > 0)
	{
		
		$.each(surveyInfo, function(i, q) {
			
			if(sIsGrouping == "Y")
			{
				sContentHtml += "<div class=\"survey_wrap group type6\">";
				sContentHtml += 	"<h3 class=\"g_tit\">" + surveyInfo[i].groupName + "</h3>";
			}
			
			sRequiredHtml = "";
			if(q.isRequired == "Y")
			{
				sRequiredHtml += "<span class=\"hd\">[" + mobile_comm_getDic("lbl_Require") + "]</span>"; //필수
			}
	
			sContentHtml += "<div class=\"survey_wrap\" id=\"survey_question" + (Number(i) + 1) + "\">";
			sContentHtml += "	<input type='hidden' value=" + q.questionID + ">";
			sContentHtml += "	<input type='hidden' value='" + q.questionType + "'>";
			sContentHtml += "	<input type='hidden' value='" + q.isEtc + "'>";
			sContentHtml += "	<input type='hidden' value='" + q.isRequired + "'>"; 
			
			sContentHtml += "	<h4 class=\"tit\">";
			sContentHtml += "		<span class=\"num\">" + q.questionNO + "</span>";
			sContentHtml += "		<span class=\"tit_tx\">";
			sContentHtml += 			sRequiredHtml;
			sContentHtml += 			q.question;
			sContentHtml += "		</span>";
			sContentHtml += "	</h4>";
			sContentHtml += "</div>";
			
			if(sIsGrouping == "Y")
			{
				sContentHtml += "</div>";
			}
		});
		
		
		sContentHtml += "<div class=\"survey_btn align\">";		
		if(_mobile_survey_view.ReqType == "join"){
			sContentHtml += 	"	<a href=\"javascript: mobile_survey_view_getQuestionData('prev');\" class=\"prev\"><span class=\"tx\">" + mobile_comm_getDic("lbl_previous") + "</span></a>"; //이전		
			if(_mobile_survey_view.NextNo == 99){
				sContentHtml += "	<a href=\"javascript: mobile_survey_view_submitSurvey();\" class=\"next\"><span class=\"tx\">" + mobile_comm_getDic("lbl_Completed") + "</span></a>"; //완료
			}
			else{
				sContentHtml += "	<a href=\"javascript: mobile_survey_view_getQuestionData('next');\" class=\"next\"><span class=\"tx\">" + mobile_comm_getDic("lbl_next") + "</span></a>"; //다음
			}
		}
		sContentHtml += "</div>";
	}
	$('#survey_' + _mobile_survey_view.HtmlTarget + '_body').html(sContentHtml);
}

//문항별 html 처리
function mobile_survey_view_getResultQuestionHtml(surveyInfo) {
	var sQuestionHtml = "";
	var sIsEtc = ""; 					//기타
	var sAnswerItem = ''; 			//기존 답변 세팅 - 답
	var sQuestionItem = ''; 		//기존 답변 세팅 - 문제 번호
	var sParagraph = "";				//지문 표시용
	
	if(surveyInfo.length > 0)
	{
		$.each(surveyInfo, function(i, q) {
			$.each(_mobile_survey_view.AnswerArr, function(i, v) {
				if (q.groupingNo == v.groupingNo && q.questionNO == v.questionNO) {
					if (q.questionType == 'N') {
						sAnswerItem = v.weighting;
						sQuestionItem = v.itemID;
					} else if(q.questionType == 'S' || q.questionType=='M'){
						sAnswerItem = v.itemID;
					} else if(q.questionType == 'D'){
						sAnswerItem = v.answerItem;
					}
						
					return false;
				}
			});
			
			sQuestionHtml = "";
			sIsEtc = q.isEtc;
			
			//지문
			if (typeof(q.paragraph) != "undefined" && q.paragraph != "") {
				sParagraph   = "<p class='tx'>";
				sParagraph += "	<b>" + 	q.paragraph + "</b>";	//지문 제목
				sParagraph += "	<br />";
				sParagraph += 	q.description;							//지문 설명
				sParagraph += "</p>";
       		}
			$("#survey_question" + (Number(i) + 1)).prepend(sParagraph);
			
			if(q.questionType == "S")
			{
				$("#survey_question" + (Number(i) + 1)).addClass('type4'); //원래 type1이나 이미지 추가시 css 지원이 미흡하여 임의로 변경
			}
			else if(q.questionType == "D")
			{
				$("#survey_question" + (Number(i) + 1)).addClass('type2');
			}
			else if(q.questionType == "M")
			{
				$("#survey_question" + (Number(i) + 1)).addClass('type4'); //원래 type3이나 이미지 추가시 css 지원이 미흡하여 임의로 변경
			}
			else if(q.questionType == "N")
			{
				$("#survey_question" + (Number(i) + 1)).addClass('type5');
			}
			
			sQuestionHtml += "<div class=\"result_wrap\">";
			
			$.each(q.items, function(j, item) {		
				if(q.questionType == "S")
				{
					if (j == (q.items.length -1) && sIsEtc == 'Y')
					{
						sQuestionHtml += "<p class='result_radio' id='survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "' name='survey_question" + (Number(i) + 1) + "_item' >";
						sQuestionHtml += "		" + mobile_comm_getDic("lbl_Etc") + "<span name='etcOpinion'></span>";
						sQuestionHtml += "		<input type='hidden' value='" + item.itemID + "'>";
						sQuestionHtml += "</p>";
					}
					else
					{
						sQuestionHtml += "<p class='result_radio' id='survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "' name='survey_question" + (Number(i) + 1) + "_item' >";
						sQuestionHtml += 		item.item;
						sQuestionHtml += 		mobile_survey_view_getImg(item);
						sQuestionHtml += "		<input type='hidden' value='" + item.itemID + "'>";
						sQuestionHtml += "		<input type='hidden' value='" + item.nextQuestionNO + "'>";
						sQuestionHtml += "</p>";
					}
					
				}
				else if(q.questionType == "D")
				{
					sQuestionHtml += "<input type='hidden' value='" + item.itemID + "'>";
					sQuestionHtml += "<p class='result_tx' id='survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "'>";
					sQuestionHtml += "</p>";
				}
				else if(q.questionType == "M")
				{
					sQuestionHtml += "<p class='result_chk' id='survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "' name='survey_question" + (Number(i) + 1) + "_item' >";
					sQuestionHtml += 		item.item;
					sQuestionHtml += 		mobile_survey_view_getImg(item);
					sQuestionHtml += "		<input type='hidden' value='" + item.itemID + "'>";
					sQuestionHtml += "</p>";
				}
				else if(q.questionType == "N")
				{
					var sDDHtml = mobile_survey_view_getImg(item);
					if(sDDHtml != "")
					{
						sDDHtml = "<dd class='thum'>" + sDDHtml + "</dd>";
					}
					
					sQuestionHtml += "<dl class='result_dl' id='survey_question" + (Number(i) + 1) + "_item" + (Number(j) + 1) + "\'>";
					sQuestionHtml += "		<dt>";
					sQuestionHtml += "			<input type='hidden' value='" + item.itemID + "'>";
					sQuestionHtml += "		</dt>";
					sQuestionHtml += "		<dd>";
					sQuestionHtml += 			item.item;
					sQuestionHtml += "		</dd>";
					sQuestionHtml += 		sDDHtml;
					sQuestionHtml += "</dl>";
				}
			});	
			
			sQuestionHtml += "</div>";
			
			$("#survey_question" + (Number(i) + 1)).append(sQuestionHtml).trigger("create");
		});		
	}
	
	//나의 답변 찾기
	var myAnswer = null;
	if(_mobile_survey_view.SurveyInfo.userAnswers != null){
		var userID = mobile_comm_getSession("UR_Code").toUpperCase(); 
		$.each(_mobile_survey_view.SurveyInfo.userAnswers, function(i, v) {
			if(v.userId.toUpperCase() == userID){
				myAnswer = v;
			};				
		});
	}

	//나의 답변 결과 세팅
	if (myAnswer != null) {
    	// 값 세팅
		$('.survey_wrap').not(".group").each(function (i, v) {
    		var question = $(this);
			var questionId = question.find('input[type=hidden]:eq(0)').val();
			var questionType = question.find('input[type=hidden]:eq(1)').val();
    		
			$.each(myAnswer.answers, function(i, v) {
	    		var answerItem = v.AnswerItem;
	    		var answerItemId = v.AnswerItemId;
	    		var etcOpinion = v.EtcOpinion;
	    		
	    		if (questionId == v.QuestionID) {
					if (questionType == 'S') {	// 객관식
						$.each(question.find('p.result_radio'), function(i, v) {
							var item = $(this).find('input[type=hidden]:eq(0)');
							if (answerItemId == item.val()){
								$(v).addClass('selected');
							}
							if (answerItemId == item.val() &&  etcOpinion != ""){
								$(v).find('span[name=etcOpinion]').text("(" + etcOpinion + ")");
							}
						});
					} else if (questionType == 'D') {	// 주관식
						question.find('p.result_tx').append(answerItem);
					} else if (questionType == 'M') {	// 복수응답
						var answerItemIdArr = answerItemId.split(';');
						$.each(question.find('p.result_chk'), function(i, v) {
							var item = $(this).find('input[type=hidden]:eq(0)');
							if ($.inArray(item.val(), answerItemIdArr) != -1) $(v).addClass('selected');
						});
					} else if (questionType == 'N') {	// 순위선택
						var answerItemArr = answerItem.split(';');
					
						$.each(question.find('dl.result_dl'), function(i, v) {
							$(this).find('dt').text(i + 1);
							$(this).find('dd:not(.thum)').text(answerItemArr[i]);
							if(i == 0){
								$(this).addClass("selected");
							}
						});
					}
	    		}
	    	});
		});
	} 	
}

//설문 - 결과보기 끝











/*!
 * 
 * 설문 참여 대상
 * 
 */
//설문 대상 조회 페이지
$(document).on('pageinit', '#survey_target_page', function () {
	if($("#survey_target_list li").length == 0) {
		setTimeout("mobile_survey_TargetInit()", 10);
	}
});

//설문 대상 조회 페이지 나가기
$(document).on('pagebeforehide', '#survey_target_page', function () {	
	$("#survey_target_page").remove();	
});

var _mobile_survey_target = {
		// 리스트 조회 초기 데이터
		SurveyID: '',				//설문ID
		Type:'',					//타입 설문대상 : Respondent, 결과 공개 대상 : ResultView
		Page: 1,					//조회할 페이지
		PageSize: 10,			//페이지당 건수
		
		// 페이징을 위한 데이터
		Loading: false,			//데이터 조회 중
		TotalCount: -1,		//전체 건수
		RecentCount: 0,		//현재 보여지는 건수
		EndOfList: false,		//전체 리스트를 다 보여줬는지
		
		//스크롤 위치 고정
		OnBack: false,			//뒤로가기로 왔을 경우
		Scroll: 0					//스크롤 위치		
	};

function mobile_survey_TargetInit() //여기
{	
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('SurveyID', 'survey_target_page') != 'undefined') {
		_mobile_survey_target.SurveyID = mobile_comm_getQueryString('SurveyID', 'survey_target_page');
    } else {
    	_mobile_survey_target.SurveyID = 0;
    }
	if (mobile_comm_getQueryString('Type', 'survey_target_page') != 'undefined') {
		_mobile_survey_target.Type = mobile_comm_getQueryString('Type', 'survey_target_page');
    } else {
    	_mobile_survey_target.Type = 'Respondent';
    }
	if (mobile_comm_getQueryString('page', 'survey_target_page') != 'undefined') {
		_mobile_survey_target.Page = mobile_comm_getQueryString('page', 'survey_target_page');
    } else {
    	_mobile_survey_target.Page = 1;
    }
	if (mobile_comm_getQueryString('pageSize', 'survey_target_page') != 'undefined') {
		_mobile_survey_target.PageSize = mobile_comm_getQueryString('pageSize', 'survey_target_page');
    } else {
    	_mobile_survey_target.PageSize = 10;
    }
	_mobile_survey_target.EndOfList = false;
	
	mobile_survey_getTargetList(_mobile_survey_target);
}

function mobile_survey_getTargetList(params)
{
	var url = "";
	
	if(params.Type == 'Respondent') 
	{
		url = "/groupware/mobile/survey/getTargetRespondentList.do";
		$('#survey_target_title').html(mobile_comm_getDic("lbl_polltarget") + " " + mobile_comm_getDic("lbl_view")); //설문대상 보기
	}
	else
	{
		url = "/groupware/mobile/survey/getTargetResultviewList.do";
		$('#survey_target_title').html(mobile_comm_getDic("lbl_title_surveyResult_01")); //결과공개대상 보기
	}
	
	var paramdata = {
		surveyId : params.SurveyID,
		pageNo: params.Page,
		pageSize: params.PageSize,
		schTxt: params.SearchText
	};
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		success: function (response) {			
			if(response.status == "SUCCESS") {
				_mobile_survey_target.TotalCount = response.page.listCount;
				
				var sHtml = "";
				sHtml = mobile_survey_getTargetListHtml(response.list);
				
				if(params.Page == 1 || sHtml.indexOf("no_list") > -1) {
					$('#survey_target_list').html(sHtml);
				} else {
					$('#survey_target_list').append(sHtml);
				}
				
				if (Math.min((_mobile_survey_target.Page) * _mobile_survey_target.PageSize, _mobile_survey_target.TotalCount) == _mobile_survey_target.TotalCount) {
					_mobile_survey_target.EndOfList = true;
	                $('#survey_target_more').hide();
	            } else {
	                $('#survey_target_more').show();
	            }
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});	
}

function mobile_survey_getTargetListHtml(targetList)
{
	var sHtml = "";
	if(targetList.length > 0) {
		$(targetList).each(function (i, targetUser){
			sHtml += "<li class=\"staff\">";
			sHtml += 	"<a href=\"#\" class=\"con_link\">";
			sHtml += 	"<span class=\"photo\" style=\"background-image: url('" + mobile_comm_getimg(targetUser.PhotoPath) + "'), url('" + mobile_comm_noperson() + "')\"></span>";
			sHtml +=	"<div class=\"info\">";
			sHtml +=		"<p class=\"name\">" + targetUser.DisplayName + "</p>";
			sHtml += 		"<p class=\"detail\">";
			sHtml += 			"<span>" + targetUser.DeptName + "</span>";
			sHtml += 		"</p>";
			sHtml +=	"</div>";
			
			// 결과공개대상 보기일 경우는 노출 안 되도록 수정
			if(_mobile_survey_target.Type != "ResultView"){
				if(targetUser.RegistDate == undefined || targetUser.RegistDate == 'undefined' || targetUser.RegistDate == '') 
				{
					sHtml += 	"<div class=\"part_state\">";
					sHtml += 	"<p class=\"state\">" + mobile_comm_getDic("lbl_Nonparticipation") + "</p>"; //미참여
					sHtml +=	"</div>";
				}
				else
				{
					sHtml += 	"<div class=\"part_state complete\">";
					sHtml += 	"<p class=\"state\">" + mobile_comm_getDic("lbl_survey_participation") + "</p>"; //참여
					sHtml += 	"<p class=\"date\">" + CFN_TransLocalTime(targetUser.RegistDate) + "</p>";
					sHtml +=	"</div>";
				}
			}
			
			sHtml += 	"</a>";
			sHtml += "</li>";
		});
	}
	else {
		sHtml += "<div class=\"no_list\">";
		sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
		sHtml += "</div>";
	}
	
	return sHtml;
}

//대상
function mobile_survey_view_target(type) {	
	var url = "/groupware/mobile/survey/targetlist.do";
	url += "?SurveyID=" + _mobile_survey_view.SurveyID;
	url += "&Type=" + type;

	mobile_comm_go(url,'Y');
}

//대상 더보기 클릭
function mobile_survey_target_nextlist() {
	if (!_mobile_survey_target.EndOfList) {
		_mobile_survey_target.Page++;

		mobile_survey_getTargetList(_mobile_survey_target);
		
    } else {
        $('#survey_list_more').css('display', 'none');
    }
}

//스크롤 더보기
function mobile_survey_target_page_ListAddMore(){
	mobile_survey_target_nextlist();
}

//순위 누락 체크
function mobile_survey_validation_Check(){
	for (var t5i = 0; t5i < $("div[class='survey_wrap type5']").length; t5i++){
		var t5obj = $("div[class='survey_wrap type5']").eq(t5i);
		
		var arr = [];
		$(t5obj).find("input[class='choice_num_input']").each(function(ci, cObj){
			var value = $(cObj).val();
			if(value){
				arr.push(value);
			}
		});
		
		if(arr.length != 0 && arr.length != $(t5obj).find("input[class='choice_num_input']").length){
			return false;
		}
	}
	
	return true;
}

function mobile_survey_view_changeRadio(obj){
	if ($(obj).parent().siblings('input[type=hidden]:eq(1)').val() == '99'){
		$(".survey_btn .next span").text(mobile_comm_getDic("lbl_Completed"));
		$(".survey_btn a.next").attr("href", "javascript: mobile_survey_view_submitSurvey();");
	}
	else {
		$(".survey_btn .next span").text(mobile_comm_getDic("lbl_next"));
		$(".survey_btn a.next").attr("href", "javascript: mobile_survey_view_getQuestionData('next');");
	}
}

//설문 - 참여 대상 끝