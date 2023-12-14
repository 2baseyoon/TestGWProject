var _ShowLayerSize = {}; // 레이어 팝업원 원래 사이즈
var _ShowLayerPosition = {}; // 레이어 팝업원 원래 위치

var _CallBackMethod,
	_CallBackMethod2,
	_CallBackMethod3,
	_CallBackMethod4,
	_CallBackMethod5;

//---상수관련---------------------------------------------------------------------------------------------



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

///<creator>김형복 (k96mi005@covision.co.kr)</creator> 
///<createDate>2011.2011.01.14</createDate> 
///<lastModifyDate>2011.2011.01.14</lastModifyDate> 
///<version>1.1.0</version>
///<summary> 
///스크립트에서 사용되는 공용상수 정의(Prefix "_")
///</summary>
///<ModifySpc>
///2013.11.18(김형복) : ie11에 대한 체크 추가 및 OS정보(Win8.1) 수정 
///</ModifySpc>
*/

//브라우져/OS 객체 확인
/* window.navigator.userAgent
-- IE : Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.3; .NET4.0C; .NET4.0E; Tablet PC 2.0)
-- Chrome : Mozilla/5.0 (Windows NT 6.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.106 Safari/535.2
-- Firefox : Mozilla/5.0 (Windows NT 6.1; rv:8.0) Gecko/20100101 Firefox/8.0
-- Safari : Mozilla/5.0 (Windows NT 6.1) AppleWebKit/534.51.22(KHTML, like Gecko) Version/5.11 Safari/534.51.22
if (window.ActiveXObject !== undefined) {
}

*/
//alert(window.navigator.userAgent)
//IE 브라우져 여부
var _ie = ((window.navigator.userAgent.indexOf("MSIE") != -1) ? true : ((window.navigator.userAgent.indexOf("Trident") != -1) ? true : false));
//IE 버젼
var _ieVer = ((window.navigator.userAgent.indexOf("MSIE 6") != -1) ? 6 : ((window.navigator.userAgent.indexOf("MSIE 7") != -1) ? 7 : ((window.navigator.userAgent.indexOf("Trident/4.0") != -1) ? 8 : ((window.navigator.userAgent.indexOf("Trident/5.0") != -1) ? 9 : ((window.navigator.userAgent.indexOf("Trident/6.0") != -1) ? 10 : ((window.navigator.userAgent.indexOf("Trident/7.0") != -1) ? 11 : 12))))));
//IE의 호환성 보기와 상관없는 IE의 원버젼 정보
var _ieOrgVer = ((window.navigator.userAgent.indexOf("Trident/4.0") != -1) ? 8 : ((window.navigator.userAgent.indexOf("Trident/5.0") != -1) ? 9 : ((window.navigator.userAgent.indexOf("Trident/6.0") != -1) ? 10 : ((window.navigator.userAgent.indexOf("Trident/7.0") != -1) ? 11 : _ieVer))));
//Firefox
var _firefox = ((window.navigator.userAgent.indexOf("Firefox") != -1) ? true : false);
//Safari
var _safari = ((window.navigator.userAgent.indexOf("Safari") != -1 && window.navigator.userAgent.indexOf("Chrome") == -1 && window.navigator.userAgent.indexOf("Mobile") == -1) ? true : false);
//Chrome
var _chrome = ((window.navigator.userAgent.indexOf("Chrome") != -1) ? true : false);
//Opera
var _opera = ((window.navigator.userAgent.indexOf("Opera") != -1) ? true : false);
//Edge
var _edge = ((window.navigator.userAgent.indexOf("Edge") != -1) ? true : false);
//Android
var _android = ((window.navigator.userAgent.toLowerCase().indexOf("android") != -1) ? true : false);
//iPhone
var _iphone = ((window.navigator.userAgent.toLowerCase().indexOf("iphone") != -1) ? true : false);
//iPad
var _ipad = ((window.navigator.userAgent.toLowerCase().toLowerCase().indexOf("ipad") != -1) ? true : false);
//Mac
var _mac = ((window.navigator.userAgent.indexOf("Macintosh") != -1) ? true : false);
//coviHybrid
var _coviHybrid = ((window.navigator.userAgent.indexOf("COVI_HYBRID") != -1) ? true : false);

//Mobile 여부
var _mobile = ((window.navigator.userAgent.indexOf("Mobile") != -1) ? true : (_android ? true : (_iphone ? true : (_ipad ? true : ((window.navigator.userAgent.indexOf("COVI_HYBRID") != -1) ? true : false)))));

//운영체제
var _OS = ((window.navigator.userAgent.indexOf("Windows NT 5.1") != -1) ? "WinXp" : ((window.navigator.userAgent.indexOf("Windows NT 5.2") != -1) ? "Win2003Svr" : ((window.navigator.userAgent.indexOf("Windows NT 5") != -1) ? "Win2000" : ((window.navigator.userAgent.indexOf("Windows NT 6.0") != -1) ? "Win2008" : ((window.navigator.userAgent.indexOf("Windows NT 6.1") != -1) ? "Win7" : ((window.navigator.userAgent.indexOf("Windows NT 6.2") != -1) ? "Win8" : ((window.navigator.userAgent.indexOf("Windows NT 6.3") != -1) ? "Win8.1" : "OrderOS")))))))

//표준만 지원 여부(IE의 기능 비지원 여부) IE => false, Chrome/Firefox/Safari = true
var _dom = (document.getElementById && !document.all) ? true : false;
//HTML5 지원 여부(HTML5에서 sessionStorage를 지원함)
var _html5 = (window.sessionStorage) ? true : false;
//네스케이프 브라우져 여부
var _nn4 = (document.layers) ? true : false;
/*
Screen 객체의 속성
availHeight : 인터페이스가 차지한 범위를 제외한 실질적인 공간의 높이를 픽셀로 구한다.
availWidth : 인터페이스가 차지한 범위를 제외한 실질적인 공간의 넓이를 픽셀로 구한다.
colorDepth : 컴퓨터에서 사용되는 컬러 수를 표시
height : 모니터상에 보여주는 즉, 디스플레이 화면의 높이를 픽셀로 구한다.
width : 모니터상에 보여주는 즉, 디스플레이 하면의 넓이를 구한다.
pixelDepth : 하나의 픽셀당 비드 수를 표시(넷스케이프 전용)
*/
/* window.screen 모든 브라우져 동일
-- IE : availHeight=1050, availWidth=1920, colorDepth=24, height=1080, width=1920, pixelDepth=24 (주모니터)
-- Chrome : availHeight=800, availWidth=1280, colorDepth=32, height=800, width=1280, pixelDepth=32 (브라우져가 뜬 모니터)
-- Firefox : availHeight=800, availWidth=1280, colorDepth=24, height=800, width=1280, pixelDepth=24 (브라우져가 뜬 모니터)
-- Safari  : availHeight=1050, availWidth=1920, colorDepth=24, height=1080, width=1920, pixelDepth=24 (주모니터)
*/
//해상도 정보
var _screenW = window.screen.width;
var _screenH = window.screen.height;
var _fixedWidth = 1024; //Width 최소고정값

//웹 사이트 경로 정보
var _HostName = window.location.hostname;             // 사이트 도메인  ex) www.No1.com
var _HostFullName = document.location.protocol + "//" + document.location.hostname;  //사이트 호스트 네임 Full ex) http://www.No1.com
var _DocPath = window.document.location.pathname;     // 현재 페이지 경로 ex) /WebSite/Main.aspx
var _QueryString = window.document.location.search;   // 현재 페이지 쿼리 스트링 ex) ?System=Portal
var _WebRoot = _DocPath.substring(0, _DocPath.indexOf("/", 2)).toUpperCase().replace("/", ""); // 현재 웹사이트 Root Name ex) WebSite

//ko(0)-한국어, en(1)-영어, ja(2)-일본어, zh(3)-중국어, e1(4)-추가 언어1, e2(5)-추가 언어2, e3(6)-추가 언어3, e4(7)-추가 언어4, e5(8)-추가 언어5, e6(9)-추가 언어6
var _LanguageIndex = { "ko": 0, "en": 1, "ja": 2, "zh": 3, "e1": 4, "e2": 5, "e3": 6, "e4": 7, "e5": 8, "e6": 9 }; // 다국어 인덱스 값

//사용자의 액션 수행 최종시간(특정 시간이 지난 후 화면을 잠그거나 하기 위함.) 
var _ActionTime = new Date();

//==== 공용자원 객체 ====> 값을 가져온 상태면 다시 가져오지 않게 사용자 세션/다국어 정보를 전역에 저장함.
//(스크립트에서 여러번 정보를 호출할때 계속 웹서비스를 호출하지 않고 객체를 먼져 뒤저서 있으면 보내줌)
var _Session = {};      // 세션정보
var _Dictionary = {};   // 다국어 정보
var _PgModule = {};     // 프로그램 모듈 정보
var _AppConfig = {};    // 어플리 케이션 설정정보
var _BaseConfig = {};   // 기초 설정 정보
var _BaseCode = {};     // 기초 코드 정보
var _MenuInfo = {};     // 메뉴 정보
var _TimeZoneTimeDiff = {}; // 타임존 코드에 대한 차이 시간
var _MobileScroll = {}; // 모바일 스크롤 객체
var _ShowLayerSize = {}; // 레이어 팝업원 원래 사이즈
var _ShowLayerPosition = {}; // 레이어 팝업원 원래 위치

var _RiseAjaxError = false; // Ajax호출시 네트워크/인증에 문제가 발생하였을 경우 Ajax 서비스가 호출되지 않도록 확인하는 처리를 위해

//==== 컨트롤 전역 ====>
//컨트롤 관련 
var _controlsPath = "/covicore/resources/images/covision";		//"/Images/Images/Controls/";
var _lodingImage = "loding12.gif";
var _lodingImageHtml = "<center><img src='/covicore/resources/images/covision/loding12.gif' alt='Loading...' /></center>";
var _progressImage = "loding14.gif";
var _IndicatorImage = "loding10.gif";

// 표준 날짜 포멧 관련
var _StandardServerDateFormat = "yyyy-MM-dd HH:mm:ss";

var _UR_DateFullFormat = "yyyy-MM-dd HH:mm:ss";
var _UR_DateFormat = "yyyy-MM-dd HH:mm";
var _UR_DateSimpleFormat = "yyyy-MM-dd";

var _ServerDateFullFormat = "yyyy-MM-dd HH:mm:ss";
var _ServerDateFormat = "yyyy-MM-dd HH:mm";
var _ServerDateSimpleFormat = "yyyy-MM-dd";


//-----상수관련 끝--------------------------------------------------------------------------------------------



