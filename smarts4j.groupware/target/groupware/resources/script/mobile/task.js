
/*!
 * 
 * 
 * SmartS4j / MobileOffice / 모바일 업무 js 파일
 * 함수명 : mobile_task_...
 * 
 * 
 */



/*!
 * 
 * 페이지별 init 함수
 * 
 */

//업무 목록 페이지
$(document).on('pageinit', '#task_list_page', function () {
	if($("#task_list_page").attr("IsLoad") != "Y"){
		$("#task_list_page").attr("IsLoad", "Y");
		setTimeout("mobile_task_ListInit()",10);
	}
});

//폴더/업무 작성 페이지
$(document).on('pageinit', '#task_write_page', function () {
	if($("#task_write_page").attr("IsLoad") != "Y"){
		$("#task_write_page").attr("IsLoad", "Y");
		setTimeout("mobile_task_WriteInit()",10);	
	}
});

//폴더 이동 페이지
$(document).on('pageinit', '#task_move_page', function () {
	if($("#task_move_page").attr("IsLoad") != "Y"){
		$("#task_move_page").attr("IsLoad", "Y");
		setTimeout("mobile_task_MoveInit()",10);	
	}
});

//업무 조회 페이지
$(document).on('pageinit', '#task_view_page', function () {
	if($("#task_view_page").attr("IsLoad") != "Y"){
		$("#task_view_page").attr("IsLoad", "Y");
		setTimeout("mobile_task_ViewInit()",10);	
	}
});

//업무 공유자 페이지
$(document).on('pageinit', '#task_sharedperson_page', function () {
	if($("#task_sharedperson_page").attr("IsLoad") != "Y"){
		$("#task_sharedperson_page").attr("IsLoad", "Y");
		setTimeout("mobile_task_SharedPersonInit()",10);	
	}
});

//업무 - 페이지별 init 함수 끝








/*!
 * 
 * 업무 목록
 * 
 */
//TODO : 더보기 기능 필요
var _mobile_task_list = {
	// 리스트 조회 초기 데이터
	FolderID: '0',			//폴더ID
	IsMine: 'N',				//업무 타입(Y - 내가하는일, N - 같이하는일)
	ParentFolderID: '0',	//부모 폴더ID
	Page: 1,					//조회할 페이지
	PageSize: 10,			//페이지당 건수
	SearchText: '',			//검색어
	SearchType: 'All',		//검색타입
	
	//폴더 종합 정보
	ShareList: null,			//같이 하는 일
	PersonList: null,		//내가 하는 일
	
	// 페이징을 위한 데이터
	Loading: false,			//데이터 조회 중
	TotalCount: -1,		//전체 건수
	RecentCount: 0,		//현재 보여지는 건수
	EndOfList: false,		//전체 리스트를 다 보여줬는지
	
	//스크롤 위치 고정
	OnBack: false,			//뒤로가기로 왔을 경우
	Scroll: 0					//스크롤 위치		
};

function mobile_task_ListInit(){	
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('folderid') != 'undefined') {
		_mobile_task_list.FolderID = mobile_comm_getQueryString('folderid');
	} else {
		_mobile_task_list.FolderID = '0';
	}
	if (mobile_comm_getQueryString('ismine') != 'undefined') {
		_mobile_task_list.IsMine = mobile_comm_getQueryString('ismine');
	} else {
		_mobile_task_list.IsMine = 'N';
	}
	if (mobile_comm_getQueryString('onback') != 'undefined') {
		_mobile_task_list.OnBack = mobile_comm_getQueryString('onback');
    } else {
    	_mobile_task_list.OnBack = false;
    }
	/*if (mobile_comm_getQueryString('page') != 'undefined') {
		_mobile_task_list.Page = mobile_comm_getQueryString('page');
	} else {
		_mobile_task_list.Page = 1;
	}
	if (mobile_comm_getQueryString('pagesize') != 'undefined') {
		_mobile_task_list.PageSize = mobile_comm_getQueryString('pagesize');
	} else {
		_mobile_task_list.PageSize = 10;
	}
	if (mobile_comm_getQueryString('searchtext') != 'undefined') {
		_mobile_task_list.SearchText = mobile_comm_getQueryString('searchtext');
	} else {
		_mobile_task_list.SearchText = '';
	}
	if (mobile_comm_getQueryString('scroll') != 'undefined') {
		_mobile_task_list.Scroll = mobile_comm_getQueryString('scroll');
    } else {
    	_mobile_task_list.Scroll = 0;
    }
	
	_mobile_task_list.TotalCount = -1;
	_mobile_task_list.RecentCount = 0;
	_mobile_task_list.EndOfList = false;*/
	
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
			
			if(prev.indexOf("/view.do") > -1 || prev.indexOf("/write.do") > -1) {
				(mobile_comm_getQueryStringForUrl(prev, 'pfid') != "undefined") ? _mobile_task_list.FolderID = mobile_comm_getQueryStringForUrl(prev, 'pfid'):"";
				(mobile_comm_getQueryStringForUrl(prev, 'isowner') != "undefined") ? _mobile_task_list.IsMine = mobile_comm_getQueryStringForUrl(prev, 'isowner'):"";
				
				_mobile_task_list.OnBack = true;
				
				if(parseInt(window.sessionStorage["mobile_history_index"]) < arrHistoryData.length) {
					arrHistoryData = arrHistoryData.splice(0, parseInt(window.sessionStorage["mobile_history_index"]));
					window.sessionStorage["mobile_history_data"] = JSON.stringify(arrHistoryData);
				}
			} else if(prev.indexOf("/move.do") > -1) {
				(mobile_comm_getQueryStringForUrl(prev, 'folderid') != "undefined") ? _mobile_task_list.FolderID = mobile_comm_getQueryStringForUrl(prev, 'folderid'):"";
				(mobile_comm_getQueryStringForUrl(prev, 'ismine') != "undefined") ? _mobile_task_list.IsMine = mobile_comm_getQueryStringForUrl(prev, 'ismine'):"";
				
				_mobile_task_list.OnBack = true;
				
				if(parseInt(window.sessionStorage["mobile_history_index"]) < arrHistoryData.length) {
					arrHistoryData = arrHistoryData.splice(0, parseInt(window.sessionStorage["mobile_history_index"]));
					window.sessionStorage["mobile_history_data"] = JSON.stringify(arrHistoryData);
				}
			}
		}
	} catch(e) {
		mobile_comm_log(e);
	}
	
	// 2. 상단메뉴
	//setTimeout(function () {
		mobile_task_getTreeData('list');
    //}, 100);

	// 3. 글 목록 조회
	//setTimeout(function () {
		//검색어 초기화
		$('#mobile_search_input').val('');
		_mobile_task_list.SearchText = '';
		
		//업무 목록 가져오기
		mobile_task_getList(_mobile_task_list);
    //}, 100);
}


