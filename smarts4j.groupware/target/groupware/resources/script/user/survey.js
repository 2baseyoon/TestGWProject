var gDataArr = new Array();	// 그룹
//개별호출 일괄호출
Common.getDicList(["lbl_surveyDirection","btn_delete","lbl_Description","lbl_addOptions","lbl_Copy","lbl_closeGroup","lbl_deleteGroup","lbl_deleteImage",
"lbl_Exit","lbl_groupTransfer","lbl_File","lbl_ImageAdd","lbl_otherOpinions","lbl_surveyAddOther","lbl_subjectiveText","lbl_subjective","lbl_surveyPluralAnswer",
"lbl_surveyMsg15","lbl_surveyMsg16","lbl_Require","lbl_RankingSelect","lbl_untitledQuestion","lbl_objective","lbl_movementArea","lbl_view", "lbl_guideInfo", "btn_OrgManage"]);
// 지문 div
var exPlanTitleEl = $("<div/>", {'class' : 'exPlanTitle inputFocusConten'})
	.append($("<span/>", {})
		.append($("<input/>", {'class' : 'inpStyle01 type02 inpFocus paragraphText', attr : {type : 'text', placeholder : coviDic.dicMap["lbl_surveyDirection"]}})))
	.append($("<a/>", {'class' : 'btnTypeDefault type02 delDBtn', attr : {href : '#'}, text : coviDic.dicMap["btn_delete"]}));

// 설명 div
var exPlanTextEl = $("<div/>", {'class' : 'exPlanText inputFocusConten'})
	.append($("<span/>", {})
		.append($("<input/>", {'class' : 'inpStyle01 type04 inpFocus descriptionText', attr : {type : 'text', placeholder : coviDic.dicMap["lbl_Description"]}})));

// 지문 + 설명 div
var exPlanDivEl = $("<div/>", {'class' : 'explanationCont'})
	.append(exPlanTitleEl.clone(), exPlanTextEl.clone());

// 문항 헤더
var questionHeaderEl = $("<a/>", {'class' : 'sruQuestContMove sortEl-header'});

// 문항 번호
var questionNumEl = $("<div/>", {'class' : 'ribbon', text: '1'});

// 다음 문항 번호
var questionNextNumEl = $("<div/>", {'class' : 'qNNum', css : {'display' : 'none'}, text: '99'});

// 문항
var questionTextEl = $("<span/>", {})
	.append($("<input/>", {'class' : 'inpStyle01 type02 inpFocus questionText HtmlCheckXSS ScriptCheckXSS',	attr : {type : 'text', placeholder : coviDic.dicMap["lbl_untitledQuestion"]}}));

// 문항유형
var questionTypeEl = $("<select/>", {'class' : 'selectType02 qTypeSelBox'})
	.append($('<option/>').text(coviDic.dicMap["lbl_objective"]).val('S'), $('<option/>').text(coviDic.dicMap["lbl_subjective"]).val('D'), $('<option/>').text(coviDic.dicMap["lbl_surveyPluralAnswer"]).val('M'), $('<option/>').text(coviDic.dicMap["lbl_RankingSelect"]).val('N'));

// 문항 div
var questionTitleEl = $("<div/>", {'class' : 'title inputFocusConten'})
	.append(questionTextEl.clone(), questionTypeEl.clone());

// 문항 최종 div
var questionDivEl = $("<div/>", {'class' : 'sruTitleCont'})
	.append(questionNumEl.clone(), questionNextNumEl.clone(), questionTitleEl.clone());

// 보기 이동영역
var itemHeaderEl = $("<a/>", {'class' : 'btnMoveStyle01 sortEl-header', attr : {href : '#'}, text : coviDic.dicMap["lbl_movementArea"]});

// 보기 라디오 버튼
var itemRadioEl = $('<div/>', {'class' : 'radioStyle03'})
	.append($("<label/>", {attr : {'for' : 'sqId01'}})
		.append('<span></span'));

// 보기 체크박스
var itemCheckboxEl = $('<div/>', {'class' : 'chkStyle02'})
	.append($("<label/>", {attr : {'for' : 'sqChk01'}})
		.append('<span></span'));

// 보기 세모
var itemTriangleEl = $('<div/>', {'class' : 'triangleStyle01'})
	.append($("<label/>", {attr : {'for' : 'sqChk01'}})
		.append('<span></span'));

// 보기(객관식, 복수응답)
var itemInputEl = $("<input/>", {attr : {type : 'text'}, placeholder : coviDic.dicMap["lbl_view"] + '1', 'class' : 'inpStyle01 type03 inpFocus itemTxt HtmlCheckXSS ScriptCheckXSS'});

// 보기 사진 올리기
var itemImageEl = $("<a/>", {'class' : 'btnPhotoUpload', attr : {href : '#'}, text : coviDic.dicMap["lbl_ImageAdd"]});

// 보기 분기
var itemDivSelEl = $("<select/>", {'class' : 'selectType02 iDivSel'});

// 보기 삭제
var itemDelEl = $("<a/>", {'class' : 'btnExDel', attr : {href : '#'}});

// 보기(객관식)
var itemSSumDivEl = $("<div/>", {'class' : 'exList'})
	.append($('<div/>', {'class' : 'titleStyle01'})
		.append(itemRadioEl.clone(), itemInputEl.clone()))
	.append($('<div/>', {'class' : 'btnBox'})
		.append(itemImageEl.clone(), itemDivSelEl.clone(), itemDelEl.clone()))
	.append($('<div/>', {css : {display : 'none'}})
		.append($('<input/>', {'class' : 'fileIds'}))
		.append($('<input/>', {'class' : 'updateFileIds'}))
		.append($('<input/>', {'class' : 'deleteFileIds'})));

