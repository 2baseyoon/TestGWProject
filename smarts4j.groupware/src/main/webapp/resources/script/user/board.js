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
*
*	CHECK: 그리드 체크 항목 가져오는거, Ajax request 날리는 항목 공통으로 뺄 수 있을 것 같다.
*
*
*/
$.fn.serializeObject = function() {
    var obj = null;
    try {
        if ( this[0].tagName && this[0].tagName.toUpperCase() == "FORM" ) {
            var arr = this.serializeArray();
            if ( arr ) {
                obj = {};
                jQuery.each(arr, function() {
                    obj[this.name] = this.value;
                });             
            }//if ( arr ) {
        }
    }
    catch(e) {alert(e.message);}
    
    return obj;
};

//개별호출-일괄호출
var sessionObj = Common.getSession(); //전체호출

var g_userCode = sessionObj["USERID"];
//게시판 옵션 정보
var g_boardConfig = null;
var g_messageConfig = null;
var g_noticeMedia = Common.getBaseCode('NotificationMedia');		//base_code 테이블에서 알림매체 목록 조회
if(g_noticeMedia != undefined){
	g_noticeMedia = g_noticeMedia.CacheData;
} else {
	g_noticeMedia = "";
}

var g_urlHistory = sessionStorage.getItem("urlHistory");  // goFolderContents 함수 내부, BoardList.jsp 내부에서 현재 URL값 저장
var g_editorBody = ""; //본문 내용, 에디터 바인딩 시점 문제 해결을 위한 변수

var g_editorKind = Common.getBaseConfig('EditorType');
var g_enableChangeUserDifField = (Common.getBaseConfig('EnableChangeUserDifField') == '') ? 'N' : Common.getBaseConfig('EnableChangeUserDifField');

//문서관리에 사용되는 권한 아이콘
var viewIcon;
var modifyIcon;
var deleteIcon;
var arrCtrl = ["Line", "Space", "Button", "Label", "Image", "Help"];

var multiFolderType; // 문서관리 다중분류

