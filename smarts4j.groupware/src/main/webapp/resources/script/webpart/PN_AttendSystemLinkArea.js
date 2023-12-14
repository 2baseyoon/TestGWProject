/**
 * pnAttendSystemLinkArea - 근태 & 시스템 바로가기 영역
 */
var pnAttendSystemLinkArea = {
	webpartType: "",
	nowDate: new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd")),
	init: function(data,ext){
		var folderID = ext.systemLinkFolderID;
		var nowDateStr = schedule_SetDateFormat(pnAttendSystemLinkArea.nowDate, '.');
		nowDateStr = schedule_SetDateFormat(pnAttendSystemLinkArea.nowDate, '.').substr(5, nowDateStr.length);
		var nowDay = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
		var nowDayStr = Common.getDic("lbl_sch_" + nowDay[pnAttendSystemLinkArea.nowDate.getDay()]);
		var titleStr = nowDateStr + " (" + nowDayStr + ") <spring:message code='Cache.lbl_AttStatus'/>"; // 출근현황
		
		$(".PN_TitleBox .ic_time").text(titleStr);
		
		pnAttendSystemLinkArea.setEvent();
		AttendUtils.getDeptList($("#selGroupPath"), "", false, false, true);
		pnAttendSystemLinkArea.setSystemLinkList(folderID);
	},
	setEvent: function(){
		$(window).load(function(){
			pnAttendSystemLinkArea.getAttendCount($("#selGroupPath").val());
		});
		
		$("#selGroupPath").on("change", function(){
			pnAttendSystemLinkArea.getAttendCount($("#selGroupPath").val());
		});
		
		$(document).on('leftOpen', function(){
			pnAttendSystemLinkArea.resize('open');
		});
		
		$(document).on('leftClose', function(){
			pnAttendSystemLinkArea.resize('close');
		});
	},
	resize: function(mode){
		var orgWidth = 0;
		if ($(".SystemSlider .slick-list").length > 0) {
			orgWidth = Number($(".SystemSlider .slick-list").css("width").replace(/[^\-\.0-9]/g, ""));	
		}
		var len = $(".SystemSlider .slick-slide").length;
		var trackWidth = 100 * len;
		var slideWidth = 100 / len;
		var width = orgWidth - (Number($(".PN_mainLeft").css("width").replace(/[^\-\.0-9]/g, "")) / 2);
		var mNum = $(".SystemSlider").slick("slickCurrentSlide");
			
		$(".SystemSlider .slick-track").css({"width": trackWidth + "%", "transform": "translate3d(-" + (width * mNum) + "px, 0px, 0px)"});
		$(".SystemSlider .slick-slide").css("width", slideWidth + "%");
		
		if (mode == 'open'){
			if (len > 0) {
				$(".SystemSlider").slick("getSlick").slideWidth = Number($(".SystemSlider .slick-slide").css("width").replace(/[^\-\.0-9]/g, ""))
																- (Number($(".PN_mainLeft").css("width").replace(/[^\-\.0-9]/g, "")) / 2);			
			}
		}
		else if (mode == 'close'){
			if (len > 0) {
				$(".SystemSlider").slick("getSlick").slideWidth = Number($(".SystemSlider .slick-slide").css("width").replace(/[^\-\.0-9]/g, ""))
																+ (Number($(".PN_mainLeft").css("width").replace(/[^\-\.0-9]/g, "")) / 2);	
			}
		}
	},
	getAttendCount: function(groupPath){
		var nowDateStr = schedule_SetDateFormat(pnAttendSystemLinkArea.nowDate, '.');
		var paramMap = {
			  startDate: nowDateStr
			, endDate: nowDateStr
			, targetDate: nowDateStr
			, pageType: "D"
		};
		
		var params = {
			  companyMap : paramMap
			, userMap : paramMap
			, deptMap : paramMap
			, queryType: "A"
			, deptUpCode: groupPath
			, deptUpCodeWork: groupPath
			, searchText: ""
			, schSeq: ""
			, pageNo: 1
			, pageSize: "10"
		};
		
		$.ajax({
			url: "/groupware/attendPortal/getMangerAttStatus.do",
			type: "POST",
			data: JSON.stringify(params),
			dataType: "json",
			contentType: "application/json; charset=utf-8",
			success: function (data) {
				if(data.status == "SUCCESS"){
					if(data.companyToday){
						if(data.companyToday.WorkCnt != null) $(".ic_attend .PN_count").text(data.companyToday.WorkCnt); // 출근
						if(data.companyToday.LateCnt != null) $(".ic_late .PN_count").text(data.companyToday.LateCnt); // 지각
						if(data.companyToday.VacCnt != null) $(".ic_vacation .PN_count").text(data.companyToday.VacCnt); // 휴가
						if(data.companyToday.AbsentCnt != null) $(".ic_calling .PN_count").text(data.companyToday.AbsentCnt); // 소명
						
						pnAttendSystemLinkArea.setAttendCount();
					}
				}else{
					Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>");
				}
			},
			error: function(request, status, error){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			}
		});
	},
	setAttendCount: function(){
		$('.PN_AttendList .PN_count').counterUp();
	},
	setSystemLinkList: function(folderID){
		//var backStorage = Common.getBaseConfig('BackStoragePath').replace("{0}", Common.getSession("DN_Code"));

		$.ajax({
			type: "POST",
			data: {
				"folderID": folderID
			},
			url: "/groupware/pnPortal/selectSystemLinkBoardList.do",
			success: function(data){
				var listData = data.list;
				var openType = "";
				var ulCnt = -1;
				
				if( listData.length > 0 ){
					var $fragment = $( document.createDocumentFragment());
					var len = Math.ceil( listData.length/6 );
					for(i=0; i < len; i++){
						var $ul = $("<ul>");
						listData.splice(0,6).forEach(function( item ){
					    	var fileInfo = "";
							var filePath = "/HtmlSite/smarts4j_n/covicore/resources/images/common/systemlink_sample.jpg";
							var liWrap = $("<li></li>");
							
							//item.SavedName && (filePath = backStorage + item.ServiceType + "/" + item.FilePath + item.SavedName);
							item.SavedName && (filePath = item.FullPath);
							
							if(item.OpenType == "1"){
								openType = "_self";
							}else{
								openType = "_blank";
							}
							filePath = coviCmn.loadImage(filePath);
							liWrap.append($("<a href='#'></a>")
									.append($("<span class='stIcon'></span>")
										.append($("<img>").attr("src", filePath)))
									.append($("<span class='stTxt'></span>").text(item.Subject)));
							
							if(!item.LinkURL || item.LinkURL == "http://"){
								liWrap.find("a").on("click", function(){
									Common.Inform("<spring:message code='Cache.msg_noRegisteredLink'/>"); // 링크가 등록되지 않았습니다.
								});
							}else{
								liWrap.find("a")
									.attr("href", item.LinkURL)
									.attr("target", openType);
							}
							
							$ul.append( liWrap );
					    });
					    $fragment.append( $ul );
					}
					
					$(".SystemSlider").append( $fragment );
				} else {
					var resultInfos = data.infos;
					var txtNoList = '<div class="PN_nolist" style="padding: 20px 10px;">';
					
					if (resultInfos === "-1") {
						// Link 게시판 또는 폴더가 선택되지 않았습니다
						txtNoList += '<p class="list_none">Link <spring:message code="Cache.msg_BoardsntSel"/>.</p>';
					} else if (resultInfos === "0") {
						// 조회 데이터가 0건. 조회할 목록이 없습니다.
						txtNoList += '<p class="list_none"><spring:message code="Cache.msg_NoDataList"/></p>';
					} 
					txtNoList += '</div>';
					$(".SystemSlider").append(txtNoList);
				}
				pnAttendSystemLinkArea.setSystemLinkSlide();
			},
			error: function(response, status, error){
				 CFN_ErrorAjax("/groupware/pnPortal/selectSystemLinkBoardList.do", response, status, error);
			}
		});
	},
	setSystemLinkSlide: function(){
		const slider = $(".SystemSlider");
		
		slider.slick({
			slide: "ul",			// 슬라이드 되어야 할 태그 ex) div, li
			infinite : false,		// 무한 반복 옵션
			slidesToShow : 1,		// 한 화면에 보여질 컨텐츠 개수
			slidesToScroll : 1,		// 스크롤 한번에 움직일 컨텐츠 개수
			speed : 500,			// 다음 버튼 누르고 다음 화면 뜨는데까지 걸리는 시간(ms)
			arrows : true,			// 옆으로 이동하는 화살표 표시 여부
			dots : false,			// 스크롤바 아래 점으로 페이지네이션 여부
			autoplay : false,		// 자동 스크롤 사용 여부
			autoplaySpeed : 3000,	// 자동 스크롤 시 다음으로 넘어가는데 걸리는 시간 (ms)
			pauseOnHover : true,	// 슬라이드 이동 시 마우스 호버하면 슬라이더 멈추게 설정
			vertical : false,		// 세로 방향 슬라이드 옵션
			draggable : false,		// 드래그 가능 여부
			variableWidth: false
		});
		
		slider.on("wheel", (function(e){
			e.preventDefault();
			if(e.originalEvent.deltaY < 0){
				$(this).slick("slickPrev");
			}else{
				$(this).slick("slickNext");
			}
		}));
	}
}
