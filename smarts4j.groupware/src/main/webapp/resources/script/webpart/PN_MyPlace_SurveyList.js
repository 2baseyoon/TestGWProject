/**
 * pnSurveyList - [포탈개선] My Place - 진행중인 설문
 */
var pnSurveyList = {
	webpartType: "", 
	init: function(data, ext){
		pnSurveyList.setEvent();
		pnSurveyList.getSurveyList();
	},
	setEvent: function(){
		$(".PN_survey").closest(".PN_myContents_box").find(".PN_portlet_btn").off("click").on("click", function(){
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

		$(".PN_survey").closest(".PN_myContents_box").find(".PN_portlet_close").click(function(){
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn").removeClass("active");
			$(this).parents(".PN_portlet_menu").stop().slideUp(300);
			$(this).parents(".PN_portlet_function").find(".PN_portlet_btn > span").removeClass("on");
		});
		
		$(".PN_survey").closest(".PN_myContents_box").find(".PN_portlet_menu li[mode=write]").off("click").on("click", function(){
			window.open("/groupware/layout/survey_SurveyWrite.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=create&surveyId=&communityId=0");
		});
	},
	getSurveyList: function() {
		$.ajax({
			url: "/groupware/survey/getSurveyList.do",
			type: "POST",
			data: {
				pageNo: 1,
				pageSize: 1,
				reqType: "proceed",
				schContentType: "subject",
				schMySel: "written",
				notReadFg: "N",
				schTxt: "",
				simpleSchTxt: "",
				communityId: 0,
				startDate: "",
				endDate: ""
			},
			success: function(data){
				if(data.status == "SUCCESS"){
					var surveyList = data.list;
					
					if(surveyList && surveyList.length != 0){
						var surveyInfo = surveyList[0];
						var divWrap = $("<div class='PN_surveyCont'></div>");
						var percent = Math.floor(Number(surveyInfo.joinRate)) + "%";
						var joinStr = "";
						var btnStr = "";
						var linkUrl = "";
						if(surveyInfo.IsTargetRespondent == "Y"){
							if(surveyInfo.joinFg == "Y"){
								joinStr = "<spring:message code='Cache.lbl_survey_participation'/>"; // 참여	
								btnStr = "<spring:message code='Cache.btn_Viewresults'/>"; // 결과보기
								if(surveyInfo.IsTargetResultView == "Y"){
									//전체 결과 공개
									linkUrl = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + surveyInfo.SurveyID + '&listType=proceed&viewType=resultView&communityId=0';	// 전체 결과 보기
								}else{
									//자기가 한 결과만 공개						
									linkUrl = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + surveyInfo.SurveyID + '&listType=proceed&viewType=myAnswer&communityId=0';	// 설문보기
								}
							}else{
								//참여
								joinStr = "<spring:message code='Cache.lbl_Nonparticipation'/>"; //미참여
								btnStr = "<spring:message code='Cache.lbl_SurveyParticipant'/>"; // 설문참여
								linkUrl = '/groupware/layout/survey_Survey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=join&listType=proceed&surveyId=' + surveyInfo.SurveyID + '&communityId=0';	// 설문참여
							}
						}else{
							//전체 결과 공개
							joinStr = "<spring:message code='Cache.lbl_Nonparticipation'/>"; //미참여
							btnStr = "<spring:message code='Cache.btn_Viewresults'/>"; // 결과보기
							linkUrl = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&listType=proceed&surveyId=' + surveyInfo.SurveyID + '&viewType=resultView&communityId=0';	// 설문보기
						}
						
						divWrap.append($("<span class='sPart'></span>").text(joinStr))
								.append($("<span class='sTitle'></span>").text(surveyInfo.Subject))
								.append($("<span class='sPeriod'></span>").text(CFN_TransLocalTime(surveyInfo.SurveyStartDate,'yyyy.MM.dd') + " ~ " + CFN_TransLocalTime(surveyInfo.SurveyEndDate,'yyyy.MM.dd')))
								.append($("<div class='PN_graphBox_sv'></div>")
									.append($("<span class='PN_graphPer_sv'></span>").text(percent + " <spring:message code='Cache.lbl_survey_participation'/>")) // 참여
									.append($("<div class='PN_graph_sv'></div>")
										.append($("<span class='PN_graphBar_sv'></span>")
											.css("width", percent))));
						
						$(".PN_survey").append(divWrap)
							.append($("<a class='PN_btnLink'></a>")
								.attr("href", linkUrl)
								.append($("<span></span>").text(btnStr)));
					}else{
						$(".PN_survey").closest(".PN_portlet_contents").find(".PN_nolist").show();
						$(".PN_survey").hide();
					}
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax("/groupware/survey/getSurveyList.do", response, status, error);
			}
		});
	}
}