var board = {
	//padding zero 월,일,시,분,초를 두자리수로 보여줌
	pad : function(n){
		return n<10 ? '0'+n : n
	},
	
	//date format처리 YYYY-MM-DD hh:mm:ss
	dateString : function( pDate ){
		var year = pDate.getFullYear();
		if (year < 1000){
		     year+=1900;
		}
		var day = pDate.getDate();
		var month=(pDate.getMonth()+1);
		var hour = pDate.getHours();
		var min = pDate.getMinutes();
		var sec = pDate.getSeconds();
		var currentTime = year + "-" + board.pad(month) + "-" + board.pad(day) + " " + board.pad(hour) + ":" + board.pad(min) + ":" + board.pad(sec);
		return currentTime;
	},
	
	dateTime: function( pDate, pTime ){
		return String.format("{0} {1}",pDate, pTime);
	},
	
	setHourMin: function(){
		var t24 = [ ],
		t60 = [ ],
		option24,
		option60,
		i,
		t;
		
		//배열 추가 
		for( i = 0 ; i < 24 ; i++ ){
			t = "0" + i;
			option24 = String.format("<option>{0}</option>",  t.substr( t.length -2, 2 ));
			t24.push( option24  );
		}

		for( i = 0 ; i < 60 ; i++ ){
			t = "0" + i;
			option60 = String.format("<option>{0}</option>",  t.substr( t.length -2, 2 ));
			t60.push( option60 );
		}

		//셀렉트 옵션 추가
		$("select[id$=Hour]").empty().append( t24 );
		$("select[id$=Min]").empty().append( t60 );
	},
	
	toggleFolderMenu: function( pObj ){
		$(pObj).parent().find("a:nth-child(2)").toggleClass("expand");	
	},
	
	toggleContextMenu: function( pObj ){
		if(!$(pObj).closest(".layerTglWrap").hasClass("active")){
			$(pObj).closest(".tblList").find(".layerTglWrap").removeClass("active");
			$(pObj).closest(".layerTglWrap").find(".tglBox").show();
			$(pObj).closest(".layerTglWrap").addClass("active");
		}else{
			$(pObj).closest(".tblList").find(".layerTglWrap").removeClass("active");
			$(pObj).closest(".layerTglWrap").find(".tglBox").hide();
			$(pObj).closest(".layerTglWrap").remove("active");
		}
	},
	
	//컨텐츠 기본정보 조회
	selectContentMessage:function(pFolderID){
		var contentsData = {};
		var params = {"folderID": pFolderID};
		
		if (CFN_GetQueryString("C") != "undefined") {
			params["communityID"] = CFN_GetQueryString("C");
		} else if (CFN_GetQueryString("CSMU") != "undefined" && CFN_GetQueryString("CSMU") === "C") {
			params["communityID"] = cID;
		}
		
		$.ajax({
			url:"/groupware/board/selectContentMessage.do",
			type:"POST",
			data:params,
			async:false,
			success:function (data) {
				if(data.status == 'SUCCESS'){
					contentsData = data.data;
				}
			},
			error:function (error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
		
		return contentsData;
	},
	
	goFolderContents: function(pBizSection, pMenuID, pFolderID, pFolderType, activeKey, cWebPart, pMenuCode, pFolderName){
		var url, contents;
		
		//게시글, 게시판 정보 URL parameter로 추가
		var context_param = String.format("&CLBIZ={0}&folderID={1}",pBizSection, pFolderID);
		
		if(arguments.length < 4){
			url = arguments[0]==null?sessionStorage.getItem("urlHistory"):arguments[0];
		} else {
			//Tree Menu에서 선택한 게시판들은 모두 boardType이 Normal로 고정 추후 FolderType은 앨범목록 보기를 사용해야할때...추후 분기처리 
			if(pFolderType == "Contents"){	//컨텐츠 타입일 경우 게시글이 있는 지 조회하여 작성, 상세보기 페이지로 이동
				contents = board.selectContentMessage(pFolderID);
				if($.isEmptyObject(contents)){
					url = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&folderID=" + pFolderID + "&menuID="+ pMenuID;
				} else {
					board.goView("Board", pMenuID, contents.Version, contents.FolderID, contents.MessageID, "", "", "", "", "", "List", "Normal", "");
					return;
				}
			} else if (pFolderType == "QuickComment"){	//한줄 댓글 게시의 경우 작성화면 이동없이 무조건 상세보기 화면으로 이동
				contents = board.selectContentMessage(pFolderID);
				board.goView("Board", pMenuID, contents.Version, contents.FolderID, contents.MessageID, "", "", "", "", "", "List","Normal", "", "",activeKey);
				return;
			} else if (pFolderID == Common.getBaseConfig("IssueBoardFolderID")){ //[DEK] 프로젝트 이슈 해결사례
				url = "/groupware/layout/issue_IssueBoardList.do?CLSYS="+ pBizSection +"&CLMD=user&boardType=Normal" + context_param;
			} else {
				url = "/groupware/layout/board_BoardList.do?CLSYS="+ pBizSection +"&CLMD=user&boardType=Normal" + context_param;
			}
			
			if(CFN_GetQueryString("C") != "undefined"){	//Community용 Parameter추가
				url += "&communityId="+CFN_GetQueryString("C") + "&CSMU=C";
			} else if (CFN_GetQueryString("communityId") != "undefined"){
				url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
			}

			if(activeKey != null && activeKey != ''){
				url += "&activeKey="+activeKey;
			}else if(CFN_GetQueryString("activeKey") != "undefined"){
				url += "&activeKey="+CFN_GetQueryString("activeKey");
			}
		}
		if(pMenuCode!= null && pMenuCode != ''){	//MenuCode Parameter추가
			url += "&menuCode="+pMenuCode;
		}	
		//페이지 URL정보 세션, 전역변수에 저장
		sessionStorage.setItem("urlHistory", url);
		g_urlHistory = url;
		
		if(cWebPart == 'Y'){
			location.href = url;
		}else{
			if (pFolderName != "")
				CoviMenu_OpenMenu(url,  false,pMenuID,pFolderName)
			else
				CoviMenu_GetContent(url);
		}
	},
	
	goList: function(pBizSection, pMenuID, pFolderID, pBoardType, pFolderType){
		var url, contents;
		//게시글, 게시판 정보 URL parameter로 추가
		var context_param = String.format("&CLBIZ={0}&menuID={1}",pBizSection, pMenuID);
		
		if(grCode){
			context_param += "&grCode=" + grCode;
		}else{
			context_param += "&folderID=" + pFolderID;
		}
		
		if(pBizSection == "Doc" && pBoardType == "Doc" ){
			url = "/groupware/layout/board_BoardList.do?CLSYS="+ pBizSection + "&CLMD=user&boardType=Normal" + context_param;
		} else if(boardType != "Normal"){
			url = "/groupware/layout/board_BoardList.do?CLSYS="+ pBizSection +"&CLMD=user&CLBIZ="+ pBizSection +"&boardType=" + pBoardType + "&menuID=" + pMenuID;
		} else {
			//Tree Menu에서 선택한 게시판들은 모두 boardType이 Normal로 고정 추후 FolderType은 앨범목록 보기를 사용해야할때...추후 분기처리 
			if(pFolderType == "Contents"){	//컨텐츠 타입일 경우 게시글이 있는 지 조회하여 작성, 상세보기 페이지로 이동
				contents = board.selectContentMessage(pFolderID);
				if($.isEmptyObject(contents)){
					url = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&folderID=" + pFolderID + "&menuID=" + pMenuID;
				} else {
					board.goView("Board", pMenuID, contents.Version, contents.FolderID, contents.MessageID, "", "", "", "", "List", "Normal", "", "");
				}
			} else if (pFolderType == "QuickComment"){	//한줄 댓글 게시의 경우 작성화면 이동없이 무조건 상세보기 화면으로 이동
				contents = board.selectContentMessage(pFolderID);
				board.goView("Board", pMenuID, contents.Version, contents.FolderID, contents.MessageID, "", "", "", "", "List", "Normal", "", "");
			} else {
				url = "/groupware/layout/board_BoardList.do?CLSYS="+ pBizSection +"&CLMD=user&boardType=Normal" + context_param;
			}
		}
		if(viewType != undefined && viewType != ""){
			url += "&viewType="+viewType;
		}

		if(sortBy != undefined && sortBy != ""){
			url += "&sortBy="+decodeURIComponent(sortBy);
		}
		
		if(page != undefined && page != ""){
			url += "&page="+page;
		}
		
		if(page != undefined && pageSize != ""){
			url += "&pageSize="+pageSize;
		}
		
		if(searchType != undefined && searchType != ""){
			url += "&searchType="+searchType;
			
			if (searchType === "UserForm" && ufColumn) {
				url += "&ufColumn="+ufColumn;
			}
		}
		
		if(searchText != undefined && searchText != ""){
			url += "&searchText="+encodeURIComponent(searchText);
		}
		
		if(startDate != undefined && startDate != ""){
			url += "&startDate="+startDate;
		}
		
		if(endDate != undefined && endDate != ""){
			url += "&endDate="+endDate;
		}
		
		if(CFN_GetQueryString("C") != "undefined"){	//Community용 Parameter추가
			url += "&communityId="+CFN_GetQueryString("C") + "&CSMU=C";
		} else if (CFN_GetQueryString("communityId") != "undefined"){
			url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
		}

		if(CFN_GetQueryString("activeKey") != "undefined" ){
			url += "&activeKey="+CFN_GetQueryString("activeKey");
		}
		
		if(CFN_GetQueryString("selectCategoryID") != "undefined" ){
			url += "&selectCategoryID=" + CFN_GetQueryString("selectCategoryID");
		}
		
		if(CFN_GetQueryString("boxType") != "undefined" ){
			url += "&boxType=" + CFN_GetQueryString("boxType");
		}
		
		if(CFN_GetQueryString("approvalStatus") != "undefined" ){
			url += "&approvalStatus=" + CFN_GetQueryString("approvalStatus");
		}
		
		if(typeof menuCode != "undefined") {
			url += '&menuCode=' + menuCode;
		}
		
		if(typeof selectSearch != "undefined") {
			url += '&selectSearch=' + selectSearch;
		}
		
		if(typeof readSearchType != "undefined") {
			url += '&readSearchType=' + readSearchType;
		}
		
		//페이지 URL정보 세션, 전역변수에 저장
		
		sessionStorage.setItem("urlHistory", url);
		g_urlHistory = url;
		
		CoviMenu_GetContent(url);
	},
	
	goTagList: function( pObj ){
		//BizSection에따라 게시판인지 문서관리인지 구분해야함
		var prefix_url = "";
		if(pObj.bizSection != "Doc"){
			prefix_url = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user";
		} else {
			prefix_url = "/groupware/layout/board_BoardList.do?CLSYS=doc&CLMD=user";
		}
		
		if(pObj.bizSection == "Community"){
			var url = String.format("{0}&boardType={1}&CLBIZ=Board&folderID={3}",
				prefix_url,
				pObj.boardType, 
				pObj.bizSection,
				pObj.folderID
				);
			
			if(CFN_GetQueryString("communityId") != "undefined" ){
			url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
			}
			
			url += String.format("&searchType={0}&searchText={1}",
				pObj.searchType,
				encodeURIComponent(pObj.searchText)
			);
		}else {
			var url = String.format("{0}&CLBIZ={1}&boardType={2}&version={3}&menuID={4}&folderID={5}&messageID={6}&searchType={7}&searchText={8}",
				prefix_url,
				pObj.bizSection, 
				pObj.boardType, 
				pObj.version, 
				pObj.menuID,
				pObj.folderID, 
				pObj.messageID,
				pObj.searchType,
				encodeURIComponent(pObj.searchText)
				);
		}

		CoviMenu_GetContent(url);
	},
	/* formatter 항목 시작 **************************************************************************************************************/
	
	//FolderGrid 사용여부, 표시여부 포멧
	formatUpdateFlag: function( pObj ){
		var returnStr = "<input type='text' kind='switch' on_value='Y' off_value='N' style='width:50px;height:21px;border:0px none;' ";
		if(pObj.key == "IsUse"){
			returnStr += String.format("value='{1}' onchange='updateFlag({0},\"{1}\",\"{2}\");' />", pObj.item.FolderID, pObj.item.IsUse, pObj.key);
		} else {
			returnStr += String.format("value='{1}' onchange='updateFlag({0},\"{1}\",\"{2}\");' />", pObj.item.FolderID, pObj.item.IsDisplay, pObj.key);
		}
		return returnStr;
	},
	
	
	//게시글 MsgState 라벨처리
	formatMessageState: function(pObj){
		var msgState;
		switch(pObj.item.MsgState){
		case "C":
			msgState = coviDic.dicMap["lbl_Registor"];	//등록
			break;
		case "A":
			msgState = coviDic.dicMap["lbl_Approval"];	//승인
			break;
		case "D":
			msgState = coviDic.dicMap["lbl_Rejected"];	//거부
			break;
		case "P":
			msgState = coviDic.dicMap["lbl_Lock"];		//잠금
			break;
		case "R":
			msgState = coviDic.dicMap["lbl_RegistReq"];	//등록 요청 ( 승인 프로세스 )
			break;
		case "T":
			msgState = coviDic.dicMap["lbl_TempSave"];	//임시저장
			break;
		default:
		}

		if(pObj.item.DeleteDate != "" && pObj.item.DeleteDate != undefined){
			msgState = coviDic.dicMap["lbl_delete"];		//DeleteDate컬럼의 데이터가 있을경우 무조건 삭제된 게시글로 표시
		}
		
		return msgState;
	},
	
	formatTopNotice: function( pObj, pTopNoticeFlag ){
		var returnStr = pObj.item.MessageID;
		
		// 게시판별 게시번호 사용 여부 체크에 따른 번호 설정
		// 전체글 보기는 pTopNoticeFlag의 값이 undefined로 들어간다.
		if(Common.getBaseConfig("UseBoardCategoryNumber") == 'Y' && pTopNoticeFlag != undefined){
			returnStr = pObj.item.Number;
		}	
		
		//CHECK: pObj.item.ListTop == "A"은 체크 할 필요가 있는지...
		if(pTopNoticeFlag == "Y" && pObj.item.IsTop == "Y"){
			returnStr = "<div><span class='iconTopNoti'></span></div>";
		}
		return returnStr;
	},
	
	//파일 첨부 아이콘 표시
	//CHECK: 파일 확장자별 개별 아이콘 표시도 해야함
	formatFileAttach: function( pObj ){
		var returnStr = "";
		
		if(pObj.item.FileExtension == "exel"){
			returnStr = "<div><span class='tblIcExcel'></span></div>";
		} else if(pObj.item.FileExtension == "ppt" ){
			returnStr = "<div><span class='tblIcPPT'></span></div>";
		} else if(pObj.item.FileCnt != "0" ){			
			var divFile = $('<div class="attFileListBox"/>');
			var anchorAttFile = $('<a href = "javascript:void(0);" onclick="javascript:board.renderFileList(this,'+ pObj.item.FolderID +','+ pObj.item.MessageID +','+ pObj.item.Version +')"/>').addClass("tblIcAttFile btnAttFileListBox btnTopOptionMenu");
			var ulFileList = $('<ul class="attFileListCont topOptionListCont"/>');
			var anchorDownloadAll = "<a href='javascript:void(0);' onclick='javascript:board.gridDownloadAll("+ pObj.item.FolderID +","+ pObj.item.MessageID +","+ pObj.item.Version +")'>"+Common.getDic("lbl_download_all")+"</a>";
			var anchorDownloadZip = "<a href='javascript:void(0);' class='zip' style='margin-left: 10%; vertical-align: inherit;' onclick='javascript:board.zipFiledownload("+ pObj.item.FolderID +","+ pObj.item.MessageID +","+ pObj.item.Version +")'>"+Common.getDic("lbl_download_compressFiles")+"</a>";
			var anchorClose = $('<a class="btnXClose btnTopOptionContClose" onclick="$(\'.topOptionListCont\').removeClass(\'active\');"></a>');
			
			if(Common.getBaseConfig('useDownloadCompressFiles') == "Y") {
				ulFileList.append($('<li />').append(anchorDownloadAll, anchorDownloadZip, anchorClose));
			} else {
				ulFileList.append($('<li />').append(anchorDownloadAll, anchorClose));
			}
			
			divFile.append(anchorAttFile, ulFileList);
			returnStr = divFile.prop("outerHTML");
		}
		
		return returnStr;
	},
	
	formatVersion: function( pObj ){
		return "<div><span class='badge'>Ver." + pObj.item.Version + "</span></div>";
	},
	
	formatCheckOut: function( pObj ){
		var divIcoWrap = $('<div class="icoWrap"/>');
		if(pObj.item.IsCheckOut == "Y"){
			divIcoWrap.append("<span class='icoDocList icoLock'><span class='toolTip'>Check-Out</span></span>");
		} else {
			divIcoWrap.append("<span class='icoDocList icoUnLock'><span class='toolTip'>Check-In</span></span>");
		}
		return divIcoWrap.clone().wrapAll("<div/>").parent().html();
	},
	
	formatAclList: function (pObj){
		var divIcoWrap = $('<div class="icoWrap"/>');
		var bReadFlag = false;
		var bModifyFlag = false;
		var bDeleteFlag = false;
		
		if(pObj.item.MsgState != "A") {	// 일반 게시글(문서) 일 경우 게시판 담당자, 문서 소유자, 등록부서 체크하여 아이콘 표시
			if(sessionObj["isAdmin"] == "Y" || pObj.item.FolderOwnerCode.indexOf(g_userCode+";") != -1 || pObj.item.OwnerCode == g_userCode){
				divIcoWrap.append(viewIcon, modifyIcon, deleteIcon);
				return divIcoWrap.clone().wrapAll("<div/>").parent().html();
			} 
		} else {						// 승인 게시글(문서) 일 경우, 본인 - 수정 X, 삭제 X, 이동 X , 관리자 - 수정 O, 삭제X, 이동 X 아이콘 표시
			if(sessionObj["isAdmin"] == "Y" || pObj.item.FolderOwnerCode.indexOf(g_userCode+";") != -1){
				divIcoWrap.append(viewIcon, modifyIcon);
				return divIcoWrap.clone().wrapAll("<div/>").parent().html();
			} else {
				divIcoWrap.append(viewIcon);
				return divIcoWrap.clone().wrapAll("<div/>").parent().html();
			}
		}
		
		//board_message_acl테이블에서 등록된 정보로 개별 체크
		var aclObj = board.getMessageAclList("Doc", pObj.item.Version, pObj.item.MessageID, pObj.item.FolderID).aclObj;
		
		bReadFlag = aclObj.Read == "_"?false:true;
		bModifyFlag = aclObj.Modify == "_"?false:true;
		bDeleteFlag = aclObj.Delete == "_"?false:true;
		
		// 등록부서와 같은 부서일 경우
		if (pObj.item.RegistDept == sessionObj["GR_Code"]){
			divIcoWrap.append(viewIcon);
			bReadFlag = true;
		}
		
		if(!bReadFlag && !bModifyFlag && !bDeleteFlag){
			divIcoWrap.append($('<span class="icoDocList icoBan"><span class="toolTip">'+ Common.getDic("lbl_noAuth") +'</span></span>'));	//권한이 없습니다.
		} else {
			if(bReadFlag){ divIcoWrap.append(viewIcon); }
			if(bModifyFlag){ divIcoWrap.append(modifyIcon); }
			if(bDeleteFlag){ divIcoWrap.append(deleteIcon); }
		}
		
		return divIcoWrap.clone().wrapAll("<div/>").parent().html();
	},
	
	//문서관리 항목 관련 문서배포, 권한 요청 context menu
	formatContextMenu: function( pObj ){
		var userCode = g_userCode;
		var folderID = pObj.item.FolderID;
		var messageID = pObj.item.MessageID;
		var version = pObj.item.Version;
		var folderPath = pObj.item.FolderPath;
		
		var layerTglWrap = $('<div class="layerTglWrap" />').append($('<button type="button" class="btnTglLayer" onclick="javascript:board.toggleContextMenu(this);">레이어열기</button>'));
		var tglBox = $('<ul class="tglBox"  style="display: none;"/>');
			if(pObj.item.OwnerCode == userCode || pObj.item.FolderOwnerCode == userCode){
				//문서배포
				tglBox.append($('<li />').append($('<a onclick="javascript:board.distributeDocPopup('+ folderID +','+ messageID +','+ version +')"/>').text(Common.getDic("lbl_Doc_docDistribution"))));
			} else {
				//권한 요청
				tglBox.append($('<li />').append($('<a onclick="javascript:board.requestAuthPopup('+ folderID +','+ messageID +','+ version +',\'' + folderPath + '\')"/>').text(Common.getDic("lbl_AclRequest"))));
			}
		layerTglWrap.append(tglBox);
		return layerTglWrap.clone().wrapAll("<div/>").parent().html();
	},
	
	//게시분류
	formatFolderName: function(pObj){
		//var clickBox = $("<div class='tblClickBox' />");
		var subject = String.format("<a onclick='javascript:board.goFolderContents(\"{1}\", {2}, {3}, \"{4}\", {5});' >{0}</a>", 
			pObj.item.FolderName,
			bizSection,
			pObj.item.MenuID,
			pObj.item.FolderID,
			pObj.item.FolderType,
			1);
		
		return subject;
		//return $(clickBox.append(subject))[0].outerHTML;
	},
	
	//게시글 제목 포멧: 삭제된 게시글 취소선 처리, 답글표시, 최근게시
	formatSubjectName: function( pObj, pRecentlyFlag, pRecentlyDay){
		var	sortBy = messageGrid.getSortParam("one").split("=")[1] != undefined?messageGrid.getSortParam("one").split("=")[1]:"";
		var page = messageGrid.page.pageNo;
		var pageSize = $("#selectPageSize").val();
		var clickBox = $("<div class='tblClickBox' />");	//제목 우측에 새글 표시 및 댓글 카운트 표시
		var recentlyBadge = $("<span />").addClass("cycleNew new").text("N");	//새글 표시 뱃지
		var replyFlag = false;		//답글 flag
		var recentFlag = false;		//최신글 flag
		var tooltip = pObj.item.Subject; //제목 tooltip
		
		//Subject항목 내부 <, >가 존재할경우 문자열로 치환(HTML DOM Element To String)
		var returnStr = pObj.item.Subject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;");
		//댓글이 있을 경우 clickbox 추가
		if(parseInt(pObj.item.CommentCnt) > 0 && (g_boardConfig.UseComment == "Y" || pObj.item.UseComment == "Y")){
			//답글 팝업
			clickBox.append("<span  style='color:black; cursor:pointer; margin-right: 3px; float: left;' onclick='javascript:board.replyPopup("+pObj.item.FolderID+","+pObj.item.MessageID+","+pObj.item.Version+",\""+bizSection+"\");'>(" + pObj.item.CommentCnt + ")</span>");
			replyFlag = true;
		}
		
		//g_boardConfig.UseIncludeReg, g_boardConfig.RecentlyDay
		if(pRecentlyFlag == "Y" && pRecentlyDay > 0){
			var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
			var registDate = new Date(CFN_TransLocalTime(pObj.item.CreateDate));
			if(today < registDate.setDate(registDate.getDate()+ pRecentlyDay)){
				recentFlag = true;
			}
		}
		
		//문서관리 바인더일 경우 표시
		if(bizSection == "Doc" && pObj.item.MsgType == "B"){
			returnStr = "<span class='btnType02'>" + coviDic.dicMap["lbl_Binder"] + "</span>" + returnStr;
		}
		
		var subject = String.format("<a onclick='javascript:board.goViewPopup(\"{1}\", {2}, {3}, {4}, {5},\"W\", \"{16}\");' class='newWindowPop'></a><a onclick='javascript:board.goView(\"{1}\", {2}, {3}, {4}, {5}, \"{6}\", \"{7}\", \"{8}\", \"{9}\", \"{10}\", \"{11}\", \"{12}\", {13}, {14}, \"\", {15}, \"{16}\", \"{17}\", \"{18}\", \"{19}\", this);' >{0}</a>", 
			returnStr,
			bizSection,
			pObj.item.MenuID,
			pObj.item.Version,
			pObj.item.FolderID,
			pObj.item.MessageID,
			$("#startDate").val(),
			$("#endDate").val(),
			sortBy,
			encodeURIComponent($("#searchText").val()),
			$("#searchType").val(),
			viewType,
			boardType,
			page,
			pageSize, 
			pObj.item.RNUM,
			pObj.item.MultiFolderType ? pObj.item.MultiFolderType : "",
			grCode,
			$("#searchType").val() === "UserForm" ? $("#searchType option:selected").attr("ufcolumn") : "",
			$("#selectCategoryID").val());
		
		returnStr = subject;
		
		if(recentFlag){
			returnStr += clickBox.append( recentlyBadge ).prop('outerHTML');
		} else if(replyFlag){
			returnStr += clickBox.prop('outerHTML');
		}
		//삭제된 게시글의 경우 취소선 표시
		if(pObj.item.DeleteDate != "" && pObj.item.DeleteDate != undefined){
			returnStr = $("<strike/>").append(returnStr);
		}
		
		if(pObj.item.Depth!="0" && pObj.item.Depth!=undefined){
			returnStr = $("<div class='tblLink re' style='margin: 0 0 0 "+(pObj.item.Depth*12)+"px; width: calc(100% - "+(pObj.item.Depth*12)+"px);'>").append(returnStr);
			//답글 게시글 화살표 표시
		} else {
			returnStr = $("<div class='tblLink'>").append(returnStr);
		}
		
		returnStr.attr('title', tooltip);	// tooltip 추가
		returnStr.attr('data-message-id', pObj.item.MessageID);
		returnStr.attr('data-message-ver', pObj.item.Version);
		
		//읽지않은 게시글 굵게
		if(pObj.item.IsRead != "Y"){
			returnStr = $("<strong />").append(returnStr);
		}
		
		return returnStr.prop('outerHTML');
	},
	
	formatRequestStatus: function ( pObj ){
		var returnStr = String.format("<a href='#' onclick='requestStatusPopup({0}, \"{1}\", \"{2}\");'>{2}</a>", pObj.item.RequestID, (pObj.item.AnswerContent==undefined?"":pObj.item.AnswerContent), pObj.item.RequestStatus);
		return returnStr;
	},
	
	//승인요청 메뉴 에서 승인상태 표시 
	formatApprovalStatus: function(pObj){
		var returnStr = "";
		var progressBar = $('<div class="participationRateBar" />');
		var progress = "";
		
		if(pObj.item.TotalApprovalCnt > 0){
			progress = $('<div/>').attr('style', 'width:' + ((pObj.item.TotalApprovalCnt/pObj.item.TotalApproverCnt) * 100)+'%');
			$(progressBar).append(progress);
		}
		
		returnStr = $('<div class="processWrap" />').append(progressBar, $('<span/>').text(pObj.item.TotalApprovalCnt + "/" + pObj.item.TotalApproverCnt)).prop("outerHTML");
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectProcessActivityList.do",
			async: false,
			data:{
	       		"processID": pObj.item.ProcessID,
	       	},
	       	success:function(data){
	       		var processDetail = $('<div class="processDetail" />').append('<ul/>');
	       		if(data.status='SUCCESS'){
	       			$(data.list).each(function(i, item){
	       				var processData = String.format("({0} {1})", Common.getDic("lbl_" + item.ActivityType), Common.getDic("lbl_" + item.ActorRole));
	       				var liClass, icoTxtClass, stateValue;
	       				
	       				if(item.State == "7"){
	       					liClass = "access";
	       					icoTxtClass = "icoTxt colorGreen";
	       					stateValue = Common.getDic("lbl_apv_Approved");
	       				} else {
	       					liClass = "";
	       					icoTxtClass = "icoTxt colorRed";
	       					stateValue = item.State=="0"?Common.getDic("lbl_Standby"):item.State=="1"?Common.getDic("lbl_Progress"):Common.getDic("lbl_Rejected");
	       				}
	       				var actorData = $('<strong/>').append(item.ActorName, $('<span>').text(processData));	//ActorName ( ActivityType ActorRole )
	       				var activityState = $('<span/>').addClass(icoTxtClass).text(stateValue);				//State
	       				var date = $('<span ="date"/>').text(item.CompleteDate);								//CompleteDate
	       				$(processDetail).find('ul').append($('<li/>').addClass(liClass).append(actorData, activityState, date));
		       		});
	       			returnStr += $(processDetail).prop('outerHTML');
	       		}
	       	},
	       	error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/admin/selectProcessActivityList.do", response, status, error);
       		}
		});
		return returnStr;
	},
	
	/* formatter 항목 끝 **************************************************************************************************************/
	
	goWrite: function(){
		var isCommunity = (typeof cID == 'string');
		var pathname = (CFN_GetQueryString("folderID")==Common.getBaseConfig("IssueBoardFolderID")) ? "issue_IssueBoardWrite" : "board_BoardWrite";		//[DEK] 프로젝트 이슈 해결사례
		var	url = '/groupware/layout/'+pathname+'.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create';
		
		if (isCommunity) {
			url += "&communityId="+cID + "&CSMU=C";
			
			if(CFN_GetQueryString("activeKey") != "undefined" ){
				url += "&activeKey="+CFN_GetQueryString("activeKey");
			}
		} else {
			url += '&menuID='+menuID;
			
			if(CFN_GetQueryString("menuCode") != "undefined" ){
				url += "&menuCode="+CFN_GetQueryString("menuCode");
			}
		}
		
		if(CFN_GetQueryString("folderID") != "undefined" ){
			if(!board.checkFolderWriteAuth(CFN_GetQueryString("folderID"))){
				Common.Warning(Common.getDic('msg_noWriteAuth'), "Warning Dialog", function () {	// 해당 분류에는 쓰기 권한이 없습니다.
					if(bizSection == "Doc"){
						$(".path").html("");
						$("#hiddenFolderID").val("");
					}
				});
				return false;
			} else {
				url += "&folderID="+CFN_GetQueryString("folderID");
			}
		}
		
		CoviMenu_GetContent(url);
	},
	
	goView: function(pBizSection, pMenuID, pVersion, pFolderID, pMessageID, pStartDate, pEndDate, pSortBy, pSearchText, pSearchType, pViewType, pBoardType, pPage, pPageSize, cActiveKey, pRNum, pMultiFolderType, pGRCode, pUfColumn, pCategoryID, pTarget){
		//BizSection에따라 게시판인지 문서관리인지 구분해야함
		
		var prefix_url = "";
		if(pBizSection != "Doc"){
			if(pFolderID == Common.getBaseConfig("IssueBoardFolderID")){ //[DEK] 프로젝트 이슈 해결사례
				prefix_url = "/groupware/layout/issue_IssueBoardView.do?CLSYS=doc&CLMD=user";
			}else{
				prefix_url = "/groupware/layout/board_BoardView.do?CLSYS=board&CLMD=user";
			}
		}else {
			prefix_url = "/groupware/layout/board_BoardView.do?CLSYS=doc&CLMD=user";
		}
		
		var url = String.format("{0}&CLBIZ={1}&menuID={2}&version={3}&folderID={4}&messageID={5}&viewType={6}&boardType={7}&startDate={8}&endDate={9}&sortBy={10}&searchText={11}&searchType={12}&page={13}&pageSize={14}&rNum={15}&boxType={16}&approvalStatus={17}",
			prefix_url,
			pBizSection, 
			pMenuID,
			pVersion, 
			pFolderID, 
			pMessageID,
			pViewType,
			pBoardType,
			pStartDate,
			pEndDate,
			pSortBy,
			encodeURIComponent(pSearchText),
			pSearchType,
			pPage,
			pPageSize,
			pRNum,
			boxType,
			$("#selectApprovalStatus").length==0?((typeof approvalStatus != 'undefined') ?approvalStatus:''):$("#selectApprovalStatus").val()
		);
		
		if(CFN_GetQueryString("C") != "undefined"){	//Community용 Parameter추가
			url += "&communityId="+CFN_GetQueryString("C") + "&CSMU=C";
		} else if (CFN_GetQueryString("communityId") != "undefined"){
			url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
		}

		if(cActiveKey != null && cActiveKey != '' ){
			url += "&activeKey="+cActiveKey;
		}else if(CFN_GetQueryString("activeKey") != "undefined" ){
			url += "&activeKey="+CFN_GetQueryString("activeKey");
		}
		
		if(CFN_GetQueryString("selectCategoryID") != "undefined" ){
			url += "&selectCategoryID=" + CFN_GetQueryString("selectCategoryID");
		}
		
		// 다차원 분류
		if(pMultiFolderType){
			url += "&multiFolderType=" + pMultiFolderType;
		}
		
		// 부서 문서함
		if(pGRCode){
			url += "&grCode=" + pGRCode;
		}
		
		// 사용자 정의 필드
		if(pUfColumn){
			url += "&ufColumn=" + pUfColumn;
		}
		
		// 카테고리
		if(pCategoryID){
			url += "&selectCategoryID=" + pCategoryID;
		}
		
		// 메뉴코드
		if(typeof menuCode != "undefined") {
			url += "&menuCode=" + menuCode;
		}
		
		// 기간
		if($("#selectSearch").length > 0 && $("#selectSearch").val() != "") {
			url += "&selectSearch=" + $("#selectSearch").val();
		}		
		
		// 읽지않음
		if($("#chkRead").length > 0 && $("#chkRead").prop("checked")) {
			url += "&readSearchType=unread";
		}
		
		if ($(pTarget).length > 0) {
			if($(pTarget).closest("tr.gridBodyTr").prev().length > 0) {	// 이전글이 있는 경우 전달. 일단 messageid값만 전달해봄
				var prevMessage = $(pTarget).closest("tr.gridBodyTr").prev();
				var prevMessageID = $($(prevMessage).find(".tblLink")[0]).attr("data-message-id");
				var prevMessageVer = $($(prevMessage).find(".tblLink")[0]).attr("data-message-ver");
				url += '&prevMessageID=' + prevMessageID + '&prevMessageVer=' + prevMessageVer;
			}
			
			if($(pTarget).closest("tr.gridBodyTr").next().length > 0) {	// 다음글이 있는 경우 전달
				//url += '&nextMessageID=' + $(pTarget).closest("tr.gridBodyTr").next().find("td:first div").text();
				var nextMessage = $(pTarget).closest("tr.gridBodyTr").next();
				var nextMessageID = $($(nextMessage).find(".tblLink")[0]).attr("data-message-id");
				var nextMessageVer = $($(nextMessage).find(".tblLink")[0]).attr("data-message-ver");
				url += '&nextMessageID=' + nextMessageID + '&nextMessageVer=' + nextMessageVer;
			}
		};
		
		CoviMenu_GetContent(url);
	},
	
	checkReadAuth: function( pBizSection, pFolderID, pMessageID, pVersion ){
		var bReadFlag = false;
		
		$.ajax({
			type:"POST",
			data: {
				"bizSection": pBizSection
				,"folderID": pFolderID
				,"messageID": pMessageID
				,"version": pVersion
				,"communityID": typeof(communityID) == 'undefined' ? null : coviCmn.isNull(communityID, null)
			},
			url: "/groupware/board/checkReadAuth.do",
			async:false,
			success:function(data){
				if(data.status == 'SUCCESS'){
					bReadFlag = data.flag;
				}
			},
		});
		return bReadFlag;
	},
	
	checkWriteAuth: function(pAclList){
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
	},
	
	checkModifyAuth: function( pBizSection, pFolderID, pMessageID, pVersion ){
		var bModifyFlag = false;
		
		$.ajax({
			type:"POST",
			data: {
				"bizSection": pBizSection
				,"folderID": pFolderID
				,"messageID": pMessageID
				,"version": pVersion
				,"communityID": typeof(communityID) == 'undefined' ? null : coviCmn.isNull(communityID, null)
			},
			url: "/groupware/board/checkModifyAuth.do",
			async:false,
			success:function(data){
				if(data.status == 'SUCCESS'){
					bModifyFlag = data.flag;
				}
			},
		});
		
		return bModifyFlag;
	},
	
	checkFolderWriteAuth: function( pFolderID ){
		var bWriteFlag = false;
		
		var serviceType = communityID != "" ? "Community" : bizSection;
		
		$.ajax({
			type:"POST",
			data: {
				"objectID": pFolderID
				,"objectType": "FD"
				,"serviceType": serviceType
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
	},
	
	checkExecuteAuth: function( pBizSection, pFolderID, pMessageID, pVersion ){
		var bExecuteFlag = false;
		
		$.ajax({
			type:"POST",
			data: {
				 "bizSection": pBizSection
				,"folderID": pFolderID
				,"messageID": pMessageID
				,"version": pVersion
				,"communityID": typeof(communityID) == 'undefined' ? null : coviCmn.isNull(communityID, null)
			},
			url: "/groupware/board/checkExecuteAuth.do",
			async:false,
			success:function(data){
				if(data.status == 'SUCCESS'){
					bExecuteFlag = data.flag;
				} else {
					bExecuteFlag = false;
				}
			},
		});
		
		return bExecuteFlag;
	},
	
	//게시글 권한별 및 버튼 표시/숨김처리
	//상단 - 수정, 삭제, 이동, 승인, 거부  
	//context - 조회자 목록, 답글
	checkAclList: function(){
		var aclObj = {}; 
		if(sessionObj["isAdmin"] != "Y"
			&& g_boardConfig.OwnerCode.indexOf(sessionObj["USERID"]+";") == -1
			&& ((bizSection!="Doc" && g_messageConfig.CreatorCode != sessionObj["USERID"]) 
				|| (bizSection=="Doc" && g_messageConfig.OwnerCode != sessionObj["USERID"])	)
		){
			aclObj = board.getMessageAclList(bizSection, version, messageID, folderID).aclObj;
		}
		
		//상단 - 수정, 삭제, 이동, 승인, 거부  버튼
		/* 조건 
		1. 게시글이 승인 프로세스를 타지 않는 경우 
		2. [이동버튼만] 게시판 복사/이동 설정(UseCopy)이 'Y
		3. 아래 중 하나라도 만족하는 경우 
			3-1. 시스템 관리자, 게시판 운영자인 경우
			3-2. bizSection이 'Doc'이 아닐 때 작성자인 경우 (Board일 때는 답글을 쓰면 소유자는 원본글 작성자이기 때문에 소유자에게는 수정권한 X)
			3-3. bizSection이 'Doc'일 때 소유자인 경우 (Doc은 개정해도 작성자는 처음 작성한 사람이기 때문에 소유자에게만 수정권한 부여)
			3-4. 해당 폴더 또는 메세지에 (수정-수정권한, 삭제-삭제권한, 이동-삭제권한) 권한이 있는 경우
		*/
		if(!["A", "R", "D"].includes(g_messageConfig.MsgState)){ //게시글 승인(A), 승인요청(R), 거부(D) 상태
			if(sessionObj["isAdmin"] == "Y"
				|| g_boardConfig.OwnerCode.indexOf(sessionObj["USERID"]+";") != -1
				|| (bizSection!="Doc" && g_messageConfig.CreatorCode == sessionObj["USERID"]) 
				|| (bizSection=="Doc" && g_messageConfig.OwnerCode == sessionObj["USERID"])){
				$("a[name=btnUpdate], a[name=btnDelete]").show();
				
				if(g_boardConfig.UseCopy == "Y"){
					 $("a[name=btnMove]").show();
					 $("a[name=btnCopy]").show();
					
				}
			}else{
				aclObj.Modify == "M" ? $("a[name=btnUpdate]").show() : $("a[name=btnUpdate]").hide();
				aclObj.Delete == "D" ? $("a[name=btnDelete]").show() : $("a[name=btnDelete]").hide();
				(aclObj.Delete == "D" && g_boardConfig.UseCopy == "Y") ? $("a[name=btnMove], a[name=btnCopy]").show() : $("a[name=btnMove], a[name=btnCopy]").hide();
			}
		}else{
			$("a[name=btnUpdate], a[name=btnDelete], a[name=btnMove], a[name=btnCopy]").hide();
			
			// 반려된 게시물 수정할 수 있도록 처리
			if (g_messageConfig.MsgState === "D") $("a[name=btnUpdate]").show();
		}
		
		// 상단 - 승인, 거부 버튼
		// 조건: 게시글이 승인 요청프로세스를 타고 승인 요청인 상태이며 승인자인 경우
		if(typeof approvalStatus != "undefined" && approvalStatus == "R"){ //승인요청(R) 상태
			if(boardType == "Approval"){
				$("a[name=btnAccept], a[name=btnReject]").show();
			}else{
				$("a[name=btnAccept], a[name=btnReject]").hide();
			}
		}else{
			$("a[name=btnAccept], a[name=btnReject]").hide();
		}
		
		//context - 조회자 목록
		/* 조건
		 1. bizSection이 'Doc' 이거나 'Board'인데 조회자목록 옵션이 Y
		 2. 아래 중 하나라도 만족하는 경우 
			 2-1. 시스템 관리자, 게시판 운영자인 경우
			 2-2. bizSection이 'Doc'이 아닐 때 작성자인 경우 (Board일 때는 답글을 쓰면 소유자는 원본글 작성자이기 때문에 소유자에게는 수정권한 X)
			 2-3. bizSection이 'Doc'일 때 소유자인 경우 (Doc은 개정해도 작성자는 처음 작성한 사람이기 때문에 소유자에게만 수정권한 부여)
			 2-4. 해당 게시물에 보안권한이 있는 경우
			  2-5. 익명 게시판 조회자 목록 비활성화
		*/
		if(bizSection=="Doc" || (bizSection != "Doc" && g_boardConfig.UseReaderView == "Y")){
			if((sessionObj["isAdmin"] == "Y"
				|| g_boardConfig.OwnerCode.indexOf(sessionObj["USERID"]+";") != -1
				|| (bizSection!="Doc" && g_messageConfig.CreatorCode == sessionObj["USERID"]) 
				|| (bizSection=="Doc" && g_messageConfig.OwnerCode == sessionObj["USERID"]))
				&& g_messageConfig.FolderType != "Anonymous"){
				$("#ctxReaderView").parent().show();
			}else{
				aclObj.Security == "S" ? $("#ctxReaderView").parent().show() : $("#ctxReaderView").parent().hide();
			}
		}
		
		//context - 답글
		/* 조건
		 1. 'Board'인데 답글 옵션이 Y
		 2. 아래 중 하나라도 만족하는 경우 
			 2-1. 시스템 관리자, 게시판 운영자인 경우
			 2-2. bizSection이 'Doc'이 아닐 때 작성자인 경우 (Board일 때는 답글을 쓰면 소유자는 원본글 작성자이기 때문에 소유자에게는 수정권한 X)
			 2-3. bizSection이 'Doc'일 때 소유자인 경우 (Doc은 개정해도 작성자는 처음 작성한 사람이기 때문에 소유자에게만 수정권한 부여)
			 2-4. 해당 게시물에 생성권한이 있는 경우
		*/
		if(bizSection != "Doc" && g_boardConfig.UseReply == "Y"){
			if(sessionObj["isAdmin"] == "Y"
				|| g_boardConfig.OwnerCode.indexOf(sessionObj["USERID"]+";") != -1
				|| (bizSection!="Doc" && g_messageConfig.CreatorCode == sessionObj["USERID"]) 
				|| (bizSection=="Doc" && g_messageConfig.OwnerCode == sessionObj["USERID"])){
				$("#ctxReply").parent().show();
			}else{
				aclObj.Create == "C" ? $("#ctxReply").parent().show() : $("#ctxReply").parent().hide();
			}
		}
		
		// context - 메일 보내기
		// 조건: bizSection이 Board인 경우
		if(bizSection != "Doc"){
			$("#ctxMailSend").parent().show();
		}
	},
	
	//수정의 경우 parameter 개수가 늘어날 경우를 대비해서 object 타입으로 우선처리
	goUpdate: function(pObj){
		//BizSection에따라 게시판인지 문서관리인지 구분해야함
		var prefix_url = "";
		var mode = "";
		if(pObj.bizSection != "Doc"){
			prefix_url = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user";
		} else {
			prefix_url = "/groupware/layout/board_DocWrite.do?CLSYS=doc&CLMD=user";
		}
		
		if(pObj.msgType == "B"){
			mode="binder";
		}else{
			mode="update";
		}
		
		var url = String.format("{0}&CLBIZ={1}&boardType={2}&version={3}&menuID={4}&folderID={5}&messageID={6}&mode={7}",
			prefix_url,
			pObj.bizSection, 
			pObj.boardType, 
			pObj.version, 
			pObj.menuID,
			pObj.folderID, 
			pObj.messageID,
			mode);
		if(CFN_GetQueryString("communityId") != "undefined" ){	//Community용 Parameter추가
			url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
		}
		
		if(CFN_GetQueryString("activeKey") != "undefined" ){	//Community용 Parameter추가
			url += "&activeKey="+CFN_GetQueryString("activeKey");
		}
		
		// 다차원 분류
		if(pObj.multiFolderType){
			url += "&multiFolderType=" + pObj.multiFolderType;
		}
		
		CoviMenu_GetContent(url);
	},
	
	//답글 작성
	goReply: function( pObj ){
		//BizSection에따라 게시판인지 문서관리인지 구분해야함
		var url = String.format("/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ={0}&boardType={1}&version={2}&menuID={3}&folderID={4}&messageID={5}&mode=reply",
			pObj.bizSection, 
			pObj.boardType, 
			pObj.version,
			pObj.menuID,
			pObj.folderID, 
			pObj.messageID 
		);
		
		if(CFN_GetQueryString("communityId") != "undefined" ){	//Community용 Parameter추가
			url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
		}
		
		if(CFN_GetQueryString("activeKey") != "undefined" ){	//Community용 Parameter추가
			url += "&activeKey="+CFN_GetQueryString("activeKey");
		}
		
		if(viewType == "Popup"){
			g_urlHistory = String.format("/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ={0}&boardType=Normal&menuID={1}&folderID={2}", pObj.bizSection, pObj.menuID, pObj.folderID );
			sessionStorage.setItem("urlHistory", location.href);
			
			var pUrl = String.format("/groupware/board/goBoardWritePopup.do?CLSYS=board&CLMD=user&CLBIZ={0}&boardType={1}&version={2}&menuID={3}&folderID={4}&messageID={5}&mode=reply&isPopup=Y",
				pObj.bizSection, 
				pObj.boardType, 
				pObj.version,
				pObj.menuID,
				pObj.folderID, 
				pObj.messageID 
			);
			
			if(opener != null && (opener["cType"] != null && opener["cType"] == "C") && opener["communityID"] != null){ //Community용 Parameter추가
				pUrl += "&communityId=" + opener["communityID"] + "&CSMU=C";
			}
			
			location.href = pUrl;
		}else{
			CoviMenu_GetContent(url);
		}
	},
	
	//수정의 경우 parameter 개수가 늘어날 경우를 대비해서 object 타입으로 우선처리
	goMigrate: function( pObj ){
		//BizSection에따라 게시판인지 문서관리인지 구분해야함
		var url = String.format("/groupware/layout/board_DocWrite.do?CLSYS=doc&CLMD=user&CLBIZ={0}&boardType={1}&version={2}&messageID={3}&mode=migrate",
			'Doc', 
			'Normal', 
			pObj.version, 
			pObj.messageID
		);
		
		if(CFN_GetQueryString("communityId") != "undefined" ){	//Community용 Parameter추가
			url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
		}
		
		if(CFN_GetQueryString("activeKey") != "undefined" ){	//Community용 Parameter추가
			url += "&activeKey="+CFN_GetQueryString("activeKey");
		}
		
		
		CoviMenu_GetContent(url);
	},
	
	//바인더 작성페이지로 이동
	goCreateBinder: function( pObj ){
		var	url = '/groupware/layout/board_DocWrite.do?CLSYS=doc&CLMD=user&CLBIZ=Doc&mode=binder';
		
		if(CFN_GetQueryString("folderID") != "undefined" ){
			url += "&folderID="+CFN_GetQueryString("folderID");
		}
		
		if(CFN_GetQueryString("communityId") != "undefined" ){	//Community용 Parameter추가
			url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
		}
		
		CoviMenu_GetContent(url);
	},
	
	//게시판 옵션 조회
	getBoardConfig: function( pFolderID ){
		$.ajax({
			type:"POST",
			url:"/groupware/admin/selectBoardConfig.do",
			async: false,
			data:{
	       		"folderID": (pFolderID == "undefined" ? "": pFolderID),
	       	},
	       	success:function(data){
	       		g_boardConfig = data.config;
	       		if (g_boardConfig.DefaultContents) g_boardConfig.DefaultContents = g_boardConfig.DefaultContents.replace(/\r\n/g, '<br>');
	       	},
	       	error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/admin/selectBoardConfig.do", response, status, error);
       		}
		});
	},
	
	//사용자 정의 필드 옵션 조회 
	//checkbox, radio button, selectbox
	//status: Create, Update 변수에 따라 설정값 조회 여부를 체크 한다.
	
	getOptionByFieldType: function(pUserFormID, pFieldType, pIsCheckVal, pAddOpt, pMode){
		var optionHtml = "";
		var addHtml ="";
		if (pAddOpt == undefined) pAddOpt="";
		var sEvent = (g_enableChangeUserDifField == 'N') ? "" : " onclick='javascript:board.setUserDefFieldValue(\""+folderID+"\",\""+messageID+"\",\""+version+"\",\""+pUserFormID+"\", this)' ";			
 		if (pMode == "V" && (g_enableChangeUserDifField == 'N' || !hasModifyAuth) ) {
			sEvent = "";
			addHtml = " disabled ";
		}
		else if (pMode != "V") {
			sEvent = "";
		}
	
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectUserDefFieldOptionList.do",
			data:{
	       		"userFormID": pUserFormID,
	       	},
	       	async: false,
	       	success:function(data){
	       		$(data.list).each(function(i, item){
	       			switch (pFieldType)  {
		                case "DropDown":
		                	optionHtml += String.format("<option value='{0}' {2} data-dic='"+item.OptionName+"'>{1}</option>", item.OptionValue, CFN_GetDicInfo(item.OptionName), (item.OptionCheck == 'Y' && CFN_GetQueryString('mode') == 'create') ? 'selected' : '');
	                        break;
		                case "ListBox":
		                case "CheckBox":
		                	optionHtml += String.format("<span class='chkStyle01'><input "+addHtml+" type='checkbox' id='{4}' userformid='{0}' name='UserForm_{0}' value='{1}' isCheck='{2}' {5} "+sEvent+" data-dic='"+item.OptionName+"'><label for='{4}'><span></span>{3}</label></span>", pUserFormID, item.OptionValue, pIsCheckVal, CFN_GetDicInfo(item.OptionName), item.OptionID, (item.OptionCheck == 'Y' && CFN_GetQueryString('mode') == 'create') ? 'checked' : '');
	                        break;
		                case "Radio":
		                	optionHtml += String.format("<span class='radioStyle04 size'><input "+addHtml+"  type='radio' id='{4}' userformid='{0}' name='UserForm_{0}' value='{1}' isCheck='{2}' {5} "+sEvent+" data-dic='"+item.OptionName+"'><label for='{4}'><span><span></span></span>{3}</label></span>", pUserFormID, item.OptionValue, pIsCheckVal, CFN_GetDicInfo(item.OptionName), item.OptionID, (item.OptionCheck == 'Y' && CFN_GetQueryString('mode') == 'create') ? 'checked' : '');
	                        break;
	       			}
	       		});

	       		if(pFieldType == "ListBox"){
	            	optionHtml = "<div class='listbox' "+pAddOpt+">"+optionHtml+"</div>";
	       		}	
	       		
	       		if(pFieldType == "DropDown"){
	       			if (pMode == "V"){
						addHtml += "class='selectType02 size102 " +(g_boardConfig.IsContents == "Y"?" ca_text ":"")+"'";
						
						if ((g_enableChangeUserDifField == 'Y')) {
							// 상세조회에서 사용자정의필드 수정 사용 시, 셀렉트박스인 경우 이벤트 유형 변경 및 포커스 이벤트 부여
							sEvent = sEvent.replace("onclick", "onchange");
							sEvent += " onfocus=\"this.dataset.oldvalue = this.value;\"";
						} 
						else {
		       				addHtml += " style='pointer-events:none;" +(g_boardConfig.IsContents == "Y"?" background:#f3f3f3":"")+"'" ;
						}
		       			
	       			}else{
	       				addHtml += "class='selectType02 size102'";
	       			}

	       			optionHtml = String.format("<select userformid='{0}' name='UserForm_{0}' isCheck='{1}' "+addHtml+" "+sEvent+">"+((pMode != "V" || g_enableChangeUserDifField == 'Y')?"<option value=''>"+Common.getDic("msg_Select")+"</option>":""), pUserFormID, pIsCheckVal) + optionHtml;
	       			optionHtml += String.format("</select>");
	       		}
	       	},
	       	error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/selectUserDefFieldOptionList.do", response, status, error);
       		}
		});
		return optionHtml;
	},
	
	//사용자정의 필드 타입별 HTML return
	renderControlWrite: function( pObj ){
		if (pObj.DefVal == null)  pObj.DefVal = "";
		var sAddOpt = board.getControlAdd(pObj);	
		var addClass = pObj.IsCheckVal == "Y"?" Required":"";
		if (pObj.FieldLimitCnt != "" && pObj.FieldLimitCnt != "0") addClass += " MaxSizeCheck";
		var sTitleEvent = ""
		if (pObj.IsTitle == "Y"){
			sTitleEvent = "onkeydown='$(\"#Subject\").val($(this).val())'";
		}
		var widthClass = (pObj.FieldSize == 'Half') ? '': 'txtInp ';
		var isViewMode = (location.pathname.indexOf('View') > -1);
		switch (pObj.FieldType){
			case "Input":
				var _event = (isViewMode && (g_enableChangeUserDifField == 'Y' && hasModifyAuth)) ? 'onkeypress="javascript:if(event.keyCode == 13) { board.setUserDefFieldValue(\''+folderID+'\',\''+messageID+'\',\''+version+'\',\''+pObj.UserFormID+'\', this); }"' : '';
				return String.format("<input userformid='{0}' name='UserForm_{0}' "+sAddOpt+ " "+sTitleEvent+" class='"+widthClass+" HtmlCheckXSS ScriptCheckXSS"+addClass+"' type='text' maxlength='{1}' max='{1}' isCheck='{2}' value='{3}' title='"+pObj.FieldName+"' {4}/>", pObj.UserFormID, pObj.FieldLimitCnt, pObj.IsCheckVal, pObj.DefVal, _event);
				break;
			case "Number":
				var _event = (isViewMode && (g_enableChangeUserDifField == 'Y' && hasModifyAuth)) ? 'onkeypress="javascript:if(event.keyCode == 13) { board.setUserDefFieldValue(\''+folderID+'\',\''+messageID+'\',\''+version+'\',\''+pObj.UserFormID+'\', this); }"' : '';
				return String.format("<input userformid='{0}' name='UserForm_{0}' "+sAddOpt+" "+sTitleEvent+" class='"+widthClass+" HtmlCheckXSS ScriptCheckXSS Number"+addClass+"' type='text' isNumber='Y' maxlength='{1}' isCheck='{2}' value='{3}' minnum='{4}' maxnum='{5}' title='"+pObj.FieldName+"' {6}/>", pObj.UserFormID, pObj.FieldLimitCnt, pObj.IsCheckVal, pObj.DefVal, pObj.FieldLimitMin, pObj.FieldLimitMax, _event);
				break;
			case "TextArea":
				return String.format("<textarea userformid='{0}' name='UserForm_{0}' "+sAddOpt+" class='"+(pObj.FieldRow  > "0"?"":"txtaraDefault")+" HtmlCheckXSS ScriptCheckXSS"+addClass+"' maxlength='{1}' isCheck='{2}' value='{3}' title='"+pObj.FieldName+"'/>", pObj.UserFormID, pObj.FieldLimitCnt, pObj.IsCheckVal, pObj.DefVal);
				break;
			case "Radio":
				return board.getOptionByFieldType(pObj.UserFormID, pObj.FieldType, pObj.IsCheckVal, sAddOpt, "W");
				break;
			case "CheckBox":
			case "ListBox":
				return board.getOptionByFieldType(pObj.UserFormID, pObj.FieldType, pObj.IsCheckVal, sAddOpt, "W");
				break;
			case "Date":
				var _event = (isViewMode && (g_enableChangeUserDifField == 'Y' && hasModifyAuth)) ? 'onchange="javascript:board.setUserDefFieldValue(\''+folderID+'\',\''+messageID+'\',\''+version+'\',\''+pObj.UserFormID+'\', this);"' : '';
				return String.format("<input userformid='{0}' name='UserForm_{0}' "+sAddOpt+" isCheck='{1}' date_separator='.' kind='date' type='text' data-axbind='date' class='adDate"+addClass+"' title='"+pObj.FieldName+"' {2}>", pObj.UserFormID, pObj.IsCheckVal, _event);
				break;
			case "DateTime":
				return String.format("<input userformid='{0}' name='UserForm_{0}'  isCheck='{1}' date_separator='.' style='width:100%' max='9999-12-31T00:00' value='"+CFN_GetLocalCurrentDate('yyyy-MM-ddTHH:mm')+"' type='datetime-local' data-axbind='datetime' title='"+pObj.FieldName+"'>", pObj.UserFormID, pObj.IsCheckVal);
				break;
			case "DropDown":
				return board.getOptionByFieldType(pObj.UserFormID, pObj.FieldType, pObj.IsCheckVal, sAddOpt, "W");
				break;
			case "Line":
				return "<div class='line' "+sAddOpt+" ></div>";
				break;
			case "Space":
				return "<div class='whitespace'  "+sAddOpt+"></div>";
				break;
			case "Button":
				return "<a class='btnTypeDefault btnTypeBg'  "+sAddOpt+" onclick='window.open(\""+pObj.GotoLink+"\");'>"+pObj.FieldName+"</a>";
				break;
			case "Image":
				return "<img src='"+pObj.GotoLink+"'  "+sAddOpt+"  onerror=\"this.onerror=null;this.src='/covicore/resources/images/no_image.jpg';\">";
				break;
			case "Help":
				return '<div class="collabo_help02">'+
					'<a href="#" class="help_ico" onclick="coviCmn.viewHelp(this)"></a>'+	
					'<div class="helppopup"><div class="help_p">'+pObj.Description+	'	</div></div>'+
				'</div>';
				break;
			case "Label":
				return "";
				break;
			default:
				return pObj.FieldType;
				break;
		}
	},
	getControlAdd:function(pObj){
		var sAddOpt = "";
		if (pObj.FieldType == 'Space' ){
			if (pObj.FieldHeight != undefined && pObj.FieldHeight != ""  && pObj.FieldHeight != "0"){
				sAddOpt = "style='height:"+pObj.FieldHeight+pObj.FieldHeightUnit+"'";
			}
		}else{
			if (pObj.FieldWidth != undefined && pObj.FieldWidth != ""  && pObj.FieldWidth != "0"){
				sAddOpt = "style='width:"+pObj.FieldWidth+pObj.FieldWidthUnit+"'";
			}
			
			if (pObj.FieldRow  != undefined && pObj.FieldRow != ""  && pObj.FieldRow != "0"){
				sAddOpt = "rows="+pObj.FieldRow;
			}
		}	
		return sAddOpt;
	},
	renderControlViewClass:function(FieldType){
		if (g_boardConfig.IsContents != "Y") return "";
		var retClass="";
		
		switch (FieldType){
			case "Input":
				retClass = "tx_input_text"	;
				break;
			case "TextArea":
				retClass = "tx_textarea"	;
				break;
			case "Date":
			case "DateTime":
				retClass = "tx_date"	;
				break;
			case "Number":
				retClass = "tx_auto"	;
				break;
		}
		
		retClass= "class='ca_text "+retClass+"'";
		return retClass;
	},
	//사용자정의 필드 타입별 HTML return
	renderControlView: function( pObj){
		var sAddOpt = board.getControlAdd(pObj);	
		switch (pObj.FieldType){
			case "Input":
			case "Number":
			case "TextArea":
			case "Date":
			case "DateTime":
				return String.format("<p userformid='{0}' name='UserForm_{0}' "+sAddOpt+ " "+ board.renderControlViewClass(pObj.FieldType)+"></p>", pObj.UserFormID);
				break;
			case "DropDown":
				return board.getOptionByFieldType(pObj.UserFormID, pObj.FieldType, pObj.IsCheckVal, sAddOpt, "V");
				break;
			case "Radio":
				return board.getOptionByFieldType(pObj.UserFormID, pObj.FieldType, pObj.IsCheckVal, sAddOpt, "V");
				break;
			case "CheckBox":
			case "ListBox":
				return board.getOptionByFieldType(pObj.UserFormID, pObj.FieldType, pObj.IsCheckVal, sAddOpt, "V");
				break;
			case "Line":
				return "<div class='line' "+sAddOpt+ "></div>";
				break;
			case "Space":
				return "<div class='whitespace' "+sAddOpt+ "></div>";
				break;
			case "Button":
				return "<a class='btnTypeDefault btnTypeBg' "+sAddOpt+ " onclick='window.open(\""+pObj.GotoLink+"\");'>"+pObj.FieldName+"</a>";
				break;
			case "Image":
				return "<img src='"+pObj.GotoLink+"' "+sAddOpt+ ">";
				break;
			case "Help":
				return '<div class="collabo_help02">'+
						'<a href="#" class="help_ico" onclick="coviCmn.viewHelp(this)"></a>'+	
						'<div class="helppopup"><div class="help_p">'+pObj.Description+	'	</div></div>'+
					'</div>';
				break;
			case "Label":
				return "";
				break;
			default:
				return pObj.FieldType;
				break;
		}
	},

	//사용자정의 필드 헤더 생성용
	getUserDefFieldHeader: function( pFolderID ){
		var gridHeaderList = [];
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectUserDefFieldList.do",
			data:{
	       		"folderID": pFolderID
				//, "isList": "Y"
	       	},
	       	async: false,
	       	success:function(data){
	       		var fieldList = data.list;
	       		board.userDefField = {};
	       		$.each(fieldList, function(i, item){
	       			var userDefField = {};
       				userDefField.label = item.FieldName;
       				userDefField.key = "UF_Value"+i;	//board_message_userform_value 조회시 사용할 컬럼명
       				userDefField.width = "5";
       				userDefField.align = "center";
       				userDefField.id = item.UserFormID;
	       			if(item.IsList == "Y"){
	       				userDefField.formatter = function(){
							var resultValue = '';
							try{
								var $this = this;
								resultValue = CFN_GetDicInfo($this.value);	
							}catch (e){
								coviCmn.traceLog(e)
							}	
								
							return resultValue;		
						};

	       				gridHeaderList.push(userDefField);
	       			}
       				board.userDefField[userDefField.key] = item;
	       		});
	       	},
	       	error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/selectUserDefFieldList.do", response, status, error);
       		}
		});
		
		return gridHeaderList;
	},
	
	/* 
	* 1. getUserDefField
	* 2. renderUserDefFieldView : FieldSize 및 Element, CSS Class 처리를 위한 분기처리 시작 
	*    renderUserDefFieldWrite 
	* 3. renderControlView		: Span, SelecBox, Checkbox, Radio Element 생성
	*    renderControlWrite     : Input, TextArea, DateTime, SelectBox, Checkbox, Radio Element 생성
	* 4. getOptionByFieldType   : 체크박스, 라디오버튼, SelectBox생성
	* 5. getUserDefFieldValue   : 수정, 상세조회시 기설정값 셋팅
	*/
	getUserDefField: function( pPageType, pFolderID ){
		$.ajax({
			type:"POST",
			url:"/groupware/board/selectUserDefFieldList.do",
			data:{
	       		"folderID": pFolderID,
	       	},
	       	async: false,
	       	success:function(data){
	       		var fieldList = data.list;
	       		
	       		if(fieldList.length == 0) { //확장 옵션 데이터 없는 경우, 확장옵션 폼 숨김 처리
					$("#divUserDefFieldHeader").hide();
					$("#divUserDefField").hide();
					return;
				}
	       		
	       		if(typeof g_messageConfig != 'undefined' && g_messageConfig != null) g_messageConfig.userDefField = JSON.parse(JSON.stringify(fieldList));
	       		
	       		if(pPageType == "View"){
	       			board.renderUserDefFieldView(fieldList);
	       		} else if(pPageType == "Write") {
	       			board.renderUserDefFieldWrite(fieldList);
	       		} 
	       	},
	       	error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/selectUserDefFieldList.do", response, status, error);
       		}
		});
	},
	renderUserTooltip:function(item){
		return '<div class="collabo_help02"><a class="help_ico"  onclick="coviCmn.viewHelp(this)"></a><div class="helppopup"><div class="help_p">'+item.Description+'</div></div></div>';
	},
	//pPageType: View, Write
	//pFieldObj: UserDefField 테이블 조회 Object, board_userform 테이블 참조
	renderUserDefFieldWrite: function(pFieldList){
		board.renderMultiCategory("Write");
		
		var multiCateLen = $(".multiCategory").length;
		var editCtrl = 0;
		
		if (g_boardConfig.IsContents == "Y"){
			$("#divUserDefField").addClass("contentsapp_write_wrap type01");
		}else{
			$("#divUserDefField").removeClass("contentsapp_write_wrap type01");
			if(multiCateLen + pFieldList.length > 10){
				Common.Inform(Common.getDic("msg_checkUserDefColumnCount")); // 사용자 정의 필드의 수와 다중 카테고리 개수의 합이<br>10을 넘는 경우 사용자 정의 컬럼이 제대로 표시되지 않을 수 있습니다.
			}
		}	
		
		for(var idx = 0; idx < pFieldList.length; idx++){
			var item = pFieldList[idx];
			if (!arrCtrl.includes(item.FieldType)) editCtrl++;
			
			if (g_boardConfig.IsContents == "Y"){
				var divWrap = $("<div>",{"class":"txt component"+(item.FieldSize=="Half"?" w50":"")});
				if (item.IsLabel == "Y"){
					divWrap.append($("<label>").append(item.IsCheckVal=="Y"?$("<span>",{"class":"thstar","text":"*"}):"")
												.append(item.FieldName));
					if (item.Description != "" && item.IsTooltip == "Y"){
						divWrap.find("label").append(board.renderUserTooltip(item));
					}	
				}								
				divWrap.append($("<span>").append(board.renderControlWrite(item)));
				if (item.Description != "" && item.IsTooltip == "N"){
					divWrap.append($("<div>",{"class":"comp_ptx","text":item.Description}));
				}	
				
				$("#divUserDefField").append(divWrap);
				
			}else{	
				var divWrap = document.createElement("div");
				if (multiCateLen % 2 == 1 && item.FieldSize == "Half") {
					var divWrapHalf = document.createElement("div");
					$(divWrapHalf).addClass("inputBoxSytel01 subDepth type02");
					$(divWrapHalf).append(String.format("<div> <span id='{0}' class='{1}'>{2}</span></div>", item.UserFormID, (item.IsCheckVal=="Y"?"star":""), item.FieldName));
					$(divWrapHalf).append(String.format("<div class='h_{1}'>{0}</div>", board.renderControlWrite(item), item.FieldSize ));
					$("#divUserDefField").find("div.inputBoxSytel01:last").append($(divWrapHalf));
					divWrap = null;
					multiCateLen = 0;
				} else if ((idx !== pFieldList.length -1) && ( item.FieldSize == "Half" && pFieldList[idx+1].FieldSize == "Half" )) {
					$(divWrap).addClass("inputBoxSytel01 type02");
					$(divWrap).append(String.format("<div><span id='{0}' class='{1}'>{2}</span></div>", item.UserFormID, (item.IsCheckVal=="Y"?"star":""), item.FieldName));
					$(divWrap).append(String.format("<div class='h_{1}'>{0}</div>", board.renderControlWrite(item), item.FieldSize));
					
					var nextUserForm = pFieldList[idx+1];
					var divWrapHalf = document.createElement("div");
					$(divWrapHalf).addClass("inputBoxSytel01 subDepth type02");
					$(divWrapHalf).append(String.format("<div> <span id='{0}' class='{1}'>{2}</span></div>", nextUserForm.UserFormID, (nextUserForm.IsCheckVal=="Y"?"star":""), nextUserForm.FieldName));
					$(divWrapHalf).append(String.format("<div class='h_{1}'>{0}</div>", board.renderControlWrite(nextUserForm), nextUserForm.FieldSize ));
					$(divWrap).append($(divWrapHalf));
					$("#divUserDefField").append($(divWrap));
					pFieldList.splice(idx+1, 1);
					continue;	//Half, Half가 동시에 있을경우 한 Row에 표시한뒤 다음 index순서 조회
				} else {
					$(divWrap).addClass("inputBoxSytel01 type02");
					$(divWrap).append(String.format("<div><span id='{0}' class='{1}'>{2}</span></div>", item.UserFormID, (item.IsCheckVal=="Y"?"star":""), item.FieldName));
					$(divWrap).append(String.format("<div class='h_{1}'>{0}</div>", board.renderControlWrite(item), item.FieldSize));
				}
				$("#divUserDefField").append($(divWrap));
			}
		}	

		if(multiCateLen + editCtrl > 10){
			Common.Inform(g_boardConfig.IsContents+":"+Common.getDic("msg_checkUserDefColumnCount")); // 사용자 정의 필드의 수와 다중 카테고리 개수의 합이<br>10을 넘는 경우 사용자 정의 컬럼이 제대로 표시되지 않을 수 있습니다.
		}

	},
	
	//pPageType: View, Write
	//pFieldObj: UserDefField 테이블 조회 Object, board_userform 테이블 참조
	renderUserDefFieldView: function(pFieldList){
		board.renderMultiCategory("View");
		
		var multiCateLen = $(".multiCategory").length;
		var editCtrl = 0;
		
		if (g_boardConfig.IsContents == "Y"){
			$("#divUserDefField").removeClass("boradDisplay").removeClass("type02")
								.addClass("boardDisplayContent")
								.append($("<div>",{"class":"contentsapp_view_wrap type01"}));
		}

		for(var idx = 0; idx < pFieldList.length; idx++){
			var item = pFieldList[idx];
			if (!arrCtrl.includes(item.FieldType)) editCtrl++;
			if (g_boardConfig.IsContents == "Y"){
				var divWrap = $("<div>",{"class":"component"+(item.FieldSize=="Half"?" w50":"")});
				if (item.IsLabel == "Y"){
					divWrap.append($("<label>").append(item.FieldName));
				}								
				divWrap.append(board.renderControlView(item, "Y"));
				$("#divUserDefField .contentsapp_view_wrap").append(divWrap);
			}else{	
				var divWrap = document.createElement("div");		//사용자 정의 폼 최상위
				var divWrapHalf = document.createElement("div");
				var itemHTML = (['Input','Number','Date'].indexOf(item.FieldType) > -1 && (g_enableChangeUserDifField == 'Y' && hasModifyAuth)) ? board.renderControlWrite(item) : board.renderControlView(item);

				if (multiCateLen % 2 == 1 && item.FieldSize == "Half") {
					var divWrapHalf = document.createElement("div");
					$(divWrapHalf).addClass("disTblStyle");
					$(divWrapHalf).append(String.format("<div class='tit'> <span id='{0}' class='{1}'>{2}</span></div>", item.UserFormID, (item.IsCheckVal=="Y"?"star":""), item.FieldName));
					$(divWrapHalf).append(String.format("<div class='txt h_{1}'>{0}</div>", itemHTML, item.FieldSize ));
					$("#divUserDefField").find("div.txt:last").append($(divWrapHalf));
					divWrap = null;
					multiCateLen = 0;
				} else if ((idx !== pFieldList.length -1) && ( item.FieldSize == "Half" && pFieldList[idx+1].FieldSize == "Half" )) {
					$(divWrap).append(String.format("<div class='tit'><span id='{0}' class='{1}'>{2}</span></div>", item.UserFormID, (item.IsCheckVal=="Y"?"star":""), item.FieldName));
					$(divWrap).append(String.format("<div class='txt h_{1}'><div class='disTblStyle'>{0}</div></div>", itemHTML, item.FieldSize));
					
					var nextUserForm = pFieldList[idx+1];
					var nextItemHTML = (['Input','Number','Date'].indexOf(nextUserForm.FieldType) > -1 && (g_enableChangeUserDifField == 'Y' && hasModifyAuth)) ? board.renderControlWrite(nextUserForm) : board.renderControlView(nextUserForm);
					$(divWrapHalf).addClass("disTblStyle");
					$(divWrapHalf).append(String.format("<div class='tit'> <span id='{0}' class='{1}'>{2}</span></div>", nextUserForm.UserFormID, (nextUserForm.IsCheckVal=="Y"?"star":""), nextUserForm.FieldName));
					$(divWrapHalf).append(String.format("<div class='txt h_{1}'>{0}</div>", nextItemHTML, nextUserForm.FieldSize ));
					$(divWrap).find(".txt").append($(divWrapHalf));
					$("#divUserDefField").append($(divWrap));
					pFieldList.splice(idx+1, 1);
					continue;	//Half, Half가 동시에 있을경우 한 Row에 표시한뒤 다음 index순서 조회
				} else {
					$(divWrap).append(String.format("<div class='tit'><span id='{0}' class='{1}'>{2}</span></div>", item.UserFormID, (item.IsCheckVal=="Y"?"star":""), item.FieldName));
					//$(divWrap).append(String.format("<div class='txt h_{1}'>{0}</div>", board.renderControlView(item), item.FieldSize));
					$(divWrap).append(String.format("<div class='txt h_{1}'>{0}</div>", itemHTML, item.FieldSize));
				}
				$("#divUserDefField").append($(divWrap));
			}	
		}
		
		if(multiCateLen + editCtrl > 10){
			Common.Inform(g_boardConfig.IsContents+":"+Common.getDic("msg_checkUserDefColumnCount")+(multiCateLen + editCtrl)); // 사용자 정의 필드의 수와 다중 카테고리 개수의 합이<br>10을 넘는 경우 사용자 정의 컬럼이 제대로 표시되지 않을 수 있습니다.
		}
	},
	
	//사용자 정의 필드 parameter 데이터
	setUserDefFieldData: function(){
		var fieldArray = [];
		var prevFieldID = "";
		//Element Name이 UserForm을 사용할 경우 ID와 설정된 값을 추출, checkbox, radio버튼의 설정된 값만 추출
		$("[name^=UserForm]:not([type=checkbox], [type=radio]), [name^=UserForm]:checked").each(function(i, item){
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
				if(Common.getBaseConfig("eventBoardID") == folderID && $(this).attr("id") == "EventOwner"){	//임직원 소식 게시판
					userDefField.FieldValue = $("#EventOwner").attr("data-value");
				} else {
					userDefField.FieldValue = $(this).val();
				}
		        
		        if( $(this).attr("type") == "radio" || $(this).attr("type") == "checkbox"){
					userDefField.FieldText = $(this).attr('data-dic');
		        } else if ( $(this).is("select")){
		        	if($(this).find(":selected").val() == ""){
		        		userDefField.FieldText = "";
		        	}else{
						userDefField.FieldText = $(this).find(":selected").attr('data-dic');
		        	}
		        } else if ( $(this).attr("type") == "datetime-local" ){
					userDefField.FieldValue = userDefField.FieldValue.replace("T", " ");
					userDefField.FieldText = $(this).val().replace("T", " ");
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
	},
	
	getProcessState: function( pFolderID ){
   		var divProgressState = $('<div id="divProgressState" style="disTblStyle"/>').append(
   				$('<div class="tit"/>').append($('<span/>').text("처리상태")), 
   				$('<div class="txt"/>').append($('<select class="selectType02 size102" id="selectProgressState"/>')));
   		
		if($('#divUserDefField').find('div:last').hasClass('h_Half')){
			$('#divUserDefField').append(divProgressState);
		} else {
			$('#divUserDefField').find('div:last').parent().append(divProgressState);
		}
   		$('#selectProgressState').coviCtrl("setSelectOption", "/groupware/board/selectProgressStateList.do", {folderID: pFolderID});
	},
	
	//열람권한 정보 조회
	getMessageReadAuth: function(pBizSection, pMessageID, pFolderID) {
		var aclString = "";
		$.ajax({
			type:"POST",
			async:false,
			data: {
				"bizSection": pBizSection,
				"messageID": pMessageID,
				"folderID": pFolderID,
			},
			url:"/groupware/board/selectMessageReadAuthList.do",
			success:function(data){
				$("#messageReadAuth").val("");
				//string타입으로 code|type|name;code|type|name;...
				$(data.list).each(function(i, item){
					aclString += String.format("{0}|{1}|{2};",item.TargetCode, item.TargetType, item.DisplayName);
				});
				
				aclString = aclString.substring(0, aclString.length-1);
				$("#messageReadAuth").val(aclString);
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/selectMessageReadAuthList.do", response, status, error);
			}
		});
		return aclString;
	},
	
	// 열람권한 정보 조회
	// checkReadAuth에서 함께 체크하도록 수정
	/*getMessageReadAuthCount: function(pBizSection, pMessageID, pFolderID) {
		var authCnt = 0;
		$.ajax({
			type:"POST",
			data: {
				"bizSection": pBizSection,
				"messageID": pMessageID,
				"folderID": pFolderID,
			},
			url:"/groupware/board/selectMessageReadAuthCount.do",
			async: false,
			success:function(data){
				if(data.status == 'SUCCESS'){
					if(data.allCount == 0){ //지정된 열람권한자가 하나도 없을 경우 폴더 권한을 따라감
						authCnt = 1; 
					}else{
						authCnt = data.count
					}
				} else {
	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	    		}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/selectMessageReadAuthCount.do", response, status, error);
			}
		});
		return authCnt;
	},*/
	
	//상세권한 정보 조회 및 작성 페이지의 messageAuth에 JSON Array 값 설정
	getMessageAuth: function(pBizSection, pVersion, pMessageID, pFolderID) {
		$.ajax({
			type:"POST",
			data: {
				"bizSection": pBizSection,
				"messageID": pMessageID,
				"version": pVersion,
				"folderID": pFolderID
			},
			url:"/groupware/board/selectMessageAuthList.do",
			success:function(data){
				$("#messageAuth").val(JSON.stringify(data.list));
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/selectMessageAuthList.do", response, status, error);
			}
		});
	},
	
	getBoardAclList: function(pFolderID){
		var aclList = [];
		$.ajax({
			type:"POST",
			data: {
				"objectID": (pFolderID == "undefined" ? "": pFolderID)
				,"objectType": "FD"
			},
			url: "/groupware/admin/selectBoardACLData.do",
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
					
					aclObj.AclList = aclShard;
					aclObj.TargetType = item.SubjectType;
					aclObj.TargetCode = item.SubjectCode;
					aclObj.DisplayName = item.SubjectName;
					aclObj.GroupType = item.GroupType;
					aclObj.IsSubInclude = item.IsSubInclude;
					aclObj.InheritedObjectID = (pFolderID == "undefined" ? "0": pFolderID)
					aclList.push(aclObj);
				});
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/admin/selectBoardACLData.do", response, status, error);
			}
		});
		return aclList;
	},
	
	//상세권한 정보 조회
	//pBizSection하고 pFolderID만 넘길 경우 Folder권한 조회
	getMessageAclList: function(pBizSection, pVersion, pMessageID, pFolderID, pRequestorCode) {		
		var aclList = null;
		$.ajax({
			type:"POST",
			data: {
				"bizSection": pBizSection,
				"folderID": pFolderID,
				"messageID": pMessageID,
				"version": pVersion,
				"communityID": coviCmn.isNull(communityID, null),
				"requestorCode": coviCmn.isNull(pRequestorCode, null)
			},
			url:"/groupware/board/selectMessageAclList.do",
			async:false,
			success:function(data){
				aclList = data;
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/selectMessageAclList.do", response, status, error);
			}
		});
		return aclList;
	},
	
	//사용자 정의 필드 정보 조회
	//pPageType : "View", "Write"
	getUserDefFieldValue: function(pPageType, pVersion, pMessageID) {
		$.ajax({
			type:"POST",
			data: {
				"messageID": pMessageID,
				"version": pVersion,
			},
			url:"/groupware/board/selectUserDefFieldValue.do",
			success:function(data){
				var fieldList = data.list;
				g_messageConfig.userDefFieldValue = fieldList;	// 전역의 메시지 정보에 사용자 정의 필드 최초값 저장
				
				$(fieldList).each(function(idx, item){
					var fieldObj = $("[name=UserForm_"+item.UserFormID+"]");
					
					//체크박스와 라디오 버튼은 UserFormID와 value로 식별
					if(fieldObj.attr("type") == "checkbox"){
						var checkboxVal = item.FieldValue.slice(1, item.FieldValue.length -1);
						if (item.FieldValue && item.FieldValue != '' && item.FieldValue.indexOf(";")!=-1){
							var valueArr = checkboxVal.split(';');
							$.each(valueArr, function(checkBoxIndex, checkedItem){
								$("[name=UserForm_"+item.UserFormID+"][value=" + checkedItem + "]").prop("checked", true);
							});
						} else {
							//단일 체크박스일경우 라디오와 동일하게 처리
							$("[name=UserForm_"+item.UserFormID+"][value=" + checkboxVal + "]").prop("checked", true);
						}
					} else if (fieldObj.attr("type") == "radio"){
						$("input[type=radio][name=UserForm_"+item.UserFormID+"][value=" + item.FieldValue + "]").prop("checked", true);
					} else if(pPageType == "View" && !fieldObj.is("select") && fieldObj.attr("type") != "text"){
						fieldObj.html(item.FieldValue.replaceAll("\n", "<br>"));
					} else {
						fieldObj.val(item.FieldValue);
					}
				});
				/*
				if(pPageType == "View"){
					$("#divUserDefField [type=radio],#divUserDefField [type=checkbox]").each(function(){ 
						$(this).attr("disabled", true);
						$(this).closest("span").find("label span").eq(0).attr("style", "background-color: #fff !important");
						$(this).on("click", function(){ return false; });
						
						if (g_boardConfig.IsContents == "Y"){
							$(this).addClass("ca_text");
						}
						else{
							 $(this).closest("span").find("label span").eq(0).attr("style", "background-color: #fff !important");
						}
					});
					
					$("#divUserDefField select").each(function(){ 
						$(this).attr("style", "pointer-events: none");
						if (g_boardConfig.IsContents == "Y"){
							$(this).attr("style", "background:#f3f3f3").addClass("ca_text");
						}
					});
				}*/
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/selectUserDefFieldValue.do", response, status, error);
			}
		}).done(function(){
			coviInput.init();
		});
	},
	//사용자 정의 필드값 수정
	setUserDefFieldValue: function(pFolderID, pMessageID, pVersion, pUserFormID, target) {
		if (pMessageID == "undefined" || !pMessageID ) return false;

		var seletedVal = '';
		if (target.type == 'checkbox'){
			$.each($("input[name=UserForm_"+pUserFormID+"]:checked"), function(idx, el){ seletedVal += ((idx > 0) ? ';' : '') + el.value });	
			if (seletedVal.right(1) != ';') seletedVal += ';';
			if (seletedVal.left(1) != ';') seletedVal = ';' + seletedVal;
		}
		else {
			seletedVal = target.value;
		}
		
		if ($(target).attr("data-required") == 'Y' && seletedVal == ''){		// 필수항목인 경우, 값이 없으면
			Common.Warning(Common.getDic("msg_EnterTheRequiredValue").replace('{0}',$(target).closest('.txt').siblings(".tit").find('span').text()),"Warning", function(){ // [{0}] 필수 입력값 입니다.
				if (target.type == 'checkbox'){		//체크박스는 마지막 남은 체크박스는 체크 상태로 되돌리고 종료.
					$(target).prop("checked", true);
				}
				else if (target.tagName == 'SELECT'){	//셀렉트박스는 클릭시 저장한 이전값으로 값 변경 후 종료 taget의 data영역에 oldvalue로 저장해놓음.
					target.value = target.dataset.oldvalue;
				}
			}); 
			return false;
		}
		
		if (target.tagName == 'SELECT') target.dataset.oldvalue = target.value;		// 값저장 전 셀렉트박스는 이전값을 갱신.
		
		var postData = {
			"folderID": pFolderID,
			"messageID": pMessageID,
			"version": pVersion,
			"userFormID": pUserFormID,
			"fieldValue": seletedVal
		}

		$.ajax({
			type: "POST",
			data: postData,
			url: "/groupware/board/updateUserDefFieldValue.do",
			success: function(data){
				var msg = Common.getDic("msg_37");
				//if (target.getAttribute('userformid') != '') msg = "["+ document.getElementById(target.getAttribute('userformid')).innerHTML +"] " + msg;
				Common.Indicator(msg, null, 1000);
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/updateUserDefFieldValue.do", response, status, error);
			}
		});
	},
	//Grid Overflow 항목 시작
	getGridOverflowCell: function( pHeaderType){
		var overflowCell = [];		//Grid Header
		
		switch( pHeaderType ){
		case "Total":
			overflowCell = [5,13];
			break;
		case "DocTotal":
			overflowCell = [17];
			break;
		case "Normal":
			overflowCell = [5];
			$(msgHeaderData).each(function(idx,obj){
				if(obj.key == "CreatorName"){
					overflowCell.push(idx);
				}
			});
			break;
		case "UserDefField":
			overflowCell = [];	
			break;
		case "MyOwnWrite":	//내가 작성한 게시
			overflowCell = [6];	
			break;
		case "MyInterest":	//즐겨찾기(Favorite)
			overflowCell = [7, 11];	
			 break;
		case "MyBooking":		//예약 게시
			overflowCell = [7];	
			break;
		case "RequestModify":
			overflowCell = [11];	
			break;
		case "Scrap":
			overflowCell = [6];	
			break;
		case "OnWriting":
			overflowCell = [7, 11];
			break;
		case "Approval":
			overflowCell = [11];
			break;
		case "Doc":
			overflowCell = [17];
			break;
		case "DocAuth":	//문서권한
			overflowCell = [13];
			break;
		case "DistributeDoc":	//문서 배포
			$(msgHeaderData).each(function(idx,obj){
				if(obj.key == "DistributerName"){
					overflowCell = [idx];
				}
			});
			break;
		case "CheckIn":	
			overflowCell = [15];
			break;
		case "CheckOut":
			overflowCell = [15];
			break;
		case "DocOwner":
			overflowCell = [15];
			break;
		case "DocFavorite":
			overflowCell = [15];
			break;
		default:
			break;
		}
		return overflowCell;
	},
	
	//Grid Header 항목 시작
	getGridHeader: function( pHeaderType , pBoxType, pFolderID){
		var headerData = null;		//Grid Header
		
		var categoryFlag = g_boardConfig.UseCategory == "Y"?true:false;				//카테고리
		var userDefFieldFlag = g_boardConfig.UseUserForm == "Y"?true:false;			//사용자 정의 필드
		var linkURLFlag = g_boardConfig.FolderType == "LinkSite"?true:false;			//링크게시판 URL
		
		//개별호출-일괄호출
		Common.getDicList(["lbl_no2","lbl_BoardCate2","lbl_subject","lbl_Register","lbl_RegistDate", "lbl_CreateDates", "lbl_ReadCount"
		                   ,"lbl_DocNo","lbl_Authority","lbl_RegistDept","lbl_Owner"
		                   ,"lbl_RevisionDate","lbl_FieldNm","lbl_FieldType","lbl_Limit2","lbl_FieldSize","lbl_OptionCnt","lbl_DisplayList","lbl_ListSearchItem","lbl_surveyIsRequire"
		                   ,"lbl_BoardCate2","lbl_Booking_Date","lbl_ProcessContents","lbl_State","lbl_State2","lbl_ScrapDate"
		                   ,"lbl_RevisionDate","lbl_RequestSummary","lbl_ApproveDate","lbl_Distributor","lbl_Reason"
		                   ,"lbl_ReceiveDate", "lbl_Request", "lbl_Requester","lbl_RequestDate","lbl_RequestContent","lbl_Mail_ReceiptNotification"
		                   ,"lbl_DistributionDate","lbl_RegistDept","lbl_Owner"
		                   ,"lbl_Registor","lbl_Approval", "lbl_Deny", "lbl_Rejected","lbl_Lock","lbl_RegistReq","lbl_TempSave","lbl_delete", "lbl_ReadAcl", "lbl_ModifyAcl", "lbl_DeleteAcl"
		                   ,"lbl_Binder","lbl_URL", "lbl_ReasonForProcessing", "lbl_Confirm","lbl_ApprovalStatus"]);
		
		viewIcon = $('<span class="icoDocList icoView"><span class="toolTip">' + coviDic.dicMap["lbl_ReadAcl"] + '</span></span>');	//조회권한
		modifyIcon = $('<span class="icoDocList icoWrite"><span class="toolTip">' + coviDic.dicMap["lbl_ModifyAcl"] + '</span></span>');//수정권한
		deleteIcon = $('<span class="icoDocList icoDel"><span class="toolTip">' + coviDic.dicMap["lbl_DeleteAcl"] + '</span></span>');	//삭제권한

		switch( pHeaderType ){
		case "Total":
			headerData = [ 
	         	{key:'chk',			label:'chk', width:'1', align:'center', formatter: 'checkbox', display:false,hideFilter : 'Y'},
	        	{key:'MessageID',	label:coviDic.dicMap["lbl_no2"], width:'5', align:'center', 
	         		formatter:function(){
	         			return board.formatTopNotice(this, g_boardConfig.UseTopNotice);	//상단공지 사용 여부 
	         		}
	        	},		//번호
	        	{key:'FolderID',	label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Seq',			label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Step',		label:'Step', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FileCnt',		label:' ', width:'1', align:'left', hideFilter : 'Y',
	        		formatter:function(){
	        			return board.formatFileAttach(this);
	        		}
	        	},
	        	{key:'Depth',		label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FolderName',  label:coviDic.dicMap["lbl_BoardCate2"], width:'5', align:'center',	// 게시분류
	        		formatter:function(){ 
	        			return board.formatFolderName(this);
	        		}
	        	},
	        	{key:'Subject',  	label:coviDic.dicMap["lbl_subject"], width:'20', align:'left',		//제목
	        		formatter:function(){ 
	        			return board.formatSubjectName(this, g_boardConfig.UseIncludeRecentReg, g_boardConfig.RecentlyDay); //최근게시 사용여부, 최근 게시 기준일
	        		}
	        	},
	        	{key:'MsgState', 	align:'center', display:false,hideFilter : 'Y'},
	        	{key:'DeleteDate', 	align:'center', display:false,hideFilter : 'Y'},
	        	{key:'CreatorCode', align:'center', display:false,hideFilter : 'Y'},
	        	{key:'CreateDate', align:'center', display:false,hideFilter : 'Y'},
	        	{key:'CreatorName',  label:coviDic.dicMap["lbl_Register"], width:'5', align:'center', 
	        		formatter: function(){
	        			if(this.item.UseAnonym == "Y"){
							return this.item.CreatorName;							
						}else{
							return coviCtrl.formatUserContext("List", this.item.CreatorName, this.item.CreatorCode, this.item.MailAddress);
						}
	        		}},
				{key:'RegistDate',	label:coviDic.dicMap["lbl_RegistDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'8', align:'center', formatter: function(){
					return CFN_TransLocalTime(this.item.RegistDate);
				}, dataType:'DateTime'}
				/*,{key:'ReadCnt',		label:coviDic.dicMap["lbl_ReadCount"], width:'3', align:'center'}*/
	        ];
			break;
		case "DocTotal":
			headerData =[ 
	         	{key:'chk', label:'chk', width:'1', align:'center', formatter: 'checkbox', display:false,hideFilter : 'Y'},
	        	{key:'MessageID',  label:'MessageID', display:false, hideFilter : 'Y'},
	        	{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FolderPath',  label:'FolderPath', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'MenuID',  label:'MenuID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Seq',  label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Step',  label:'Step', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Depth',  label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'IsCheckOut',  label:'IsCheckOut', display:false, hideFilter : 'Y'},
	        	{key:'Version',  label:' ', width:'3', align:'center', formatter:function(){
	        			return board.formatVersion(this);
	        		}
	        	},
	        	{key:'FolderName',  label:coviDic.dicMap["lbl_BoardCate2"], width:'5', align:'center',
	        		formatter:function(){
	        			return board.formatFolderName(this); 
	        		}
	        	},
	        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'15', align:'left', formatter:function(){ 
	        			return board.formatSubjectName(this);
	        		}
	        	},
	        	{key:'Number',  label:coviDic.dicMap["lbl_DocNo"], width:'7', align:'center'},
	        	{key:'IsCheckOut',  label:' ', width:'2', align:'center', sort:false,  addClass:"bodyTdFile", formatter:function(){
	        			return board.formatCheckOut(this);
	        		}
	        	},
	        	{key:'AclList',  label:coviDic.dicMap["lbl_Authority"], width:'7', align:'center', sort:false,  addClass:"bodyTdFile", formatter:function(){
	        			return board.formatAclList(this);
	        		}
	        	},
	        	{key:'RegistDeptName', label:coviDic.dicMap["lbl_RegistDept"],width:'7', align:'center',
	        		formatter: function(){ return this.item.RegistDeptName;
	        	}},
	        	{key:'RegistDept', label:' ', display:false, hideFilter : 'Y'},
	        	{key:'OwnerName',  label:coviDic.dicMap["lbl_Owner"], width:'5', align:'center', formatter: function(){
        			return coviCtrl.formatUserContext("List", this.item.OwnerName, this.item.OwnerCode, this.item.MailAddress);
        		}},
	        	{key:'RevisionDate', label:coviDic.dicMap["lbl_RevisionDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'7', align:'center', sort:'desc', formatter: function(){
					return CFN_TransLocalTime(this.item.RevisionDate);
				}, dataType:'DateTime'},
	        	{key:'MsgType', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'MsgState', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'DeleteDate', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'CreaterDepth', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'OwnerCode', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'',  label:' ', width:'3', sort: false,  addClass:"bodyTdFile", formatter: function() {
	        		return board.formatContextMenu(this);
	        	}}
	        ];
			break;
		case "Normal":
			//사용자 정의 필드 이전의 컬럼헤더
			var beforeUserDefField = [ 
	         	{key:'chk',			label:'chk', width:'1', align:'center', formatter: 'checkbox'},
	        	{key:'MessageID',	label:coviDic.dicMap["lbl_no2"], width:'5', align:'center',
	         		formatter:function(){
	         			return board.formatTopNotice(this, g_boardConfig.UseTopNotice);	//상단공지 사용 여부 
	         		}
	        	},		//번호
	        	{key:'FolderID',	label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Seq',			label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Step',		label:'Step', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FileCnt',		label:' ', width:'1', align:'left', hideFilter : 'Y',
	        		formatter:function(){
	        			return board.formatFileAttach(this);
	        		}
	        	},
	        	{key:'Depth',		label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'CategoryName',label:coviDic.dicMap["lbl_BoardCate2"], display: categoryFlag, width:'4', align:'center'},
	        	{key:'Subject',  	label:coviDic.dicMap["lbl_subject"], width:'12', align:'left',		//제목
	        		formatter:function(){ 
	        			return board.formatSubjectName(this, g_boardConfig.UseIncludeRecentReg, g_boardConfig.RecentlyDay); //최근게시 사용여부, 최근 게시 기준일
	        		}
	        	},
	        	{key:'LinkURL',  	label:coviDic.dicMap["lbl_URL"], display: linkURLFlag, width:'12', align:'left',		//LINK
	        		formatter:function(){ 
	        			return board.formatLinkSiteURL(this); //URL 클릭
	        		}
	        	},	        	
	        	{key:'MsgState', 	align:'center', display:false, hideFilter : 'Y'},
	        	{key:'DeleteDate', 	align:'center', display:false, hideFilter : 'Y'},
	        	{key:'CreatorCode', align:'center', display:false, hideFilter : 'Y'}
	        ];
			
			//사용자 정의 필드 이후의 컬럼 헤더
			var afterUserDefField = [
				{key:'CreatorName',  label:coviDic.dicMap["lbl_Register"], width:'5', align:'center', addClass:"bodyTdFile",
					formatter: function(){
						if(this.item.UseAnonym == "Y" || this.item.UsePubDeptName == "Y"){
							return this.item.CreatorName;							
						}else{
							return coviCtrl.formatUserContext("List", this.item.CreatorName, this.item.CreatorCode, this.item.MailAddress);
						}
					}
				},
				{key:'RegistDate',	label:coviDic.dicMap["lbl_RegistDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'8', align:'center', formatter: function(){
					return CFN_TransLocalTime(this.item.RegistDate);
				}, dataType:'DateTime'}
			];
			if(bizSection != 'Board' || g_boardConfig.UseReadCnt == "Y"){
				afterUserDefField = afterUserDefField.concat(
						[{key:'ReadCnt', label:coviDic.dicMap["lbl_ReadCount"], width:'3', align:'center'}]);
			}
			
			headerData = beforeUserDefField;
			//사용자 정의 필드 추가 구간
			if(pFolderID != undefined && pFolderID != ""){
				//FolderID가 있을경우 board_config 옵션에 따라서 확장필드 검색 및 카테고리 표기하도록 처리
				if(userDefFieldFlag){
					//g_boardConfig참조
					headerData = headerData.concat(board.getUserDefFieldHeader(pFolderID));
				}
			}
			
			headerData = headerData.concat(afterUserDefField);
			if (g_boardConfig.SortCols != null && g_boardConfig.SortCols != "" ){// 그리드 sort 재정렬
				var arrList = g_boardConfig.SortCols.split(",");
				
				var tmpHeaderData = [];
				tmpHeaderData.push(headerData[0]);
				for (var i=0 ; i < arrList.length; i++){
					var key = arrList[i];
					$.each(headerData, function(i, item){
		    			if (key == item.id || key == item.key){
		    				tmpHeaderData.push(item);
		    			}
		    		});
				}
				headerData=tmpHeaderData;
			}
			break;
		case "UserDefField":
			headerData =[ 
	         	{key:'chk', label:'chk', width:'1', align:'center', formatter: 'checkbox'},
	       		{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	       		{key:'UserFormID',  label:'UserFormID', align:'center', display:false, hideFilter : 'Y'},
	       		{key:'IsOption',  label:'IsOption', align:'center', display:false, hideFilter : 'Y'},
	       		{key:'FieldName',  label:'FieldName', display:false, hideFilter : 'Y'},
	       		{key:'SortKey',  label:'SortKey', display:false, sort:'asc'},
	       		{key:'DisplayName',  label:coviDic.dicMap["lbl_FieldNm"], width:'3', align:'left',
	       			formatter: function(){ return CFN_GetDicInfo(this.item.FieldName) }
	       		},
	       		{key:'FieldType',  label:coviDic.dicMap["lbl_FieldType"], width:'3', align:'center'},
	       		{key:'FieldLimitCnt',  label:coviDic.dicMap["lbl_Limit2"], width:'2', align:'center'},
	       		{key:'FieldSize',  label:coviDic.dicMap["lbl_FieldSize"], width:'3', align:'center'},
	       		{key:'OptionCnt',  label:coviDic.dicMap["lbl_OptionCnt"], width:'2', align:'center'},
	       		{key:'IsList',  label:coviDic.dicMap["lbl_DisplayList"], width:'3', align:'center'},
	       		{key:'IsSearchItem',  label:coviDic.dicMap["lbl_ListSearchItem"], width:'3', align:'center'},
	       		{key:'IsCheckVal',  label:coviDic.dicMap["lbl_surveyIsRequire"], width:'3', align:'center'}
	       ];
			break;
		case "MyOwnWrite":	//내가 작성한 게시
			headerData =[ 
	         	{key:'chk', label:'chk', width:'2', align:'center', formatter: 'checkbox'},
	        	{key:'MessageID',  label:coviDic.dicMap["lbl_no2"], width:'5', align:'center'},		//번호
	        	{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Seq',  label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Step',  label:'Step', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Depth',  label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FileCnt',		label:' ', width:'1', align:'left', hideFilter : 'Y',
	        		formatter:function(){
	        			return board.formatFileAttach(this);
	        		}
	        	},
	        	{key:'FolderName',  label:coviDic.dicMap["lbl_BoardCate2"], width:'7', align:'center', 
	        		formatter:function(){
	        			return board.formatFolderName(this); 
	        		}
	        	},
	        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'20', align:'left',		//제목
	        		formatter:function(){
	        			return board.formatSubjectName(this); 
	        		}
	        	},
	        	{key:'MsgState',  label:coviDic.dicMap["lbl_State2"], width:'7', align:'center',
	        		formatter:function(){ 
	        			return board.formatMessageState(this); 
	        		}
	        	},
	        	{key:'DeleteDate', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'CreatorCode', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'RegistDate',  label:coviDic.dicMap["lbl_RegistDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'10', align:'center', formatter: function(){
					return CFN_TransLocalTime(this.item.RegistDate);
				}, dataType:'DateTime'},
	        	{key:'ReadCnt',  label:coviDic.dicMap["lbl_ReadCount"], width:'7', align:'center'}
	        ];
			break;
		case "MyInterest":	//즐겨찾기(Favorite)
			headerData =[ 
	         	{key:'chk', label:'chk', width:'1', align:'center', formatter: 'checkbox'},
	        	{key:'MessageID',  label:coviDic.dicMap["lbl_no2"], width:'5', align:'center', sort:'desc'},
	        	{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'MenuID',  label:'MenuID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Seq',  label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Step',  label:'Step', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Depth',  label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FileCnt',		label:' ', width:'1', align:'left',
	        		formatter:function(){
	        			return board.formatFileAttach(this);
	        		}
	        	},
	        	{key:'FolderName',  label:coviDic.dicMap["lbl_BoardCate2"], width:'7', align:'left'},
	        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'20', align:'left' },
	        	{key:'CreatorCode', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'CreatorName',  label:coviDic.dicMap["lbl_Register"], width:'10', align:'center',
	        		formatter: function(){
	        			return coviCtrl.formatUserContext("List", this.item.CreatorName, this.item.CreatorCode, this.item.MailAddress);
	        		}},
	        	{key:'RegistDate',  label:coviDic.dicMap["lbl_RegistDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'10', align:'center', formatter: function(){
					return CFN_TransLocalTime(this.item.RegistDate);
				}, dataType:'DateTime'},
	        	{key:'ReadCnt',  label:coviDic.dicMap["lbl_ReadCount"], width:'3', align:'center'}
	        ];
			break;
		case "MyBooking":		//예약 게시
			headerData =[ 
	         	{key:'chk', label:'chk', width:'2', align:'center', formatter: 'checkbox'},
	        	{key:'MessageID',  label:coviDic.dicMap["lbl_no2"], width:'5', align:'center'},
	        	{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'MenuID',  label:'MenuID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Seq',  label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Step',  label:'Step', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Depth',  label:'Depth', align:'center', display:false,  hideFilter : 'Y'},
	        	{key:'FileCnt',		label:' ', width:'1', align:'left', hideFilter : 'Y',
	        		formatter:function(){
	        			return board.formatFileAttach(this);
	        		}
	        	},
	        	{key:'FolderName',  label:coviDic.dicMap["lbl_BoardCate2"], width:'7', align:'center',
	        		formatter:function(){
	        			return board.formatFolderName(this); 
	        		}
	        	},
	        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'20', align:'left',
	        		formatter:function(){ 
	        			return board.formatSubjectName(this); 
	        		}
	        	},
	        	{key:'MsgState',  label:coviDic.dicMap["lbl_State2"], width:'7', align:'center',
	        		formatter:function(){ 
	        			return board.formatMessageState(this); 
	        		}
	        	},
	        	{key:'DeleteDate', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'CreatorCode', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'CreateDate',  label:coviDic.dicMap["lbl_CreateDates"]  + Common.getSession("UR_TimeZoneDisplay"), width:'10', align:'center', formatter: function(){
					return CFN_TransLocalTime(this.item.CreateDate);
				}, dataType:'DateTime'},
				{key:'ReservationDate',  label:coviDic.dicMap["lbl_Booking_Date"]  + Common.getSession("UR_TimeZoneDisplay"), width:'10', align:'center', formatter: function(){
					return CFN_TransLocalTime(this.item.ReservationDate);
				}, dataType:'DateTime'}
	        ];
			break;
		case "RequestModify":
			headerData =[ 
	         	{key:'chk', label:'chk', width:'1', align:'center', formatter: 'checkbox'},
	        	{key:'MessageID',  label:coviDic.dicMap["lbl_no2"], width:'5', align:'center'},
	        	{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'MenuID',  label:'MenuID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Seq',  label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Step',  label:'Step', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Depth',  label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'RequestID',  label:'RequestID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'DeleteDate', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'FolderName',  label:coviDic.dicMap["lbl_BoardCate2"], width:'7', align:'center',
	        		formatter:function(){
	        			return board.formatFolderName(this); 
	        		}
	        	},
	        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'20', align:'left',
	        		formatter:function(){ 
	        			return board.formatSubjectName(this); 
	        		}
	        	},
	        	{key:'RequestorName',  label:coviDic.dicMap["lbl_Requester"], width:'6', align:'center',
	        		formatter: function(){
	        			return coviCtrl.formatUserContext("List", this.item.RequestorName, this.item.RequestorCode, this.item.RequestorMailAddress);
	        		}},
	        	{key:'RequestDate',  label:coviDic.dicMap["lbl_RequestDate"]  + Common.getSession("UR_TimeZoneDisplay"), width:'6', align:'center', formatter: function(){
					return CFN_TransLocalTime(this.item.RequestDate);
				}, dataType:'DateTime'},
	        	{key:'RequestMessage',  label:coviDic.dicMap["lbl_RequestContent"], width:'10', align:'center'},
	        	{key:'AnswerContent',  label:coviDic.dicMap["lbl_ProcessContents"], width:'10', align:'left'},
	        	{key:'RequestStatus',  label:coviDic.dicMap["lbl_State"], width:'6', align:'center',
	        		formatter:function(){
	        			return board.formatRequestStatus(this);
	        		}
	        	}
	        ];
			break;
		case "Scrap":
			headerData =[ 
	         	{key:'chk', label:'chk', width:'2', align:'center', formatter: 'checkbox'},
	        	{key:'MessageID',  label:coviDic.dicMap["lbl_no2"], width:'5', align:'center'},		//번호
	        	{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Seq',  label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Step',  label:'Step', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Depth',  label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FileCnt',		label:' ', width:'1', align:'left', hideFilter : 'Y',
	        		formatter:function(){
	        			return board.formatFileAttach(this);
	        		}
	        	},
	        	{key:'FolderName',  label:coviDic.dicMap["lbl_BoardCate2"], width:'7', align:'center', 
	        		formatter:function(){
	        			return board.formatFolderName(this); 
	        		}
	        	},
	        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'20', align:'left',		//제목
	        		formatter:function(){
	        			return board.formatSubjectName(this); 
	        		}
	        	},
	        	{key:'DeleteDate', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'CreatorCode', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'RegistDate',  label:coviDic.dicMap["lbl_ScrapDate"]  + Common.getSession("UR_TimeZoneDisplay"), width:'10', align:'center', formatter: function(){
					return CFN_TransLocalTime(this.item.RegistDate);
				}, dataType:'DateTime'}		//스크랩 일시
	        ];
			break;
		case "OnWriting":
			headerData =[ 
	         	{key:'chk', label:'chk', width:'2', align:'center', formatter: 'checkbox'},
	        	{key:'MessageID',  label:coviDic.dicMap["lbl_no2"], width:'5', align:'center'},
	        	{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'MenuID',  label:'MenuID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Seq',  label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Step',  label:'Step', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Depth',  label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FileCnt',		label:' ', width:'1', align:'left', hideFilter : 'Y',
	        		formatter:function(){
	        			return board.formatFileAttach(this);
	        		}
	        	},
	        	{key:'FolderName',  label:coviDic.dicMap["lbl_BoardCate2"], width:'7', align:'center',
	        		formatter:function(){
	        			return board.formatFolderName(this); 
	        		}
	        	},
	        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'20', align:'left',		//제목
	        		formatter:function(){
	        			return board.formatSubjectName(this); 
	        		}
	        	},
	        	{key:'CreatorCode', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'CreatorName',  label:coviDic.dicMap["lbl_Register"], width:'10', align:'center',
	        		formatter: function(){
	        			return coviCtrl.formatUserContext("List", this.item.CreatorName, this.item.CreatorCode, this.item.MailAddress);
	        		}},
	        	{key:'RegistDate',  label:coviDic.dicMap["lbl_RegistDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'10', align:'center', formatter: function(){
					return CFN_TransLocalTime(this.item.RegistDate);
				}, dataType:'DateTime'}
	        ];
			break;
		case "Approval":
			headerData =[ 
	         	{key:'chk', label:'chk', width:'1', align:'center', formatter: 'checkbox', disabled : function(){
					if(boxType != 'Receive' || (this.item.State > 0 && this.item.MsgState == 'R')){
						return false;
					}else{
						return true;
					}
				 }},
	        	{key:'MessageID',  label:'', align:'center', display:false, hideFilter : 'Y' },
	        	{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'ProcessID',  label:'ProcessID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Seq',  label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Step',  label:'Step', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Depth',  label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FolderName',  label:coviDic.dicMap["lbl_BoardCate2"], width:'7', align:'center',
	        		formatter:function(){ 
	        			return board.formatFolderName(this);
	        		}
	        	},
	        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'15', align:'left',		//제목
	        		formatter:function(){
	        			return board.formatSubjectName(this); 
	        		}
	        	},
	        	{key:'DeleteDate', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'CreatorCode', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'CreatorName',  label:coviDic.dicMap["lbl_Register"], width:'10', align:'center',
	        		formatter: function(){
	        			return coviCtrl.formatUserContext("List", this.item.CreatorName, this.item.CreatorCode, this.item.MailAddress);
	        		}},
	        	{key:'RegistDate',  label:coviDic.dicMap["lbl_RegistDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'7', align:'center', sort: 'desc' , formatter: function(){
					return CFN_TransLocalTime(this.item.RegistDate);
				}, dataType:'DateTime'},
	        	{key:'ApprovalStatus',  label:coviDic.dicMap["lbl_ApprovalStatus"], width:'5', sort: false, align:'center', formatter:function(){
	        			return board.formatApprovalStatus(this);
	        		}
	        	},
	        ];
			break;
		case "Doc":
			headerData =[ 
	         	{key:'chk', label:'chk', width:'1', align:'center', formatter: 'checkbox'},
	        	{key:'MessageID',  label:'MessageID', display:false, hideFilter : 'Y'},
	        	{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FolderPath',  label:'FolderPath', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'MenuID',  label:'MenuID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Seq',  label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Step',  label:'Step', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Depth',  label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FolderName',  label:'FolderName', display:false, hideFilter : 'Y'},
	        	{key:'IsCheckOut',  label:'IsCheckOut', display:false, hideFilter : 'Y'},
	        	{key:'Version',  label:' ', width:'3', align:'center', formatter:function(){
	        			return board.formatVersion(this);
	        		}
	        	},
	        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'15', align:'left', formatter:function(){ 
	        			return board.formatSubjectName(this);
	        		}
	        	},
	        	{key:'Number',  label:coviDic.dicMap["lbl_DocNo"], width:'7', align:'center'},
	        	{key:'IsCheckOut',  label:' ', width:'2', align:'center', sort:false,  addClass:"bodyTdFile", formatter:function(){
	        			return board.formatCheckOut(this);
	        		}
	        	},
	        	{key:'AclList',  label:coviDic.dicMap["lbl_Authority"], width:'7',sort:false, align:'center',  addClass:"bodyTdFile", formatter:function(){
	        			return board.formatAclList(this);
	        		}
	        	},
	        	{key:'RegistDept', label:coviDic.dicMap["lbl_RegistDept"],width:'7', align:'center',
	        		formatter: function(){ return this.item.RegistDeptName;
	        	}},
	        	{key:'RegistDept', label:'', display:false, hideFilter : 'Y'},
	        	{key:'OwnerName',  label:coviDic.dicMap["lbl_Owner"], width:'5', align:'center', formatter: function(){
        			return coviCtrl.formatUserContext("List", this.item.OwnerName, this.item.OwnerCode, this.item.MailAddress);
        		}},
	        	{key:'RevisionDate', label:coviDic.dicMap["lbl_RevisionDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'7', align:'center', sort:'desc', formatter: function(){
					return CFN_TransLocalTime(this.item.RevisionDate);
				}, dataType:'DateTime'},
	        	{key:'MsgType', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'MsgState', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'DeleteDate', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'CreaterDepth', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'OwnerCode', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'',  label:' ', width:'3', sort: false, addClass:"bodyTdFile", formatter: function() {
	        		return board.formatContextMenu(this);
	        	}}
	        ];
			break;
		case "DocAuth":	//문서권한
			var beforeHeaderDataDocAuth =[ 
	         	{key:'chk', label:'chk', width:'1', align:'center', formatter: 'checkbox'},
	        	{key:'MessageID',  label:'MessageID', display:false, hideFilter : 'Y'},
	        	{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'MenuID',  label:'MenuID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FolderName',  label:'FolderName', display:false, hideFilter : 'Y'},
	        	{key:'IsCheckOut',  label:'IsCheckOut', display:false, hideFilter : 'Y'},
	        	{key:'Version',  label:' ', width:'3', align:'center', formatter:function(){
	        			return board.formatVersion(this);
	        		}
	        	},
	        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'15', align:'left', formatter:function(){ 
	        			return board.formatSubjectName(this);
	        		}
	        	},
	        	{key:'Number',  label:coviDic.dicMap["lbl_DocNo"], width:'7', align:'center'},
	        	{key:'IsCheckOut',  label:' ', width:'2', align:'center', sort:false,  addClass:"bodyTdFile", formatter:function(){
	        			return board.formatCheckOut(this);
	        		}
	        	},
	        	{key:'AclList',  label:coviDic.dicMap["lbl_Authority"], width:'7', sort:false, align:'center', addClass:"bodyTdFile", formatter:function(){
	        			var divIcoWrap = $('<div class="icoWrap"/>');
	        			var aclList = this.item.RequestAclList;
	        			
	        			if(aclList.indexOf("R") != -1){ divIcoWrap.append(viewIcon); }
	        			if(aclList.indexOf("M") != -1){ divIcoWrap.append(modifyIcon); }
	        			if(aclList.indexOf("D") != -1){ divIcoWrap.append(deleteIcon); }
	        			
	        			return divIcoWrap.clone().wrapAll("<div/>").parent().html();
	        		}
	        	},
	        	{key:'RegistDept', label:'', display:false, hideFilter : 'Y'},
	        	{key:'RequestMessage', label:coviDic.dicMap["lbl_RequestSummary"], width:'7', align:'center'},
	        	{key:'RequestorName',  label:coviDic.dicMap["lbl_Requester"], width:'5', align:'center', formatter: function(){
        			return coviCtrl.formatUserContext("List", this.item.RequestorName, this.item.RequestorCode, this.item.RequestorMailAddress);
        		}},
        		
	        	{key:'RequestDate', label:coviDic.dicMap["lbl_ApproveDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'10', align:'center', sort:'desc', formatter: function(){
					return CFN_TransLocalTime(this.item.RequestDate);
				}, dataType:'DateTime'}
        		];

	        	headerData = beforeHeaderDataDocAuth;
				
				var switchingHeaderDocAuth = [];
				if(pBoxType == "Receive"){
					switchingHeaderDocAuth = [
						{key:'ActType', label:coviDic.dicMap["lbl_State"], width:'5', align:'center',  formatter:function(){
							//승인유형 ( A: 승인, R: 요청, D:거부 )
							if(this.item.ActType =="R"){
								return coviDic.dicMap["lbl_Request"];
							}else if(this.item.ActType =="A"){
								return coviDic.dicMap["lbl_Approval"];
							}else if(this.item.ActType =="D"){
								return coviDic.dicMap["lbl_Deny"];
							}else{
								return this.item.ActType;
							}
							
						}},
						{key:'', label:coviDic.dicMap["lbl_Confirm"], width:'7', align:'center', formatter:function(){
								var rowObj = this.item;	
								var btn = $("<a class=\"btnTypeDefault btnTypeChk\" onclick=\"javascript:board.approveAuthPopup("+ rowObj.FolderID +", "+ rowObj.MessageID +", "+ rowObj.Version +", "+ rowObj.RequestID +", '"+ rowObj.RequestorCode +"')\">확인</a>");
			        			return btn.clone().wrapAll("<div/>").parent().html();
			        		}
			        	},
					];
				} else {
					switchingHeaderDocAuth = [
   						{key:'ActType', label:coviDic.dicMap["lbl_State"], width:'5', align:'center',  formatter:function(){
							//승인유형 ( A: 승인, R: 요청, D:거부 )
							if(this.item.ActType =="R"){
								return coviDic.dicMap["lbl_Request"];
							}else if(this.item.ActType =="A"){
								return coviDic.dicMap["lbl_Approval"];
							}else if(this.item.ActType =="D"){
								return coviDic.dicMap["lbl_Deny"];
							}else{
								return this.item.ActType;
							}							
						}},
						{key:'ActMessage', label:coviDic.dicMap["lbl_ReasonForProcessing"], width:'10', align:'center'},
					];
				}
				
				headerData = headerData.concat(switchingHeaderDocAuth);
				
				var afterHeaderDataDocAuth = [
					{key:'DeleteDate', align:'left', display:false, hideFilter : 'Y'},
					{key:'CreaterDepth', align:'left', display:false, hideFilter : 'Y'},
					{key:'OwnerCode', align:'left', display:false, hideFilter : 'Y'},                 
				];
				
				headerData = headerData.concat(afterHeaderDataDocAuth);
			break;
		case "DistributeDoc":	//문서 배포
			var beforeHeaderData = [
				{key:'chk', label:'chk', width:'1', align:'center', formatter: 'checkbox'},
				{key:'MessageID',  label:'MessageID', display:false, hideFilter : 'Y'},
				{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
				{key:'MenuID',  label:'MenuID', align:'center', display:false, hideFilter : 'Y'},
				{key:'Seq',  label:'Seq', align:'center', display:false, hideFilter : 'Y'},
				{key:'Step',  label:'Step', align:'center', display:false, hideFilter : 'Y'},
				{key:'Depth',  label:'Depth', align:'center', display:false, hideFilter : 'Y'},
				{key:'FolderName',  label:'FolderName', display:false, hideFilter : 'Y'},
				{key:'IsCheckOut',  label:'IsCheckOut', display:false, hideFilter : 'Y'},
				{key:'Version',  label:' ', width:'3', align:'center', formatter:function(){
						return board.formatVersion(this);
					}
				},
				{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'15', align:'left', formatter:function(){ 
						return board.formatSubjectName(this);
					}
				},
				{key:'Number',  label:coviDic.dicMap["lbl_DocNo"], width:'7', align:'center'},
				{key:'IsCheckOut',  label:' ', width:'2', align:'center', sort:false,  addClass:"bodyTdFile", formatter:function(){
						return board.formatCheckOut(this);
					}
				}
			];
			headerData = beforeHeaderData;
			
			var switchingHeader = [];
			if(pBoxType == "Receive"){
				switchingHeader = [
					{key:'DistributerName',  label:coviDic.dicMap["lbl_Distributor"], width:'10', align:'center', formatter: function(){
	        			return coviCtrl.formatUserContext("List", this.item.DistributerName, this.item.DistributerCode, this.item.MailAddress);
	        		}},
					{key:'DistributeMsg', label:coviDic.dicMap["lbl_Reason"], width:'7', align:'left'},	//사유
					{key:'DistributeDate', label:coviDic.dicMap["lbl_ReceiveDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'7', align:'center', sort:'desc', formatter: function(){
						return CFN_TransLocalTime(this.item.DistributeDate);
					}, dataType:'DateTime'}	//수신일시
				];
			} else {
				switchingHeader = [
					{key:'ReadCnt',  display:false, hideFilter : 'Y'},
					{key:'DisCnt', display:false, hideFilter : 'Y'},
					{key:'',  label:coviDic.dicMap["lbl_Mail_ReceiptNotification"], width:'5', sort: false, align:'center', formatter:function(){	//수신확인
							return this.item.DisReadCnt + "/" + this.item.DisCnt;
						}
					},
					{key:'DistributeDate', label: coviDic.dicMap["lbl_DistributionDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'7', align:'center', sort:'desc', formatter: function(){
						return CFN_TransLocalTime(this.item.DistributeDate);
					}, dataType:'DateTime'}
				];
			}
			headerData = headerData.concat(switchingHeader);
			
			var afterHeaderData = [
				{key:'MsgType', align:'left', display:false, hideFilter : 'Y'},
				{key:'DeleteDate', align:'left', display:false, hideFilter : 'Y'},
				{key:'CreaterDepth', align:'left', display:false, hideFilter : 'Y'},
				{key:'OwnerCode', align:'left', display:false, hideFilter : 'Y'}                    
			];
			
			headerData = headerData.concat(afterHeaderData);
			break;
		case "CheckIn":	
		case "CheckOut":
		case "DocOwner":
		case "DocFavorite":
			headerData =[ 
	         	{key:'chk', label:'chk', width:'1', align:'center', formatter: 'checkbox'},
	        	{key:'MessageID',  label:'MessageID', display:false, hideFilter : 'Y'},
	        	{key:'FolderID',  label:'FolderID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'MenuID',  label:'MenuID', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Seq',  label:'Seq', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Step',  label:'Step', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'Depth',  label:'Depth', align:'center', display:false, hideFilter : 'Y'},
	        	{key:'FolderName',  label:'FolderName', display:false, hideFilter : 'Y'},
	        	{key:'IsCheckOut',  label:'IsCheckOut', display:false, hideFilter : 'Y'},
	        	{key:'Version',  label:' ', width:'3', align:'center', formatter:function(){
	        			return board.formatVersion(this);
	        		}
	        	},
	        	{key:'Subject',  label:coviDic.dicMap["lbl_subject"], width:'15', align:'left',
	        		formatter:function(){ 
	        			return board.formatSubjectName(this);
	        		}
	        	},
	        	{key:'Number',  label:coviDic.dicMap["lbl_DocNo"], width:'7', align:'center'},
	        	{key:'IsCheckOut',  label:' ', width:'2', align:'center', sort:false,  addClass:"bodyTdFile", formatter:function(){
	        			return board.formatCheckOut(this);
	        		}
	        	},
	        	{key:'RegistDept', label:coviDic.dicMap["lbl_RegistDept"],width:'7', align:'center',
	        		formatter: function(){ return this.item.RegistDeptName;
	        	}},
	        	{key:'RegistDept', label:'', display:false, hideFilter : 'Y'},
	        	{key:'OwnerName',  label:coviDic.dicMap["lbl_Owner"], width:'10', align:'center', formatter: function(){
        			return coviCtrl.formatUserContext("List", this.item.OwnerName, this.item.OwnerCode, this.item.MailAddress);
        		}},
	        	{key:'RevisionDate', label:coviDic.dicMap["lbl_RevisionDate"] + Common.getSession("UR_TimeZoneDisplay"), width:'7', align:'center', sort:'desc', formatter: function(){
					return CFN_TransLocalTime(this.item.RevisionDate);
				}, dataType:'DateTime'},
	        	{key:'MsgType', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'DeleteDate', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'CreaterDepth', align:'left', display:false, hideFilter : 'Y'},
	        	{key:'OwnerCode', align:'left', display:false, hideFilter : 'Y'},
	        	
	        ];
			break;
		default:
			break;
		}
		return headerData;
	},
	
	//연결 URL 사용시 URL입력 input 표시
	changeIsUrl : function( pObj ){
		if($(pObj).val() == "Y"){
			$("#linkURL").show();
		} else {
			$("#linkURL").hide();
		}
	},
	
	
	/*****************************************************************************************************************************************/
	
	//게시글 삭제: BoardList.jsp, BoardView.jsp
	deleteMessage: function (pMode){
		var params = new Object();
		var messageIDs = '';
		var messageVers = '';
		
		if($("#messageGrid").length > 0 ){
			$.each(messageGrid.getCheckedList(0), function(i,obj){
				messageIDs += obj.MessageID + ';'
				messageVers += obj.Version + ';'
			});
		} else {
			messageIDs = messageID;
			messageVers = version;
		}
		
		params.bizSection = bizSection;
		params.messageID = messageIDs;
		params.comment = $("#hiddenComment").val();
		params.version = messageVers;
		params.folderID = folderID;

		//커뮤니티 
		if(CFN_GetQueryString("communityId") != "undefined" ){	//Community용 Parameter추가
			params.communityId = CFN_GetQueryString("communityId");
			params.CSMU = CFN_GetQueryString("CSMU");
		}else{
			params.CSMU = "X";
		}
		
	    $.ajax({
	    	type:"POST",
	    	url:"/groupware/board/deleteMessage.do",
	    	data: params,
	    	success:function(data){
	    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
	    			if(pMode != "simpleMake"){ // 간편 게시작성 상세 등록 취소시에는 삭제 코멘트 표시 안함
	    				Common.Inform(Common.getDic('msg_50')); // 삭제되었습니다.
	    			}
	    			
	    			if($("#messageGrid").length > 0){
	    				//BoardList에서 삭제시 Grid정보 재조회
	    				//messageGrid.reloadList();
	    				$('#btnRefresh').click();
	    			} else {
	    				if(g_boardConfig.FolderType == "Contents"){
	    					var url = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&folderID=" + folderID + "&menuID="+ menuID;
	    					
	    					if(CFN_GetQueryString("communityId") != "undefined" ){	//Community용 Parameter추가
	    						url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
	    					}
	    					
	    					CoviMenu_GetContent(url);
	    				} else {
	    					//상세보기에서 삭제했을 경우 목록으로 돌아감
		    				board.goFolderContents(g_urlHistory);	
	    				}
	    			}
	    		}else{
	    			if (data.message != ""){
	    				Common.Warning(data.message);//오류가 발생헸습니다.
	    			}
	    			else{
	    				Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	    			}	
	    		}
	    	},
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/board/deleteMessage.do", response, status, error);
	    	}
	    });
	},
	
	//게시글 신고: BoardView.jsp Context Menu에서 호출
	reportMessage: function (){
	    $.ajax({
	    	type:"POST",
	    	url:"/groupware/board/reportMessage.do",
	    	data:{
	    		"bizSection": bizSection
	    		,"messageID": messageID
	    		,"comment": $("#hiddenComment").val()
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			Common.Warning(data.message); // 신고처리 되었스빈다.
	    		} else{
	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	    		}
	    	},
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/board/reportMessage.do", response, status, error);
	    	}
	    });
	},
	
	//게시글 수정요청: BoardView.jsp Context Menu에서 호출
	requestModifyMessage: function (){
	    $.ajax({
	    	type:"POST",
	    	url:"/groupware/board/requestModifyMessage.do",
	    	data:{
	    		"bizSection": bizSection
	    		,"messageID": messageID
	    		,"folderID": folderID
	    		,"comment": $("#hiddenComment").val()
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			Common.Warning(data.message); // 수정 요청됐습니다.
	    		} else{
	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	    		}
	    	},
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/board/requestModifyMessage.do", response, status, error);
	    	}
	    });
	},
	
	//삭제, 신고, 수정요청 등을 할때 처리 사유 입력 팝업
	commentPopup : function(pMode) {
		var messageIDs = '';
		
		//게시글 목록이 있는 페이지의 경우 선택한 게시글의 MessageID를 설정
		if($("#messageGrid").length > 0 ){
			$.each(messageGrid.getCheckedList(0), function(i,obj){
				messageIDs += obj.MessageID + ';'
			});
		} else {
			//상세보기 페이지에서는 현재 선택된 게시글의 MessageID를 설정
			messageIDs = messageID;
		}
		
		//게시글 목록이 있는 페이지에서 체크박스를 선택하지 않았을 경우 경고 호출
		if(messageIDs == ''){
			Common.Warning(Common.getDic('msg_SelectTarget'), "Warning Dialog", function () { });          //대상을 선택해주세요.
			return;
		}
		
		if(pMode == 'lock') {
			Common.Confirm(Common.getDic("lbl_MessageLockConfirm"), 'Confirmation Dialog', function (result) {	
	            if (result) {
					//mode: delete, lock, unlock, restore
					//parent._CallBackMethod = new Function("board." + pMode + "Message()");
					parent._CallBackMethod = board[pMode + "Message"];
					//CHECK: 처리 이력 팝업 제목 다국어처리 필요
					parent.Common.open("", "commentPopup", Common.getDic('lbl_ReasonForProcessing'), "/groupware/board/goCommentPopup.do?mode=" + pMode, "300px", "230px", "iframe", true, null, null, true);
	            }
	        });
		} else {
			//mode: delete, lock, unlock, restore
			//parent._CallBackMethod = new Function("board." + pMode + "Message()");
			parent._CallBackMethod = board[pMode + "Message"];
			//CHECK: 처리 이력 팝업 제목 다국어처리 필요
			parent.Common.open("", "commentPopup", Common.getDic('lbl_ReasonForProcessing'), "/groupware/board/goCommentPopup.do?mode=" + pMode, "300px", "230px", "iframe", true, null, null, true);
		}
	},
	
	//조회자 목록 팝업: 관리자와 동일한 api호출
	viewerPopup : function() {
		var messageIDs = '';
		var messageVers = '';
		var folderIDs = '';
		
		//게시글 목록이 있는 페이지의 경우 선택한 게시글의 MessageID를 설정
		if($("#messageGrid").length > 0 ){
			$.each(messageGrid.getCheckedList(0), function(i,obj){
				messageIDs += obj.MessageID + ';'
				messageVers += obj.Version + ';'
				folderIDs += obj.FolderID + ';'
			});
		} else {
			//상세보기 페이지에서는 현재 선택된 게시글의 MessageID를 설정
			messageIDs = messageID;
			messageVers = version;
			folderIDs = folderID;
		}
		
		//게시글 목록이 있는 페이지에서 체크박스를 선택하지 않았을 경우 경고 호출
		if(messageIDs == ''){
			 Common.Warning(Common.getDic('msg_Common_03'), "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
	       return;
		}
		
		//CHECK: 처리 이력 팝업 제목 다국어처리 필요
		parent.Common.open("", "viewerPopup", Common.getDic("btn_readerList"), "/groupware/board/goViewerPopup.do?messageID=" + messageIDs+"&messageVer=" + messageVers+"&folderID=" + folderIDs + "&CLBIZ=" + CFN_GetQueryString("CLBIZ"), "550px", "600px", "iframe", true, null, null, true);
	},
	
	//조회자 목록 팝업: 관리자와 동일한 api호출
	historyPopup : function() {
		var messageIDs = '';
		
		//게시글 목록이 있는 페이지의 경우 선택한 게시글의 MessageID를 설정
		if($("#messageGrid").length > 0 ){
			$.each(messageGrid.getCheckedList(0), function(i,obj){
				messageIDs += obj.MessageID + ';'
			});
		} else {
			//상세보기 페이지에서는 현재 선택된 게시글의 MessageID를 설정
			messageIDs = messageID;
		}
		
		//게시글 목록이 있는 페이지에서 체크박스를 선택하지 않았을 경우 경고 호출
		if(messageIDs == ''){
			 Common.Warning(Common.getDic('msg_Common_03'), "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
	       return;
		}
		
		//CHECK: 처리 이력 팝업 제목 다국어처리 필요
		parent.Common.open("", "historyPopup", Common.getDic("lbl_ProcessingHistory"), "/groupware/board/goHistoryPopup.do?messageID=" + messageIDs, "500px", "390px", "iframe", true, null, null, true);
	},
	
	//처리이력 팝업: 문서관리 checkin/out, 개정 이력 팝업
	checkInHistoryPopup : function() {
		var messageIDs = null;
		var versions = null;
		//게시글 목록이 있는 페이지의 경우 선택한 게시글의 MessageID를 설정
		if($("#messageGrid").length > 0 ){	
			//상세보기 Context로 이동하기 때문에 해당 소스는 임시로 유지함.
//			$.each(messageGrid.getCheckedList(0), function(i,obj){
//				messageIDs += obj.MessageID + ';'
//			});
		} else {
			//상세보기 페이지에서는 현재 선택된 게시글의 MessageID를 설정
			messageIDs = messageID;
			versions = version;
		}
		
		//게시글 목록이 있는 페이지에서 체크박스를 선택하지 않았을 경우 경고 호출
		if(messageIDs == ''){
			 Common.Warning("문서글을 선택해주세요.", "Warning Dialog", function () { });
	       return;
		}
		
		//CHECK: 처리 이력 팝업 제목 다국어처리 필요
		parent.Common.open("", "checkInHistoryPopup", Common.getDic("lbl_ProcessingHistory"), "/groupware/board/goDocInOutHistoryListPopup.do?messageID=" + messageIDs + "&version="+versions + "&bizSection=" + CFN_GetQueryString("CLBIZ"), "1100px", "390px", "iframe", true, null, null, true);
	},
	
	//게시글 조회 팝업
	searchMessagePopup : function(pMode, pBizSection) {	//게시 목록
		//연결된 게시글, 바인더에 등록된 게시글을 제외
		parent.Common.open("", "searchMessagePopup", Common.getDic("lbl_AllListBoardList"), "/groupware/board/goSearchMessagePopup.do?mode="+pMode+"&bizSection="+pBizSection+"&menuID="+menuID +"&communityID="+communityID, "850px", "650px", "iframe", true, null, null, true);
	},
	
	requestAuthPopup : function(pFolderID, pMessageID, pVersion) {	//권한요청
		parent.Common.open("", "requestAuthPopup", Common.getDic("lbl_AclRequest"), "/groupware/board/goRequestAuthPopup.do?folderID=" + pFolderID + "&messageID=" + pMessageID + "&version=" + pVersion, "700px", "510px", "iframe", true, null, null, true);
	},
	
	approveAuthPopup: function(pFolderID, pMessageID, pVersion, pRequestID, pRequestorCode){	//권한요청
		parent.Common.open("", "approveAuthPopup", Common.getDic("lbl_AclRequest"), "/groupware/board/goApproveAuthPopup.do?folderID=" + pFolderID + "&messageID=" + pMessageID + "&version=" + pVersion + "&requestID=" + pRequestID + "&requestorCode=" + pRequestorCode, "700px", "600px", "iframe", true, null, null, true);
	},
	
	distributeDocPopup : function(pFolderID, pMessageID, pVersion) {	//문서배포
		parent.Common.open("", "distributeDocPopup", Common.getDic("lbl_Doc_docDistribution"), "/groupware/board/goDistributeDocPopup.do?messageID=" + pMessageID + "&version=" + pVersion, "360px", "550px", "iframe", true, null, null, true);
	},
	
	replyPopup: function(pFolderID, pMessageID, pVersion, pBizSection){	//댓글
		parent.Common.open("", "replyPopup", Common.getDic("lbl_Comments"), "/groupware/board/goReplyPopup.do?folderID=" + pFolderID + "&messageID=" + pMessageID + "&version=" + pVersion + "&bizSection=" + pBizSection + "&folderType=" + g_boardConfig.FolderType, "950px", "550px", "iframe", true, null, null, true);
	},
	
	//게시글 이동: BoardList.jsp, BoardView.jsp 페이지에서 호출함
	moveMessage: function (){
		var messageIDs = '';
		var messageVers = '';
		var folderIDs = '';
		if($("#messageGrid").length > 0 ){
			$.each(messageGrid.getCheckedList(0), function(i,obj){
				messageIDs += obj.MessageID + ';';
				messageVers += obj.Version + ';'
				folderIDs += obj.FolderID + ';';
			});
		} else {
			messageIDs = messageID;
			messageVers = version;
			folderIDs = folderID;
		}
		
	    $.ajax({
	    	type:"POST",
	    	url:"/groupware/board/moveMessage.do",
	    	data:{
	    		"bizSection": bizSection
	    		,"messageID": messageIDs
	    		,"version" : messageVers
	    		,"orgFolderID": folderIDs
	    		,"folderID": $("#hiddenFolderID").val()
	    		,"comment": $("#hiddenComment").val()
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
	    			Common.Inform(Common.getDic('msg_FolderMoved')); // 분류 이동이 완료되었습니다.
	    			if($("#messageGrid").length > 0){
	    				//BoardList에서 삭제시 Grid정보 재조회
	    				//messageGrid.reloadList();
	    				$('#btnRefresh').click();
	    			} else {
	    				//상세보기에서 삭제했을 경우 목록으로 돌아감
	    				board.goFolderContents(g_urlHistory);	
	    			}
	    		}else{
	    			if (data.message != ""){
	    				Common.Warning(data.message);//오류가 발생헸습니다.
	    			}
	    			else{
	    				Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	    			}	
	    		}
	    	},
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/board/moveMessage.do", response, status, error);
	    	}
	    });
	},
	
	//게시글 복사: BoardList.jsp, BoardView.jsp 페이지에서 호출함
	copyMessage: function (){
		var messageIDs = '';
		var folderIDs = '';
		var versions = '';
		var useAnonym = '';
		var creatorName = '';
		
		if($("#messageGrid").length > 0 ){
			$.each(messageGrid.getCheckedList(0), function(i,obj){
				messageIDs += obj.MessageID + ';';
				folderIDs += obj.FolderID + ';';
				versions += obj.Version + ';';
				useAnonym += obj.UseAnonym + ';';
				creatorName += obj.CreatorName + ';';
			});
		} else {
			messageIDs = messageID;
			folderIDs = folderID;
			versions = version;
		}
	    $.ajax({
	    	type:"POST",
	    	url:"/groupware/board/copyMessage.do",
	    	data:{
	    		"bizSection": bizSection
	    		,"messageID": messageIDs
	    		,"orgFolderID": folderIDs
	    		,"folderID": $("#hiddenFolderID").val()
	    		,"comment": $("#hiddenComment").val()
	    		,"version": versions
				,"useAnonym":useAnonym
				,"creatorName":creatorName
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
	    			Common.Inform(Common.getDic('msg_CopyCheckMsg') + ' ' + Common.getDic('msg_task_completeCopy')); // 복사 되었습니다.
	    			if($("#messageGrid").length > 0){
	    				//BoardList에서 삭제시 Grid정보 재조회
	    				$('#btnRefresh').click();
	    			} else {
	    				//상세보기에서 삭제했을 경우 목록으로 돌아감
	    				board.goFolderContents(g_urlHistory);	
	    			}
	    		}else{
	    			if (data.message != ""){
	    				Common.Warning(data.message);//오류가 발생헸습니다.
	    			}
	    			else{
	    				Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	    			}	
	    		}
	    	},
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/board/copyMessage.do", response, status, error);
	    	}
	    });
	},
	
	//게시 이동, 복사용 게시판 목록 조회 팝업
	moveFolderPopup : function(pMode) {
		var messageIDs = '';
		var Depths = '';
		var pFolderID = folderID;
		
		if($("#messageGrid").length > 0 ){
			$.each(messageGrid.getCheckedList(0), function(i,obj){
				messageIDs += obj.MessageID + ';'
				Depths += obj.Depth + ';'
			});
		} else {
			messageIDs = messageID;
		}
		
		if(messageIDs == ''){
			Common.Warning(Common.getDic("msg_SelecteBeforeProcess"), "Warning Dialog", function () { });
			return;
		}
		
		if(pMode == "move"){
			var DepthsList = Depths.split(";").join("");
			for(var i=0;i<DepthsList.length; i++){
				var DepthsKey = DepthsList[i];
				if(DepthsKey > 0){
					Common.Warning(Common.getDic("msg_DepthNotMove"), "Warning Dialog", function () { }); //답글 게시물은 이동할 수 없습니다.
					return;
				}
			}
		}
		
		if(bizSection == "Doc" && multiFolderType == "SUB" && g_messageConfig.MultiFolderIDs != ""){
			pFolderID = g_messageConfig.FolderID;
		}
		
		var confirmMsg = bizSection == "Doc" ? Common.getDic("lbl_DocMoveClassSification") : Common.getDic("lbl_MessageMoveClassSification");
		// 분류를 변경하게되면 권한설정과 [*]확장필드의 값이 초기화 될 수 있습니다. 그래도 분류를 변경하시겠습니까?
		Common.Confirm(confirmMsg, 'Confirmation Dialog', function (result) {	
            if (result) {
				//mode: move, copy  ex) board.moveMessage()
				//parent._CallBackMethod = new Function("board." + pMode + "Message()");
				parent._CallBackMethod = board[pMode + "Message"];
				
				//게시글 이동, 복사 팝업 조회
				var url = String.format("/groupware/board/goMoveBoardTreePopup.do?bizSection={0}&folderID={1}&menuID={2}&communityID={3}&mode={4}&menuCode={5}", bizSection, pFolderID, menuID, communityID, pMode, CFN_GetQueryString("menuCode"));
				
				if(bizSection == "Doc" && g_messageConfig.MultiFolderIDs != ""){
					url += "&multiFolderIDs=" + g_messageConfig.MultiFolderIDs;
				}
				
				parent.Common.open("", "boardTreePopup", Common.getDic("lbl_SelectBoard"), url, "360px", "500px", "iframe", true, null, null, true);
            }
        });
	},
	
	/***** 게시글 승인 / 거부 ******************************/
	//게시글 승인: BoardList.jsp, BoardView.jsp 페이지에서 호출함
	acceptMessage: function (){
		var messageIDs = '';
		var processIDs = '';
		
		if($("#messageGrid").length > 0 ){
			$.each(messageGrid.getCheckedList(0), function(i,obj){
				messageIDs += obj.MessageID + ';';
				processIDs += obj.ProcessID + ';';
			});
		} else {
			messageIDs = messageID;
			
			if(boardType == "Approval" && approvalStatus == "R"){
				processIDs = g_messageConfig.ProcessID; // 승인 요청 게시
			}else{
				processIDs = ProcessID;
			}
		}
		
	    $.ajax({
	    	type:"POST",
	    	url:"/groupware/board/acceptMessage.do",
	    	data:{
	    		"bizSection": bizSection
	    		,"messageID": messageIDs
	    		,"processID": processIDs
	    		,"comment": $("#hiddenComment").val()
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
	    			Common.Inform(data.message); //
	    			if($("#messageGrid").length > 0){
	    				//BoardList에서 삭제시 Grid정보 재조회
	    				$('#btnRefresh').click();
	    			} else {
	    				//상세보기에서 삭제했을 경우 목록으로 돌아감
	    				board.goFolderContents(g_urlHistory);	
	    			}
	    		}else{
	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	    		}
	    	},
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/board/acceptMessage.do", response, status, error);
	    	}
	    });
	},
	
	//게시글 승인 거부: BoardList.jsp, BoardView.jsp 페이지에서 호출함
	rejectMessage: function (){
		var messageIDs = '';
		var processIDs = '';
		
		if($("#messageGrid").length > 0 ){
			$.each(messageGrid.getCheckedList(0), function(i,obj){
				messageIDs += obj.MessageID + ';';
				processIDs += obj.ProcessID + ';';
			});
		} else {
			messageIDs = messageID;
			
			if(boardType == "Approval" && approvalStatus == "R"){
				processIDs = g_messageConfig.ProcessID; // 승인 요청 게시
			}else{
				processIDs = ProcessID;
			}
		}
		
	    $.ajax({
	    	type:"POST",
	    	url:"/groupware/board/rejectMessage.do",
	    	data:{
	    		"bizSection": bizSection
	    		,"messageID": messageIDs
	    		,"processID": processIDs
	    		,"comment": $("#hiddenComment").val()
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
	    			Common.Inform(data.message); 
	    			if($("#messageGrid").length > 0){
	    				//BoardList에서 삭제시 Grid정보 재조회
	    				//messageGrid.reloadList();
	    				$('#btnRefresh').click();
	    			} else {
	    				//상세보기에서 삭제했을 경우 목록으로 돌아감
	    				board.goFolderContents(g_urlHistory);	
	    			}
	    		}else{
	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	    		}
	    	},
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/board/rejectMessage.do", response, status, error);
	    	}
	    });
	},
	
	
	//권한 요청 승인
	allowMessage: function (){
		var messageIDs = '';
		var requestIDs = '';
		var versions = '';
		var comments = '';
		var customAcl = '';

		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		if($("#messageGrid").length > 0 ){
			$.each(messageGrid.getCheckedList(0), function(i,obj){
				messageIDs += obj.MessageID + ';';
				requestIDs += obj.RequestID + ';';
				versions += obj.Version + ';';
				comments = $("#hiddenComment").val();
			});
		} else {
			messageIDs = messageID;
			requestIDs = requestID;
			versions = version;
			comments = $('#txtComment').val();
			customAcl = setAclList();
		}
		
	    $.ajax({
	    	type:"POST",
	    	url:"/groupware/board/allowMessage.do",
	    	data:{
	    		"bizSection": "Doc"
	    		,"messageID": messageIDs
	    		,"requestID": requestIDs
	    		,"version"	: versions
	    		,"comment"	: comments
	    		,"customAcl": customAcl
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
	    			Common.Inform(data.message, "Information", function(){
	    				if(parent.$("#messageGrid").length > 0){
	    					//BoardList에서 삭제시 Grid정보 재조회
	    					//messageGrid.reloadList();
	    					parent.$('#btnRefresh').click();
	    				} 
	    				Common.Close();
	    			}); //
	    		}else{
	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	    		}
	    	},
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/board/allowMessage.do", response, status, error);
	    	}
	    });
	},
	
	//게시글 승인 거부: BoardList.jsp, BoardView.jsp 페이지에서 호출함
	denieMessage: function (){
		var messageIDs = '';
		var requestIDs = '';
		var versions = '';
		var comments = '';
		
		if($("#messageGrid").length > 0 ){
			$.each(messageGrid.getCheckedList(0), function(i,obj){
				messageIDs += obj.MessageID + ';';
				requestIDs += obj.RequestID + ';';
				versions += obj.Version + ';';
				comments = $("#hiddenComment").val();
			});
		} else {
			messageIDs = messageID;
			requestIDs = requestID;
			versions = version;
			comments = $('#txtComment').val();
		}
		
	    $.ajax({
	    	type:"POST",
	    	url:"/groupware/board/denieMessage.do",
	    	data:{
	    		"bizSection": "Doc"
	    		,"messageID": messageIDs
	    		,"requestID": requestIDs
	    		,"version"	: versions
	    		,"comment": comments
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
	    			Common.Inform(data.message, "Information", function(){
	    				if(parent.$("#messageGrid").length > 0){
	    					//BoardList에서 삭제시 Grid정보 재조회
	    					//messageGrid.reloadList();
	    					parent.$('#btnRefresh').click();
	    				} 
	    				Common.Close();
	    			}); //
	    		}else{
	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	    		}
	    	},
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/board/denieMessage.do", response, status, error);
	    	}
	    });
	},
	
	/***************************************************/
	/***** 게시글 체크아웃 *********************************/
	// 해당 항목은 Grid내부 checkbox가 아니라 Context Menu로 호출될 예정이기때문에 수정이 필요
	// commentPopup에서 callback함수로 자동 호출 되는 구조 이기때문에 type변수를 설정하고 chageCheckOutState 함수 호출 
	// commentPopup - checkOutMessage - updateCheckOutState( pType ) - ajaxRequest...
	//체크아웃: BoardList.jsp, BoardView.jsp 페이지에서 호출함
	checkOutMessage: function (){
		var aclObj = board.getMessageAclList(bizSection, version, messageID, folderID).aclObj;
		
		if(sessionObj["isAdmin"] != "Y"
			&& aclObj.Modify != "M"
			&& !((bizSection == "Board" && g_messageConfig.CreatorCode == sessionObj["USERID"])
				|| (bizSection == "Doc" && g_messageConfig.OwnerCode == sessionObj["USERID"]))){
			Common.Warning(Common.getDic('msg_noModifyACL'), "Warning Dialog", function () { return; });// 수정 권한이 없습니다.
			return false;
		}
		
		board.updateCheckOutState("Out");
	},
	
	//체크아웃 취소: BoardList.jsp, BoardView.jsp 페이지에서 호출함
	cancelMessage: function (){
		board.updateCheckOutState("Cancel");
	},
	
	//체크인: BoardList.jsp, BoardView.jsp 페이지에서 호출함
	checkInMessage: function (){
		board.updateCheckOutState("In");
	},
	
	//최신버전으로 대체: BoardList.jsp, BoardView.jsp 페이지에서 호출함
	renewMessage: function (){
		board.updateCheckOutState("Renew");
	},
	
	updateCheckOutState: function( pType ){
		var messageIDs = messageID;
		var versions = version;
		
	    $.ajax({
	    	type:"POST",
	    	url:"/groupware/board/updateCheckOutState.do",
	    	data:{
	    		"bizSection": bizSection
	    		,"messageID": messageIDs
	    		,"version": versions
	    		,"actType": pType
	    		,"comment": $("#hiddenComment").val()
				,"folderID": folderID
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){			//성공시 Grid재조회 및 필드 입력항목 초기화
	    			Common.Inform(data.message); 	// 분류 이동이 완료되었습니다.
	    			if($("#messageGrid").length > 0){
	    				//BoardList에서 삭제시 Grid정보 재조회
	    				//messageGrid.reloadList();
	    				$('#btnRefresh').click();
	    			} else {
	    				//체크아웃 취소이후 목록으로 돌아감
	    				board.goFolderContents(g_urlHistory);	
	    			}
	    		}else{
	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	    		}
	    	},
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/board/updateCheckOutState.do", response, status, error);
	    	}
	    });
	},
	
	//문서관리 수정페이지로 이동
	updateCheckOutMessage: function(){
	    $.ajax({
	    	type:"POST",
	    	url:"/groupware/board/updateCheckOutState.do",
	    	data:{
	    		"bizSection": bizSection
	    		,"messageID": messageID
	    		,"version": version
	    		,"actType": "Out"
	    		,"comment": $("#hiddenComment").val()
	    		,"folderID": ($("#hiddenFolderID").val() != "") ? $("#hiddenFolderID").val() : CFN_GetQueryString("folderID")
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){			//성공시 수정페이지로 이동
	    			board.goUpdate(boardObj);
	    		}else{
	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	    		}
	    	},
	    	error:function(response, status, error){
	    	     CFN_ErrorAjax("/groupware/board/updateCheckOutState.do", response, status, error);
	    	}
	    });
	},
	
	/***************************************************/
	/***** 게시글 스크랩 **********************************/
	scrapMessage: function(){
		//<spring:message code='Cache.msg_RUScrap'/>
		//개별호출-일괄호출
		Common.getDicList(["msg_RUScrap","msg_Scraped","msg_apv_030","msg_ScrapCheckMsg"]);
		Common.Confirm(coviDic.dicMap["msg_ScrapCheckMsg"] + " " + coviDic.dicMap["msg_RUScrap"], 'Confirmation Dialog', function (result) {       // 본문과 첨부 파일만 스크랩됩니다. 스크랩하시겠습니까?
			if (result){
			    $.ajax({
			    	type:"POST",
			    	url:"/groupware/board/scrapMessage.do",
			    	data:{
			    		"fileInfos": JSON.stringify(g_messageConfig.fileList)
			    		,"bizSection": bizSection
			    		,"orgMessageID": messageID
			    		,"folderID": folderID
			    		,"Version": version
			    	},
			    	success:function(data){
			    		if(data.status=='SUCCESS'){
			    			Common.Inform(coviDic.dicMap['msg_Scraped']); 	//스크랩했습니다.
		    				//스크랩 완료 후 페이지 이동이 필요하지 않음
		    				//goFolderContents(g_urlHistory);	
			    		}else{
			    			Common.Warning(coviDic.dicMap['msg_apv_030']);//오류가 발생헸습니다.
			    		}
			    	},
			    	error:function(response, status, error){
			    	     CFN_ErrorAjax("/groupware/board/scrapMessage.do", response, status, error);
			    	}
			    });
			}
		});
	},
	
	/***************************************************/
	/***** 본문 인쇄 *************************************/
	printMessage: function(){
		$('.btnAddFunc, .addFuncLilst').removeClass('active');	//Context Menu 닫기
		var cssPath = Common.getGlobalProperties("css.path");
		var resourceVersion = Common.getBaseConfig("resourceVersion");
		resourceVersion = resourceVersion ? "?ver=" + resourceVersion : "";
		
		var userDefFieldFlag = g_boardConfig.UseUserForm == "Y" ? true : false;	//사용자 정의 필드 유무
		var filePath = "/covicore/resources/images/common/bul_chk_01.png";
		
		//인쇄용 팝업 호출
		var contentsHtml = window.open('', 'PRINT', 'height=768,width=1024');
		var selectedRadio = $('.radioStyle04 input[type="radio"]:checked + label > span > span');
		var selectedCheckbox = $('.chkStyle01 input[type="checkbox"]:checked + label span:first-child');
		
		contentsHtml.document.write('<html><head><title>' + document.title  + '</title>');
		contentsHtml.document.write(String.format('<link rel="stylesheet" type="text/css"href="{0}/covicore/resources/css/common.css{1}"/>', cssPath, resourceVersion));
		contentsHtml.document.write(String.format('<link rel="stylesheet" type="text/css"href="{0}/board/resources/css/board.css{1}"/>', cssPath, resourceVersion));
		contentsHtml.document.write(String.format('<link rel="stylesheet" type="text/css"href="{0}/community/resources/css/community.css{1}"/>', cssPath, resourceVersion));
		contentsHtml.document.write(String.format('<link rel="stylesheet" type="text/css"href="{0}/covicore/resources/css/theme/{1}.css{2}"/>', cssPath, Common.getSession("PortalOption").theme, resourceVersion));
		contentsHtml.document.write(String.format('<link rel="stylesheet" type="text/css"href="{0}/appstore/resources/css/appstore.css{1}"/>', cssPath, resourceVersion));
		contentsHtml.document.write(String.format('<link rel="stylesheet" type="text/css"href="{0}/covicore/resources/css/covision/Controls.css{1}"/>', cssPath, resourceVersion));
		contentsHtml.document.write(String.format('<link rel="stylesheet" type="text/css"href="{0}/collaboration/resources/css/collaboration.css{1}"/>', cssPath, resourceVersion));
		contentsHtml.document.write(String.format('<link rel="stylesheet" type="text/css"href="{0}/covicore/resources/css/axisj/arongi/AXJ.min.css{1}"/>', cssPath, resourceVersion));
		contentsHtml.document.write('</head><body >');
		contentsHtml.document.write('<div id="content"/>');
		contentsHtml.document.write('<div class="boardAllCont">');	
		
		if(userDefFieldFlag == true){
			selectedRadio.css("background","#566472");
			selectedCheckbox.css("background","url("+cssPath+filePath+") no-repeat center center");
		}
		
		contentsHtml.document.write($(".boardAllCont").html());
		contentsHtml.document.write('</div></div>');
		contentsHtml.document.write('</body></html>');
		
		contentsHtml.document.close();	// necessary for IE >= 10
		contentsHtml.focus(); 			// necessary for IE >= 10
		
		setTimeout(function(){
			contentsHtml.print();
			setInterval(function(){contentsHtml.close();}, 2000);
			//contentsHtml.close();
		}, 1000);
		
	    return true;
	},
	
	/***************************************************/
	/***** 태그 설정 *************************************/
	
	//보안등급
	renderSecurityLevel: function(config){
		var levelHTML = "";
		$.each(Common.getBaseCode('SecurityLevel').CacheData,function(i, item){
			if(config.SecurityLevel == String(item.Code)){
				levelHTML += String.format("<div class='tag'>{0}</div>", CFN_GetDicInfo(item.MultiCodeName));
			}
		});
		$(".authView").prepend(levelHTML);
		$(".authView").prepend("<span class='boxDivTit'>"+Common.getDic("lbl_SecurityLevel")+"</span>"); 				//보안등급
	},
	
	//열람권한
	renderReadAuth: function(pBizSection, pMessageID, pFolderID){
		var authHTML = "";
		var ReadAuth = (board.getMessageReadAuth(pBizSection,pMessageID,pFolderID)).split(";");
		$.each(ReadAuth, function(i, item){
			authHTML += String.format("<div class='tag'>{0}</div>", item.split("|")[2] );
		}); 
		if(!authHTML.includes("undefined")){
			$(".authView").prepend(authHTML);
			$(".authView").prepend("<span class='boxDivTit' style='margin-left:12px'>"+Common.getDic("lbl_MessageReadAuth")+"</span>");
		}
	},
	
	//작성화면과 상세보기 화면에서 다르게 표시
	renderTag: function(pMessageID, pVersion){
		$.ajax({
			type:"POST",
			async:false,
			data: {
				"messageID": pMessageID,
				"version": pVersion,
			},
			url:"/groupware/board/selectMessageTagList.do",
			success:function(data){
				if(data.list.length > 0){
					var tagHTML = "";
					$(data.list).each(function(idx, item){
						tagHTML += String.format("<div class='tag' tag='{0}'>#{0}</div>", item.Tag );
					});
					$(".tagView").prepend(tagHTML);
					$(".tagView").prepend("<span class='tagIcon'>태그</span>");
					
					$('.tagView .tag').attr("style","cursor:pointer;");
					$('.tagView .tag').on('click', function(){
						goTagList($(this).attr("tag"));
					});
				}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/selectMessageTagList.do", response, status, error);
			}
		});
	},
	
	//태그 설정정보 조회
	getTagData: function(pMessageID, pVersion) {
		$.ajax({
			type:"POST",
			data: {
				"messageID": pMessageID,
				"version": pVersion,
			},
			url:"/groupware/board/selectMessageTagList.do",
			success:function(data){
				var sHTML = "";
				$(data.list).each(function(idx, item){
					if(!$('#divTagHeader .btnSurMove').hasClass('active')){
						$("#divTagHeader").find(".btnSurMove").addClass("active");
			    		$("#divTagHeader").next().addClass("active");
					}
					
					sHTML += String.format("<div tag='{0}'>{0}", item.Tag );
					sHTML += String.format("<a href='#' class='btnRemoveAuto' onclick='javascript:board.deleteTag(this);'/>");
					sHTML += String.format("</div>");
				});
				$("#divTagList").append(sHTML);
				//태그 설정 개수
				$("#tagCount").text(String.format("({0}개)",$("#divTagList").children().size()));
				
				if($("#divTagList").children().size() >= 10){
					$("#tag").prop("disabled", true).attr("placeholder", "Tag  Maaaaax !!!");
				}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/selectMessageTagList.do", response, status, error);
			}
		});
	},
	
	//태그 추가
	addTag: function (){
		var pTag = $("#tag").val();

		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }

		if(pTag != null && pTag != ""){
			$("#tag").val("");
			var dupCheck = false;
			var sHTML = "";
			//Tag 중복 체크
			$("#divTagList").children().each(function () {
	            if ($(this).attr("tag") == pTag)
	            	dupCheck = true;
			});
	
			if (!dupCheck) {
				sHTML += String.format("<div tag='{0}'>{0}", pTag );
				sHTML += String.format("<a href='#' class='btnRemoveAuto' onclick='javascript:board.deleteTag(this);'/>");
				sHTML += String.format("</div>");
			}
			$("#divTagList").append(sHTML);
			//태그 설정 개수
			$("#tagCount").text(String.format("({0}" + Common.getDic("lbl_Count") + ")",$("#divTagList").children().size()));
			if($("#divTagList").children().size() >= 10){
				$("#tag").prop("disabled", true).attr("placeholder", "Tag  Max !");
			}
			
			if(!$('#divTagHeader .btnSurMove').hasClass('active')){
				$("#divTagHeader").find(".btnSurMove").addClass("active");
	    		$("#divTagHeader").next().addClass("active");
			}
		}
	},
	
	deleteTag: function( pObj ){	//Tag Node 삭제
		//화면상에서만 삭제처리, 실제 데이터는 게시글 추가 및 수정시에 데이터 일괄 삭제후 추가하는 방식
		$(pObj).parent().remove();
		if($("#divTagList").children().size() < 10){
			$("#tag").prop("disabled", false).attr("placeholder", "");
		}
		
		if($("#divTagList").children().size() == 0 && $('#divTagHeader .btnSurMove').hasClass('active')){
			$("#divTagHeader").find(".btnSurMove").removeClass("active");
    		$("#divTagHeader").next().removeClass("active");
		}
		
		//태그 설정 개수 갱신
		$("#tagCount").text(String.format("({0}" + Common.getDic("lbl_Count") + ")",$("#divTagList").children().size()));
	},
	
	//Tag 정보 parameter 
	setTagData: function(){
		var tagArray = [];
		
		$('#divTagList').children().each(function () {
	        var tagObj = new Object();
	        tagObj.Tag = $(this).attr("tag");
	        //tagObj.Version = $(this).attr("version");
	    	tagArray.push(tagObj);
	    });
	    
		return JSON.stringify(tagArray);
	},
	
	
	/***** 링크 설정 **********/
	//작성화면과 상세보기 화면에서 다르게 표시
	renderLink: function(pMessageID){
		$.ajax({
			type:"POST",
			async:false,
			data: {
				"messageID": pMessageID,
			},
			url:"/groupware/board/selectMessageLinkList.do",
			success:function(data){
				if(data.list.length > 0){
					var tagHTML = "";
					$(data.list).each(function(idx, item){
						tagHTML += String.format("<div class='tag'><a target='_blank' href='{1}'>{0}</a></div>", item.Title, item.Url );
					});
					$(".tagView").prepend(tagHTML);
					$(".tagView").prepend("<span class='tagIcon'>" + Common.getDic("lbl_Link") + "</span>");
				}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/selectMessageLinkList.do", response, status, error);
			}
		});
	},
	
	getLinkData: function(pMessageID) {
		$.ajax({
			type:"POST",
			data: {
				"messageID": pMessageID,
			},
			url:"/groupware/board/selectMessageLinkList.do",
			success:function(data){
				var sHTML = "";
				$(data.list).each(function(idx, item){
					if(!$('#divLinkHeader .btnSurMove').hasClass('active')){
						$("#divLinkHeader").find(".btnSurMove").addClass("active");
			    		$("#divLinkHeader").next().addClass("active");
					}
					
					sHTML += String.format("<div title='{0}' link='{1}'>{0}", item.Title, item.Url);
					sHTML += String.format("<a href='#' class='btnRemoveAuto' onclick='javascript:board.deleteLink(this);'/>");
					sHTML += String.format("</div>");
					
				});
				$("#divLinkList").append(sHTML);
				
				//링크 설정 개수
				$("#linkCount").text(String.format("({0}" + Common.getDic("lbl_Count") + ")",$("#divLinkList").children().size()));
				
				//링크 설정 제한
				var limitLinkCount = g_boardConfig.LimitLinkCnt;
				if($("#divLinkList").children().size() >= limitLinkCount){
					$("#title").prop("disabled", true).attr("placeholder", "Link");
					$("#link").prop("disabled", true).attr("placeholder", "Max");
				}
			},
			error:function(response, status, error){
			     CFN_ErrorAjax("/groupware/board/selectMessageLinkList.do", response, status, error);
			}
		});
	},
	
	//링크 추가
	addLink: function (){
		var pTitle = $("#title").val();
		var pLink = $("#link").val();
		var limitLinkCount = g_boardConfig.LimitLinkCnt;

		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		
		if(pTitle == undefined || pTitle == ""){
			Common.Warning(Common.getDic("msg_board_enterLinkURL"), "Warning", function(){
				$("#title").focus();
			});
			
			return;
		}
		
		if(pLink == undefined || pLink == ""){
			Common.Warning(Common.getDic("msg_board_enterLinkURL"), "Warning", function(){
				$("#link").focus();
			});
			
			return;
		}
		
		$("#title, #link").val("");
		var dupCheck = false;
		var sHTML = "";
		//중복 체크
		$("#divLinkList").children().each(function () {
			//title과 link로 중복 체크
            if ($(this).attr("title") == pTitle && $(this).attr("link") == pLink)
            	dupCheck = true;
		});

		if (!dupCheck) {
			sHTML += String.format("<div title='{0}' link='{1}'>{0}", pTitle, pLink);
			sHTML += String.format("<a href='#' class='btnRemoveAuto' onclick='javascript:board.deleteLink(this);'/>");
			sHTML += String.format("</div>");
		}
		$("#divLinkList").append(sHTML);
		
		//링크 설정 개수
		$("#linkCount").text(String.format("({0}" + Common.getDic("lbl_Count") + ")",$("#divLinkList").children().size()));
		
		//링크 설정 제한
		if($("#divLinkList").children().size() >= limitLinkCount){
			$("#title").prop("disabled", true).attr("placeholder", "Link");
			$("#link").prop("disabled", true).attr("placeholder", "Max !");
		}
	
		if(!$('#divLinkHeader .btnSurMove').hasClass('active')){
			$("#divLinkHeader").find(".btnSurMove").addClass("active");
    		$("#divLinkHeader").next().addClass("active");
		}
	},
	
	deleteLink: function( pObj ){	//Tag Node 삭제
		//화면상에서만 삭제처리, 실제 데이터는 게시글 추가 및 수정시에 데이터 일괄 삭제후 추가하는 방식
		$(pObj).parent().remove();
		var limitLinkCount = g_boardConfig.LimitLinkCnt;
		if($("#divLinkList").children().size() < limitLinkCount){
			$("#title, #link").prop("disabled", false).attr("placeholder", "");
		}
		
		if($("#divLinkList").children().size() == 0 && $('#divLinkHeader .btnSurMove').hasClass('active')){
			$("#divLinkHeader").find(".btnSurMove").removeClass("active");
    		$("#divLinkHeader").next().removeClass("active");
		}
		
		//링크 설정 개수 갱신
		$("#linkCount").text(String.format("({0}" + Common.getDic("lbl_Count") + ")",$("#divLinkList").children().size()));
	},
	
	setLinkData: function(){
		var linkArray = [];
		
		$('#divLinkList').children().each(function () {
	        var linkObj = new Object();
	        linkObj.Title = $(this).attr("title");
	        linkObj.Link = $(this).attr("link");
	        linkArray.push(linkObj);
	    });
	    
		return JSON.stringify(linkArray);
	},
	
	/****** 바인더,연결 게시글  ******/
	
	getLinkedMessage: function(pPageType, pBizSection, pMessageID, pVersion){
		$.ajax({
	 		type:"POST",
	 		data: {
	 			"bizSection": pBizSection,
	 			"messageID": pMessageID,	
	 			"version": pVersion
	 		},
	 		url:"/groupware/board/selectLinkedMessageList.do",
	 		async: false,
	 		success:function(data){
	 			//var config = data.list;
	 			//작성화면과 상세조회화면에서 표시 처리하기 위한 분기처리
	 			if(pPageType == "View"){
	 				//CHECK:상세보기 UI작업 완료후 추가 예정
	 				board.renderLinkedMessageView(pBizSection, data.list);
	 			} else {
	 				$("#hiddenLinkedMessage").val(JSON.stringify(data.list));
	 				board.renderLinkedMessage($("#hiddenLinkedMessage"));
	 			}
	 		},
	 		error:function(response, status, error){
	 		     CFN_ErrorAjax("/groupware/board/selectLinkedMessageList.do", response, status, error);
	 		}
	 	});
	},
	
	//작성화면에서 연결게시글 표시
	renderLinkedMessage: function( pElementObj ){
		if(pElementObj.val() != ""){
			var linkedMessage = $.parseJSON(pElementObj.val());
			var divLinkedMessage = pElementObj.next();
			
			divLinkedMessage.find(".autoComText.clearFloat").html("");
			$.each(linkedMessage, function(i, item){
				var btnLinkedMessage = $("<div />").attr({targetID: item.MessageID, folderID:item.FolderID, version: item.Version}).text(item.DisplayName).append($("<a href='#' onclick='javascript:board.deleteLinkedMessage(this);'/>").addClass("btnRemoveAuto"));
				divLinkedMessage.find(".autoComText.clearFloat").append(btnLinkedMessage);
			});
			
			if(!divLinkedMessage.parent().prev().find('.btnSurMove').hasClass('active')){
				divLinkedMessage.parent().prev().find(".btnSurMove").addClass("active");
	    		divLinkedMessage.parent().addClass("active");
			}
		}
	},
	
	//작성화면에서 연결게시글 표시
	renderLinkedMessageView: function(pBizSection, pLinkedList ){
		if(pLinkedList.length > 0){
			//통합게시, 문서관리별 표시문구 변경
			if(pBizSection == "Doc" && g_messageConfig.MsgType == "B"){
				$("#divLinkedMessage .tit").text(Common.getDic("lbl_Binder"));	//바인더
			} else if (pBizSection != "Doc"){
				$("#divLinkedMessage .tit").text(Common.getDic("lbl_Board_linkMessage"));	//연결 게시
			} else {
				$("#divLinkedMessage .tit").text(Common.getDic("lbl_LinkDoc"));	//연결 문서
			}
			
			$("#divLinkedMessage").find(".borNemoListBox").empty();
			
			//$("#divLinkedMessage").append($('<div />').append(String.format("<div class='tit'>연결문서  </div><div class='autoComText clearFloat'></div>")));
			$.each(pLinkedList, function(i, item){
				var btnLinkedMessage = $("<span class='btnType02 btnNormal' style='cursor:pointer; margin-bottom: 0px;' onclick='javascript:board.goViewPopup(\""+ pBizSection +"\","+menuID+","+item.Version+"," + item.FolderID +","+ item.MessageID +");'/>").attr({targetID: item.MessageID, folderID:item.FolderID, version: item.Version}).text(item.DisplayName);
				$("#divLinkedMessage").find(".borNemoListBox").append(btnLinkedMessage);
			});
		} else {
			$("#divLinkedMessage").hide();
		}
	},
	
	deleteLinkedMessage: function( pObj ){
		var targetID = $(pObj).parent().attr("targetID");
		
		var linkedMessage = $.parseJSON($("#hiddenLinkedMessage").val());
		$.each(linkedMessage, function(i, item){	//연결글 개별 삭제
			if(item.MessageID == targetID){
				linkedMessage.splice(i,1);
				return false;	//break;
			}
		});
		
		if(linkedMessage.length == 0){
			$("#divLinkedMessage").find(".btnSurMove").removeClass("active");
    		$("#divLinkedMessage").next().removeClass("active");
		}
		
		//삭제 한 항목 제외하고 재설정
		$("#hiddenLinkedMessage").val(JSON.stringify(linkedMessage));
		$(pObj).parent().remove();
	},
	
	deleteLinkedMessageAll: function(){
		$("#divLinkedList").html("");
		$("#hiddenLinkedMessage").val("");
	},
	
	getLinkedFeedMessage: function(pBizSection, pMessageID, pVersion){
		$.ajax({
	 		type:"POST",
	 		data: {
	 			"bizSection": pBizSection,
	 			"messageID": pMessageID,	
	 			"version": pVersion
	 		},
	 		url:"/groupware/board/selectLinkedFeedMessageList.do",
	 		async: false,
	 		success:function(data){
	 			var feedLinkedList = data.list;	 			
	 			if(feedLinkedList != null && feedLinkedList.length > 0){
	 				$("#divLinkedFeed .tit").text(Common.getDic("lbl_Feed_LinkMessage"));
	 				$("#divLinkedFeed").find(".borNemoListBox").empty();

	 				$.each(feedLinkedList, function(i, item){
	 					var btnLinkedFeedMessage = $("<span class='btnType02 btnNormal' style='cursor:pointer; margin-bottom: 0px;' onclick='javascript:board.goFeedViewPopup(\"Folder\", \""+ item.FeedMessageID +"\", \""+ item.FeedVersion +"\");'/>").attr({targetID: item.FeedMessageID, version: item.FeedVersion}).text(item.Subject);
	 					$("#divLinkedFeed").find(".borNemoListBox").append(btnLinkedFeedMessage);
	 				});
	 				
	 				$("#divLinkedFeed").show();
	 			}
	 		},
	 		error:function(response, status, error){
	 		     CFN_ErrorAjax("/groupware/board/selectLinkedFeedMessageList.do", response, status, error);
	 		}
	 	});
	},
	
	validationRadio: function(pRadioName){
		var radioObj = $("input[name=" + pRadioName + "]");
	    for (var i = 0; i < radioObj.length; i++){
	        if (radioObj[i].checked) return true;
	    }
	    return false;
	},
	
	//validation check - 분류명, 우선순위, 확장옵션 사용 체크 후 등록하지 않았을경우
	checkMessageValidation: function(){
		var flag = false;	//false로 실패처리 
		var g_currentTime = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));

		if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
		if (!coviUtil.checkValidation("", true, true)) { return false; }			
		
		//개별호출-일괄호출
		Common.getDicList(["msg_EnterSubject","msg_EnterRegister","msg_SelectBoard","msg_SelCate","msg_task_enterSchedule","msg_EnterName","msg_checkMessageAuth"
		                   ,"msg_EnterFieldValue","msg_apv_ValidationDocNum","msg_ExceededNumberOfUpload","msg_EnterTopNoticeDate","lbl_NoticeTop","msg_StartDateCannotAfterEndDate"]);
		Common.getBaseConfigList(["eventBoardID"]);
		
		if ($("#Subject").val() == "") {
	        parent.Common.Warning(coviDic.dicMap["msg_EnterSubject"], "Warning Dialog", function () {     //제목 입력
	        	$("#Subject").focus();
	        });
	        return false;
	    }
		
		if($("#chkUseAnonym").prop("checked") && $("#CreatorName").val() == ""){         //익명 게시판 - 익명자 처리
			$("#CreatorName").val(Common.getDic("lbl_Anonymity"));
		}
		
		if (bizSection != "Doc" && ($("#selectFolderID").val() == null || $("#selectFolderID").val() == "" || $.isEmptyObject(g_boardConfig))){
			parent.Common.Warning(coviDic.dicMap["msg_SelectBoard"], "Warning Dialog", function () {			//게시판 선택
				$("#selectFolderID").focus();
	        });
			return false;
		}
		
		if (bizSection != "Doc" && coviCmn.configMap["eventBoardID"] == $("#selectFolderID").val() && $("#EventType option:selected").val() == "EventDefault"){
			parent.Common.Warning(coviDic.dicMap["msg_SelCate"], "Warning Dialog", function () {			//경조사 게시판 - 분류를 선택해주세요
				$("#EventType").focus();
	        });
			return false;
		}
		
		if (bizSection != "Doc" && coviCmn.configMap["eventBoardID"] == $("#selectFolderID").val() && $("#EventDate").val() == ""){
			parent.Common.Warning(coviDic.dicMap["msg_task_enterSchedule"], "Warning Dialog", function () {			//경조사 게시판 - 종류를 선택해주세요
				$("#EventDate").focus();
	        });
			return false;
		}
		
		if (bizSection != "Doc" && coviCmn.configMap["eventBoardID"] == $("#selectFolderID").val() && $("#EventOwner").parent().children('.ui-autocomplete-multiselect-item').length == 0){
			parent.Common.Warning(coviDic.dicMap["msg_EnterName"], "Warning Dialog", function () {//경조사 게시판 - 일자를 설정해주세요
				$("#EventOwner").focus();
	        });
			return false;
		}
		
		if( bizSection != "Doc" && g_boardConfig.UseCategory == "Y" && (!$("#selectCategoryID").val() || $("#selectCategoryID").val() == "0")){
			parent.Common.Warning(coviDic.dicMap["msg_SelCate"], "Warning Dialog", function () {    			//분류 선택
				$("#selectCatetegoryID").focus();
	        });
			return false;
		}
		
		if(g_boardConfig.UseUserForm == "Y" || Common.getBaseConfig("use" + bizSection + "MultiCategory") == "Y"){		//사용자 정의 필드 필수값 체크
			var isUserForm = true;
			var userFormName = ""
			var userFormObj = null;
			$('[name^=UserForm][ischeck=Y]').each(function(i, item){
				var userFormType = $(this).attr("type");
				userFormObj = $(this); 
				
				if($(this).val() == "" && (userFormType != "checkbox" || userFormType != "radio")){
					userFormName = $(this).parent().prev().text().split(" ").join("");
					isUserForm = false;
				} else if(userFormType == "radio" || userFormType == "checkbox"){
					if(!board.validationRadio($(this).attr("name"))){
						userFormName = $(this).parent().parent().prev().text();
						isUserForm = false;
					}
				}
			});
			
			if(!isUserForm){
				parent.Common.Warning(userFormName + " " + coviDic.dicMap["msg_EnterFieldValue"], "Warning Dialog", function () {	//필드값을 설정해주세요.
					userFormObj.focus();
		        });
				
				return false;
			}
		}
		
		if(bizSection == "Doc" && $("#hiddenFolderID").val() == ""){
			parent.Common.Warning(coviDic.dicMap["msg_SelCate"], "Warning Dialog", function () {    //문서 번호
				$("#DocNumber").focus();
	        });
			return false;
		}
		
		if(bizSection == "Doc" && $("#UseAutoDocNumber").val() != "Y" && $("#DocNumber").val() == ""){
			parent.Common.Warning(coviDic.dicMap["msg_apv_ValidationDocNum"], "Warning Dialog", function () {    //문서 번호
				$("#DocNumber").focus();
	        });
			return false;
		}

		 // 파일정보
	    if(bizSection != "Doc" && coviFile.fileInfos.length > g_boardConfig.LimitFileCnt){
		    //게시판에서 설정한 첨부파일 개수 제한에 걸림
	    	parent.Common.Warning(coviDic.dicMap["msg_ExceededNumberOfUpload"], "Warning Dialog", function () {     //파일을 업로드할 수 있는 개수를 초과하였습니다.
				//$("#selectFolderID").focus();
	        });
	    	return false;
		}
	    
		if( $("#chkIsTop").prop("checked") && ($("#TopStartDate").val() == "" || $("#TopEndDate").val() == "")){
			parent.Common.Warning(coviDic.dicMap["msg_EnterTopNoticeDate"], "Warning Dialog", function () {    //상단공지일자를 입력하세요
	        });
			return false;
		}
		if( $("#chkIsPopup").prop("checked") && ($("#PopupStartDate").val() == "" || $("#PopupEndDate").val() == "")){
			parent.Common.Warning(coviDic.dicMap["msg_EnterPopNoticeDate"], "Warning Dialog", function () {    //팝업공지일자를 입력하세요
	        });
			return false;
		}
		
		if(parseInt(g_currentTime.getTime() / 1000 / 60) > parseInt(new Date(replaceDate($("#ReservationDate").val() + ' ' + $("#reservationTime").val())).getTime() / 1000 / 60)){
			Common.Warning(Common.getDic("msg_cannotBookingBefore"));			//현재보다 이전 시간에 대해서 예약할 수 없습니다.
			return false;
		}
					
		//if($("#ReservationDate").val() >= )
	    
	    return true;
	},
	
	//이벤트 바인드
	bindEventByBizSection: function( pBizSection ){
		if(pBizSection != 'Doc'){
			board.setHourMin();			//시간은 0~23, 분은 00~59 5분단위로 잘라야한다면 board.js에서 수정
			coviInput.setDate();		//datepicker 바인드
			
			//1. 게시판 목록 조회
			if (typeof(treeList) !== 'undefined' && treeList.length > 0) {
				$("#selectFolderID").append("<option value=''>"+Common.getDic("lbl_Notice_Select")+"</option>");	
				$.each(treeList, function(i, item){
					if(item.FolderType != "Root" && item.FolderType != "Folder" && item.FolderType != "QuickComment") {
						$("#selectFolderID").append("<option value='"+item.FolderID+"'>"+item.FolderName+"</option>");
					}
				});				
				$("#selectFolderID").val(folderID);
			} else {
				$("#selectFolderID").coviCtrl( "setSelectOption",  "/groupware/board/selectBoardList.do", 	//SelectBox OptionData조회 URL
					{	bizSection: bizSection, menuID: menuID, communityID: communityID },	//Parameter
					Common.getDic("lbl_Notice_Select"),	""				//게시판 선택
				).val(folderID);
			}	
			
			$("[name=btnRevision]").hide();	//통합게시는 개정 버튼 숨김처리
			$("[name=btnNoticePreView]").hide(); // 미리보기 버튼 숨김처리

			//만료일, 상단공지, 예약게시 설정 표시/숨김
			$('.btnInqPer').on('click', function(){
				var mParent = $('.inPerView');
				$(this).parent().hasClass('active') == true ? $(this).parent().removeClass('active') :$(this).parent().addClass('active') ;
				
				if($('.btnInqPer').parent().hasClass('active')){
					mParent.addClass('active');
					coviInput.init();
//					$(this).closest('li').addClass('active');
				}else {
					mParent.removeClass('active');
//					$(this).closest('li').removeClass('active');
				}
				
//				if($('.btnNoti').parent().hasClass('active')){
//					$('.btnInqPer').parent().addClass('active');
//					$("#selectNotice, #chkIsTop, #TopStartDate, #TopEndDate, #chkIsPopup, #PopupStartDate, #PopupEndDate").prop("disabled", false);
//				} else {
//					$("#selectNotice, #TopStartDate, #TopEndDate, #PopupStartDate, #PopupEndDate").prop("disabled", true).val("");
//					$("#chkIsTop").prop("disabled", true).attr("checked", false);
//					$("#chkIsPopup").prop("disabled", true).attr("checked", false);
//				}
				
				// 체크 유무에 따라 달력 선택 활성/비활성
				$("#chkIsTop").prop("checked") ? $("#selectTopNotice, #TopStartDate, #TopEndDate").prop("disabled", false) : $("#selectTopNotice, #TopStartDate, #TopEndDate").prop("disabled", true).val("");
				$("#chkIsPopup").prop("checked") ? $("#selectPopupNotice, #PopupStartDate, #PopupEndDate").prop("disabled", false) : $("#selectPopupNotice, #PopupStartDate, #PopupEndDate").prop("disabled", true).val("");
				
				coviInput.init();	//달력컨트롤 탈출방지
			});
			
			// 버튼 클릭 이벤트
			$("#chkIsTop").on('click', function(){
				$("#chkIsTop").prop("checked") ? $("#selectTopNotice, #TopStartDate, #TopEndDate").prop("disabled", false) : $("#selectTopNotice, #TopStartDate, #TopEndDate").prop("disabled", true).val("");
			});
			$("#chkIsPopup").on('click', function(){
				$("#chkIsPopup").prop("checked") ? $("#selectPopupNotice, #PopupStartDate, #PopupEndDate").prop("disabled", false) : $("#selectPopupNotice, #PopupStartDate, #PopupEndDate").prop("disabled", true).val("");
			});
			
			//부서명 체크박스 이벤트 바인딩
			$("#chkUsePubDeptName").on("click", function(){
				if($(this).prop("checked")){
					$("#CreatorName").val($("#GroupName").val()).prop("disabled", true);
					$("#chkUseReply, #chkUseComment").prop("disabled", false);
					//$("#chkTopNotice, #chkReservation").prop("disabled", false);
				} else {
					$("#CreatorName").val($("#UserName").val());
					//상단공지, 예약게시 사용 불가 처리인데 이제 체크박스 안씀
		            //$('#chkTopNotice, #chkReservation').attr('checked', false).attr('disabled', true);
				}
				$("#chkUseAnonym").attr('checked',false);
			});

			//익명 게시 체크박스 이벤트 바인딩
			$("#chkUseAnonym").on("click", function(){
				if($(this).prop("checked")){
					//등록자 이름 삭제, 수정가능, 포커스 처리
					$("#CreatorName").val(Common.getDic("lbl_Anonymity")).prop("disabled",false).removeClass("inpReadOnly").focus();
					$('#chkUseReply, #chkUseComment').attr('checked', false).prop('disabled', true);
				} else {
					//기본 등록자 익명처리
					$("#CreatorName").val($("#UserName").val()).prop("disabled",true).removeClass("inpReadOnly").focus();
					$("#chkUseReply, #chkUseComment").prop("disabled", false);
				}
				$('#chkUsePubDeptName').attr('checked', false);
			});
			
			$("#chkIsPopup").on("change", function(){
				if($("#chkIsPopup").prop("checked")){
					$("[name=btnNoticePreView]").show();
				}else{
					$("[name=btnNoticePreView]").hide();
				}
			});
		} else {
			//게시판 외의 문서관리 화면 처리
			$("#hiddenFolderID").val(folderID);			//페이지 이동시 FolderID가 존재할경우 set
			$('.btnUrgent').hide();						//TOP 상단공지 아이콘 숨김
			//$("#selectKeepyear").val(3);				//기본 3년으로 설정
			
			var date = new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat));
            date.setFullYear(date.getFullYear()+3);
            date.setMonth(date.getMonth());
            date.setDate(date.getDate());
            $("#ExpiredDate").val(board.dateString(date).substring(0, 10));
			
			//부서목록 검색
			$("#selectRegistDept").coviCtrl("setSelectOption", "/groupware/board/selectRegistDeptList.do");
			
			//소유자 설정용 조직도 팝업 호출
			$("#btnOwner").on("click", function(){
				OrgMapLayerPopup_Owner();
			});
		}
		
		//기본설정탭 - 보안등급
		$("#selectSecurityLevel").coviCtrl("setSelectOption", "/groupware/board/selectSecurityLevelList.do");
		
		//BaseConfig에서 Security Level 기본값 조회
		var default_security = Common.getBaseConfig('DefaultSecurityLevel',sessionObj["DN_ID"]);
		$("#selectSecurityLevel").val(default_security);
		
		//상단 설정 접기 
		$('.btnMakeCont').on('click', function(){
			var mParent = $('.allMakeSettingView');
			if(mParent.hasClass('active')){
				mParent.removeClass('active');
				$(this).removeClass('active');
			}else {
				mParent.addClass('active');
				$(this).addClass('active');
			}
		});
		
		// 작성 화면 더보기 부분
		$('.btnSurMove').on('click', function(){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
				$("#divUserDefField").hide();
				$('.makeMoreInput').eq($( ".btnSurMove" ).index( this )).removeClass('active');
			}else {
				$(this).addClass('active');
				$("#divUserDefField").show();
				$('.makeMoreInput').eq($( ".btnSurMove" ).index( this )).addClass('active');
			}
		});
		
		//최상단으로 이동
		$('.btnTop').on('click', function(){
			$('.mScrollVH').animate({scrollTop:0}, '500');
		});
	},
	
	//게시판 옵션별 화면 표시 처리: 초기 화면에서는 모든 설정항목을 숨김표시하고 게시판 옵션에 따라 표시
	//초기 바인딩 시 pIsChange "N" 게시판 변경 시 "Y" 
	bindOptionControl: function(pFolderID, pIsChange, pIsFile){
		board.getBoardConfig(pFolderID);
		var optionList = g_boardConfig;
		$("#messageAuth, #messageReadAuth").val("");	//권한 설정 초기화
		$("#divTagList, #divLinkList").html("");		//태그, 링크 초기화
		$("#tagCount, #linkCount").text("(0개)");		//UI 표시용 Count: DB에 기록 하지 않음
		$(".btnInqPer").closest("li").removeClass("active");
		$(".inPerView").removeClass("active");
		
		//개별호출-일괄호출
		Common.getDicList(["msg_noWriteAuth","msg_contentAfterRegist","msg_contentAlreadyExist","lbl_CategorySelect"]);
		
		if(pFolderID != ""){
			if(mode == "update") {
				if(!board.checkModifyAuth(bizSection, folderID, messageID, version)){
					Common.Warning(Common.getDic("msg_noModifyACL"), "Warning", function(answer){ 		// 수정 권한이 없습니다.
						if(answer){
							cancelMessage();
						}
					});
				}
			} else {
				if(!board.checkFolderWriteAuth(pFolderID)){
					Common.Warning(coviDic.dicMap["msg_noWriteAuth"], "Warning Dialog", function () {	// 해당 분류에는 쓰기 권한이 없습니다.
						if(bizSection != "Doc"){
							var locationSearchArr = location.search.slice(1, location.search.length).split('&');
							var redirectLocationSearchArr = [];
							$.each(locationSearchArr, function(idx, el){
								if (el.indexOf('folderID') == -1) redirectLocationSearchArr.push(el);
							});
							CoviMenu_GetContent(location.pathname + '?' + redirectLocationSearchArr.join('&'));
						} else {
							$(".path").html("");
							$("#hiddenFolderID").val("");
						}
					});
					return false;
				}
			}
		}
		
		if(optionList.FolderType == "Contents" && mode == "create"){
			var contents = board.selectContentMessage(pFolderID);
			//선택한 컨텐츠 게시판에 게시물이 존재할 경우 상세보기 화면으로 이동 여부 확인 후 이동하지 않으면 게시판 선택 불가 처리
			if(!$.isEmptyObject(contents)){
				//해당 컨텐츠 게시판에 저장된 게시글이 존재합니다. 상세보기 화면으로 이동하시겠습니까?', '해당 컨텐츠 게시판에 저장된 게시글이 존재합니다. 상세보기 화면으로 이동하시겠습니까?
				Common.Confirm(coviDic.dicMap["msg_contentAfterRegist"], 'Confirmation Dialog', function (result) {
    	            if (result) {
    					//게시판 상세보기 조회 팝업
    	            	board.goView("Board", menuID, contents.Version, contents.FolderID, contents.MessageID, "", "", "", "", "", "List", "Normal", "", "");
    	            } else {
    	            	//컨텐츠 게시판에는 한개의 게시글만 등록 가능합니다. 다른 게시판을 선택해주세요.', '컨텐츠 게시판에는 한개의 게시글만 등록 가능합니다. 다른 게시판을 선택해주세요.
    	            	Common.Warning(coviDic.dicMap["msg_contentAlreadyExist"], "Warning Dialog", function () {
    	            		$('#selectFolderID').val("");
    			        });
    	            }
    	        });
				
			}
		}
		
		//문서 번호 자동 발번 옵션 사용
		if(optionList.UseAutoDocNumber == "Y"){
			$('#DocNumber').attr({placeholder:'AUTO', readonly:'readonly'}).addClass('inpReadOnly');
		}else{
			$('#DocNumber').attr({placeholder:''}).prop("readonly", false).removeClass('inpReadOnly');
		}
		
		//익명게시 사용
		if(optionList.UseAnony != "Y"){
			$('#chkUseAnonym, [for=chkUseAnonym]').hide();
			$("#CreatorName").val($("#UserName").val());
		} else {
			$('#chkUseAnonym').attr('checked', true);
			$('#chkUseAnonym, [for=chkUseAnonym]').show();
			$("#CreatorName").val(Common.getDic("lbl_Anonymity")).prop("disabled",false).removeClass("inpReadOnly").focus();;
			if(optionList.UsePubDeptName == "Y"){
				optionList.UsePubDeptName = "N";
				$('#chkUsePubDeptName, [for=chkUsePubDeptName]').hide();
			}
		}
		
		//부서명 게시 사용
		if(optionList.UsePubDeptName != "Y"){
			$('#chkUsePubDeptName, [for=chkUsePubDeptName]').hide();
		} else {
			$('#chkUsePubDeptName, [for=chkUsePubDeptName]').show();
		}
		
		//Limit 설정 영역
		$("#limitFileSize").text(optionList.LimitFileSize);	//업로드 파일 용량 제한
		$("#limitLinkCount").text(optionList.LimitLinkCnt);	//링크 설정 개수 제한, 태그의 경우 고정적으로 10개
		
		//링크 설정 제한
		if($("#divLinkList").children().size() >= optionList.LimitLinkCnt){
			$("#title").prop("disabled", true).attr("placeholder", "Link");
			$("#link").prop("disabled", true).attr("placeholder", "Max");
		}
		
		//카테고리 사용여부
		if(optionList.UseCategory == "Y"){
			$("#selectCategoryID").show();
			//분류 선택
			$("#selectCategoryID").coviCtrl("setSelectOption", "/groupware/board/selectCategoryList.do", 
				{folderID: pFolderID},
				coviDic.dicMap["lbl_CategorySelect"], "0"	
			);
		} else {
			$("#selectCategoryID").hide();
		}
		
		//본문기본내용
		var defaultContents = coviCmn.isNull(optionList.DefaultContents,'');
		if(pIsChange == "Y"){ 
			g_editorBody = defaultContents;
			coviEditor.setBody(g_editorKind, 'tbContentElement', g_editorBody);
		}
		
		//본문양식 사용여부
		if(optionList.UseBodyForm == "Y"){
			//표시 및 조회
			$("#divBodyForm").show();
			$("#selectBodyFormID").coviCtrl("setSelectOption", "/groupware/board/selectBodyFormList.do", {folderID: pFolderID}).val();
			if(pIsChange == "Y"){
				$("#selectBodyFormID").change();
			} 
		} else {
			//숨김처리
			$("#divBodyForm").hide();
			$("#selectBodyFormID").html("");
		}
		
		//사용자정의 필드  초기화, 사용 여부 체크 후 조회
		$("#divUserDefField").html("");
		if(optionList.UseUserForm == "Y" || Common.getBaseConfig("use" + bizSection + "MultiCategory") == "Y"){
			//게시판 환경설정에 따라 확장필드 조회 및 표시
			$("#divUserDefFieldHeader").show();
			$("#divUserDefFieldHeader").find(".btnSurMove").addClass("active");
			$("#divUserDefFieldHeader").next().addClass("active");
			board.getUserDefField("Write", pFolderID);
			$("#IsUserForm").val("Y");
		} else {
			//board_config의 UseUserForm이 N이면 게시글의 사용자정의폼도 N으로 설정
			$("#divUserDefFieldHeader").hide();
			$("#divUserDefFieldHeader").find(".btnSurMove").removeClass("active");
			$("#divUserDefFieldHeader").next().removeClass("active");
			$("#IsUserForm").val("N");
		}
		
		//본문사용 체크
		if (optionList.UseBody == "N"){
			$("#divWebEditor").hide();
		}else{
			$("#divWebEditor").show();
		}

		//경조사 게시판 이벤트 바인드
		if(Common.getBaseConfig("eventBoardID") == pFolderID){
			$("#divEventBoard").show();
   			setOwnerInput();
		} else {
			$("#divEventBoard").hide();
		}
		
		//승인프로세스 사용여부
        if (optionList.UseOwnerProcess == "Y" || optionList.UseUserProcess == "Y") {
            $("#IsApproval").val("Y");
            
            $("#divApprovalDiv").show();
            $("#divApprovalInfo").show();
            $('#spnApprovalLine').empty();
            
            //승인프로세스 사용 일때 답글 승인프로세스 사용여부
            if (optionList.UseReplyProcess == "Y") {
            	$("#IsReplyApproval").val("Y");
            }
            
            board.selectProcessActivityList(pFolderID);
		} else {
			$("#IsApproval").val("N");
			$("#divApprovalDiv").hide();
			$("#divApprovalInfo").hide();
			$('#spnApprovalLine').empty();
		}
        
        //열람권한 설정 영역 표시 숨김, 값 설정은 api호출전 별도로 작업
        if(optionList.UseMessageReadAuth == "Y"){
        	$("#btnUseMessageReadAuth").show();
        } else {
        	$("#btnUseMessageReadAuth").hide();
        }
        
        //상세권한 설정 표시/숨김
        if(optionList.UseMessageAuth == "Y" || bizSection == "Doc"){
        	$("#btnUseMessageAuth").show();
        } else {
        	$("#btnUseMessageAuth").hide();
        }
        
        //태그 
        if(optionList.UseTag == "Y"){
        	//태그 설정항목 표시
        	$("#divTagHeader").show();
        	$('#divTagHeader #tag').off('keypress').on('keypress', function(e){
        		if (e.which == 13) {
        	        e.preventDefault();
        	        board.addTag();
        	    }
        	});
        } else {
        	//태그  설정항목 숨김
        	$("#divTagHeader").hide();
			$("#divTagHeader").find(".btnSurMove").removeClass("active");
			$("#divTagHeader").next().removeClass("active");
        } 
        
        //링크
        if(optionList.UseLink == "Y"){
        	//링크 설정항목 표시 
        	$("#divLinkHeader").show();        	
        	$('#divLinkHeader #title, #divLinkHeader #link').off('keypress').on('keypress', function(e){
        		if (e.which == 13) {
        	        e.preventDefault();
        	        board.addLink();
        	    }
        	});
        } else {
        	//링크 설정항목 숨김
        	$("#divLinkHeader").hide();
			$("#divLinkHeader").find(".btnSurMove").removeClass("active");
			$("#divLinkHeader").next().removeClass("active");
        }
        
        //팝업, 상단공지 표시/숨김처리
        if(optionList.FolderType == "Notice" && optionList.UseTopNotice == "Y"){
//        	$(".btnNoti").parent().show();
        	$("#divTopNotice, #divPopupNotice").show();
        } else if(optionList.FolderType != "Notice" && optionList.UseTopNotice == "Y"){
//        	$(".btnNoti").parent().show();
        	$("#divTopNotice").show();
        	$("#divPopupNotice").hide();
        } else {
//        	$(".btnNoti").parent().hide();
        	$("#divTopNotice, #divPopupNotice").hide();
        }
        
        //예약 게시, 예약 일시 
        if(optionList.UseReservation == "Y"){
        	$('#divReservation').show();
        } else {
        	$('#divReservation').hide();
        	$('#ReservationDate').val("");
        	$('#reservationTime').val("00:00");
        }
		coviInput.init();	//달력컨트롤 탈출방지.
        
        //일괄 체크하여 div영역 자체를 숨김
        $('#divConfigGroup input[type=checkbox]').prop('checked',false);
        
        //BaseConfig에서 Security Level 기본값 조회
		var default_security = Common.getBaseConfig('DefaultSecurityLevel',sessionObj["DN_ID"]);
		$("#selectSecurityLevel").val(default_security);
		
        if( optionList.UseSecurity != "Y"
        	&& optionList.UseReply != "Y"
        	&& optionList.UseComment != "Y"
        	&& optionList.UseScrap != "Y"){
        	$("#divConfigGroup").hide();
        } else {
        	$("#divConfigGroup").show();
        	//개별적으로 체크박스 숨김처리
        	//스크랩
            if(optionList.UseScrap == "Y") {
            	$("#spanScrap").show();
            } else {
            	$("#spanScrap").hide();
            }
        	
        	//비밀글 
        	if(optionList.UseSecret == "Y") {
            	$("#spanSecurity").show();
            } else {
            	$("#spanSecurity").hide();
            }
        	/*
        	//답글 사용시 답글 알림 사용여부 표시
        	if(optionList.UseReply == "Y") {
            	$("#spanReplyNotice").show();
            } else {
            	$("#spanReplyNotice").hide();
            }
        	
        	//코멘트 사용시 코멘트 알림 사용여부 표시
        	if(optionList.UseComment == "Y") {
            	$("#spanUseCommNotice").show();
            } else {
            	$("#spanUseCommNotice").hide();
            }
            */
            //답글 사용시 답글 알림 사용여부 표시
        	if(optionList.UseReply == "Y") {
            	$("#chkUseReplyNotice").prop("checked", true);
            }
        	
        	//코멘트 사용시 코멘트 알림 사용여부 표시
        	if(optionList.UseComment == "Y") {
            	$("#chkUseCommNotice").prop("checked", true);
            }
        }
    	
        //연결글, 문서관리에서는 무조건 표시
        if(optionList.UseLinkedMessage == "Y" || bizSection == "Doc"){
    		$("#divLinkedMessage").show();
//    		$("#divLinkedMessage").find(".btnSurMove").addClass("active");
//    		$("#divLinkedMessage").next().addClass("active");
    	} else {
    		$("#divLinkedMessage").hide();
    		$("#divLinkedMessage").find(".btnSurMove").removeClass("active");
    		$("#divLinkedMessage").next().removeClass("active");
    	}
        
        //작성자 만료일 수정 가능 여부
		if (optionList.UseExpiredDate == "Y") {
			$('#ExpiredDate').css('display', 'block');
            $("#divExpiredDate").show();
        } else{
        	$('#ExpiredDate').css('display', 'none');
        	$("#divExpiredDate").hide();
		}
		
		if (optionList.ExpireDay != undefined && optionList.ExpireDay != 0) {		
            var date = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
            date.setFullYear(date.getFullYear());
            date.setMonth(date.getMonth());
            date.setDate(date.getDate() + parseInt(optionList.ExpireDay, 10));
            $("#ExpiredDate").val(board.dateString(date).substring(0,10).replaceAll("-",".")).css('display', '');
        }
		
		//우측버튼 표시 여부 결정
		if(optionList.UseReservation == "Y" || optionList.UseExpiredDate == "Y" || optionList.UseTopNotice == "Y" || optionList.UsePopNotice == "Y"){
			$(".btnInqPer").parent().show();
        } else {
        	$(".btnInqPer").parent().hide();
        }
		
        //링크사이트게시판설정
        if(optionList.FolderType == "LinkSite"){
        	$("#divLinkSiteBoard").show();
        } else {
        	$("#divLinkSiteBoard").hide();
        }   
        
        if(pIsFile == null || pIsFile == "N") {
	    	coviFile.fileInfos.length = 0;
			
			//File Upload 공통 컨트롤
			if ((bizSection == "Doc" && mode != 'binder') || (bizSection == "Board" && optionList.UseFile == "Y") || (bizSection == "Community" && optionList.UseFile == "Y")) {
				var imageFileOption = "false";
				
				if((bizSection == "Board" && optionList.FolderType == "Album") || (bizSection=="Community")){
					imageFileOption = "true";
				}			
				
				$("#con_file").empty();
				
				coviFile.renderFileControl('con_file', {listStyle:'table', actionButton :'add', multiple : 'true', image : imageFileOption});
				$("#fileDiv").show();
			} else {
				$("#fileDiv").hide();
			}
		}
		
		//답글, 댓글, 알림 매체를 사용할 경우
		/*
		if((optionList.UseReply == "Y" || optionList.UseComment == "Y") && g_noticeMedia.length > 0){
			$("#divNoticeMedia").show();
			$("#divMediaList").html("");
			var mediaList = "";
			// DB 조회 할때는 sortKey가 0 인 데이터는 제외하고 가져와야함
			// CHECK: CodeGroup에 왜 NotificationMedia가 들어있는지 확인필요
			$.each(g_noticeMedia, function(i, item){
				if(i == 0) return true;
				mediaList += String.format("<div class='alarm type01'><span>{0}</span><a href='#' id='{1}' class='onOffBtn'><span></span></a></div>", item.CodeName, item.Code);
			});
			
			$("#divMediaList").html(mediaList);
			
			// 알림문구
			var notiInfoMsg = "<span class='sNoti' style='margin: 15px 10px 0 0;'>* 개인환경설정에 활성화되지 않은 매체로는 발송되지 않습니다.</span>";
			
			$("#divMediaList").append(notiInfoMsg);
			
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
		
		$("#divNoticeMedia").hide();
		
		coviFile.option.fileEnable = (optionList.EnableFileExtention != null && optionList.EnableFileExtention != "") ? optionList.EnableFileExtention : coviFile.option.fileEnable;
		coviFile.option.fileImageEnable = (optionList.EnableFileExtention != null && optionList.EnableFileExtention != "") ? optionList.EnableFileExtention : coviFile.option.fileImageEnable;
		coviFile.option.fileSizeLimit = (optionList.LimitFileSize != 0) ? optionList.LimitFileSize : optionList.FileSize;
		coviFile.option.totalFileSize = (optionList.TotalFileSize != 0) ? optionList.TotalFileSize : optionList.FileSize;
		coviFile.option.limitFileCnt = optionList.LimitFileCnt;
		
		if(optionList.FolderType == "Album") {
			$("#coviFileTooltip").text(coviFile.option.fileImageEnable.replaceAll(',', ', '));
		} else {
			$("#coviFileTooltip").text(coviFile.option.fileEnable.replaceAll(',', ', '));
		}
		
		if(optionList.FolderType == "Album") {
			$("#coviFileTooltip").text(coviFile.option.fileImageEnable.replaceAll(',', ', '));
		}
		
		if(bizSection == 'Board' && g_boardConfig.UseExpiredDate == 'N' && g_boardConfig.ExpireDay > 0) {
			$(".subUnputBoxStyle").append(getExpiredDateHTML());
		}
		
		board.renderFileLimitInfo();
	},
	//버젼벌 보기 (버젼별 보기시 곧바로 selectMessageDetail을 호출할 경우 renderMessageOptionView가  현재 게시 조회 시 중복 호출됨.)
	//그렇다고 renderMessageOptionView를 selectMessageDetail 호출후 실행되도록 수정하면 selectMessageDetail의 사용폭이 좁아질거 같음.
	selectVersionMessageDetail:  function(pPageType, pBizSection, pVersion, pMessageID, pFolderID){ //버젼벌 보기 
		board.selectMessageDetail(pPageType, pBizSection, pVersion, pMessageID, pFolderID);
		board.renderMessageOptionView(pBizSection, pVersion, pMessageID, pFolderID);
	},
	//게시글 정보 조회: 게시 수정화면 및 상세보기에 사용
	selectMessageDetail: function(pPageType, pBizSection, pVersion, pMessageID, pFolderID){
		var readFlag = false;	//읽기 권한
		readFlag = board.checkReadAuth(pBizSection, pFolderID, pMessageID, pVersion);
		$.ajax({
			type:"POST",
			data: {
				"bizSection": pBizSection,
				"version": pVersion,
				"messageID": pMessageID,
				"folderID": pFolderID,
				"readFlagStr": readFlag
			},
			url:"/groupware/board/selectMessageDetail.do",
			async: false,
			success:function(data){
				if(data.status == "SUCCESS"){
					var config = data.list;
					g_messageConfig = data.list;
					g_messageConfig.fileList = data.fileList;
					
					//작성화면과 상세조회화면에서 표시 처리하기 위한 분기처리
					if(pPageType == "View"){
						var currentUser = sessionObj["USERID"];
						if(g_boardConfig.FolderType == "OneToOne") {
							// 1:1게시판의 경우 작성자이거나 게시판 담당자가 아닌경우 조회불가
							if(!(g_boardConfig.OwnerCode.indexOf(currentUser) > -1 || data.list.OwnerCode == currentUser)) {
								Common.Inform(Common.getDic("lbl_NoReadAuth"), "Warning Dialog", function(){ //조회권한이 없습니다
									if(g_urlHistory == null){
										g_urlHistory = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuID=" + Common.getBaseConfig("BoardMain");
									}
									CoviMenu_GetContent(g_urlHistory);
								});
								return;
							}
						}
						
						//한줄 게시는 읽기권한 체크 안함
						if(g_boardConfig.FolderType == "QuickComment"){
							readFlag = true;
						}
						
						if(pBizSection == "Board"){
							$(".tagView").before("<div class='authView'></div>");
							$(".authView").html('');
							//열람권한
							if(!(g_boardConfig.UseMessageReadAuth=="N")){
								board.renderReadAuth(pBizSection, pMessageID, pFolderID);
							}	
							//보안등급
							board.renderSecurityLevel(config);
						}
						
						// 열람 권한 확인
						// checkReadAuth에서 함께 체크하도록 수정
						/*if(g_messageConfig.UseMessageReadAuth == "Y"){
							//열람권한 테이블에서 조회된 데이터가 없을경우
							if(board.getMessageReadAuthCount(bizSection, messageID, folderID) > 0){
								readFlag = true;
							}
						}*/

						// 삭제 날짜 확인 후 관리자가 아닐 경우, 관리자이면 삭제 게시물 관리 이므로 보여준다.
						if(!readFlag || ((g_messageConfig.DeleteDate != undefined && g_messageConfig.DeleteDate.trim() != "") && sessionObj["isAdmin"] != "Y")){
							var errMsg = Common.getDic("lbl_NoReadAuth") ;
							if (readFlag) errMsg = Common.getDic("msg_50");	//삭제된 게시판
							
							Common.Inform(errMsg, "Warning Dialog", function(){	//조회권한이 없습니다
								if(CFN_GetQueryString("CFN_OpenLayerName") != 'undefined'){ //팝업일 경우 
									parent.Common.close(CFN_GetQueryString("CFN_OpenLayerName"));
								}else if(CFN_GetQueryString("CFN_OpenWindowName") != 'undefined'){ //윈도우 팝업일 경우 
									window.close();
								}else{
									if(g_urlHistory == null){
										g_urlHistory = "/groupware/layout/board_BoardList.do?CLSYS=board&CLMD=user&CLBIZ=Board&boardType=Total&menuID=" + Common.getBaseConfig("BoardMain");
									}
									CoviMenu_GetContent(g_urlHistory);
								}
							});
							return;
						} else {
							board.renderMessageInfoView(pBizSection, config);
						}
						
						//게시글 권한별 및 상단 버튼 표시/숨김처리==>서버로 로직 이동 22/07/13 kimhy2
						//board.checkAclList();	
					} else if(pPageType == "Write"){
						board.renderMessageInfoWrite(pBizSection, config);
					}
				} else {
					Common.Warning(Common.getDic("msg_notHaveAccess"), "Warning", function(result){ // 접근권한이 없습니다.
						if(viewType == "Popup"){
							if(opener != null){
								window.close();
							}else if(parent != null){
								Common.Close();
							}
						}else{
							CoviMenu_GetContent(g_urlHistory);
						}
					});
					return;
				}
			},
			error:function(response, status, error){
			    CFN_ErrorAjax("/groupware/board/selectMessageDetail.do", response, status, error);
			}
		});
	},
	
	//게시글 정보 조회: 게시 수정화면 및 상세보기에 사용
	selectOriginMessageInfo: function(pBizSection, pVersion, pMessageID, pFolderID){
	 	$.ajax({
	 		type:"POST",
	 		data: {
				"bizSection": pBizSection,
	 			"version": pVersion,
	 			"messageID": pMessageID,
	 			"folderID": pFolderID,
	 		},
	 		url:"/groupware/board/selectMessageDetail.do",
	 		success:function(data){
	 			var config = data.list;
	 			
	 			$("#Subject").val("RE:"+config.Subject);
	 			$("#OwnerCode").val(config.OwnerCode);
	 			$("#Seq").val(config.Seq);
	 			$("#Step").val(config.Step);
	 			$("#Depth").val(config.Depth);
	 		},
	 		error:function(response, status, error){
	 		     CFN_ErrorAjax("/groupware/board/selectMessageDetail.do", response, status, error);
	 		}
	 	});
	},
	
	//작성 페이지에서 게시글 정보 설정
	renderMessageInfoWrite: function(pBizSection, pConfig){
		for(var key in pConfig) {
    		//Use로 시작되는 항목은 전부 체크박스 처리
		    if(/^Use/.test(key)){
		    	pConfig[key] == "Y"?$("#chk"+key).prop('checked',true):$("#chk"+key).prop('checked',false);
		   	} else if (/^Is/.test(key)){
    		   	//is로 시작되는 항목은 전부 selectbox처리
		   		$("#select"+key).val(pConfig[key]+"");
    		} else {
    		   	$("#"+key).val(pConfig[key]);
    		}
		}
			
		$("#selectCategoryID").val(pConfig.CategoryID);
		$("#selectSecurityLevel").val(pConfig.SecurityLevel);
		$("#IsApproval").val(pConfig.IsApproval);
		$("#IsInherited").val(pConfig.IsInherited);
		$("#UseMessageReadAuth").val(pConfig.UseMessageReadAuth);
		
		if(pConfig.IsTop == "Y" || pConfig.IsPopup == "Y"){	//공지 영역 활성화 여부
//			$('.btnNoti').parent().addClass('active');	//공지 스피커 버튼 활성화
			$('.inPerView').addClass('active');			//공지 날짜 입력창 표시
			
			if(pConfig.IsPopup=="Y"){
				$('#chkIsPopup').prop('checked',true);
				$("[name=btnNoticePreView]").show();
			}else{
				$('#chkIsPopup').prop('checked',false)
			}
		}

		// 만료일
		pConfig.ExpiredDate.indexOf('9999') != -1 ? $("#ExpiredDate").val('') : $("#ExpiredDate").val(pConfig.ExpiredDate);
		
		// 상단공지, 팝업 체크박스 체크 여부
		pConfig.IsTop=="Y"?$('#chkIsTop').prop('checked',true):$('#chkIsTop').prop('checked',false);
		pConfig.IsPopup=="Y"?$('#chkIsPopup').prop('checked',true):$('#chkIsPopup').prop('checked',false);

		// 상단공지, 팝업 달력 선택 활성/비활성
		pConfig.IsTop=="Y"?$("#TopStartDate, #TopEndDate").prop("disabled", false) : $("#TopStartDate, #TopEndDate").prop("disabled", true).val("");
		pConfig.IsPopup=="Y"?$("#PopupStartDate, #PopupEndDate").prop("disabled", false) : $("#PopupStartDate, #PopupEndDate").prop("disabled", true).val("");
		
		if(pBizSection == "Doc"){
			//$("#hiddenFolderID").val(pConfig.FolderID);
			$("#DocNumber").val(pConfig.Number).prop("disabled", true);
			$("#selectKeepyear").val(pConfig.KeepYear);
			if(mode == "migrate"){	//문서이관의 경우 작성할때와 동일하게 부서 정보 selectbox표시
				$("#selectRegistDept").show();
				$("#RegistDeptName").hide();
			} else {
				$("#selectRegistDept").hide();								//작성시에 설정한 부서정보는 수정불가: 관리자만 수정
				$("#RegistDeptName").text(pConfig.RegistDeptName).show();	//부서정보만 표시
				$("#divOwnerName").hide();
				$("#spanOwnerName").text(pConfig.OwnerName).show();
			}
		}
		
		if(pConfig.ReservationDate != undefined){
			pConfig.ReservationDate = CFN_TransLocalTime(pConfig.ReservationDate);
			$("#ReservationDate").val(pConfig.ReservationDate.substring(0,10));
			$("#reservationTime").val(pConfig.ReservationDate.substring(11,13) + ":" + pConfig.ReservationDate.substring(14,16))
		}
		
		if(pConfig.NoticeMedia != undefined && pConfig.NoticeMedia != "" && pConfig.NoticeMedia.trim() != ""){
			var noticeMedia = pConfig.NoticeMedia.split(";");
			$("#divMediaList").children().find('a').removeClass('on');	//버튼 초기화
			$.each(noticeMedia, function(i, item){
				$("#"+noticeMedia[i]).addClass('on');
			});
		}
		
		//에디터에 본문정보 설정
		/*setTimeout(function (){ 
			coviEditor.setBody(g_editorKind, 'tbContentElement', unescape(pConfig.Body));
		}, 1500);*/
		g_editorBody = unescape(pConfig.Body);
		
		//File Upload 공통 컨트롤 - 파일 목록 바인딩
		if ((bizSection == "Doc" && mode != 'binder') || (bizSection == "Board" && g_boardConfig.UseFile == "Y") || (bizSection == "Community" && g_boardConfig.UseFile == "Y")) {					
			if(mode == "migrage" || mode == "update"){
				var fileList = JSON.parse(JSON.stringify(pConfig.fileList));
				coviFile.setFile('con_file', fileList);
			}
		} 
	},
	
	//문서관리와 일반 게시판의 경우 분기처리 필요사항 적용
	setDataByBizSection: function(pBizSection, pFormData ){
		//form내부 입력,설정사항 formData에 설정
	    var messageData = $('#formData').serializeArray();
	    $.each(messageData,function(key,input){
	    	pFormData.append(input.name,input.value);
	    });

	  	//체크박스 체크 안된 Element의 이름으로 formData에 ''값으로 추가, controller에서 공백값은 N으로 처리
	    $("#formData input[type=checkbox]:not(:checked)").each(function(){ pFormData.append(this.name, ''); });
		
		//Board, Doc 타입별 데이터 맵핑 
		switch(pBizSection){
			case "Board": case "Community":
				pFormData.append("msgType", "O");	//O: 원본, S: 스크랩
				
				// 상단공지 체크에 따른 FormData 처리 
				if($("#chkIsTop").prop("checked")){	
					pFormData.append("isTop", "Y");
					pFormData.append("topStartDate", board.dateTime($("#TopStartDate").val(), "00:00:00"));
					pFormData.append("topEndDate", board.dateTime($("#TopEndDate").val(), "23:59:59"));
				}else{
					pFormData.append("isTop", "N");
					pFormData.append("topStartDate", "0000-00-00 00:00:00");
					pFormData.append("topEndDate", "0000-00-00 00:00:00");					
				}
				
				//팝업공지 체크에 따른 FormData 처리
				if($("#chkIsPopup").prop("checked")){ 
					pFormData.append("isPopup", "Y");
					pFormData.append("popupStartDate", board.dateTime($("#PopupStartDate").val(), "00:00:00"));
					pFormData.append("popupEndDate", board.dateTime($("#PopupEndDate").val(), "23:59:59"));
				}else{
					pFormData.append("isPopup", "N");
					pFormData.append("popupStartDate", "0000-00-00 00:00:00");
					pFormData.append("popupEndDate", "0000-00-00 00:00:00");
				}

				//링크 기능 설정
				if(g_boardConfig.UseLink == "Y"){
					pFormData.append("linkList", encodeURIComponent(board.setLinkData()));
				}

				//예약 계시 설정
				if($("#ReservationDate").val()!="" && $("#ReservationDate").val() != undefined){
					var reservationDate = String.format("{0} {1}:00",$("#ReservationDate").val(), $("#reservationTime").val());
					pFormData.append("reservationDate", reservationDate);
				}
				
				var noticeMedia = "";
				if($("#divMediaList").children().find('a.on').size() > 0){
					$.each($("#divMediaList").children().find('a.on'), function(i, item){
						noticeMedia += $(this).attr("id") + ";";
					});
				}
				pFormData.append("noticeMedia", noticeMedia);
				
				//경조사 게시판 - 임직원 소식 웹파트에 표시될 사용자 코드 설정
				$("#EventOwner").parent().children('.ui-autocomplete-multiselect-item').each(function () {
			        pFormData.append("eventOwnerCode", $(this).attr("data-value"));
			    });
				pFormData.append("eventDate", $("#EventDate").val());
				pFormData.append("eventType", $("#EventType option:selected").val());
				break;
			case "Doc":
				pFormData.append("folderID", $("#hiddenFolderID").val());
				if(mode == "binder"){
					pFormData.append("msgType", "B");
				} else {
					pFormData.append("msgType", "N");
				}
				//문서번호 자동발번의 경우 class레벨에서 조회해서 사용예정
				//문서 번호 설정: 수동, 자동(클래스 단에서 설정함)
				//문서등급 : 일반문서, 보안문서
				//연결문서: 게시글 연결과 동일
				//권한설정: 보안, 삭제, 수정, 읽기 SDMR
				break;
			default:
				//bizSection 누락
				parent.Common.Warning("잘못된 접근입니다. BizSection 누락", "Warning Dialog", function () {     //분류명 입력
					
		        });
		}
		
		if(g_boardConfig.UseBody == "Y"){ //본문 체크 해제 시 editor 사용 안하도록 설정
			/****** 공통기능: 본문, 파일업로드, 만료일, 상세권한, 사용자 정의 필드 설정 *****/
			//공통 파일 업로드에서 선언된 coviFile.fileInfos 사용
			var body = escape(coviEditor.getBody(g_editorKind, 'tbContentElement'));
			var bodyText = coviEditor.getBodyText(g_editorKind, 'tbContentElement');
			var bodyInlineImage= escape(coviEditor.getImages(g_editorKind, 'tbContentElement'));
			var bodyBackgroundImage = escape(coviEditor.getBackgroundImage(g_editorKind, 'tbContentElement'));
			pFormData.append("bodySize", bodyText.length);
			pFormData.append("bodyText", bodyText);
			pFormData.append("bodyInlineImage", bodyInlineImage);
			pFormData.append("bodyBackgroundImage", bodyBackgroundImage);
			pFormData.append("body", body);
			if(AwsS3.isActive()){
				pFormData.append("frontStorageURL", escape(Common.getGlobalProperties("smart4j.path")+"/covicore/common/photo/photo.do?img="+Common.getGlobalProperties("frontAwsS3.path")));
			}else{
				pFormData.append("frontStorageURL", escape(Common.getGlobalProperties("smart4j.path")+ Common.getBaseConfig("FrontStorage")));
			}
			pFormData.append("fileInfos", JSON.stringify(coviFile.fileInfos));
		}
		
		//태그 설정, 태그의 경우 공통컨트롤로 빠질 수 있기 때문에 기존상태 유지 
		if(g_boardConfig.UseTag == "Y"){
			pFormData.append("tagList", encodeURIComponent(board.setTagData()));
		}
		
	    // 파일정보
	    for (var i = 0; i < coviFile.files.length; i++) {
	    	if (typeof coviFile.files[i] == 'object') {
	    		pFormData.append("files", coviFile.files[i]);
	        }
	    }
	    pFormData.append("fileCnt", coviFile.fileInfos.length);

		//만료일 설정
		if($("#ExpiredDate").val() != ""){
			pFormData.append("expiredDate", board.dateTime($("#ExpiredDate").val(), "00:00:00"));
		} else{
			pFormData.append("expiredDate", board.dateTime("9999.12.31", "00:00:00"));
		}
		
		/* 상세 메시지 설정을 사용할경우 열람권한 조회는 사용안함 처리된다.
		if($("#messageAuth").val() != "" && $("#UseMessageAuth").val() == "Y"){
			$("#UseMessageReadAuth").val("N");
		}
		*/
		
		pFormData.append("aclList", encodeURIComponent($("#messageAuth").val()));

		//사용자정의 필드(사용자정의폼) 설정
		if($("#IsUserForm").val() == "Y"){
			pFormData.append("fieldList", encodeURIComponent(board.setUserDefFieldData()));
		}
		
		//링크게시판
		if(g_boardConfig.FolderType == "LinkSite"){
			pFormData.append("linkURL", $("#LinkURL").val());
		}
	},
	
	//상세보기 게시글 기본정보 항목 표시/숨김
	renderMessageInfoView: function(pBizSection, pConfig){
		$("#FolderName").text(g_boardConfig.FolderPathName.replace(/;/g, ' > ') + CFN_GetDicInfo(g_boardConfig.MultiDisplayName));
		$("#Subject").text(pConfig.Subject).attr('title', pConfig.Subject);
		
		//게시글 타입 표시
		var messageType = '<span class="btnType02 {0}">{1}</span>';
		
		$(".boardTitData .btnType02").remove();
		if (g_boardConfig.UseCategory == 'Y'){
			setTimeout(function(){
				$("#categoryName").remove();
				var upperCategory = $("#selectCategoryID option[value="+pConfig.CategoryID+"]").attr("data-memberof");
				var categorieGroup = (upperCategory != null && upperCategory != "") ? upperCategory + ' > ' + pConfig.CategoryName : pConfig.CategoryName;
				
				if(categorieGroup != null && categorieGroup != "") {
					$("#FolderName").after('<div id="categoryName" class="boxDivTit"> ' + categorieGroup + '</div>');
				}
			}, 100);
		}		
		
		if(pConfig.MsgType == "S")
			$(".boardTitData").prepend( String.format(messageType, "jinGrey", Common.getDic('lbl_Scrap')));
		
		if(pConfig.IsApproval == "Y"){
			$(".boardTitData").prepend( String.format(messageType, "jinGrey", Common.getDic('lbl_ApprovalProcess')));
		} else {
			$(".boardTitData").prepend( String.format(messageType, "jinGrey", Common.getDic('lbl_normalMessage')));
		}
		
		if(pConfig.UseSecurity == "Y")
			$(".boardTitData").prepend( String.format(messageType, "red", Common.getDic('lbl_chkSecurity')));
		
		//게시만료일, 상세보기 tooltip data
		var boardDataList = [];
		var ResigstDate = pConfig.RegistDate.slice(0,-3);
		var ModifyDate = pConfig.ModifyDate.slice(0,-3);
		if(bizSection == "Board"){ 
			if (pConfig.ExpiredDate.split('.')[0] != "9999"){ //게시만료일
				boardDataList.push('<span>'+Common.getDic("lbl_ExpiredDate")+'</span>'+(pConfig.ExpiredDate).replaceAll('.','-')); 
			}
			if(Common.getBaseConfig('BoardModifyDateTimeSet') != ''){
				if (Common.getBaseConfig('BoardModifyDateTimeSet') < ResigstDate && ResigstDate != ModifyDate) { //수정일시
					boardDataList.push('<span class="tx_ex">'+Common.getDic("lbl_ModifyDateTime")+'</span>'+pConfig.ModifyDate+'</br>'); 
				}
			}
			if (pConfig.PopupStartDate != "0000.00.00" && pConfig.PopupStartDate != "") { //팝업공지 
				boardDataList.push('<span class="tx_ex">'+Common.getDic("lbl_NoticePopup")+'</span>'+pConfig.PopupStartDate+'~'+pConfig.PopupEndDate+'</br>');
			}
			if (pConfig.TopStartDate != "0000.00.00" && pConfig.TopStartDate != "") { //상단공지
				boardDataList.push('<span class="tx_ex">'+Common.getDic("lbl_NoticeTop")+'</span>'+pConfig.TopStartDate+'~'+pConfig.TopEndDate+'</br>');
			}
			if (pConfig.ReservationDate != "") { //예약게시일
				boardDataList.push('<span class="tx_ex">'+Common.getDic("lbl_ReservationDate")+'</span>'+pConfig.ReservationDate+'</br>');
			}
			
			//boardDataList의 첫번째 값을 노출
			if(boardDataList.length > 0){
				$("#ExpiredDate").html('');
				$("#ExpiredDate").append(boardDataList[0]);
				$("#ExpiredDate span").after(" : ");
				boardDataList.shift();
				//첫번째 값이 마지막 값일 경우 tooltip제거
				if(boardDataList.length < 1){
					$("#boardIcon").removeClass("help_ico");
				}
				$(".boardData").append(boardDataList);
				
				$("#boardIcon").mouseover(function() {
					$(this).toggleClass("active");
				});
				
				$("#boardIcon").mouseout(function() {
					$(this).toggleClass("active");
				});
				
			}else{
				$("#boardIcon").removeClass("help_ico");
			}
		}else{
			$(".collabo_help02").remove();
		}

		$("#RegistDate").text(CFN_TransLocalTime(pConfig.RegistDate) + " " + Common.getSession("UR_TimeZoneDisplay"));									//작성일
		
		if(bizSection != 'Board' || g_boardConfig.UseReadCnt == "Y"){
			$("#ReadCnt").text(pConfig.ReadCnt);										//조회수
		}else{
			$("#ReadCnt").hide();
		}
//		var displayName = pConfig.CreatorName+ " " + pConfig.CreatorLevel.split(";").join("");
		
		if (pConfig.UsePubDeptName == "Y"){
			$("#CreatorName").text(g_messageConfig.CreatorDept);
		} else {
			if(pConfig.UseAnonym != "Y"){
				$("#CreatorDept").text("(" + pConfig.CreatorDept + ")");			//익명 게시 사용시에는 표시하지 않음(부서명)
				$('#CreatorPhoto').attr('src', coviCmn.loadImage(pConfig.PhotoPath));					//프로필 사진 설정
				var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
				var sRepJobType = pConfig.CreatorLevel;
		        if(sRepJobTypeConfig == "PN"){
		        	sRepJobType = pConfig.CreatorPosition;
		        } else if(sRepJobTypeConfig == "TN"){
		        	sRepJobType = pConfig.CreatorTitle;
		        } else if(sRepJobTypeConfig == "LN"){
		        	sRepJobType = pConfig.CreatorLevel;
		        }
				$("#CreatorName").text(pConfig.CreatorName+ " " + sRepJobType);
				$("#CreatorName").css({"position":"relative","cursor":"pointer"});
				$("#CreatorName").attr("onclick","coviCtrl.setFlowerName(this)");
				$("#CreatorName").attr({"data-user-code":pConfig.CreatorCode, "data-user-mail":""});
				$("#CreatorName").addClass("btnFlowerName");
			} else {
				$('#CreatorPhoto').attr('src', "/covicore/resources/images/no_profile.png");	//프로필 사진 기본이미지로 변경
				$("#CreatorName").text(pConfig.CreatorName);
			}
		}
		
		// CHECK: 사용자 정보 Context Menu 퍼블리싱 수정 이후 변경
		// $("#CreatorName").html(coviCtrl.formatUserContext("View", displayName, pConfig.CreatorCode));	//작성자 이름 직급
		
		//게시 내용
		$("#BodyText").html(board.XSSBoard(coviUtil.replaceInlinePhotoMig(unescape(pConfig.Body))));
		
		// ie 에서 휴대폰으로 찍은 사진 회전하는 현상 처리
		if (_ie && $("#BodyText img").length > 0) {
			board.setImageRotate($("#BodyText img"));
		}
		
		//댓글 표시
		if(g_boardConfig.UseComment == "Y"){
			//댓글알림 관련 연동정보 설정
			if(pConfig.UseCommNotice == "Y"){
				//연결 URL
				var goToUrl = String.format("{0}/groupware/layout/board_BoardView.do?CLSYS={1}&CLMD=user&CLBIZ={2}&version={3}&folderID={4}&messageID={5}&menuID={6}&viewType=List&startDate=&endDate=&searchType=&searchText=&sortBy=&page=1&pageSize=10&menuCode={7}", Common.getGlobalProperties("smart4j.path"), bizSection, bizSection, pConfig.Version, pConfig.FolderID, pConfig.MessageID,CFN_GetQueryString("menuID"),CFN_GetQueryString("menuCode"));
				var mobileUrl = String.format("/groupware/mobile/board/view.do?version={0}&folderid={1}&messageid={2}", pConfig.Version, pConfig.FolderID, pConfig.MessageID);
				
				 if (CFN_GetQueryString("communityId") != "undefined" && CFN_GetQueryString("communityId") != ""){
					 goToUrl += String.format("&communityId={0}&CSMU={1}&activeKey={2}", CFN_GetQueryString("communityId") , CFN_GetQueryString("CSMU"), CFN_GetQueryString("activeKey"));
					 mobileUrl += String.format("&cuid={0}", CFN_GetQueryString("communityId"));
				 }
				
				//알림 옵션
				var messageSetting = {
				    SenderCode : g_userCode,
				    RegistererCode : g_userCode,
				    ReceiversCode : pConfig.CreatorCode,
				    MessagingSubject : pConfig.Subject,
				    ReceiverText : pConfig.Subject, //요약된 내용
				    ServiceType : pBizSection, 
				    GotoURL: goToUrl,
				    PopupURL: goToUrl,
				    MobileURL: mobileUrl,
				    Width:"700",
				    Height:"980",
				    MsgType : "Comment",
				    MentionMsgType: "CommentMention"
				};
				coviComment.load('divComment', bizSection, pConfig.MessageID+"_"+pConfig.Version, messageSetting, g_boardConfig.FolderType);
			} else {
				coviComment.load('divComment', bizSection, pConfig.MessageID+"_"+pConfig.Version, null, g_boardConfig.FolderType);
			}
		}
		
		//카테고리와 만료일 표시 분기 처리
		$(".sNoti").html("");
		if(g_boardConfig.UseCategory == "Y" && g_boardConfig.UseExpiredDate == "Y"){
			$(".sNoti").prepend(Common.getDic("lbl_Division") + ":" + pConfig.CategoryName);//"분류"
			$(".sNoti").append(Common.getDic("lbl_ExpireDate") + ":" + pConfig.ExpiredDate);//"만료일"
		} else if(g_boardConfig.UseCategory == "Y" && g_boardConfig.UseExpiredDate == "N"){
			$(".sNoti").find(".line").hide();
			$(".sNoti").prepend(Common.getDic("lbl_Division") + ":" + pConfig.CategoryName);//"분류"
		} else if(g_boardConfig.UseCategory == "N" && g_boardConfig.UseExpiredDate == "Y"){
			$(".sNoti").find(".line").hide();
			$(".sNoti").append(Common.getDic("lbl_ExpireDate") + ":" + pConfig.ExpiredDate);//"만료일"
		} else {
			$(".sNoti").hide();
		}
		
		//첨부파일 팝업 및 다운로드 이벤트 바인드 부분
		$(".attFileListBox").html("");
		if(pConfig.fileList.length > 0){			
			var attFileAnchor = $('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');"/>').addClass('btnAttFile btnAttFileListBox').text('(' + pConfig.fileList.length + ')');
			var attFileListCont = $('<ul>').addClass('attFileListCont');
			var attFileDownloadAll = "<a href='javascript:void(0);' onclick='javascript:board.downloadAll(g_messageConfig.fileList, g_messageConfig.FolderID, g_messageConfig.MessageID, g_messageConfig.Version)'>"+Common.getDic("lbl_download_all")+"</a>";
			var attFileDownloadZip = "<a href='javascript:void(0);' class='zip' style='margin-left: 10%;' onclick='javascript:board.zipFiledownload(g_messageConfig.FolderID, g_messageConfig.MessageID, g_messageConfig.Version)'>"+Common.getDic("lbl_download_compressFiles")+"</a>";
			var attFileDownAll = $('<li>').append(Common.getBaseConfig('useDownloadCompressFiles') == "Y" ? attFileDownloadAll + attFileDownloadZip : attFileDownloadAll).append($('<a onclick="$(\'.attFileListCont\').toggleClass(\'active\');" >').addClass("btnXClose btnAttFileListBoxClose"));
			var attFileList = $('<li>');
			var videoHtml = '';

			$.each(pConfig.fileList, function(i, item){
				var iconClass = "";
				if(item.Extention == "ppt" || item.Extention == "pptx"){
					iconClass = "ppt";
				} else if (item.Extention == "excel" || item.Extention == "xlsx" || item.Extention == "xls"){
					iconClass = "fNameexcel";
				} else if (item.Extention == "pdf"){
					iconClass = "pdf";
				} else if (item.Extention == "doc" || item.Extention == "docx"){
					iconClass = "word";
				} else if (item.Extention == "zip" || item.Extention == "rar" || item.Extention == "7z"){
					iconClass = "zip";
				} else if (item.Extention == "jpg" || item.Extention == "gif" || item.Extention == "png"|| item.Extention == "bmp"){
					iconClass = "attImg";
				} else {
					iconClass = "default";
				}
				
				$(attFileList).append($('<p style="cursor:pointer;"/>').attr({"fileID": item.FileID, "fileToken": item.FileToken}).addClass('fName').append($('<span title="'+item.FileName+'">').addClass(iconClass).text(item.FileName)).append($('<span class="fileSize">').text("("+ coviFile.convertFileSize(item.Size) +")")).append($('<a href="#">').attr({"fileExtention": item.Extention}).addClass("btnFilePrev")));
				
				var VideoTypeCase = item.Extention.toLowerCase();
				
				// 내용에 비디오 추가 (HTML5 재생 지원하는 확장자만) 
				if (VideoTypeCase == 'mp4') {
					videoHtml += '<video width="900" height="500" style="margin-top:10px;" controls preload="none" poster="'+ coviCmn.loadImageIdThumb(item.FileID) +'">';
					//videoHtml += '<source src="' + coviCmn.loadImage(Common.getBaseConfig('BackStoragePath').replace("{0}", Common.getSession("DN_Code")) +  item.ServiceType +'/' + item.FilePath + item.SavedName) + '" type="video/mp4">';
					videoHtml += '<source src="' + coviCmn.loadImageId(item.FileID) + '" type="video/mp4">';
					videoHtml += '</video>';
				} else if (VideoTypeCase == 'ogg') {
					videoHtml += '<video width="900" height="500" style="margin-top:10px;" controls preload="none" poster="'+ coviCmn.loadImageIdThumb(item.FileID) +'">';
					//videoHtml += '<source src="' + coviCmn.loadImage(Common.getBaseConfig('BackStoragePath').replace("{0}", Common.getSession("DN_Code")) +  item.ServiceType +'/' + item.FilePath + item.SavedName) + '" type="video/ogg">';
					videoHtml += '<source src="' + coviCmn.loadImageId(item.FileID) + '" type="video/ogg">';
					videoHtml += '</video>';
				}  else if (VideoTypeCase == 'webm') {
					videoHtml += '<video width="900" height="500" style="margin-top:10px;" controls preload="none" poster="'+ coviCmn.loadImageIdThumb(item.FileID) +'">';
					//videoHtml += '<source src="' + coviCmn.loadImage(Common.getBaseConfig('BackStoragePath').replace("{0}", Common.getSession("DN_Code")) +  item.ServiceType +'/' + item.FilePath + item.SavedName) + '" type="video/webm">';
					videoHtml += '<source src="' + coviCmn.loadImageId(item.FileID) + '" type="video/webm">';
					videoHtml += '</video>';
				}
			});
			$('#BodyText').html($('#BodyText').html() + videoHtml);
			
			$(attFileListCont).append(attFileDownAll, attFileList);
			$('.attFileListBox').append(attFileAnchor ,attFileListCont);
			
			// 뷰 화면에서 파일 다운로드
			$('.attFileListBox .fName span').click(function(){
				var bExecuteAuth = board.checkExecuteAuth(bizSection, pConfig.FolderID, pConfig.MessageID, pConfig.Version)
				if(!bExecuteAuth) {
					Common.Warning(Common.getDic('msg_noFileDownloadACL'));	// 파일 다운로드 권한이 없습니다.
					return false;
				}
				
				Common.fileDownLoad($(this).parent().attr("fileID"), $(this).text(), $(this).parent().attr("fileToken"));
			}); 
			$('.attFileListBox .fName .btnFilePrev').click(function(){
				Common.filePreview($(this).parent().attr("fileID"), $(this).parent().attr("fileToken"), $(this).attr("fileExtention"));
			});			
			$('.attFileListBox').show();
		} else {
			$('.attFileListBox').hide();
		}
		
		if(pBizSection != "Doc"){			
			//권한에 상관없이 폴더 타입별 표시/숨김
			if(g_boardConfig.FolderType == "Contents" || g_boardConfig.FolderType == "QuickComment"){	
				//컨텐츠,한줄 댓글 게시는 폴더선택 - 상세보기, 작성화면 두가지 이므로 상세보기화면에서 페이지 정보 저장
				sessionStorage.setItem("urlHistory", $(location).attr('pathname') + $(location).attr('search'));
				g_urlHistory = $(location).attr('pathname') + $(location).attr('search');
				$("[name=btnList], .prvNextList").hide();
				
				if(g_boardConfig.FolderType == "QuickComment"){
					//CHECK: 한줄 게시의 경우 상단,하단 버튼 모두 숨김 처리 이후 top 5px로 고정 추후 변동사항을 고려하여 selector별로 숨김처리
					$('.cRContBottom').css('top','5px');
					$('.bvcTitle, .boardDisplayContent, .commentInfo').hide();
					$('.buttonStyleBoxLeft').hide();				//수정, 이동, 삭제 버튼 숨김
					$('.cRConTop, .boardTitle, .cRContEnd').hide();	//게시글 제목, 게시글 작성일, 조회수 정보 숨김
				}
			} else if ( g_boardConfig.FolderType == "TableHistory"){
				board.selectRevisionHistory(pConfig);	//개정 이력 조회
				if(viewType != "Popup"){
					board.selectPrevNextMessage(boardObj);	//이전글, 다음글 조회
				}
			} else if( g_boardConfig.FolderType == "OneToOne"){
				//TODO: 1:1게시판은 이전글 다음글 표시 여부를 옵션으로 처리 하도록 분기 별도 생성
				$(".prvNextList").hide();
			} else if( viewType == "Popup"){
				//TODO: 상세보기 팝업 내부 해당메뉴, 폴더, 본문으로 이동 기능 관련 표시용
				
			} else {
				board.selectPrevNextMessage(boardObj);	//이전글, 다음글 조회
			}
		} else {
			$(".prvNextList").hide();				//이전글,다음글 숨김
			
			//문서글 관련 기본 정보 표시
			board.selectDocumentInfo(pConfig);
			
			//개정정보 표시
			board.selectRevisionHistory(pConfig);
		}
	},
	
	//옵션별 context menu 표시 분기
	//게시판 표시 버튼: 신고, 답글, 스크랩, 인쇄, 조회자목록, 수정요청(미구현사항), 문서이관(미구현사항)
	//문서관리 표시 버튼: 조회자목록, 처리이력, 문서배포, 권한요청, 체크아웃, 체크아웃 취소, 체크인	
	setContextMenuConfig: function(pOptionName){
		var displayFlag = "N";
		
		if(bizSection != "Doc"){
			//displayFlag = new Function ("return g_boardConfig.Use" + pOptionName).apply();
			displayFlag = g_boardConfig["Use" + pOptionName];
			
			if(pOptionName == "Scrap"){ //게시판 설정이 스크랩 허용이어도 게시글 스크랩 여부가 Y여야함
				displayFlag = (g_messageConfig.UseScrap == "Y" ? "Y" : "N"); 
			}else if(pOptionName == "ReaderView" || pOptionName == "Reply"){
				//checkACL에서 작성권한 조회 후 표시 여부 결정
				displayFlag = "N";
			}
		}else{
			if(pOptionName == "ReaderView"){
				displayFlag = "N";  //checkACL에서 보안권한 조회 후 표시 여부 결정
			}else if(pOptionName == "HistoryView"){
				displayFlag = "Y";
			}else if(pOptionName == "RequestAuth"){
				if(g_messageConfig.OwnerCode != g_userCode){
					displayFlag = "Y";
				}
			}else if(pOptionName == "DeployDoc"){
				displayFlag = g_messageConfig.OwnerCode == g_userCode? "Y" : "N";
			}else if(pOptionName == "CheckOut"){	//체크아웃해도 권한없으면 수정 못함
				if(sessionObj["isAdmin"] == "Y"
					|| g_boardConfig.OwnerCode.indexOf(sessionObj["USERID"]+";") != -1
					|| (bizSection!="Doc" && g_messageConfig.CreatorCode == sessionObj["USERID"])
					|| (bizSection=="Doc" && g_messageConfig.OwnerCode == sessionObj["USERID"])) {

					displayFlag = g_messageConfig.IsCheckOut == "N" ? "Y" : "N";
				} else {
					displayFlag = "N";
				}
			}else if(pOptionName == "CheckIn"){
				if(sessionObj["isAdmin"] == "Y"
					|| g_boardConfig.OwnerCode.indexOf(sessionObj["USERID"]+";") != -1
					|| (bizSection!="Doc" && g_messageConfig.CreatorCode == sessionObj["USERID"])
					|| (bizSection=="Doc" && g_messageConfig.OwnerCode == sessionObj["USERID"])) {

					displayFlag = (g_messageConfig.IsCheckOut == "Y" && g_messageConfig.CheckOuterCode == g_userCode) ? "Y" : "N";
				} else {
					displayFlag = "N";
				}
			}else if(pOptionName == "Cancel"){
				if(g_messageConfig.IsCheckOut == "Y" && 
						(sessionObj["isAdmin"] == "Y" || g_boardConfig.OwnerCode == g_userCode  || g_messageConfig.CheckOuterCode == g_userCode )){
					displayFlag = "Y"
				}
			}
		}
		
		if(displayFlag == "Y"){
			$("#ctx"+pOptionName).parent().show();
		}
	},
	
	//작성 페이지에서 게시글 옵션 설정
	renderMessageOptionWrite: function(pBizSection, pVersion, pMessageID, pFolderID){
		//부서명 게시
		if($("#chkUsePubDeptName").prop("checked")){
			$("#CreatorName").val($("#GroupName").val());
		}
		
		//상단공지 사용하거나 공지 게시판일 경우 공지 입력 버튼 활성화
		/*
		if((g_boardConfig.UseTopNotice == "Y" || g_boardConfig.FolderType == "Notice")){
			$('.btnNoti').parent().addClass('active');
		}
		*/
		
		//tag정보 조회
		if(g_boardConfig.UseTag == "Y"){
			board.getTagData(pMessageID, pVersion)
		}
		
		//link정보 조회
		if(g_boardConfig.UseLink == "Y"){
			board.getLinkData(pMessageID);
		}
		
		//게시판 환경설정에서 사용가능하도록 설정, 게시글에서도 열람권한 설정이 되어있을 경우 조회
		if(g_boardConfig.UseMessageReadAuth == "Y" && $("#UseMessageReadAuth").val() == "Y"){
			//열람권한 설정이 Y면 상세권한 설정이 되지 않은 상태 
			board.getMessageReadAuth(pBizSection, pMessageID, pFolderID);	//열람권한 조회
		} else {
			$("#UseMessageReadAuth").val("");
			$("#messageReadAuth").val("");
		}
		
		board.getMessageAuth(pBizSection, pVersion, pMessageID, pFolderID);		//버전별 상세권한 조회
		
		if(g_boardConfig.UseMessageAuth == "Y"){
			//열람권한 설정: N, 해당 폴더의 상세권한 설정이 Y, 상세권한 설정 후 저장할 경우 isinherited가 N 
			//상세권한 조회
			$("#UseMessageAuth").val(g_boardConfig.UseMessageAuth);	//사용여부 설정
		} else {
			$("#UseMessageAuth").val("");
			$("#messageAuth").val("");
		}
		
		if(g_boardConfig.UseUserForm == "Y" || $("#IsUserForm").val() == "Y"){
			//게시판 설정 및 게시글의 사용자 정의 폼 사용시 설정값 조회
			board.getUserDefFieldValue("Write", pVersion, pMessageID);
		}
		
		//경조사 게시판 수정시 기존 설정된 사원명 표시 처리
		if(Common.getBaseConfig("eventBoardID") == pFolderID && g_messageConfig.EventOwnerCode != ""){
			var divEventOwner = $('<div class="ui-autocomplete-multiselect-item"/>');
			var eventOwnerCode = g_messageConfig.EventOwnerCode;
			var eventOwnerName = g_messageConfig.EventOwnerName;
			divEventOwner.attr({'data-json':'{"UserCode":"'+eventOwnerCode+'","UserName":"'+eventOwnerName+'","label":"'+eventOwnerName+'","value":"'+eventOwnerCode+'"}', 'data-value':eventOwnerCode});
			divEventOwner.text(eventOwnerName);
			divEventOwner.append(
				$("<span></span>")
                .addClass("ui-icon ui-icon-close")
                .click(function(){
                    var item = $(this).parent();
                    item.remove();
                })
			);
			$("#EventOwner").parent().prepend(divEventOwner);
			$("#EventType option[value='" + g_messageConfig.EventType + "']").prop("selected", true);
			$("#EventDate").val(g_messageConfig.EventDate);
		}
		
		//연결 게시글, 바인더 검색
		if(g_boardConfig.UseLinkedMessage == "Y" || pBizSection == "Doc"){
			board.getLinkedMessage("Write", pBizSection, pMessageID, pVersion);
		}
	},
	
	//상세보기 게시글 옵션 항목 표시/숨김
	renderMessageOptionView: function(pBizSection, pVersion, pMessageID, pFolderID){
		
		//tag, link 영역 초기화
		$(".tagView").empty();
		
		//tag정보 조회
		if(g_boardConfig.UseTag == "Y"){
			board.renderTag(pMessageID, pVersion);
		}
		
		//link정보 조회
		if(g_boardConfig.UseLink == "Y"){
			board.renderLink(pMessageID);
		}
		
		//태그/링크가 없을 시 빈공간 제거
		if($(".tagView").html() == '' || $(".tagView").length == 0){
			$(".tagView").remove();
		}else{
			$(".authView").attr("style","padding-bottom:0px");
		}
			
		//경조사 게시판 상세보기 화면 표시 처리
		if(Common.getBaseConfig("eventBoardID") == pFolderID){
			//개별호출
			Common.getDicList(["lbl_empNm","lbl_kind","lbl_Schedule"]);
			
			var divEventOwner = $('<div />');
			divEventOwner.append( $('<div class="tit"><span class="star">' + coviDic.dicMap["lbl_empNm"] + '<span/></div>'));
			divEventOwner.append( $('<div class="txt h_Line"><span id="EventOwnerName">' + g_messageConfig.EventOwnerName + '</span></div>'));
			
			var divDateAndType = $('<div />');
			var eventDate = $('<div class="disTblStyle"><span id="eventDate">' + g_messageConfig.EventDate +'</span></div>');
			var eventType = $('<div class="tit"> <span>' +  coviDic.dicMap["lbl_kind"] + '</span></div><div class="txt h_Half"> <span id="eventType">' + Common.getDic("lbl_" + g_messageConfig.EventType) + '</span></div></div>');
			divDateAndType.append($('<div class="tit"><span>' + coviDic.dicMap["lbl_Schedule"] + '</span></div>'));
			divDateAndType.append($('<div class="txt h_Half">').append(eventDate).append($('<div class="disTblStyle"/>').append(eventType)));
			
			$("#divEventBoard").append(divEventOwner);
			$("#divEventBoard").append(divDateAndType);
			$("#divEventBoard").show();
		} else {
			$("#divEventBoard").hide();
		}
		
		//카테고리 사용여부
		if(g_boardConfig.UseCategory == "Y"){
			$.ajax({
				type: "POST",
				url: "/groupware/board/selectCategoryList.do",
				data: { folderID: pFolderID },
				async: false,
				success: function(data){
		 			if (data.list){
						$.each(data.list, function(idx, el){
							$("#selectCategoryID").append(
								'<option value="'+el.optionValue+'" data-memberof="'+el.MemberOfName+'">'+el.optionText+'</option>'
							)
						});
					}
		 		},
		 		error:function(response, status, error){
		 		     CFN_ErrorAjax("/groupware/board/selectCategoryList.do", response, status, error);
		 		}
			});
		} 
		$("#selectCategoryID").hide();
		
		if((g_boardConfig.UseUserForm == "Y" && g_messageConfig.IsUserForm == "Y")
				|| Common.getBaseConfig("use" + bizSection + "MultiCategory") == "Y"){
			//게시판 설정 및 게시글의 사용자 정의 폼 사용시 설정값 조회
			$("#divUserDefField").html("");
			$("#divUserDefField").show();
			board.getUserDefField("View", pFolderID);
			board.getUserDefFieldValue("View", pVersion, pMessageID);
		} else {
			$("#divUserDefField").hide();
		}
		
		if(g_boardConfig.UseProgressState == "Y"){
			$("#divUserDefField").show();
			board.getProcessState(pFolderID);
		}
		
		if(g_boardConfig.UseLinkedMessage == "Y" || pBizSection == "Doc"){
			$("#divLinkedMessage").show();
			board.getLinkedMessage("View", pBizSection, pMessageID, pVersion);
		} else {
			$("#divLinkedMessage").hide();
		}

		// 피드 연결 게시
		if((Common.getBaseConfig("isUseTransferFeed") == "Y" && g_boardConfig.UseTransferFeed == "Y") || Common.getBaseConfig("isUseTransferFeed") == "A") {
			board.getLinkedFeedMessage(pBizSection, pMessageID, pVersion);
		} else {
			$("#divLinkedFeed").hide();
		}
		
		if(g_boardConfig.FolderType == "LinkSite" && pBizSection != "Doc"){
			var returnStr = String.format("<a href='{0}' target='_new' title='{0}'>{0}</a>", g_messageConfig.LinkURL);
			var divLinkSite = $('<div />');
			divLinkSite.append( $('<div class="tit"><span>' + Common.getDic("lbl_URL") + '<span/></div>'));
			divLinkSite.append( $('<div class="txt h_Line"><span>' + returnStr + '</span></div>'));

			$("#divLinkSiteBoard").append(divLinkSite);
			$("#divLinkSiteBoard").show();
		} else {
			$("#divLinkSiteBoard").hide();
		}		
	},
	
	//이전글, 다음글 조회
	selectPrevNextMessage: function(pBoardObj){
		pBoardObj.useTopNotice = g_boardConfig.UseTopNotice;
		if (CFN_GetQueryString("prevMessageID") != 'undefined') pBoardObj.prevMessageID = CFN_GetQueryString("prevMessageID");
		if (CFN_GetQueryString("prevMessageVer") != 'undefined') pBoardObj.prevMessageVer = CFN_GetQueryString("prevMessageVer");
		if (CFN_GetQueryString("nextMessageID") != 'undefined') pBoardObj.nextMessageID = CFN_GetQueryString("nextMessageID");
		if (CFN_GetQueryString("nextMessageVer") != 'undefined') pBoardObj.nextMessageVer = CFN_GetQueryString("nextMessageVer");
		if (bizSection == 'Board' && !pBoardObj.menuCode) pBoardObj.menuCode = CFN_GetQueryString("menuCode");
		
		//Sort정보 없을 경우 이전글, 다음글 조회 하지 않음
		if(bizSection != "Doc"){
			$.ajax({
		 		type:"POST",
		 		data: pBoardObj,
		 		url:"/groupware/board/selectPrevNextMessage.do",
		 		async: false,
		 		success:function(data){
		 			if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
		 				var anchorView = "<a href='#' onclick='javascript:board.goView(\"{1}\", {2}, {3}, {4}, {5}, \"{6}\", \"{7}\", \"{8}\", \"{9}\", \"{10}\", \"{11}\", \"{12}\", {13}, {14}, \"\", \"{15}\", \"{16}\", \"{17}\", \"{18}\", \"{19}\");' >{0}</a>";
		    			if(!$.isEmptyObject(data.prev)){
		    				var prev = String.format(anchorView, 
		    					data.prev.Subject,
	     						bizSection,
	     						data.prev.MenuID,
	     						data.prev.Version,
	     						data.prev.FolderID,
	     						data.prev.MessageID,
	     						startDate, endDate, sortBy, encodeURIComponent(searchText), searchType, viewType, boardType, page, pageSize, data.prev.RNUM,
	     						(data.prev.MultiFolderType ? data.prev.MultiFolderType : ""), grCode, ufColumn, categoryID
	     					);
		    				$("#prevMessage").html(prev);
		    			} else {
	    					$("#prevMessage").html("<span>"+ Common.getDic("lbl_noPrevMsg") +"</span>");	//이전 글이 없습니다.
		    			}
		    			if(!$.isEmptyObject(data.next)){
		    				var next = String.format(anchorView, 
		    					data.next.Subject,
	     						bizSection,
	     						data.next.MenuID,
	     						data.next.Version,
	     						data.next.FolderID,
	     						data.next.MessageID,
	     						startDate, endDate, sortBy, encodeURIComponent(searchText), searchType, viewType, boardType, page, pageSize, data.next.RNUM,
	     						(data.next.MultiFolderType ? data.next.MultiFolderType : ""), grCode, ufColumn, categoryID
	     					);
		    				$("#nextMessage").html(next);
		    			} else {
		    				$("#nextMessage").html("<span>"+ Common.getDic("lbl_noNextMsg") +"</span>");	//다음 글이 없습니다.
		    			}
		    		}
		 		},
		 		error:function(response, status, error){
		 		     CFN_ErrorAjax("/groupware/board/selectPrevNextMessage.do", response, status, error);
		 		}
		 	});
		}
		
	},
	
	getFolderPath: function( pFolderPath ){
		var pathList = null;
		$.ajax({
	 		type:"POST",
	 		data: {
	 			"folderPath": pFolderPath
	 		},
	 		url:"/groupware/board/selectFolderPath.do",
	 		async: false,
	 		success:function(data){
	 			pathList = data.list;
	 		},
	 		error:function(response, status, error){
	 		     CFN_ErrorAjax("/groupware/board/selectFolderPath.do", response, status, error);
	 		}
	 	});
		return pathList;
	},
	
	renderFolderPath: function(){
		var pathList = board.getFolderPath(g_boardConfig.FolderPath);
		var outerHTML = "";
		if(typeof pathList != 'undefined' && pathList.length > 0){
			$.each(pathList, function(i, item){
				outerHTML += String.format("<em>{0}</em>", item.DisplayName);
				outerHTML += String.format("<span>&gt;</span>", item.DisplayName);
			});
			outerHTML += String.format("<strong>{0}</strong>", g_boardConfig.DisplayName);
		}
		return outerHTML;
	},
	
	setEditor: function(){
		coviEditor.loadEditor(
			'divWebEditor',
			{
				editorType : g_editorKind,
				containerID : 'tbContentElement',
				frameHeight : '510',
				focusObjID : '',
				onLoad:  function(){
		        	coviEditor.setBody(g_editorKind, 'tbContentElement', g_editorBody);
		        }
			}
		);
	},
	
	//본문양식 정보 조회
	//pBodyFormID - 본문양식ID
	//editorBind - 에디터 바인딩 여부 (에디터 바인딩  후에 바인딩되어야하므로 초기양식은 바로 바인딩되면 X) 
	selectBodyFormData: function( pBodyFormID , editorBind){
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
	 					coviEditor.setBody(g_editorKind, 'tbContentElement', g_editorBody);
	 				}
	 				
	 			} else {
	 				Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	 			}
	 		},
	 		error:function(response, status, error){
	 		     CFN_ErrorAjax("/groupware/board/selectBodyFormData.do", response, status, error);
	 		}
	 	});
	},
	
	selectDocumentInfo: function( pConfig ){	//g_messageConfig
		$("#docInfo").remove("");		//문서정보 초기화
		//개별호출-일괄호출
		Common.getDicList(["lbl_RevisionWriter","lbl_Owner","lbl_RevisionDate","lbl_CheckOut","lbl_CheckIn","lbl_RevisionState","lbl_apv_DocboxFolder","lbl_MultiClass"]);
		
		var documentInfo = $('<div id="docInfo" class="boradDisplay type02" />');
		
		if(pConfig.MultiFolderIDs){
			board.getBoardConfig(pConfig.FolderID);
			var multiFolderName = board.getMultiFolderName(pConfig.MultiFolderIDs);
			var folderInfo = $('<div/>').append( $('<div class="tit"/>').text(coviDic.dicMap["lbl_apv_DocboxFolder"]), $('<div class="txt"/>').text(g_boardConfig.DisplayName) );	//문서분류
			var multiFolderInfo = $('<div/>').append( $('<div class="tit"/>').text(coviDic.dicMap["lbl_MultiClass"]), $('<div class="txt"/>').text(multiFolderName) );				//다중분류
			
			$(documentInfo).append(folderInfo, multiFolderInfo);
		}

		var reviserInfo = $('<div/>').append( $('<div class="tit"/>').text(coviDic.dicMap["lbl_RevisionWriter"]), $('<div class="txt"/>').text(pConfig.RevisionName) );	//개정자
		var ownerInfo = $('<div/>').append( $('<div class="tit"/>').text(coviDic.dicMap["lbl_Owner"]), $('<div class="txt"/>').text(pConfig.OwnerName) );				//소유자
		var revisionDate = $('<div/>').append( $('<div class="tit"/>').text(coviDic.dicMap["lbl_RevisionDate"]), $('<div class="txt"/>').text(CFN_TransLocalTime(pConfig.RevisionDate) + " " + Common.getSession("UR_TimeZoneDisplay")) );	//개정일
		
		var icoClass = pConfig.IsCheckOut=="Y"?"icoCheckOut":"icoCheckIn";
		var statusTxt = pConfig.IsCheckOut=="Y"?coviDic.dicMap["lbl_CheckOut"]:coviDic.dicMap["lbl_CheckIn"];
		var checkOutStatus = $('<div/>').append( $('<div class="tit"/>').text(coviDic.dicMap["lbl_RevisionState"]), $('<div class="txt"/>').append($('<span class="icoState ' + icoClass + '" />').text(statusTxt)) );
		
		$(documentInfo).append(reviserInfo, ownerInfo, revisionDate, checkOutStatus);
		
		$(".bvcTitle").after(documentInfo);
	},
	
	selectRevisionHistory: function( pConfig ){
		$.ajax({
	 		type:"POST",
	 		data: {
	 			"messageID": pConfig.MessageID
	 		},
	 		url:"/groupware/board/selectRevisionHistory.do",
	 		success:function(data){
	 			if(data.status=='SUCCESS'){
	 				$("#historyInfo").remove("");	//이력 정보 초기화
	 				var wrapDiv = $('<div/>').append($('<div class="tit" />').text(Common.getDic("lbl_RevisionInfo")));
	 				var wrapVersionOL = $('<ol class="verInfo"/>');
	 				$.each(data.list, function(i,item){
	 					var li = $('<li>');
	 					// 선택한 버전 색상
	 					if(data.list.length - i == pConfig.Version) {
	 						$(li).addClass('latest');
	 					}
	 					
	 					//var li = $('<li class="' + (item.IsCurrent == "Y"?'latest':'') + '">');	//최상위 li 태그
	 					// item.RevisionDate == "" ? item.RevisionDate : item.RevisionDate + " " + Common.getSession("UR_TimeZoneDisplay")
	 					var divRevisionInfo = $('<div class="revisionInfo"/>').append($('<span class="name"/>').text(item.RevisionName), $('<span class="date"/>').text(item.RevisionDate), $('<span class="time"/>').text(item.RevisionTime + (item.RevisionDate == "" ? "" : " " + Common.getSession("UR_TimeZoneDisplay"))));
	 					var anchorSubject = $('<a onclick="javascript:board.selectVersionMessageDetail(\'View\',\''+bizSection+'\','+ item.Version +',' + item.MessageID +','+ folderID+');"/>').append(item.Subject,divRevisionInfo);
	 					var dlWrap = $('<dl/>').append($('<dt/>').text("Ver."+item.Version), $('<dd/>').append(anchorSubject));
	 					$(wrapVersionOL).append($(li).append(dlWrap));
	 				});
	 				
	 				$(wrapDiv).append($('<div class="txt"/>').append(wrapVersionOL));
	 				var historyInfo = $('<div id="historyInfo" class="boradDisplay type02" />').append(wrapDiv);
	 				//$('#docInfo').after($('<div />').append(historyInfo));	//문서 정보 뒤에 추가
	 				$('.boradDisplay.type02:last').after($('<div />').append(historyInfo));
	 			} else {
	 				Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
	 			}
	 		},
	 		error:function(response, status, error){
	 		     CFN_ErrorAjax("/groupware/board/selectCheckInOutHistory.do", response, status, error);
	 		}
	 	});
	},
	
	renderFileList: function(pObj, pFolderID, pMessageID, pVersion){
		if(!board.checkReadAuth(bizSection, pFolderID, pMessageID, pVersion)){
			Common.Warning(Common.getDic("msg_noViewACL"));	//읽기 권한이 없습니다.
			return;
		}
		
		// 파일목록 표시, 숨김처리
		var displayCont = $(pObj).siblings('.topOptionListCont');
		if(displayCont.hasClass('active')){
			displayCont.removeClass('active');
			$(pObj).removeClass('active');
		}else {			
			$('.topOptionListCont').removeClass('active');
			$(pObj).addClass('active');
			displayCont.addClass('active');
		}
		
		// 선택 시 조회
		if($(pObj).next().children().length < 2){
			$.ajax({
				type:"POST",
				url:"/groupware/board/selectFileList.do",
				data:{
					"bizSection": bizSection,
					"folderID": pFolderID,
		       		"messageID": pMessageID,
		       		"version": pVersion
		       	},
		       	success:function(data){
		       		if(data.status='SUCCESS'){
		       			var attFileList = $('<li>');
		       			$(data.fileList).each(function(i, item){
		       				var iconClass = "";
		    				if(item.Extention == "ppt" || item.Extention == "pptx"){
		    					iconClass = "ppt";
		    				} else if (item.Extention == "excel" || item.Extention == "xlsx" || item.Extention == "xls"){
		    					iconClass = "fNameexcel";
		    				} else if (item.Extention == "pdf"){
		    					iconClass = "pdf";
		    				} else if (item.Extention == "doc" || item.Extention == "docx"){
		    					iconClass = "word";
		    				} else if (item.Extention == "zip" || item.Extention == "rar" || item.Extention == "7z"){
		    					iconClass = "zip";
		    				} else if (item.Extention == "jpg" || item.Extention == "gif" || item.Extention == "png"|| item.Extention == "bmp"){
		    					iconClass = "attImg";
		    				} else {
		    					iconClass = "default";
		    				}
		    				
		    				$(attFileList).append($('<p style="cursor:pointer;"/>').attr({"fileID": item.FileID, "fileToken": item.FileToken}).addClass('fName').append($('<span title="'+item.FileName+'">').addClass(iconClass).text(item.FileName)).append($('<span class="fileSize">').text("("+ coviFile.convertFileSize(item.Size) +")")).append($('<a href="#">').attr({"fileExtention": item.Extention}).addClass("btnFilePrev")));
			       		});
		       			
		       			$(pObj).next().append(attFileList);
		       			
		       			// 리스트에서 파일 다운로드
		       			$(pObj).next().find('.fName span').click(function(){
		       				var bExecuteAuth = board.checkExecuteAuth(bizSection, pFolderID, pMessageID, pVersion)		       				
		       				if(!bExecuteAuth) {
		       					Common.Warning(Common.getDic('msg_noFileDownloadACL'));	// 파일 다운로드 권한이 없습니다.
		    					return false;
		       				}
		       				
		    				Common.fileDownLoad($(this).parent().attr("fileID"), $(this).text(), $(this).parent().attr("fileToken"));
		    				
		    				// 파일 다운로드 시도 시 조회자 추가
		    				board.createFileDownloadToMessageReader(bizSection, pFolderID, pMessageID, pVersion);
		    			});
		       			
		       			$(pObj).next().find('.fName .btnFilePrev').click(function(){
		       				Common.filePreview($(this).parent().attr("fileID"), $(this).parent().attr("fileToken"), $(this).attr("fileExtention"));
		       				
		       				// 파일 미리보기 시도 시 조회자 추가
		       				board.createFileDownloadToMessageReader(bizSection, pFolderID, pMessageID, pVersion);
		    			});       			
		       		}
		       	},
		       	error:function(response, status, error){
				     CFN_ErrorAjax("/groupware/board/selectFileList.do", response, status, error);
	       		}
			});
		}
	},
	
	// Grid 내부 파일 전체 다운로드 (리스트에서 전체 파일 다운로드)
	gridDownloadAll: function(pFolderID, pMessageID, pVersion){
		var bExecuteAuth = board.checkExecuteAuth(bizSection, pFolderID, pMessageID, pVersion)
		if(!bExecuteAuth) {
			Common.Warning(Common.getDic('msg_noFileDownloadACL'));	// 파일 다운로드 권한이 없습니다.
			return false;
		} else {
			$.ajax({
				type:"POST",
				url:"/groupware/board/selectFileList.do",
				data:{
					"bizSection": bizSection,
					"folderID": pFolderID,
		       		"messageID": pMessageID,
		       		"version": pVersion
		       	},
		       	success:function(data){
		       		if(data.status == "SUCCESS"){
		       			var pFileList = data.fileList;
		       			var fileList = pFileList.slice(0);
		       			Common.downloadAll(fileList);
		       			
		       			// 파일 다운로드 시도 시 조회자 추가
		       			board.createFileDownloadToMessageReader(bizSection, pFolderID, pMessageID, pVersion);
		       		}
		       	},
		       	error:function(response, status, error){
				     CFN_ErrorAjax("/groupware/board/selectFileList.do", response, status, error);
	       		}
			});
		}
	},
	
	//object내부 데이터를 하나씩 재귀호출로 삭제하면서 시도
	downloadAll: function( pFileList, pFolderID, pMessageID, pVersion ){
		var bExecuteAuth = board.checkExecuteAuth(bizSection, pFolderID, pMessageID, pVersion)
		if(!bExecuteAuth) {
			Common.Warning(Common.getDic('msg_noFileDownloadACL'));	// 파일 다운로드 권한이 없습니다.
			return false;
		}
		
		var fileList = pFileList.slice(0);	//array 객체 복사용
		Common.downloadAll(fileList);
	},
	
	zipFiledownload: function( pFolderID, pMessageID, pVersion ){
		var bExecuteAuth = board.checkExecuteAuth(bizSection, pFolderID, pMessageID, pVersion)
		if(!bExecuteAuth) {
			Common.Warning(Common.getDic('msg_noFileDownloadACL'));	// 파일 다운로드 권한이 없습니다.
			return false;
		}
		
		Common.zipFiledownload(bizSection, pFolderID, pMessageID, pVersion);
		
		// 파일 다운로드 시도 시 조회자 추가
		board.createFileDownloadToMessageReader(bizSection, pFolderID, pMessageID, pVersion);
	},
	
	goViewPopup: function(pBizSection, pMenuID, pVersion, pFolderID, pMessageID, pPopUpOption, pMultiFolderType){	//상세보기
		var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup&startDate=&endDate=&searchType=&searchText=&sortBy=", pBizSection, pMenuID, pVersion, pFolderID, pMessageID);
		
		// 다차원 분류
		if(pMultiFolderType){
			url += "&multiFolderType=" + pMultiFolderType;
		}
		
		if(CFN_GetQueryString("C") != "undefined"){	//Community용 Parameter추가
			url += "&communityId="+CFN_GetQueryString("C") + "&CSMU=C";
		} else if (CFN_GetQueryString("communityId") != "undefined"){
			url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
		}
		
		// 메뉴코드
		if(typeof menuCode != "undefined") {
			url += "&menuCode=" + menuCode;
		}
		
		//window popup 지원
		if(pPopUpOption == "W"){
			CFN_OpenWindow(url, encodeURIComponent(Common.getDic("lbl_DetailView")), 1080, 780,"resize");
		}else{
			parent.Common.open("", "boardViewPop_"+pMessageID, Common.getDic("lbl_DetailView"), url, "1080px", "600px", "iframe", true, null, null, true);
		}
		
		/*if(board.checkReadAuth(pBizSection, pFolderID, pMessageID, pVersion)){	//읽기 권한 체크
			var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&version={1}&folderID={2}&messageID={3}&viewType=Popup&startDate=&endDate=&searchType=&searchText=&sortBy=", pBizSection, pVersion, pFolderID, pMessageID);
			//window popup 지원
			if(pPopUpOption == "W"){
				CFN_OpenWindow(url, Common.getDic("lbl_DetailView"),1080, 780,"resize");
			}else{
				parent.Common.open("", "boardViewPop", Common.getDic("lbl_DetailView"), url, "1080px", "600px", "iframe", true, null, null, true);
			}
		} else {
			Common.Warning(Common.getDic("msg_UNotReadAuth"));
		}*/
	},
	
	goFeedViewPopup: function(pFeedType, pMessageID, pVersion, pPopUpOption) {	// 피드 상세보기
		var url = String.format("/feed/user/goFeedViewPopup.do?CLBIZ=Feed&feedType={0}&messageID={1}&version={2}", pFeedType, pMessageID, pVersion);
		
		if(self.opener) {
			CFN_OpenWindow(url, "feedViewPopup", (parent.window.innerWidth), (parent.window.innerHeight), "resize");
		} else {
			if(pPopUpOption == "W"){
				CFN_OpenWindow(url, "feedViewPopup", (parent.window.innerWidth - 500), (parent.window.innerHeight - 100), "resize");
			}else{
				parent.Common.open("", "feedViewPopup", Common.getDic("lbl_DetailView"), url, (parent.window.innerWidth - 500), (parent.window.innerHeight - 100), "iframe", true, null, null, true);
			}
		}
	},
	
	simpleGoWrite: function(pFolderID, pMenuID, pMessageID){
		if(pFolderID != undefined && pFolderID != "" && pMenuID != undefined && pMenuID != ""){
			var menuURL = '';
			if (typeof headerdata == 'object'){
				$.each(headerdata, function(idx, el){
					if (el.MenuID == pMenuID) {
						menuURL = el.URL;
						return false;	
					}
				});
			}
			var tempURL = '';
			var menuCode = '';
			try{
				tempURL = new URL(location.origin + menuURL);
				menuCode = tempURL.searchParams.get("menuCode");
			} catch(e) {
				coviCmn.traceLog(e);
			}
			
			var	url = '/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=update&menuID='+pMenuID+'&folderID='+pFolderID+'&messageID='+pMessageID+'&version=1&writeMode=simpleMake';
			if (menuCode && menuCode != '') url += '&menuCode=' +menuCode;
			location.href = url;
		} else {
			Common.Warning(Common.getDic("msg_SelectBoard"));	//게시판을 선택해주세요.
		}
	},
	
	createSimpleMessage:function(pFolderID, pMenuID, pMode){
		//게시 작성
		if(pFolderID != undefined && pFolderID != "" && pMenuID != undefined && pMenuID != ""){
			if($("#boardBodyText").val() == ""){
				Common.Warning(Common.getDic("msg_EnterContents"));	//내용을 입력하세요
				return;
			} else if($("#boardSubject").val() == ""){
				Common.Warning(Common.getDic("msg_EnterSubject"));	//제목을 입력하세요
				return;
			}
			
/*			var text = $("#boardBodyText").val().split(' ').join('&nbsp;'); //replaceAll() 함수 효과
			text = text.replace(/(\r\n|\n|\n\n)/gi, '<br />');*/
			var bodyText;
			var bodyInlineImage = $("#hiddenEditorInlineImage").val();
			var body = $("#boardBodyText").val();
			var frontStorageURL = escape(Common.getGlobalProperties("smart4j.path")+ Common.getBaseConfig("FrontStorage"));
			var msgState = "C";
			body = body.split(' ').join('&nbsp;');				//공백 
			body = body.replace(/(\r\n|\n|\n\n)/gi, '<br />');	//줄바꿈
			if ($('#boardBodyText').is(':disabled')) bodyText = $("#hiddenEditorBody").val(); else bodyText = body;
			
			board.getBoardConfig(pFolderID);
			
			if(pMode == "writeDetail"){
				msgState = "T";
			}else{
				if(g_boardConfig.UseCategory == "Y"){
					Common.Confirm(Common.getDic("msg_selectDetailCategory"), "Informaition", function(result){ // 분류를 지정해야 합니다.<br>[OK] 버튼 클릭 시 상세 등록 페이지로 이동합니다.
						if(result){
							if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
							
							var simpleMenuID = $('#boardFolderID').val().split("_")[0];
							var simpleFolderID = $('#boardFolderID').val().split("_")[1];
							sessionStorage.setItem("urlHistory", location.href);
							board.createSimpleMessage(simpleFolderID, simpleMenuID, "writeDetail");
						}
						return false;
					});
					
					return false;
				}
				
				var ufCheckVal = false;
				
				$.ajax({
					type: "POST",
					url: "/groupware/board/selectUserDefFieldList.do",
					data: {
						"folderID": pFolderID,
					},
					async: false,
					success: function(data){
						var fieldList = data.list;
						
						$.each(fieldList, function(i, item){
							if(g_boardConfig.UseUserForm == "Y" && item.IsCheckVal == "Y"){
								ufCheckVal = true;
								return false;
							}
						});
					},
					error: function(response, status, error){
						CFN_ErrorAjax("/groupware/board/selectUserDefFieldList.do", response, status, error);
					}
				});
				
				if(ufCheckVal){
					Common.Confirm(Common.getDic("msg_selectDetailUserField"), "Informaition", function(result){ // 사용자 지정 필드의 값을 지정해야 합니다.<br>[OK] 버튼 클릭 시 상세 등록 페이지로 이동합니다.
						if(result){
							if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
							
							var simpleMenuID = $('#boardFolderID').val().split("_")[0];
							var simpleFolderID = $('#boardFolderID').val().split("_")[1];
							sessionStorage.setItem("urlHistory", location.href);
							board.createSimpleMessage(simpleFolderID, simpleMenuID, "writeDetail");
						}
						return false;
					});
					
					return false;
				}
			}
			
			var targetBtnSelector = '';
			var targetBtnEvent = '';
			
			if(msgState == 'C' || msgState == 'T'){
				targetBtnSelector = "#btnBoardWrite";
			}
			targetBtnEvent = $._data($(targetBtnSelector)[0], "events").click[0].handler;
			
			//Multipart 업로드를 위한 formdata객체 사용 
			$.ajax({
		    	type:"POST",
		    	url: "/groupware/board/createSimpleMessage.do",
		    	data: {
					"mode"		: "create"
					,"bizSection"	: "Board"
					,"ownerCode"	: g_userCode
					,"msgState"	: msgState
					,"msgType"	: "O"
					,"step"		: 0
					,"depth"	: 0
					,"folderID"	: pFolderID
					,"menuID"	: pMenuID
					,"subject"	: $("#boardSubject").val()
					,"bodyText"	: body
					,"body"		: bodyText
					,"bodyInlineImage"		: bodyInlineImage
					,"frontStorageURL"		: frontStorageURL
					,"folderType"			: g_boardConfig.FolderType
				},
		    	dataType : 'json',
				beforeSend: function() {
					$(targetBtnSelector).off('click');
				},
		    	success:function(data){
		    		if(data.status=='SUCCESS'){
		    			if(pMode == "writeDetail"){
		    				board.simpleGoWrite(pFolderID, pMenuID, data.messageID);
		    			}else{
							$(targetBtnSelector).on('click', targetBtnEvent);
		    				Common.Confirm(Common.getDic('CPMail_mail_msgSaveBoard'), 'Confirmation Dialog', function (result) {
			    	            if (result) {
			    					//게시판 목록 조회 팝업
			    	            	var prefixURL = '/groupware/layout/board_BoardView.do?CLBIZ=Board&CLSYS=board&CLMD=user&sortBy=&startDate=&endDate=&searchText=&searchType=Subject';
			    	            	var viewURL = String.format('{0}&menuID={1}&folderID={2}&messageID={3}&version={4}&boardType=Normal', prefixURL, pMenuID, pFolderID, data.messageID, 1);
			    	            	location.href = viewURL;
			    	            } else {
			    	            	$("#boardSimpleMake #boardSubject").val("");
			    					$("#boardSimpleMake #boardFolderID").val("");
			    					$("#boardSimpleMake #boardBodyText").val("");
			    	            }
			    	        });
		    			}
		    		}else{
						$(targetBtnSelector).on('click', targetBtnEvent);
		    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
		    		}
		    	}, 
		  		error:function(error){
					$(targetBtnSelector).on('click', targetBtnEvent);
		  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
		  		}
		    });
		} else {
			$(targetBtnSelector).on('click', targetBtnEvent);
			Common.Warning(Common.getDic("msg_SelectBoard"));	//게시판을 선택해주세요.
		}
	},
	createSimpleRegError:function(pFolderID, pMenuID){
		//게시 작성
		if(pFolderID != undefined && pFolderID != "" && pMenuID != undefined && pMenuID != ""){
			if($("#regErrorBodyText").val() == ""){
				Common.Warning(Common.getDic("msg_EnterContents"));	//내용을 입력하세요
				return;
			} else if($("#regErrorSubject").val() == ""){
				Common.Warning(Common.getDic("msg_EnterSubject"));	//제목을 입력하세요
				return;
			}
			
/*			var text = $("#boardBodyText").val().split(' ').join('&nbsp;'); //replaceAll() 함수 효과
			text = text.replace(/(\r\n|\n|\n\n)/gi, '<br />');*/
			var bodyText;
			var body = $("#regErrorBodyText").val();
			body = body.split(' ').join('&nbsp;');				//공백 
			body = body.replace(/(\r\n|\n|\n\n)/gi, '<br />');	//줄바꿈
			if ($('#regErrorBodyText').is(':disabled')) bodyText = $("#hiddenRegErrorEditorBody").val(); else bodyText = body;
			
			//Multipart 업로드를 위한 formdata객체 사용 
			$.ajax({
		    	type:"POST",
		    	url: "/groupware/board/createSimpleMessage.do",
		    	data: {
					"mode"		: "create"
					,"bizSection"	: "Board"
					,"ownerCode"	: g_userCode
					,"msgState"	: "C"
					,"msgType"	: "O"
					,"step"		: 0
					,"depth"	: 0
					,"folderID"	: pFolderID
					,"menuID"	: pMenuID
					,"subject"	: $("#regErrorSubject").val()
					,"bodyText"	: body
					,"body"		: bodyText
				},
		    	dataType : 'json',
		    	success:function(data){
		    		if(data.status=='SUCCESS'){
		    			Common.Confirm("저장되었습니다. 저장된 게시글 페이지로 이동하시겠습니까?", 'Confirmation Dialog', function (result) {
		    	            if (result) {
		    					//게시판 목록 조회 팝업
		    	            	var prefixURL = '/groupware/layout/board_BoardView.do?CLBIZ=Board&CLSYS=board&CLMD=user&sortBy=&startDate=&endDate=&searchText=&searchType=Subject';
		    	            	var viewURL = String.format('{0}&menuID={1}&folderID={2}&messageID={3}&version={4}&boardType=Normal', prefixURL, pMenuID, pFolderID, data.messageID, 1);
		    	            	location.href = viewURL;
		    	            } else {
		    	            	$("#regErrorSimpleMake #regErrorSubject").val("");
		    					$("#regErrorSimpleMake #regErrorFolderID").val("");
		    					$("#regErrorSimpleMake #regErrorBodyText").val("");
		    	            }
		    	        });
		    		}else{
		    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
		    		}
		    	}, 
		  		error:function(error){
		  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
		  		}
		    });
		} else {
			Common.Warning(Common.getDic("msg_SelectBoard"));	//게시판을 선택해주세요.
		}
	},
	
	renderFileLimitInfo: function() {
		if(coviFile.option.fileSizeLimit > 0 || coviFile.option.limitFileCnt > 0) {
			var sHTML = "";
			sHTML += '<span style="color:#999">';
			sHTML += Common.getDic("lbl_UploadTotalLimit")+': ';
			
			if(coviFile.option.totalFileSize > 0) 
				sHTML += coviFile.convertFileSize(coviFile.option.totalFileSize);
			
			if(coviFile.option.totalFileSize > 0 && coviFile.option.fileSizeLimit > 0) 
				sHTML += " / ";			
			
			sHTML += Common.getDic("lbl_UploadLimit3")+': ';
			
			if(coviFile.option.fileSizeLimit > 0) 
				sHTML += coviFile.convertFileSize(coviFile.option.fileSizeLimit);
			
			if(coviFile.option.fileSizeLimit > 0 && coviFile.option.limitFileCnt > 0) 
				sHTML += " / ";
			
			if(coviFile.option.limitFileCnt > 0)
				sHTML += coviFile.option.limitFileCnt + Common.getDic("lbl_DocCount");
			
			
			sHTML += '</span>';
			
			$("#divFileLimitInfo").html(sHTML);
		}
	},
	
	getBodyText: function(){
		if (g_editorKind === "13") {	// 22.02.21, CoviEditor의 게시글 이메일보내기 기능 수정.  CoviEditor 일 경우, class="covi_out_wrapper" 안의 본문 내용을 보내준다.
			if($("#BodyText").find(".covi_out_wrapper").length > 0 ){
				return $("#BodyText").find(".covi_out_wrapper").html();
			}else{
				return $("#BodyText").html();	
			}
		} else {
			return $("#BodyText").html();	
		}
	},
	
	getAttachFileInfo: function(){
		var fileList = g_messageConfig.fileList;
		var attFileInfo = new Array();
		//var attachFileRootPath = "";
		
		if(fileList != null && fileList != ""){
			/* fileid로 경로 조회하도록 변경
			var osType = Common.getGlobalProperties("Globals.OsType");
			
			if(osType == "UNIX"){
				attachFileRootPath = Common.getGlobalProperties("attachUNIX.path");
			}else{
				attachFileRootPath = Common.getGlobalProperties("attachWINDOW.path");
			}
			attachFileRootPath = attachFileRootPath + Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")); 
			*/
			$.each(fileList, function(i, file){
				var json = new Object();
				
				json.fileName = file.FileName;
				json.saveFileName = file.SavedName;
				//json.savePath = attachFileRootPath + bizSection + "/" + file.FilePath;
				json.savePath = "";
				json.fileID = file.FileID;
				json.fileSize = file.Size;
				
				attFileInfo.push(json);
			});
		}
		
		return attFileInfo;
	},
	
	openMailPopup: function(){
		if(Common.getBaseConfig("isUseMail") == "Y" && Common.getBaseConfig("isUseExchMail") == "Y"){
			// 파일 리스트 세팅
			var fileArray = new Array();
			
			// 인라인 이미지 불러오기(에디터 첨부 이미지)
			$.ajax({
				type: "GET",
				async: false,
				data:{ 
						MessageID : g_messageConfig.MessageID
						, Version : g_messageConfig.Version
					},
				url: "/groupware/portal/exchFileList.do",
				success: function(data) {
					$(data.result.list).each(function(nIdx, value) {
						fileArray.push(board.exch_fileList(value));
					});
				}
			});
			
			// 첨부 파일
			$(g_messageConfig.fileList).each(function(nIdx, value) {
				fileArray.push(board.exch_fileList(value));
			});
			
			// 본문의 이미지 변경
			var dummy = document.createElement("div"); // 더미 태그 생성
			dummy.innerHTML = board.decodeUnicode(g_messageConfig.Body); // 게시글 본문 내용 세팅
			var images = Array.from(dummy.querySelectorAll("img[src]")); // img 태그  가져오기
			var sources = images.map(function (item) { return item.src.split("/").pop();}); // 파일명만 가져오기
			
			// 게시글 본문이 이미지 파일명이 파일 리스트의 파일명과 같은 경우 이미지 url을 다운로드 url로 변경
			$(sources).each(function(imgIdx, imgValue) {
				$(fileArray).each(function(nIdx, value) {
					if(imgValue==value.Name){
						images[imgIdx].src=value.Url;
					}
				});
			});
			
			// exchBody에 dummy 태그 넣기
			var exchBody = dummy.outerHTML;
			
			// 전송 데이터 세팅
			MailJsonData = {
			  "Token": GetEncryptToken(), // 인증용 JWT 토큰
			  "Subject": g_messageConfig.Subject, // 메일 제목
			  "Body": exchBody, // 메일 본문
			  "To": [], // 받는 사람
			  "Cc": [], // 참조
			  "Bcc": [], // 숨은 참조
			  "Attachment": fileArray // 첨부 파일
			};
			
			exch_mailSend(MailJsonData);
		} else {
			window.open("/mail/bizcard/goMailWritePopup.do?"
				+"callBackFunc=mailWritePopupCallback"
				+"&callMenu=" + "Board"
				+ "&userMail=" + Common.getSession("UR_Mail") 
				+ "&inputUserId=" + Common.getSession().DN_Code + "_" + Common.getSession().UR_Code
				+ "&popup=Y",
				"MailWriteCommonPopup", "height=800, width=1000, resizable=yes");
		}
	},
	
	openFeedPopup : function(pBizSection, pMenuID, pFolderID, pMessageID, pVersion) {
		var url = "/feed/user/goFeedWritePopup.do?CLBIZ=Feed&modeType=Create&orgBizSection=" + pBizSection + "&orgMenuID=" + pMenuID + "&orgFolderID=" + pFolderID + "&orgMessageID=" + pMessageID + "&orgVersion=" + pVersion;
		CFN_OpenWindow(url, encodeURIComponent(Common.getDic("lbl_TransferFeed")), (window.innerWidth - 500), (window.innerHeight - 100), "resize");		
	},
	
	openProjectAllocPopup : function() {
        window.addEventListener( 'message', boardcollabSelectCallback );
        collabUtil.openProjectAllocPopup(0, "N", "boardcollabSelectCallback");		
	},
	
	// MP 메일 연동 - 유니코드 텍스트 디코드
	decodeUnicode : function(unicodeString) {
		var r = /\\u([\d\w]{4})/gi;
		unicodeString = unicodeString.replace(r, function (match, grp) {
		    return String.fromCharCode(parseInt(grp, 16)); } );
		return unescape(unicodeString);
	},
	
	// 파일 리스트 세팅
	exch_fileList : function(value) {
		var origin = $(location).attr('origin');
		
		fileItem = new Object();
		fileItem.Name = (value.SaveType == "INLINE")? value.SavedName : value.FileName;
		fileItem.Url = origin + "/groupware/portal/exchFileDown.do?fileID="+value.FileID;
		fileItem.IsInline = (value.SaveType == "INLINE")?  "Y" : "N";
		
		return fileItem;
	},
	
	formatLinkSiteURL: function( pObj){
		var returnStr = String.format("<a href='{0}' target='_new' title='{0}'>{0}</a>", pObj.item.LinkURL);
		return returnStr;
	},
	
	getMultiFolderName: function(pMultiFolderIDs){
		var result = "";
		
		$.ajax({
			type: "POST",
			url: "/groupware/board/getMultiFolderName.do",
			data: {
				"MultiFolderIDs": pMultiFolderIDs
			},
			async: false,
			success: function(data){
				if(data.status == "SUCCESS"){
					result = data.result;
				}
			}, 
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/getMultiFolderName.do", response, status, error);
			}
		});
		
		return result;
	},

	renderMultiCategory: function(pType){ // View, Write
		if(Common.getBaseConfig("use" + bizSection + "MultiCategory") != "Y") return false;
		
		var multiCategoryCode = Common.getBaseConfig(bizSection + "MultiCategoryCode");
		
		if(multiCategoryCode){
			var $fragment = $(document.createDocumentFragment());
			var multiCategoryCodeArr = multiCategoryCode.split(",");
			var selectMsg = Common.getDic("msg_Select");
			var lang = Common.getSession("lang");
			
			$.each(multiCategoryCodeArr, function(idx, mCode){
				var divWrap = document.createElement("div");
				var isHalf = (idx % 2) == 1 ? true : false;
				
				$(divWrap).addClass("multiCategory");
				
				if(pType == "View"){
					if(isHalf) $(divWrap).addClass("disTblStyle");
					
					$(divWrap).append(String.format("<div class='tit'><span id='{0}' class='star'></span></div>", mCode));
					
					if(isHalf || (idx + 1) == multiCategoryCodeArr.length){
						$(divWrap).append(String.format("<div class='txt'><select userformid='{0}' name='UserForm_{0}' isCheck='Y' class='selectType02 size102' style='pointer-events: none;'><option value=''>{1}</option></select></div>", (idx+1), selectMsg));
					}else{
						$(divWrap).append(String.format("<div class='txt'><div class='disTblStyle'><select userformid='{0}' name='UserForm_{0}' isCheck='Y' class='selectType02 size102' style='pointer-events: none;'><option value=''>{1}</option></select></div></div>", (idx+1), selectMsg));
					}
				}else if(pType == "Write"){
					var divClass = "inputBoxSytel01 type02";
					
					if(isHalf) divClass += " subDepth";
					
					$(divWrap).addClass(divClass);
					$(divWrap).append(String.format("<div><span id='{0}' class='star'></span></div>", mCode));
					$(divWrap).append(String.format("<div><select userformid='{0}' name='UserForm_{0}' isCheck='Y' class='selectType02 size102'><option value=''>{1}</option></select></div>", (idx+1), selectMsg));
				}
				
				$(Common.getBaseCode(mCode).CacheData).each(function(){
					if(this.Code == mCode){
						$(divWrap).find("#" + mCode).text(CFN_GetDicInfo(this.MultiCodeName, lang));
					}else if(this.Code != ""){
						$(divWrap).find("select[userformid=" + (idx+1) + "]").append('<option value="'+this.Code+'">'+CFN_GetDicInfo(this.MultiCodeName, lang)+'</option>');
					}
				});
				
				if(isHalf){
					if(pType == "View") $($fragment[0].querySelectorAll(".txt")[idx - 1]).append($(divWrap));
					else if(pType == "Write") $($fragment[0].querySelectorAll(".inputBoxSytel01")[idx - 1]).append($(divWrap));
				}else{
					$fragment.append($(divWrap));
				}
			});
			
			$("#divUserDefField").empty().append($fragment);
		}
	},
	
	setImageRotate: function(pImg) {
		var $script = document.createElement("script");
		$script.type = "text/javascript";
		$script.src = "https://cdn.jsdelivr.net/npm/exif-js";
		$script.onload = function(){
			$(pImg).each(function(idx, img){
				EXIF.getData(img, function() {
					var orientation = EXIF.getTag(this, "Orientation");
					
					switch (orientation) {
						case 1: // 이미지 회전값이 0인경우 (정방향)
							$(img).css("transform", "rotate(0deg)");
							break;
						case 3: // 이미지 회전값이 180 (뒤집힌 경우)
							$(img).css("transform", "rotate(180deg)");
							break;
						case 6: // 이미지 회전값이 270 기운 경우 (왼쪽으로 90 기운 경우)
							$(img).css("transform", "rotate(90deg)");
							break;
						case 8: // 이미지 회전값이 90 기운 경우 (오른쪽으로 90 기운 경우)
							$(img).css("transform", "rotate(270deg)");
							break;
					}
				});
			});
		};
		
		document.head.appendChild($script);
	},
	
	lockMessage : function () {
		$.ajax({
	    	type:"POST",
	    	url:"/groupware/board/lockMessage.do",
	    	data:{
	    		"messageID": messageID
	    		,"comment": $("#hiddenComment").val()
	    	},
	    	success:function(data){
	    		if(data.status=='SUCCESS'){
	    			Common.Inform(Common.getDic("msg_ProcessOk"), "Inform", function() {
						if(g_boardConfig.FolderType == "Contents"){
	    					var url = "/groupware/layout/board_BoardWrite.do?CLSYS=board&CLMD=user&CLBIZ=Board&mode=create&folderID=" + folderID + "&menuID="+ menuID;
	    					
	    					if(CFN_GetQueryString("communityId") != "undefined" ){	//Community용 Parameter추가
	    						url += "&communityId="+CFN_GetQueryString("communityId") + "&CSMU=C";
	    					}
	    					
	    					CoviMenu_GetContent(url,false);
	    				} else {
	    					//상세보기에서 삭제했을 경우 목록으로 돌아감
		    				board.goFolderContents(g_urlHistory);	
	    				}
					});
	    		}else{
	    			Common.Warning(Common.getDic("msg_apv_030"));
	    		}
	    	},
	    	error:function(response, status, error){
	    	     //TODO 추가 오류 처리
	    	     CFN_ErrorAjax("/groupware/admin/lockMessage.do", response, status, error);
	    	}
	    });
	},	
	
	selectProcessActivityList: function(folderID){
		$.ajax({
			type: "POST",
			url: "/groupware/board/manage/selectProcessActivityList.do",
			dataType: 'json',
			data: {
				"folderID": folderID
			},
			success: function(data){
				if(data.status=='SUCCESS'){
					$('#spnApprovalLine').empty();
					var htmlApprovalLine = "";
					$(data.list).each(function(i, item){
						if(i > 0){
							htmlApprovalLine += "<li class='arr'><span></span></li>";
						}
						htmlApprovalLine += board.drawAppovalList(item.ActivityType, item.ActorCode, item.DisplayName);
					});
					
					$('#spnApprovalLine').append(htmlApprovalLine);
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/board/manage/selectProcessActivityList.do", response, status, error);
			}
		});
	},

	drawAppovalList: function(ActivityType, ActorCode, DisplayName){		
		return '<li class="person">'+
				'<p class="appname">'+(ActivityType=="Parall"? Common.getDic("lbl_Parall") : Common.getDic("lbl_Serial"))+'</p>'+
			    '<div class="image">'+
			    '    <span class="appphoto" style="background-image:url(\'/covicore/resources/images/no_profile.png\')"></span>'+
			    '</div>'+
			    '<p class="appname">'+DisplayName+'</p>'+
			    '</li>';
	},
	
	// XSS 변환 추가
	XSSBoard: function(body){
		var defaultFilterKey = "oncontextmenu,onmousemovexx,innerHTML,onmousewheel,onactive,onfocusxxout,expression,charset,ondataavailable,oncut,onkeyup,applet,onafteripudate,onclickxx,onkeypress,meta,string,onmousedownxx,onchange,onloadxx,xml,create,onbeforeactivate,onbeforecut,onbounce,blink,append,onbeforecopy,ondbclick,onmouseenter,link,binding,onbeforedeactivate,ondeactivate,onmouseout,ondatasetchaged,ondrag,onmouseoverxx,script,msgbox,cnbeforeprint,ondragendxx,onsubmit,embed,refresh,cnbeforepaste,ondragenter,onmouseend,object,void,onbeforeeditfocus,ondragleave,onresizexxstart,iframe,cookie,onbeforeuload,ondragover,onuload,frame,onbeforeupdate,ondragstart,onselectstart,frameset,onpaste,onpropertychange,ondrop,onreset,ilayer,onresize,ondatasetcomplete,onerrorxx,onmove,layer,onselect,oncellchange,onfinish,onstop,bgsound,base,onlayoutcomplete,onfocus,onrowexit,onblurxx,onselectionchange,vbscript,onerrorupdate,onbefore,onstart,onrowsinserted,onkeydownxx,onfilterchage,onmouseupxx,onfocusin,oncontrolselected,onrowsdelete,onlosecapture,onrowenter,onhelp,onreadystatechange,onmouseleave,onmousemove";
		var XSSFilterKey = Common.getBaseConfig("XSSFilterKey") ? Common.getBaseConfig("XSSFilterKey") : defaultFilterKey; // 기초설정 값 추가
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
	},
	
	goPreView: function(){	
		var msgDoNotOpenWindow = Common.getDic('msg_DoNotOpenWindow'); // {0}일 동안 이 창을 열지 않습니다.
		var p_PopupLimit = Common.getBaseConfig("PopupLimit_Portal");
		var p_FolderID = $("#selectFolderID").val();
		
		var url = String.format("/groupware/board/goBoardPreViewPopup.do?CLBIZ={0}&menuID={1}&folderID={2}&viewType=Popup", bizSection, menuID, p_FolderID);
		
		if(communityID != null && communityID != "" && communityID != "undefined") {
			url += "&communityId="+communityID;
		}
		
		parent.Common.open("", "boardPreViewPop", $("#Subject").val(), url, "925px", "580px", "iframe", true, null, null, true);
		
		var html = '';
		html =  '<div class="pro_today_x">';
		html += '	<a>';
		html += '		<p class="pro_today_btn" style="float:left;margin-left: 500px;">' + String.format(msgDoNotOpenWindow, 1) + '</p>';
		html += '	</a>';
		if(p_PopupLimit){
			html += '	<a">';
			html += '		<p class="pro_today_btn" style="float:left;margin-left:10px">' + String.format(msgDoNotOpenWindow, p_PopupLimit) + '</p>';
			html += '	</a>';
			html += '</div>';
		}
		
		$("#boardPreViewPop_pc").parent().append(html);
	},

	//미리보기 상세보기 게시글 옵션 항목 표시/숨김
	renderpreViewMessageOptionView: function(pBizSection, pFolderID, pConfig){
		//tag, link 영역 초기화
		$(".tagView").empty();
		
		//tag정보 조회
		if(g_boardConfig.UseTag == "Y"){
			if(pConfig.tagList.length > 0){
				var tagHTML = "";
				$(pConfig.tagList).each(function(idx, item){
					tagHTML += "<div class='tag' tag='" +item.Tag+ "'>"+ item.Tag +"</div>"
				});
				$(".tagView").prepend(tagHTML);
				$(".tagView").prepend("<span class='tagIcon'>" + Common.getDic("lbl_Tag") + "</span>");
				
				$('.tagView .tag').attr("style","cursor:pointer;");
				
			}
		}
		
		//link정보 조회
		if(g_boardConfig.UseLink == "Y"){
			
			if(pConfig.linkList.length > 0){
		
				var linkHTML = "";
				$(pConfig.linkList).each(function(idx, item){
					linkHTML += "<div class='tag'><a target='_blank' href='#'>" +item.Title+ "</a></div>";
				});
				$(".tagView").prepend(linkHTML);
				$(".tagView").prepend("<span class='tagIcon'>" + Common.getDic("lbl_Link") + "</span>");
				
			}
			
		}
		
		//카테고리 사용여부
		if(g_boardConfig.UseCategory == "Y"){
			$("#selectCategoryID").show();
			$("#selectCategoryID").coviCtrl("setSelectOption", "/groupware/board/selectCategoryList.do", 
				{folderID: pFolderID},
				 Common.getDic("lbl_CategorySelect"), "0", pConfig.CategoryID	
			);
		} else {
			$("#selectCategoryID").hide();
		}
		
		//사용자 정의필드정보 조회
		if((g_boardConfig.UseUserForm == "Y" && pConfig.IsUserForm == "Y")
				|| Common.getBaseConfig("use" + bizSection + "MultiCategory") == "Y"){
			//게시판 설정 및 게시글의 사용자 정의 폼 사용시 설정값 조회
			$("#divUserDefField").html("");
			$("#divUserDefField").show();
			board.getUserDefField("View", pFolderID);
			
			$(pConfig.fieldList).each(function(idx, item){
				var fieldObj = $("[name=UserForm_"+item.UserFormID+"]");
				
				//체크박스와 라디오 버튼은 UserFormID와 value로 식별
				if(fieldObj.attr("type") == "checkbox"){
					if (item.FieldValue && item.FieldValue != '' && item.FieldValue.indexOf(";")!=-1){
						$.each(item.FieldValue.split(";"), function(checkBoxIndex, checkedItem){
							$("[name=UserForm_"+item.UserFormID+"][value=" + checkedItem + "]").prop("checked", true);
						});
					} else {
						//단일 체크박스일경우 라디오와 동일하게 처리
						$("[name=UserForm_"+item.UserFormID+"][value=" + item.FieldValue + "]").prop("checked", true);
					}
				} else if (fieldObj.attr("type") == "radio"){
					$("input[type=radio][name=UserForm_"+item.UserFormID+"][value=" + item.FieldValue + "]").prop("checked", true);
				} else if(!fieldObj.is("select")){
					fieldObj.html(item.FieldValue.replaceAll("\n", "<br>"));
				} else {
					fieldObj.val(item.FieldValue);
				}
			});
			
		} else {
			$("#divUserDefField").hide();
		}
		
		if(g_boardConfig.UseProgressState == "Y"){
			$("#divUserDefField").show();
			board.getProcessState(pFolderID);
		}
		
		//연결게시정보 조회
		if(g_boardConfig.UseLinkedMessage == "Y" && pConfig.LinkedMessageList.length > 0){
			$("#divLinkedMessage").show();
			board.renderLinkedMessageView(pBizSection, pConfig.LinkedMessageList);
		} else {
			$("#divLinkedMessage").hide();
		}
		
		//링크사이트정보 조회
		if(g_boardConfig.FolderType == "LinkSite" && pBizSection != "Doc"){
			var returnStr = String.format("<a href='{0}' target='_new' title='{0}'>{0}</a>", g_messageConfig.LinkURL);
			var divLinkSite = $('<div />');
			divLinkSite.append( $('<div class="tit"><span>' + Common.getDic("lbl_URL") + '<span/></div>'));
			divLinkSite.append( $('<div class="txt h_Line"><span>' + returnStr + '</span></div>'));

			$("#divLinkSiteBoard").append(divLinkSite);
			$("#divLinkSiteBoard").show();
		} else {
			$("#divLinkSiteBoard").hide();
		}		
		
		//부서명 체크 시 강제 변경
		if(pConfig.UseDeptName == "Y"){
			$("#CreatorName").replaceWith('<strong id="CreatorName">'+pConfig.CreatorDept+'</strong>');
			$("#CreatorDept").text("");
		}
		
	},
	
	getPreViewData: function(){
		var preViewBody = coviEditor.getBody(g_editorKind, 'tbContentElement');
		var preViewBodyInlineImage= coviEditor.getImages(g_editorKind, 'tbContentElement');
		var preViewBodyBackgroundImage = coviEditor.getBackgroundImage(g_editorKind, 'tbContentElement');
		var LinkedMessageList = [];
		
		if(preViewBodyInlineImage){
			var preViewBodyInlineImageList = preViewBodyInlineImage.split('|');
			for (var pi = 0; pi < preViewBodyInlineImageList.length; pi++) {
				preViewBody = preViewBody.replace("‡" + pi + "‡", "src=\""+  preViewBodyInlineImageList[pi] + "\"" );
			}
		}
		
		if(preViewBodyBackgroundImage) {
			preViewBody = preViewBody.replaceAll("‡"+9999+"‡", "src=\""+  preViewBodyBackgroundImage + "\"" );
		}
		
		var preViewDataFiles = coviFile.files;
		
		if(preViewDataFiles.length > 0){
			for (var fi = 0; fi < preViewDataFiles.length; fi++) {
				
				var preViewDataFile = preViewDataFiles[fi];
				if(preViewDataFile.name){
					preViewDataFile.FileName = preViewDataFile.name;
					preViewDataFile.Extention = preViewDataFile.name.split('.')[1];					
				}
			}
		}
		
		if ($("#divLinkedList div").length > 0) {
			LinkedMessageList = JSON.parse($("#hiddenLinkedMessage").val());
		}
		
		var preViewData = {
			 "Subject"  : $("#Subject").val()
			,"FolderID": $("#selectFolderID").val()
			,"fileList" : preViewDataFiles
			,"RegistDate": (new Date()).yyyymmddhhmm() + ":00"
			,"ModifyDate": (new Date()).yyyymmddhhmm() + ":00"
			,"UseSecurity": $("#chkUseSecurity").is(":checked") ? "Y" : "N"
			,"UseDeptName" : $("#chkUsePubDeptName").prop("checked") ? "Y" : "N"
			,"CategoryID" : $("#selectCategoryID").val()
			,"FolderType": "Notice"
			,"Body" : escape(preViewBody)
			,"tagList" : JSON.parse(board.setTagData())
			,"linkList" : JSON.parse(board.setLinkData())
			,"fieldList" : JSON.parse(board.setUserDefFieldData())
			,"ExpiredDate" :$("#ExpiredDate").val() ? $("#ExpiredDate").val() : "9999.12.31"
			,"PopupStartDate" : $("#PopupStartDate").val()
			,"PopupEndDate" : $("#PopupEndDate").val()
			,"TopStartDate" : $("#TopStartDate").val()
			,"TopEndDate" : $("#TopEndDate").val()
			,"ReservationDate" : $("#ReservationDate").val() != "" ? String.format("{0} {1}:00",$("#ReservationDate").val(), $("#reservationTime").val()) : ""
			,"CreatorName" : Common.getSession("USERNAME")
			,"CreatorDept" : Common.getSession("DEPTNAME")
			,"CreatorLevel" : Common.getSession("UR_JobLevelName")
			,"PhotoPath" : Common.getBaseConfig('ProfileImagePath',1)+Common.getSession("USERID")+".jpg"
			,"IsUserForm" : $("#IsUserForm").val()
			,"LinkedMessageList" : LinkedMessageList
		};
		
		return preViewData;
	},
	
	// 게시 목록에서 파일 다운로드 및 미리보기 시도 시 조회자 추가
	createFileDownloadToMessageReader: function(pBizSection, pFolderID, pMessageID, pVersion) {
		$.ajax({
			url:"/groupware/board/createFileDownloadToMessageReader.do",
			type:"POST",
			data: {
				"bizSection": pBizSection,
				"folderID": pFolderID,
				"messageID": pMessageID,
				"version": pVersion
			},
			async:false,
			success:function (data) {
				if(data.status != "SUCCESS"){
    				Common.Error("<spring:message code='Cache.msg_apv_030'/>");
    			}
			},
			error:function (error){
				CFN_ErrorAjax("/groupware/board/createFileDownloadToMessageReader.do", response, status, error);
			}
		});
	}
}