// Grid Control
var coviGrid = Class.create(AXGrid,{
	ObjectName   : "myGrid" + (window.crypto.getRandomValues(new Uint32Array(1))/4294967296).toString(24).replace(/[^a-z]+/g, '') ,
	rightMargin  : 11,
	_targetID    : "AXGridTarget", // {String} -- 그리드 div ID
	_theme       : "AXGrid",       // {String} -- CSS Class 이름
	_fixedColSeq : null,              // {Number} -- 컬럼고정 기능을 사용합니다. 고정할 마지막 컬럼의 인덱스 값입니다. 예제) http://dev.axisj.com/samples/AXGrid/fixedColSeq.html
	_fitToWidth  : true,           // {Boolean} [false] -- 컬럼 가로 길이를 그리드의 가로 길이에 맞춥니다.
	_colHeadAlign: "center",       // {String} 헤드의 기본 정렬. "left"|"center"|"right" 값을 사용할 수 있습니다. colHeadAlign 을 지정하면 colGroup 에서 정의한 정렬이 무시되고 colHeadAlign : false 이거나 없으면 colGroup 에서 정의한 속성이 적용됩니다.
	_mergeCells  : [],           // {Boolean|Array} -- 전체셀병합,병합안함,지정된 인덱스열만 병합 예제) http://dev.axisj.com/samples/AXGrid/mergeCells.html
	_height      : "400",         // {Number|String} -- 그리드의 높이를 지정합니다. 숫자를 사용하면 픽셀 단위로, "auto" 값을 사용하면 그리드의 높이가 내용에 맞춰서 늘어납니다. 예제) http://dev.axisj.com/samples/AXGrid/autoHeight.html
	_sort        : true,           // {Boolean} -- true: 그리드의 헤더를 클릭해서 정렬 할 수 있습니다. false: 정렬 기능을 비활성화 합니다.  이 설정은 colGroup의 sort 보다 우선적으로 적용됩니다.
	_displayColHead : true,           // {Boolean} -- 헤더 표시여부를 설정합니다. 이 설정이 false인 경우 remoteSort는 자동으로 false로 처리(remoteSort 설정보다 우선) - 2017.09.21 yjlee 추가
	_remoteSort  : true,           // {Boolean} [false] -- 서버에서 정렬을 처리(서버에서 별도 처리 필요)합니다. 헤더 클릭시 'sortBy=cost desc' 형식의 정렬 정보가 ajax 요청에 포함됩니다.
	_colHeadTool : true,           // {Boolean} -- 컬럼 display 여부를 설정 합니다. 이 설정은 colGroup의 colHeadTool 보다 우선적으로 적용됩니다.
	_viewMode    : "grid",          // {String} -- 그리드가 보여지는 형태("grid"|"icon"|"mobile")를 지정합니다. viewMode는 mediaQuery에 의해서 자동으로 결정되기도 합니다. 예제) http://localhost/axisj/samples/AXGrid/viewMode.html
	_overflowCell : [] , 				// TD 영역의 overflow 를 visible값으로 할 셀의 index를 저장합니다. (ex. context menu, file 등) 
	_reserveKeys : {},// reserveKeys는 AXISJ에서 지정한 키를 다른 키로 지정하는 하는 경우 사용합니다. reserveKeys를 사용하면 데이터를 수정없이 바로 사용할 수 있습니다.
	_colGroup : [],// 데이터 리스트의 컬럼을 정의합니다.
	_colHead: {},  // 컬럼 헤더를 병합할 수 있습니다. 사용법은 colGroup과 동일하며 key 대신 colSeq를 사용할 수 있습니다. 예제) http://dev.axisj.com/samples/AXGrid/colhead.html
	_body: {},
	_foot: {},
	_paging: true,
	_page:{
		paging:false,
		pageNo:1,
		pageSize:10,
		pageCount:"10",
		listCount:100,
		listOffset:5
	},
	_editor: {},
	_contextMenu: {}, // API와 예제를 참고하세요. API) http://jdoc.axisj.com/AXContextMenu.html 예제) http://dev.axisj.com/samples/AXCore/AXContextMenu.html
	_emptyListMSG: "조회할 목록이 없습니다.",	// 목록이 비어 있을 때 표시할 메시지
	_listCountMSG: "<b>{listCount}</b> counts",
	_resizeable:true,
	_xscroll:false,
	_selectedClearOnPaging:false,
	_pageSizeOption: '10,30,50,100,200',
	listData: {},
	bindGrid			: function (pListData) {
		this.listData = pListData;
		
		this.acceptConfig();		
	},
	setGridHeader		:function (pHeader){
		this._colGroup = pHeader;
		
		//this.acceptConfig();
	},
	setGridBody			:function (pBodyOption) {
		this._body = pBodyOption;
	},
	setGridFooter		:function (pFooter) {
		this._foot = pFooter;
	},
	setGridConfig		:function (pObj) {
		AXConfig.AXGrid.fitToWidthRightMargin = this.rightMargin;
		this._targetID    	= pObj.targetID == undefined ? this._targetID : pObj.targetID;
		this._theme       	= pObj.theme == undefined ? this._theme : pObj.theme;
		this._fixedColSeq 	= pObj.fixedColSeq == undefined ? this._fixedColSeq : pObj.fixedColSeq;
		this._fitToWidth  	= pObj.fitToWidth == undefined ? this._fitToWidth : pObj.fitToWidth;
		this._colHeadAlign	= pObj.colHeadAlign == undefined ? this._colHeadAlign : pObj.colHeadAlign;
		this._mergeCells  	= pObj.mergeCells == undefined ? this._mergeCells : pObj.mergeCells;
		this._height      	= pObj.height == undefined ? this._height : pObj.height;
		this._sort        	= pObj.sort == undefined ? this._sort : pObj.sort;
		this._displayColHead 	= pObj.displayColHead == undefined ? this._displayColHead : pObj.displayColHead;
		this._remoteSort  	= (this._displayColHead == false) ? false : (pObj.remoteSort == undefined ? this._remoteSort : pObj.remoteSort); //_displayColHead가 false일 경우 false
		this._colHeadTool 	= pObj.colHeadTool == undefined ? this._colHeadTool : pObj.colHeadTool;
		this._viewMode    	= pObj.viewMode == undefined ? this._viewMode : pObj.viewMode;
		this._reserveKeys 	= pObj.reserveKeys == undefined ? this._reserveKeys : pObj.reserveKeys;
		this._colGroup 		= pObj.colGroup == undefined ? this._colGroup : pObj.colGroup;
		this._colHead		= pObj.colHead == undefined ? this._colHead : pObj.colHead;
		this._body			= pObj.body == undefined ? this._body : pObj.body;
		this._foot			= pObj.foot == undefined ? this._foot : pObj.foot;
		this._page			= pObj.page == undefined ? this._page : pObj.page;
		this._editor		= pObj.editor == undefined ? this._editor : pObj.editor;
		this._contextMenu	= pObj.contextMenu == undefined ? this._contextMenu : pObj.contextMenu;
		this._paging		= pObj.paging == undefined ? this._paging : pObj.paging;		
		this._listCountMSG  = pObj.listCountMSG == undefined ? this._listCountMSG : pObj.listCountMSG;
		this._resizeable    = pObj.resizeable == undefined ? this._resizeable : pObj.resizeable;

		this.config.emptyListMSG = pObj.emptyListMSG == undefined? Common.getDic("msg_NoDataList"): pObj.emptyListMSG ;
		this.config.listCountMSG = pObj.listCountMSG == undefined ? ("<b>{listCount}</b> " + Common.getDic("lbl_Count") ) : pObj.listCountMSG 
		
		this._notFixedWidth    = pObj.notFixedWidth == undefined ? this._notFixedWidth : pObj.notFixedWidth;
		this._ckGridWidth    = pObj.ckGridWidth == undefined ? this._ckGridWidth : pObj.ckGridWidth;
		this._ckBeforeViewYn    = pObj.ckBeforeViewYn == undefined ? this._ckBeforeViewYn : pObj.ckBeforeViewYn;
		this._overflowCell    = pObj.overflowCell == undefined ? this._overflowCell : pObj.overflowCell;
		this._xscroll    	= pObj.xscroll == undefined ? this._xscroll : pObj.xscroll;
		this._selectedClearOnPaging	= pObj.selectedClearOnPaging == undefined ? this._selectedClearOnPaging : pObj.selectedClearOnPaging; //mergeCells 사용시, grid선택 > page이동시 ui깨짐으로 인해 clear 옵션추가
		this._pageSizeOption = (typeof Common == 'object' && typeof Common.getBaseConfig == 'function' && Common.getBaseConfig('adminPageSizeOption') != '') ? Common.getBaseConfig('adminPageSizeOption') : this._pageSizeOption;
		//this.acceptConfig();
		/*
		 * setConfig 중복 호출 방지를 위해 위치를 acceptConfig에서 옮김
		 * */
		this.setConfig({
			targetID    	: this._targetID,
			theme       	: this._theme,
			fixedColSeq 	: this._fixedColSeq,
			fitToWidth  	: this._fitToWidth,
			colHeadAlign	: this._colHeadAlign,
			mergeCells  	: this._mergeCells,
			height      	: this._height,
			sort        	: this._sort,
			displayColHead : this._displayColHead,
			remoteSort  	: this._remoteSort,
			colHeadTool 	: this._colHeadTool,
			viewMode    	: this._viewMode,
			reserveKeys 	: this._reserveKeys,
			colGroup 		: this._colGroup,
			colHead			: this._colHead,
			body			: this._body,
			foot			: (Object.keys(this._foot).length > 0 ? this._foot : undefined),
			page			: this._page,
			editor			: (Object.keys(this._editor).length > 0 ? this._editor : undefined),
			contextMenu		: (Object.keys(this._contextMenu).length > 0 ? this._contextMenu : undefined),
			resizeable		: this._resizeable, //resize 시 다시 그리는 설정 off
			notFixedWidth	: this._notFixedWidth,
			ckGridWidth	: this._ckGridWidth,
			ckBeforeViewYn	: this._ckBeforeViewYn,
			overflowCell : this._overflowCell,
			xscroll : this._xscroll
        });
		
		
	},
	acceptConfig		: function () {
		if(this.listData.page != undefined){
			this.page = this.listData.page;
			this.setData(this.listData);
			coviInput.init();
			//custom 페이징 추가
			this.fnMakeNavi(this._targetID);
			// 페이지 옵션 추가
			if(this.listData.objectName && this.listData.callbackName) this.renderPageSizeControl(this.listData);
		} else {
			//custom 페이징 추가
			if(Object.keys(this.listData).includes("onLoad")){
				var onload = this.listData.onLoad;
				var thisGridObj = this;
				
				this.listData.onLoad = function () {
					onload();
					coviInput.init();
					thisGridObj.fnMakeNavi(thisGridObj._targetID);			//custom 페이징 추가
					
					if(thisGridObj.listData.objectName && thisGridObj.listData.callbackName) thisGridObj.renderPageSizeControl(thisGridObj.listData);
				}
			} else {
				var thisGridObj = this;
				
				this.listData.onLoad = function () {
					coviInput.init();
					thisGridObj.fnMakeNavi(thisGridObj._targetID);			//custom 페이징 추가
					
					if(thisGridObj.listData.objectName && thisGridObj.listData.callbackName)thisGridObj.renderPageSizeControl(thisGridObj.listData);
				}
			}
			this.setList(Object.keys(this.listData).length > 0 ? this.listData : {}, null, null, "paging");
		}
	},
    changeView : function (viewMode){
    	if(viewMode == "grid"){
            this.changeGridView({
                viewMode:viewMode
            });
        }else if(viewMode == "icon"){
        	this.changeGridView({
                viewMode:viewMode,
                view: {
                    // 속성이 없을때 예외 처리 마지막에 구현
                    width:"150",
                    height:"200",
                    img: {left:"10", top:"10", width:"129", height:"150",style:"border:1px solid #ccc;"},
                    label:{left:"10", top:"160", width:"130", height:"20"},
                    description: {left:"10", top:"175", width:"130", height:"20", style:"color:#888;"},
                    format: function(){
                        return {
                            imgsrc : "resources/images/test/1.jpg",// + this.item.img,
                            label : this.item.id,//this.item.subject,
                            description : this.item.status//this.item.registDate + "," + this.item.register
                        }
                    }
                }
            });
        }else if(viewMode == "mobile"){
            this.changeGridView({
            	viewMode:viewMode,
        		view: {
                    column: [ // col 은 4
                        $(headerData)
                        //{key:"subject", label:"제목",  addClass:"underLine"},
                        //{key:"registDate", label:"작성일",  align:"right"},
                        //{key:"register", label:"작성자",  align:"center"},
                        //{key:"img", label:"이미지", align:"center"}
                    ]
                }
            });
        }
    },
    deleteItem			: function(index) {
        $.Event(event).stopPropagation(); // 버튼클릭 이벤트가 row click 이벤트를 발생시키지 않도록 합니다.
        var item = this.list[index];
        toast.push('deleteItem: ' + $.param(item).dec());
    },
    getExcel			: function(type){
        var obj = this.getExcelFormat(type);
        //trace(obj);
        $("#printout").html(Object.toJSON(obj));
    },
    fnMakeNavi: function (pObj){
    	if(this._paging == false){
    		return ;
    	}
    	this.ObjectName = pObj;
    	
    	$('#' + this._targetID + "_AX_gridPageBody").append('<div id="custom_navi_' + this._targetID + '" style="text-align:center;margin-top:2px;"></div>');
    	
    	var list_offset = this.page.listOffset?this.page.listOffset:5; // navigation에서 한번에 보여질 페이지 개수

        // gypark 전체갯수가 한번 보여주는 갯수의 배일 경우 페이지가 하나 더 나오는 오류 수정
        if(this.page.listCount != 0 && this.page.listCount % this.page.pageSize == 0){
        	this.page.pageCount = (this.page.listCount / this.page.pageSize);
        }
        if(this.page.pageCount == 0){
        	this.page.pageCount = 1;
        }
    	
        var start_page = Math.ceil(this.page.pageNo / list_offset) * list_offset - (list_offset - 1);
        var end_page = (start_page + list_offset - 1 > this.page.pageCount) ? this.page.pageCount : start_page + list_offset - 1;
        
        var pageCount = this.page.pageCount;//this.page.listCount == this.page.pageCount * this.page.pageSize ? this.page.pageCount - 1 : this.page.pageCount; 
        
        var custom_navi_html = '';

        custom_navi_html += "<input type=\"button\" id=\"AXPaging_begin\" class=\"AXPaging_begin\"/>";
        custom_navi_html += "<input type=\"button\" id=\"AXPaging_prev\" class=\"AXPaging_prev\"/>";
        
        for (var i=start_page; i<= end_page; i++) {
            custom_navi_html += "<input type=\"button\" id=\"AXPaging\" value=\"" + i + "\" style=\"min-width:20px;\" class=\"AXPaging " + (i == this.page.pageNo ? "Blue\"" : "\" ") + "/>";
        }
        custom_navi_html += "<input type=\"button\" id=\"AXPaging_next\" class=\"AXPaging_next\"/>";
        custom_navi_html += "<input type=\"button\" id=\"AXPaging_end\" class=\"AXPaging_end\"/>";
        $('#custom_navi_' + this._targetID).html(custom_navi_html);
        
        //쿠폰관리 mergeCells 사용으로 인해 grid 깨짐 방지.
        if(this.ObjectName == "couponListGrid"){
        	$(".gridBodyTr :nth-child(2)").filter(function (index, selector) {
    			if($(selector).attr("rowspan") >  1) {
    				$(selector).css("border-left","0px");
    			}
    		});
        }
        this.bindEvent(false);
        /*var pagemovefunc = function (pObj) {
        	//스크롤 위치 변경 
        	if (pObj.config.viewMode != "mobile") {

                var scrollTop = 0;
                pObj.scrollContent.css({top: scrollTop});
                pObj.contentScrollContentSync({top: scrollTop});

                if (pObj.pageActive && pObj.ajaxInfo) {
                	pObj.setList(pObj.ajaxInfo, pObj.ajax_sortDisable, null, "paging");
                	pObj.contentScrollResize();
                }
            }
            else {
            	
                if (pObj.pageActive && pObj.ajaxInfo) {
                	pObj.setList(pObj.ajaxInfo, pObj.ajax_sortDisable, null, "paging");
                }
            }
        }
        
        $(".AXPaging_begin").click(function (event) {
        	event.stopImmediatePropagation();
        	this.page.pageNo = 1;
        	pagemovefunc(this);
        }.bind(this));
        
        $(".AXPaging_prev").click(function (event) {
        	event.stopImmediatePropagation();
        	this.page.pageNo = start_page > 1 ? start_page - 1 : 1;
        	pagemovefunc(this);
        }.bind(this));
        
        var obj = this;
        $(".AXPaging").each(function () {
        	$(this).click(function () { 
                var thisobjname =$(this).parents("div").parents("div").parents("div").parents("div").attr("id");
                
                if(obj.ObjectName==thisobjname){
                 obj.page.pageNo = $(this).attr("value");           
                    pagemovefunc(obj);
                   }             
             });     
        });
        
        $(".AXPaging_next").click(function (event) {
        	event.stopImmediatePropagation();
        	this.page.pageNo = end_page < this.page.pageCount ? end_page + 1 : end_page;
        	pagemovefunc(this);
        }.bind(this));
        
        $(".AXPaging_end").click(function (event) {
        	event.stopImmediatePropagation();
        	this.page.pageNo = pageCount;
        	pagemovefunc(this);
        }.bind(this));*/
    },
    fnGoPage: function(page) {
    	var pageAdd = page - this.page.pageNo;
        this.goPageMove(pageAdd);
        this.fnMakeNavi(this.ObjectName);
    },
	renderPageSizeControl: function(){
		var objectName = (this.listData.objectName) ? this.listData.objectName : '';
		var callbackName = (this.listData.callbackName) ? this.listData.callbackName : '';
		
		if (typeof objectName == 'undefined' || objectName == '') return false;
		
		var cn = (typeof callbackName == 'undefined') ? '' : callbackName;
		
		var pageSizeOption = (this.listData.pageSizeOption) ? this.listData.pageSizeOption : this._pageSizeOption;
		var optionArry = pageSizeOption.split(',');
		var optionStr = '';
		
		$.each(optionArry, function(idx, el){
			optionStr += '<option value="'+el+'">'+el+'</option>';
		});
		
		var selectID = this.ObjectName+"_selectPageSize";
		$(document.getElementById("custom_navi_" + this._targetID)).prepend(
			"<select id=\""+selectID+"\" class=\"AXSelect\" style=\"float: left; margin-top: 15px;\">"+
				optionStr+
			"</select>"
		);
		
		$(document.getElementById(selectID))
			.val(this.page.pageSize)
			.attr("onchange", "javascript:"+objectName+".changePageSize(this,'"+cn+"');");
	},
    changePageSize: function(target, callbackName){
		if (typeof target == 'undefined' || target.value == '' || isNaN(target.value)) return false;
		
		this.page.pageSize = Number(target.value);
		
		if (typeof callbackName != 'undefined' && callbackName != '' && target.value != ''){
			var callback = new Function(callbackName+'()');
			callback();
		}
	},
	bindEvent:function(bReload){
		//tab 설정시 grid event 재설정
		if (bReload){
			let cfg = this.config;

		    this.gridFocus = axdom("#" + cfg.targetID + "_AX_grid_focus");
	        this.gridBody = axdom("#" + cfg.targetID + "_AX_grid");
	        this.scrollBody = axdom("#" + cfg.targetID + "_AX_gridScrollBody");
	        this.colHead = axdom("#" + cfg.targetID + "_AX_gridColHead");
	        this.body = axdom("#" + cfg.targetID + "_AX_gridBody");

	        this.scrollTrackY = axdom("#" + cfg.targetID + "_AX_scrollTrackY");
	        this.scrollYHandle = axdom("#" + cfg.targetID + "_AX_scrollYHandle");
	        this.scrollYTip = axdom("#" + cfg.targetID + "_AX_scrollY_AX_tip");
	        this.scrollYTipSpan = axdom("#" + cfg.targetID + "_AX_scrollY_AX_tip").find("span");
	        this.scrollTrackX = axdom("#" + cfg.targetID + "_AX_scrollTrackX");
	        this.scrollXHandle = axdom("#" + cfg.targetID + "_AX_scrollXHandle");

	        this.editor = axdom("#" + cfg.targetID + "_AX_gridEditor");

	        this.pageBody = axdom("#" + cfg.targetID + "_AX_gridPageBody");
	        this.pageBody.data("display", "show");
	        this.pagingUnit = axdom("#" + cfg.targetID + "_AX_gridPagingUnit");
	        this.status = axdom("#" + cfg.targetID + "_AX_gridStatus");
	        this.scrollContent = axdom("#" + cfg.targetID + "_AX_scrollContent");
	        //this.scroller = axdom("#" + cfg.targetID + "_AX_gridScroller");

	        /* define part --------------------------------- */
	        this.defineConfig();
	        
			this.cachedDom.tbody = axdom("#" + cfg.targetID + "_AX_tbody");
	        if (this.hasFixed) this.cachedDom.fixed_tbody = axdom("#" + cfg.targetID + "_AX_fixedTbody");
	        this.cachedDom.thpadding = axdom("#" + cfg.targetID + "_AX_hpadding").find("td");
	        this.cachedDom.tfpadding = axdom("#" + cfg.targetID + "_AX_fpadding").find("td");
	        if (this.hasFixed) {
	            this.cachedDom.fthpadding = axdom("#" + cfg.targetID + "_AX_fhpadding").find("td");
	            this.cachedDom.ftfpadding = axdom("#" + cfg.targetID + "_AX_ffpadding").find("td");
	        }
	         
	         this.body.find(".gridBodyTr").bind("mouseover", this.gridBodyOver.bind(this));
	         this.body.find(".gridBodyTr").bind("mouseout", this.gridBodyOut.bind(this));
	         this.body.find(".gridBodyTr:not(.gridBodyMarker)").bind("click", this.gridBodyClick.bind(this));
	         if (this.needBindDBLClick()) this.body.find(".gridBodyTr").bind("dblclick", this.gridBodyDBLClick.bind(this));
		}
		         
        var pagemovefunc = function (pObj) {
        	/*스크롤 위치 변경 */
        	if (pObj.config.viewMode != "mobile") {

                var scrollTop = 0;
                pObj.scrollContent.css({top: scrollTop});
                pObj.contentScrollContentSync({top: scrollTop});

                if (pObj.pageActive && pObj.ajaxInfo) {
                	pObj.setList(pObj.ajaxInfo, pObj.ajax_sortDisable, null, "paging");
                	pObj.contentScrollResize();
                }
            }
            else {
                if (pObj.pageActive && pObj.ajaxInfo) {
                	pObj.setList(pObj.ajaxInfo, pObj.ajax_sortDisable, null, "paging");
                }
            }
        }
        
        $(".AXPaging_begin").bind("click",function (event) {
        	event.stopImmediatePropagation();
        	this.page.pageNo = 1;
        	pagemovefunc(this);
        }.bind(this));
        
        $(".AXPaging_prev").click(function (event) {
        	event.stopImmediatePropagation();
        	this.page.pageNo = this.page.pageNo > 1 ? this.page.pageNo - 1 : 1;
        	pagemovefunc(this);
        }.bind(this));
        
        var obj = this;
        $(".AXPaging").each(function () {
        	$(this).click(function () { 
                var thisobjname =$(this).parents("div").parents("div").parents("div").parents("div").attr("id");
                
                if(obj.ObjectName==thisobjname){
                 obj.page.pageNo = $(this).attr("value");           
                    pagemovefunc(obj);
                   }             
             });     
        });
        
        $(".AXPaging_next").click(function (event) {
        	event.stopImmediatePropagation();
        	this.page.pageNo = this.page.pageNo < this.page.pageCount ? this.page.pageNo + 1 : this.page.pageCount;
        	pagemovefunc(this);
        }.bind(this));
        
        $(".AXPaging_end").click(function (event) {
        	event.stopImmediatePropagation();
        	this.page.pageNo = this.page.pageCount;
        	pagemovefunc(this);
        }.bind(this));
        
	}
});