// 보기(주관식)
var itemDSumDivEl = $("<div/>", {'class' : 'exList'})
	.append($('<div/>', {'class' : 'titleStyle01'})
		.append($("<span/>", {})
			.append($("<input/>", {attr : {type : 'text', placeholder : coviDic.dicMap["lbl_subjectiveText"], readonly : true}, 'class' : 'inpStyle01 type04 itemTxt'}))))
	.append($('<div/>', {'class' : 'btnBox'})
	.append(itemDivSelEl.clone()))
	.append($('<div/>', {css : {display : 'none'}})
		.append($('<input/>', {'class' : 'fileIds'}))
		.append($('<input/>', {'class' : 'updateFileIds'}))
		.append($('<input/>', {'class' : 'deleteFileIds'})));

// 보기(복수응답)
var itemMSumDivEl = $("<div/>", {'class' : 'exList'})
	.append($('<div/>', {'class' : 'titleStyle01'})
		.append(itemCheckboxEl.clone(), itemInputEl.clone()))
	.append($('<div/>', {'class' : 'btnBox'})
		.append(itemImageEl.clone(), itemDelEl.clone()))
	.append($('<div/>', {css : {display : 'none'}})
		.append($('<input/>', {'class' : 'fileIds'}))
		.append($('<input/>', {'class' : 'updateFileIds'}))
		.append($('<input/>', {'class' : 'deleteFileIds'})));		

// 보기(순위선택)
var itemNSumDivEl = $("<div/>", {'class' : 'exList'})
	.append($('<div/>', {'class' : 'titleStyle01 type02'})
		.append($("<span/>", {})
			.append(itemInputEl.clone())))
	.append($('<div/>', {'class' : 'btnBox'})
		.append(itemImageEl.clone(), itemDelEl.clone()))
	.append($('<div/>', {css : {display : 'none'}})
		.append($('<input/>', {'class' : 'fileIds'}))
		.append($('<input/>', {'class' : 'updateFileIds'}))
		.append($('<input/>', {'class' : 'deleteFileIds'})));		

// 보기(객관식) 최종 div
var itemSDivEl = $("<div/>", {'class' : 'sruQuestListDivi inputFocusConten itemDtl'})
	.append(itemHeaderEl.clone(), itemSSumDivEl.clone());

// 보기(주관식) 최종 div
var itemDDivEl = $("<div/>", {'class' : 'sruQuestListDivi inputFocusConten itemDtl'})
	.append(itemDSumDivEl.clone());

// 보기(복수응답) 최종 div
var itemMDivEl = $("<div/>", {'class' : 'sruQuestListDivi inputFocusConten itemDtl'})
	.append(itemHeaderEl.clone(), itemMSumDivEl.clone());

// 보기(순위선택) 최종 div
var itemNDivEl = $("<div/>", {'class' : 'sruQuestListDivi inputFocusConten itemDtl'})
	.append(itemHeaderEl.clone(), itemNSumDivEl.clone());

// 보기(객관식) 히든 div
var itemSHidDivEl = $("<div/>", {'class' : 'sruQuestListDivi inputFocusConten item-hidden'})
	.append(itemHeaderEl.clone(), itemSSumDivEl.clone());

// 보기(복수응답) 히든 div
var itemMHidDivObj = $("<div/>", {'class' : 'sruQuestListDivi inputFocusConten item-hidden'})
	.append(itemHeaderEl.clone(), itemMSumDivEl.clone());

// 보기(순위선택) 히든 div
var itemNHidDivObj = $("<div/>", {'class' : 'sruQuestListDivi inputFocusConten item-hidden'})
	.append(itemHeaderEl.clone(), itemNSumDivEl.clone());

// 보기 기타 히든 div
var itemTextHidDivObj = $("<div/>", {'class' : 'sruQuestListDivi inputFocusConten item-text-hidden'})
	.append($("<div/>", {'class' : 'exList'})
		.append($('<div/>', {'class' : 'titleStyle01'})
			.append(itemRadioEl.clone())
			.append($("<input/>", {attr : {type : 'text', readonly : true, placeholder : coviDic.dicMap["lbl_otherOpinions"]},	css : {'opacity' : '1!important;'},	'class' : 'inpStyle01 type03 inpFocus'})))
		.append($('<div/>', {'class' : 'btnBox'})
			.append(itemDelEl.clone(), itemDivSelEl.clone())));

// 보기 추가
var itemAddEl = $("<a/>", {'class' : 'btnSruOptionAdd', attr : {href : '#'}, text : coviDic.dicMap["lbl_addOptions"]});

// 보기 기타 추가
var itemTextAddEl = $("<a/>", {'class' : 'btnSruOtherAdd',	attr : {href : '#'}, text : coviDic.dicMap["lbl_surveyAddOther"]});

// 보기(객관식) 추가(보기 추가 + 기타 추가) div
var itemSAddDivObj = $('<div/>', {'class' : 'titleStyle01 itemAdd',})
	.append(itemRadioEl.clone(), itemAddEl.clone(), ' or ', itemTextAddEl.clone());

// 보기(복수응답) 추가(보기 추가 + 기타 추가) div
var itemMAddDivEl = $('<div/>', {'class' : 'titleStyle01 itemAdd',})
	.append(itemCheckboxEl.clone(), itemAddEl.clone());

// 보기(순위선택) 추가(보기 추가) div
var itemNAddDivEl = $('<div/>', {'class' : 'titleStyle01 itemAdd',})
	.append(itemTriangleEl.clone(), itemAddEl.clone());

// 보기 추가(객관식) 최종 div
var itemSAddEl = $('<div/>', {'class' : 'sruQuestListDivi notSort'})
	.append($('<div/>', {'class' : 'exListAdd',})
		.append(itemSAddDivObj.clone()));

// 보기 추가(복수응답) 최종 div
var itemMAddEl = $('<div/>', {'class' : 'sruQuestListDivi notSort'})
	.append($('<div/>', {'class' : 'exListAdd'})
		.append(itemMAddDivEl.clone()));

// 보기 추가(순위선택) 최종 div
var itemNAddEl = $('<div/>', {'class' : 'sruQuestListDivi notSort'})
	.append($('<div/>', {'class' : 'exListAdd'})
		.append(itemNAddDivEl.clone()));