//게시 업무등록 팝업에서 확인 버튼 클릭
function boardcollabSelectCallback(ev){
	if( ev.data.functionName != 'boardcollabSelectCallback' ) {
        return;
    }
	window.removeEventListener( 'message', boardcollabSelectCallback );
	
	var linkURL = "/groupware/board/goBoardViewPopup.do?CLBIZ=" + bizSection + "&menuID=" + menuID + "&version=" + version + "&folderID=" + folderID + "&messageID=" + messageID + "&viewType=Popup";
	
	collabUtil.openTaskAddPopupFromMessage("CollabTaskAddPopup", "callbackTaskSave", "", ev.data.params.PrjType, ev.data.params.PrjSeq, ev.data.params.SectionSeq, encodeURIComponent(ev.data.params.PrjName), encodeURIComponent(ev.data.params.SectionName), "", bizSection, Base64.utf8_to_b64(linkURL), g_messageConfig.Subject, Base64.utf8_to_b64(JSON.stringify(g_messageConfig.fileList)));

}

function getExpiredDateHTML(){
	var expiredDate = '';
	if (mode == 'create') expiredDate = XFN_addMinusDateByCurrDate(g_boardConfig.ExpireDay, '.')
	else if (mode == 'update') expiredDate = g_messageConfig.ExpiredDate;
	var expiredDateHTML = '';
	expiredDateHTML += '<div class="inputBoxSytel01 type02">'
	expiredDateHTML += '<div><span>'+Common.getDic('lbl_ExpireDate')+'</span></div>'
	expiredDateHTML += '<div>'+expiredDate+'</div>'
	expiredDateHTML += '</div>'
	return expiredDateHTML;
}