//////////////////////////////CoviInput///////////////////////////////////////////////
/**
 * coviInput
 * @class coviInput
 */
var coviInput = {
	init : function(){
		this.setInputPattern();
		this.setNumber();
		this.setMoney();
		this.setSwitch();
		this.setSlider();
		this.setTwinSlider();
		this.setDate();
		this.setDictionary();
	},
	setInputPattern : function() {
		/* input box */
		/* net.sf.json 미사용됨에 따라 아래 로직은 미사용처리. 22.9 hgsong
		$("input[type='text'][json-value!='true'],textarea[json-value!='true']").each(function(){
			$(this).focusout(function(){
				var $this = $(this);
				try{
					if(typeof JSON.parse($this.val()) == 'object'){
						$this.val('');
						Common.Warning(Common.getDic("ACC_032"), "Warning", function(){
							$this.focus();
						});	//형식이 올바르지 않습니다.
						
					}
				}catch(e){ 	//JSON 형식이 아닐 경우 
					if($this.val().charAt(0)=="[" && $this.val().charAt($this.val().length-1) == "]" && ($.isNumeric($this.val().charAt(1)) || $this.val().charAt(1) =="." )){ 
						//net.sf.json 라이브러리가 [로 시작 ]로 끝나고 [다음 글자가 숫자또는 .면 JSON 으로 인식하는 현상 방지
						$this.val('');
						Common.Warning(Common.getDic("ACC_032"), "Warning", function(){
							$this.focus();
						});	//형식이 올바르지 않습니다.
					}
				}
			})
		});
		*/
		$("input[mode=money]").each(function(){
			$(this).bindPattern({
				pattern : "money",
				allow_minus : ($(this).attr("allow_minus") == "true" ? true : false),
				max_length : parseFloat($(this).attr("max_length")),
				max_round : parseFloat($(this).attr("max_round"))
			})
		});
		$("input[mode=moneyint]").each(function(){
			$(this).bindPattern({
				pattern : "moneyint",
				max_length : parseFloat($(this).attr("max_length"))
			})
		});
		$("input[mode=number]").each(function(){
			$(this).bindPattern({
				pattern : "number",
				allow_minus : ($(this).attr("allow_minus") == "true" ? true : false),
				max_length : parseFloat($(this).attr("max_length")),
				max_round : parseFloat($(this).attr("max_round")),
				num_max : parseFloat($(this).attr("num_max")), // 2016-11-07 안기현 추가
				num_min : parseFloat($(this).attr("num_min")) // 2016-11-07 안기현 추가
			})
		});
		$("input[mode=numberint]").each(function(){
			$(this).bindPattern({
				pattern : "numberint",
				max_length : parseFloat($(this).attr("max_length")),
				num_max : parseFloat($(this).attr("num_max")), // 2016-11-07 안기현 추가
				num_min : parseFloat($(this).attr("num_min")) // 2016-11-07 안기현 추가
			})
		});
		$("input[mode=date]").each(function(){
			$(this).bindPattern({
				pattern : "date"
			})
		});
		$("input[mode=date-ymd]").each(function(){
			$(this).bindPattern({
				pattern : "date(년월일)"
			})
		});
		$("input[mode=datetime]").each(function(){
			$(this).bindPattern({
				pattern : "datetime"
			})
		});
		$("input[mode=time]").each(function(){
			$(this).bindPattern({
				pattern : "time"
			})
		});
		$("input[mode=date-slash]").each(function(){
			$(this).bindPattern({
				pattern : "date(/)"
			})
		});
		$("input[mode=datetime-ymd]").each(function(){
			$(this).bindPattern({
				pattern : "datetime(년월일)"
			})
		});
		$("input[mode=custom]").each(function(){
			$(this).bindPattern({
				pattern : "custom",
				max_length : parseFloat($(this).attr("max_length")),
				patternString : $(this).attr("patternString")
			})
		});
		$("input[mode=bizno]").each(function(){
			$(this).bindPattern({
				pattern : "bizno"
			})
		});
		$("input[mode=phone]").each(function(){
			$(this).bindPattern({
				pattern : "phone"
			})
		});
	},
	
	/* Number */
	setNumber : function(){
		$("input[kind=number]").each(function(){
			$(this).bindNumber({
				max : parseFloat($(this).attr("num_max")),
				min : parseFloat($(this).attr("num_min"))
			})
		});
	},
	
	setMoney : function(){
		$("input[kind=money]").each(function(){
			$(this).bindMoney({
				max : parseFloat($(this).attr("money_max")),
				min : parseFloat($(this).attr("money_min"))
			})
		});
	},
	
	/* Switch */
	setSwitch : function(pReadOnly){
		$("input[kind=switch]").each(function(){
			$(this).bindSwitch({
				off : ($(this).attr("off_value")),
				on : ($(this).attr("on_value")),
				//readonly : pReadOnly == true ? true : false
				readonly : typeof ($(this).attr("readonly_Fg")) == "undefined" ? false : ($(this).attr("readonly_Fg"))
			})
		});
	},
	
	/* Slider */
	setSlider : function(){
		$("input[kind=slider]").each(function(){
			$(this).bindSlider({
				min : parseFloat($(this).attr("slider_min")),
				max : parseFloat($(this).attr("slider_max")),
				snap : parseFloat($(this).attr("snap")),
				unit : $(this).attr("unit")
			})
		});
	},
	
	setTwinSlider : function(){
		$("input[kind=twinslider]").each(function(){
			$(this).bindTwinSlider({
				min : parseFloat($(this).attr("twslider_min")),
				max : parseFloat($(this).attr("twslider_max")),
				snap : parseFloat($(this).attr("snap")),
				unit : $(this).attr("unit"),
				separator : $(this).attr("separator")
			})
		});
	},
	
	//다국어 이벤트 세팅
	setDictionary : function(){
		$("input[kind='dictionary']").each(function(){
			$(this).click(function(){
				var pInitData = $(this).val();
				var dicCallback = "CFN_setDic" ;// $(this).attr("id")+"Dic_CallBack";
				
				if($(this).attr("dic_src") != undefined){
					if ($("#"+$(this).attr("dic_src")).val() != '') pInitData= $("#"+$(this).attr("dic_src")).val();
				} 
				
				if($(this).attr("dic_callback") != undefined){
					dicCallback=$(this).attr("dic_callback");
				} 
						
				
				var option = {
						lang : Common.getSession("lang"),
						hasTransBtn : 'true',
						allowedLang : 'ko,en,ja,zh',
						useShort : 'false',
						dicCallback : dicCallback,
						popupTargetID : 'DictionaryPopup',
						initData : pInitData,
						dicID : $(this).attr("id")
					};
					
				coviCmn.openDicLayerPopup(option,"");
			})
		});
		$("a[kind='dictionaryBtn']").each(function(){
			$(this).click(function(){
				$('#'+$(this).attr("src_elem")).trigger('click');
			})
		});
		
		
	},
	
	/* Segment Method */
	/**
	 * setSegment
	 * @method setSegment
	 * @param id - HTML Element target ID
	 * @param option - 바인드될 데이터. [{optionValue:0, optionText:"왼쪽"}, ... ]
	 */
	setSegment : function(id, option){
		$("#"+id).bindSegment({
			options : option
		});
	},
	
	/**
	 * setCssSegment
	 * @method setCssSegment
	 * @param id - HTML Element target ID
	 * @param theme_name - css 파일 안에서 적용될 style name
	 * @param option - 바인드될 데이터. [{optionValue:0, optionText:"왼쪽", addClass:"type1"}, ... ]
	 * @param css_name - 사용자 지정 css 파일명. (해당 파일의 위치 url 포함)
	 */
	setCssSegment : function(id, theme_name, option, css_name){
		var head = document.getElementsByTagName('head')[0];
		var link = document.createElement('link');
		link.type = "text/css";
		link.rel = "stylesheet";
		link.href = css_name;
		
		head.appendChild(link);
		
		$("#"+id).bindSegment({
			theme : theme_name,
			options : option
		});
	},
	
	/* Selector Method */
	/**
	 * SimpleBindSelector
	 * @method SimpleBindSelector
	 * @param id - HTML Element target ID
	 * @param appendable - option에 정해진 값 외의 입력 가능 여부. [true | false]
	 * @param option - 바인드될 데이터. [{optionValue:1, optionText:"Seoul"}, ... ]
	 * @param positionfixed - expandBox position CSS 를 fixed 할지 여부. selector 가 fixed 된 엘리먼트 위에 위치하는 경우 사용. [true | false]
	 * @param direction - expandBox의 위/아래 열리는 방향을 지정. 기본값은 ""이며 "bottom"을 사용하는 경우 expandBox의 방향이 밑에서 위로 열리게 됨
	 * @param finder - finder 버튼 사용 여부. [true | false]
	 * @param finder_onclick - finder 버튼 클릭 이벤트 함수
	 */
	SimpleBindSelector : function(id, appendable, option, positionfixed, direction, finder, finder_onclick){
		
		if(finder == true){
			$("#"+id).bindSelector({
				appendable : appendable,
				options : option,
				positionFixed : positionfixed,
				direction : direction,
				finder : {
					onclick: function(){
						if($.isFunction(finder_onclick)){
							finder_onclick.apply(this);
						}else{
							if(finder_onclick != ""){
								window[finder_onclick].apply(this);
							}
						}
					}
				}
			});
		}else{
			$("#"+id).bindSelector({
				appendable : appendable,
				options : option,
				positionFixed : positionfixed,
				direction : direction
			});
		}
	},
	
	/**
	 * AjaxBindSelector
	 * @method AjaxBindSelector
	 * @param id - HTML Element target ID
	 * @param appendable - option에 정해진 값 외의 입력 가능 여부. [true | false]
	 * @param positionfixed - expandBox position CSS 를 fixed 할지 여부. selector 가 fixed 된 엘리먼트 위에 위치하는 경우 사용. [true | false]
	 * @param direction - expandBox의 위/아래 열리는 방향을 지정. 기본값은 ""이며 "bottom"을 사용하는 경우 expandBox의 방향이 밑에서 위로 열리게 됨
	 * @param url - AJAX 데이터 호출 URL
	 * @param param - AJAX 데이터 호출 URL 파라미터
	 */
	AjaxBindSelector : function(id, appendable, positionfixed, direction, url, param){
		$("#"+id).bindSelector({
			appendable: appendable,
			positionFixed : positionfixed,
			direction : direction,
			ajaxUrl : url,
			ajaxPars: param
		});
	},
	
	/**
	 * MultiSelector
	 * @method MultiSelector
	 * @param id - HTML Element target ID
	 * @param options - 바인드될 데이터. [{name:"opt1", width:200, options:[{optionValue:1, optionText:"Seoul"}, ... ]}, ... ]
	 */
	MultiSelector : function(id, options){
		var myMultiSelector = new AXMultiSelector();
		myMultiSelector.setConfig({
			targetID : id,
			optionGroup: options
		});
	},
	
	/**
	 * UserBindSelector
	 * @method UserBindSelector
	 * @param id - HTML Element target ID
	 * @param appendable - option에 정해진 값 외의 입력 가능 여부. [true | false]
	 * @param positionfixed - expandBox position CSS 를 fixed 할지 여부. selector 가 fixed 된 엘리먼트 위에 위치하는 경우 사용. [true | false]
	 * @param direction - expandBox의 위/아래 열리는 방향을 지정. 기본값은 ""이며 "bottom"을 사용하는 경우 expandBox의 방향이 밑에서 위로 열리게 됨
	 * @param optionvalue - 바인드된 데이터의 사용자 지정 value 명
	 * @param optiontext - 바인드된 데이터의 사용자 지정 text 명
	 * @param opion - 바인드될 데이터. [{CD:1, NM:"Seoul"}, ... ]
	 */
	UserBindSelector : function(id, appendable, positionfixed, direction, optionvalue, optiontext, option){
		$("#"+id).bindSelector({
			positionFixed : positionfixed,
			direction : direction,
			reserveKeys: {
				optionValue: optionvalue,
				optionText : optiontext
			},
			appendable : appendable,
			onsearch : function(objID, objVal, callBack) {
				setTimeout(function(){
					callBack({
						options: option
					});
					// return {options : option}
				}, 100);
			}
		});
	},
	
	/* TagSelector Method */
	/**
	 * SimpleBindTagSelector
	 * @method SimpleBindTagSelector
	 * @param id - HTML Element target ID
	 * @param opion - 바인드될 데이터. [{optionValue:1, optionText:"Seoul"}, ... ]
	 * @param appendable - option에 정해진 값 외의 입력 가능 여부. [true | false]
	 * @param direction - expandBox의 위/아래 열리는 방향을 지정. 기본값은 ""이며 "bottom"을 사용하는 경우 expandBox의 방향이 밑에서 위로 열리게 됨
	 * @param selectorWidth - selectorWidth 값이 없으면 인풋의 너비를 이용.
	 * @param optionValue_hname - 태그가 추가될 때 생성되는 optionValue input hidden name값
	 * @param optionText_hname - 태그가 추가될 때 생성되는 optionText input hidden name값
	 */
	SimpleBindTagSelector : function(id, option, appendable, direction, selectorWidth, optionValue_hname, optionText_hname){
		$("#"+id).bindTagSelector({
			appendable : appendable,
			direction : direction,
			selectorWidth: selectorWidth,
			optionValue_inputName: optionValue_hname,
			optionText_inputName: optionText_hname,
			options: option
		});
	},
	
	/**
	 * AjaxBindTagSelector
	 * @method AjaxBindTagSelector
	 * @param id - HTML Element target ID
	 * @param appendable - option에 정해진 값 외의 입력 가능 여부. [true | false]
	 * @param direction - expandBox의 위/아래 열리는 방향을 지정. 기본값은 ""이며 "bottom"을 사용하는 경우 expandBox의 방향이 밑에서 위로 열리게 됨
	 * @param url - AJAX 데이터 호출 URL
	 * @param param - AJAX 데이터 호출 URL 파라미터
	 */
	AjaxBindTagSelector : function(id, appendable, direction, url, param){
		$("#"+id).bindTagSelector({
			appendable : appendable,
			direction : direction,
			ajaxUrl : url,
			ajaxPars : param
		});
	},
	
	/**
	 * UserBindTagSelector
	 * @method UserBindTagSelector
	 * @param id - HTML Element target ID
	 * @param opion - 바인드될 데이터. [{VL:1, TX:"Seoul"}, ... ]
	 * @param appendable - option에 정해진 값 외의 입력 가능 여부. [true | false]
	 * @param direction - expandBox의 위/아래 열리는 방향을 지정. 기본값은 ""이며 "bottom"을 사용하는 경우 expandBox의 방향이 밑에서 위로 열리게 됨
	 * @param selectorWidth - selectorWidth 값이 없으면 인풋의 너비를 이용.
	 * @param optionValue_hname - 태그가 추가될 때 생성되는 optionValue input hidden name값
	 * @param optionText_hname - 태그가 추가될 때 생성되는 optionText input hidden name값
	 * @param optionvalue - 바인드된 데이터의 사용자 지정 value 명
	 * @param optiontext - 바인드된 데이터의 사용자 지정 text 명
	 */
	UserBindTagSelector : function(id, option, appendable, direction, selectorWidth, optionValue_hname, optionText_hname, optionvalue, optiontext){
		$("#"+id).bindTagSelector({
			appendable : appendable,
			direction : direction,
			selectorWidth: selectorWidth,
			optionValue_inputName: optionValue_hname,
			optionText_inputName: optionText_hname,
			 reserveKeys: {
				 optionValue: optionvalue,
				 optionText: optiontext
			 },
			onsearch: function(objID, kword, callBack){
				callBack(option);
				/*
				return option;
				*/
			}
		});
	},
	
	/* Validator Method */
	/**
	 * setValidator
	 * @method setValidator
	 * @param formname - validation이 적용될 form name
	 * @param required_msg - 필수체크할 경우 나타나는 alert창의 메시지
	 * @return [true | false] - validation check를 했을 때 잘못된 input 이 있을 경우 false를 반환
	 */
	setValidator : function(formname, required_msg){
		var objValidator = new AXValidator();
		objValidator.setConfig({
			targetFormName : formname
		});
		if(required_msg == undefined) {
			required_msg = "은(는) 필수 입력값입니다.";
		 }
		
		var alertmsg = "";
		var validateResult = objValidator.validate();
		if (!validateResult) {
			
			AXConfig.AXValidator.validateErrMessage.required = objValidator.getErrorElement()[0].name + required_msg;
			alertmsg = objValidator.getErrorMessage();
			
			AXUtil.alert(alertmsg);
			objValidator.getErrorElement().focus();
			
			return false;
		}else{
			return true;
		}
	},
	
	/* Date */
	setDate : function(){
		$("input[kind=date]").each(function(){
			$(this).bindDate({
				align : $(this).attr("date_align"),
				valign : $(this).attr("date_valign"),
				separator : $(this).attr("date_separator"),
				selectType : $(this).attr("date_selectType"),
				defaultSelectType: $(this).attr("date_defaultSelectType"),
				defaultDate : $(this).attr("defaultDate"),
				minDate : $(this).attr("minDate"),
				maxDate : $(this).attr("maxDate"),
				onBeforeShowDay : function(date){
					var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
					if(fnStr != null && fnStr != ""){
						return coviCmn.callFnBasedNamespace(fnStr, [date]);
					}
				}
			});
			if($(this).attr("vali_early") == "true"){
				$(this).setConfigInput({
					onChange:{
						earlierThan:$(this).attr("vali_date_id"), err:"시작일을 종료일의 이전으로 선택하세요"
	                }
				});
			}else if($(this).attr("vali_late") == "true"){
				$(this).setConfigInput({
					onChange : {
	                    laterThan:$(this).attr("vali_date_id"), err:"종료일을 시작일의 이후로 선택하세요"
	                }
				});
			}
		});
		
		$("input[kind=datetime]").each(function(){
			$(this).bindDateTime({
				align : $(this).attr("date_align"),
				valign : $(this).attr("date_valign"),
				separator : $(this).attr("date_separator"),
				selectType : $(this).attr("date_selectType"),
				defaultSelectType: $(this).attr("date_defaultSelectType"),
				defaultDate : $(this).attr("defaultDate"),
				minDate : $(this).attr("minDate"),
				maxDate : $(this).attr("maxDate"),
				onBeforeShowDay : function(date){
					var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
					if(fnStr != null && fnStr != ""){
						return coviCmn.callFnBasedNamespace(fnStr, [date]);
					}
				}
			});
			if($(this).attr("vali_early") == "true"){
				$(this).setConfigInput({
					onChange:{
						earlierThan:$(this).attr("vali_date_id"), err:"시작일을 종료일의 이전으로 선택하세요"
	                }
				});
			}else if($(this).attr("vali_late") == "true"){
				$(this).setConfigInput({
					onChange : {
	                    laterThan:$(this).attr("vali_date_id"), err:"종료일을 시작일의 이후로 선택하세요"
	                }
				});
			}
		});
		$("input[kind=twindate]").each(function(){
			$(this).bindTwinDate({
				startTargetID : $(this).attr("date_startTargetID"),
				align : $(this).attr("date_align"),
				valign : $(this).attr("date_valign"),
				separator : $(this).attr("date_separator"),
				selectType : $(this).attr("date_selectType"),
				defaultSelectType: $(this).attr("date_defaultSelectType"),
				defaultDate : $(this).attr("defaultDate"),
				minDate : $(this).attr("minDate"),
				maxDate : $(this).attr("maxDate"),
				buttonText : $(this).attr("date_buttonText"),
				onBeforeShowDay : function(date){
					var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
					if(fnStr != null && fnStr != ""){
						return coviCmn.callFnBasedNamespace(fnStr, [date]);
					}
				}
			})
		});
		$("input[kind=twindatetime]").each(function(){
			$(this).bindTwinDateTime({
				startTargetID : $(this).attr("date_startTargetID"),
				align : $(this).attr("date_align"),
				valign : $(this).attr("date_valign"),
				separator : $(this).attr("date_separator"),
				selectType : $(this).attr("date_selectType"),
				defaultSelectType: $(this).attr("date_defaultSelectType"),
				defaultDate : $(this).attr("defaultDate"),
				minDate : $(this).attr("minDate"),
				maxDate : $(this).attr("maxDate"),
				buttonText : $(this).attr("date_buttonText"),
				onBeforeShowDay : function(date){
					var fnStr = $("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay");
					if(fnStr != null && fnStr != ""){
						return coviCmn.callFnBasedNamespace(fnStr, [date]);
					}
				}
			})
		});
	},
	/*IE Input Focus Error 임시 대응 코드 */
	makeFocus : function(){
		var t = document.createElement("textarea");
		document.body.appendChild(t);
		t.value = '';
		t.select();
		document.body.removeChild(t);
	}
};

