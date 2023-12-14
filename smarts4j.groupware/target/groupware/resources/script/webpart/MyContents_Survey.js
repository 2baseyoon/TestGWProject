/**
 * myContents_Survey - 마이 컨텐츠  - 설문조사
 */
var myContents_Survey ={
	init: function (data,ext){
		myContents_Survey.getSurveyList();				// 설문 조회
	},
	setSortTable : function(){
		$( function() {
		    $( ".myContenLIneView" ).sortable({
		      connectWith: ".myContenLIneView",
		      handle: ".btnPieceMove",
		      cancel: ".pieceCont",	  
		      placeholder: "portlet-placeholder ui-corner-all"
		    });	 	 
		});	
	},
	// 설문 조회
	getSurveyList : function() {
		$.ajax({
			type:"POST",
			url:"/groupware/survey/getWebpartSurveyList.do",
			data: {},
			success:function(data) {
				var tar = $('#myContents_Survey_ContentDiv');
				
				var list = data.data;
				var className = '';
				
				var html = '';
			
				if (list.length > 0) {
					if (list[0].respondentYn == 'N') {
						className = 'piecePollScroll';
						
						html += '<div class="mScrollV scrollVType01" style="height: 87px;">';
						html += '<div class="pieceMiddle pollBarLine" style="height: auto;">';
						html += '	<div class="clearFloat pollCont flowerPopupText">';
						var svyTitle = "";
						if(list[0].Subject.length>26) {
							svyTitle = list[0].Subject.substr(0, 26).match(/.{12}/g).join("<br/>")+"..";
						}else if(list[0].Subject.length>13) {
							svyTitle = list[0].Subject.substr(0, 13)+"<br/>"+list[0].Subject.substr(13, list[0].Subject.length);
						}else{
							svyTitle = list[0].Subject
						}
						html += '		<div class="tit" style="line-height:20px;width:100%;padding-bottom: 10px;min-height: 62px;" title="'+list[0].Subject+'">' + svyTitle + '</div>';
						html += '	</div>';
						html += '</div>';

						html += '</div>';
						
						html += '<div class="pieceCont">';
						html += '<input type="hidden" id="surveyId" value="' + list[0].SurveyID + '">';
						html += '<input type="hidden" id="questionId" value="' + list[0].QuestionID + '">';
						html += '<div class=" pollSelList mScrollV scrollVType01" style="height: 118px">';
						html += '<div>';
						$.each(list, function(i, v) {
							if (v.Item != '') {
								html += '<div class="radioStyle03 pollBarLine" style="height:20px;">';
								html += '	<div class="clearFloat pollCont flowerPopupText">';
								html += '<input type="radio" id="pppp' + i + '" name="radioBox" value="' + v.ItemID + '"><label class="tit" for="pppp' + i + '" style="line-height:18px;width:100%;padding: 0 0;" title="'+v.Item+'"><span></span>' + v.Item + '</label>';
								html += '</div>';
								html += '</div>';
							}
						});
						html += '</div>';
						html += '</div>';
						html += '<div class="pllSelBtn">';
						html += '<a href="#" class="btnTypeDefault btnTypeChk" onClick="myContents_Survey.joinSurvey();">'+ "<spring:message code='Cache.lbl_SurveyParticipant'/>" +'</a>';
						html += '</div>';
						html += '</div>';
					} else {
						className = 'piecePoll';
						html += '<div class="mScrollV scrollVType01" style="height: 250px;">';
						html += '<div class="pieceCont pollBarLine" style="height: auto;">';
						html += '	<div class="clearFloat pollCont flowerPopupText">';
						html += '		<div class="tit" style="line-height:23px;width:100%;padding: 0 0;" title="'+list[0].Subject+'">' + list[0].Subject + '</div>';
						html += '	</div>';
						html += '	<div class="clearFloat pollCont">';
						var descTxt = list[0].Description.replace(/(<([^>]+)>)/gi, "");
						html += '		<div class="tit" style="line-height:25px;width:100%;padding: 0 0;"  title="'+descTxt+'">' + descTxt + '</div>';
						html += '	</div>';
						html += '<p class="date">' + CFN_TransLocalTime(list[0].RegistDate) + '</p>';
						html += '	<div class="pollBar">';
						$.each(list, function(i, v) {
							if (v.Item != '') {
								html += '<div class="pollBarLine';
								if (i == 0) html += ' majority';
								html += '">';
								html += '<div class="bgBar">';
								html += '	<div class="percentBg" style="width:' + Math.round(v.rate) + '%;"></div>';
								html += '</div>';
								html += '<div class="clearFloat pollCont">';
								html += '	<div class="tit">' + v.Item + '</div>';
								html += '	<div class="percentNum">' + Math.round(v.rate) + '%</div>';
								html += '</div>';
								html += '</div>';
							}
						});
						html += '	</div>';
						html += '	<p class="hCount">' + list[0].totCnt + "<spring:message code='Cache.lbl_Participation_User'/>" +'</p>';
						html += '</div>';
						html += '</div>';
					}
				} else {
					className = 'piecePollScroll';
					
					html += '<div class="pieceMiddle">';
					html += '<div class="Survey_Nodata">';
					html += '<p class="Survey_NodataTxt">'+ "<spring:message code='Cache.msg_NoSurveyInProgress'/>" + '</p>';
					html += '</div>';
				}

				$('#myContents_Survey_Div').removeClass('piecePollScroll', 'piecePoll').addClass(className);
				
				tar.empty().append(html);
				
				coviCtrl.bindmScrollV($('#myContents_Survey_Div').find('.mScrollV'));
			}
		});
	},
	// 설문 참여
	joinSurvey: function() {
		var tar = $("#myContents_Survey_ContentDiv > .pieceCont input[type='radio']:checked");
		var tarVal = tar.val();
		var surveyId = $('#surveyId').val();
		var questionId = $('#questionId').val();
		
		if (typeof(tarVal) == 'undefined') {
			Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>");
			return;
		} else {
			var surveyInfo = new Object();
			surveyInfo.surveyID = surveyId;
			surveyInfo.etcOpinion = '';
			
			var obj = new Object();
			obj.surveyID = surveyId;
			obj.questionID = questionId;
			obj.questionNO = 1;
			obj.groupingNo = 0;
			obj.itemID = tarVal;
			obj.answerItem = tar.siblings('label').text();
			obj.etcOpinion = '';
			obj.weighting = '';
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
									myContents_Survey.getSurveyList();	// 설문 조회
				          		} else {
				          			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");  //오류가 발생했습니다.
				          		}
							}
						},
						error:function(response, status, error) {
							CFN_ErrorAjax(url, response, status, error);
						}
					});		
				} else {
					return false;
				}
			});
		}
	}
}