// 그룹 이동
var questionMoveEl = $("<select/>", {'class' : 'selectType02 gMDivSel'});

// 문항 옵션
var questionOptionEl = $("<div/>", {'class' : 'itemSetOption'})
	.append($("<div/>", {'class' : 'alarm type01'})
		.append('<span>' + coviDic.dicMap["lbl_Require"] + '</span>')
		.append($("<a/>", {'class' : 'onOffBtn qReq', attr : {href : '#'}})
			.append($("<span>"))))
		.append($("<input>", {'class':'requiredInfo', placeholder : coviDic.dicMap["lbl_guideInfo"],'style':'margin-right:10px;display:none;'}))
	.append($("<a/>", {'class' : 'btnTypeDefault type02 qCopy', attr : {href : '#'}, text : coviDic.dicMap["lbl_Copy"]}))
	.append($("<a/>", {'class' : 'btnTypeDefault type02 qDel', attr : {href : '#'},	text : coviDic.dicMap["btn_delete"]}));

// 문항 (객관식) 최종 div
var surveySDivEl = $("<div/>", {'class' : 'sruQuestCont multiChoice selectTypeView sortEl'})
	.append(questionHeaderEl.clone(), questionDivEl.clone(), itemSDivEl.clone(), itemSHidDivEl.clone(), itemTextHidDivObj.clone(), itemSAddEl.clone(), questionOptionEl.clone());

// 문항 (주관식) 최종 div
var surveyDDivEl = $("<div/>", {'class' : 'sruQuestCont multiChoice selectTypeView sortEl'})
	.append(questionHeaderEl.clone(), questionDivEl.clone(), itemDDivEl.clone(), questionOptionEl.clone());

// 문항 (복수응답) 최종 div
var surveyMDivEl = $("<div/>", {'class' : 'sruQuestCont multiChoice selectTypeView sortEl'})
	.append(questionHeaderEl.clone(), questionDivEl.clone(), itemMDivEl.clone(), itemMHidDivObj.clone(), itemTextHidDivObj.clone(), itemMAddEl.clone(), questionOptionEl.clone());

// 문항 (순위선택) 최종 div
var surveyNDivEl = $("<div/>", {'class' : 'sruQuestCont multiChoice selectTypeView sortEl'})
	.append(questionHeaderEl.clone(), questionDivEl.clone(), itemNDivEl.clone(), itemMHidDivObj.clone(), itemTextHidDivObj.clone(), itemNAddEl.clone(), questionOptionEl.clone());

// 문항(객관식)
var surveyQSDivEl = $("<div/>", {'class' : 'surveyMakeBox'})
	.append(surveySDivEl.clone());

// 문항(주관식)
var surveyQDDivEl = $("<div/>", {'class' : 'surveyMakeBox'})
	.append(surveyDDivEl.clone());

// 문항(복수응답)
var surveyQMDivEl = $("<div/>", {'class' : 'surveyMakeBox'})
	.append(surveyMDivEl.clone());

// 문항(순위선택)
var surveyQNDivEl = $("<div/>", {'class' : 'surveyMakeBox'})
	.append(surveyNDivEl.clone());

// 그룹 번호
var groupNumEl = $("<span/>", {'class' : 'gNumTxt', css : {'display' : 'none'}, text: '1'});

// 그룹 분기 selectbox
var groupDivSelEl = $("<select/>", {'class' : 'selectType02 gDivSel'});

// 그룹분기
var groupSelEl = $("<div/>", {'class' : 'groupQuartSelect'})
	.append(groupDivSelEl.clone());

// 그룹 명
var groupTitleEl = $("<div/>", {'class' : 'sgTitle'})
	.append($("<div/>", {})
		.append($("<input/>", {attr : {type : 'text', placeholder : coviDic.dicMap["lbl_surveyMsg15"]},'class' : 'inpStyle01 type01 gName'})))
	.append($("<div/>", {})
		.append($("<a/>", {'class' : 'btnTypeArrUpDown bntGroupContClose', attr : {href : '#'}, text : coviDic.dicMap["lbl_closeGroup"]}))
		.append($("<a/>", {'class' : 'btnTypeXClose', attr : {href : '#'}, text : coviDic.dicMap["lbl_deleteGroup"]})));

// 그룹 문항
var groupDivEl = $("<div/>", {'class' : 'surMListcont group sortEl'})
	.append(groupNumEl.clone(), groupTitleEl.clone(), surveyQSDivEl.clone(), groupSelEl.clone());

// 옵션(종료)
var selOptionEndEl = $("<option/>", {value: "99", text : coviDic.dicMap["lbl_Exit"]});

// 이미지
var photoDivEl = $("<div/>", {'class' : 'photoBox'});

// 이미지 detail
var photoDetailDivEl = $("<div/>", {'class' : 'photoImg delete frontPhoto'})
	.append($("<img/>", {src : '', alt : '', width : 106, height : 104}))
	.append($("<a/>", {'class' : 'btnPhotoRemove', attr : {href : '#'}, text : coviDic.dicMap["lbl_deleteImage"]}));

// 조직도 item
var orgMapDivEl = $("<div/>", {'class' : 'ui-autocomplete-multiselect-item', attr : {type : '', code : ''}})
	.append($("<span/>", {'class' : 'ui-icon ui-icon-close'}));

// sortable
function sortable() {
	$('.sortEl').sortable({
		handle:'.sortEl-header',
		axis: 'y',
		placeholder: "sortEl-placeholder",
		start: function(e, ui){
			if (ui.item.parent().hasClass('surMListcont')) {
				ui.placeholder.width(ui.helper.width());
			} else {
				ui.placeholder.width(ui.helper.width() - 30);
			}
		},
        items: "> div:not(.sruTitleCont, .itemSetOption, .notSort, .sgTitle, .item-text, .groupQuartSelect)",
        update: function(e) {
        	syncGroupInfo();	// 그룹 정보, 번호, 문항 번호
        }
    });
}