$(window).load(function(){
	/*
	 * bind 되는 시점 상의 문제가 있음
	 * 먼저 bind되어 버리면 위치가 뒤로 밀림
	 * 임시로 지연 로드 시켜 봄
	 * 2500->250 timeout 속도 재지정 (8/17 kimhy2)
	 * */
	
	setTimeout(function() { coviInput.init(); }, 250);
	//coviInput.init();
	
	
	/*
	coviInput.setInputPattern();
	coviInput.setNumber();
	coviInput.setMoney();
	coviInput.setSwitch();
	coviInput.setSlider();
	coviInput.setTwinSlider();
	coviInput.setDate();
	*/
});

addEventListener("resize", function(){		// 윈도우 리사이즈 시 coviInput 재설정
	coviInput.init();
});

/**
 * coviTree
 * @class coviTree
 * @extends AXTree
 */

var coviTree= Class.create(AXTree, {
	
	/**
	 * setTreeList
	 * @method setTreeList
	 * @param pid - HTML element target ID
	 * @param data - tree date
	 * @param nodeName - data에서 title node 명
	 * @parma col_width - tree width
	 * @param col_align - tree align
	 * @param IsCheck - tree list의 checkbox 여부
	 * @param IsRadio - tree list의 radiobox 여부
	 * @param iconClass - tree list icon class명(생략가능)
	 * @param theme - tree class명(생략가능)
	 */
	setTreeList: function(pid, data, nodeName, col_width, col_align, IsCheck, IsRadio, body, iconClass, theme){
		var colGroup = [{
			key: nodeName,			// 컬럼에 매치될 item 의 키
			//label:"TREE",				// 컬럼에 표시할 라벨
			width: col_width,
			align: col_align,				// left
			indent: true,					// 들여쓰기 여부
			getIconClass: function(){		// indent 속성 정의된 대상에 아이콘을 지정 가능
				var iconNames = "folder, AXfolder, movie, img, zip, file, fileTxt, company".split(/, /g);
				var iconName = "";
				if(iconClass){
					iconName = iconClass;
				}else if(typeof this.item.type == "number") {
					iconName = iconNames[this.item.type];
				} else if(typeof this.item.type == "string"){
					if(this.item.FolderType == "Root" || this.item.FolderType == "DocRoot" || this.item.FolderType == "Folder") {
						iconName = this.item.type.toLowerCase();
					} else {
						iconName = "fileTxt";
					}
				} 
				return iconName;
			},
			formatter:function(){
				var anchorName = $('<a />').attr('id', 'folder_item_'+this.item.no);
				anchorName.text(this.item.nodeName);
				
				if(this.item.url != "" && this.item.url != undefined){
					anchorName.attr('href', this.item.url);
				}
				if(this.item.onclick != "" && this.item.onclick != undefined){
					anchorName = $('<div />').attr('onclick', this.item.onclick).append(anchorName);
				}
				if(this.item.type != undefined) { //전결규정 트리 관련 : e-Accounting용 전결규정 type 속성 추가
					if(this.item.type == "") this.item.type = "APPROVAL";
					anchorName.attr('type', this.item.type);
					anchorName.attr('data-menu-id', "commu_"+this.item.no);
					anchorName.attr('display-name', this.item.nodeName);
					if(this.item.type == "ACCOUNT" && this.item.pno != "1") {
						var moneyStr = "";
						if(this.item.MaxAmount.split(".")[0] != "0") {
							moneyStr = " ~" + CFN_AddComma(this.item.MaxAmount.split(".")[0]) + " " + Common.getDic("lbl_below");	
						}
						anchorName.text(this.item.nodeName + " " + moneyStr);
					}
				}
				
				var str = anchorName.prop('outerHTML');
				if(IsCheck){
					str = func.covi_setCheckBox(this.item) + str;
				}
				if(IsRadio){
					str = func.covi_setRadio(this.item) + str;
				}
				
				return str;
			}
		}];
				
		var func = { 		// 내부에서 필요한 함수 정의
			covi_setCheckBox : function(item){		// checkbox button
				if(item.chk == "Y"){
					return "<input type='checkbox' id='"+pid+"_treeCheckbox_"+item.no+"' name='treeCheckbox_"+item.no+"' value='"+Object.toJSON(item).replaceAll("'", "&#39;")+"' />";
				}else if(item.chk == "N"){
					return "";
				}else{
					return "";
				}
			},
			covi_setRadio : function(item){			// radio button
				if(item.rdo == "Y"){
					return "<input type='radio' id='"+pid+"_treeRadio_"+item.no+"' name='treeRadio' value='"+Object.toJSON(item).replaceAll("'", "&#39;")+"' />";
				}else if(item.rdo == "N"){
					return "";
				}else{
					return "";
				}
			}
		};
		
		this.setTreeConfig(pid, "pno", "no", false, false, colGroup, body, theme);
		this.setList(data);
	},
	
	/**
	 * setTreeConfig
	 * @method setTreeConfig
	 * @param pid - HTML element target ID
	 * @param parentkey - parent node의 child key
	 * @param childkey - tree node의 number 
	 * @param cookie_expand - 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
	 * @param cookie_select - 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
	 * @param colGroup - tree 헤드 정의 값
	 * @param body - 이벤트 콜벡함수 정의 값
	 * @param theme - tree class명(생략가능)
	 */
	setTreeConfig : function(pid, parentkey, childkey, cookie_expand, cookie_select, colGroup, body, theme){
		if(!theme) theme = "AXTree_none";
		this.setConfig({
			targetID : pid,					// HTML element target ID
			theme: theme,		// css style name (AXTree or AXTree_none)
			showConnectionLine:true,		// 점선 여부
			relation:{
				parentKey: parentkey,		// 부모 아이디 키
				childKey: childkey			// 자식 아이디 키
			},
			persistExpanded: cookie_expand,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
			persistSelected: cookie_select,			// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
			colGroup:colGroup,						// tree 헤드 정의 값
			body:body									// 이벤트 콜벡함수 정의 값
		});
	},
	
	/**
	 * setappendTree
	 * @method setappendTree
	 * @param data - 추가할 item
	 */
	setAppendTree : function(data){
		var obj = this.getSelectedList();						// 현재 선택된 item
		this.appendTree(obj.index, obj.item, data);		// 해당 item의 하위 노드에 추가
	},
	
	/**
	 * getCheckedTreeList
	 * @method getCheckedTreeList
	 * @param inputType - input 타입. checkbox | radio
	 */
	getCheckedTreeList : function(inputType){
		var collect = [];
		var list = this.list;
		
		this.body.find("input[type="+inputType+"]").each(function(){
			var arr = this.id.split('_'); 
			if($(this).prop("checked") && (arr[1] == "treeCheckbox" || arr[1]== "treeRadio")){
				var itemIndex = this.id.replace(arr[0]+ "_" + arr[1] + "_", "");
				for(var i=0; i < list.length; i++)
					if(list[i].no == itemIndex)
						collect.push(list[i]);
			}
		});
		return collect;
	},
	
	//[2016-11-15] 
	//inputType: Checkbox or radio 
	//nodeValue: 체크여부를 설정할 트리 요소의 nodeValue
	//value: 체크여부 (true or false)
	setCheckedObj : function(inputType, nodeValue, value){
		var list = this.list;
		var target = this.config.targetID;
		
		$.each(list, function(idx,obj){
			if(obj.nodeValue==nodeValue){
				if(inputType.toUpperCase()=="CHECKBOX"){
					$("input:checkbox[id="+target+"_treeCheckbox_"+obj.no+"]").prop("checked",value);
				}else if(inputType.toUpperCase()=="RADIO"){
					$("input:radio[id="+target+"_treeRadio_"+obj.no+"]").prop("checked",value);
				}
			}
		});
		
	},
	displayIcon:function(value){
		if(value){
			$("[id^='"+this.config.targetID+"_AX_bodyNodeIcon']").css("display","block");
		}else{
			$("[id^='"+this.config.targetID+"_AX_bodyNodeIcon']").css("display","none");
		}
	},
	/**
	 * gridCheckClick : Tree 형 Grid 에서 체크박스를 check 했을 경우 상위 노드 혹은 하위 노드까지 다 선택되는 것을 막기 위해 빈 내용의 함수로 다시 정의
	 */
	gridCheckClick: function (event, tgId) {},
	
	callExpandAllTree: function(id, IsExpand){
		var itemIndex = new Array();
		var treeObj = this.tree;
			
		this.body.find("#"+id+"_AX_tbody tr").each(function(){
			itemIndex.push($(this)[0].id.replace("folder_item_", ""));
		});
		//trace(itemIndex);
		
		this.expandAllTree(itemIndex, treeObj, 0, IsExpand);
	},
	
	expandAllTree : function(itemIndex, obj, startCnt, IsExpand){
		var cnt = startCnt;
		for(var i=0; i< obj.length; i++){
			if(obj[i].__subTree != false && obj[i].open != IsExpand)
				this.expandToggleList(itemIndex[cnt], obj[i], IsExpand);
			cnt ++;
			if(obj[i].subTree.length > 0){
				//trace(obj[i].hash);
				cnt = this.expandAllTree(itemIndex, obj[i].subTree, cnt, IsExpand);
			}
		}
		return cnt;
	},
	findKeyword:function(filterCol, keyword, bMsg, bClick ){
		this.collapseAll();
		var gridObj = this;
		var targetID = gridObj.config.targetID;
		var bFind = false;
		$( this.list ).each( function(idx, v) {
			if (v[filterCol].indexOf(keyword)>=0){
				var focusItem = gridObj.click(idx, "open", bClick==undefined?true:bClick); // 아이템 확장처리만 원함.
				bFind = true;
			}
		});
		
		if (bMsg == true && bFind == false){
			Common.Inform(Common.getDic("msg_apv_112"));

		}
	},
	findKeywordData:function(filterCol, keyword, bMsg, bClick, curIdx){
		var gridObj = this;
		var targetID = gridObj.config.targetID;
		var bFind = false;
		
		// curIdx : 현재 선택된 트리 데이터의 인덱스 
		curIdx = curIdx>gridObj.list.length-1 || curIdx===undefined ? 0:curIdx; 
		// curIdx가 마지막 데이터 인덱스일 때, 값이 0이 되는 오류 수정 (22.08.29 연구2팀 임준혁)

		for(var i=0;i<gridObj.list.length;i++){
			var item = this.list[curIdx];
			if (item[filterCol].indexOf(keyword)>=0){
				var focusItem = gridObj.click(curIdx, "open", bClick==undefined?true:bClick);
				// "open" : 아이템 개체 확장 후 선택, "expand" : 아이템 개체 확장만
				// bClick : 아이템 개체 확장 처리 후, 클릭 이벤트 발생 방지 : true 개체 확장만, false 확장 후 선택
				bFind = true;
				break;
			}
			curIdx = (curIdx>=gridObj.list.length-1)?0:curIdx+1;
			// 검색조건에 해당하는 데이터가 없는 경우, curIdx 값 증가 curIdx가 마지막 인덱스이면 0으로 값 변경
		}
		if (bMsg == true && bFind == false){
			Common.Inform(Common.getDic("msg_apv_112"));
		}
	}
});



