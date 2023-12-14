/**
 * MyContents : 설문
 */
var ctnSurvey = {
	init: function (data, ext, caller, webPartID) {
		ctnSurvey.getSurveyList(webPartID);	
	},
	// 설문 조회
	getSurveyList : function(webPartID) {
		$.ajax({
			type:"POST",
			url:"/groupware/survey/getWebpartSurveyData.do",
			data: {},
			success:function(data) {
				if(data.status == "SUCCESS"){
					var list = data.data;
					if(!coviUtil.isMobile()){
						// PC
						if (list.length > 0) {
							if (list[0].QuestionCount == 1 && list[0].QuestionType == "S") {
								// 객관식 단건
								ctnSurvey.drawOneSelectSurvey(webPartID, list);							
							}else{
								// 객관식 단건 이외
								ctnSurvey.drawOthersSurvey(webPartID, list);
							}
						}
						var writeUrl = "/groupware/layout/survey_SurveyWrite.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=create&surveyId=&communityId=0";
						coviUtil.webpartDrawEmpty(list, "Contents", webPartID, Common.getDic('msg_NoSurveyInProgress'), writeUrl);						
					} else {
						// mobile
						if (list.length > 0) {
							ctnSurvey.drawOthersSurvey(webPartID, list);						
						}else{
							coviUtil.webpartDrawEmpty(list, "Contents", webPartID, mobile_comm_getDic('msg_NoSurveyInProgress'));	
						}
					}

				} // status
			}
		});
	},
	// 객관식 단건
	drawOneSelectSurvey : function(webPartID, list){
		let preId = webPartID!=undefined?"#"+webPartID+" ":"";
		var widgetSurvey = $(preId + ".widget_content").empty();
		var svyTitle = "";
		if(list[0].Subject.length>26) {
			svyTitle = list[0].Subject.substr(0, 26)+"..";
		} else {
			svyTitle = list[0].Subject;
		}

		if (list[0].respondentYn == "N") {
			// 설문 응답전 
			$(preId).removeClass("widget_poll").removeClass("widget_survey").removeClass("widget_survey_ongoing").addClass("widget_poll");
			widgetSurvey.append($("<input>", {"type" : "hidden" , "id" : "surveyId", "value": list[0].SurveyID}))
				.append($("<input>", {"type" : "hidden" , "id" : "questionId", "value": list[0].QuestionID}))
				.append($("<div>", {"class" : "form"})
					.append($("<h4>")
						.append($("<span>", {"text" : svyTitle}))
					)
					.append($("<div>" , {"data-custom-scrollbar":""})
						.append($("<div>", {"class" : "content_list"})
							.append($("<ul>"))
						)
					)
				)
				.append($("<div>", {"class":"widget_link"})
					.append($("<a>",{"href":"#"})
						.append($("<span>", {"text" : Common.getDic('lbl_SurveyParticipant')}))
					).on("click", function(){
						ctnSurvey.joinSurvey(webPartID)})
				);
				
				$.each(list, function(i, item) {
					if (item.Item != '') {
						widgetSurvey.find("ul")
							.append($("<li>")
								.append($("<label>" , {"class" : "ui_checkbox"})
									.append($("<input>" , {"type" : "radio" , "name" : "poll", "id": "pppp"+i , "value" : item.ItemID }))
										.append($("<i>"))
										.append($("<span>", {"text": item.Item}))
								)
							);
					}
				});
				$('[data-custom-scrollbar]').each(function (index, element) {
	        	    new SimpleBar(element);
		        });
				
			} else {
				// 설문 응답후 
				var moveLink = "";
				if(list[0].registerYn == "Y"){
					//전체 결과 공개
					moveLink = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + list[0].SurveyID + '&listType=proceed&viewType=resultView&communityId=0';	// 전체 결과 보기
				}else{
					//자기가 한 결과만 공개						
					moveLink = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + list[0].SurveyID + '&listType=proceed&viewType=myAnswer&communityId=0';	// 설문보기
				}
				$(preId).removeClass("widget_poll").removeClass("widget_survey").removeClass("widget_survey_ongoing").addClass("widget_survey");
				widgetSurvey.append($("<h4>",{"class":"survey_title"})
					.append($("<a>",{"text" : svyTitle , "href" : moveLink}))
				)
				.append($("<div>",{"data-custom-scrollbar":""})
					.append($("<div>",{"class":"content_list"}))
				
				);
				
				$.each(list, function(i, item) {
					if (item.Item != '') {
						widgetSurvey.find(".content_list")
							.append($("<div>", {"class":"survey_option"})
								.append($("<dl>", {"class":"info"})
									.append($("<dt>",{"text":item.Item}))
									.append($("<dd>",{"text":Math.round(item.rate)+"%"}))
								)
								.append($("<div>",{"class":"widget_progress c"+Number(i%3+1)})
									.append($("<div>", {"class":"bar", "style":"width:"+Math.round(item.rate)+"%"}))
								)
							);
						}
				});
				
				$('[data-custom-scrollbar]').each(function (index, element) {
	        	    new SimpleBar(element);
		        });
				
				
			}
	},
	// 객관식 단건 이외
	drawOthersSurvey : function(webPartID, list){
		let preId = webPartID!=undefined?"#"+webPartID+" ":"";
		var widgetSurvey = $(preId + ".widget_content").empty();
		$(preId).removeClass("widget_poll").removeClass("widget_survey").removeClass("widget_survey_ongoing").addClass("widget_survey_ongoing");
		var joinStr = "";
		var moveLink = "";
		var btnText = "";
		var joinClass = "";
		if (list[0].respondentYn == "N") {
			// 설문 응답전 
			joinClass = "";
			if(coviUtil.isMobile()){
				joinStr = mobile_comm_getDic('lbl_Nonparticipation'); // 미참여
				btnText = mobile_comm_getDic('lbl_SurveyParticipant'); //설문참여
				moveLink = "javascript: mobile_comm_go('/groupware/mobile/survey/survey.do?surveyid="+list[0].SurveyID+"&stype=proceed&mysel=written&mysel=written','Y')";
			}else{
				joinStr = Common.getDic('lbl_Nonparticipation'); // 미참여
				btnText = Common.getDic('lbl_SurveyParticipant'); // 설문참여
				moveLink = "/groupware/layout/survey_Survey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=join&listType=proceed&communityId=0&surveyId=" + list[0].SurveyID;
			}
		} else {
			// 설문 응답후
			joinClass = "on";
			if(coviUtil.isMobile()){
				joinStr = mobile_comm_getDic('lbl_survey_participation'); // 참여
				btnText = mobile_comm_getDic('btn_Viewresults'); // 결과보기
				moveLink = "javascript: mobile_comm_go('/groupware/mobile/survey/result.do?surveyid="+list[0].SurveyID+"&stype=proceed&mysel=written&mysel=written','Y')";
			}else{
				joinStr = Common.getDic('lbl_survey_participation'); // 참여
				btnText = Common.getDic('btn_Viewresults'); // 결과보기
				if(list[0].registerYn == "Y"){
					//전체 결과 공개
					moveLink = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + list[0].SurveyID + '&listType=proceed&viewType=resultView&communityId=0';	// 전체 결과 보기
				}else{
					//자기가 한 결과만 공개						
					moveLink = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + list[0].SurveyID + '&listType=proceed&viewType=myAnswer&communityId=0';	// 설문보기
				}
			}
		}
		widgetSurvey.append($("<div>", {"class" : "form"})
				.append($("<em>",{"text" : joinStr, "class": joinClass}))
				.append($("<h4>",{"text" : list[0].Subject}))
				.append($("<time>",{"text" : list[0].SurveyStartDate + "~" + list[0].SurveyEndDate}))
				.append($("<strong>",{"text" : Math.round(list[0].joinRate) + "% "+"<spring:message code='Cache.lbl_survey_participation'/>"}))
				.append($("<div>", {"class" : "widget_progress"})
					.append($("<span>", {"class" : "bar" , "style":"width:"+Math.round(list[0].joinRate)+"%"}))
					)
			)
			.append($("<div>", {"class" : "widget_link"})
				.append($("<a>",{"href" : moveLink})
					.append($("<span>",{"text":btnText}))
				)
			);	
	},
	// 클릭시 팝업
	linkSurveyUrl : function(opt, surveyID){
		if(opt == "result"){
		popupID		= "surveyResultPopup";
		popupTit	= Common.getDic("lbl_surveyResultView"); // 설문 결과 조회
		popupUrl	= "/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&listType=proceed&viewType=resultView&communityId=0&surveyId=" + surveyID;
		}
		Common.open("", popupID, popupTit, popupUrl, "1000px", "600px", "iframe", true, null, null, true);
	},
	// 설문 참여
	joinSurvey: function(webPartID) {
		let preId = webPartID!=undefined?"#"+webPartID+" ":"";
		var tar = $(preId + ".widget_content input[type='radio']:checked");
		var tarVal = tar.val();
		var surveyId = $('#surveyId').val();
		var questionId = $('#questionId').val();
		
		if (typeof(tarVal) == 'undefined') {
			Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>"); //대상을 선택해주세요.
			return;
		} else {
			var surveyInfo = new Object();
			surveyInfo.surveyID = surveyId;
			surveyInfo.etcOpinion = '';
			
			var obj = new Object();
			obj.surveyID = surveyId;
			obj.questionID = questionId;
			obj.itemID = tarVal;
			obj.answerItem = tar.siblings('span').text();
			obj.etcOpinion = '';
			obj.weighting = '';
			obj.questionNO = 1;
			obj.groupingNo = 0;
			obj.questionType = 'S';
			
			var answers = new Array();
			answers.push(obj);

			surveyInfo.answers = answers;
			
	       	Common.Confirm("<spring:message code='Cache.Msg_Admin_4'/>", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
			 		$.ajax({
						type : "POST",
						data : {surveyID : surveyInfo.surveyID, surveyInfo : JSON.stringify(surveyInfo)},
						url : "/groupware/survey/insertQuestionItemAnswer.do",
						success:function (data) {
							if (data.result == "ok") {
								if (data.status == 'SUCCESS') {
									ctnSurvey.getSurveyList(webPartID);	// 설문 조회
				          		} else {
				          			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");  //오류가 발생했습니다.
				          		}
							}
						},
						error:function(response, status, error) {
							CFN_ErrorAjax(url, response, status, error);
						}
					});		
				} 
			});
		}
	}
}