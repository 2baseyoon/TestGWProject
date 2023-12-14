/*
 * covision util
 * 
 * use : covisionUtil.test();
 * */

var coviUtil = function(){
	if (!(this instanceof arguments.callee )) return new arguments.callee();
	
	/* this.checkValidation: 페이지 이동
	 * @method pageMove
	 * @param pBoxID 박스 ID
	 * @param pFolderID 폴더 ID
	 * @param pFolderType 폴더 타입 (ex. Normal, Published, Trashbin, ...)
	 * */
	this.showErrorMsg = function(sMsgId, oTarget, bShowMsg, bFocus, sAddMsg){
		let sMsg = Common.getDic(sMsgId).replace("{0}", oTarget.attr("title"));
		if (sAddMsg != undefined) sMsg+= sAddMsg;
		
		if (bShowMsg){
			Common.Warning(sMsg, "Warning", function(){ 
				if (bFocus) oTarget.focus();
			});
			
		}
	}
	
	this.checkValidation = function(obj, bShowMsg, bFocus){
		let bValidation = true;
		if (obj == undefined) {
			obj="";
		}
		//필수값 체크
		$(obj+" .Required").each(function () {
			if ($(this).attr("type") != "radio" && $(this).attr("type") != "checkbox" ){
				if ($.trim($(this).val()) == ""){
					coviUtil.showErrorMsg("msg_EnterTheRequiredValue", $(this), bShowMsg, bFocus );
					bValidation = false;
					return false;
				}
			}
			
		});
		if (bValidation == false) return bValidation;

		// Html 태그 입력 불가
		$(obj+" .HtmlCheckXSS").each(function () {
			if (XFN_CheckHTMLinText($(this).val())) {
				coviUtil.showErrorMsg("msg_ThisPageLimitedHTMLTag", $(this), bShowMsg, bFocus );
				bValidation = false;
				return false;
			}
		});
		if (bValidation == false) return bValidation;
		
		// <script>, <style> 입력 불가
		$(obj+" .ScriptCheckXSS").each(function () {
			if (XFN_CheckInputLimit($(this).val())) {
				coviUtil.showErrorMsg("msg_ThisInputLimitedScript", $(this), bShowMsg, bFocus );
				bValidation = false;
				return false;
			}
		});
		if (bValidation == false) return bValidation;

		// <script> 입력 불가
		$(obj+" .ScriptCheckXSSOnlyScript").each(function () {
			if (XFN_CheckInputLimitOnlyScript($(this).val())) {
				coviUtil.showErrorMsg("msg_ThisInputLimitedScript", $(this), bShowMsg, bFocus );
				bValidation = false;
				return false;
			}
		});
		if (bValidation == false) return bValidation;
		
		// 특수 문자 입력 불가 
		var spePatt = /[`~!@#$%^&*|\\\'\";:\/?(){}\[\]¢™$®]/gi;
		$(obj+" .SpecialCheck").each(function () {
			if (spePatt.test($(this).val())) {
				coviUtil.showErrorMsg("msg_specialNotAllowed", $(this), bShowMsg, bFocus );
				bValidation = false;
				return false;
			}
		});
		if (bValidation == false) return bValidation;
		
		// 이모지 입력 불가
//		console.log("emoji check")
	    var emojPatt = /(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff]|[\u0023-\u0039]\ufe0f?\u20e3|\u3299|\u3297|\u303d|\u3030|\u24c2|\ud83c[\udd70-\udd71]|\ud83c[\udd7e-\udd7f]|\ud83c\udd8e|\ud83c[\udd91-\udd9a]|\ud83c[\udde6-\uddff]|\ud83c[\ude01-\ude02]|\ud83c\ude1a|\ud83c\ude2f|\ud83c[\ude32-\ude3a]|\ud83c[\ude50-\ude51]|\u203c|\u2049|[\u25aa-\u25ab]|\u25b6|\u25c0|[\u25fb-\u25fe]|\u00a9|\u00ae|\u2122|\u2139|\ud83c\udc04|[\u2600-\u26FF]|\u2b05|\u2b06|\u2b07|\u2b1b|\u2b1c|\u2b50|\u2b55|\u231a|\u231b|\u2328|\u23cf|[\u23e9-\u23f3]|[\u23f8-\u23fa]|\ud83c\udccf|\u2934|\u2935|[\u2190-\u21ff])/g;
		$(obj+" .EmojiCheck").each(function () {
			if (emojPatt.test($(this).val())) {
				coviUtil.showErrorMsg("msg_emojiNotAllowed", $(this), bShowMsg, bFocus );
				bValidation = false;
				return false;
			}
		});
		if (bValidation == false) return bValidation;
		
		//최대 사이즈
		$(obj+" .MaxSizeCheck").each(function () {
			if (CFN_CalByte($(this).val()) > $(this).attr("max")){
				coviUtil.showErrorMsg("msg_RxceedNumberOfEnter", $(this), bShowMsg, bFocus,  "["+CFN_CalByte($(this).val())+" > "+$(this).attr("max")+"]" );
				bValidation = false;
				return false;
			}
		});

		if (bValidation == false) return bValidation;
		
		//숫자만
		var numPatt 	= /^[+\-\.\d]*$/;
		$(obj+" .Number").each(function () {
			if (!(numPatt.test($(this).val()))){
				coviUtil.showErrorMsg("msg_apv_249", $(this), bShowMsg, bFocus);
				bValidation = false;
				return false;
			};

			if ($(this).attr("minnum") != "" && $(this).attr("maxnum") != ""){
				if ((parseInt($(this).val(),10) < $(this).attr("minnum")) || (parseInt($(this).val(),10) > $(this).attr("maxnum") ) ){
					coviUtil.showErrorMsg("msg_RxceedNumberOfEnter", $(this), bShowMsg, bFocus,  "["+$(this).attr("minnum")+" ~ "+$(this).attr("maxnum")+"]" );
					bValidation = false;
					return false;
				}
			}	
			
		});
		return bValidation;

	}
	
	changeWebpartLayer=function(webpartId, caller, objJson, webpartName, Reserved1){
		switch(caller){
			case "Widget":
				if (!$("#"+webpartId+" .webpart-top").hasClass("widget_head")){
					$("#"+webpartId+" .webpart-top").addClass("widget_head");
				}
				
				if (!$("#"+webpartId+" .webpart-content").hasClass("widget_content")){
					$("#"+webpartId+" .webpart-content").addClass("widget_content");
				}
				
				if (coviUtil.isMobile()){//mobile만 헤더 
					$("#"+webpartId+" .widget_head").html(
						'<h3 class="title"></h3>' +
						'<div class="action">' +
							'<a href="#" class="widget_more ui-link"><span>더보기</span></a>'+
						'</div>'
					);
				}	
//				var listObj = JSON.parse(list);
				$("#"+webpartId+" .widget_head h3").text(webpartName);
				
				if (!coviUtil.isMobile()){   // PC버전일 경우
					if (objJson.moreUrl != undefined) {
						let jsonMoreUrl = objJson.moreUrl;
						$("#"+webpartId).find("a.widget_more").attr("href", jsonMoreUrl);
					}
				} else {
					// mobile mode
					if (objJson.mobileMoreUrl != undefined) {
						$("#"+webpartId).find("a.widget_more").attr("href", "javascript:mobile_comm_go(\""+objJson.mobileMoreUrl+"\", \"N\")");
					}
				}
				
				break;
			case "Contents":
				
	//			var listObj = JSON.parse(list); 	// header의 title은 웹파트 정보에서 가져옴.
//				var objJson = listObj.ExtentionJSON;
				// 추가 설정 토글 버튼 HTML(PC버전에서만).
				if (!coviUtil.isMobile()) {
					// title
					$(".grid_item[data-id='"+webpartId+"']").find(".title").text(webpartName);
					coviUtil.addContentHeader(webpartId, objJson, Reserved1);
				} else {
					// 모바일 버전.
					// title
					$(".grid_item[id='"+webpartId+"']").find(".title").text(webpartName);
					if (objJson.mobileMoreUrl != undefined && objJson.mobileMoreUrl != "") {
						$("#"+webpartId).find(".widget_head")
						.append($("<div>", {"class": "action"})
							.append($("<a>", {"href": "javascript:mobile_comm_go(\""+objJson.mobileMoreUrl+"\", \"N\")", "class": "widget_more"}))
						);
					}
				}
				
				break;
			}
		
	}
	
	this.addContentHeader=function(webpartId, objJson, Reserved1){
		
//		var objJson = listObj.ExtentionJSON;

		$("#"+webpartId + " .widget_card .widget_head").append($("<div>", {"class": "action"}));//헤더 메뉴 영역
		$("#"+webpartId).append($("<div>",{"class":"widget_control"}));	//삭제및 이동 영역
		$("#"+webpartId).append($("<div>",{"class":"widget_option","hidden":""}));	//추가 메뉴영역

		if (Reserved1 != 'FIX'){ 	//고정이 아니면 삭제 버튼 추가
			$("#"+webpartId + " .widget_control").append($("<button>",{"class":"delete"}).append($("<span>",{"text":Common.getDic("btn_delete")})));
		}		
		//이동 버튼
		$("#"+webpartId + " .widget_control").append($("<button>",{"class":"move"}).append($("<span>",{"text":Common.getDic("lbl_Move")})));
		
		
		//위젯색상 
		if (objJson.chngColor == undefined || objJson.chngColor == ""){
			$("#"+webpartId + " .widget_option").append($("<button>",{"type":"button","data-action":"color"}).append($("<span>",{"text":Common.getDic("lbl_ColorChange")})));	
		}	
		//설정
		if (objJson.popupFn != undefined && objJson.popupFn != "") {
			$("#"+webpartId + " .widget_option").append($("<button>",{"type":"button","data-action":"setting"}).append($("<span>",{"text":Common.getDic("lbl_Set")})));	 
		}	

		//위젯 설정메뉴
		if ($("#"+webpartId + " .widget_option button").size()>0){
			$("#"+webpartId + " .widget_head .action").append($("<button>", {"type": "button", "class": "widget_option_toggle"}))
		}
		
		// more
		if (objJson.moreUrl != undefined && objJson.moreUrl != "") {
			$("#"+webpartId+ " .widget_head .action").append($("<a>", {"href": objJson.moreUrl, "class": "widget_more"}));
		}
	}

	// 실제 갯수(cnt)가 표시제한갯수(limitCnt)가 더 크면 +limitCnt로 표기(예, +99, +50).
	this.showCntOver = function(cnt, limitCnt) {
		if (Number.parseInt(cnt) > Number.parseInt(limitCnt)) {
			return "+" + limitCnt;
		} else {
			return cnt;
		}
	}
	
	this.isMobile = function(){
		if (typeof isMobile  === 'undefined' || !isMobile) return false;
		else return true;
	}
	
	
	/* 웹파트 swiper 연결
		params : 
			pSelector(id or class selector)
			pCnt(갯수)
			pDelay(슬라이드 지연시간)
			pBannerPage(배너 페이지 번호, 0보다 크면 표시)
			pButton (좌우버튼유무 : Y / Y 이외)
			pPagination (하단...버튼유무 : Y / Y 이외)
	 */
	this.webpartSwiper = function(pSelector, pCnt, pDelay, pBannerPage, pButton, pPagination, pClass) {
		if(pButton == undefined || pButton == "") pButton = "Y";
		
	 	var $this = $(pSelector);
	 	if (pClass == undefined)	 	pSelector = pSelector.substr(1);
	 	else {
	 		pSelector = pClass;
	 	}

	 	$this.addClass(pSelector);
	 	
		$this.append($("<div>", {"class" : "swiper " + pSelector +"_swiper swiper-container-fade swiper-container-horizontal"})
			.append($("<div>", {"class" : "swiper-wrapper"}))
		);
		
		if(pPagination == "Y"){
			$this.find(".swiper-wrapper")
				.after($("<div>", {"class" : "swiper-pagination"}))
		}
		
		if(pButton == "Y"){
			$this.find(".swiper-wrapper")
				.after($("<div>", {"class" : "swiper-control"})
					.append($("<div>", {"class" : "swiper-button-prev " + pSelector + "_button_prev"})
						.append($("<span>", {"value" : "이전"}))
					)
					.append($("<div>", {"class" : "swiper-button-next " + pSelector + "_button_next" })
						.append($("<span>", {"value" : "다음"}))
					)
				)
		} else if(pButton == "N") {
			$this.append($("<div>", {"class" : "swiper-button-prev " + pSelector + "_button_prev"})
						.append($("<span>", {"value" : "이전"}))
					)
					.append($("<div>", {"class" : "swiper-button-next " + pSelector + "_button_next" })
						.append($("<span>", {"value" : "다음"}))
					)
		}
		
		if (Number(pBannerPage) > 0) {
			 $this.find(".swiper-button-prev")
			 	.after($("<div>", {"class" : "swiper-pagination "+ pSelector+"_swiper-pagination"}))
			 	.after($("<button>", {"type": "button", "class" : "swiper-button-play"})
					.append($("<span>", {"value" : "정지/재생"}))
				)
		}
	 	
		return "."+pSelector + " .swiper-wrapper";
	}
	
	this.drawSwiper=function(webpartID, swiperInfo){
		var strTarget = "#" +webpartID + "  .swiper";//coviUtil.webpartSwiper("#" + caller.toLowerCase() + "_employee_favorites", 3, 5000, -1,"N","");
		var	$targetDiv = $(strTarget);
		
		$targetDiv.attr("id",webpartID+"_swiper");
		$("#" +webpartID + " .swiper-slide").wrapAll("<div class='swiper-wrapper'>") ;
		var strBtnCtn = "#" +webpartID + " .swiper";
		if (coviUtil.isMobile()) strBtnCtn  = "#" +webpartID + " .widget_content";
		
		var slidesPerGroup = 1;
		
		if (swiperInfo.slidesPerGroup == undefined || swiperInfo.slidesPerGroup == 0) slidesPerGroup=1;
		else slidesPerGroup = swiperInfo.slidesPerGroup;
		
		let swiperOpt = {
		        threshold: 5,
		        slidesPerView: slidesPerGroup,
				slidesPerGroup: slidesPerGroup,
		       };


		if (swiperInfo.pagination == true){
			if (swiperInfo.paginationMode == "button"){
				$(strBtnCtn).append('<div class="swiper-control">'+
	            '<div class="swiper-button-prev portal_banner_button_prev '+webpartID+'_swiper_prev"><span>이전</span></div>'+
	            '<div class="swiper-pagination '+webpartID+'_swiper-pagination"></div>'+
				'<button type="button" class="swiper-button-play '+webpartID+'_swiper_stop"><span>정지/재생</span></button>'+
					'<div class="swiper-button-next portal_banner_button_next '+webpartID+'_swiper_next"><span>다음</span></div></div>');
				
				swiperOpt["pagination"]= {el: "."+webpartID+"_swiper-pagination",type: "fraction"};
				swiperOpt["fadeEffect"]= {crossFade: true};
			        
			}	
			else{
				$(strBtnCtn).append('<div class="swiper-pagination '+webpartID+'_swiper-pagination"></div>');
				swiperOpt["pagination"]= {el: "."+webpartID+"_swiper-pagination",clickable: true};
			}	
		}else{	
			$(strBtnCtn).append('<div class="swiper-button-next '+webpartID+'_swiper_next"><span>다음</span></div>');
			$(strBtnCtn).append('<div class="swiper-button-prev '+webpartID+'_swiper_prev"><span>이전</span></div>');
		}
		
		if (swiperInfo.autoplay == true){
			swiperOpt["autoplay"]= {delay: 5000,disableOnInteraction: false};
		}
		        
		swiperOpt["navigation"]= {nextEl: "."+webpartID+"_swiper_next",prevEl: "."+webpartID+"_swiper_prev"};
		return new Swiper("#"+webpartID+"_swiper",swiperOpt);
	}

	/* 웹파트 데이터 없는 경우 화면 처리
		@param item : 조회 데이터 리스트
		@param caller : 웹파트 영역
		@param webpartID : 해당 웹파트 id
		@param message : 화면에 보여질 메세지
		@param url : 이동, 등록 url
	 */
	this.webpartDrawEmpty = function(item, caller, webpartID, message, url) {
		if(item.length > 0) return;
		
		var $card = $("#" + webpartID).find(".widget_card");
		
		if($card.find(".widget_aside").length > 0) {
			$card = $card.find(".widget_content");
			$card.empty();
		} else {
			$card.find(".widget_content").remove();
		}
		var className = "";
		if (!coviUtil.isMobile()){   // PC버전일 경우
			className = "widget_empty";
		} else {
			className = "ui_empty";
		}
		
		$card.find("."+className).remove();

		$card
		.append($("<div>", {"class" : className})
			.append($("<div>", {"class" : "message"})
				.append($("<p>", {"text" : message}))
			)
		);
		
		if(url !== undefined && caller == "Contents") {
			if(coviUtil.isMobile()) url = "javascript: mobile_comm_go('"+url+"')";
			$card.find("."+className)
			.append($("<div>", {"class" : "link"})
				.append($("<a>", {"href" : url, "text" : coviUtil.getDic("btn_register")}))
			);
		}
	}
	
	this.readURL = function(imgObj, file, bImg) {
		if (file) {
			var reader = new FileReader(); //파일을 읽기 위한 FileReader객체 생성
			reader.onload = function (e) {
				if (bImg == false){	//이미지 객체가 아니면
					console.log(bImg)
					imgObj.css("background-image","url('"+e.target.result+"')");
				}else{
					imgObj.attr("onerror", "coviCtrl.imgError(this);")
			        imgObj.attr("src", e.target.result);
				}	
		    }                   
		    reader.readAsDataURL(file);
		}
	}
	
	/*
	* 금액 3자리 마다 콤마(,) 붙이기
	*/
	this.toAmtFormat = function(val) {
		var retVal = "";
		if(val != null){
			retVal = val.toString();
			if(!isNaN(retVal.replaceAll(",", ""))){
				var splitVal = retVal.split(".");
				if(splitVal.length==2){
					retVal = splitVal[0].replace(/(\d)(?=(?:\d{3})+(?!\d))/g,'$1,');
					retVal = retVal +"."+ splitVal[1];
				}
				else if(splitVal.length==1){
					retVal = splitVal[0].replace(/(\d)(?=(?:\d{3})+(?!\d))/g,'$1,');
				}else{
					retVal = "";
				}
			}
		}
		return retVal;
	}
	
	/*
	 * BizSection 여부 판단 
	 */
	this.getAssignedBizSection = function(bizSection){
		var arrBizSection = Common.getSession('UR_AssignedBizSection').split("|"); 
		for (var i = 0; i < arrBizSection.length; i++) {
			if(arrBizSection[i].indexOf(bizSection) > -1){
				return true;
			}
		}
		return false;
	}
	
	this.getDic = function(dicCode){
		var returnData = "";
		if(coviUtil.isMobile()){
			returnData = mobile_comm_getDic(dicCode);
		}else{
			returnData = Common.getDic(dicCode);
		}
		return returnData;
	}
	
	/* 웹파트 데이터 없는 경우 화면 처리[메일용] - 팝업창 오픈 용
	@param item : 조회 데이터 리스트
	@param caller : 웹파트 영역
	@param webpartID : 해당 웹파트 id
	@param message : 화면에 보여질 메세지
	@param url : 이동, 등록 url
	 */
	this.webpartDrawEmptyToMail = function(item, caller, webpartID, message, url) {
		if(item.length > 0) return;
		
		var $card = $("#" + webpartID).find(".widget_card");
		
		if($card.find(".widget_aside").length > 0) {
			$card = $card.find(".widget_content");
			$card.empty();
		} else {
			$card.find(".widget_content").remove();
		}
		var className = "";
		if (!coviUtil.isMobile()){   // PC버전일 경우
			className = "widget_empty";
		} else {
			className = "ui_empty";
		}
		
		$card.find("."+className).remove();

		$card
		.append($("<div>", {"class" : className})
			.append($("<div>", {"class" : "message"})
				.append($("<p>", {"text" : message}))
			)
		);
		
		$card.find("."+className)
			.append($("<div>", {"class" : "link"})
				.append($("<a>", {"href" : "#", "onclick" : "window.open(\"" + url + "\", \"Mail Write\" + stringGen(10), \"height=700, width=1000\");", "text" : coviUtil.getDic("CPMail_mail_compose")}))
		);
	}
	
	this.getAjaxPost = function (apiLink, params, callback) {
      $.ajax({
          type: "POST",
          url: apiLink,
          data: params,
          success: function (result) {
               return callback(result);
          },
          error : function (response, status, error) {
              CFN_ErrorAjax(pUrl, response, status, error);
          }
      });
	}
	this.setFrontTitle = function(){
		if (typeof frontTitle == "undefined"||  ["Portal", "Mail"].includes(CFN_GetQueryString("CLBIZ")) ) return;
		let addTitle = "";
		switch (CFN_GetQueryString("CLBIZ")){
			case "Account":
				addTitle = $(".l-contents-tabs .l-contents-tabs__item--active div:eq(0)").text();
				break;
			default:
				addTitle =  $("#content .title:eq(0)").text();
				break;
		}
		
		if (addTitle == ""){
			addTitle = $("#left .cLnbTop h2").length > 0? $("#left .cLnbTop h2").text(): CFN_GetQueryString("CLBIZ");
		}	
		
		if (addTitle != "")	$(document).attr("title", frontTitle+ " (" + addTitle+ ")");
	}
	//엑셀용 Grid 헤더정보 설정
	this.getHeaderNameForExcel=function(headerData){
		var returnStr = "";
		
	   	for(var i=0;i<headerData.length-6; i++){
			returnStr += headerData[i].label + "|";
		}
	   	
	   	returnStr = returnStr.substring(0, returnStr.length-1);
		return returnStr;
	}

	this.getHeaderKeyForExcel=function(headerData){
		var returnStr = "";
		
	   	for(var i=0;i<headerData.length-6; i++){
			returnStr += headerData[i].key + "|";
		}
	   	returnStr = returnStr.substring(0, returnStr.length-1);
		return returnStr;
	}

	this.getHeaderTypeForExcel=function(headerData){
		var returnStr = "";

	   	for(var i=0;i<headerData.length-6; i++){
				returnStr += (headerData[i].dataType != undefined ? headerData[i].dataType:"Text") + "|";
		}
	   	returnStr = returnStr.substring(0, returnStr.length-1);
		return returnStr;
	}
	
	this.exportGridExcel=function(url, params, grid){
		var headerData  =  grid.config.colGroup;
		var sortInfo =  grid.getSortParam("one")
		
		var headerName = this.getHeaderNameForExcel(headerData);
		var headerKey = this.getHeaderKeyForExcel(headerData);
		var headerType = this.getHeaderTypeForExcel(headerData);
		
		var sortArry = sortInfo.split("=");
		var	sortBy = sortArry.length>1? sortArry[1]:""; 	
		
		let paramsStr = "sortBy="+sortBy
		+"&headerName="+encodeURI(headerName)
		+"&headerKey="+encodeURI(headerKey)
		+"&headerType="+encodeURI(headerType);

		for(var index in params){
			paramsStr += "&"+index+"=" +params[index] ;
		
		}
		
		location.href = url+"?"+paramsStr;
	};

	this.backStoragePath = null;
	this.sessionDnCode = null;
	this.replaceInlinePhotoMig = function(html) {
		try{
			if(this.backStoragePath == null){
				this.backStoragePath = Common.getBaseConfig("BackStorage");
			}
			if(this.sessionDnCode == null){
				this.sessionDnCode = Common.getSession("DN_Code");
			}
			let _backStoragePath = this.backStoragePath.replace("{0}", this.sessionDnCode);
			let domain = document.domain;
			let regexp = new RegExp(domain + "/gwstorage/", "gi");
			let replacedHtml = html.replace(regexp, domain+"/covicore/common/photo/photo.do?img="+_backStoragePath);
			
			return replacedHtml;
		}catch(e){
			return html;
		}
	};
}();