// --------------------------------------------- 전자결재 첨부파일 컨트롤 -------------------------------------------------------
/**
 * 1. 개발지원에 있는 첨부파일 컨트롤 HTML 사용
 * 2. 스크립트단은 아래 함수들로 실행됨
 * 3. 서버단에서는 개발지원에 있는 submit 함수를 이용해서 컨트롤에서 Request에 있는 MultipartFile 로 받아서 처리.
 * 4. 컨트롤에서는 FileUtil.fileUpload 함수이용해서 첨부파일 저장
 */


var l_aObjFileList = [];

// 파일추가 버튼
function AddFile() {
	// Iframe FileControl의 파일추가 버튼 클릭
	document.getElementById("FileSelect").click();
}

//전자결재 웹하드 첨부 
function AddWebhardFile(){
	var sUrl = "/webhard/user/popup/callWebhardAttachPopup.do?CLSYS=webhard&CLMD=user&CLBIZ=Webhard&callbackFunc=callBackAddWebhardFile&openType=approval";
	
	CFN_OpenWindow(sUrl, "", 1100, 600, "fix");
}


// Iframe의 파일 컨트롤 값이 입력될때(파일 선택 시)
function FileSelect_onchange() {
	// 파일 선택 시 파일명 중복 검사
	var nLength = document.getElementById("FileSelect").files.length;
	var oFileInfo = document.getElementById("FileSelect").files;
	var bCheck = false;
	var aObjFiles = [];
	var fileDisenableName = Common.getBaseConfig("DisenableFileName").split("|");
	var bFileCheck = false;
	var fileSize = 0;

	// 문서유통 첨부파일 용량 제한 7MB
	try {
		if(getInfo("SchemaContext.scDistribution.isUse") != undefined && getInfo("SchemaContext.scDistribution.isUse") == "Y"){		
			// 기존파일 사이즈의 합
			for(var i = 0; i< l_aObjFileList.length; i++){
				fileSize += l_aObjFileList[i].size
			}
	
			// 추가한 파일
			for (var j = 0; j < nLength; j++) {
				fileSize += oFileInfo[j].size
				if (fileSize>7340032) { // 7mb 넘음
					bFileCheck = true;
					parent.Common.Warning("외부공문서 파일은 총 7mb까지 첨부 가능합니다.");
					break;
				}
			}
		}
	} catch(e){coviCmn.traceLog(e)}
	
	for (var i = 0; i < nLength; i++) {
		for (var j = 0; j < l_aObjFileList.length; j++) {
			if (oFileInfo[i].name == l_aObjFileList[j].name) { // 중복됨
				bCheck = true;
				parent.Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
				break;
			} else { // 중복안됨
				bCheck = false;
			}
		}
		for (var k = 0; k < $("input[name=chkFile]").length; k++) {
			if (oFileInfo[i].name == $("input[name=chkFile]").eq(k).val().split(":")[1]) { // 중복됨
				bCheck = true;
				parent.Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
				break;
			} else { // 중복안됨
				bCheck = false;
			}
		}
		for (var l = 0; l < fileDisenableName.length; l++){
			if(fileDisenableName[l] != "" && oFileInfo[i].name.indexOf(fileDisenableName[l]) > -1){
				var warningComment = Common.getDic("msg_disenableFileName") + " " + fileDisenableName.join(", ");
				parent.Common.Warning(warningComment.substr(0, warningComment.length - 2));
				bCheck = true;
				break;
			}
		}
		if (!bCheck && !bFileCheck) {
			aObjFiles.push(oFileInfo[i]);
		}
	}
	readfiles(aObjFiles);
	SetFileInfo(aObjFiles);
	
	setSeqInfo();
}