// syncGroupArr
function syncGroupArr() {
	gDataArr = new Array();
	var gData = null;
	$('.surveyMakeListView .group').each(function (i, v) {
		gData = new Array();
		gData.push(i);
		gData.push($(this).find('.surveyMakeBox').length);
		gDataArr.push(gData);
	});
}

// 그룹 정보, 번호, 문항 번호
function syncGroupInfo() {
	syncGroupArr();	// syncGroupArr
	
	var gLen = gDataArr.length;
	if (gLen == 0) {
		var qCnt = 1;
		var qLen = $('.surveyMakeBox').length
		$('.surveyMakeBox').each(function (i, v) {
			$(v).find('.ribbon').text(qCnt);
			(qCnt == qLen) ? $(v).find('.qNNum').text(99) : $(v).find('.qNNum').text(qCnt + 1);
			
			var iDivSel = $(v).find('.iDivSel');
			// 보기 분기
			var selValue = new Array();
			$.each(iDivSel,function (idx, obj){
				 selValue.push(obj.value)
			 });
			
			
			iDivSel.children().remove();
			for (var index=0; index<qLen; index++) {
				var idx = Number(index) + 1;
				if (idx > qCnt) {
					iDivSel.append($('<option>', {
						value: idx,
						text : idx
					}));
				}
			}
			iDivSel.append(selOptionEndEl.clone());
			
			$.each(iDivSel,function (idx, obj){
				if(selValue[idx] != undefined  && selValue[idx] != null && selValue[idx] != "" &&(/*selValue[idx] == 99  ||*/ selValue[idx] <=qLen ) ){ //종료는 유지 X
					$(obj).val(selValue[idx]);
					
					if($(obj).val() == null) $(obj).find("option").eq(0).prop("selected", true);
				}
			 });
			
			qCnt++;
		});
	} else {
		var gCnt = 1;
		
		$('.surveyMakeListView .group').each(function (i, v) {
			// 그룹 번호
			$(v).find('.gNumTxt').text(gCnt);
			
			// 그룹 분기, 보기 분기, 그룹 이동
			var gDivSel = $(v).find('.gDivSel');
			var gMDivSel = $(v).find('.gMDivSel');

			var gSelValue = new Array();
			$.each(gDivSel,function (idx, obj){
				gSelValue.push(obj.value)
			});
			
			$(v).find('.gDivSel, .iDivSel, .gMDivSel').children().remove(); //gDivSel -> 그룹 분기, gMDivSel-> 그룹 이동 select , iDivSel-> 객관식 분기			
			
			gMDivSel.append($('<option>', {
				value: '',
				text : coviDic.dicMap["lbl_groupTransfer"]
			}));
			
			for (var index=0; index<gLen; index++) {
				var gDataNum = Number(gDataArr[index][0]) + 1;
				if (gDataNum > gCnt) {
					gDivSel.append($('<option>', {
						value: gDataNum,
						text : gDataNum
					}));
				}
				if (gDataNum != gCnt) {
					gMDivSel.append($('<option>', {
						value: gDataNum,
						text : gDataNum
					}));
				}
			}
			gDivSel.append(selOptionEndEl.clone());
			
			$.each(gDivSel,function (idx, obj){
				if(gSelValue[idx] != undefined  && gSelValue[idx] != null && gSelValue[idx] != "" &&(/*gSelValue[idx] == 99  || */gSelValue[idx] <=qLen ) ){ //종료는 유지 X
					$(obj).val(gSelValue[idx]);
				}
			 });
			
			
			gCnt++;
			
			// 문항 번호
			var qCnt = 1;
			var qLen = $('.surveyMakeBox').length
			$('.surveyMakeBox').each(function (i, v) {
				$(v).find('.ribbon').text(qCnt);
				(qCnt == qLen) ? $(v).find('.qNNum').text(99) : $(v).find('.qNNum').text(qCnt + 1);
				var iDivSel = $(v).find('.iDivSel');
				// 보기 분기
				var selValue = new Array();
				$.each(iDivSel,function (idx, obj){
					 selValue.push(obj.value)
				 });
				
				
				iDivSel.children().remove();
				for (var index=0; index<qLen; index++) {
					var idx = Number(index) + 1;
					if (idx > qCnt) {
						iDivSel.append($('<option>', {
							value: idx,
							text : idx
						}));
					}
				}
				iDivSel.append(selOptionEndEl.clone());
				
				$.each(iDivSel,function (idx, obj){
					if(selValue[idx] != undefined  && selValue[idx] != null && selValue[idx] != "" && selValue[idx] <= qLen ){ //종료는 유지 X
						$(obj).val(selValue[idx]);
						
						if($(obj).val() == null) $(obj).find("option").eq(0).prop("selected", true);
					}
				 });
				
				qCnt++;
			});
		});
	}
}

// 이미지 callback
function callImgUploadCallBack(data, num) {
	var tarGNum = num.split('_')[0];
	var tarQNum = num.split('_')[1];
	var tarINum = num.split('_')[2];
	
	var target;
	if (tarGNum == 0) {	// 일반
		target = $($('.surveyMakeBox')[tarQNum - 1]).find('.itemDtl')[tarINum - 1];
	} else {	// 그룹
		target = $($($('.group')[tarGNum - 1]).find('.surveyMakeBox')[tarQNum - 1]).find('.itemDtl')[tarINum - 1];
	}
	
	var json = ($(target).find('.fileIds').val() == '') ? [] : JSON.parse($(target).find('.fileIds').val());
	$.each(data, function (i, v) {
		if ($(target).find('.photoBox').length == 0) $(target).append(photoDivEl.clone());
		
		var src = coviCmn.commonVariables.frontPath  + Common.getSession("DN_Code") + '/' + v.FrontAddPath + '/' + v.SavedName;
		var thumbSrc = src.split('.')[0] + '_thumb.jpg';
		var cloned = photoDetailDivEl.clone();
		$(cloned).find('img').attr('src', thumbSrc).attr('orgSrc', src);
		$(target).find('.photoBox').append(cloned);
		
		json.push(v);
	});
	
	$(target).find('.fileIds').val(JSON.stringify(json));
	
	$('.divpop_close').click();
}

