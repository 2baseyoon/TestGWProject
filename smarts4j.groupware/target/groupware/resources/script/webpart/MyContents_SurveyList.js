/**
 * myContents_SurveyList - 마이 컨텐츠  - 설문조사
 */
var myContents_SurveyList ={
	init: function (data,ext){
		myContents_SurveyList.getSurveyList();				// 설문 조회
	},
	// 설문 조회
	getSurveyList : function() {
		$.ajax({
			type:"POST",
			url:"/groupware/survey/getWebpartSurveyListNew.do",
			data: {},
			success:function(data) {
				var tar = $('#myContents_SurveyList_ContentDiv');
				var list = data.data;
				
				var html = "";
				if(list.length>0){
					html += "<div class='pieceCont mScrollV scrollVType01' style='overflow:hidden;'>";
					html += "<ul>";
					for(var i=0;i<list.length;i++){
						var setFn = myContents_SurveyList.openPop(list[i].reqType,list[i].SurveyID,list[i].joinFg,list[i].IsTargetResultView,list[i].IsTargetRespondent,list[i].State);
						html +="<li><a href='"+setFn+"' class='title' target='_self'>"+list[i].Subject+"</a><a href='"+setFn+"' class='btnSysScMore' target='_self'></a></li>";
					}
					html += "</ul>";
					html += "</div>";
					
					tar.attr("class","systemShortCut");
				}else{
					
					tar.attr("class","piecePollScroll");
					html += '<div class="pieceMiddle">';
					html += '<div class="Survey_Nodata">';
					html += '<p class="Survey_NodataTxt">'+ "<spring:message code='Cache.msg_NoSurveyInProgress'/>" + '</p>';
					html += '</div>';
					html += '</div>';
				}
				tar.empty().append(html);
			}
		});
	},
	openPop : function(type, surveyId, joinFg, isViewer, isTarget, state) {
		var url = '';
		var reqType = "proceed";
		var communityId = typeof(cID) == 'undefined' ? 0 : cID;	// 커뮤니티ID
		
		myContents_SurveyList.updateSurveyRead(surveyId);	// 읽음 업데이트
		
		if(isTarget == "Y"){
			if(joinFg == "Y"){
				if(isViewer == "Y"){
					//전체 결과 공개
					url = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + surveyId + '&listType='+reqType+'&viewType=resultView&communityId=' + communityId;	// 전체 결과 보기
				}else{
					//자기가 한 결과만 공개
					url = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&surveyId=' + surveyId + '&listType='+reqType+'&viewType=myAnswer&communityId=' + communityId;	// 설문보기
				}
			}else{
				//참여
				url = '/groupware/layout/survey_Survey.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&reqType=join&listType='+reqType+'&surveyId=' + surveyId + '&communityId=' + communityId;	// 설문참여
			}
		}else{ // isTarget == "N"
			//전체 결과 공개
			url = '/groupware/layout/survey_SurveyView.do?CLSYS=survey&CLMD=user&CLBIZ=Survey&listType='+reqType+'&surveyId=' + surveyId + '&viewType=resultView&communityId=' + communityId;	// 설문보기
		}
		
		if (communityId != 0) 
			url += '&CSMU=C';
		
		return url;
			
	},
	updateSurveyRead:function(surveyId) {
		$.ajax({
			type : "POST",
			data : {surveyId : surveyId},
			url : "/groupware/survey/updateSurveyTargetRead.do",
			success:function (data) {
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	}
		
}