function callBackAddWebhardFile(files){
	// 파일 선택 시 파일명 중복 검사
	var nLength = files.length;
	var oFileInfo = JSON.parse(JSON.stringify(files));// IE 는 팝업의 객체이므로 참조를 잃는다.
	var bCheck = false;
	var aObjFiles = [];
	var fileDisenableName = Common.getBaseConfig("DisenableFileName").split("|");

	for (var i = 0; i < nLength; i++) {
		oFileInfo[i].attachType = "webhard";
		oFileInfo[i].name = oFileInfo[i].FileName;
		oFileInfo[i].savedName = oFileInfo[i].SavedName;
		oFileInfo[i].size = oFileInfo[i].Size;
	}
	
	for (var i = 0; i < nLength; i++) {
		for (var j = 0; j < l_aObjFileList.length; j++) {
			if (oFileInfo[i].name == l_aObjFileList[j].name) { // 중복됨
				bCheck = true;
				parent.Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
				break;
			} else { // 중복안됨
				bCheck = false;
			}
		}
		for (var k = 0; k < $("input[name=chkFile]").length; k++) {
			if (oFileInfo[i].name == $("input[name=chkFile]").eq(k).val().split(":")[1]) { // 중복됨
				bCheck = true;
				parent.Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
				break;
			} else { // 중복안됨
				bCheck = false;
			}
		}
		for (var l = 0; l < fileDisenableName.length; l++){
			if(fileDisenableName[l] != "" && oFileInfo[i].name.indexOf(fileDisenableName[l]) > -1){
				var warningComment = Common.getDic("msg_disenableFileName") + " " + fileDisenableName.join(", ");
				parent.Common.Warning(warningComment.substr(0, warningComment.length - 2));
				bCheck = true;
				break;
			}
		}
		if (!bCheck) {
			aObjFiles.push(oFileInfo[i]);
		}
	}
	readfiles(aObjFiles);
	SetFileInfo(aObjFiles);
	
	setSeqInfo();
}