//버튼 이벤트
$(function() {
	// 버튼
	var $mScrollV = $('.mScrollV');
	// 탑으로 가기
	$('.btnTop').on('click', function(){
		$('.mScrollVH').animate({scrollTop:0}, '500');
	});
	$('.cRContBottom.mScrollVH, .individualCommunityContainer.mScrollVH').scroll(function(eve) {	// 커뮤니티의 경우 스크롤 위치가 달라, 해당 클래스 하위의 스크롤 요소에도 이벤트 적용
		var questionLength = $(".surveyMakeBox").length;												// 문항개수
		var mTop = parseInt($(".surveyMakeListView").css("padding-top").replace(/[^-\d\.]/g, '')); 		// default top 
		var movedTop = mTop; 
		
		if(questionLength > 1){
			var headerHeight = $(".cRConTop").outerHeight(); 		// 상단 영역 높이 (메뉴 + 버튼 영역)
			var sideMenuHeight = $(".surMakeSideMenu").outerHeight();									// 우측 메뉴 영역 높이
			var questionDivTop = $(".surveyMakeListView").offset().top + mTop; 							// 문항 영역 top 위치
			
			if(headerHeight > questionDivTop){ //문항 영역이 상단 영역보다 위로 올라 갔을 떄 
				var diffHeight = headerHeight - questionDivTop;
				var questionDivHeight = $(".surveyMakeListView").height() - $(".surMListcontEnd").outerHeight(true); //문항 영역 높이 (문항 영역 높이 - 하단 버튼 영역)
				
				movedTop = (diffHeight + (mTop*5.5));
				
				if(questionDivHeight < (movedTop + sideMenuHeight)){ //문항 영역을 넘어갔을 경우
					movedTop = (questionDivHeight - sideMenuHeight + mTop);
				}
			}
		}
		
		$('.surMakeSideMenu').stop().animate({top: movedTop}, 200, function() {});
	});
	$(window).load(function(){
         window.setTimeout(loader, 100);
    });
    function loader(){
         $.mCustomScrollbar.defaults.scrollButtons.enable=true; //enable scrolling buttons by default
         $mScrollV.mCustomScrollbar({
			mouseWheelPixels: 500,scrollInertia: 350
		});
    };
	$(window).on('beforeunload', function() {
		$mScrollV.mCustomScrollbar('scrollTo', 'top');
	});
	
	var mSruMuestCont  = $('.surveyMakeListView');
	
	var $btnSurveryContSetting = $('.surveryContSetting');
	 
	/* 설문 설정 on Off*/
	$btnSurveryContSetting.on('click', function(){
		var mParent = $('.surveySettingView');
		if(mParent.hasClass('active')){
			mParent.removeClass('active');
			$(this).addClass('active');
		}else {
			mParent.addClass('active');
			$(this).removeClass('active');
		}
	});
	
	// 긴급
	$('.btnUrgent').on('click', function(){
		$(this).hasClass('active') == true ? $(this).removeClass('active') :$(this).addClass('active') ;
	});
	
	/*조회 기간 설정*/
	$('.btnInqPer').on('click', function() {
		var mParent = $('#inPerView');
		if(mParent.hasClass('active')){
			mParent.removeClass('active');
			$(this).closest('li').removeClass('active');
		}else {
			mParent.addClass('active');
			$(this).closest('li').addClass('active');
		}
	});
	
	// 설문 - 볼드
	$('.btnBold').on('click', function(){
		if($(this).closest('li').hasClass('active')){
			$('#surveySubject').css("font-weight","");
			$(this).closest('li').removeClass('active');
		}else {
			$('#surveySubject').css("font-weight","bold");
			$(this).closest('li').addClass('active');
		}
	});
	
	/* 설문 대상 더 보기*/
	$('.btnSurMove').on('click', function(){
		var mParent = $('.surveyMoreInput');
		if(mParent.hasClass('active')){
			mParent.removeClass('active');
			$(this).removeClass('active');
		}else {
			mParent.addClass('active');
			$(this).addClass('active');
		}
	});	 
	 
	// 알람
	$('.cRContBottom').on('click', '.alarm', function(){
		var target = $(this).closest('.sruQuestCont').children('.sruTitleCont').children('.inputFocusConten').children('.qTypeSelBox').find("option:selected");
		
		if($(this).find('.onOffBtn').hasClass('on') == true){
			$(this).find('.onOffBtn').removeClass('on');
			$(this).next(".requiredInfo").hide();
		}else{
			$(this).find('.onOffBtn').addClass('on');
			if(target.val() == "D") $(this).next(".requiredInfo").show();
		}
	});
	
	//그룹 닫기
	mSruMuestCont.on('click', '.bntGroupContClose', function(){
		if($(this).hasClass('active')){
			$(this).removeClass('active');
			$(this).closest('.surMListcont').removeClass('on');
		}else {
			$(this).closest('.surMListcont').addClass('on');			
			$(this).addClass('active');
		}
	});
	
	// 설문 포커스 이동
	mSruMuestCont.on('focus', '.inpFocus', function(eve) {
		  //eve.stopPropagation(); 
		  var mParent = $(this).closest('.inputFocusConten');
		  
		  if(!mParent.hasClass('focus')){
			  $('.inputFocusConten').removeClass('focus');
		   mParent.addClass('focus');
		   if(mParent.closest('.sruQuestCont').hasClass('active') == false){
			   $('.sruQuestCont').removeClass('active');
		    mParent.closest('.sruQuestCont').addClass('active');
		   }   
		  }
    });
/*	mSruMuestCont.on('focusout', '.inpFocus', function(eve){				
		$('.inputFocusConten').removeClass('focus');
	});*/
	mSruMuestCont.on('click', '.sruQuestCont', function() {
		if(!$(this).hasClass('active')) {
			$('.sruQuestCont').removeClass('active');
			$(this).addClass('active');
			$('.inputFocusConten').removeClass('focus');
		}
    });
	
    // 보기 추가
	mSruMuestCont.on('click', '.btnSruOptionAdd', function(e) {
		e.preventDefault();
        
		var tar = $(this).closest('.notSort');
        
        var hiddenItem = tar.siblings('.item-hidden').clone()
        					.removeClass('item-hidden')
        					.addClass('itemDtl');
        hiddenItem.find('.itemTxt').attr("placeholder", coviDic.dicMap["lbl_view"] + (tar.siblings('.itemDtl').length + 1));
        
        var textTar = tar.parent().find('.item-text');
        if (textTar.length > 0) {
        	hiddenItem.insertBefore(textTar);
        } else {
        	hiddenItem.insertBefore(tar);
        }
        
        syncGroupInfo();	// 그룹 정보, 번호, 문항 번호

		hiddenItem.find(".type03 ").focus();
    });

    // 보기 삭제
	mSruMuestCont.on('click', '.btnExDel', function(e) {
        e.preventDefault();
        
        var tar = $(this).closest('.sruQuestListDivi');
        
        if (tar.parent().find('.itemDtl:visible').length > 1 || tar.hasClass('item-text')) tar.remove();
    });
    
    // 기타 추가
	mSruMuestCont.on('click', '.btnSruOtherAdd', function(e) {
        e.preventDefault();
        
        var tar = $(this).closest('.notSort');

        if (tar.parent().find('.item-text').length == 0) {
        	var hiddenItem = tar.siblings('.item-text-hidden').clone()
							 	.removeClass('item-text-hidden')
							    .addClass('item-text');
        	hiddenItem.insertBefore(tar);
			hiddenItem.find(".type03 ").focus();
        }
    });
	
    // 문항 복사
	mSruMuestCont.on('click', '.qCopy', function(e) {
        e.preventDefault();
        
        var tar = $(this).closest('.surveyMakeBox');
        
        var val = $(tar).find('.qTypeSelBox option:selected').val();
        var cloned = tar.clone();
        cloned.find('.sruQuestCont, .itemDtl, .title')
        	  .removeClass("focus")
        	  .removeClass("active");
		
		//복제항목중 이미지 제외
		var tarFileId;
    	var tarIdx;
    	if (cloned.find('.btnPhotoRemove').length > 0){	// 이미지가 없는 경우 처리하지 않음.
	    	if (cloned.find('.btnPhotoRemove').closest('.photoImg').hasClass('frontPhoto')) {	// front 이미지
	    		tarFileId = cloned.find('.btnPhotoRemove').closest('.itemDtl').find('.fileIds');
	    		var tarName = cloned.find('.btnPhotoRemove').siblings('img').attr('src').split('/').pop().replace('_thumb.jpg', '');
	    		var fileIds = JSON.parse($(tarFileId).val());
	    		$.each(fileIds, function(i, v) {
	    			if (tarName == v.SavedName.split('.')[0]) tarIdx = i;
	    		});
	    		fileIds.splice(tarIdx, 1);
	    		
	    		$(tarFileId).val(JSON.stringify(fileIds));
	    	} else {	// back 이미지
	    		tarFileId = cloned.find('.btnPhotoRemove').siblings('img').attr('src').split('/').pop().replace('.do', '');
	    		var deleteFileIds = cloned.find('.btnPhotoRemove').closest('.itemDtl').find('.deleteFileIds');
	    		if (deleteFileIds.val() == '') deleteFileIds.val(tarFileId); else deleteFileIds.val(deleteFileIds.val() + ',' + tarFileId);
				var updateFileIds = cloned.find('.btnPhotoRemove').closest('.itemDtl').find('.updateFileIds').val();
				updateFileIds = updateFileIds.replace(tarFileId, "");
				if(updateFileIds.lastIndexOf(";") == updateFileIds.length - 1) updateFileIds = updateFileIds.substr(0, updateFileIds.length - 1);
	    		
	    		cloned.find('.btnPhotoRemove').closest('.itemDtl').find('.updateFileIds').val(updateFileIds);
	    	}
	    }
    	
    	var parent = cloned.find('.btnPhotoRemove').closest('.photoBox');
    	var imgLen = parent.find('.photoImg').length;
    	
    	if (imgLen == 1) {
    		parent.remove();
    	} else {
    		cloned.find('.btnPhotoRemove').parent().remove();
    	}
        
        cloned.find('.qTypeSelBox').val(val);
        tar.after(cloned);
        
        sortable();
        syncGroupInfo();	// 그룹 정보, 번호, 문항 번호
    });	
	
    // 문항 삭제
	mSruMuestCont.on('click', '.qDel', function(e) {
    	e.preventDefault();
    	
    	var tar = $(this).closest('.surveyMakeBox');
    	
        if (tar.parent().find('.surveyMakeBox').length > 1){
        	tar.remove();
        }else{
        	Common.Warning(coviDic.dicMap["lbl_surveyMsg16"]);
        }
        
        syncGroupInfo();	// 그룹 정보, 번호, 문항 번호
    });
	
    // 지문 삭제
    mSruMuestCont.on('click', '.delDBtn', function(e) {
    	e.preventDefault();
    	
    	$(this).closest('.explanationCont').remove();
    });
    
	// 문항유형 Selectbox
    mSruMuestCont.on('change', '.qTypeSelBox', function(e) {
		e.preventDefault();
		
		var val = $(e.target).val();
		var tar = $(this).closest('.surveyMakeBox');
		
		tar.find('.sruQuestListDivi').remove();
		
		if (val == 'S') {	// 객관식
			tar.find('.sruTitleCont').after(itemSDivEl.clone(), itemSHidDivEl.clone(), itemTextHidDivObj.clone(), itemSAddEl.clone());
		} else if (val == 'D') {	// 주관식
			tar.find('.sruTitleCont').after(itemDDivEl.clone());
		} else if (val == 'M') {	// 복수응답
			tar.find('.sruTitleCont').after(itemMDivEl.clone(), itemMHidDivObj.clone(), itemTextHidDivObj.clone(), itemMAddEl.clone());
		} else if (val == 'N') {	// 순위선택
			tar.find('.sruTitleCont').after(itemNDivEl.clone(), itemNHidDivObj.clone(), itemNAddEl.clone());
		}
		
		sortable();
		syncGroupInfo();
	});    
    
	// 그룹 이동 Selectbox
    mSruMuestCont.on('change', '.gMDivSel', function(e) {
		e.preventDefault();
		
		var val = $(e.target).val();
		var tar = $(this).closest('.surveyMakeBox');
		var orgIdx = tar.closest('.group').index();
		var orgGroup = $('.surveyMakeListView').children().eq(orgIdx);

		$('.surveyMakeListView').children().eq(val - 1).find('.groupQuartSelect').before(tar);
		
		if (orgGroup.find('.surveyMakeBox').length == 0) orgGroup.remove();
		
		sortable();
		syncGroupInfo();
	}); 
    
	// 그룹 삭제
    mSruMuestCont.on('click', '.btnTypeXClose', function(e) {
    	e.preventDefault();
    	
    	if (gDataArr.length == 1) {
    		$(this).closest('.group').remove();
    		
    		$(".surveyMakeListView").prepend($("<div/>", {'class' : 'surMListcont sortEl'}).append(surveyQSDivEl.clone()));
    	} else {
    		$(this).closest('.group').remove();
    	}
    	
        syncGroupInfo();	// 그룹 정보, 번호, 문항 번호
	});
    
	// 이미지 업로드
    mSruMuestCont.on('click', '.btnPhotoUpload', function(e) {
    	var groupNum = typeof($(this).closest('.group').find('.gNumTxt').html()) == "undefined" ? '0' : $(this).closest('.group').find('.gNumTxt').html();
    	var questionNum = $(this).closest('.surveyMakeBox').find('.ribbon').html();
    	var tarCont = $(this).closest('.sruQuestCont').find('.sruQuestListDivi').not('.item-hidden, .item-text-hidden');
    	var itemNum = tarCont.index($(this).closest('.sruQuestListDivi')) + 1;
    	var elemID = groupNum + '_' + questionNum + '_' + itemNum;
    	
    	var url = "/covicore/control/callFileUpload.do?"
    	url += "lang=ko&";
    	url += "listStyle=div&";
    	url += "callback=callImgUploadCallBack&";
    	url += "actionButton="+encodeURIComponent("add,upload")+"&";
    	url += "multiple=true&";
    	url += "servicePath=" + coviComment.commentVariables.servicePath + "&";
    	url += "elemID=" + elemID+"&";
    	url += "image=true";

    	Common.open("", elemID + "_CoviCommentImgUp", coviDic.dicMap["lbl_File"], url, "500px", "250px", "iframe", true, null, null, true);
	});
    
    // 문항 추가
    $('#addQBtn').click(function(e) {
        e.preventDefault();
        
        var cloned = surveyQSDivEl.clone();
        if ($('.surveyMakeListView').find('.group').length == 0) {
        	$('.surMListcont').append(cloned);
        } else {
        	var tar = $(".surveyMakeBox .active");
        	
        	if (tar.length > 0) {
        		cloned.find('.itemSetOption').append(questionMoveEl.clone());
        		
        		tar.closest('.surMListcont').find('.groupQuartSelect').before(cloned);
        	} 
        }
        
        sortable();
        syncGroupInfo();

		$(cloned).find(".questionText").focus();
    });
    
    // 지문 추가
    $('#addDBtn').click(function(e) {
        e.preventDefault();
        
        var tar = $(".surveyMakeBox .active");
        
        if ($(".surveyMakeBox .active").length > 0 && tar.find('.explanationCont').length == 0){
			var cloned = exPlanDivEl.clone();
			tar.find('.sruQuestContMove').after(cloned);
			$(cloned).find(".paragraphText").focus();
		}

    });

    // 그룹 추가
    $('#addGBtn').click(function(e) {
    	e.preventDefault();
    	
    	var parent = $('.surveyMakeListView');
    	var tar = null;
    	
    	if (parent.find('.group').length == 0) {
    		tar = $('.surveyMakeListView').find('.surMListcont');
    		tar.prepend(groupNumEl.clone(), groupTitleEl.clone());
    		tar.addClass('group');
    		tar.append(groupSelEl.clone());
    		tar.find('.itemSetOption').append(questionMoveEl.clone());
    	} else {
    		tar = groupDivEl.clone();
    		tar.find('.itemSetOption').append(questionMoveEl.clone());
    		tar.insertBefore(parent.find('.surMListcontEnd'));
    	}
		$(".groupQuartSelect").hide();
    	
    	sortable();
    	syncGroupInfo();	// 그룹 정보, 번호, 문항 번호

		tar.find(".gName").focus();
    });
    
	// 이미지 삭제
    mSruMuestCont.on('click', '.btnPhotoRemove', function(e) {
    	e.preventDefault();
    	
    	var tarFileId;
    	var tarIdx;
    	if ($(this).closest('.photoImg').hasClass('frontPhoto')) {	// front 이미지
    		tarFileId = $(this).closest('.itemDtl').find('.fileIds');
    		var tarName = $(this).siblings('img').attr('src').split('/').pop().replace('_thumb.jpg', '');
    		var fileIds = JSON.parse($(tarFileId).val());
    		$.each(fileIds, function(i, v) {
    			if (tarName == v.SavedName.split('.')[0]) tarIdx = i;
    		});
    		fileIds.splice(tarIdx, 1);
    		
    		$(tarFileId).val(JSON.stringify(fileIds));
/*    		$.map(fileIds, function (i,v) {
  			  return (tarName != v.SavedName.split('.')[0])
  			});*/
    	} else {	// back 이미지
    		tarFileId = $(this).siblings('img').attr('src').split('/').pop().replace('.do', '');
    		var deleteFileIds = $(this).closest('.itemDtl').find('.deleteFileIds');
    		if (deleteFileIds.val() == '') deleteFileIds.val(tarFileId); else deleteFileIds.val(deleteFileIds.val() + ',' + tarFileId);
			var updateFileIds = $(this).closest('.itemDtl').find('.updateFileIds').val();
			updateFileIds = updateFileIds.replace(tarFileId, "");
			if(updateFileIds.lastIndexOf(";") == updateFileIds.length - 1) updateFileIds = updateFileIds.substr(0, updateFileIds.length - 1);
			
    		/*$.each(updateFileIds, function(i, v) {
    			if (tarFileId == v) tarIdx = i;
    		});
    		updateFileIds.splice(tarIdx, 1);*/
    		
    		$(this).closest('.itemDtl').find('.updateFileIds').val(updateFileIds);
    	}
    	
    	var parent = $(this).closest('.photoBox');
    	var imgLen = parent.find('.photoImg').length;
    	
    	if (imgLen == 1) {
    		parent.remove();
    	} else {
    		$(this).parent().remove();
    	}
	});
    
	// 이미지 클릭
    mSruMuestCont.on('click', 'img', function(e) {
    	e.preventDefault();
    	
    	var src;
    	if ($(this).closest('.photoImg').hasClass('frontPhoto')) {	// front 이미지
    		src = $(this).attr('orgSrc');
    	} else {	// back 이미지
    		src = "/covicore/common/view/Survey/" + $(this).attr('src').split('/').pop();
    	}
    	
    	coviComment.callImageViewer(src);
	});
    
	// 사용자나 부서 삭제
    $('.surveyMakeView').on('click', '.ui-icon-close', function(e) {
    	e.preventDefault();

		if($(this).closest('.ui-autocomplete-multiselect').find('input').attr('id') == 'targetDetailInput'){
			$(this).parent().remove();
			if(Common.getBaseConfig("SurveyApproveType") == "Assign" && Common.getBaseConfig("SurveyApprover")) {
					var targetarr = new Array();
					$("#targetDetailDiv").find('.ui-autocomplete-multiselect-item').each(function (i,v){
						targetarr.push($(v).attr("code"));
					});
					
					var targetDeptArr = new Array();
					var params = new Object();
					params.targetarr = targetarr;
					if(params.targetarr.length > 0){
						$.ajax({
							type : "POST",
							data : params,
							async: false,
							url : "/groupware/survey/getGroupFullPath.do",
							success:function (data) {
								var CheckDept;
								for (var key in data) {
								  if (data.hasOwnProperty(key)) {
								    var value = data[key];
								    if(value != null){ // User인 경우
									    targetDeptArr.push(value);
								    } else { // Group인 경우
								    	if(Common.getSession('DEPTID') == key){
								    		value = Common.getSession('DEPTID');
								    		targetDeptArr.push(value);
								    	} else {
								    		targetDeptArr.push(null);
								    	}
								    }
								  }
								  
								  CheckDept = value;
								}
								
								var DeptCheck = true;
								var WriterDept = Common.getSession('DEPTID');
								for(i=0;i<targetDeptArr.length;i++){
									for(j=i+1;j<targetDeptArr.length;j++){
										if(targetDeptArr[i] != targetDeptArr[j]){
											DeptCheck = false;	
										}
									}									
								}
								
								if(DeptCheck && (CheckDept == WriterDept)){
									var approverDetailDiv = document.getElementById('approverDetailDiv');
									var btnElement = approverDetailDiv.querySelector('.btnTypeDefault.nonHover.type01');
									if(!btnElement){
										var anchorElement = document.createElement("a");
										anchorElement.classList.add("btnTypeDefault", "nonHover", "type01");
										anchorElement.onclick = function() {
										    openOrgMapLayerPopup('approverDetailDiv', this);
										};
										anchorElement.innerHTML = coviDic.dicMap["btn_OrgManage"];
										var approverDetailDiv = document.getElementById("approverDetailDiv");
										approverDetailDiv.appendChild(anchorElement);
									}
									
									$('#approverDetailDiv .ui-autocomplete-multiselect-item').css('padding-right', '20px');
									document.getElementById('approverDetailInput').removeAttribute('readonly');
									
									var multiselectItems = approverDetailDiv.getElementsByClassName('ui-autocomplete-multiselect-item');
									for (var i = 0; i < multiselectItems.length; i++) {
									  var closeIcon = multiselectItems[i].querySelector('.ui-icon-close');
									  if (!closeIcon) {
									    var newSpan = document.createElement('span');
									    newSpan.className = 'ui-icon ui-icon-close';
									    multiselectItems[i].appendChild(newSpan);
									  }
									}
								} else {
									ApproverCheck();
								}
							},
							error:function(response, status, error) {
								CFN_ErrorAjax(url, response, status, error);
							}
						});
					} else {
						ApproverCheck();
					}
				}
		} else {
			$(this).parent().remove();
		}
	});
	
function ApproverCheck() {
	$('#approverDetailDiv').find('.ui-autocomplete-multiselect-item').remove();
								
	var cloned = orgMapDivEl.clone();
	var type = 'UR';
	var code = Common.getBaseConfig("SurveyApprover");
	var name;
	
	$.ajax({
		type : "POST",
		data : {code : code},
		async: false,
		url : "/groupware/survey/getSurveyApprover.do",
		success:function (data) {
			name = data.data;
		},
		error:function(response, status, error) {
			CFN_ErrorAjax(url, response, status, error);
		}
	});
	
	if(name != null) {
		cloned.attr('type', type).attr('code', code);
		cloned.find('.ui-icon-close').before(name);
		$('#approverDetailDiv' + ' .ui-autocomplete-input').before(cloned);
		$('#approverDetailDiv .ui-autocomplete-multiselect-item').find('.ui-icon-close').remove();
		$('#approverDetailDiv .ui-autocomplete-multiselect-item').css('padding-right', '3px');
		document.getElementById('approverDetailInput').setAttribute('readonly', 'readonly');
	}
	
	var approverDetailDiv = document.getElementById('approverDetailDiv');
	var btnElement = approverDetailDiv.querySelector('.btnTypeDefault');
	if (btnElement) {
	  btnElement.remove();
	}
}
});