/**
 * pnReport - [포탈개선] My Place - 업무보고
 */
var pnReport = {
	webpartType: "",
	userCode: Common.getSession("USERID"),
	deptName: Common.getSession("DEPTNAME"),
	sDate: "",
	eDate: "",
	init: function(data, ext){
		var nowDate = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
		var sun = schedule_GetSunday(nowDate);
		var mon = schedule_AddDays(schedule_SetDateFormat(sun, '/'), 1);
		var fri = schedule_AddDays(schedule_SetDateFormat(sun, '/'), 5);
		pnReport.sDate = schedule_SetDateFormat(mon, '-');
		pnReport.eDate = schedule_SetDateFormat(fri, '-');
		
		pnReport.setEvent();
		pnReport.getReportWeeklyList("GT");
		pnReport.getMyProject();
	},
	setEvent: function(){
		$(".PN_BsReport").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
			if(!$(this).hasClass("active")){
				$(this).addClass("active");
				$(this).next(".PN_portlet_menu").stop().slideDown(300);
				$(this).children(".PN_portlet_btn > span").addClass("on");
			}else{
				$(this).removeClass("active");
				$(this).next(".PN_portlet_menu").stop().slideUp(300);
				$(this).children(".PN_portlet_btn > span").removeClass("on");
			}
		});
		
		$(".PN_BsReport").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on");
		});
		
		$(".PN_myContents_sizeW .PN_BsReport").closest("div[name=mycontents_webpart]").css("width", "100%");
		
		$(".PN_btnArea .btnOpen").on("click", function(){
			if($(this).parents().find(".PN_mainLeft").is(":hidden") == false){
				var orgWidth = Number($(".PN_BsReport .slick-list").css("width").replace(/[^\-\.0-9]/g, ""));
				var len = $(".PN_BsReport .slick-slide").length;
				var trackWidth = 50 * len;
				var slideWidth = 100 / len;
				var width = orgWidth - Number($(".PN_mainLeft").css("width").replace(/[^\-\.0-9]/g, ""));
				var mNum = $(".PN_BsReport").slick("slickCurrentSlide");
				var addNum = len / 2;
				var subNum = Number($(".PN_BsReport .slick-slide").css("margin-right").replace("px", ""))
							+ Number($(".PN_BsReport .slick-slide").css("margin-left").replace("px", ""));
				
				$(".PN_BsReport .slick-track").css({"width": "calc(" + trackWidth + "% + " + addNum + "px)", "transform": "translate3d(-" + ((width/2) * mNum) + "px, 0px, 0px)"});
				$(".PN_BsReport .slick-slide").css("width", "calc(" + slideWidth + "% - " + subNum + "px)");
				
				$(".PN_BsReport").slick("getSlick").slideWidth = Number($(".PN_BsReport .PN_BsList").css("width").replace(/[^\-\.0-9]/g, ""))
																- (Number($(".PN_mainLeft").css("width").replace(/[^\-\.0-9]/g, "")) / 2)
																+ subNum;
			}
		});
		
		$(".PN_btnArea .btnClose").on("click", function(){
			if($(this).parents().find(".PN_mainLeft").is(":hidden") == false){
				var orgWidth = Number($(".PN_BsReport .slick-list").css("width").replace(/[^\-\.0-9]/g, ""));
				var len = $(".PN_BsReport .slick-slide").length;
				var trackWidth = 50 * len;
				var slideWidth = 100 / len;
				var width = orgWidth + Number($(".PN_mainLeft").css("width").replace(/[^\-\.0-9]/g, ""));
				var mNum = $(".PN_BsReport").slick("slickCurrentSlide");
				var addNum = len / 2;
				var subNum = Number($(".PN_BsReport .slick-slide").css("margin-right").replace("px", ""))
							+ Number($(".PN_BsReport .slick-slide").css("margin-left").replace("px", ""));
				
				$(".PN_BsReport .slick-track").css({"width": "calc(" + trackWidth + "% + " + addNum + "px)", "transform": "translate3d(-" + ((width/2) * mNum) + "px, 0px, 0px)"});
				$(".PN_BsReport .slick-slide").css("width", "calc(" + slideWidth + "% - " + subNum + "px)");
				
				$(".PN_BsReport").slick("getSlick").slideWidth = Number($(".PN_BsReport .PN_BsList").css("width").replace(/[^\-\.0-9]/g, ""))
																+ (Number($(".PN_mainLeft").css("width").replace(/[^\-\.0-9]/g, "")) / 2)
																+ subNum;
			}
		});
	},
	setReportSlide: function(){
		$(function(){
			var slider = $(".PN_BsReport");
			slider.slick({
				slide: "div",			// 슬라이드 되어야 할 태그 ex) div, li
				infinite : false,		// 무한 반복 옵션
				slidesToShow : 2,		// 한 화면에 보여질 컨텐츠 개수
				slidesToScroll : 1,		// 스크롤 한번에 움직일 컨텐츠 개수
				speed : 500,			// 다음 버튼 누르고 다음 화면 뜨는데까지 걸리는 시간(ms)
				arrows : true,			// 옆으로 이동하는 화살표 표시 여부
				dots : false,			// 스크롤바 아래 점으로 페이지네이션 여부
				autoplay : false,		// 자동 스크롤 사용 여부
				autoplaySpeed : 3000,	// 자동 스크롤 시 다음으로 넘어가는데 걸리는 시간 (ms)
				pauseOnHover : true,	// 슬라이드 이동	시 마우스 호버하면 슬라이더 멈추게 설정
				vertical : false,		// 세로 방향 슬라이드 옵션
				draggable : false,		// 드래그 가능 여부
				variableWidth: false
			});
		});
	},
	getMyProject: function() {
		$.ajax({
			url: "/groupware/bizreport/getMyProject.do",
			type: "POST",
			data: {
				"userCd": pnReport.userCode
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					$.each(data.list, function(idx, item){
						pnReport.getReportWeeklyList(item.ProjectCode, item.ProjectName);
					});
					
					if(data.list.length <= 1){
						$(".PN_BsReport").closest(".PN_myContents_box").find(".PN_portlet_function").removeClass("PN_pos");
					}
					
					pnReport.setReportSlide();
				}else{
					$(".PN_portlet_function").removeClass("PN_pos");
					$(".PN_BsReport").hide();
					$(".PN_BsReport").closest(".PN_portlet_contents").find(".PN_nolist").show();
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/bizreport/getMyProject.do", response, status, error);
			}
		});
	},
	getReportWeeklyList: function(pCode, pName){
		var projectCode = "";
		var taskGubunCode = "";
		var timeZoneStr = Common.getSession("UR_TimeZoneDisplay");
		
		if(pCode == "GT"){
			taskGubunCode = pCode;
		}else{
			projectCode = pCode;
			taskGubunCode = "P";
		}
		
		$.ajax({
			url: "/groupware/bizreport/getTaskReportWeeklyList.do",
			type: "GET",
			async: false,
			data: {
				"startDate": pnReport.sDate,
				"endDate": pnReport.eDate,
				"userCode": pnReport.userCode,
				"projectCode": projectCode,
				"taskGubunCode": taskGubunCode
			},
			success: function(data){
				var reportList = data.TaskReportWeeklyList;
				var divWrap = $("<div class='PN_BsList'></div>");
				var sDate = pnReport.sDate.replaceAll("-", ".").substr(5, pnReport.sDate.length);
				var eDate = pnReport.eDate.replaceAll("-", ".").substr(5, pnReport.eDate.length);
				
				divWrap.append($("<div class='PN_rpCont'></div>")
							.append($("<span class='PN_rpState'></span>"))
							.append($("<strong class='PN_rpDate'></strong>").text(sDate + "~" + eDate))
							.append($("<ul class='PN_rpList'></ul>")
								.append($("<li></li>").text("<spring:message code='Cache.lbl_dept'/> : " + pnReport.deptName))) // 부서  
							.append($("<span class='PN_rpTime'></span>")))
						.append($("<a class='PN_btnDetail'></a>")
							.attr("href", "/groupware/layout/bizreport_WeeklyReport.do?CLSYS=bizreport&CLMD=user&CLBIZ=BizReport"));
				
				if(pName){
					divWrap.find(".PN_rpList")
						.prepend($("<li></li>").text("<spring:message code='Cache.lbl_project_name'/> : " + pName)); // 프로젝트명 
				}
				
				if(reportList.length > 0){
					var reportDate = new Date(CFN_TransLocalTime(reportList[0].RegistDate)).format("HH:mm") + " " + timeZoneStr;
					
					divWrap.find(".PN_rpState").text("<spring:message code='Cache.lbl_ReportComplete'/>"); // 보고완료
					divWrap.find(".PN_btnDetail").text("<spring:message code='Cache.lbl_DetailView'/>"); // 상세보기
					divWrap.find(".PN_rpTime").text(reportDate + " <spring:message code='Cache.lbl_Submission'/>") // 제출
				}else{
					divWrap.addClass("PN_BsNone");
					divWrap.find(".PN_rpState").text("<spring:message code='Cache.lbl_reportn'/>"); // 미보고
					divWrap.find(".PN_btnDetail").text("<spring:message code='Cache.lbl_ReportRegist'/>"); // 보고서 등록
				}
				
				$(".PN_BsReport").append($(divWrap)[0].outerHTML);
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/bizreport/getTaskReportWeeklyList.do", response, status, error);
			}
		});
	}
}