function boardDescription(item){
	if($(item).attr('class') === 'close'){
		$('.boardSummary').attr('aria-expanded', 'false');
		$('.cRConTop .help').attr('aria-pressed', 'false');
		
		var existingValue = localStorage.getItem('ContentsID');
		
		if(existingValue) {
		  var parsedValue = JSON.parse(existingValue);
		  parsedValue.push(g_boardConfig.ContentsID);
		  localStorage.setItem('ContentsID', JSON.stringify(parsedValue));
		} else {
		  var newValue = [g_boardConfig.ContentsID];
		  localStorage.setItem('ContentsID', JSON.stringify(newValue));
		}
	} else {
		$('.boardSummary').attr('aria-expanded', 'true');
		$('.cRConTop .help').attr('aria-pressed', 'true');
		
		for(i=0;i<JSON.parse(localStorage.getItem("ContentsID")).length;i++){
			if(g_boardConfig.ContentsID == JSON.parse(localStorage.getItem("ContentsID"))[i]){
				var existingValue = JSON.parse(localStorage.getItem('ContentsID'));
				
				if (Array.isArray(existingValue)) {
				    var indexToRemove = existingValue.indexOf(g_boardConfig.ContentsID);
				    if (indexToRemove !== -1) {
				        existingValue.splice(indexToRemove, 1);
				        localStorage.setItem('ContentsID', JSON.stringify(existingValue));
				    }
				}
			}
		}
	}
}