//폴더 목록 조회
function mobile_task_getTreeData(pPage){
	
	var url = "/groupware/mobile/task/getFolderList.do";
	var paramdata = {
			type:"All"
	};
	
	$.ajax({
		url: url,
		data:	paramdata,
		type:"POST",
		async: false,
		success: function(response){
			
			if(response.status == "SUCCESS") {
				_mobile_task_list.ShareList = response.ShareList;
				_mobile_task_list.PersonList = response.PersonList;
				
				if(pPage != "move"){
					$('#task_' + pPage + '_topmenuShare>li:eq(0)').html(mobile_task_getTopTreeHtml(pPage, response.ShareList, 'pno', '0', 'ParentFolderID', 'with')).trigger("create");
					$('#task_' + pPage + '_topmenuPerson>li:eq(0)').html(mobile_task_getTopTreeHtml(pPage, response.PersonList, 'pno', '0', 'ParentFolderID', 'my')).trigger("create");
				} else {
					if(_mobile_task_move.IsMine == "N"){
						$('#task_' + pPage + '_topmenuShare>li:eq(0)').html(mobile_task_getTopTreeHtml(pPage, response.ShareList, 'pno', '0', 'ParentFolderID', 'with')).trigger("create");
						$('#task_' + pPage + '_topmenuPerson').parent('div').parent('li').hide();
					} else {	
						$('#task_' + pPage + '_topmenuPerson>li:eq(0)').html(mobile_task_getTopTreeHtml(pPage, response.PersonList, 'pno', '0', 'ParentFolderID', 'my')).trigger("create");
						$('#task_' + pPage + '_topmenuShare').parent('div').parent('li').hide();
					}
				}
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
 		}
	});
}

//트리 그리기
function mobile_task_getTopTreeHtml(pPage, pData, pRootNode, pRootValue, pParentNode, pParentType) {
	
	//pPage - 페이지 종류(list, move 등)
	//pData - 트리 전체 데이터 Array
	//pRootNode - 루트 여부 확인하는 node명
	//pRootValue - pRootNode가 이 값인게 루트
	//pParentNode - 상위 여부 확인하는 node명
	//pParentType - 루트의 타입을 확인(my-내가하는일, with-같이하는일)
	
	var sHtml = "";
	
	if(pParentType == "with"){
		sHtml += "<a href=\"\" class=\"t_link not_tree\">";
		sHtml += "		<span onclick=\"javascript: mobile_task_openclose('ul_sub_with', 'span_menu_with', 'with');\">";
		sHtml += "			<span id=\"span_menu_with\" class=\"t_ico_open\"></span><span class=\"t_ico_with\"></span>";
		sHtml += "		</span>";
		sHtml += "		<span onclick=\"javascript: mobile_task_changeFolder('0', 'with');\">";
		sHtml += "			" + mobile_comm_getDic("lbl_Share_Task"); //같이 하는 일
		sHtml += "		</span>";
		sHtml += "</a>";
	} else {
		sHtml += "<a href=\"\" class=\"t_link not_tree\">";
		sHtml += "		<span onclick=\"javascript: mobile_task_openclose('ul_sub_my', 'span_menu_my', 'my');\">";
		sHtml += "			<span id=\"span_menu_my\" class=\"t_ico_open\"></span><span class=\"t_ico_my\"></span>";
		sHtml += "		</span>";
		sHtml += "		<span onclick=\"javascript: mobile_task_changeFolder('0', 'my');\">";
		sHtml += "			" + mobile_comm_getDic("lbl_Person_Task"); //내가 하는 일
		sHtml += "		</span>";
		sHtml += "</a>";
	}
	
	if(pPage == "move"){
		sHtml += "<label for=\"task_radio0\"></label>";
		sHtml += "<input type=\"radio\" name=\"task_radio\" value=\"0\" id=\"task_radio0\">";
	}
	
	
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
			
	var iDepth = 0;
	var sClass = "";
	var sArrow = "";	 //폴더 열기/닫기 화살표
	var sALink = "";	 //폴더 열기/닫기 링크
	var sFLink = ""; 	 //폴더 이동 링크
	var sRadio = ""; 	 //폴더 선택 라디오
	
	sHtml += "<ul id=\"ul_sub_"+pParentType+"\" class=\"sub_list\">";
	$(arrRoot).each(function (j, root) {
		
		if(root.childCnt > 0){
			sClass = "t_ico_open";
			//sClass = "t_ico_f_open";
			//sArrow = "<span class='t_ico_open'></span>";
			sALink = "mobile_task_openclose('ul_sub_" + root.FolderID + "', 'span_menu_" + root.FolderID + "', '');";
		} else {
			sClass = "t_ico_board";
			//sClass = "t_ico_f_close";
			//sArrow = "" ;
			sALink = "";
		}
		
		

		//폴더 이동 페이지일 경우
		if(pPage == "move"){
			//라디오 버튼
			sRadio = "	<label for=\"task_radio" + root.FolderID +"\"></label>";
			sRadio += "<input type=\"radio\" name=\"task_radio\" value=\"" + root.FolderID + "\" id=\"task_radio" + root.FolderID +"\">";
			//폴더로 이동 불가
			sFLink = "#";
		} else {
			//라디오 버튼
			sRadio = "";
			//폴더로 이동 가능
			sFLink = "javascript: mobile_task_changeFolder('" + root.FolderID + "', '" + pParentType + "');";
		}
			
		//sHtml += "<ul class=\"sub_list\">";
		sHtml += "    <li>";
		sHtml += "        <a href=\"\" class=\"t_link\">";
		sHtml += "				<span id=\"span_menu_" + root.FolderID + "\" class=\"" + sClass + "\" onclick=\""+sALink+"\"></span>";
		sHtml += "				<span onclick=\"" + sFLink + "\">";
		sHtml += 					root.DisplayName;
		sHtml += "				</span>";
		sHtml += "			</a>";
		sHtml += 			sRadio;	//pPage가 move일 경우에만 보임
		sHtml += "		<ul id=\"ul_sub_" + root.FolderID + "\" class=\"sub_list\">";
		sHtml += 			mobile_task_getTopTreeHtmlRecursive(pPage, pData, pParentNode, root.FolderID, iDepth + 1, pParentType);
		sHtml += "		</ul>";
		sHtml += "    </li>";
		//sHtml += "</ul>";
	});	
	sHtml += "</ul>";
	
	return sHtml;
}

//하위 트리 폴더 그리기
function mobile_task_getTopTreeHtmlRecursive(pPage, pData, pParentNode, pParentValue, pDepth, pParentType) {
	
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
	
	var sClass = "";
	var sArrow = "";	 //폴더 열기/닫기 화살표
	var sALink = "";	 //폴더 열기/닫기 링크
	var sFLink = ""; 	 //폴더 이동 링크
	var sRadio = ""; 	 //폴더 선택 라디오
	
	//sHtml += "<ul id=\"ul_sub_" + pParentValue + "\" class=\"sub_list\">";
	$(arrSub).each(function (j, sub) {
		
		if(sub.childCnt > 0){
			sClass = "t_ico_open";
			//sClass = "t_ico_f_open";
			//sArrow = "<span class='t_ico_open'></span>";
			sALink = "mobile_task_openclose('ul_sub_" + sub.FolderID + "', 'span_menu_" + sub.FolderID + "', '');";
		} else {
			sClass = "t_ico_board";
			//sClass = "t_ico_f_close";
			//sArrow = "" ;
			sALink = "";
		}
				
		//sALink = "javascript: mobile_task_openclose('ul_sub_" + sub.FolderID + "', 'span_menu_" + sub.FolderID + "', '');";
		
		//폴더 이동 페이지일 경우
		if(pPage == "move"){
			//라디오 버튼
			sRadio = "	<label for=\"task_radio" + sub.FolderID +"\"></label>";
			sRadio += "<input type=\"radio\" name=\"task_radio\" value=\"" + sub.FolderID + "\" id=\"task_radio" + sub.FolderID +"\">";
			//폴더로 이동 불가
			sFLink = "#";
		} else {
			//라디오 버튼
			sRadio = "";
			//폴더로 이동 가능
			sFLink = "javascript: mobile_task_changeFolder('" + sub.FolderID + "', '" + pParentType + "');";
		}
		
		sHtml += "    <li folderid=\"" + sub.FolderID + "\" displayname=\"" + sub.DisplayName + "\">";
		sHtml += "        <a href=\"\" class=\"t_link\">";
		sHtml += "				<span id=\"span_menu_" + sub.FolderID + "\" class=\"" + sClass + "\" onclick=\""+sALink+"\"></span>";
		sHtml += "				<span onclick=\"" + sFLink + "\">";
		sHtml += 					sub.DisplayName;
		sHtml += "				</span>";
		sHtml += "			</a>";
		sHtml += 			sRadio;	//pPage가 move일 경우에만 보임
		sHtml += "		<ul id=\"ul_sub_" + sub.FolderID + "\" class=\"sub_list\">";
		sHtml += 			mobile_task_getTopTreeHtmlRecursive(pPage, pData, pParentNode, sub.FolderID, pDepth + 1, pParentType);
		sHtml += "		</ul>";
		sHtml += "    </li>";
	});
	//sHtml += "</ul>";
	
	return sHtml;
	
}

//하위 메뉴/트리 열고 닫기
function mobile_task_openclose(liId, iconId, rootName) {
	var obj =$('#' + iconId); 
	if($(obj).hasClass('t_ico_open')){			
		$(obj).removeClass('t_ico_open').addClass('t_ico_close');											
		$('#' + liId).hide();
	} else {			
		$(obj).removeClass('t_ico_close').addClass('t_ico_open');						
		$('#' + liId).show();
	}
}
/*
//하위 메뉴/트리 열고 닫기
function mobile_task_openclose(liId, iconId, rootName) {
	if(rootName != ''){
		var obj =$('.t_ico_' + rootName); 
		if($(obj).siblings('span:eq(0)').hasClass('t_ico_open')){			
			$(obj).siblings('span:eq(0)').removeClass('t_ico_open').addClass('t_ico_close');					
			$(obj).parent('span').parent('a').siblings('li').hide();
		} else {			
			$(obj).siblings('span:eq(0)').removeClass('t_ico_close').addClass('t_ico_open')
			$(obj).parent('span').parent('a').siblings('li').show();
		}
	} else {
		var obj =$('#' + iconId); 
		if($(obj).siblings('span:eq(0)').hasClass('t_ico_open')){			
			$(obj).siblings('span:eq(0)').removeClass('t_ico_open').addClass('t_ico_close');						
			$(obj).removeClass('t_ico_f_open').addClass('t_ico_f_close');						
			$('#' + liId).hide();
		} else {			
			$(obj).siblings('span:eq(0)').removeClass('t_ico_close').addClass('t_ico_open');						
			$(obj).removeClass('t_ico_f_close').addClass('t_ico_f_open');
			$('#' + liId).show();
		}
	}
}
*/

//폴더 및 업무 리스트 조회
function mobile_task_getList(params)
{
	
	//같이 하는 일(루트) 폴더의 경우 폴더/업무 추가 불가능
	if(params.FolderID == "0" && params.IsMine == "N"){		
		$("#task_list_btnAdd").hide();
		$("#task_list_btnAddTask").hide();
	} else {
		$("#task_list_btnAdd").show();
		$("#task_list_btnAddTask").show();
	}
	
	mobile_comm_TopMenuClick('task_list_topmenu',true);
	
	var paramdata = {
			folderID : params.FolderID,
			isMine : params.IsMine,
			stateCode : '',
			searchType : params.SearchType,
			searchWord : params.SearchText,
			sortColumn : '',
			sortDirection : ''
	};
	var url = "/groupware/mobile/task/getFolderItemList.do";
	
	$.ajax({
		url: url,
		data: paramdata,
		type: "post",
		async: false,
		success: function (response) {
			if(response.status=='SUCCESS'){
				//DisplayName 설정				
				$("#task_list_title").html(response.FolderInfo.DisplayName);							
				$(".task_loc_list").html(mobile_task_getCurrentFolderLocation('list', params.FolderID));
				if(_mobile_task_list.FolderID != "0"){					
					$("#task_loc_top").attr("onclick","mobile_task_changeFolder();");
				}else{
					$("#task_loc_top").attr("onclick","");			
				}
				
				_mobile_task_list.ParentFolderID = response.FolderInfo.ParentFolderID;
				mobile_task_setFolderItemResult(response);
				
				if(_mobile_task_list.OnBack) {
					_mobile_task_list.OnBack = false;
				}
			}else{
				alert(mobile_comm_getDic("msg_ErrorOccurred")); //오류가 발생하였습니다.
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//폴더 현 위치 가져오기
function mobile_task_getCurrentFolderLocation(pMode, pFolderID){
	
	var arrLocation = new Array();
	var folderList = null;
	var sHtml = "";
	
	//리스트일 경우, 이미 조회한 데이터가 있음
	if(pMode == "list"){
		//대상 리스트 선정
		if(_mobile_task_list.IsMine == "Y"){
			folderList = _mobile_task_list.PersonList;
		} else {
			folderList = _mobile_task_list.ShareList;
		}
	} else {
		var url = "/groupware/mobile/task/getFolderList.do";
		var paramdata = {
				type:"All"
		};
		
		$.ajax({
			url: url,
			data:	paramdata,
			type:"POST",
			async: false,
			success: function(response){
				
				if(response.status == "SUCCESS") {
					//대상 리스트 선정
					if(pMode == "write"){
						//같이 하는 일(루트)폴더에 폴더/업무 추가 불가능 
						if((_mobile_task_write.Type == "T" && _mobile_task_write.ParentFolderID == "0") || _mobile_task_list.IsMine == "Y"){
							folderList = response.PersonList;
						} else {
							folderList = response.ShareList;
						}
					} else if(pMode == "move"){
						if(_mobile_task_move.IsMine == "Y"){
							folderList = response.PersonList;
						} else {
							folderList = response.ShareList;
						}
					} else if(pMode == "view"){
						if(_mobile_task_view.IsMine == "Y"){
							folderList = response.PersonList;
						} else {
							folderList = response.ShareList;
						}
					}
				}
			},
			error:function(response, status, error){
				mobile_comm_ajaxerror(url, response, status, error);
			}
		});
	}
	
	if(folderList != null){

		var currFolderID = pFolderID;
		do {
			$.each(folderList, function(idx, obj){
				if( currFolderID == obj.FolderID){
					arrLocation.push(obj);
					currFolderID = obj.pno;
					return false;
				} 
			});
		} while(currFolderID != "");
		
		//html 생성 및 적용	
		arrLocation.reverse();
		
		$.each(arrLocation, function(idx, obj){
			sHtml += "<li fdid='" + obj.FolderID + "'><p class='tx'>" + obj.DisplayName + "</p></li>";
		});
	}
	
	return sHtml;
	
}

//폴더 조회 결과 셋팅
function mobile_task_setFolderItemResult(folderObj){
	$("#task_list_folderlist").html(getFolderListHTML(folderObj.FolderList));
	$("#task_list_tasklist").html(getTaskListHTML(folderObj.TaskList));
}

//폴더 리스트 HTML 그리기
function getFolderListHTML(folderList){
	
	var userCode = mobile_comm_getSession("UR_Code").toLowerCase();
	var listHTML = '';

	if(folderList.length <= 0){
		$("#task_list_folderCnt").html("<i class='bull'></i>" + mobile_comm_getDic("lbl_Folder")); //폴더
		
		listHTML += "<div class=\"no_list\" style=\"padding-top: 50px;\">";
		listHTML += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
		listHTML += "</div>";
		return listHTML;
	}else{
		$("#folderDiv").show();
		$("#task_list_folderCnt").html("<i class='bull'></i>" + mobile_comm_getDic("lbl_Folder") + "("+folderList.length+")"); //폴더
	}
	
	$.each(folderList, function(idx,obj){
		
		listHTML += '<li class="folder_link">';
		listHTML += '	 <a onclick="javascript: mobile_task_changeFolder(\'' + obj.FolderID + '\'); " class="con_link">';
		listHTML += '		<i class="ico_folder"></i>';
		listHTML += '		<p class="tx ellip">'+ obj.DisplayName +'</p>';
		if(obj.FolderState == "대기"){
			if(obj.FolderProgress == ""){
				listHTML += '		<p class="state">' + mobile_comm_getDic("lbl_inactive") + '</p>'; //대기
			}else{			
				listHTML += '		<p class="state">' + mobile_comm_getDic("lbl_inactive") + '('+ obj.FolderProgress + '%)' + '</p>';
			}
		} else if(obj.FolderState == "진행중"){
			if(obj.FolderProgress == ""){
				listHTML += '		<p class="state ing">' + mobile_comm_getDic("lbl_Progressing") + '</p>'; //진행중
			}else{
				listHTML += '		<p class="state ing">' + mobile_comm_getDic("lbl_Progressing") + '('+ obj.FolderProgress + '%)' + '</p>';
			}
		} else{
			listHTML += '		<p class="state complete">' + mobile_comm_getDic("lbl_Completed") + '</p>'; //완료
		}
		listHTML += '	 </a> ';
		listHTML += '	 <a href="#" class="btn_drop_menu" onclick="mobile_task_clickDropMenu(this);"><!-- 메뉴--></a>';
		listHTML += '	 <div class="exmenu_layer">';
		listHTML += '		<ul class="exmenu_list ">';
		if(obj.OwnerCode == userCode){
			listHTML += '			<li><a class="btn ui-link" onclick="javascript: mobile_task_clickmove(\'moveFolder\', \'' + obj.FolderID + '\', \'' + obj.ParentFolderID + '\', \'' + _mobile_task_list.IsMine + '\');">' + mobile_comm_getDic("btn_Move") + '</a></li>'; //이동
		}
		if(obj.RegisterCode==userCode || obj.OwnerCode == userCode){
			listHTML += '			<li><a class="btn ui-link" onclick="javascript: mobile_task_clickdelete(\'F\', \''+obj.FolderID +'\')">' + mobile_comm_getDic("btn_delete") + '</a></li>'; //삭제
			listHTML += '			<li><a class="btn ui-link" onclick="javascript: mobile_task_clickmodify(\'F\', \'' + obj.FolderID + '\', \'Y\', \'' + obj.ParentFolderID + '\');">' + mobile_comm_getDic("btn_Setting") + '</a></li>'; //설정
		} else {
			listHTML += '			<li><a class="btn ui-link" onclick="javascript: mobile_task_clickmodify(\'F\', \'' + obj.FolderID + '\', \'N\', \'' + obj.ParentFolderID + '\');">' + mobile_comm_getDic("btn_Setting") + '</a></li>'; //설정
		}
		listHTML += '		</ul>';
		listHTML += '	 </div>';
		listHTML += '</li>';
	});
	
	return listHTML;
}

//드롭다운 메뉴 클릭
function mobile_task_clickDropMenu(pObj){
	var divObj = $(pObj).siblings('div.exmenu_layer');
	if($(divObj).css("display") == "none"){
		$(divObj).show(); 
	} else { 
		$(divObj).hide(); 
	}
}

//업무 리스트 HTML 그리기
function getTaskListHTML(taskList){
	
	var userCode = mobile_comm_getSession("UR_Code").toLowerCase();
	var listHTML = '';
	
	if(taskList.length <= 0){
		$("#task_list_taskCnt").html("<i class='bull'></i>" + mobile_comm_getDic("lbl_task_task")); //업무
		
		listHTML += "<div class=\"no_list\" style=\"padding-top: 50px;\">";
		listHTML += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
		listHTML += "</div>";
		return listHTML;
	}else{
		$("#taskDiv").show();
		$("#task_list_taskCnt").html("<i class='bull'></i>" + mobile_comm_getDic("lbl_task_task") + "("+taskList.length+")"); //업무
	}
					
	$.each(taskList, function(idx,obj){
		var isOwner = (obj.RegisterCode==userCode || obj.OwnerCode == userCode)? "Y":"N";

		listHTML += '<li class="task_link">';
		listHTML += '		<a onclick="javascript: mobile_task_viewTask(\''+obj.TaskID +'\', \''+obj.FolderID +'\', \''+ isOwner +'\', \'' + _mobile_task_list.IsMine + '\');">';
		listHTML += '			<i class="ico_task"></i>';
		if(obj.IsDelay=="Y"){ //지연 여부
			listHTML += '		<span class="ico_point"></span>';
		}
		listHTML += '			<p class="tx">';
		listHTML += '				<span class="ti ellip">';
		listHTML += 					obj.Subject;
		listHTML += '				</span>'; 
		if(obj.IsRead=="N"){ //읽음 여부
			listHTML += '			<span class="newDot"></span>';
		}
		listHTML += '			</p>';
		if(obj.TaskState == "대기"){
			if(obj.TaskProgress == ""){
				listHTML += '		<p class="state">' + mobile_comm_getDic("lbl_inactive") + '</p>'; //대기
			}else{			
				listHTML += '		<p class="state">' + mobile_comm_getDic("lbl_inactive") + '('+ obj.TaskProgress + '%)' + '</p>';
			}
		} else if(obj.TaskState == "진행중"){
			if(obj.TaskProgress == ""){
				listHTML += '		<p class="state ing">' + mobile_comm_getDic("lbl_Progressing") + '</p>'; //진행중
			}else{
				listHTML += '		<p class="state ing">' + mobile_comm_getDic("lbl_Progressing") + '('+ obj.TaskProgress + '%)' + '</p>';
			}
		} else{
			listHTML += '		<p class="state complete">' + mobile_comm_getDic("lbl_Completed") + '</p>'; //완료
		}
		listHTML += '		</a> ';
		listHTML += '</li> ';
		
	});
	
	return listHTML;
}

//TODO : 더보기 클릭
function mobile_task_nextlist () {
	if (!_mobile_task_list.EndOfList) {
		_mobile_task_list.Page++;

		mobile_task_getList(_mobile_task_list);
    } else {
        $('#task_list_more').css('display', 'none');
    }
}

//검색 클릭
function mobile_task_clicksearch() {
	_mobile_task_list.SearchText = $('#mobile_search_input').val();
	mobile_task_getList(_mobile_task_list);
}

//새로고침 클릭
function mobile_task_clickrefresh(pFolderID) {
	_mobile_task_list.Page = 1;
	_mobile_task_list.SearchText = '';
	$('#mobile_search_input').val('');
	
	mobile_task_getList(_mobile_task_list);
}

//추가 클릭
function mobile_task_clickwrite(pType) {
	var sUrl = "/groupware/mobile/task/write.do";
	sUrl += "?mode=add";
	sUrl += "&type=" + pType;
	sUrl += "&isowner=" + _mobile_task_list.IsMine;
	sUrl += "&pfid=" + _mobile_task_list.FolderID;
		
	mobile_comm_go(sUrl, "Y");
}

//이동 클릭
function mobile_task_clickmove(pType, pTargetID, pFolderID, pIsMine){
	var sUrl = "/groupware/mobile/task/move.do";
	sUrl += "?type=" + pType;
	sUrl += "&targetid=" + pTargetID;
	sUrl += "&folderid=" + pFolderID;
	sUrl += "&ismine=" + pIsMine;
		
	mobile_comm_go(sUrl);
}

//삭제 클릭
function mobile_task_clickdelete(pType, pTargetID){
	var url = "";
	var params = null;
	
	if(pType == "F"){
		url = "/groupware/mobile/task/deleteFolderData.do";
		params = {
			"FolderID": pTargetID,
		};
	} else if(pType == "T"){
		url = "/groupware/mobile/task/deleteTaskData.do";
		params = {
			"TaskID": pTargetID,
		};
	}
	
	$.ajax({
		type: "POST",
		url: url,
		data: params, 
		success : function(data){
			if(data.status=='SUCCESS'){
				alert(mobile_comm_getDic("msg_deleteSuccess")); //성공적으로 삭제하였습니다.
				if(pType == "T"){
					mobile_comm_back();
				}
				mobile_task_getTreeData('list');
				mobile_task_getList(_mobile_task_list);
			}else{
				alert(mobile_comm_getDic("msg_ErrorOccurred")); //오류가 발생하였습니다.
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//설정 클릭 
function mobile_task_clickmodify(pType, pTargetID, pIsOwner, pParentFolderID){
	
	if(pIsOwner == "Y") {
		alert(mobile_comm_getDic("msg_board_donotSaveInlineImage")); ////수정 시 본문의 인라인 이미지는 저장되지 않습니다.
	}
			
	var sUrl = "/groupware/mobile/task/write.do";
	sUrl += "?mode=modify";
	sUrl += "&type=" + pType;
	sUrl += "&isowner=" + pIsOwner;
	sUrl += "&pfid=" + pParentFolderID;
	sUrl += "&targetid=" + pTargetID;
		
	mobile_comm_go(sUrl, "Y");
}

//폴더 트리 클릭
function mobile_task_changeFolder(pFolderID, pParentType) {
	
	if(pFolderID == undefined && pParentType == undefined){
		_mobile_task_list.FolderID = _mobile_task_list.ParentFolderID;
		if(_mobile_task_list.FolderID == "") _mobile_task_list.FolderID = "0";
	} else if(pFolderID != undefined && pParentType != undefined){
		if(pParentType == "with"){
			_mobile_task_list.IsMine = "N";
		} else if(pParentType == "my") {
			_mobile_task_list.IsMine = "Y";
		}
		_mobile_task_list.FolderID = pFolderID;
	} else {
		_mobile_task_list.FolderID = pFolderID;
	}
	
	_mobile_task_list.Page = 1;
	_mobile_task_list.SearchText = '';
	$('#mobile_search_input').val('');
	
	mobile_task_getList(_mobile_task_list);
}

//업무 조회 클릭 
function mobile_task_viewTask(pTaskID, pFolderID, pIsOwner, pIsMine){
	var sUrl = "/groupware/mobile/task/view.do";
	sUrl += "?taskid=" + pTaskID;
	sUrl += "&folderid=" + pFolderID;
	sUrl += "&isowner=" + pIsOwner;
	sUrl += "&ismine=" + pIsMine;
		
	mobile_comm_go(sUrl, "Y");
}

//UI 이벤트 처리
function mobile_task_clickUiSetting(pObj, pClass){
	if($(pObj).hasClass(pClass)) {
		$(pObj).removeClass(pClass);
	} else {
		$(pObj).addClass(pClass);
	}
}

//확장메뉴 show or hide
function mobile_task_showORhide(obj) {
	if($(obj).parent().hasClass("show")) {
		$(obj).parent().removeClass("show");
	} else {
		$(obj).parent().addClass("show");
	}
}

function mobile_task_toggleList(pType){	
	var oTarget = $("#task_list_"+pType+"list");		
	var oTarget2 = $("#task_list_"+pType+"Cnt").find("i");
	
	if($(oTarget2).hasClass("upper")){
		$(oTarget2).removeClass("upper").css("background-position","");
		$(oTarget).show();			
	}else{
		$(oTarget2).addClass("upper").css("background-position","0 0");
		$(oTarget).hide();		
	}			
}
//업무 - 목록 끝










/*!
 * 
 * 폴더/업무 작성
 * 
 */

var _mobile_task_write = {
		
	Mode: 'add',					//add-추가, modify-수정
	Type: 'F',							//F-폴더, T-업무
	TargetID: '',						//수정 대상 ID
	IsOwner: '',						//소유자 체크
	ParentFolderID: '',				//부모 폴더ID
	HaveModifyAuth: '',			//수정권한 (추가시, 수정 시 등록자 또는 소유자일 경우)
	ParentInfoObj: null			//부모 폴더 정보
};

function mobile_task_WriteInit(){	
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('mode', "task_write_page") != 'undefined' || mobile_comm_getQueryString('mode', "task_write_page").toLowerCase() != 'add') {
		_mobile_task_write.Mode = mobile_comm_getQueryString('mode', "task_write_page");
		_mobile_task_write.HaveModifyAuth = ''; //임시값
	} else {
		_mobile_task_write.Mode = 'add';
		_mobile_task_write.HaveModifyAuth = 'Y'; //임시값
	}
	if (mobile_comm_getQueryString('type', "task_write_page") != 'undefined') {
		_mobile_task_write.Type = mobile_comm_getQueryString('type', "task_write_page");
	} else {
		_mobile_task_write.Type = 'F';
	}
	if (mobile_comm_getQueryString('targetid', "task_write_page") != 'undefined') {
		_mobile_task_write.TargetID = mobile_comm_getQueryString('targetid', "task_write_page");
	} else {
		_mobile_task_write.TargetID = '0';
	}
	if (mobile_comm_getQueryString('isowner', "task_write_page") != 'undefined' || mobile_comm_getQueryString('isowner', "task_write_page").toLowerCase() != 'n') {
		_mobile_task_write.IsOwner = mobile_comm_getQueryString('isowner', "task_write_page");
		if(_mobile_task_write.IsOwner == 'Y' || _mobile_task_write.Mode == 'add'){
			_mobile_task_write.HaveModifyAuth = 'Y'; //확정값
		} else {
			_mobile_task_write.HaveModifyAuth = 'N'; //확정값
		}
	} else {
		_mobile_task_write.IsOwner = 'N';
		if(_mobile_task_write.Mode != 'add') {
			_mobile_task_write.HaveModifyAuth = 'N'; //확정값
		}
	}
	if (mobile_comm_getQueryString('pfid', "task_write_page") != 'undefined') {
		_mobile_task_write.ParentFolderID = mobile_comm_getQueryString('pfid', "task_write_page");
	} else {
		_mobile_task_write.ParentFolderID = '0';
	}
	mobile_task_SetWriteDateTimeSelectBox();
	
	// 2. 기본 Display 설정
	mobile_task_writeInitDisplay();
	
	// 3. 기본데이터 및 수정데이터 셋팅
	if(_mobile_task_write.Mode == "add"){
		mobile_task_setParentFolderData(_mobile_task_write.ParentFolderID); //상위 폴더 정보에 따른 값 세팅
		//$("#task_write_save").text(mobile_comm_getDic("btn_register")); //등록
		$("#task_write_save, #task_write_btnCoowner").show();
		if(_mobile_task_write.Type == 'T'){//업무
			mobile_comm_uploadhtml();
		}
	} else {
		if(_mobile_task_write.Type == 'F'){	//폴더
			mobile_task_setFolderData();
		} else { //업무
			mobile_task_setTaskData(_mobile_task_write.TargetID, _mobile_task_write.ParentFolderID);
			$("#task_write_save").show();
		}
		//$("#task_write_save").text(mobile_comm_getDic("btn_Modify")); //수정
	}
	
	// 4. datepicker
	$( ".input_date" ).datepicker({
		dateFormat : 'yy/mm/dd',
		dayNamesMin : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
	});
}

//폴더/업무 작성 - 기본 Display 설정
function mobile_task_writeInitDisplay(){
	
	// 1. Title 변경
	if(_mobile_task_write.Mode == "add") {
		$("#task_write_mode").html(mobile_comm_getDic("lbl_Write")); //작성
	} else if(_mobile_task_write.HaveModifyAuth == "Y") {
		$("#task_write_mode").html(mobile_comm_getDic("lbl_Modify")); //수정
	} else {
		$("#task_write_mode").html(mobile_comm_getDic("lbl_Views")); //조회
	}
	
	// 2. 현재 Location 설정
	var sHtml = "<li><span></span></li>";
	$(".task_loc_list").html(mobile_task_getCurrentFolderLocation('write', _mobile_task_write.ParentFolderID) + sHtml);
	
	// 3. 폴더/업무 타입에 따른 display 설정
	mobile_task_setWriteTypeDisplay();
}

//입력 Type 변경(F-폴더, T-업무)
function mobile_task_changeWriteType(){
	_mobile_task_write.Type = $("#task_write_type").val();
	mobile_task_setWriteTypeDisplay();
}

//폴더/업무 타입에 따른 display 설정
function mobile_task_setWriteTypeDisplay(){
	if(_mobile_task_write.Type == 'F'){
		$("#task_write_descriptionFolder").parent().show();
		$("#task_write_personFolder").show();
		
		$("#task_write_descriptionTask").parent().hide();
		$("#task_write_personTask").hide();
		
		$(".task_loc_list li span").removeClass().addClass("ico_folder");		
		
		$("#task_write_date").hide();
		
		$("#task_write_subject").attr("placeholder",mobile_comm_getDic("msg_apv_ValidationBizDocName"));		
	} else {
		$("#task_write_descriptionFolder").parent().hide();
		$("#task_write_personFolder").hide();
		
		$("#task_write_descriptionTask").parent().show();
		$("#task_write_personTask").show();
		
		$(".task_loc_list li span").removeClass().addClass("ico_task");		
		
		$("#task_write_date").show();
		
		$("#task_write_subject").attr("placeholder",mobile_comm_getDic("msg_Common_12"));
	}
}

//수정 모드 - 데이터 가져오기(폴더)
function mobile_task_setFolderData(){
	var folderObj = mobile_task_getFolderData(_mobile_task_write.TargetID);
	
	mobile_task_setFolderDataBind(folderObj.folderInfo); //폴더 정보를 input 또는 p태그에 바인딩
	mobile_task_setMember("Folder", _mobile_task_write.HaveModifyAuth, folderObj.shareMemberList);
}

//수정 모드 - 데이터 가져오기(업무)
function mobile_task_setTaskData(pTaskID, pFolderID){
	var taskObj = mobile_task_getTaskData(pTaskID, pFolderID);
	
	mobile_task_setTaskDataBind(taskObj.taskInfo); //업무 정보를 input 또는 p태그에 바인딩
	mobile_task_setMember("Performer", _mobile_task_write.HaveModifyAuth, taskObj.performerList);
	mobile_comm_uploadhtml(taskObj.fileList);
}

//수정 모드 - 데이터 바인딩(폴더)
function mobile_task_setFolderDataBind(folderObj){
	$("#task_write_subject").val(folderObj.DisplayName);
	$("#task_write_progress").val(folderObj.State);
	$("#task_write_descriptionFolder").val(folderObj.Description);
	$("#task_write_progressPercent").val(folderObj.Progress);
	
	var bEditable = true; //수정이 불가능한 경우disabled, readonly 처리
	if(_mobile_task_write.HaveModifyAuth == "Y"){ //수정이 가능한 경우 write 요소에 바인딩
		bEditable = false;
		$("#task_write_save, #task_write_btnCoowner").show();
	}
	
	$("#task_write_subject").attr("readonly", bEditable);
	$("#task_write_progress").attr("disabled", bEditable);
	$("#task_write_descriptionFolder").attr("readonly", bEditable);
	$("#task_write_progressPercent").attr("readonly", bEditable);
}

//수정 모드 - 데이터 바인딩(업무)
function mobile_task_setTaskDataBind(taskObj){
	$("#task_write_subject").val(taskObj.Subject);
	$("#task_write_startdate").val(mobile_comm_replaceAll(taskObj.StartDate.split(" ")[0], '-', '/'));
	$("#task_write_enddate").val(mobile_comm_replaceAll(taskObj.EndDate.split(" ")[0], '-', '/'));
	$("#task_write_starttime").val(taskObj.StartDate.split(" ")[1]);
	$("#task_write_endtime").val(taskObj.EndDate.split(" ")[1]);
	
	$("#task_write_progress").val(taskObj.TaskStateCode);
	$("#task_write_descriptionTask").html(taskObj.Description);
	$("#task_write_progressPercent").val(taskObj.Progress);
}

//폴더 정보 조회
function mobile_task_getFolderData(folderID){
	var returnData; 
	
	var url = "/groupware/mobile/task/getFolderData.do";
	$.ajax({
		url: url,
		type:"POST",
		async: false,
		data : {
			"FolderID" : folderID
		},
		success:function(data){
			returnData =  data;
		},error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	return returnData;
}

//이메일 추가
function mobile_task_clickAddEmail(obj){	
	obj = $(obj).siblings('div');
	
	var sHtml = "";
	var sEmailTxt = $(obj).find("input[name=task_write_emailtxt]").val();
	
	if(sEmailTxt != ""){
		sHtml += "<a onclick=\"mobile_task_delUser(this, 'Task');\" class=\"btn_add_person\" code='" + sEmailTxt + "' type='UR'>";
		sHtml += 		sEmailTxt; 
		sHtml += "</a>";
		
		$(obj).parent().siblings("div.joins_a").append(sHtml).show();		
		$(obj).find("input[name=task_write_emailtxt]").val('');
	}
	
}

//상위 폴더 정보 조회 (공유자 정보는 상위에 속하는 모든 폴더에서 조회)
function mobile_task_setParentFolderData(parentFolderID){
	$.ajax({
		url:"/groupware/mobile/task/getParentFolderData.do",
		type:"POST",
		data : {
			"ParentFolderID" : parentFolderID,
			"isMine": "Y" //폴더 추가시 상위 정보는 최상위일 경우 무조건 Y
		},
		success:function(data){
			_mobile_task_write.ParentInfoObj = data.folderData;
			mobile_task_setMember("Folder", _mobile_task_write.HaveModifyAuth, data.shareMemberList);
		}
	});
}

//공유자or 수행자 HTML 그리기
function mobile_task_setMember(target, haveModifyAuth, memberList, pMode){
	var listHTML = '';
	var haveDup = false; //중복 요소 체크
	var mode = pMode == undefined ? "write" : pMode;	//조회/작성 모드 여부
	var rTarget = target;
	if(rTarget == "Performer" && mode == "write") {
		rTarget = "Task";
	}
	
	$.each(memberList,function(idx,obj){
		if(mode == "write"){
			if($("#task_" + mode + "_person"+rTarget).find("div.joins_a > a[code='"+ obj.Code +"'][type='"+ obj.Type +"']").length > 0 ){
				haveDup = true;
				return true; //continue;
			}
		} else {
			if($("#task_" + mode + "_person"+rTarget).find("dd.name_list_wrap>a[code='"+ obj.Code +"'][type='"+ obj.Type +"']").length > 0 ){
				haveDup = true;
				return true; //continue;
			}
		}
		
		var sLink = "";
		if(haveModifyAuth == "Y" && mode == "write"){
			sLink = "mobile_task_delUser(this, '" + target + "');";
		}
	
		listHTML += "<a onclick=\"" + sLink + "\" class=\"btn_add_person\" code=\"" + obj.Code + "\" type=\"" + obj.Type + "\">"
		listHTML += 		mobile_comm_getDicInfo(obj.Name); 
		listHTML += "</a>";
		
	});
	
	if(listHTML != ''){
		if(mode == "write"){
			$("#task_" + mode + "_person"+rTarget).find("div.joins_a").append(listHTML).show();
			$("#task_" + mode + "_person"+rTarget).find(".tx").hide();
		} else {
			$("#task_" + mode + "_person"+rTarget).find("dd.name_list_wrap").append(listHTML).show();	
		}
	}
	
	if(haveDup){
		//alert(mobile_comm_getDic("msg_task_notDupAdd")); //특정 사용자 또는 그룹을 중복 추가할 수 없습니다.
	}
	
	if(mode == "view" || (haveModifyAuth == "N" && mode == "write")){
		if(mode == "write"){
			$("#task_" + mode + "_person"+rTarget +" div.joins_a").find("a.btn_add_person").each(function(i, user) {
				$(user).css("padding", "5px 10px 3px 10px").css("background", "#fff");
			});
		} else {
			$("#task_" + mode + "_person"+rTarget).find("dd.name_list_wrap a.btn_add_person").each(function(i, user) {
				$(user).css("padding", "5px 10px 3px 10px").css("background", "#fff");
			});	
		}
	}
}

//추가 및 수정 시 validation chk
function mobile_task_chekValidation(){
	if($("#task_write_subject").val() == ''){
		alert(mobile_comm_getDic("msg_028")); //제목을 입력하세요.
		return false;
	}else if($("#task_write_progress").val() == ''){
		alert(mobile_comm_getDic("msg_task_selectState")); //상태를 선택하세요.
		return false;
	}else if($("#task_write_personTask").find('.joins_a').find('a').length < 1 && _mobile_task_write.Type == "T"){
		alert(mobile_comm_getDic("msg_task_plzEnterPerformer")); //수행자를 선택하세요
		return false;
	}else if(_mobile_task_write.Type == "T"){
		if($("#task_write_startdate").val() == '' || $("#task_write_enddate").val() == ''){
			alert(mobile_comm_getDic("msg_task_enterSchedule")); //일정을 입력하세요.
			return false;
		} else if($("#task_write_startdate").val() > $("#task_write_enddate").val()){
			alert(mobile_comm_getDic("msg_bad_period")); //시작일이 종료일보다 클 수 없습니다.
			return false;
		} else{
			return true;
		}
	}else{
		return true;
	}
}

//저장
function mobile_task_save(){
	if(!mobile_task_chekValidation()){
		return; 
	}
	
	var url = "";
	var formData = new FormData();		// [Added][FileUpload]
	var mode = _mobile_task_write.Mode.toUpperCase()=="ADD" ? "I" : "U";

	if($("#task_write_progress").val() == 'Complete'){
		$("#task_write_progressPercent").val('100');
	}
	
	if(_mobile_task_write.Type == "F"){
		url = "/groupware/mobile/task/saveFolderData.do";
		formData.append("mode", mode);
		formData.append("folderStr", JSON.stringify(mobile_task_getFolderObj(mode)));
	} else {
		url = "/groupware/mobile/task/saveTaskData.do";
		formData.append("mode", mode);
		formData.append("taskStr", JSON.stringify(mobile_task_getTaskObj(mode)));
		formData.append("fileInfos", JSON.stringify(mobile_comm_uploadfilesObj.fileInfos));
	    for (var i = 0; i < mobile_comm_uploadfilesObj.files.length; i++) {
	    	if (typeof mobile_comm_uploadfilesObj.files[i] == 'object') {
	    		formData.append("files", mobile_comm_uploadfilesObj.files[i]);
	        }
	    }
	    formData.append("fileCnt", mobile_comm_uploadfilesObj.fileInfos.length);
	}
	
	
	$.ajax({
		url: url,
		type: 'post',
		data: formData,
		dataType: 'json',
		processData : false,
        contentType : false,
		success: function (res) {
			if(res.status=='SUCCESS'){
				mobile_task_getTreeData('list');
				mobile_task_getList(_mobile_task_list);
				mobile_comm_back();
						
				if(_mobile_task_write.Mode.toUpperCase() == "MODIFY") {
					// 저장 후 조회 창도 닫기(수정시)
					setTimeout("mobile_comm_back()", 1000);	
				}
			}else{
				alert(mobile_comm_getDic("msg_ErrorOccurred")); //오류가 발생하였습니다.
			}    	
			
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
}

//폴더 추가/수정 시 필요한 Data를 JSON 형식으로 생성
function mobile_task_getFolderObj(mode){
	var folderObj; 
	var userCode = mobile_comm_getSession("UR_Code").toLowerCase();
	
	if(mode.toUpperCase()=="I"){ //추가
		folderObj = { 
				  "ParentFolderID": _mobile_task_write.ParentFolderID,
				  "DisplayName": $("#task_write_subject").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />'),
				  "State": $("#task_write_progress").val(),
				  "Description": $("#task_write_descriptionFolder").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />'),
				  "RegistCode":  userCode,
				  "OwnerCode": _mobile_task_write.ParentInfoObj.OwnerCode == undefined ? userCode :  _mobile_task_write.ParentInfoObj.OwnerCode, //내가 하는 일 폴더는 ownerCode가 넘어오지 않음
				  "ShareMember": mobile_task_getMemberList("Folder"),
				  "Progress": $("#task_write_progressPercent").val()
				};
	}else if(mode.toUpperCase()=="U"){ //수정
		folderObj = {
				  "FolderID": _mobile_task_write.TargetID,
				  "ParentFolderID": _mobile_task_write.ParentFolderID,
				  "DisplayName": $("#task_write_subject").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />'),
				  "State": $("#task_write_progress").val(),
				  "Description": $("#task_write_descriptionFolder").val().split(' ').join('&nbsp;').replace(/(\r\n|\n|\n\n)/gi, '<br />'),
				  "ShareMember": mobile_task_getMemberList("Folder"),
				  "Progress": $("#task_write_progressPercent").val()
				};
	}
	
	return folderObj;
}

//공유자 목록 조회
function mobile_task_getMemberList(target){
	var arrMember = [];
	
	if(target.toUpperCase()=="FOLDER"){
		$("#task_write_personFolder div.joins_a").children("a").each(function(idx,obj){
			arrMember.push(	{
	           	 "Code": $(obj).attr("code"),
	           	 "Type": $(obj).attr("type")
			});
		});
	}else{
		$("#task_write_personTask div.joins_a").children("a").each(function(idx,obj){
			arrMember.push(	{
	           	 "PerformerCode": $(obj).attr("code"),
			});
		});
	}
	
	return arrMember;
}

//업무 추가/수정 시 필요한 Data를 JSON 형식으로 생성
function mobile_task_getTaskObj(mode){
	var taskObj; 
	var userCode = mobile_comm_getSession("UR_Code").toLowerCase();
	
	var startDateTime = CFN_TransServerTime($("#task_write_startdate").val().replaceAll("/","-") + " " + $("#task_write_starttime").val());
	var endDateTime = CFN_TransServerTime($("#task_write_enddate").val().replaceAll("/","-") + " " + $("#task_write_endtime").val());
	
	if(mode.toUpperCase()=="I"){ //추가
		taskObj = { 
				  "FolderID": _mobile_task_write.ParentFolderID,
				  "Subject": $("#task_write_subject").val(),
				  "State": $("#task_write_progress").val(),
				  "StartDate": startDateTime,
				  "EndDate":  endDateTime,
				  "InlineImage": "",
				  "Description": $("#task_write_descriptionTask").val(),
				  "RegisterCode": userCode,
				  "OwnerCode": _mobile_task_write.ParentInfoObj.OwnerCode == undefined ? userCode :  _mobile_task_write.ParentInfoObj.OwnerCode, //내가 하는 일 폴더는 ownerCode가 넘어오지 않음
				  "PerformerList": mobile_task_getMemberList("Performer"),
				  "Progress": isNull($("#task_write_progressPercent").val(),0)
				};
	}else if(mode.toUpperCase()=="U"){ //수정
		taskObj = {
				  "TaskID": _mobile_task_write.TargetID,
				  "FolderID": _mobile_task_write.ParentFolderID,
				  "Subject": $("#task_write_subject").val(),
				  "State": $("#task_write_progress").val(),
				  "StartDate": startDateTime,
				  "EndDate":  endDateTime,
				  "InlineImage": "",
				  "Description": $("#task_write_descriptionTask").val(),
				  "PerformerList": mobile_task_getMemberList("Performer"),
				  "Progress": isNull($("#task_write_progressPercent").val(),0)
				};
	}
	
	return taskObj;
}

//조직도 호출
function mobile_task_openOrg(target) {
	var sUrl = "/covicore/mobile/org/list.do";

	window.sessionStorage["mode"] = "Select";
	window.sessionStorage["multi"] = "Y";
	window.sessionStorage["callback"] = "mobile_task_setPerson" + target + "List();";
	
	mobile_comm_go(sUrl, 'Y');
}

//조직도 콜백 함수 - 공유자
function mobile_task_setPersonFolderList() {
	var dlObj = $("#task_write_personFolder div.joins_a");
	var userinfo = JSON.parse("[" + window.sessionStorage["userinfo"] + "]");
	var strDup = ";";
	var strHtml = "";
	var isDup = "N";
	
	$(dlObj).find('a').each(function(i){
		strDup += $(this).attr("code") + ";";
	});

	$(userinfo).each(function(i, user) {
		if(strDup.indexOf(";" + user.AN + ";") > -1) {
			isDup = "Y";
			return false;
		}
		var type = user.itemType.toUpperCase() == "USER" ? "UR" : (user.AN == user.CompanyCode ? "CM": "GR" );
		strHtml += "<a onclick=\"mobile_task_delUser(this, 'Folder');\" class=\"btn_add_person\" code=\"" + user.AN + "\" type=\"" + type + "\" >" + mobile_comm_getDicInfo(user.DN) + "</a>";
	});

	if(isDup == "Y") {
		alert(mobile_comm_getDic("msg_task_notDupAdd"));
	} else {
		$(dlObj).append(strHtml).show();
		$(dlObj).parent().find(".tx").hide();
	}	
	
	window.sessionStorage["userinfo"] = null;
	$("#org_list_selecteditems").val('');
	
}
 
//공유자/수행자 - 사용자/부서 삭제
function mobile_task_delUser(obj, target) {
	$(obj).remove();
	
	var dlObj = $("#task_write_person" + target + " div.joins_a");
	if($(dlObj).find("a").length == 0) {
		$(dlObj).hide();
		$(dlObj).parent().find(".tx").show();
	}
}

//수행자 선택(공유자 리스트)
function mobile_task_openPersonFolderList(){
	var sUrl = "/groupware/mobile/task/sharedpersonlist.do";
	
	window.sessionStorage["TaskFolderID"] = _mobile_task_write.ParentFolderID;
	mobile_comm_go(sUrl, 'Y');
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
	mobile_comm_back();
}

//폴더/업무 - 작성 끝










/*!
 * 
 * 폴더/업무 이동
 * 
 */

var _mobile_task_move = {
	
	Type: 'moveFolder',	//moveFolder-폴더이동, moveTask-업무이동, copyTask-업무복사
	TargetID: '0', 			//옮겨져야하는 대상의 ID
	FolderID: '0', 			//옮겨져야하는 대상이 위치한 FolderID
	IsMine: 'N',				//업무 타입(Y - 내가하는일, N - 같이하는일) 
	
};

function mobile_task_MoveInit(){	
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('type', "task_move_page") != 'undefined') {
		_mobile_task_move.Type = mobile_comm_getQueryString('type', "task_move_page");
	} else {
		_mobile_task_move.Type = 'moveFolder';
	}
	if (mobile_comm_getQueryString('targetid', "task_move_page") != 'undefined') {
		_mobile_task_move.TargetID = mobile_comm_getQueryString('targetid', "task_move_page");
	} else {
		_mobile_task_move.TargetID = '0';
	}
	if (mobile_comm_getQueryString('folderid', "task_move_page") != 'undefined') {
		_mobile_task_move.FolderID = mobile_comm_getQueryString('folderid', "task_move_page");
	} else {
		_mobile_task_move.FolderID = '0';
	}
	if (mobile_comm_getQueryString('ismine', "task_move_page") != 'undefined') {
		_mobile_task_move.IsMine = mobile_comm_getQueryString('ismine', "task_move_page");
	} else {
		_mobile_task_move.IsMine = 'N';
	}
	
	// 2. btn 이벤트 연결 및 title 설정
	$("#task_move_save").attr("href", "javascript: mobile_task_" + _mobile_task_move.Type + "();");
	if(_mobile_task_move.Type == "copyTask"){
		$("#task_move_mode").text(mobile_comm_getDic("btn_Copy")); //복사
	}
	
	// 3. 현재 Location 설정
	var sHtml = "<li><span class='ico_folder'></span></li>";
	$(".task_loc_list").html(mobile_task_getCurrentFolderLocation('move', _mobile_task_move.FolderID) + sHtml);
	
	// 4. 트리 목록 가져오기
	//setTimeout(function () {
		mobile_task_getTreeData('move');
		//맨 처음 radio 체크
		$("#task_move_topmenu :radio:first").attr("checked", "checked");
		$("#task_move_topmenu :radio").checkboxradio("refresh");
		//자기 자신 및 하위 가리기(이동 불가능한 영역)
		$("#task_move_topmenu :radio[value=" + _mobile_task_move.TargetID + "]").parent("div").parent("li").hide();
    //}, 100);
}

// 폴더 이동 
function mobile_task_moveFolder(){
	var url = "/groupware/mobile/task/moveFolder.do";
	$.ajax({
		type: "POST",
		url: url,
		data:{
			"FolderID": _mobile_task_move.TargetID,
			"targetFolderID": $("#task_move_topmenu :radio:checked").val()
		}, 
		success : function(data){
			if(data.status=='SUCCESS'){
				if(data.isHaveShareChild=="Y"){
					alert(mobile_comm_getDic("msg_task_shareFolderNotMove")); //해당 폴더 또는 하위 항목에 공유 폴더가 있을 경우 이동이 불가합니다.
				}else if(data.chkDuplilcation.isDuplication=="Y"){
					alert(mobile_comm_getDic("msg_task_renameFolder").replace("{0}", data.chkDuplilcation.saveName)); //이동 위치에 동일한 이름의 폴더가 존재하여<br>[{0}]로 이름이 변경하였습니다.
					mobile_comm_back();
				}else{
					alert(mobile_comm_getDic("msg_task_completeMove")); //이동 되었습니다.
					mobile_comm_back();
				}	
			}else{
				alert(mobile_comm_getDic("msg_ErrorOccurred")); //오류가 발생하였습니다.
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//리스트로 이동
function mobile_task_goToList(pFolderID, pIsMine){
	var sUrl = "/groupware/mobile/task/list.do";
	
	if(pFolderID != null & pFolderID != undefined & pFolderID != ""){
		sUrl += "?folderid=" + pFolderID;
	}
	if(pIsMine != null & pIsMine != undefined & pIsMine != ""){
		sUrl += (sUrl.indexOf("?") > -1 ? "&" : "?") + "ismine=" + pIsMine;
	}
	
	mobile_comm_go(sUrl);	
}

//업무 이동
function mobile_task_moveTask(){
	var url = "/groupware/mobile/task/moveTask.do";
	$.ajax({	
		type: "POST",
		url: url,
		data:{
			"TaskID": _mobile_task_move.TargetID,
			"targetFolderID": $("#task_move_topmenu :radio:checked").val()
		}
		, success : function(data){
			if(data.status=='SUCCESS'){
				if(data.chkDuplilcation.isDuplication=="Y"){
					alert(mobile_comm_getDic("msg_task_moveRenameTask").replace("[{0}]", ("\n[" + data.chkDuplilcation.saveName + "]"))); //이동 위치에 동일한 이름의 업무가 존재하여<br>[{0}]로 이름이 변경되었습니다.
					mobile_comm_back();
				}else{
					alert(mobile_comm_getDic("msg_task_completeMove")); //이동 되었습니다.
					mobile_comm_back();
					mobile_task_clickrefresh();
				}	
			}else{
				alert(mobile_comm_getDic("msg_ErrorOccurred")); //오류가 발생하였습니다.
			}
		}
		,error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
       	}
	});
}

//업무 복사
function mobile_task_copyTask(){
	var url = "/groupware/mobile/task/copyTask.do";
	$.ajax({
		type: "POST",
		url: url,
		data:{
			"TaskID": _mobile_task_move.TargetID,
			"targetFolderID": $("#task_move_topmenu :radio:checked").val()
		}
		, success : function(data){
			if(data.status=='SUCCESS'){
				if(data.chkDuplilcation.isDuplication=="Y"){
					alert(mobile_comm_getDic("msg_task_copyRenameTask").replace("{0}", data.chkDuplilcation.saveName).replace("<br>", "\n")); //복사 위치에 동일한 이름의 업무가 존재하여<br>[{0}]로 이름이 변경되었습니다.					
					mobile_comm_back();
				}else{
					alert(mobile_comm_getDic("msg_task_completeCopy")); //복사 되었습니다.					
					mobile_comm_back();
					mobile_task_clickrefresh();
				}	
			}else{
				alert(mobile_comm_getDic("msg_ErrorOccurred")); //오류가 발생하였습니다.
			}
		}
		,error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
       	}
	});
}

//폴더/업무 이동 끝









/*!
 * 
 * 업무 상세보기
 * 
 */

var _mobile_task_view = {
		TaskID: '0',					//업무ID
		FolderID: '0',				//폴더ID
		HaveModifyAuth: 'N',	//수정권한 (추가시, 수정 시 등록자 또는 소유자일 경우)
		IsOwner: 'N',				//소유자 체크
		IsMine: 'N'					//업무 타입(Y - 내가하는일, N - 같이하는일)
};

function mobile_task_ViewInit(){	
	// 1. 파라미터 셋팅
	if (mobile_comm_getQueryString('taskid', "task_view_page") != 'undefined') {
		_mobile_task_view.TaskID = mobile_comm_getQueryString('taskid', "task_view_page");
	} else {
		_mobile_task_view.TaskID = '';
	}
	if (mobile_comm_getQueryString('folderid', "task_view_page") != 'undefined') {
		_mobile_task_view.FolderID = mobile_comm_getQueryString('folderid', "task_view_page");
	} else {
		_mobile_task_view.FolderID = '';
	}
	if (mobile_comm_getQueryString('isowner', "task_view_page") != 'undefined') {
		_mobile_task_view.IsOwner = mobile_comm_getQueryString('isowner', "task_view_page");
		_mobile_task_view.HaveModifyAuth = mobile_comm_getQueryString('isowner', "task_view_page");
	} else {
		_mobile_task_view.IsOwner = 'N';
		_mobile_task_view.HaveModifyAuth = 'N';
	}
	if (mobile_comm_getQueryString('ismine', "task_view_page") != 'undefined') {
		_mobile_task_view.IsMine = mobile_comm_getQueryString('ismine', "task_view_page");
	} else {
		_mobile_task_view.IsMine = 'N';
	}
	
	// 2. 현 업무 위치 표시
	//setTimeout(function () {
		$(".task_loc_list").html(mobile_task_getCurrentFolderLocation('view', _mobile_task_view.FolderID));
    //}, 100);

	// 3. 업무 조회
	//setTimeout(function () {
		//업무 정보 가져오기
		mobile_task_setTaskViewData(_mobile_task_view.TaskID, _mobile_task_view.FolderID);
    //}, 100);
}

//업무 정보 셋팅
function mobile_task_setTaskViewData(taskID, folderID){
	//정보 가져오기
	var taskObj = mobile_task_getTaskData(taskID, folderID);
	
	//폴더 정보를 바인딩
	mobile_task_setTaskViewDataBind(taskObj.taskInfo); 
	
	//수행자 표시
	mobile_task_setMember("Performer", _mobile_task_view.HaveModifyAuth, taskObj.performerList, "view");
	
	//댓글 및 좋아요
	mobile_comment_getCommentLike('Task', _mobile_task_view.TaskID , 'N');

	//첨부처리
	$('#task_view_attach').html(mobile_comm_downloadhtml(taskObj.fileList));
	
	//버튼 세팅
	if(_mobile_task_view.HaveModifyAuth=="Y"){
		var sHtml = "";
		
		sHtml += '<li><a href="javascript: mobile_task_clickmodify(\'T\', \'' + _mobile_task_view.TaskID + '\', \'' + _mobile_task_view.IsOwner + '\', \'' + _mobile_task_view.FolderID + '\');" class="btn" >' + mobile_comm_getDic("btn_Setting") + '</a></li>'; //설정
		sHtml += '<li><a href="javascript: mobile_task_clickdelete(\'T\', \'' + _mobile_task_view.TaskID + '\');" class="btn" >' + mobile_comm_getDic("btn_delete") + '</a></li>'; //삭제 
		
		if(taskObj.taskInfo.OwnerCode.toUpperCase() == mobile_comm_getSession("UR_Code").toUpperCase()){
			sHtml += '<li><a href="javascript: mobile_task_clickmove(\'copyTask\', \'' + _mobile_task_view.TaskID + '\', \'' + _mobile_task_view.FolderID + '\', \'' + _mobile_task_view.IsMine + '\');" class="btn" >' + mobile_comm_getDic("btn_Copy") + '</a></li>'; //복사
			sHtml += '<li><a href="javascript: mobile_task_clickmove(\'moveTask\', \'' + _mobile_task_view.TaskID + '\', \'' + _mobile_task_view.FolderID + '\', \'' + _mobile_task_view.IsMine + '\');" class="btn" >' + mobile_comm_getDic("btn_Move") + ' </a></li>';//이동
		}
		
		$('#task_view_ulBtnArea').html(sHtml);
		$("#task_view_ulBtnArea").parents("div.dropMenu").show();
	}
}


//업무 정보 조회
function mobile_task_getTaskData(taskID, folderID){
	var returnData; 
	var url = "/groupware/mobile/task/getTaskData.do";
	
	$.ajax({
		url: url,
		type:"POST",
		async: false,
		data : {
			"TaskID" : taskID,
			"FolderID" : folderID
		},
		success:function(data){
			returnData =  data;
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	return returnData;
}

//조회한 업무 정보를 바인딩
function mobile_task_setTaskViewDataBind(taskObj){
	$("#task_view_registDate").text(mobile_comm_getDateTimeString("yyyy.MM.dd HH:mm", new Date(CFN_TransLocalTime(taskObj.RegistDate))));
	$("#task_view_register").text(taskObj.RegisterName);
	
	$("#task_view_subject").text(taskObj.Subject);
	$("#task_view_date").text(mobile_comm_replaceAll(CFN_TransLocalTime(taskObj.StartDate), '-', '.') + " ~ " + mobile_comm_replaceAll(CFN_TransLocalTime(taskObj.EndDate), '-', '.'));
	
	var sState = "";
	if (taskObj.TaskStateCode.toUpperCase() == "PROCESS"){
		sState = mobile_comm_getDic("lbl_Progressing"); //진행중
	} else if (taskObj.TaskStateCode.toUpperCase() == "COMPLETE"){
		sState = mobile_comm_getDic("lbl_Completed"); //완료
	} else {
		sState = mobile_comm_getDic("lbl_inactive"); //대기
	}
		
	$("#task_view_progress").text(sState);
	$("#task_view_description").html((taskObj.Description).replace(/ /gmi, "&nbsp;").replace(/(\r\n|\n|\r)/g,"<br />"));
	setTimeout(function () {
		mobile_comm_replacebodyinlineimg($('#task_view_description'));
		mobile_comm_replacebodylink($('#task_view_description'));
	}, 100);
}

//업무 - 상세보기 끝









/*!
 * 
 * 업무 공유자 리스트
 * 
 */

var _mobile_task_sharedperson = {
		FolderID: '0'	,			//폴더ID
		SearchWord: '',			//검색어	
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

function mobile_task_SharedPersonInit(){	
	// 1. 파라미터 셋팅
	if (window.sessionStorage["TaskFolderID"] != 'undefined') {
		_mobile_task_sharedperson.FolderID = window.sessionStorage["TaskFolderID"];
	} else {
		_mobile_task_sharedperson.FolderID = '';
	}
	
	//상단에 close 버튼 생기는 부분 방지
	$("div.sub_header").siblings("a.ui-icon-delete").remove();
	
	// 2. 업무 조회
	//setTimeout(function () {
		//업무 공유자 리스트 가져오기
		mobile_task_getSharedPersonList(_mobile_task_sharedperson);
    //}, 100);
}

//업무 공유자 리스트 가져오기
function mobile_task_getSharedPersonList(params){
	
	var url = "/groupware/mobile/task/getShareUseList.do";
	var paramdata = {
		FolderID : params.FolderID,
		searchWord: params.SearchWord,
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
				_mobile_task_sharedperson.TotalCount = response.page.listCount;
				
				var sHtml = "";
				sHtml = mobile_task_getSharedPersonListHtml(response.list);
				
				if(params.Page == 1 || sHtml.indexOf("no_list") > -1) {
					$('#task_sharedperson_list').html(sHtml).trigger('create');
				} else {
					$('#task_sharedperson_list').append(sHtml).trigger( "create" );
				}
				
				if (Math.min((_mobile_task_sharedperson.Page) * _mobile_task_sharedperson.PageSize, _mobile_task_sharedperson.TotalCount) == _mobile_task_sharedperson.TotalCount) {
					_mobile_task_sharedperson.EndOfList = true;
	                $('#task_sharedperson_more').hide();
	            } else {
	                $('#task_sharedperson_more').show();
	            }
			}
		},
		error: function (response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});	
}

function mobile_task_getSharedPersonListHtml(targetList)
{
	var sHtml = "";
	if(targetList.length > 0) {
		$(targetList).each(function (i, obj){
			sHtml += "<li class=\"staff\">";
			sHtml += "		<a href=\"#\" class=\"con_link\">";
			sHtml += "			<span class=\"photo\" style=\"background-image: url('" + mobile_comm_noimg(obj.PhotoPath) + "'), url('" + mobile_comm_noperson() + "')\"></span>";
			sHtml += "			<div class=\"info\">";
			sHtml += "				<p class=\"name\">" + (obj.Name=="" ? "-" : obj.Name) + "</p>";
			sHtml += "				<p class=\"detail\">";
			sHtml += "					<span>" + obj.DeptName + "</span>";
			sHtml += "				</p>";
			sHtml += "			</div>";
			sHtml += "		</a>";
			sHtml += "		<div class=\"check\">";
			sHtml += "			<div class=\"ui-checkbox\">";
			sHtml += "   			<input type=\"checkbox\" name=\"" + (obj.Name=="" ? "-" : obj.Name) + "\" code=\"" + obj.Code + "\" id=\"task_sharedperson_selectuser_" + obj.Code + "\" \">";
			sHtml += "   			<label for=\"task_sharedperson_selectuser_" + obj.Code + "\"></label>";
			sHtml += "			</div>";
			sHtml += "		</div>";
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

//공유자 더보기 클릭
function mobile_task_sharedperson_nextlist() {
	if (!_mobile_task_sharedperson.EndOfList) {
		_mobile_task_sharedperson.Page++;

		mobile_task_getSharedPersonList(_mobile_task_sharedperson);
		
    } else {
        $('#task_sharedperson_more').css('display', 'none');
    }
}

//공유자 선택 시, 값 넣기
function mobile_task_setSelectedPerson(){
	var sHtml = "";
	var sCodeExist = "";
	var bIsDup = false;
	
	$("#task_write_personTask").find("div.joins_a a").each(function(idx,obj){
		sCodeExist += $(obj).attr("code") + ";";
	});
	
	$("#task_sharedperson_list input[type=checkbox]").each(function(idx,obj){
		if($(obj).is(":checked")){
			if(sCodeExist.indexOf($(obj).attr("code")) > -1){
				bIsDup = true;
				return false;
			} else {
				sHtml += "<a onclick=\"mobile_task_delUser(this, 'Task');\" class=\"btn_add_person\" code='" + $(obj).attr("code") + "' type='UR'>";
				sHtml += 		$(obj).attr("name");
				sHtml += "</a>";
			}
		}
	});
	
	if(bIsDup == true){
		alert(mobile_comm_getDic("msg_task_alreadyPerformer")); //이미 중복된 수행자가 존재합니다.
		return false;
	} else {
		$("#task_write_personTask").find("div.joins_a").append(sHtml);
		if(sHtml != ""){
			$("#task_write_personTask").find("div.joins_a").show();
			$("#task_write_personTask").find(".tx").hide();
		}
	}
	
	//dialog 창 닫기
	mobile_comm_back();
	
	_mobile_task_sharedperson.SearchWord = '';
}

//체크박스 ui 처리
function mobile_task_setCheckedArea(pCode){
	var bDisplay = false;
	if($("#task_sharedperson_selectuser_" + pCode).is(":checked")) {
		bDisplay = true;
	}
	$("#task_sharedperson_selectuser_" + pCode).prop("checked", bDisplay).checkboxradio('refresh');
}

//검색 클릭
function mobile_task_clickSharedPersonSearch(){	
	_mobile_task_sharedperson.SearchWord = $("#task_sharedperson_page").find("#task_search_shared").val();
	mobile_task_getSharedPersonList(_mobile_task_sharedperson);
}

//빈값 체크
function isNull(value, defaultValue){
	if(typeof value == 'undefined' || value == null || value == 'undefined' || value == ''){
		return defaultValue;
	}
	return value;
}


//시작일시/종료일시 Validation Check
function mobile_task_chkDateValidation(from) {
	
	//날짜 입력값 유효성 검사 추가
	if(from == "SD" || from == "ED") {
		try {
			var	dtCheck = new Date($("#task_write_startdate").val().substring(5,7)+'/'+$("#task_write_startdate").val().substring(8,10)+'/'+$("#task_write_startdate").val().substring(0,4)+' 00:00:00');
			if(from == "ED") {
				dtCheck = new Date($("#task_write_enddate").val().substring(5,7)+'/'+$("#task_write_enddate").val().substring(8,10)+'/'+$("#task_write_enddate").val().substring(0,4)+' 00:00:00');
			}
			if((dtCheck.getDate() + "") == "NaN") {
				alert(mobile_comm_getDic("msg_InValidDateInput"));		//날짜 입력값이 잘못 되었습니다.
				
				if(from == "SD") {
					var date = new Date();
					if (mobile_comm_getQueryString('date', 'task_write_page') != 'undefined') {
						date = new Date(mobile_task_ReplaceDate(mobile_comm_getQueryString('date', 'task_write_page')));
					}
					$("#task_write_startdate").val(mobile_task_SetDateFormat(date, '.'));
				} else if(from == "ED") {
					$("#task_write_enddate").val($("#task_write_startdate").val());
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
		if($("#task_write_startdate").val() > $("#task_write_enddate").val()){
			$("#task_write_enddate").val($("#task_write_startdate").val());
		}
		
		if($("#task_write_startdate").val() == $("#task_write_enddate").val() && $("#task_write_starttime").val() > $("#task_write_endtime").val()) {
			$("#task_write_endtime").val($("#task_write_starttime").val());
		}
	} else if(from == "ED"){
		if($("#task_write_startdate").val() > $("#task_write_enddate").val()){
			$("#task_write_startdate").val($("#task_write_enddate").val());
		}
		
		if($("#task_write_startdate").val() == $("#task_write_enddate").val() && $("#task_write_starttime").val() > $("#task_write_endtime").val()) {
			$("#task_write_starttime").val($("#task_write_endtime").val());
		}
	} else if(from == "ST"){
		if($("#task_write_startdate").val() >= $("#task_write_enddate").val()){
			if($("#task_write_starttime").val() > $("#task_write_endtime").val()){
				$("#task_write_endtime").val($("#task_write_starttime").val());
			}
		}
	} else if(from == "ET"){
		if($("#task_write_startdate").val() >= $("#task_write_enddate").val()){
			if($("#task_write_starttime").val() > $("#task_write_endtime").val()){
				$("#task_write_starttime").val($("#task_write_endtime").val());
			}
		}
	}
}

//날짜 형식 바꿈
function mobile_task_ReplaceDate(dateStr) {

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

//날짜 포멧 변환
function mobile_task_SetDateFormat(pDate, pType) {
  var formattedDate = '';
  var date = new Date(mobile_task_ReplaceDate(pDate));
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

//일시 바인딩
function mobile_task_SetWriteDateTimeSelectBox(){
	
	var oTodate = CFN_GetLocalCurrentDate('yyyy/MM/dd');
	
	//일시 > date
	if(mobile_comm_getQueryString('mode', "task_write_page").toLowerCase() == 'add'){
		$("#task_write_startdate").val(oTodate);
		$("#task_write_enddate").val(oTodate);
	}
	
	//일시 > time
	var sTimeHtml = "";
	for(var i=0; i<24; i++){
		for(var j=0; j<60; j+=30){
			sTimeHtml += "<option value='" + (i<10 ? "0"+i : i) + ":" + (j<10 ? "0"+j : j) + "'>" + (i<10 ? "0"+i : i) + ":" + (j<10 ? "0"+j : j) + "</option>";
		}
	}
	$("#task_write_starttime").html(sTimeHtml);
	$("#task_write_endtime").html(sTimeHtml);
	$("#task_write_endtime").append("<option value='23:59'>23:59</option>");
	
	if(mobile_comm_getQueryString('mode', "task_write_page").toLowerCase() == 'add'){
		$("#task_write_starttime").val("00:00");
		$("#task_write_endtime").val(mobile_comm_AddFrontZero(parseInt("00:00") + 1, 2) + ":00");
	}	
}

// 종일 설정
function mobile_task_chkAllDay() {
	
	var sStartDate = "";
    var sStartTime = "";
    var sEndDate = "";
    var sEndTime = "";
	
	if($("#task_write_chkAllDay").is(":checked")) {
		//00:00 ~ 23:59분으로 설정
		sStartDate = $("#task_write_startdate").val();
        sStartTime = $("#task_write_starttime").val();
        sEndDate = $("#task_write_enddate").val();
        sEndTime = $("#task_write_endtime").val();

        $("#task_write_hidstartdate").val(sStartDate);
        $("#task_write_hidstarttime").val(sStartTime);
        $("#task_write_hidenddate").val(sEndDate);
        $("#task_write_hidendtime").val(sEndTime);
        
        $("#task_write_startdate").val(sStartDate);
        $("#task_write_enddate").val(sStartDate);
        $("#task_write_starttime").val("00:00");
        $("#task_write_endtime").val("23:59");
        
		//disabled true
		$("#task_write_startdate").attr("disabled", true);
		$("#task_write_starttime").attr("disabled", true);
		$("#task_write_enddate").attr("disabled", true);
		$("#task_write_endtime").attr("disabled", true);
        
	} else {
		//기존에 있던 값으로 재설정
        sStartDate = $("#task_write_hidstartdate").val();
        sStartTime = $("#task_write_hidstarttime").val();
        sEndDate = $("#task_write_hidenddate").val();
        sEndTime = $("#task_write_hidendtime").val();

        $("#task_write_startdate").val(sStartDate);
        $("#task_write_starttime").val(sStartTime);
        $("#task_write_enddate").val(sEndDate);
        $("#task_write_endtime").val(sEndTime);
        
		//disabled true
		$("#task_write_startdate").attr("disabled", false);
		$("#task_write_starttime").attr("disabled", false);
		$("#task_write_enddate").attr("disabled", false);
		$("#task_write_endtime").attr("disabled", false);
	}
}
//업무 - 공유자 리스트 끝