// onDragEnter Event
function onDragEnter(event) {
	event.preventDefault();
}

// onDragOver Event
function onDragOver(event) {
	event.preventDefault();
}

// Drop Event
function onDrop(event) {
	var aTempList = event.dataTransfer.files;
	var aObjFileList = new Array();

	event.stopPropagation();
	event.preventDefault();
	
	// 폴더 타입의 파일 제거
	for (var i = 0; i < aTempList.length; i++) {
		if (aTempList[i].name.indexOf('.') > -1 && aTempList[i].size != 0 && aTempList[i].size != 4096) {
			aObjFileList.push(aTempList[i]);
		}
	}

	// 파일 선택 시 파일명 중복 검사
	var nLength = aObjFileList.length;
	var oFileInfo = aObjFileList;
	var bCheck = false;
	var aObjFiles = [];
	var fileDisenableName = Common.getBaseConfig("DisenableFileName").split("|");
	var bFileCheck = false;
	var fileSize = 0;

	// 문서유통 첨부파일 용량 제한 7MB
	try {
		if(getInfo("SchemaContext.scDistribution.isUse") != undefined && getInfo("SchemaContext.scDistribution.isUse") == "Y"){		
			// 기존파일 사이즈의 합
			for(var i = 0; i< l_aObjFileList.length; i++){
				fileSize += l_aObjFileList[i].size
			}
	
			// 추가한 파일
			for (var j = 0; j < nLength; j++) {
				fileSize += oFileInfo[j].size
				if (fileSize>7340032) { // 7mb 넘음
					bFileCheck = true;
					parent.Common.Warning("외부공문서 파일은 총 7mb까지 첨부 가능합니다.");
					break;
				}
			}
		}
	} catch(e){coviCmn.traceLog(e)}
	
	for (var i = 0; i < nLength; i++) {
		for (var j = 0; j < l_aObjFileList.length; j++) {
			if (oFileInfo[i].name == l_aObjFileList[j].name) { // 중복됨
				bCheck = true;
				Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
				break;
			} else { // 중복안됨
				bCheck = false;
			}
		}
		for (var k = 0; k < $("input[name=chkFile]").length; k++) {
			if (oFileInfo[i].name == $("input[name=chkFile]").eq(k).val().split(":")[1]) { // 중복됨
				bCheck = true;
				parent.Common.Warning(Common.getDic("msg_AlreadyAddedFile"));
				break;
			} else { // 중복안됨
				bCheck = false;
			}
		}
		for (var l = 0; l < fileDisenableName.length; l++){
			if(fileDisenableName[l] != "" && oFileInfo[i].name.indexOf(fileDisenableName[l]) > -1){
				var warningComment = Common.getDic("msg_disenableFileName") + " " + fileDisenableName.join(", ");
				parent.Common.Warning(warningComment.substr(0, warningComment.length - 2));
				bCheck = true;
				break;
			}
		}
		if (!bCheck && !bFileCheck) {
			aObjFiles.push(oFileInfo[i]);
		}
	}
	readfiles(aObjFiles);
	SetFileInfo(aObjFiles);
	
	setSeqInfo();
}

// 파일정보 배열(l_aObjFileList)에 추가
function readfiles(files) {
	for (var i = 0; i < files.length; i++) {
		//unique한 값을 추가
		//var timestamp = new Date().getUTCMilliseconds();
		//files[i].timestamp = timestamp;
		l_aObjFileList.push(files[i]);
	}
}

// 파일 정보 히든필드에 셋팅
function SetFileInfo(pObjFileInfo) {
	var aObjFileInfo = new Array();
	aObjFileInfo = pObjFileInfo;
	var sFileInfo = "";
	var sFileInfoTemp = "";
	var nLength = aObjFileInfo.length; 
	for (var i = 0; i < nLength; i++) {
		var attachType = (aObjFileInfo[i].attachType == undefined ? "normal" : aObjFileInfo[i].attachType); //webhard or normal

		sFileInfo += aObjFileInfo[i].name + ":" + aObjFileInfo[i].size + ":" + "NEW" + ":" + "0" + ":" + attachType + ":" + "|";

		// hidFileSize 값 셋팅
		//sFileInfoTemp += aObjFileInfo[i].name + ":" + aObjFileInfo[i].size + "|";
		sFileInfoTemp += aObjFileInfo[i].name + ":" + aObjFileInfo[i].name.split(',')[aObjFileInfo[i].name.split(',').length - 1] + ":" + aObjFileInfo[i].size + "|";
	}

	// 유효성 검사를 위해 부모창의 히든필드에 값 셋팅
	/*if(parent.document.getElementById("fileInfo") != null) {
		if (parent.document.getElementById("fileInfo").value == null) {
			parent.document.getElementById("fileInfo").value = "";
		}
		parent.document.getElementById("fileInfo").value += sFileInfo;
	}*/

	if (document.getElementById("fileInfo").value == null) {
		document.getElementById("fileInfo").value = "";
	}
	document.getElementById("fileInfo").value += sFileInfo;
	document.getElementById("hidFileSize").value += sFileInfoTemp;

	// 목록에 바인딩
	DrawTable(pObjFileInfo);
}

// 첨부파일 정보 Row 추가
function DrawTable(fileInfo) {
	var aObjFileInfo = new Array();
	aObjFileInfo = fileInfo;
	var sFileInfo = "";
	//var sFilePath = document.getElementById("hidFrontPath").value;
	//sFilePath = sFilePath.split('\\')[sFilePath.split('\\').length - 1];
	//sFilePath = sFilePath.split('|')[2] + "/file/" + sFilePath.split('|')[3];

	for (var l = 0; l < aObjFileInfo.length; l++) {
		var sExtension = aObjFileInfo[l].name.split('.')[aObjFileInfo[l].name.split('.').length - 1];
		var sFileName = aObjFileInfo[l].name;
		var sFileSize = aObjFileInfo[l].size;
		var sAttachType = (aObjFileInfo[l].attachType == undefined ? "normal" : aObjFileInfo[l].attachType); //webhard or normal
		var sSavedName = (aObjFileInfo[l].savedName == undefined ? "" : aObjFileInfo[l].savedName); // 신규 첨부의 경우 savedName이 필요없지만 webhard 첨부일 경우 필요하여 추가
		var sOriginID = (aObjFileInfo[l].FileID == undefined ? "" : aObjFileInfo[l].FileID); // edms첨부의경우 storage/company 정보조회위해 기존 fileid 필요
		var sFileType = "";
		sFileInfo += sFileName + ":" + sExtension + ":" + sFileSize + ":" + sAttachType + ":" + sSavedName + ":" + sOriginID + "|"; //":" + sFilePath +
	}

	var l_selObj = document.getElementById("fileInfo");
	var l_arrFile = "";
	if (sFileInfo != "")
		l_arrFile = sFileInfo.split("|"); // 새 파일 정보
	if (l_arrFile != "" && l_arrFile.length > 0) {
		$("#trFileInfoBox").hide();
	}
	if (l_arrFile != "") {
		if (l_selObj.rows[l_selObj.rows.length - 1].innerHTML.indexOf("colspan") > -1)
			l_selObj.deleteRow(l_selObj.rows.length - 1); //기본 줄이 있을 경우 제거처리
		for (var i = 0; i < l_arrFile.length - 1; i++) {
			var l_arrDetail = l_arrFile[i].split(':');
			var l_oRow = l_selObj.insertRow(l_selObj.rows.length);

			var l_oCell_1 = l_oRow.insertCell(l_oRow.cells.length);
			l_oCell_1.innerHTML = '<input name="chkFile" type="checkbox" value="' +'_0' + ':' + l_arrDetail[0] + ':NEW:' + l_arrDetail[4] + ':' + l_arrDetail[3] + ':' + l_arrDetail[2] + ':' + l_arrDetail[5] + '" class="input_check">'; //+ l_arrDetail[3]

			var l_oCell_2 = l_oRow.insertCell(l_oRow.cells.length);
			l_oCell_2.innerHTML += '<span class=' + setFileIconClass(l_arrDetail[1]) + '>파일첨부</span>';

			var l_oCell_3 = l_oRow.insertCell(l_oRow.cells.length);
			l_oCell_3.innerHTML = l_arrDetail[0];

			var l_oCell_4 = l_oRow.insertCell(l_oRow.cells.length);
			l_oCell_4.innerHTML += ConvertFileSizeUnit(l_arrDetail[2]);
			l_oCell_4.className = "t_right";

			l_selObj.appendChild(l_oRow); //상단에서 객체 insertRow로 이미 추가됨
		}
	}
}

// 부모창의 파일삭제 버튼 클릭 시 선택한 파일 제거
function DeleteFile() {
	var l_selObj = document.getElementById("fileInfo");
	var l_chk = document.getElementsByName("chkFile");
	document.getElementById("hidDeletFiles").value = "";

	if (l_chk.length <= 0) {
		return;
	}

	for (var i = l_chk.length - 1; i > -1; i--) {
		if (l_chk[i].checked) {
			document.getElementById("hidDeletFiles").value += l_chk[i].value.split(":")[1] + "|"; // 선택한 파일명

			if (l_chk[i].value.split(":")[2] == "OLD") {
				document.getElementById("hidDeleteFile").value += l_chk[i].value.split(":")[1] + "|";
			}

			l_selObj.deleteRow(i);
			if (l_selObj.rows.length < 1) {
				var l_oRow = l_selObj.insertRow(l_selObj.rows.length);
				l_oRow.setAttribute("id", "trFileInfoBox");
				l_oRow.setAttribute("height", "99%");

				var l_oCell_1 = l_oRow.insertCell(l_oRow.cells.length);
				l_oCell_1.innerHTML = '<td><div class="dragFileBox"><span class="dragFile">icn</span>' + Common.getDic("lbl_DragFile") + '</div></td>';
				l_oCell_1.setAttribute("colspan", "4");
				l_selObj.appendChild(l_oRow); //상단에서 객체 insertRow로 이미 추가됨
			}
		}
	}

	// 삭제한 파일
	var sDeletFiles = document.getElementById("hidDeletFiles").value.split("|");
	var nLength = sDeletFiles.length;

	for (var i = 0; i < nLength - 1; i++) {
		for (var j = 0; j < l_aObjFileList.length; j++) {
			if (sDeletFiles[i] == l_aObjFileList[j].name) {
				l_aObjFileList.splice(j, 1);
				break;
			}
		}
	}

	var sFileInfo = "";
	var sFileInfoTemp = "";
	for (var i = 0; i < l_aObjFileList.length; i++) {
		sFileInfo += l_aObjFileList[i].name + ":" + l_aObjFileList[i].size + ":NEW:0:|";
		sFileInfoTemp += l_aObjFileList[i].name + ":" + l_aObjFileList[i].name.split('.')[l_aObjFileList[i].name.split('.').length - 1] + ":" + l_aObjFileList[i].size + "|";
	}
	document.getElementById("fileInfo").value = sFileInfo;
	document.getElementById("hidFileSize").value = sFileInfoTemp;

	//수정 부분 강제 change
	if (_ie) {
		var temp_input = $(document.getElementById("FileSelect"));
		temp_input.replaceWith(temp_input.val('').clone(true));
	} else {
		document.getElementById("FileSelect").value = "";
	}
	$("#FileSelect").change();
	
	setSeqInfo();
}

function clearDeleteFront() {
	/// <summary>
	/// Non ActiceX 에서 파일 추가, 삭제, 재추가시 첨부가 사라지는 문제점 해결
	/// &#10; ( hidDeleteFront 컨트롤에서 값이 남아 있어서 문제가 됨. )
	/// &#10; 값을 초기화 하여 조치. (2013-12-18 leesh)
	/// </summary>

	// ActiceX 인 경우에 첨부 UI 를 바로 업데이트 하지 않는다.(추가할때도 바로 업데이트가 안되므로 일관성 유지)
	if (document.getElementById("CoviUpload") == null) {
		//setAttInfo();	// [2015-09-30 modi] 무조건 기안/임시저장/승인 등 저장행위시에만 UI에 추가되도록 수정
	}

	document.getElementById("hidDeleteFront").value = "";
}

//파일 아이콘 class 타입 구별
function setFileIconClass(extention) {
	var strReturn = "";

	if (extention == "xls" || extention == "xlsx") {
		strReturn = "exCel";
	} else if (extention == "jpg" || extention == "JPG" || extention == "png" || extention == "PNG" || extention == "bmp") {
		strReturn = "imAge";
	} else if (extention == "doc" || extention == "docx") {
		strReturn = "woRd";
	} else if (extention == "ppt" || extention == "pptx") {
		strReturn = "pPoint";
	} else if (extention == "txt") {
		strReturn = "teXt";
	} else {
		strReturn = "etcFile";
	}

	return strReturn;
}

// 파일 사이즈의 값 변환
function ConvertFileSizeUnit(pSize) {
	var nSize = 0;
	var sUnit = "Byte";

	nSize = pSize;
	if (nSize >= 1024) {
		nSize = nSize / 1024;
		sUnit = "KB";
	}
	if (nSize >= 1024) {
		nSize = nSize / 1024;
		sUnit = "MB";
	}
	if (nSize >= 1024) {
		nSize = nSize / 1024;
		sUnit = "GB";
	}
	if (nSize >= 1024) {
		nSize = nSize / 1024;
		sUnit = "TB";
	}
	var sReturn = parseFloat(nSize).toFixed(1) + sUnit;
	return sReturn;
}

// 체크박스 전체 선택 및 해제
// 현재 함수를 사용하고 있지 않으며, 향후 수정하여 사용될 함수.
var l_chkflag = "false";
function CheckAll() {
	var l_chk = document.getElementsByName("chkFile");
	var i;
	if (l_chkflag == "false") {
		for (i = 0; i < l_chk.length; i++) {
			l_chk[i].checked = true;
		}
		l_chkflag = "true";
	} else {
		for (i = 0; i < l_chk.length; i++) {
			l_chk[i].checked = false;
		}
		l_chkflag = "false";
	}
}

//선택건 위로 이동
function SelectedFileUp() {
    var uplist = $("#fileInfo").find("input[name=chkFile]:checked").closest("tr");
    $.each(uplist, function (i, item) {
        $(item).prev().before($(item)); // 현재 tr 의 이전 tr 앞에 선택한 tr 넣기

    });
    newFileInfo();
    setSeqInfo();
}
//선택건 아래로 이동
function SelectedFileDown() {
    var downlist = $("#fileInfo").find("input[name=chkFile]:checked").closest("tr");
    for (var index = downlist.length - 1; index >= 0 ; index--) {
        var item = downlist[index];
        $(item).next().after($(item)); // 현재 tr 의 다음 tr 뒤에 선택한 tr 넣기
    }

    newFileInfo();
    setSeqInfo();
}

//선택건 위로 이동
function SelectedMultiFileUp() {
	const idx = getMultiIdx();
	
    var uplist = $("#fileInfo"+idx).find("input[name=chkFile]:checked").closest("tr");
    $.each(uplist, function (i, item) {
        $(item).prev().before($(item)); // 현재 tr 의 이전 tr 앞에 선택한 tr 넣기

    });
    newFileInfo();
    setSeqInfo();
}
//선택건 아래로 이동
function SelectedMultiFileDown() {
	const idx = getMultiIdx();
	
    var downlist = $("#fileInfo"+idx).find("input[name=chkFile]:checked").closest("tr");
    for (var index = downlist.length - 1; index >= 0 ; index--) {
        var item = downlist[index];
        $(item).next().after($(item)); // 현재 tr 의 다음 tr 뒤에 선택한 tr 넣기
    }

    newFileInfo();
    setSeqInfo();
}

//parent#fileInfo 값 변경
function newFileInfo() {
    var arrayFilesize = $("#hidFileSize").val().split("|");
    var arrayfileinfo = $("#fileInfo").val().split("|"); //FileName:FileSize:NEW/OLD:0:normal:
    var newFileInfoStr = "";
    var newFileSizeStr = "";
    var newFileList = [];
    
    var filelist = $("#fileInfo").find("input[name=chkFile]"); //MessageID_Seq:FileName:NEW/OLD:SavedName:normal
    $(filelist).each(function (i, item) {
        var aa = $(item).val();
        for (var j = 0 ; j < arrayfileinfo.length ; j++) {
            if (arrayfileinfo[j].split(":")[0] == aa.split(":")[1]) {
                newFileInfoStr += arrayfileinfo[j] + "|";
                continue;
            }
        }
        for (var j = 0 ; j < arrayFilesize.length ; j++) {
            if (arrayFilesize[j].split(":")[0] == aa.split(":")[1]) {
                newFileSizeStr += arrayFilesize[j] + "|";
                continue;
            }
        }
        for (var j = 0 ; j < l_aObjFileList.length ; j++) {
            if (l_aObjFileList[j].name == aa.split(":")[1]) {
            	newFileList.push(l_aObjFileList[j]);
                continue;
            }
        }
    });
    $("#fileInfo").val(newFileInfoStr);
    $("#hidFileSize").val(newFileSizeStr);
    l_aObjFileList = newFileList;
}

function setSeqInfo() {
    var seqStr = "";
    
    var fileInfos = [];
    // getInfo를 사용하지 않는 결재 외 모듈에서 오류 발생해서 예외처리 추가함.
    try {
	    if(getInfo("FormInstanceInfo.AttachFileInfo") != undefined && getInfo("FormInstanceInfo.AttachFileInfo") != "") {
	    	fileInfos = JSON.parse(getInfo("FormInstanceInfo.AttachFileInfo")).FileInfos;
	    }
    } catch(e){coviCmn.traceLog(e)}
    
    $("input[name=chkFile]").each(function(i, obj) {
    	var isNew = $(obj).val().split(":")[2];
    	var fileName = $(obj).val().split(":")[1];

    	if(isNew == "NEW") {
    		seqStr += isNew + ":" + i + ":" + "" + ":" + fileName + "|"; // NEW:0::파일명|
    	} else {
    		for(var j = 0; j < fileInfos.length; j++) {
    			if(fileName == fileInfos[j].FileName) {
    				seqStr += isNew + ":" + i + ":" + fileInfos[j].FileID + ":" + fileName + "|"; // OLD:0:파일ID:파일명
    				break;
    			}
    		}
        }
    });
    
    $("#hidFileSeq").val(seqStr);
    
    // getInfo를 사용하지 않는 결재 외 모듈에서 오류 발생해서 예외처리 추가함.
    try {
	    if(getInfo("FormInstanceInfo.AttachFileInfo") != undefined && getInfo("FormInstanceInfo.AttachFileInfo") != "") {
		    var newFileInfo = [];
		    var oldFileInfo = $.parseJSON($("#AttachFileInfo").val()).FileInfos;
		    var arrFileSeq = $("#hidFileSeq").val().split("|");
		
		    for(var i = 0; i < arrFileSeq.length; i++) {
		    	for(var j = 0; j < oldFileInfo.length; j++) {
		    		if(arrFileSeq[i].split(":")[3] == oldFileInfo[j].FileName) {
		    			oldFileInfo[j].Seq = i;
		    			newFileInfo.push(oldFileInfo[j]);
		    			break;
		            }
		        }
		    }
		    $("#AttachFileInfo").val('{"FileInfos":' + JSON.stringify(newFileInfo) + '}');
	    }
    } catch(e){coviCmn.traceLog(e)}
}
//--------------------------------------------- 첨부파일 컨트롤 끝 ------------------------------------------------------- 