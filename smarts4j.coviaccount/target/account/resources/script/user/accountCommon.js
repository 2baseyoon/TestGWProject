window.onresize =	function(){
	//account에서만 호출되도록 변경
	if(CFN_GetQueryString("CLSYS") == "account"){
		eAccountTabListDivResize();
	}
}	

var accountCommon = {
	getHeaderNameForExcel : function(headerData){
		var returnStr	= "";
	   	for(var i=0;i<headerData.length; i++){
	   	   	if(headerData[i].display != false && headerData[i].label != 'chk'){
	   	   		returnStr += headerData[i].label + "†";
	   	   	}
		}
		return returnStr;
	},
	getHeaderKeyForExcel : function(headerData){
		var returnStr	= "";
	   	for(var i=0;i<headerData.length; i++){
	   	   	if(headerData[i].display != false && headerData[i].label != 'chk'){
				returnStr += headerData[i].key + ",";
	   	   	}
		}
		return returnStr;
	},
	getHeaderTypeForExcel : function(headerData){
		var returnStr	= "";
	   	for(var i=0;i<headerData.length; i++){
	   	   	if(headerData[i].display != false && headerData[i].label != 'chk'){
				returnStr += (headerData[i].dataType != undefined ? headerData[i].dataType:"Text") + "|";
	   	   	}
		}
		return returnStr;
	}
};

var maxTabSize	= 0;
function getMaxTabSize(key) {
	//최대 탭 사이즈 GET
	try{
		var fixedTabAInfo			= $('#fixedTabAcc');
		var eAccountTabListInfo		= $('#eAccountTabList');
		var fixedTabAInfoSize		= fixedTabAInfo[0].offsetWidth;
		var eAccountTabListInfoSize	= eAccountTabListInfo[0].offsetWidth;
		maxTabSize = Math.floor((eAccountTabListInfoSize-20) / fixedTabAInfoSize) - 1;
	}catch (e) {
		coviCmn.traceLog(e);
	}
}

//화면 사이즈에 따른 탭 Setting
function eAccountTabListDivResize(){
	
	getMaxTabSize();
	
	var eAccountTabListInfo			= $('#eAccountTabListDiv');
	var eAccountTabMoreItemsInfo	= $('#eAccountTabMoreItems');
	
	var tabList			= eAccountTabListInfo.children();
	var moreItemList	= eAccountTabMoreItemsInfo.children();
	
	//최대 탭 사이즈 < 현재 탭 사이즈
	if(maxTabSize < tabList.length){
		var forChk = 0;
		
		//최대 탭 사이즈를 넘어선 가장 마지막 탭 항목부터 순차적으로 more탭의 첫번재 항목으로 등록
		for(var i=tabList.length - 1; i > maxTabSize; i--){
			var info		= tabList[i].children[0];
			var addID		= info.id.replace('TabDivTitle','');
			var contentUrl	= info.getAttribute('url');
			var label		= info.textContent;
			
			var appendTabStr	= "<div id=\""+addID+"TabAMoreItem\"		class=\"l-contents-tabs__more-pop_list\"	url=\""+contentUrl+"\">"
								+ 	"<a id=\""+addID+"TabAMoreItemA\"		class=\"l-contents-tabs__pop-item\"			url=\""+contentUrl+"\"	name=\"tabAMoreItemA\">"+label+"</a>"
								+ 	"<a id=\""+addID+"TabAMoreItemDeleteA\"	class=\"l-contents-tabs__delete\"			url=\""+contentUrl+"\"	name=\"tabAMoreItemDeleteA\">"
								+ 	"<i class=\"i-cancle\"></i>"
								+ 	"</a>"
								+ "</div>";
			
			eAccountTabMoreItemsInfo.prepend(appendTabStr);
			forChk = 1;
		}
		
		if(forChk == 1){
			$('#eAccountTabMoreDiv').css("display",	"");
			//최대 탭 사이즈를 넘어선 가장 마지막 탭 항목부터 순차적으로 탭 항목 제거
			for(var i=tabList.length - 1; i > maxTabSize; i--){
				var removeID	= tabList[i].id;
				$('#'+removeID).remove();
			}
			setTabActiveNowView();
		}
	}
	
	//최대 탭 사이즈 > 현재 탭 사이즈
	if(maxTabSize > tabList.length){
		if(moreItemList.length > 0){
			var forChk = 0;
			
			/* maxTabSize - tabList.length
			 * 최대 탭 사이즈 - 현재 탭 사이즈 = 현제 탭에 추가 가능한 탭의 수
			 * +1 : 고정텝[HOME]
			 * 단, more탭 사이즈보다 추가 가능한 탭 수가 클 경우 more탭 사이즈 만큼만 조정 
			 */ 
			var endNum = maxTabSize - tabList.length;
			
			endNum = endNum + 1
			
			if(endNum > moreItemList.length){
				endNum = moreItemList.length
			}
			
			//more탭의 첫번째부터 탭 항목으로 추가
			for(var i=0; i<endNum; i++){
				
				var tabMorechildrenId		= moreItemList[i].id.replace('TabAMoreItemA','').replace('TabAMoreItem','');
				var tabMorechildrenUrl		= moreItemList[i].getAttribute('url');
				var tabMorechildrenlabel	= moreItemList[i].children[0].text.trim();
				
				var dateInfo	= new Date();
				var yy			= dateInfo.getFullYear();
				var mm			= dateInfo.getMonth()+1;
				var dd			= dateInfo.getDate();
				var mi			= dateInfo.getMinutes();
				var se			= dateInfo.getSeconds();
				var ms			= dateInfo.getMilliseconds();
				
				if(mm < 10){mm ="0" + mm;}
				if(dd < 10){dd ="0" + dd;}
				
				var dataOrder	= yy+mm+dd+mi+se+ms;
				//dataOrder : 탭의 정렬을 위한 값으로 탭마다 유니크하게 보유 필요 [Drag and Drop]
				var appendTabStr	=	""
									+	"<div id=\""+tabMorechildrenId+"TabDiv\" data-order="+dataOrder+" class=\"l-contents-tabs__item l-contents-tabs__item--active\">"
									+		"<div id=\""+tabMorechildrenId+"TabDivTitle\" class=\"l-contents-tabs__title\" name=\"tabDivTitle\" url=\""+tabMorechildrenUrl+"\">"+tabMorechildrenlabel+"</div>"
									+		"<a id=\""+tabMorechildrenId+"TabDivDeleteA\" class=\"l-contents-tabs__delete\" name=\"tabDivDeleteA\" url=\""+tabMorechildrenUrl+"\">"
									+			"<i class=\"i-cancle\"></i>"
									+		"</a>"
									+	"</div>";
				$('#eAccountTabListDiv').append(appendTabStr);
				forChk = 1;
			}
			if(forChk == 1){
				//more탭의 첫번째부터 more탭의 항목 제거
				for(var i=0; i<endNum; i++){
					$('#'+moreItemList[i].id).remove();
				}
				setTabActiveNowView();
			}
		}
	}
	
	//최대 탭 사이즈 == 현재 탭 사이즈
	if(maxTabSize == tabList.length){
		return;
	}
}

//탭 항목 또는 more탭 항목의 CLASS 정의
function setTabActiveNowView(){
	var tabInfo		= $('#eAccountTabListDiv');
	var moreInfo	= $('#eAccountTabMoreItems');
	
	var tabList		= tabInfo.children();
	var moreList	= moreInfo.children();
	
	var nowView		= accountCtrl.getViewPageDivID();
	var nowViewR	= nowView.replace('ViewArea','');
	if(tabList.length > 0){
		for(var tl=0; tl<tabList.length; tl++){
			var nowTabListID = tabList[tl].id.replace('TabDiv','');
			if(nowViewR == nowTabListID){
				$('#' + tabList[tl].id).addClass('l-contents-tabs__item--active');
			}else{
				$('#' + tabList[tl].id).removeClass('l-contents-tabs__item--active');
			}
		}
	}
	
	if(moreList.length > 0){
		$('#eAccountTabMoreDiv').css("display",	"");
		for(var ml=0; ml<moreList.length; ml++){
			var nowMTabListID = moreList[ml].id.replace('TabAMoreItem','');
			if(nowViewR == nowMTabListID){
				$('#' + moreList[ml].id + 'A').addClass('selected')
	}else{
				$('#' + moreList[ml].id + 'A').removeClass('selected');
			}
		}
	}else{
		$('#eAccountTabMoreDiv').css("display", "none");
	}
}

function getStr(key){
	var rtValue = "";
	if(key == null || key == 'undefined'){
		rtValue = "";
	}else{
		rtValue = key;
	}
	return rtValue
}

function getNum(key) {
	var reg	= /^[0-9]+$/;
	var rtValue = 0;
	
	if (reg.test(key)){
		rtValue = key;
	}
	
	return rtValue
}

function getNumOnly(key){
	if(key == null || key == undefined){
		key = "0";
	}
	
	var rex = /[^-0-9]/gi;
	
	key = key + "";
	key = key.replace(rex,'');
	key = key.trim();
	
	return key
}

function getCardNoValue(key,exceptKey){
	var len = 0;
	var rex = /[^'+exceptKey+'0-9]/gi

	if(!key){
		key = "0";
	}
	
	key = key + "";
	key = key.replace(rex,'');
	key = key.trim();
	len = 16-key.length;
	
	var returnCardNo = "";
	if(len == 1) { //15자리 카드번호
		returnCardNo = key.substr(0,4) + '-' + key.substr(4,6) + '-' + key.substr(10,5);
	} else {
		for(var i=0; i<len; i++){
			key = key + "X"
		}
		
		returnCardNo = key.substr(0,4) + '-' + key.substr(4,4) + '-' + key.substr(8,4) + '-' + key.substr(12,4);
		
		if(returnCardNo.indexOf('X') > 0){
			returnCardNo = returnCardNo.substr(0,returnCardNo.indexOf('X'));
		}
	}
	
	return returnCardNo;
}

function getAmountValue(key){
	key = key + "";
	key = key.replace(/[^-0-9,]/gi,'');
	key = key.trim();
	if(key.length>16){
		key = 999999999999999
	}
	key = key * 1;
	return CFN_AddComma(key+"")
}
	
function pressHan(obj){
	if(	event.keyCode == 8	||
		event.keyCode == 9	||
		event.keyCode == 37	||
		event.keyCode == 39	||
		event.keyCode == 46){
		return;
	}
	obj.value = obj.value.replace(/[^-0-9]/gi,'');
}

function inputNumChk(e){
	var keyValue	= e.keyCode;
	if(	(keyValue	>= 48)	&&
		(keyValue	<= 57)){
		return true
	}else{
		return false
	}
}

//문자열 공백 체크
function isEmptyStr(str){
	if(str == null){
		return true;
	}
	if(str.toString == null){
		return true;
	}	
	
	var getStr = str.toString();
	if(getStr == null){
		return true;
	}
	if(getStr != ""
		&& getStr != null
		&& !getStr.isBlank()){
		return false;
	}
	return true;
}

//문자열 공백 체크
function accToString(str){
	if(str == null){
		return "";
	}
	if(str.toString == null){
		return "";
	}
	
	return str.toString();
}

//input필드 값 획득
function getTxTFieldData(field) {
	return accountCtrl.getInfo(field).val()
}

//input 값 세팅
function setFieldData(field, data) {
	return accountCtrl.getInfo(field).val(data)
}

//input 수정가능여부 처리
function setFieldDisabled(field, val) {
	accountCtrl.getInfo(field).attr('disabled',val)
}

//input필드 값 획득
function getTxTFieldDataPopup(field) {
	return $("#"+field).val()
}

//input 값 세팅
function setFieldDataPopup(field, data) {
	return $("#"+field).val(data)
}

//input 수정가능여부 처리
function setFieldDisabledPopup(field, val) {
	$("#"+field).attr('disabled',val)
}

//숫자 체크
function ckNaN(val) {
	var retVal = 0;
	
	if(isNaN(val)) {
		retVal = 0;
	} else {
		retVal = Number(val);	
	}
	
	return retVal;
}

//null값 공백 반환
function nullToBlank(val) {
	var retVal = "";
	
	if(!isEmptyStr(val)){
		retVal = val
	}
	
	return retVal
}

//null값 문자열 반환
function nullToStr(val, str) {
	var retVal = "";
	if(str != null){
		retVal = str;
	}
	if(!isEmptyStr(val)){
		retVal = val
	}
	
	return retVal
}

//금액, 찍기
function toAmtFormat(val) {
	var retVal = "";
	if(val != null){
		if(val.toString != null){
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
	}
	//	str.replace(/[^\d]+/g,'')
	return retVal
}

//,찍힌값 되돌리기
function AmttoNumFormat(val) {
	var retVal = "";
	if(val != null){
		if(val.toString != null){
			retVal = val.toString();
			//retVal = retVal.replace(/[^\d]+/g,'');
			retVal = retVal.replaceAll(',', '');
		}
	}
	return retVal
}
	
//금액 , 다시찍기
function resetAmtFormat(val) {
	var retVal = val;
	retVal = AmttoNumFormat(retVal)
	retVal = toAmtFormat(retVal)
	return retVal
}

var LeftSubIdNow	= "";
var selectLeftSubId	= "";

function eAccountMenuListControl(id,label,contentUrl) {
	eAccountSelectLeftSub(id);
	eAccountSelectTab(id,label,contentUrl);	
	eAccountMoreTabRemoveClassActive();
	coviUtil.setFrontTitle();
}

//페이지 항목 클릭
function eAccountSelectLeftSub(id) {
	
	/* 페이지 항목 클릭
	 * 1. 좌측 매뉴 2. 탭 3. more탭
	 */
	
	//eaccountingTopGroupMenuList : DB를 통해 등록하지 않은 버튼 메뉴 (신청 메뉴)
	var topChk = 0;
	var topGroupList = $('#eaccountingTopGroupMenuList').find("a");
	for(var i=0; i<topGroupList.length;i++){
		if(topGroupList[i].id == id){
			topChk = 1;
			break;
		}
	}
	
	//이후 작업을 위해 접근한 아이디를 모두 동일하게 구성하기 위한 작업
	var ttReplaceId	= id.replace('TabDivTitle','');
	var tdReplaceId	= ttReplaceId.replace('TabDiv','');
	var taReplaceId	= tdReplaceId.replace('TabAMoreItemA','').replace('TabAMoreItem','');
	LeftSubIdNow	= taReplaceId;
	
	//동일 항목을 선택한 경우 추가 작업이 필요 없으므로 return
	if(LeftSubIdNow == selectLeftSubId){
		return;
	}
	
	//좌측 메뉴의 선택 여부 Class를 setting
	if(topChk == 0){
		//DB를 통해 제작된 서브 메뉴를 선택한 경우
		
		var leftSubIdNowInfo		= $('#' + LeftSubIdNow);
		if(leftSubIdNowInfo.length > 0) {
			var ppLeftSubIdNowChildren	= leftSubIdNowInfo[0].parentElement.parentElement.children;
			var chkGroupID		= ppLeftSubIdNowChildren[0].id;
			var chkGroupItemID	= ppLeftSubIdNowChildren[1].id;
	
			var leftMenuInfo = $('#eaccountingMenuList');
			var leftMenuList = leftMenuInfo.children();
			
			for(var a=0; a<leftMenuList.length; a++){
				if(leftMenuList[a].children[0].tagName.toUpperCase() == "DIV") {
					var groupID		= leftMenuList[a].children[0].id;
					var groupItemID	= leftMenuList[a].children[1].id;
					
					if(chkGroupID == groupID){
						$('#'+groupID).addClass('active');
						$('#'+groupItemID).addClass('active');
						$('#'+$('#'+groupID).children()[0].id).addClass('active');
						
						var items = $('#'+groupItemID).children();
						
						for(var b=0; b<items.length; b++){
							var nowItemID	= items[b].id;
							if(LeftSubIdNow == nowItemID){
								$('#'+nowItemID).addClass('selected');
							}else{
								$('#'+nowItemID).removeClass('selected');
							}
						}
					}else{
						$('#'+groupID).removeClass('active');
						$('#'+groupItemID).removeClass('active');
						$('#'+$('#'+groupID).children()[0].id).removeClass('active');
						
						var items = $('#'+groupItemID).children();
						
						for(var c=0; c<items.length; c++){
							$('#'+items[c].id).removeClass('selected');
						}
					}
				} else {
					var nowItemID = leftMenuList[a].children[0].id;
					if(LeftSubIdNow == nowItemID){
						$('#'+nowItemID).addClass('selected');
					}else{
						$('#'+nowItemID).removeClass('selected');
					}
				}
			}
		}
	}else{
		//DB를 통해 등록하지 않은 [통합비용신청 / 경비신청 / 법인카드 간편신청] 3개 메뉴를 선택한 경우
		
		var leftMenuInfo = $('#eaccountingMenuList');
		var leftMenuList = leftMenuInfo.children();
		
		for(var a=0; a<leftMenuList.length; a++){
			if(leftMenuList[a].children[0].tagName.toUpperCase() == "DIV") {
				var groupID		= leftMenuList[a].children[0].id;
				var groupItemID	= leftMenuList[a].children[1].id;
			
				$('#'+groupID).removeClass('active');
				$('#'+groupItemID).removeClass('active');
				$('#'+$('#'+groupID).children()[0].id).removeClass('active');
				
				var items = $('#'+groupItemID).children();
				
				for(var c=0; c<items.length; c++){
					$('#'+items[c].id).removeClass('selected');
				}
			} else {
				var nowItemID = leftMenuList[a].children[0].id;
				$('#'+nowItemID).removeClass('selected');
			}
		}
	}
	
	selectLeftSubId = LeftSubIdNow;
}

// 탭 클릭
function eAccountSelectTab(id,label,contentUrl) {
	
	/* 탭 클릭
	 * 1. 탭 2. more탭
	 */
	
	//이후 작업을 위해 접근한 아이디를 모두 동일하게 구성하기 위한 작업 
	var ttReplaceId	= id.replace('TabDivTitle','');
	var tdReplaceId	= ttReplaceId.replace('TabDiv','');
	var taReplaceId	= tdReplaceId.replace('TabAMoreItemA','').replace('TabAMoreItem','');
	var chkId		= taReplaceId;
	
	
	// 탭 항목의 선택 여부 Class를 setting
	var eAccountFixedTabDivTabInfo		= $('#fixedTabDiv');
	var eAccountFixedTabDivTabChildren 	= eAccountFixedTabDivTabInfo.children();
	
	if(eAccountFixedTabDivTabChildren.length > 0 && eAccountFixedTabDivTabChildren[0].id == chkId){
		$('#fixedTabDiv').addClass('l-contents-tabs__fixed-tab--active');
	}else{
		$('#fixedTabDiv').removeClass('l-contents-tabs__fixed-tab--active');
	}
	
	var eAccountTabListInfo			= $('#eAccountTabListDiv');
	var eAccountTabMoreItemsInfo	= $('#eAccountTabMoreItems');
	
	var tabList			= eAccountTabListInfo.children();
	var moreItemList	= eAccountTabMoreItemsInfo.children();
	
	var setActive	= 0;
	
	//탭 사이즈가 0보다 크면
	if(tabList.length > 0){
		for(var tl=0; tl<tabList.length; tl++){
			
			var nowTabListID			= tabList[tl].id;
			var replaceNowTabListIDTT	= nowTabListID.replace('TabDivTitle','');
			var replaceNowTabListIDTD	= replaceNowTabListIDTT.replace('TabDiv','');
			var replaceNowTabListIDTA	= replaceNowTabListIDTD.replace('TabAMoreItemA','').replace('TabAMoreItem','');
			
			if(chkId == replaceNowTabListIDTA){
				$('#' + tabList[tl].id).addClass('l-contents-tabs__item--active');
				setActive = 1;
			}else{
				$('#' + tabList[tl].id).removeClass('l-contents-tabs__item--active');
			}
		}
	}
	
	//more탭 사이즈가 0보다 크면
	if(moreItemList.length > 0){
		for(var mil=0; mil<moreItemList.length; mil++){
			
			var nowMoreItemListID			= moreItemList[mil].id;
			var replaceNowMoreItemListIDTT	= nowMoreItemListID.replace('TabDivTitle','');
			var replaceNowMoreItemListIDTD	= replaceNowMoreItemListIDTT.replace('TabDiv','');
			var replaceNowMoreItemListIDTA	= replaceNowMoreItemListIDTD.replace('TabAMoreItemA','').replace('TabAMoreItem','');
			
			if(chkId == replaceNowMoreItemListIDTA){
				$('#' + moreItemList[mil].id + 'A').addClass('selected')
				setActive = 1;
			}else{
				$('#' + moreItemList[mil].id + 'A').removeClass('selected');
			}
		}
	}
	
	//탭 또는 more탭에 선택될 항목이 없을 경우 새롭게 탭을 추가
	if(setActive == 0){
		
		//접근 ID가 HOME인 경우 return
		if(	id			== 'fixedTabAcc'				||
			id			== null || id == ''			||
			contentUrl	== null || contentUrl == ''	||
			label		== null || label == ''
		){
			return;
		}
		
		var appendTabStr	= "";
		
		//현재 탭 사이즈 > 최대 탭 사이즈 의 경우 more탭의 항목으로 추가 
		if(tabList.length > maxTabSize){
			appendTabStr	= "<div id=\""+chkId+"TabAMoreItem\"		class=\"l-contents-tabs__more-pop_list\"	url=\""+contentUrl+"\">"
							+	"<a id=\""+chkId+"TabAMoreItemA\"		class=\"l-contents-tabs__pop-item selected\"url=\""+contentUrl+"\"	name=\"tabAMoreItemA\">"+label+"</a>"
							+	"<a id=\""+chkId+"TabAMoreItemDeleteA\"	class=\"l-contents-tabs__delete\"			url=\""+contentUrl+"\"	name=\"tabAMoreItemDeleteA\">"
							+	"<i class=\"i-cancle\"></i>"
							+	"</a>"
							+ "</div>";
			eAccountTabMoreItemsInfo.append(appendTabStr);
			$('#eAccountTabMoreDiv').css("display",	"");
		}else{
			//탭 항목으로 추가
			
			var dateInfo	= new Date();
			var yy			= dateInfo.getFullYear();
			var mm			= dateInfo.getMonth()+1;
			var dd			= dateInfo.getDate();
			var mi			= dateInfo.getMinutes();
			var se			= dateInfo.getSeconds();
			var ms			= dateInfo.getMilliseconds();
			
			if(mm < 10){mm ="0" + mm;}
			if(dd < 10){dd ="0" + dd;}
			
			var dataOrder	= yy+mm+dd+mi+se+ms;
			//dataOrder : 탭의 정렬을 위한 값으로 탭마다 유니크하게 보유 필요 [Drag and Drop]
			appendTabStr	=	""
							+	"<div id=\""+chkId+"TabDiv\" data-order="+dataOrder+" class=\"l-contents-tabs__item l-contents-tabs__item--active\">"
							+		"<div id=\""+chkId+"TabDivTitle\" class=\"l-contents-tabs__title\" name=\"tabDivTitle\" style=\"line-height : 50px;\" url=\""+contentUrl+"\">"+label+"</div>"
							+		"<a id=\""+chkId+"TabDivDeleteA\" class=\"l-contents-tabs__delete\" name=\"tabDivDeleteA\" url=\""+contentUrl+"\">"
							+			"<i class=\"i-cancle\"></i>"
							+		"</a>"
							+	"</div>";
			$('#eAccountTabListDiv').append(appendTabStr);
		}
	}
}

//more탭 펼치기 Class 제거
function eAccountMoreTabRemoveClassActive() {
	$('#eAccountTabMoreDiv').removeClass('active');
}

//more탭의 [X]버튼 클릭
function eAccountMoreTabDelete(id) {
	//이후 작업을 위해 접근한 아이디를 모두 동일하게 구성하기 위한 작업
	var nowViewDivID	= accountCtrl.getViewPageDivID();
	var pageDivID		= id.replace('TabAMoreItemDeleteA','') + 'ViewArea';
	var deleteTabID		= id.replace('DeleteA','');
	
	//현재 선택된 화면 == 제거하려는 more탭 ID
	if(nowViewDivID == pageDivID){
		
		var eAccountTabMoreItemsInfo	= $('#eAccountTabMoreItems');
		var moreItemList				= eAccountTabMoreItemsInfo.children();
		
		var nextViewID				= "";
		var nextViewUrl				= "";
		var nextViewLabel			= "";
		var nextViewchildrenInfo	= null; 
		
		if(moreItemList.length > 1){
			//more탭의 항목 수가 2개 이상인 경우
			var childrenNo			= 0;
			var nextViewchildrenNo	= 0;
			for(var i=0; i<moreItemList.length; i++){
				if(moreItemList[i].id == deleteTabID){
					childrenNo = i;
					break;
				}
			}
			
			/* 제거하려는 more탭의 항목에 따라
			 * 제거한 more탭의 다음 more탭을 보여줄 것인지
			 * 제거한 more탭의 이전 more탭을 보여줄 것인지 결정
			 */
			
			if(childrenNo == 0){
				nextViewchildrenNo = childrenNo + 1; 
			}else{
				nextViewchildrenNo = childrenNo - 1; 
			}
			
			nextViewchildrenInfo = moreItemList[nextViewchildrenNo]
			
			nextViewID		= nextViewchildrenInfo.id;
			nextViewUrl		= nextViewchildrenInfo.getAttribute('url');
			nextViewLabel	= nextViewchildrenInfo.children[0].text.trim();
			
		}else{
			/* more탭의 항목 수가 1개 이하인 경우
			 * 제거 후 more탭의 항목은 모두 제거된 상태이므로
			 * 탭의 가장 마지막 항목을 보여줌
			 */
			var eAccountTabListInfo	= $('#eAccountTabListDiv');
			var tabList				= eAccountTabListInfo.children();
			var lastTabInfo			= tabList[tabList.length-1];
			nextViewchildrenInfo	= lastTabInfo.children[0];
			
			nextViewID		= nextViewchildrenInfo.id;
			nextViewUrl		= nextViewchildrenInfo.getAttribute('url');
			nextViewLabel	= nextViewchildrenInfo.textContent.trim();
		}
		
		eAccountContentHtmlChangeAjax(nextViewID,nextViewLabel,nextViewUrl);
	}
	
	// 선택한 more탭의 항목 및 화면 제거
	$('#'+deleteTabID).remove();
	$('#'+pageDivID).remove();
	
	var moreInfo	= $('#eAccountTabMoreItems');
	var moreList	= moreInfo.children();

	if(moreList.length > 0){
		$('#eAccountTabMoreDiv').css("display",	"");
	}else{
		$('#eAccountTabMoreDiv').css("display", "none");
	}
}

//탭의 항목 제거 후 more탭의 항목 재구성
function eAccountMoreTabRelocation(id,pid) {
	var pidInfo		= $('#'+pid);
	var activePid	= pidInfo.hasClass('l-contents-tabs__item--active')
	
	var eAccountTabListInfo		= $('#eAccountTabListDiv');
	var eAccountTabListchildren	= eAccountTabListInfo.children();
	
	//이후 작업을 위해 접근한 아이디를 모두 동일하게 구성하기 위한 작업
	var viewAreaID		= id.replace('TabDivDeleteA','') + 'ViewArea';
	var viewAreaInfo	= $('#'+viewAreaID);
	
	var nextViewId		= "";
	var nextViewLabel	= "";
	var nextViewUrl		= "";
	
	//고정탭이 있으므로 탭 목록의 항목 수가 2개 이상인 경우
	if(eAccountTabListchildren.length > 1){
		for(var i=0; i<eAccountTabListchildren.length; i++){
			var chkId	= id.replace('TabDivDeleteA','');
			var nowId	= eAccountTabListchildren[i].id.replace('TabDiv','');
			//탭 목록의 탭 아이디와 제거하려는 탭 항목의 아이디가 같은 경우
			if(nowId == chkId){
				if(i==0){
					//첫번째 탭 항목을 제거하는 경우 두번째 탭 항목을 보여줌
					nextViewId		= eAccountTabListchildren[i+1].id.replace('TabDiv','');
					nextViewLabel	= eAccountTabListchildren[i+1].children[0].textContent.trim();
					nextViewUrl		= eAccountTabListchildren[i+1].children[0].getAttribute('url');
				}else{
					//현재 보여주고 있는 탭 항목 이전 탭 항목을 보여줌
					nextViewId		= eAccountTabListchildren[i-1].id.replace('TabDiv','');
					nextViewLabel	= eAccountTabListchildren[i-1].children[0].textContent.trim();
					nextViewUrl		= eAccountTabListchildren[i-1].children[0].getAttribute('url');
				}
			}
		}
	}
	
	//선택한 탭 항목 제거
	pidInfo.remove();
	viewAreaInfo.remove();
	
	eAccountTabListchildren	= eAccountTabListInfo.children();
	
	if(eAccountTabListchildren.length == 0){
		// 탭 항목이 모두 제거된 경우 HOME 선택
		
		var fixedTabAInfo	= $('#fixedTabAcc');
		
		var id		= fixedTabAInfo[0].id;
		var label	= fixedTabAInfo[0].text.trim();
		var url		= fixedTabAInfo[0].getAttribute('url');
		eAccountContentHtmlChangeAjax(id,label,url)
		
	}else{
		/* 탭 항목 제거 후 more탭의 항목이 있을 경우
		 * more탭의 항목을 탭으로 옮겨 담음
		 */
		
		var eAccountTabMoreInfo		= $('#eAccountTabMoreItems');
		var eAccountTabMorechildren	= eAccountTabMoreInfo.children();
		
		if(	eAccountTabListchildren.length	< maxTabSize+1	&&
			eAccountTabMorechildren.length	> 0
		){
			var tabMorechildrenId		= eAccountTabMorechildren[0].id.replace('TabAMoreItemA','').replace('TabAMoreItem','');
			var tabMorechildrenUrl		= eAccountTabMorechildren[0].getAttribute('url');
			var tabMorechildrenlabel	= eAccountTabMorechildren[0].children[0].text.trim();
			
			var dateInfo	= new Date();
			var yy			= dateInfo.getFullYear();
			var mm			= dateInfo.getMonth()+1;
			var dd			= dateInfo.getDate();
			var mi			= dateInfo.getMinutes();
			var se			= dateInfo.getSeconds();
			var ms			= dateInfo.getMilliseconds();
			
			if(mm < 10){mm ="0" + mm;}
			if(dd < 10){dd ="0" + dd;}
			var dataOrder	= yy+mm+dd+mi+se+ms;
			//dataOrder : 탭의 정렬을 위한 값으로 탭마다 유니크하게 보유 필요 [Drag and Drop]
			var appendTabStr	=	""
								+	"<div id=\""+tabMorechildrenId+"TabDiv\" data-order="+dataOrder+" class=\"l-contents-tabs__item l-contents-tabs__item--active\">"
								+		"<div id=\""+tabMorechildrenId+"TabDivTitle\" class=\"l-contents-tabs__title\" name=\"tabDivTitle\" url=\""+tabMorechildrenUrl+"\">"+tabMorechildrenlabel+"</div>"
								+		"<a id=\""+tabMorechildrenId+"TabDivDeleteA\" class=\"l-contents-tabs__delete\" name=\"tabDivDeleteA\" url=\""+tabMorechildrenUrl+"\">"
								+			"<i class=\"i-cancle\"></i>"
								+		"</a>"
								+	"</div>";
			$('#eAccountTabListDiv').append(appendTabStr);
			$('#'+eAccountTabMorechildren[0].id).remove();
		}
		
		setTabActiveNowView();
		
		if(activePid){
			eAccountContentHtmlChangeAjax(nextViewId,nextViewLabel,nextViewUrl);
		}
	}
}

var nowAjaxID	= "";
var nowAjaxUrl	= "";
// 화면 전환
function eAccountContentHtmlChangeAjax(key,label,url,params) {

	//화면 전환 시 띄워져 있는 모든 레이어 팝업 닫기
	$(".divpop_close").trigger("click");
	
	//이후 작업을 위해 접근한 아이디를 모두 동일하게 구성하기 위한 작업		
	var ttReplaceId	= key.replace('TabDivTitle','');
	var tdReplaceId	= ttReplaceId.replace('TabDiv','');
	var taReplaceId	= tdReplaceId.replace('TabAMoreItemA','').replace('TabAMoreItem','');
	var id			= taReplaceId;
		nowAjaxID	= id; // setInterval 로 호출되기때문에 전역변수 변경만하고, 함수내부에서는 지역변수 사용
		nowAjaxUrl	= url;
	
	var contentUrl	= url + "&fragments=content";
	
	var pageID			= url.split('/')[3].split('.')[0].split('_')[1];	
	if(url.split("requesttype=").length > 1) {
		pageID += url.split("requesttype=")[1].split("&")[0]; //신청서 유형 정보 추가
	}
	
	var state	= CoviMenu_makeState(url);
	var title	= url;
	
	history.pushState(state, title, url);
	CoviMenu_SetState(state)
	
	var ajaxTF		= true;
	var content		= $("#content");
	var contentList	= content.children();
	for(var i=0; i<contentList.length; i++){
		var nowListId	= contentList[i].id;
		if(nowListId.length > 0){
			//이미 만들어진 화면인 경우 화면만 전환
			nowListId	= nowListId.replace('ViewArea','');
			if(id == nowListId){
				$('#'+nowListId+'ViewArea').css("display", "");
				
				var functionName	= 'pageView';
				
				evalPage(pageID,functionName,params)
				
				ajaxTF = false;
			}else{
				$('#'+nowListId+'ViewArea').css("display", "none");
			}
		}
	}
	
	//새롭게 만들어야하는 화면인 경우
	if(ajaxTF){
		var resAddDiv
		var functionName	= 'pageInit';
		
		$.ajax({
			type : "GET",
			beforeSend : function(req) {
				req.setRequestHeader("Accept", "text/html;type=ajax");
			},
			async: false,
			url : contentUrl,
			success : function(res) {
				resAddDiv	= res.replace('<script>','</div><script>');
				resAddDiv	= "<div id = \"" + id + "ViewArea\" class=\"accountViewArea\">" + resAddDiv;
			},
			error : function(response, status, error){
				CFN_ErrorAjax(contentUrl, response, status, error);
			}
		});
		
		//content를 찾을 수 없어 Interval 추가
		var bindContent = window.setInterval(function() {
    	    if (document.getElementById("content") != null || document.getElementById("content") != undefined) {
    	        window.clearInterval(bindContent);
    	        
    	        eAccountMenuListControl(id,label,contentUrl); // 탭은 먼저 생성
    	        if(id == "fixedTabAcc" || // 경비결재포탈은 예외
    	        	(
    	        		$("#content").find("#" + id + "ViewArea").length == 0 // 같은메뉴를 로드 전 여러번 클릭한경우 최초1번만 실행
    	        		&& accountCtrl.getViewPageDivID().replace("ViewArea","") == id // 다른메뉴를 로드 전 여러번 클릭한경우 최종메뉴만 로드
    	        	)
    	        ){
	    	        if(id == "fixedTabAcc"){ // 이건 불필요해보이는데 왜 있는거지..
						$("#content").find("#"+id+"ViewArea").remove();
	    	        }
	    	        $("#content").append(resAddDiv);
	    	        
	    	        evalPage(pageID,functionName,params);
    	        }
    	    }
    	}, 200);
		
	}else{
		eAccountMenuListControl(id,label,contentUrl)
	}
}

function evalPage(pageID,functionName,params){
	var evalStr = pageID + '.' + functionName + '(params)'
	try {
		//eval(evalStr);
		let fn = window[pageID][functionName];
		fn.apply(window[pageID], [params]);
	} catch (e) {
		coviCmn.traceLog(e);
	}
}

//좌측 서브 메뉴 선택
$(document).on("click", "a[name='LeftSub']", function(){
	$(".nea_menu_wrap").hide();
	
	var url	= this.getAttribute('url');
	if(url != null && url != ''){
		var id		= this.id;
		var label	= this.childNodes[0].textContent;
		var params	= {'name':'LeftSub'
							, 'id': id
							, 'url': url};
		eAccountContentHtmlChangeAjax(id,label,url,params);
	} 
});

//탭 항목 선택
$(document).on("click", "a[name='tab']", function(){
	var url	= this.getAttribute('url');
	if(url != null && url != ''){
		var id		= this.id;
		var label	= this.text;
		var params	= {'name':'tab'
						, 'id': id
						, 'url': url};
		eAccountContentHtmlChangeAjax(id,label,url,params);
	}
});

//탭 항목 선택
$(document).on("click", "div[name='tabDivTitle']", function(){
	var url	= this.getAttribute('url');
	if(url != null && url != ''){
		var id		= this.id;
		var label	= this.textContent;
		var params	= {'name':'tabDivTitle'
						, 'id': id
						, 'url': url};
		eAccountContentHtmlChangeAjax(id,label,url,params);
	}
});

//more탭 항목 선택
$(document).on("click", "a[name='tabAMoreItemA']", function(){
	var url	= this.getAttribute('url');
	if(url != null && url != ''){
		var id		= this.id;
		var label	= this.text;
		var params	= {'name':'tabAMoreItemA'
							, 'id': id
							, 'url': url};
		eAccountContentHtmlChangeAjax(id,label,url,params);
	}
});

//more탭 항목의[X]버튼 선택
$(document).on("click", "a[name='tabAMoreItemDeleteA']", function(){
	var id = this.id;
	if(id != null && id != ''){
		eAccountMoreTabDelete(id)
	}
});

//탭 항목의[X]버튼 선택
$(document).on("click", "a[name='tabDivDeleteA']", function(){
	var id	= this.id;
	var pid	= this.parentElement.id;
	eAccountMoreTabRelocation(id,pid);
});

//more탭 선택
$(document).on("click", "a[id='eAccountTabMoreA']", function(){
	var tabMoreDiv			= $('#eAccountTabMoreDiv');
	var tabMoreDivclassList	= tabMoreDiv[0].classList;
	var activeAddTF			= true;
	
	for(var i=0; i<tabMoreDivclassList.length; i++){
		var tabMoreDivclassName = tabMoreDivclassList[i];
		if(tabMoreDivclassName == 'active'){
			activeAddTF = false;
		}
	}
	
	if(activeAddTF){
		$('#eAccountTabMoreDiv').addClass('active');
	}else{
		$('#eAccountTabMoreDiv').removeClass('active');
	}
});	


//탭 휠 클릭
$(document).on("mousedown", "div[name='tabDivTitle']", function(e){
    if(e.which == 2) { // 1:좌클릭, 2:휠클릭, 3:우클릭
		$(this).siblings("a[name=tabDivDeleteA]").trigger('click');
    }
});

//달력 컴포넌트 생성
function makeDatepicker(target,startTarget,endTarget,startDefaultDate,endDefaultDate,size,disabledTF, code){
	var openerID	= CFN_GetQueryString("openerID");
	var twindate	= true;
	
	if(!startTarget){
		startTarget = target + '_Date';
	}
	
	if(!endTarget){
		twindate = false;
	}
	
	if(!size){
		size = 110;
	}
	
	if(!disabledTF){
		disabledTF = false;
	}
	if(!code) {
	    code = "";
	} else {
	    var bigSplit = code.split("|");
	    var strAttr = "";
	    $.each(bigSplit, function (i, item) {
	        strAttr += item.split(";")[0] + "=\"" + item.split(";")[1] + "\" ";
	    });
	}
	var html  = '';
		if(disabledTF){
			html += "<input id=\""+startTarget+"\" class=\"adDate\" type=\"text\" readonly=\"\" style=\"width: "+size+"px\"  disabled=\"true\"" + strAttr + ">";
		}else{
			html += "<input id=\""+startTarget+"\" class=\"adDate\" type=\"text\"  style=\"width: "+size+"px; ime-mode:disabled;\""
			+"onchange='datepickerChange(this)' onkeyup='datepickerKeyup(this)' " + strAttr + ">";
			html += "<a class=\"icnDate\" onclick=\"onclickMakeDatepicker('"+startTarget+"')\"></a>";
		}

	if(twindate){
		html += "<input id=\""+startTarget+"Hidden\"	type=\"hidden\" twinId=\""+endTarget+"_from\" />";
	}else{
		html += "<input id=\""+startTarget+"Hidden\"	type=\"hidden\"/>";
	}
	
	if(twindate){
		html += ' ~ ';
		if(disabledTF){
			html += "<input id=\""+endTarget+"\" class=\"adDate\" type=\"text\" readonly=\"\" style=\"width: "+size+"px\" disabled=\"true\"" + strAttr + ">";
		}else{
			html += "<input id=\""+endTarget+"\" class=\"adDate\" type=\"text\"  style=\"width: "+size+"px; ime-mode:disabled;\""
			+"onchange='datepickerChange(this)' onkeyup='datepickerKeyup(this)'" + strAttr + ">";
			html += "<a class=\"icnDate\" onclick=\"onclickMakeDatepicker('"+endTarget+"')\"></a>";
		}
		html += "<input id=\""+endTarget+"Hidden\"	type=\"hidden\" twinId=\""+startTarget+"_to\" />";
	}
	
		html += '<label style="position:absolute; width:1px;"></label>';
		
	var targetInfo;
		
	if(openerID == "undefined"){
		targetInfo	= accountCtrl.getInfo(target);
	}else{
		targetInfo	= $("#" + target);
	}
	
	if(targetInfo){
		targetInfo.append(html);
	}
	
	var startTargetInfo;
	var startTargetHiddenInfo;
	
	if(openerID == "undefined"){
		startTargetInfo			= accountCtrl.getInfo(startTarget);
		startTargetHiddenInfo	= accountCtrl.getInfo(startTarget + "Hidden");
		
	}else{
		startTargetInfo			= $("#" + startTarget);
		startTargetHiddenInfo	= $("#" + startTarget + "Hidden");
		
	}
	
	startTargetHiddenInfo.datepicker({
		onSelect	: function(dateText){
			onSelectMakeDatepicker(startTarget,dateText);
		}
	});
	
	if(startDefaultDate){
		
		startDefaultDate = startDefaultDate + "";
		
		var y		= startDefaultDate.substring(0,4);
		var m		= startDefaultDate.substring(4,6);
		var d		= startDefaultDate.substring(6,8);
		var dateStr	= y+'.'+m+'.'+d;
		
		startTargetInfo.val(dateStr);
	}
	
	if(twindate){		
		var endTargetInfo;
		var endTargetHiddenInfo;
		
		if(openerID == "undefined"){
			endTargetInfo		= accountCtrl.getInfo(endTarget);
			endTargetHiddenInfo	= accountCtrl.getInfo(endTarget + "Hidden");			
		}else{
			endTargetInfo		= $("#" + endTarget);
			endTargetHiddenInfo	= $("#" + endTarget + "Hidden");			
		}
		
		if(endTargetHiddenInfo){
			endTargetHiddenInfo.datepicker({
				onSelect	: function(dateText){
					onSelectMakeDatepicker(endTarget,dateText);
				}
			});
		}
		
		if(endDefaultDate){			
			endDefaultDate = endDefaultDate + "";
			
			var y		= endDefaultDate.substring(0,4);
			var m		= endDefaultDate.substring(4,6);
			var d		= endDefaultDate.substring(6,8);
			var dateStr	= y+'.'+m+'.'+d;
			
			endTargetInfo.val(dateStr);
		}
	}
}

function datepickerChange(obj){
	var objVal = obj.value;
	var objId = obj.id;
	var objHidden = accountCtrl.getInfo(objId + "Hidden")
	
	objVal = objVal.replace(/\D/g, "");
	
	if(objVal.length<8){
		obj.value = "";
		objHidden.val = "";
		return;
	}
	objVal = objVal.substr(0,8);
	
	var objValDt = accComm.accFormatDate(objVal);
	
	var setDate = new Date(objValDt);
	if(_ie || _edge) setDate = new Date(objValDt.replace(/\./gi, "-"));
	
	if(setDate=="Invalid Date"){
		obj.value = "";
		objHidden.val = "";
		return;
	}
	
	obj.value = objValDt;
	var objValHd = objVal.substr(4,2) + "/" + objVal.substr(6,2) + "/" + objVal.substr(0,4);
	objHidden.val(objValHd);
	
	if($(obj).parent().attr("onchange") != undefined) {
		//eval($(obj).parent().attr("onchange"));
		coviCmn.callFnBasedNamespace($(obj).parent().attr("onchange"));
	}
}

function datepickerKeyup(obj){
	var objVal = obj.value;
	objVal = objVal.replace(/[^0-9.]/g, "");
	obj.value = objVal;
}

function onclickMakeDatepicker(key){
	var openerID			= CFN_GetQueryString("openerID");
	var keyTargetInfo;
	var keyTargetHiddenInfo;
	
	if(openerID == "undefined"){
		keyTargetInfo		= accountCtrl.getInfo(key);
		keyTargetHiddenInfo	= accountCtrl.getInfo(key + "Hidden");		
	}else{
		keyTargetInfo		= $("#" + key);
		keyTargetHiddenInfo	= $("#" + key + "Hidden");
	}
	
	var defaultDate = keyTargetInfo.val(); 
	keyTargetHiddenInfo && (keyTargetHiddenInfo.datepicker('show'));
	if(defaultDate != null && defaultDate != undefined && defaultDate != ""){
		keyTargetHiddenInfo.datepicker("setDate", new Date(defaultDate));
	}else{
		keyTargetInfo && (keyTargetInfo.val(''));
	}
}

function onSelectMakeDatepicker(key,dateText){
	var openerID			= CFN_GetQueryString("openerID");
	var keyTargetInfo;
	var keyTargetHiddenInfo;
	var keyTarget;
	
	if(openerID == "undefined"){
		keyTargetInfo		= accountCtrl.getInfo(key);
		keyTargetHiddenInfo	= accountCtrl.getInfo(key + "Hidden");
		keyTarget = accountCtrl.getInfo(key.replace("_Date", ""));
	}else{
		keyTargetInfo		= $("#" + key);
		keyTargetHiddenInfo	= $("#" + key + "Hidden");
		keyTarget = $("#" + key.replace("_Date", ""));
	}
	
	var datepickerInfo = keyTargetHiddenInfo;
	var twinId = datepickerInfo[0].getAttribute('twinId');
	
	if(!twinId){
		keyTargetInfo.val((new Date(dateText)).format('yyyy.MM.dd'));
	}else{
		var fromto	= twinId.substring(twinId.lastIndexOf('_')+1);
		var twinKey	= twinId.substring(0,twinId.lastIndexOf('_'));
		
		var twinKeyTargetInfo;
		if(openerID == "undefined"){
			twinKeyTargetInfo	= accountCtrl.getInfo(twinKey);
		}else{
			twinKeyTargetInfo	= $("#" + twinKey);
		}

		var twinVal = twinKeyTargetInfo.val();
		
		if(!twinVal){
			keyTargetInfo.val((new Date(dateText)).format('yyyy.MM.dd'));
		}else{
			var setValNum	= (new Date(dateText)).format('yyyyMMdd');
			var twinValNum	= twinVal.replaceAll('.','');
			
			if(fromto == 'from'){
				if(setValNum > twinValNum){
					twinKeyTargetInfo.val((new Date(dateText)).format('yyyy.MM.dd'));
				}
			}else{
				if(setValNum < twinValNum){
					twinKeyTargetInfo.val((new Date(dateText)).format('yyyy.MM.dd'));
				}
			}
			keyTargetInfo.val((new Date(dateText)).format('yyyy.MM.dd'));
		}
	}
	
	if(keyTarget.attr("onchange") != undefined) {
		$(keyTarget).trigger("change");
	}
}

//달력 컴포넌트 생성
//미사용 -makeDatepicker로 변경 필요
function makeAccSimpleCalendar(target, defaultDate, onChange) {
	var chgEvt = "";
	if(onChange != null){
		chgEvt = 'onChange="'+onChange+'"'
	}
	var html = '';
	html += '<span name="date">';
	html += '	<input id="' + target + '_Date" type="text" style="width:80px;"'+chgEvt+'>';
	html += '</span>';
	
	$('#' + target).append(html);
	$('#' + target + '_Date').datepicker({
		dateFormat: 'yy.mm.dd',
	    showOn: 'button',
	    buttonText : 'calendar',
	    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
        buttonImageOnly: true
	});
	
	if(defaultDate == null || defaultDate == undefined ){
		$('#' + target + '_Date').datepicker("setDate", new Date().format('yyyy.MM.dd'));
	} else {
		$('#' + target + '_Date').datepicker("setDate", defaultDate);
	}
}

// page Header title set
function setHeaderTitle(target) {
	var leftMenuObj = $('#' + accountCtrl.getViewPageDivID().replace('ViewArea','')).clone();
	leftMenuObj.find("span.fCol19abd8").remove();
	
	accountCtrl.getInfo(target).text(leftMenuObj.text())
}

function setApplicationTitle() {
	var date = new Date();
	//당월
	var deadLineDate = new Date(date.getFullYear(), date.getMonth() , 1);
	//전월
	var deadLineInfo = accComm.deadlineInfo;
	if(deadLineInfo)
		if(deadLineInfo.standardMonth == "01")
			deadLineDate = new Date(deadLineDate.setDate(deadLineDate.getDate() - 1));
	
	//n월 신청유형 - 사용자명
	var str = (deadLineDate.getMonth()+1) 
				+ Common.getDic("ACC_lbl_month") + " " 
				+ accountCtrl.getInfo('headerTitle').text() + " - "
				+ sessionObj.USERNAME;
	
	return str;
}

// page SearchType by Property
function setPropertySearchType(pageID,target) {
	
	$.ajax({
		type:"POST",
		data:{
			"pageID" : pageID
		},
		url:"/account/accountCommon/getPropertyInfoSearchType.do",
		async	: false,
		success:function (data) {
			try{
				if(data.status == "SUCCESS"){
					
					var openerID	= CFN_GetQueryString("openerID");
					if(openerID == "undefined"){
						accountCtrl.getInfo(target).val(data.pageSearchTypeProperty);
					}else{
						$("#" + target).val(data.pageSearchTypeProperty);
					}
					
				}else{
					//Common.Error('오류가 발생하였습니다. 관리자에게 문의 바랍니다.'); // data.message	
				}
			}catch(err){
				coviCmn.traceLog(err);
			}
		},
		error:function (error){
			//Common.Error('오류가 발생하였습니다. 관리자에게 문의 바랍니다.'); // error.message
		}
	});
}

// page SyncType by Property
function setPropertySyncType(pageID,target) {
	
	$.ajax({
		type:"POST",
		data:{
			"pageID" : pageID
		},
		url:"/account/accountCommon/getPropertyInfoSyncType.do",
		async	: false,
		success:function (data) {
			try{
				if(data.status == "SUCCESS"){
					
					var openerID	= CFN_GetQueryString("openerID");
					if(openerID == "undefined"){
						accountCtrl.getInfo(target).val(data.pageSyncTypeProperty);
					}else{
						$("#" + target).val(data.pageSyncTypeProperty);
					}
					
				}else{
					//Common.Error('오류가 발생하였습니다. 관리자에게 문의 바랍니다.'); // data.message	
				}
			}catch(err){
				coviCmn.traceLog(err);
			}
		},
		error:function (error){
			//Common.Error('오류가 발생하였습니다. 관리자에게 문의 바랍니다.'); // error.message
		}
	});
}

/*
 OBJECT 복사
 */
function objCopy(inputObj) {
	var obj = {};
	
	for(var key in inputObj){
		var arrCk = Array.isArray(inputObj[key]);
		if(arrCk){
			var newArr = [];
			for(var i = 0; i<inputObj[key].length; i++){
				var arrObj = inputObj[key][i];
				newArr.push(objCopy(arrObj))
			}
			obj[key] = newArr;
		}else{
			obj[key] = inputObj[key];
		}
	}
	return obj
}	
function convertCode(str){
	if(str != null){
		str = str.replace(/</g,"&lt;");
		str = str.replace(/>/g,"&gt;");
		str = str.replace(/\"/g,"&quot;");
		str = str.replace(/\'/g,"&#39;");
		str = str.replace(/,/g,"&#44;");	
	}
	return str;
}

function revertConvertCode(str){
	if(str != null){
		str = str.replace(/&lt;/g,"<");
		str = str.replace(/&gt;/g,">");
		str = str.replace(/&quot;/g,'"');
		str = str.replace(/&#39;/g,"'");
		str = str.replace(/&#44;/g,",");
	}
	return str;
}	
function chkInputCode(str){
	var chkStr = /[`<]/gi;
	var chk;
	if(chkStr.test(str) == true){
		chk = true;
	}else{
		chk = false;
	}
	return chk;
}


//파일 크기 변환 목록
var sizeUnitList ={
	"0": "bytes",
	"1": "KB",
	"2": "MB",
	"3": "GB",
	"4": "TB",
	"5": "PB",
}

//파일 크기 체크
function ckFileSize(val) {
	var retVal = "";
	var numVal = ckNaN(val);
	var calcSize = calcFileSize(val, 0);
	retVal = calcSize.size +" " +calcSize.unit;
	return retVal
}

//파일 크기 변환
function calcFileSize(val, unit) {

	val = ckNaN(val)
	val = val.toFixed(2);
	if(sizeUnitList[unit+1]==null){
		var retVal = {
			size : val,
			unit : sizeUnitList[unit]
		}
		return retVal;
	}
	else{
		if(unit==null){
			unit=0;
		}
		if(val > 1024){
			var retVal = calcFileSize((val/1024), unit+1)
			return retVal;
		}
		else{
			var retVal = {
				size : val,
				unit : sizeUnitList[unit]
			}
			return retVal;
		}
	}
}

function accFilter(arr, key, value) {
	return arr.filter(obj => obj[key] == value)[0];
}

function accFetch(api, method, request) {
	let options = {
		headers: new Headers({
			"Content-type": "application/json"
		}),
		url: api,
		method: method
	}

	if (method == "GET") {
		Object.keys(request).forEach(function(key, index) {
			options.url = options.url + (index === 0 ? "?" : "&") + key + "=" + request[key];
		});
	} else {
		options.body = JSON.stringify(request);
	}
	
	return fetch(options.url, options)
				.then((response) => response.json().then((json) => {
					if (json.status == "FAIL") {
						Common.Error(Common.getDic("ACC_msg_error")); //오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
					return json;
				}))
				.catch((error) => {
					console.log(error);
					console.log(CFN_GetQueryString("callBackFunc"));
					Common.Error(Common.getDic("ACC_msg_error")); //오류가 발생했습니다. 관리자에게 문의바랍니다.
				});
}

function accMerge(target, source) {
	if (target === undefined) { target = new Object(); }
	for (let key of Object.keys(source)) {
        if (source[key] instanceof Object) Object.assign(source[key], accMerge(target[key], source[key]))
    }
    Object.assign(target || {}, source)
    return target;
}

/**
IE에서 findIndex가 안먹혀서 만든 함수.
*/
function accFindIdx(arr, keyField, keyValue) {
	var retVal = -1;
	if(arr != null
			&& keyField != null
			&& keyValue != null){
		var arrCk = Array.isArray(arr);
		if(arrCk){
			for(var i=0;i<arr.length; i++){
				var item = arr[i];
				if(item[keyField] == keyValue){
					retVal = i;
					break;
				}
			}
		}
	}
	return retVal
}

function accFind(arr, keyField, keyValue) {
	var retVal = {};
	if(arr != null
			&& keyField != null
			&& keyValue != null){
		var arrCk = Array.isArray(arr);
		if(arrCk){
			for(var i=0;i<arr.length; i++){
				var item = arr[i];
				if(item[keyField] == keyValue){
					retVal = item;
					break;
				}
			}
		}
	}
	return retVal
}

//input에 숫자와 , 이외의 값 제거
function removeChar(obj){
	var objVal = obj.value;
	objVal = objVal.charAt(0) == "-" ? objVal.charAt(0) + objVal.substr(1).replace(/[^0-9,]/g, "") : objVal.replace(/[^0-9,]/g, "");
	obj.value = objVal;
}

//input에 숫자와 - 이외의 값 제거
function removeCharDash(obj){
	var objVal = obj.value;
	objVal = objVal.replace(/[^0-9\-]/g, "");
	obj.value = objVal;
}

function removeCharMoney(obj) {
	var objVal = obj.value;
	objVal = objVal.replace(/[^0-9\-,.]/g, "");
	obj.value = objVal;
}

//비용신청에서 사용
if (!window.accComm) {
    window.accComm = {};
}

var formJson;

(function(window) {
	var accComm = {
			//신청서 정보
			pageExpenceFormInfo : {},
			
			getCompanyCodeOfUser : function(pSessionUser) {
				var SessionUser = pSessionUser == undefined ? "" : pSessionUser;
				var pKey = "EACC_User_"+SessionUser+"CompanyCode";
				if (localCache.exist(pKey)) {
					var CompanyCode = localCache.get(pKey);
					if(CompanyCode != undefined && CompanyCode != "" && CompanyCode.length > 0){
						return CompanyCode;
					}
				}
				CompanyCode = "";
				$.ajax({
					url : "/account/accountCommon/getCompanyCodeOfUser.do",
					type : "POST",
					async : false,
					data : {
						"SessionUser" : SessionUser
					},
					success : function(data) {
						if(data.status == "SUCCESS"){
							CompanyCode = data.CompanyCode;
							localCache.set(pKey, CompanyCode, null);
						}else{
							Common.Error(Common.getDic("ACC_msg_error")); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error : function(error){
						Common.Error(Common.getDic("ACC_msg_error")); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
				
				return CompanyCode;
			},
			
			getBaseCodeName : function(CodeGroup, Code, CompanyCode) {
				var CodeName = "";
				$.ajax({
					url : "/account/baseCode/getBaseCodeName.do",
					type : "POST",
					async : false,
					data : {
						CodeGroup : CodeGroup,
						Code : Code,
						CompanyCode : CompanyCode
					},
					success : function(data) {
						if(data.status == "SUCCESS"){
							CodeName = data.CodeName;
						}else{
							Common.Error(Common.getDic("ACC_msg_error")); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error : function(error){
						Common.Error(Common.getDic("ACC_msg_error")); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
				
				return CodeName;
			},

			//HTML폼에 @@{}값 변환 세팅
			accHtmlFormSetVal : function(inputStr, replaceMap) {
				var me = this;
				var noInfiniteLoofVal = 0;
				if(inputStr == null
						|| replaceMap == null){
					return "";
				}
				while (true) {
					var stIdx = inputStr.indexOf("@@{");
					var edIdx = inputStr.indexOf("}", stIdx+1);
					
					if(stIdx != -1
						&& edIdx != -1){
						var getWord = inputStr.substr(stIdx, edIdx-stIdx+1);
						var getKeyWord = inputStr.substr(stIdx+3, edIdx-stIdx-3);
						var transWord = replaceMap[getKeyWord];
						inputStr = inputStr.replaceAll(getWord, nullToBlank(transWord));
					}
					else{
						break;
					}
					noInfiniteLoofVal ++;
					if(noInfiniteLoofVal>9999){
						break;
					}
				}
				return inputStr;
			},

			//HTML폼에 **{}다국어 처리
			accHtmlFormDicTrans : function(inputStr) {
				var me = this;
				if(inputStr==null){
					return "";
				}
				var tempVal = 0;
				while (true) {
					var stIdx = inputStr.indexOf("**{");
					var edIdx = inputStr.indexOf("}", stIdx+1);
					
					if(stIdx != -1
						&& edIdx != -1){

						var getWord = inputStr.substr(stIdx, edIdx-stIdx+1);
						var getKeyWord = inputStr.substr(stIdx+3, edIdx-stIdx-3);
						var transWord = Common.getDic(getKeyWord);
						if(isEmptyStr(transWord)){
							transWord = getKeyWord;
						}
						inputStr = inputStr.replace(getWord, transWord);
					}
					else{
						break;
					}
					
					tempVal ++;
					if(tempVal>9999){
						break;
					}
				}
				return inputStr;
			},
			
			//카드 영수증 띄우기
			accCardAppClick : function (ReceiptID, openerStr){
				var me = this;
				if(ReceiptID == null || ReceiptID == ""){
					return;
				}
				var popupID		=	"cardReceiptPopup";
				var popupTit	=	Common.getDic("ACC_lbl_cardReceiptInvoice");	//신용카드매출정보
				var popupName	=	"CardReceiptPopup";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"receiptID="	+	ReceiptID	+	"&"
								+	openerStr
								+	"includeAccount=N&"
				Common.open(	"",popupID,popupTit,url,"320px","510px","iframe",true,null,null,true);
			},

			//전자세금계산서 띄우기
			accTaxBillAppClick : function (TaxInvoiceID, openerStr){
				var me = this;
				if(TaxInvoiceID == null || TaxInvoiceID == ""){
					return;
				}

				var popupID		=	"taxInvoicePopup";
				var popupTit	=	Common.getDic("ACC_lbl_taxInvoiceCash");
				var popupName	=	"TaxInvoicePopup";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"taxInvoiceID="	+	TaxInvoiceID	+	"&"
								+	openerStr
								+	"includeAccount=N&"
				Common.open(	"",popupID,popupTit,url,"1000px","600px","iframe",true,null,null,true);
			},
			
			// (비용정산) : 증빙(지급정보) 상세 팝업
			accCombineCostDetClick : function (ExpListID, openerStr, appType, requestType){
				var me = this;
				if(ExpListID == null || ExpListID == ""){
					return;
				}
				var me = this;
				var iHeight = 600;
				var iWidth = 1600;
		        var sUrl = "/account/expenceApplication/ExpenceApplicationListDetailViewPopup.do?" 
		        			+ "ExpAppListID=" + ExpListID + "&"
		        			+ openerStr
		        			+ "RequestType=" + requestType + "&"
		        			+ "AppType=" + appType + "&"
		        			+ "CompanyCode=" + accComm.getCompanyCodeOfUser(sessionObj["UR_Code"]) + "&"
							+ "gloct=" + (getInfo("Request.gloct") ? getInfo("Request.gloct") : "");
		        
		        var sSize = "both";
				CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
			}, 

			accMobileReceiptAppClick : function (FileID, openerStr) {
				var me = this;
				if(FileID == null || FileID == ""){
					return;
				}
				
				var popupID		=	"fileViewPopup";
				var popupTit	=	Common.getDic("ACC_lbl_receiptPopup");	//영수증 보기
				var popupName	=	"FileViewPopup";
				var callBack	=	"accComm.accZoomMobileReceiptAppClick";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"fileID="		+	FileID		+	"&"			
									+	"openerID="		+	""			+	"&"
									+	"callBackFunc="	+	callBack;
				Common.open(	"",popupID,popupTit,url,"340px","500px","iframe",true,null,null,true);
			},
			
			accZoomMobileReceiptAppClick : function(info) {
				var me = this;
				
				var popupID		=	"fileViewPopupZoom";
				var popupTit	=	Common.getDic("ACC_lbl_receiptPopup");	//영수증 보기
				var popupName	=	"FileViewPopup";
				var url			=	"/account/accountCommon/accountCommonPopup.do?"
								+	"popupID="		+	popupID		+	"&"
								+	"popupName="	+	popupName	+	"&"
								+	"fileID="		+	info.FileID	+	"&"						
								+	me.pageOpenerIDStr				+	"&"		
								+	"zoom="			+	"Y"
				Common.open(	"",popupID,popupTit,url,"490px","700px","iframe",true,null,null,true);
			},
			

			//마감일자 정보
			deadlineInfo : {
				lastGetDate : "",
				deadlineStDt : null,
				deadlineEdDt : null,
					
			},

			//날짜 포멧처리
			accFormatDate : function (inputDateStr){
				var retVal = "";
				if(inputDateStr != null){
					retVal = inputDateStr.toString();
					retVal = retVal.replaceAll(".", "");
					retVal = retVal.replaceAll("-", "");
					retVal = retVal.replaceAll("/", "");
					retVal = ckNaN(retVal).toString();
					retVal = retVal.substr(0,4) + "." + retVal.substr(4,2) + "." + retVal.substr(6,2) 
				}
				return retVal;
			},

			//날짜 포멧처리
			accFormatDatefromDate : function (inputDate){
				var retVal = "";
				if(inputDate != null){
					retVal = inputDate.format("yyyyMMdd");
					retVal = retVal.replaceAll(".", "");
					retVal = retVal.replaceAll("-", "");
					retVal = retVal.replaceAll("/", "");
					retVal = ckNaN(retVal).toString();
					retVal = retVal.substr(0,4) + "." + retVal.substr(4,2) + "." + retVal.substr(6,2) 
				}
				return retVal;
			},
			
			//마감일자정보 반환
			getDeadlindDate : function (){
				var me = this;
				var ret = "";
				if(me.deadlineInfo.deadlineStDt != null
						&& me.deadlineInfo.deadlineEdDt != null){
					ret =  me.accFormatDatefromDate(me.deadlineInfo.deadlineStDt)
					+ "~" + me.accFormatDatefromDate(me.deadlineInfo.deadlineEdDt);
				}
				return ret;
			},
			
			//마감일자 체크
			accDeadlineCk : function (inputDateStr){
				var me = this;

				inputDateStr = me.accFormatDate(inputDateStr);
				return me.deadlineCk(inputDateStr);
			},

			//마감일자 정보 조회후 세팅
			setDeadlineInfo : function (){
				var me = this;

				var today = new Date();
				var todayStr = today.format("yyyyMMdd");
				
				var companyCode = accComm.getCompanyCodeOfUser(Common.getSession("USERID"));
				
				$.ajax({
					url : "/account/deadline/getDeadlineInfo.do",
					type : "POST",
					data : {
						"companyCode" : companyCode
					},
					success : function(data) {
						if (data.status == "SUCCESS"){
							if(data.list!=null){
								
								var today = new Date();
								var todayStr = today.format("yyyyMMdd");
								me.deadlineInfo.lastGetDate = todayStr;
								if(data.list.length > 0) {
									if(data.list[0].DeadlineStartDate != null){
										me.deadlineInfo.deadlineStDt = new Date(data.list[0].DeadlineStartDate.replaceAll(".", "/"));
									}
									if(data.list[0].DeadlineFinishDate != null){
										me.deadlineInfo.deadlineEdDt = new Date(data.list[0].DeadlineFinishDate.replaceAll(".", "/"));
									}
									if(data.list[0].StandardMonth != null){
										me.deadlineInfo.standardMonth = data.list[0].StandardMonth;
									}
								}
							}
						}else{
							console.log("==DEAD ERR1==", data);
						//	Common.Error('오류가 발생하였습니다. 관리자에게 문의 바랍니다.'); // data.message
						}
					},
					error : function(error){
						console.log("==DEAD ERR2==", error);
					//	Common.Error('오류가 발생하였습니다. 관리자에게 문의 바랍니다.'); // error.message
					}
				});
				
			},

			//마감일자정보 체크
			deadlineCk : function (inputDateStr){
				var me = this;
				inputDateStr = inputDateStr.replaceAll(".", "/");
				var inputDate = new Date(inputDateStr);
				var retVal = false;
				retVal = (me.deadlineInfo.deadlineEdDt >= inputDate)
					//&& (me.deadlineInfo.deadlineStDt <= inputDate)
				return retVal;
			},
			
			
			//신청서 관리 정보 가져오기
			getFormManageInfo : function (requestType, companyCode) {
				var me = this;
				
				$.ajax({
					type:"POST",
					url:"/account/formManage/getFormManageInfo.do",
					data:{
						"formCode" : requestType,
						"companyCode" : companyCode
					},
					async:false,
					success:function (data) {
						if(data.result == "ok" && data.list != null && data.list.length > 0){
							me[requestType] = {};
							me[requestType].pageExpenceFormInfo = data.list[0];
							me[requestType].pageExpenceFormInfo.mode = "DRAFT";
							me[requestType].pageExpenceFormInfo.templatemode = "Write";
							
							setInfoAll(me[requestType].pageExpenceFormInfo);
							setInfo("RuleInfo", getInfo("RuleInfo").replace(/item/gi, 'ruleitem'));
							accComm.getStandardBriefSearchStr(requestType);
						}
						else{
							Common.Error(Common.getDic("ACC_msg_error"));	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error(Common.getDic("ACC_msg_error"));	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			//조회용 신청서 관리 정보 가져오기
			getFormLegacyManageInfo : function (requestType, companyCode, ExpAppID) {
				var me = this;
				
				$.ajax({
					type:"POST",
					url:"/account/formManage/getFormLegacyManageInfo.do",
					data:{
						"formCode" : requestType,
						"companyCode" : companyCode,
						"ExpAppID" : ExpAppID
					},
					async:false,
					success:function (data) {
						if(data.result == "ok" && data.list != null && data.list.length > 0){
							me[requestType] = {};
							me[requestType].pageExpenceFormInfo = data.list[0];
							me[requestType].pageExpenceFormInfo.mode = "DRAFT";
							me[requestType].pageExpenceFormInfo.templatemode = "Write";
							
							setInfoAll(me[requestType].pageExpenceFormInfo);
							setInfo("RuleInfo", getInfo("RuleInfo").replace(/item/gi, 'ruleitem'));
							accComm.getStandardBriefSearchStr(requestType);
						}
						else{
							Common.Error(Common.getDic("ACC_msg_error"));	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
						}
					},
					error:function (error){
						Common.Error(Common.getDic("ACC_msg_error"));	//오류가 발생했습니다. 관리자에게 문의 바랍니다.
					}
				});
			},
			
			getStandardBriefSearchStr : function (requestType) {
				var me = this;

				var StandardBriefInfo = me[requestType].pageExpenceFormInfo.StandardBriefInfo;
				var StandardBriefSearchStr = "";
				for(var i=0; i<StandardBriefInfo.length; i++) {
					$(StandardBriefInfo[i].item).each(function() { StandardBriefSearchStr += "'" + this + "',"});
				}
				StandardBriefSearchStr = StandardBriefSearchStr.slice(0,-1);
				
				me[requestType].pageExpenceFormInfo.StandardBriefSearchStr = StandardBriefSearchStr;
			},
			
			getJobFunctionData : function(requestType) {
				var me = this;
				var jobFunctionCode = me[requestType].pageExpenceFormInfo.AccountChargeInfo;

				var scChrg = "";
				
				if(jobFunctionCode && getJFID()) {
					$.ajax({
						type:"POST",
						url:"/approval/legacy/getJobFunctionData.do",
						async:false,
						data:{
							JobFunctionCode : jobFunctionCode
							, CompanyCode : accComm.getCompanyCodeOfUser(Common.getSession("USERID"))
						},
						success:function (data) {
							if(data.status == "SUCCESS" && data.result.JobFunctionData){
								scChrg = data.result.JobFunctionData;
							}
						},
						error:function (error){
							Common.Error(Common.getDic("ACC_msg_error")); // 오류가 발생하였습니다. 관리자에게 문의바랍니다.
						}
					});
				}
				
				return scChrg;
			},
			
			getFiscalYearByDate : function(executeDate) {
				var FiscalYear = "";

				var companyCode = accComm.getCompanyCodeOfUser(Common.getSession("USERID"));
				
				$.ajax({
					type:"POST",
					url:"/account/budgetFiscal/getFiscalYearByDate.do",
					async:false,
					data:{
						companyCode : companyCode,
						executeDate : executeDate
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							FiscalYear = data.FiscalYear;
						}
					},
					error:function (error){
						Common.Error(Common.getDic("ACC_msg_error")); // 오류가 발생하였습니다. 관리자에게 문의바랍니다.
					}
				});
				
				return FiscalYear;
			},
			
			setComboByProofInfo : function(requestType, target, companyCode) {
				var me = this;
				
				var ProofInfo = me[requestType].pageExpenceFormInfo.ProofInfo;
				var item = [];
				for(var i = 0; i < ProofInfo.length; i++) {
					var info = ProofInfo[i];
					if(info.DNCode == companyCode || info.DNCode == "ALL") {
						item = info.item;
					}
				}
				
				accountCtrl.getComboInfo(target).find("option").each(function(i, obj) {
					var isUse = false;
					for(var j = 0; j < item.length; j++) {
						if(obj.value == item[j]) {
							isUse = true;
							break;
						}
					}

					if(!isUse) {
						accountCtrl.getComboInfo(target).find("option[value="+obj.value+"]").remove();
					}
				});
				
				accountCtrl.getComboInfo(target).bindSelect();
				
				accountCtrl.getComboInfo(target).change();
			},
			
			accLinkOpen: function(ProcessID, forminstanceID, bstored, expAppID){
				if(typeof forminstanceID == 'undefined' || forminstanceID == 'undefined') {
					forminstanceID = '&archived=true';
				}
				
				if(typeof bstored == 'undefined' || bstored == 'undefined') {
					bstored = 'false';
				}
				
				var expAppInfo = "";
				if(typeof expAppID != "undefined" && expAppID != "undefined") {
					expAppInfo = "&ExpAppID=" + expAppID + "&taskID=";
				}
				
				var ownerExpAppID = CFN_GetQueryString("ExpAppID");
				if(ownerExpAppID == "undefined" && formJson && formJson.Request) ownerExpAppID = formJson.Request.expAppID;
				
				var FormUrl = document.location.protocol + "//" + document.location.host + "/approval/approval_Form.do";
				CFN_OpenWindow(FormUrl + '?mode=COMPLETE&processID='+ProcessID + "&forminstanceID=" + forminstanceID + "&bstored=" + bstored +"&ownerExpAppID=" + ownerExpAppID + expAppInfo ,'',1070, 998, 'scroll');
			},
			
			getProofNameByCode: function(ProofCode) {
				var ProofName = "";
				switch(ProofCode) {
				case "CorpCard": 	ProofName = Common.getDic("ACC_lbl_corpCard"); break;
				case "TaxBill": 	ProofName = Common.getDic("ACC_lbl_taxInvoiceCash"); break;
				case "PaperBill": 	ProofName = Common.getDic("ACC_lbl_paperBill"); break;
				case "CashBill": 	ProofName = Common.getDic("ACC_lbl_cashBill"); break;
				case "PrivateCard": ProofName = Common.getDic("ACC_lbl_privateCard"); break;
				case "EtcEvid": 	ProofName = Common.getDic("ACC_lbl_etcEvid"); break;
				case "Receipt": 	ProofName = Common.getDic("ACC_lbl_mobileReceipt"); break;
				}
				
				return ProofName;
			},
			
			accPageAmtSet: function(evidList, appType) {				
				var me = this;
	
				var totalAmt = 0, totalReqAmt = 0;
				var totalCnt = evidList.length;
	
				var EvidJson = {};
				for(var i = 0; i < evidList.length; i++){
					var item = evidList[i];
					var id = item.ProofCode;
					
					var itemTotalAmt = ckNaN(item.TotalAmount);
					var itemReqAmt = ckNaN(item.divSum == undefined ? item.Amount : item.divSum);
					
			        if(EvidJson[id] == undefined) {
			        	EvidJson[id] = itemTotalAmt;
			        	EvidJson[id+"Cnt"] = 1;
			        } else {
			        	EvidJson[id] = Number(EvidJson[id]) + Number(itemTotalAmt);
			        	EvidJson[id+"Cnt"] = Number(EvidJson[id+"Cnt"]) + 1;
			        }
			        
					totalAmt = totalAmt + itemTotalAmt;
					totalReqAmt = totalReqAmt + itemReqAmt;
				}
	
				var SBJson = {};
				for(var i = 0; i < evidList.length; i++) {
				    var divList = evidList[i].divList;
				    if(divList == undefined) {
				    	divList = [];
				    	if(evidList[i].StandardBriefName != undefined && evidList[i].Amount != undefined) {
					    	divList[0] = {};
					    	divList[0].Amount = evidList[i].Amount;
					    	divList[0].StandardBriefName = evidList[i].StandardBriefName;
				    	}
				    }
				    for(var j = 0; j < divList.length; j++) {
				        var item = divList[j];
						var id = item.StandardBriefName;
						
						if(id == undefined) {
							continue;
						}
						
						var itemAmt = ckNaN(item.Amount);
						
				        if(SBJson[id] == undefined) {
				            SBJson[id] = itemAmt;
				            SBJson[id+"Cnt"] = 1;
				        } else {
				            SBJson[id] = Number(SBJson[id]) + Number(itemAmt);
				            SBJson[id+"Cnt"] = Number(SBJson[id+"Cnt"]) + 1;
				        }
				    }
				}
	
				var formStr = "<dl class='total_acooungting_dl'>&nbsp;<dt>@@{msg} : </dt> <dd>@@{amt}"+Common.getDic("ACC_krw")+"</dd> <dd>(@@{cnt})</dd></dl>";
				var tempStr = "";
				
				var htmStr = "";
				var flag = 0;
				for(var EvidObj in EvidJson) {
				    if(EvidJson.hasOwnProperty(EvidObj)) {
				    	if(flag % 2 == 0) {
							tempStr = formStr;
							tempStr = tempStr.replace("@@{msg}", me.getProofNameByCode(EvidObj));
							tempStr = tempStr.replace("@@{amt}", toAmtFormat(EvidJson[EvidObj].toString()));
							tempStr = tempStr.replace("@@{cnt}", EvidJson[EvidObj+"Cnt"].toString());
							htmStr = htmStr+tempStr;
				    	}
				    	flag++;
				    }
				}
	
				var htmStrSB = "";
				var flagSB = 0;
				for(var SBObj in SBJson) {
				    if(SBJson.hasOwnProperty(SBObj)) {
				    	if(flagSB % 2 == 0) {
							tempStr = formStr;
							tempStr = tempStr.replace("@@{msg}", SBObj);
							tempStr = tempStr.replace("@@{amt}", toAmtFormat(SBJson[SBObj].toString()));
							tempStr = tempStr.replace("@@{cnt}", SBJson[SBObj+"Cnt"].toString());
							htmStrSB = htmStrSB+tempStr;
				    	}
				    	flagSB++;
				    }
				}


				var inputFieldType = appType.charAt(0).toUpperCase() + appType.replace("_", "").slice(1);
				//expApp_ -> ExpApp
				
				if(appType.toLowerCase().indexOf("view") > -1) {
					$("#"+appType+"lblTotalAmt").html(toAmtFormat(totalAmt));
					$("#"+appType+"lblTotalCnt").html(" (" + totalCnt + ")");
					$("#"+appType+"lblBillReqAmt").html(toAmtFormat(totalReqAmt));
					$("#"+appType+"EvidAmtArea").html(htmStr);
					$("#"+appType+"SBAmtArea").html(htmStrSB);
					
					$("[name="+inputFieldType+"InputField][tag=TotalAmt]").val(totalAmt);
					$("[name="+inputFieldType+"InputField][tag=ReqAmt]").val(totalReqAmt);
				} else {
					accountCtrl.getInfo(appType+"lblTotalAmt").html(toAmtFormat(totalAmt));
					accountCtrl.getInfo(appType+"lblTotalCnt").html(" (" + totalCnt + ")");
					accountCtrl.getInfo(appType+"lblBillReqAmt").html(toAmtFormat(totalReqAmt));
					accountCtrl.getInfo(appType+"EvidAmtArea").html(htmStr);
					accountCtrl.getInfo(appType+"SBAmtArea").html(htmStrSB);
					
					accountCtrl.getInfoStr("[name="+inputFieldType+"InputField][tag=TotalAmt]").val(totalAmt);
					accountCtrl.getInfoStr("[name="+inputFieldType+"InputField][tag=ReqAmt]").val(totalReqAmt);	
				}
			},

			evidArr : [],
			pageCount : 1,
			tempTargetID : '',
			accCallEvidPreview: function(isPaging, targetID, pageExpenceAppEvidList) {		
				var me = this;
				
				if(targetID != undefined) { // 처음 증빙 미리보기 클릭 시
					me.tempTargetID = targetID;
				} else { // 페이징 혹은 hover 시
					targetID = me.tempTargetID;
				}
				
				var targetType = targetID.replace("comCostApp", "").replace("_", "");
				
				if($("#"+targetID+"evidPreview").css("display") != "none" && !isPaging && $(".e_TitleBtn").css("display") != "none") {
					$("#"+targetID+"evidPreview").hide();
					$("#"+targetID+"contView").removeClass();
					$("#"+targetID+"iframePreview").attr('src', '');

					if(CFN_GetQueryString("CFN_OpenLayerName") != "undefined") { //layer popup
					parent.$("div[id^=expenceApplication"+targetType+"Popup][layertype=iframe]").css("width", "1000px");
					} else { //window popup
						window.resizeTo(1070, window.outerHeight);
					}
				} else {
					if(me.evidArr.length == 0) {
						$(pageExpenceAppEvidList).each(function(i, evidList) {
							var proofCode = evidList.ProofCode;
							var expenceApplicationListID = evidList.ExpenceApplicationListID;
							
							if(proofCode == "CorpCard" || proofCode == "TaxBill" || proofCode == "Receipt") {
								var tempObj = {};
								tempObj.ProofCode = proofCode;
								tempObj.ExpenceApplicationListID = expenceApplicationListID;

								switch(proofCode) {
								case "CorpCard": 
									tempObj.ReceiptID = evidList.CardUID; break;
								case "TaxBill": 
									tempObj.ReceiptID = evidList.TaxUID; break;
								case "Receipt": 
									tempObj.FileID = evidList.FileID;
									tempObj.FileToken = evidList.FileToken;
									tempObj.FileExt = evidList.FileName.split('.')[evidList.FileName.split('.').length-1];
									break;
								}
								
								me.evidArr.push(tempObj);
							}
							
							// 기타 증빙은 첨부파일이 여러 개인 상황도 있어서 반복문을 한번 더 해줘야 함.
							/* if (proofCode == "EtcEvid") {
								$(pageExpenceAppEvidList.fileInfoList).each(function(i, obj) {
									me.evidArr.push({
										FileID: obj.FileID,
										FileToken: obj.FileToken,
										FileExt: obj.Extention
									});
								});	
							} */
							
							$(evidList.fileList).each(function(j, fileList) {
								var tempObj = {};
								tempObj.ProofCode = proofCode;
								tempObj.ExpenceApplicationListID = expenceApplicationListID;
								tempObj.FileID = fileList.FileID;
								tempObj.FileExt = fileList.Extention;
								tempObj.FileToken = fileList.FileToken;
								me.evidArr.push(tempObj);
							});
						});
						
						$("tr[name=evidItemAreaApv]").each(function(i, obj) {
							$(obj).find("a.btn_Bill").mouseenter(function() {
								me.accHoverEvidItemArea(i, targetID, pageExpenceAppEvidList);
						    });
						});
						
						$("tr[name=fileDocAreaApv]").each(function(i, obj) {
							$(obj).find("a.previewBtn").each(function(j, btn) {
								$(btn).mouseenter(function() {
									me.accHoverEvidFileArea(btn, targetID, pageExpenceAppEvidList);
							    });
							});
						});
					}
					
					if(me.evidArr.length == 0) {
						Common.Warning("미리보기할 증빙이 없습니다.");
						return;
					}
					
					$(".e_TitleText").text(Common.getDic("ACC_lbl_"+me.evidArr[me.pageCount-1].ProofCode+"UseInfo") + " - ");
					
					if(me.evidArr[me.pageCount-1].FileID != undefined) {
						me.accAttachFilePreview(me.evidArr[me.pageCount-1].FileID, me.evidArr[me.pageCount-1].FileToken, me.evidArr[me.pageCount-1].FileExt, targetID, targetType, false, true);
					} else if(me.evidArr[me.pageCount-1].ReceiptID != undefined) {
						me.accShowEvidPreview(me.evidArr[me.pageCount-1].ProofCode, me.evidArr[me.pageCount-1].ReceiptID, targetID, targetType, false, true);
					}
					
					$("#"+targetID+"previewTotalPage").text(me.evidArr.length);
					$("#"+targetID+"previewCurrentPage").text(me.pageCount);
				}
			},
			
			accAttachFilePreview: function(fileId, fileToken, extention, targetID, targetType, isEach, isFrame) {
				if(Common.getBaseConfig("usePreviewPopup") != "Y" || isFrame){
					if(isEach) {
						$(".e_TitleText").html("첨부 파일");
						$(".e_TitleBtn").hide();
					} else {
						$(".e_TitleText").append("첨부 파일");
						$(".e_TitleBtn").show();
					}
				}
				$("#"+targetID+"evidContent").hide();
				$("#"+targetID+"fileContent").show();
				
				extention = extention.toLowerCase();
				
				if (extention ==  "jpg" ||
						extention ==  "jpeg" ||
						extention ==  "png" ||
						extention ==  "tif" ||
						extention ==  "bmp" ||
						extention ==  "xls" ||
						extention ==  "xlsx" ||
						extention ==  "doc" ||
						extention ==  "docx" ||
						extention ==  "ppt" ||
						extention ==  "pptx" ||
						extention ==  "txt" ||
						extention ==  "pdf" ||
						extention ==  "hwp") {
					var url = Common.getBaseConfig("MobileDocConverterURL") + "?fileID=" + fileId + "&fileToken=" + encodeURIComponent(fileToken) ;
					if(Common.getBaseConfig("usePreviewPopup") == "Y" && !isFrame) {
						window.open(url, "", "width=850, height=" + (window.screen.height-100));
					}else{
						if ($("#"+targetID+"evidPreview").css('display') == 'none') {
							$("#"+targetID+"evidPreview").show();
							$("#"+targetID+"contView").attr("class", "e_formL");
							if(parent == window) { //window popup
								window.resizeTo(1600, window.outerHeight);
							} else { //layer popup
								parent.$("div[id^=expenceApplication"+targetType+"Popup][layertype=iframe]").css("width", "1606px");
							}
							$("#"+targetID+"iframePreview").attr('src', url);
							$("#"+targetID+"previewVal").val(fileId);
						} else {
							$("#"+targetID+"iframePreview").attr('src', url);
							$("#"+targetID+"previewVal").val(fileId);
						}
					}
				} else {
					alert("변환이 지원되지않는 형식입니다.");
					return false;
				}
			},
			
			accShowEvidPreview: function(proofCode, receiptID, targetID, targetType) {
				var me = this;
				
				$(".e_TitleText").append("상세 내역");
				$(".e_TitleBtn").show();
				$("#"+targetID+"fileContent").hide();
				$("#"+targetID+"evidContent").show();
				
				if ($("#"+targetID+"evidPreview").css('display') == 'none') {
					$("#"+targetID+"evidPreview").show();
					$("#"+targetID+"contView").attr('class', 'e_formL');
					if(parent == window) { //window popup
						window.resizeTo(1600, window.outerHeight);
					} else { //layer popup
						parent.$("div[id^=expenceApplication"+targetType+"Popup][layertype=iframe]").css("width", "1606px");
					}
				}
				
				var sHTML = "";
				if(proofCode == "CorpCard") {
					me.getCardReceiptInfo(receiptID);
				} else if(proofCode == "TaxBill") {
					me.getTaxInvoiceInfo(receiptID);
				}

				$("#"+targetID+"hidReceiptID").val(receiptID);
			},
			
			getCardReceiptInfo: function(pReceiptID, mode) {
				var me = this;
				
				var sHTML = "";
				$.ajax({
					url	:"/account/accountCommon/getCardReceiptPopupInfo.do?",
					type: "POST",
					async: false,
					data: {		
						"receiptID"			: pReceiptID
						, "approveNo"		: ""
						, "searchProperty"	: ""
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							var info = data.list[0];
							
							var cardNoStr		= Common.getDic("ACC_lbl_cardNumber")+'('+getCardNoValue(info.CardNo,'*')+')';
							var amountWonStr	= info.AmountWon + '('+info.InfoIndexName+')';
							var storeAddressStr	= info.StoreAddress1 + '\n' +info.StoreAddress2;
							
							sHTML += '<div class="eaccounting_bill">';
							sHTML += '	<p class="card_number"><span>' + cardNoStr + '</span></p>';
							sHTML += '	<div class="card_info01_wrap">';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>승인번호</dt>';
							sHTML += '			<dd>' + info.ApproveNo + '</dd>';
							sHTML += '		</dl>';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>거래일자</dt>';
							sHTML += '			<dd>' + info.UseDate + ' ' + info.UseDate + '</dd>';
							sHTML += '		</dl>';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>결제방법</dt>';
							sHTML += '			<dd>' + '</dd>';
							sHTML += '		</dl>';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>가맹점명</dt>';
							sHTML += '			<dd>' + info.StoreName + '</dd>';
							sHTML += '		</dl>';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>가맹점번호</dt>';
							sHTML += '			<dd>' + info.StoreNo + '</dd>';
							sHTML += '		</dl>';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>대표자명</dt>';
							sHTML += '			<dd>' + info.StoreRepresentative + '</dd>';
							sHTML += '		</dl>';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>사업자등록번호</dt>';
							sHTML += '			<dd>' + info.StoreRegNo + '</dd>';
							sHTML += '		</dl>';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>전화번호</dt>';
							sHTML += '			<dd>' + info.StoreTel + '</dd>';
							sHTML += '		</dl>';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>주소</dt>';
							sHTML += '			<dd>' + storeAddressStr + '</dd>';
							sHTML += '		</dl>';
							sHTML += '	</div>';
							sHTML += '	<div class="card_info02_wrap">';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>금액</dt>';
							sHTML += '			<dd>' + info.RepAmount + '</dd>';
							sHTML += '		</dl>';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>부가세</dt>';
							sHTML += '			<dd>' + info.TaxAmount + '</dd>';
							sHTML += '		</dl>';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>봉사료</dt>';
							sHTML += '			<dd>' + info.ServiceAmount + '</dd>';
							sHTML += '		</dl>';
							sHTML += '	</div>';
							sHTML += '	<div class="card_info02_wrap">';
							sHTML += '		<dl class="card_info">';
							sHTML += '			<dt>합계</dt>';
							sHTML += '			<dd>' + amountWonStr + '</dd>';
							sHTML += '		</dl>';
							sHTML += '	</div>';
							sHTML += '</div>';
							
							if(mode != "print") {
								$(".billW").html(sHTML);
								
								$(".invoice_wrap").hide();
								$(".billW").show();
							}
							
						}else{
							Common.Error(Common.getDic("ACC_msg_error"));	
						}
					},
					error:function (error){
						Common.Error(Common.getDic("ACC_msg_error"));
					}
				});
				
				if(mode == "print") {
					return sHTML;
				}
			},
			
			getTaxInvoiceInfo: function(pReceiptID, mode) {				
				var sHTML = "";
				$.ajax({
					url	:"/account/accountCommon/getTaxInvoicePopupInfo.do?",
					type: "POST",
					async: false,
					data: {		
						"taxInvoiceID" : pReceiptID		
					},
					success:function (data) {
						if(data.status == "SUCCESS"){
							var info = data.list[0];
							
							sHTML += '<dl class="invoice_no"><dt>승인번호 :</dt><dd>' + getStr(info.NTSConfirmNum) + '</dd></dl>';
							sHTML += '<table class="invoice_table mb9">';
							sHTML += '	<tbody>';
							sHTML += '		<tr>';
							sHTML += '			<td class="t_tit" colspan="7"><p class="invoice_title">전자(세금)계산서<span class="invoice_sub">(공급받는자 보관용)</span></p></td>';
							sHTML += '			<td colspan="3" class="noPad">';
							sHTML += '				<table class="invoice_table_in">';
							sHTML += '					<tbody>';
							sHTML += '						<tr>';
							sHTML += '							<td width="90" class="t_tit">책번호</td>';
							sHTML += '							<td>권</td>';
							sHTML += '							<td>호</td>';
							sHTML += '						</tr>';
							sHTML += '						<tr>';
							sHTML += '							<td class="t_tit">일련번호</td>';
							sHTML += '							<td colspan="2">' + getStr(info.SerialNum) + '</td>';
							sHTML += '						</tr>';
							sHTML += '					</tbody>';
							sHTML += '				</table>';
							sHTML += '			</td>';
							sHTML += '		</tr>';
							sHTML += '		<tr>';
							sHTML += '			<td class="t_tit" rowspan="8" width="40">공급자</td>';
							sHTML += '			<td class="t_tit" width="90">등록번호</td>';
							sHTML += '			<td colspan="3">' + getStr(info.InvoicerCorpNum) + '</td>';
							sHTML += '			<td class="t_tit" rowspan="8" width="40">공급받는자</td>';
							sHTML += '			<td class="t_tit" width="90">등록번호</td>';
							sHTML += '			<td colspan="3">' + getStr(info.InvoiceeCorpNum) + '</td>';
							sHTML += '		</tr>';
							sHTML += '		<tr>';
							sHTML += '			<td class="t_tit">상호</td>';
							sHTML += '			<td width="140">' + getStr(info.InvoicerCorpName) + '</td>';
							sHTML += '			<td class="t_tit" width="90">성명</td>';
							sHTML += '			<td>' + getStr(info.InvoicerCEOName) + '</td>';
							sHTML += '			<td class="t_tit">상호</td>';
							sHTML += '			<td width="140">' + getStr(info.InvoiceeCorpName) + '</td>';
							sHTML += '			<td class="t_tit" width="90">성명</td>';
							sHTML += '			<td>' + getStr(info.InvoiceeCEOName) + '</td>';
							sHTML += '		</tr>';
							sHTML += '		<tr>';
							sHTML += '			<td class="t_tit">사업장주소</td>';
							sHTML += '			<td colspan="3">' + getStr(info.InvoicerAddr) + '</td>';
							sHTML += '			<td class="t_tit">사업장주소</td>';
							sHTML += '			<td colspan="3">' + getStr(info.InvoiceeAddr) + '</td>';
							sHTML += '		</tr>';
							sHTML += '		<tr>';
							sHTML += '			<td class="t_tit">업태</td>';
							sHTML += '			<td>' + getStr(info.InvoicerBizType) + '</td>';
							sHTML += '			<td class="t_tit" colspan="2">총사업장번호</td>';
							sHTML += '			<td class="t_tit">업태</td>';
							sHTML += '			<td>' + getStr(info.InvoiceeBizType) + '</td>';
							sHTML += '			<td class="t_tit" colspan="2">총사업장번호</td>';
							sHTML += '		</tr>';
							sHTML += '		<tr>';
							sHTML += '			<td class="t_tit">종목</td>';
							sHTML += '			<td width="140">' + getStr(info.InvoicerBizClass) + '</td>';
							sHTML += '			<td colspan="2"' + getStr(info.InvoicerTaxRegID) + '></td>';
							sHTML += '			<td class="t_tit">종목</td>';
							sHTML += '			<td width="140">' + getStr(info.InvoiceeBizClass) + '</td>';
							sHTML += '			<td colspan="2">' + getStr(info.InvoiceeTaxRegID) + '</td>';
							sHTML += '		</tr>';
							sHTML += '		<tr>';
							sHTML += '			<td class="t_tit">부서명</td>';
							sHTML += '			<td>' + getStr(info.InvoicerDeptName) + '</td>';
							sHTML += '			<td class="t_tit">담당자</td>';
							sHTML += '			<td>' + getStr(info.InvoicerContactName) + '</td>';
							sHTML += '			<td class="t_tit">부서명</td>';
							sHTML += '			<td>' + getStr(info.InvoiceeDeptName1) + '</td>';
							sHTML += '			<td class="t_tit">담당자</td>';
							sHTML += '			<td>' + getStr(info.InvoiceeContactName1) + '</td>';
							sHTML += '		</tr>';
							sHTML += '		<tr>';
							sHTML += '			<td class="t_tit">연락처</td>';
							sHTML += '			<td>' + getStr(info.InvoicerTel) + '</td>';
							sHTML += '			<td class="t_tit">휴대폰</td>';
							sHTML += '			<td></td>';
							sHTML += '			<td class="t_tit">연락처</td>';
							sHTML += '			<td>' + getStr(info.InvoiceeTel1) + '</td>';
							sHTML += '			<td class="t_tit">휴대폰</td>';
							sHTML += '			<td></td>';
							sHTML += '		</tr>';
							sHTML += '		<tr>';
							sHTML += '			<td class="t_tit">E-Mail</td>';
							sHTML += '			<td colspan="3">' + getStr(info.InvoicerEmail) + '</td>';
							sHTML += '			<td class="t_tit">E-Mail</td>';
							sHTML += '			<td colspan="3">' + getStr(info.InvoiceeEmail1) + '</td>';
							sHTML += '		</tr>';
							sHTML += '	</tbody>';
							sHTML += '</table>';
							sHTML += '<table class="invoice_table mb9">';
							sHTML += '	<tbody>';
							sHTML += '		<tr>';
							sHTML += '			<td class="t_tit" width="300">작성일자</td>';
							sHTML += '			<td class="t_tit" width="300">공급가액</td>';
							sHTML += '			<td class="t_tit">세액</td>';
							sHTML += '		</tr>';
							sHTML += '		<tr>';
							sHTML += '			<td><span>'+ getStr(info.WriteDate1) + '</span><span>'+ getStr(info.WriteDate2) + '</span><span>'+ getStr(info.WriteDate3) + '</span></td>';
							sHTML += '			<td style="text-align: right;">' + getStr(info.SupplyCostTotal) + '</td>';
							sHTML += '			<td class="t_tit" style="text-align: right;">' + getStr(info.TaxTotal) + '</td>';
							sHTML += '		</tr>';
							sHTML += '	</tbody>';
							sHTML += '</table>';
							sHTML += '<table class="invoice_table mb9">';
							sHTML += '	<tbody>';
							sHTML += '		<tr>';
							sHTML += '			<td class="t_tit" width="130">비고</td>';
							sHTML += '			<td>' + getStr(info.Remark1) + '</td>';
							sHTML += '		</tr>';
							sHTML += '	</tbody>';
							sHTML += '</table>';
							sHTML += '<table class="invoice_table"><tbody id="invoice_table_info"></tbody></table>';
							sHTML += '<table class="invoice_table mb0"><tbody id="invoice_table_info_sum"></tbody></table>';
							
							$(".invoice_wrap").html(sHTML);
							
							var appendStr		= "";
							var appendStrHeader	= "";
							var appendStrBody	= "";
							var appendStrBottom	= "";
						
							appendStrHeader	+=	"<tr>"
											+		"<td class='t_tit' width='65'>"+Common.getDic("ACC_lbl_month")+"</td>"//월
											+		"<td class='t_tit' width='65'>"+Common.getDic("ACC_lbl_day")+"</td>"//일
											+		"<td class='t_tit'>"+Common.getDic("ACC_lbl_item")+"</td>"//품목명
											+		"<td class='t_tit' width='78'>"+Common.getDic("ACC_lbl_standardName")+"</td>"//규격
											+		"<td class='t_tit' width='78'>"+Common.getDic("ACC_lbl_quantity")+"</td>"//수량
											+		"<td class='t_tit' width='78'>"+Common.getDic("ACC_lbl_unitPrice")+"</td>"//단가
											+		"<td class='t_tit' width='100'>"+Common.getDic("ACC_lbl_supplyCost")+"</td>"//공급액
											+		"<td class='t_tit' width='100'>"+Common.getDic("ACC_lbl_taxValue")+"</td>"//세액
											+		"<td class='t_tit' width='100'>"+Common.getDic("ACC_lbl_description")+"</td>"//비고
											+	"</tr>";
							
							if(getNum(info.TaxInvoiceItemCnt) > 0){
								var list = data.list;
								for(var i=0; i<list.length; i++){
									appendStrBody	+=	"<tr>"
													+		"<td>"
													+			"<span id='PurchaseMM_"+i+"'>"	+ getStr(list[i].PurchaseMM)	+ "</span>"
													+		"</td>"
													+		"<td>"
													+			"<span id='PurchaseDD_"+i+"'>"	+ getStr(list[i].PurchaseDD)	+ "</span>"
													+		"</td>"
													+		"<td>"
													+			"<span id='ItemName_"+i+"'>"	+ getStr(list[i].ItemName)		+ "</span>"
													+		"</td>"
													+		"<td>"
													+			"<span id='Spec_"+i+"'>"		+ getStr(list[i].Spec)			+ "</span>"
													+		"</td>"
													+		"<td style='text-align: right;'>"
													+			"<span id='Qty_"+i+"'>"			+ getStr(list[i].Qty)			+ "</span>"
													+		"</td>"
													+		"<td style='text-align: right;'>"
													+			"<span id='UnitCost_"+i+"'>"	+ getStr(list[i].UnitCost)		+ "</span>"
													+		"</td>"
													+		"<td style='text-align: right;'>"
													+			"<span id='SupplyCost_"+i+"'>"	+ getStr(list[i].SupplyCost)	+ "</span>"
													+		"</td>"
													+		"<td style='text-align: right;'>"
													+			"<span id='Tax_"+i+"'>"			+ getStr(list[i].Tax)			+ "</span>"
													+		"</td>"
													+		"<td>"
													+			"<span id='Remark_"+i+"'>"		+ getStr(list[i].Remark)		+ "</span>"
													+		"</td>"
													+	"</tr>";
								}
							}

							var payMsg = Common.getDic("ACC_lbl_payBill"); //이 금액을 청구 함
							if(info.PurposeType=="01"){
								payMsg = Common.getDic("ACC_lbl_payBill2"); //이 금액을 영수 함
							}
							appendStrBottom	+=	"<tr>"
											+		"<td class='t_tit' width='130'>"+Common.getDic("ACC_lbl_totalAmount")+"</td>"//합계금액
											+		"<td class='t_tit' width='122'>"+Common.getDic("ACC_lbl_cash")+"</td>"//현금
											+		"<td class='t_tit'>"+Common.getDic("ACC_lbl_check")+"</td>" //수표
											+		"<td class='t_tit' width='117'>"+Common.getDic("ACC_lbl_etc_1")+"</td>"//어름
											+		"<td class='t_tit' width='117'>"+Common.getDic("ACC_lbl_payAble")+"</td>"//외상미수금
											+		"<td rowspan='2' width='300'>"
											+			"<p class='invoice_text'>"
											+				payMsg
											+			"</p>"
											+		"</td>"
											+	"</tr>"
											+	"<tr>"
											+		"<td style='text-align: right;'>"
											+			"<span id='totalAmount'>"	+ getStr(info.TotalAmount)	+ "</span>"
											+		"</td>"
											+		"<td style='text-align: right;'>"
											+			"<span id='cash'>"			+ getStr(info.Cash) 		+ "</span>"
											+		"</td>"
											+		"<td style='text-align: right;'>"
											+			"<span id='chkBill'>"		+ getStr(info.ChkBill)		+ "</span>"
											+		"</td>"
											+		"<td style='text-align: right;'>"
											+			"<span id='note'>"			+ getStr(info.Note)			+ "</span>"
											+		"</td>"
											+		"<td style='text-align: right;'>"
											+			"<span id='credit'>"		+ getStr(info.Credit)		+ "</span>"
											+		"</td>"
											+	"</tr>";
						
							if(getNum(info.TaxInvoiceItemCnt) > 0){
								appendStr	= appendStrHeader
											+ appendStrBody;
								$("#invoice_table_info").append(appendStr);
								
								appendStr	= appendStrBottom;
								$("#invoice_table_info_sum").append(appendStr);
							}

							if(mode != "print") {
								$(".billW").hide();
								$(".invoice_wrap").show();
							}
							
						}else{
							Common.Error(Common.getDic("ACC_msg_error"));	
						}
					},
					error:function (error){
						Common.Error(Common.getDic("ACC_msg_error"));
					}
				});
				
				if(mode == 'print') {
					return "<div class='invoice_wrap' style='width:910px;'>" + $(".invoice_wrap").html() + "</div>";
				}
			},
			
			getReceiptInfo: function(pFilePath) {
				var me = this;
				
				var sHTML = "";
				sHTML += '<div>';
				sHTML += '	<img src="' + coviCmn.loadImage(pFilePath) + '" name="fileArea" alt="" style="width:300px;height:400px">';
				sHTML += '</div>';
				
				return sHTML;
			},
			
			accClickPaging: function(obj) {
				var me = this;

				if($(obj).attr("class") == "pre") {
					if(me.pageCount > 1) {
						me.pageCount--;
					} else {
						Common.Warning("첫번째 증빙입니다.");
					}
				} else {
					if(me.pageCount < me.evidArr.length) {
						me.pageCount++;
					} else {
						Common.Warning("마지막 증빙입니다.");
					}
				}
				
				me.accCallEvidPreview(true);
			},
			
			accHoverEvidItemArea: function(index, targetID, pageExpenceAppEvidList) {
				var me = this;
				
				if($("#"+targetID+"evidPreview").css('display') != 'none') {
					var expenceApplicationListID = pageExpenceAppEvidList[index].ExpenceApplicationListID;
					for(var i = 0; i < me.evidArr.length; i++) {
						if(me.evidArr[i].ExpenceApplicationListID == expenceApplicationListID) { 
							me.pageCount = i+1;
							break;
						}
					}
					
					me.accCallEvidPreview(true);	
				}
			},
			
			accHoverEvidFileArea: function(obj, targetID, pageExpenceAppEvidList) {
				var me = this;
				
				if($("#"+targetID+"evidPreview").css('display') != 'none') {
					var fileID = $(obj).attr("fileid");
					for(var i = 0; i < me.evidArr.length; i++) {
						if(me.evidArr[i].FileID == fileID) { 
							me.pageCount = i+1;
							break;
						}
					}
					
					me.accCallEvidPreview(true);	
				}
			},
			
			//카카오택시 이력 조회
			getkakaoTaxiList : function (startDate, endDate, requestType) {
				var me = this;
				
				$.ajax({
					type:"POST",
					url:"/account/accountCommon/getKakaoBizUseList.do",
					data:{
						"StartDate" : startDate,
						"EndDate" : endDate,
						"Vertical" : "TAXI"
					},
					async:false,
					success:function (data) {
						if(data.status == "SUCCESS" && data.list != null && data.list.length > 0){
							me[requestType].kakaoTaxiInfo = data.list[0];
						}
						else{
						}
					},
					error:function (error){
					}
				});
			},
			// coviEditor 사용여부
			getNoteIsUse: function(companyCode, formCode, id) {
				var noteIsUse = new String();
				
				var domainID = this.getDomainID(companyCode);
				var eAccNoteIsUse = Common.getBaseConfig("eAccNoteIsUse", domainID);
				
				if(eAccNoteIsUse == "Y") {
					$.ajax({
						type: "POST",
						url: "/account/accountCommon/getNoteIsUse.do",
						data: {
							"companyCode": companyCode,
							"formCode": formCode
						},
						async: false,
						success: function (data) {
							noteIsUse = data.NoteIsUse;

							if(data.NoteIsUse == "Y") {
								$("#" + id).show();
							} else {
								$("#" + id).hide();
							}
						}
					});
				} else {
					$("#" + id).hide();
				}
				
				return nullToBlank(noteIsUse);
			},
			getDomainID: function(domainCode) {
				var domainID = new String();
				// 변경 후
				$.ajax({
					type: "POST",
					url: "/covicore/control/GetBaseObjectInfo.do",
					data: {
						mode: "DN",
						objId: domainCode == "ALL" ? "ORGROOT" : domainCode
					},
					async: false,
					success: function (data) {
						domainID = data.result.list[0].DomainID;
					}
				});
				// 변경 전
				/*$.ajax({
					type: "POST",
					url: "/covicore/domain/getList.do",
					data: {
						pageSize: "999"
					},
					async: false,
					success: function (data) {
						for(var i = 0; i < data.list.length; i++) {
							if(domainCode == data.list[i].DomainCode) {
								domainID = data.list[i].DomainID;
								break;
							}
						}
					}
				});*/
				
				return nullToBlank(domainID);
			},
			// 환종,환율 사용여부
			getExchangeIsUse: function(companyCode, formCode) {
				var exchangeIsUse = new String();
				
				$.ajax({
					type: "POST",
					url: "/account/accountCommon/getExchangeIsUse.do",
					data: {
						"companyCode": companyCode,
						"formCode": formCode
					},
					async: false,
					success: function (data) {
						exchangeIsUse = data.ExchangeIsUse;
					}
				});
				
				return nullToBlank(exchangeIsUse);
			},
			// 환율 정보 가져오기
			getExchangeRate: function(proofDate, currency) {
				var exchangeRateJson;
				
				if (proofDate != undefined && proofDate != "") {
					$.ajax({
						url: "/account/exchangeRate/exchangesRead.do",
						method: "POST",
						async: false,
						headers: {
							"Content-Type": "application/json"
						},
						dataType: "json",
						data: JSON.stringify({
							"exchangeRateDate": proofDate.replace(/[^0-9]/g, "")
						}),
						success: function (data) {
							if(data.status == "SUCCESS"){
								exchangeRateJson = data.dto[currency];
							} else {
								Common.Error(Common.getDic("ACC_msg_error")); //오류가 발생했습니다. 관리자에게 문의바랍니다.
							}
						},
						error: function (error){
							Common.Error(Common.getDic("ACC_msg_error"));
						}
					});
				}
				
				return nullToBlank(exchangeRateJson);
			}
	}
	window.accComm = accComm;
})(window);

//account에서만 호출되도록 변경
if (document.location.href.indexOf("/account/") > -1 ){
	accComm.setDeadlineInfo();
}

function getBudgetCtrlInfo(accountCode, standardBriefID, fiscalYear, executeDate, companyCode) {
	var returnObj = new Object();
	
	$.ajax({
		type:"POST",
		url:"/account/budgetUse/getBudgetCtrlInfo.do",
		async: false,
		cache: false,
		data:{
			accountCode : accountCode,
			standardBriefID : standardBriefID,
			fiscalYear : fiscalYear,
			executeDate	: executeDate,
			companyCode : companyCode
		},
		success:function (result) {
			if(result.status == "SUCCESS") {
				returnObj.bgType = result.data.CostCenterType;
				returnObj.periodLabel = result.data.PeriodLabel;
				returnObj.periodLabelName = result.data.PeriodLabelName;
			} else {
				returnObj.message = result.message;
			}
		}
	});
	
	return returnObj;
}

function budgetControl(requestType, pageExpenceAppEvidList) {
	//if(requestType != "SELFDEVELOP") return ""; // TODO: 추후 모든 신청 유형에 대한 예산 관련 통제 정책 수립 시 (하드코딩) 제거 필요
	var returnStr 	= "";
	var userID 		= Common.getSession("USERID");
	var userName 	= Common.getSession("USERNAME");
	var companyCode = accComm.getCompanyCodeOfUser(userID);
	
	var chkList = [];
	pageExpenceAppEvidList.map(evid => {
		var divList 	= evid.divList;
		var executeDate = new Date(evid.ProofDateStr);
		var fiscalYear 	= "";
		
		executeDate.setDate(executeDate.getDate() + Number(Common.getBaseConfig("BudgetControlDate")));	//10일전 데이타로 예산조회 
		executeDate = executeDate.format("yyyyMMdd");
		fiscalYear 	= accComm.getFiscalYearByDate(executeDate);
		
		divList.map(divItem => {
			var budgetInfo = getBudgetCtrlInfo(divItem.AccountCode, divItem.StandardBriefID, fiscalYear, executeDate, companyCode);
			/*
			if(budgetInfo.message && requestType == "SELFDEVELOP") {
				//[복리후생비/자기개발] 편성된 예산이 존재하지 않습니다.
				returnStr += "["+divItem.AccountName+"/"+divItem.StandardBriefName+"] "+Common.getDic("ACC_msg_budgetControlExists");
			}
			*/
			
			//사용자 예산은 UserCode, 부서 예산은 CostCenterCode 사용
			var budgetCode = budgetInfo.bgType == "USER" ? userID : divItem.CostCenterCode;
			var budgetName = budgetInfo.bgType == "USER" ? userName : divItem.CostCenterName;
			
			var isNew = true;
			chkList
				.filter(chkItem => chkItem.periodLabel == budgetInfo.periodLabel && chkItem.budgetCode == budgetCode && chkItem.accountCode == divItem.AccountCode && chkItem.standardBriefID == divItem.StandardBriefID)
				.map(chkItem => {
					isNew = false;
					chkItem.amount = Number(chkItem.amount) + divItem.Amount;
				});
	   		
			if(isNew) {
				chkList.push({
					"executeDate"		:executeDate,
					"fiscalYear"		:fiscalYear,
					"periodLabel"		:budgetInfo.periodLabel,
					"periodLabelName"	:budgetInfo.periodLabelName,
					"costCenterCode"	:divItem.CostCenterCode,
					"costCenterName"	:divItem.CostCenterName,
					"accountCode"		:divItem.AccountCode,
					"accountName"		:divItem.AccountName,
					"standardBriefID"	:divItem.StandardBriefID,
					"standardBriefName"	:divItem.StandardBriefName,
					"budgetCode"		:budgetCode,
					"budgetName"		:budgetName,
					"amount"			:divItem.Amount
				});
			}
		});
	});
	
	if(chkList.length > 0) {
		$.ajax({
			type:"POST",
			url:"/account/budgetUse/getBudgetAmount.do",
			async: false,
			cache: false,
			data:{
				companyCode : companyCode,
				chkList 	: JSON.stringify(chkList)
			},
			success:function (result) {
				//코스트센터+표준적요의 예산편성 존재
				if(result.status == "SUCCESS") {
					result.list.forEach((data, idx) => {
						var chkItem = chkList[idx];
						
						if(data && Object.keys(data).length > 0) {
							//예산통제
							if(data.IsUse == 'Y' && data.IsControl == 'Y') {
								var overAmount =  Number(data.BudgetAmount) - Number(data.PendingAmount) - Number(data.CompletAmount) - chkItem.amount;
								
								if(overAmount < 0) {
									//[곽믿음][복리후생비/기타 행사] 3분기 예산을 155,000원 초과하였습니다.
									returnStr += (returnStr.length!=0 ? "\n":"") + "["+chkItem.budgetName+"]["+chkItem.accountName+"/"+chkItem.standardBriefName+"]["+chkItem.periodLabelName+"] "+(Common.getDic("ACC_msg_budgetControlOver")).replace("{0}",toAmtFormat(overAmount*-1));
								}
							}
						} else {
							if(requestType == "SELFDEVELOP") {
								//[복리후생비/자기개발] 편성된 예산이 존재하지 않습니다.
								returnStr += (returnStr.length!=0 ? "\n":"") + "["+chkItem.accountName+"/"+chkItem.standardBriefName+"] "+Common.getDic("ACC_msg_budgetControlExists");
							}
						}
					});
				} else {
					returnStr = Common.getDic("ACC_msg_error");
				}
			},
			error:function (error){
				returnStr = Common.getDic("ACC_msg_error");
			}
		});
	}
	
	return returnStr;
}

function setAccountDocreadCount() {
	callDocReadCntAll("USER", "U_Approval;U_Process;U_TCInfo"); // 카운트 조회시 서버요청 1번만 하도록 변경
	
	setHeaderTitle('headerTitle');
}

// boxList
function callDocReadCntAll(listType, boxList){
	$.ajax({
		url: "/approval/user/getApprovalCntAll.do",
		type:"post",
		data:{
			businessData1 : "ACCOUNT",
			listType : listType,
			boxList : boxList
		},
		async: false,
		success:function (data) {
			if(data.status == "SUCCESS" && data.list && data.list.length > 0) {
				for(var boxInfo of data.list){
					var boxAlias = boxInfo.type;
					var boxCnt = boxInfo.cnt;
					if(boxAlias && boxInfo.cnt != undefined){
						var mode = boxAlias.substring(2);
						$("li.eaccountingMenu02").find("a[id$=" + mode + "]").find("span.fCol19abd8").remove();
						$("li.eaccountingMenu02").find("a[id$=" + mode + "]").append("<span class='fCol19abd8'>&nbsp;"+boxCnt+"</span>");
					}	
				}
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/getApprovalCntAll.do", response, status, error);
		}
	});
}

function callDocReadCnt(mode) {
	var url = "/approval/user/get" + mode + "Cnt.do";
	if(mode == "TCInfo") {
		url = "/approval/user/get" + mode + "NotDocReadCnt.do";
	}
	
	$.ajax({
		url:url,
		type:"post",
		data:{
			businessData1 : "ACCOUNT"
		},
		async: false,
		success:function (data) {
			//메소드 호출마다 갱신되도록 수정
			$("li.eaccountingMenu02").find("a[id$=" + mode + "]").find("span.fCol19abd8").remove();
			$("li.eaccountingMenu02").find("a[id$=" + mode + "]").append("<span class='fCol19abd8'>&nbsp;"+data.cnt+"</span>");
		},
		error:function(response, status, error){
			CFN_ErrorAjax(url, response, status, error);
		}
	});
}



// 결재 관련	
var commentPopupTitle = '';
var commentPopupButtonID = '';
var commentPopupReturnValue = false;
var aryComment = new Array();

var sessionObj = Common.getSession();

var m_oFormMenu = window;
try { if (m_oFormMenu == null) m_oFormMenu = parent.window; } catch (e) { coviCmn.traceLog(e); }
var m_print = false; //출력상태여부 - 출력형태로 할때 사용 

var g_commentAttachList = [];
var g_dicFormInfo = null;
var g_BaseImgURL = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")) + "e-sign/ApprovalSign/BackStamp/"; // 2022/05 이전 서명표시를 위해서만 사용

var tableLineMax = Common.getBaseConfig("ApprovalLineMax_Table"); //테이블형 결재선 표시 최대 수

var g_DisplayJobType = Common.getBaseConfig("ApprovalLine_DisplayJobType") || "title"; // 직책, 직급, 직위 중 결재선에 표시될 타입 설정 (직책 : title, 직급 : level, 직위 : position)

function setWorkedAutoDomainData(formPrefix, mode, expAppID, processID) {
	
	if(mode == undefined) mode = "DRAFT";
	if(mode == "DRAFT" && expAppID) mode = "TEMPSAVE";
	
	if(document.getElementById("APVLIST") == undefined) {
		$(".accountContent").append(
			'<input type="hidden" id="APVLIST" /> '
			+ '<input type="hidden" id="ACTIONCOMMENT" /> '
			+ '<input type="hidden" id="ACTIONCOMMENT_ATTACH" value="[]"/> '
		);
	}

	if(mode == "DRAFT" || mode == "TEMPSAVE") {
		document.getElementById("APVLIST").value = '{"steps":{"status":"'+sessionObj.USERID+'","initiatoroucode":"'+sessionObj.DEPTID+'","initiatorcode":"inactive"}}';
	}
	
	var url = "";
	var data = {};
	if(mode == "COMPLETE") {
		url = "/approval/getDomainListData.do";
		data = {
			"ProcessID": processID
		};
	} else {
		url = "/approval/getWorkedAutoDomainData.do";
		data = {
			"strFormPrefix" : formPrefix,
			"strExpAppID" : expAppID
		};
	}
	
	$.ajax({
		type:"POST",
		url:url,
		data:data,
		async:false,
		success:function (data) {
			if(data.result == "ok"){
				var domainData = null;
				if(mode == "COMPLETE") {
					domainData = JSON.stringify(data.list[0].DomainDataContext);
				} else {
					domainData = JSON.stringify(data.autoDomainData); // 최종결재선
					setInfo("AutoApprovalLine", data.autoApprovalLine); // 자동결재선(양식셋팅)
					domainData = receiveApvHTTP(domainData, mode); //자동결재선 세팅
				}
								
				accountCtrl.getInfo("APVLIST_").val(domainData);
				document.getElementById("APVLIST").value = domainData;
				
				if(Common.getBaseConfig("AccountApvLineType") == "Graphic") {
					$("#graphicDiv").removeClass("apv-stat-init apv-stat-open");
					
					var objGraphicList = ApvGraphicView.getGraphicData(domainData);
					ApvGraphicView.initRender(accountCtrl.getInfo("graphicDiv"), objGraphicList, "account");
				} else {
					initApvList();	
				}
			}
			else{
				Common.Error(data);
			}
		},
		error:function (error){
			Common.Error(Common.getDic("ACC_msg_error")); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
		}
	});
}

function receiveApvHTTP(responseJSONdata, mode) {
	
	if ($$(responseJSONdata) != null) {
        var errorNode = $$(responseJSONdata).find("error");
        if ($(errorNode).length > 0) {
            alert("Desc: " + errorNode.val());
        } else {
            var elmList = $$(responseJSONdata).find("steps");
			var oApvList = $.parseJSON(document.getElementById("APVLIST").value);
			if (oApvList == null) {
				alert(gMessage75); //"결재선 지정 오류"
			} else {
				if(!sessionObj["ApprovalParentGR_Name"]) sessionObj["ApprovalParentGR_Name"] = sessionObj["GR_MultiName"];
				
				var oGetApvList = {};
				if ($$(responseJSONdata).find("steps").exist()) {
					//결재선 내 & 문자열로 인해 오류 발생으로 수정함
					oGetApvList = $.parseJSON(responseJSONdata.replace(/&/gi, '&amp;'));
				}
				var oCurrentOUNode;
				if (mode == "REDRAFT") {
					//담당부서 - 담당부서 및 담당업무 결재선 삭제할것 그 후로 기안자 결재선 입력할것
					oCurrentOUNode = $$(oApvList).find("steps > division").children().find("[divisiontype='receive']").has(">taskinfo[status='pending']");
					if (oCurrentOUNode == null) {
						var oDiv = {};
						$$(oDiv).attr("taskinfo", {});
						$$(oDiv).attr("step", {});
						$$(oDiv).attr("divisiontype", "receive");
						$$(oDiv).attr("name", Common.getDic("lbl_apv_ChargeDept"));
						$$(oDiv).attr("oucode", sessionObj.ApprovalParentGR_Code);
						$$(oDiv).attr("ouname", sessionObj.ApprovalParentGR_Name);
						
						$$(oDiv).find("taskinfo").attr("status", "pending");
						$$(oDiv).find("taskinfo").attr("result", "pending");
						$$(oDiv).find("taskinfo").attr("kind", "receive");
						$$(oDiv).find("taskinfo").attr("datereceived", new Date().format("yyyy-MM-dd hh:mm:ss"));
						
						$$(oApvList).find("division").push(oDiv);
						
						oCurrentOUNode = $$(oApvList).find("steps > division:has(>taskinfo[status='pending'])[divisiontype='receive']");
					}
					var oRecOUNode = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']");
                    var tempOu = null;
                    if (oRecOUNode.length != 0 && $$(oRecOUNode).find("ou").hasChild("person").length == 0) {
                    	tempOu = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']");
                    	$$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']").remove();
                    }
					var oChargeNode = $$(oCurrentOUNode).find("step").has("ou>person>taskinfo[status='pending']");

					//담당 수신자 대결
					var isChkDeputy = false;

					if (oChargeNode.length != 0) {
						//담당 수신자 대결 S ----------------------------------------
						var objDeputyOU = $$(oApvList).find("steps>division[divisiontype='receive']>step>ou");
                        var chkObjPersonNode = $$(objDeputyOU).find("person[code='" + gReqUserCode + "'][code!='" + sessionObj.USERID + "']").find(">taskinfo[status='pending']");
                        var chkObjRoleNode = $$(objDeputyOU).find("role:has(person[code='" + gReqUserCode + "'][code!='" + sessionObj.USERID + "'])");

                        if (0 < (chkObjPersonNode.length + chkObjRoleNode.length)) {
                            isChkDeputy = true;
                        }
						//담당 수신자 대결 E -----------------------------------------
						
						var oRecApprovalNode = $$(oCurrentOUNode).find("step>ou>person>taskinfo[status='inactive']");
						if (oRecApprovalNode.length != 0) {
							for(var i=0; i<oRecApprovalNode.length; i++){
								var RecApprovalNode = oRecApprovalNode.concat().eq(i);
								oCurrentOUNode.concat().eq(0).remove(RecApprovalNode.parent().parent().parent());
							}
						}

						//person의 takinfo가 inactive가 있는 경우 routetype을 변경함
						var nodesInactives = $$(oCurrentOUNode).find("step[routetype='receive']").has("ou > person > taskinfo[status='inactive']");

						$$(nodesInactives).each(function (i, nodesInactive) {
							$$(nodesInactive).attr("unittype", "person");
							$$(nodesInactive).attr("routetype", "approve");
							$$(nodesInactive).attr("name", Common.getDic("lbl_apv_ChargeDept"));	
						});

					}

					
					var oJFNode = $$(oCurrentOUNode).find("step").has("ou>role>taskinfo[status='pending'], ou>role>taskinfo[status='reserved']"); 
					var bHold = false; //201108 보류여부
					var oComment = null;
					if (oJFNode.length != 0) {
						var oHoldTaskinfo = $$(oJFNode).find("ou>role>taskinfo[status='reserved']");
						if (oHoldTaskinfo.length != 0) {
							bHold = true;
							oComment = $$(oHoldTaskinfo).find("comment").json();
                            
                            // 보류한 사용자와 로그인한 사용자가 다른 경우
                            if($$(oComment).attr("reservecode") != undefined && $$(oComment).attr("reservecode") != sessionObj.USERID) {
                            	Common.Warning(Common.getDic("msg_apv_holdOther")); // 해당 양식은 다른 사용자가 보류한 문서입니다.
                            	bHold = false;
                        	}
						}
                        tempOu = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='reserved']");
						$$(oCurrentOUNode).eq(0).remove("step");
					}

					$$(oCurrentOUNode).attr("oucode", sessionObj.ApprovalParentGR_Code);
					$$(oCurrentOUNode).attr("ouname", sessionObj.ApprovalParentGR_Name);
					
					$$(oCurrentOUNode).find("taskinfo").attr("status", "pending");
					$$(oCurrentOUNode).find("taskinfo").attr("result", "pending");
					
					var oStep = {};
					var oOU = {};
					var oPerson = {};
					var oTaskinfo = {};

					$$(oStep).attr("unittype", "person");
					$$(oStep).attr("routetype", "approve");
					$$(oStep).attr("name", Common.getDic("lbl_apv_ChargeDept"));
					
					$$(oOU).attr("code", sessionObj.ApprovalParentGR_Code);
					$$(oOU).attr("name", sessionObj.ApprovalParentGR_Name);
					
                    $$(oOU).attr("taskid", (tempOu ? tempOu.find("ou").attr("taskid") : $$(oCurrentOUNode).find("step>ou").attr("taskid")));
					$$(oOU).attr("widescid", (tempOu ? tempOu.find("ou").attr("widescid") : $$(oCurrentOUNode).find("step>ou").attr("widescid")));
					$$(oOU).attr("wiid", (tempOu ? tempOu.find("ou").attr("wiid") : $$(oCurrentOUNode).find("step>ou").attr("wiid")));
					
					$$(oPerson).attr("code", sessionObj.USERID);
					$$(oPerson).attr("name", sessionObj.UR_MultiName);
					$$(oPerson).attr("position", sessionObj.UR_JobPositionCode + ";" + sessionObj.UR_MultiJobPositionName);
					$$(oPerson).attr("title", sessionObj.UR_JobTitleCode + ";" + sessionObj.UR_MultiJobTitleName);
					$$(oPerson).attr("level", sessionObj.UR_JobLevelCode + ";" + sessionObj.UR_MultiJobLevelName);
					$$(oPerson).attr("oucode", sessionObj.DEPTID);
					$$(oPerson).attr("ouname", sessionObj.GR_MultiName);
					$$(oPerson).attr("sipaddress", sessionObj.UR_Mail);
					
					$$(oTaskinfo).attr("status", (bHold == true ? "reserved" : "pending")); 
					$$(oTaskinfo).attr("result", (bHold == true ? "reserved" : "pending")); 
					$$(oTaskinfo).attr("kind", "charge");
					$$(oTaskinfo).attr("datereceived", new Date().format("yyyy-MM-dd hh:mm:ss"));
					if (bHold) $$(oTaskinfo).attr("comment", oComment); 
					
					$$(oPerson).append("taskinfo", oTaskinfo);
					
					$$(oOU).append("person", oPerson);
					
					$$(oStep).append("ou", oOU);
					
					// 조건 추가 - charge가 있는 경우에만 실행
					// receive division의 첫번째 step 교체
					if($$(oCurrentOUNode).find("step > ou > person > taskinfo[kind='charge']").length > 0) {                        
						$$(oCurrentOUNode).append("step", oStep);
						$$(oCurrentOUNode).find("step").concat().eq(0).remove();
					}
					else if($$(oCurrentOUNode).find("step").length == 0) {
						$$(oCurrentOUNode).append("step", oStep);
					}
					
					//담당 수신자 대결 S ---------------------------------------------
					if (isChkDeputy) {
                    	Common.Warning(Common.getDic("msg_ApprovalDeputyWarning"));

                        var objOriginalApprover = $$(oChargeNode).find('ou').find("person");
                        $$(objOriginalApprover).attr('title', $$(objOriginalApprover).attr('title'));
                        $$(objOriginalApprover).attr('level', $$(objOriginalApprover).attr('level'));
                        $$(objOriginalApprover).attr('position', $$(objOriginalApprover).attr('position'));

                        $$(objOriginalApprover).find('taskinfo').remove('datereceived');
                        $$(objOriginalApprover).find('taskinfo').attr('kind', 'bypass');
                        $$(objOriginalApprover).find('taskinfo').attr('result', 'inactive');
                        $$(objOriginalApprover).find('taskinfo').attr('status', 'inactive');

                        // [2015-05-28 modi] 현재 대결인 division에만 추가하도록
                        //objDeputyOU = $(oApvList).find("steps > division[divisiontype='receive'] > step > ou");
                        //objDeputyOU = $$(oApvList).find("steps>division").has("taskinfo[status='pending']").find("step>ou");
                        //$$(objDeputyOU).append("person", $$(objOriginalApprover).json());
                        
                        // [2020-10-23] person 추가에서 step 추가로 변경
                        $$(oChargeNode).attr("routetype", "approve");
                        $$(oChargeNode).attr("name", "원결재자");
                    	$$(oCurrentOUNode).append("step", $$(oChargeNode).json());
					}
					//담당 수신자 대결 E ----------------------------------------------

					//퇴직자 및 인사정보 최신 적용을 위해 추가 예외사항생기더라도 기안/재기안자 결재선 디스플레이
					document.getElementById("APVLIST").value = JSON.stringify($$(oApvList).json());
					
					var nodesAllItems;
					nodesAllItems = $$(oGetApvList).find("steps > division").children().find("[divisiontype='receive']").has(">taskinfo[status='pending']").has("step");

					if (nodesAllItems.length > 0) {
						var oSteps = $$(oGetApvList).find("steps");
						var oCheckSteps = chkAbsent(oSteps);

						if (oCheckSteps) {
							//담당 대결자 체크 필요 
							//1. 중복으로 들어가는 문제 검토 필요 (주석 처리)
							//2. chkAbsent(oSteps) 함수에서 퇴직자 정보 체크 한다 - 아래 appendChild 확인 필요
							//3. 담당수신자 지정 후 담당수신자를 대결 지정시 아래 로직을 거치면 중복으로 결재자가 들어간다

                        	var absentType = oCheckSteps.split("@@@")[0];
                        	var absentMsg = oCheckSteps.split("@@@")[1];
                        	var absentCode = oCheckSteps.split("@@@")[2].split(",");
                        	                            		
                    		alert(absentMsg);
                    		
                    		if(absentType == "change") {
                    			$$(oSteps).find("division").concat().has(">taskinfo[status='pending']").find("[divisiontype='receive'] > step[unittype='person']").has("ou>person>taskinfo[kind!='charge']").each(function (i, enodeItem) {
                    				var isChanged = false; //인사정보 변경 여부
                    				for(var j = 0; j < absentCode.length; j++) {
                    					if(absentCode[j] != "") {
                        					if(absentCode[j] == $$(enodeItem).find("ou>person").attr("code")) {
                        						isChanged = true;
                        					}
                    					}
                    				}

                    				if(!isChanged) { //인사정보 변경되지 않은 결재자만 추가
                    					$$(oApvList).find("division[divisiontype='receive']").append("step", enodeItem.json());
                    				}
                                });
                    		}
						} else {
                            $$(oSteps).find("division").concat().has(">taskinfo[status='pending']").find("[divisiontype='receive'] > step[unittype='person']").has("ou>person>taskinfo[kind!='charge']").each(function (i, enodeItem) {
                                $$(oApvList).find("division[divisiontype='receive']").append("step", enodeItem.json());
                            });
                        }
					}
					if (nodesAllItems.length > 0) {
						document.getElementById("btDeptDraft").style.display = "";
					}
				} else {
					//if (sessionObj.DEPTID != sessionObj.DEPTID) 
					//	$(oApvList).find("steps").attr("initiatoroucode", sessionObj.DEPTID);
					
					// ************************************* 자동결재선 옵션처리 ************************************* 
            		// 1. (기본) 최종결재선 불러온 후 자동결재선 적용 & 재사용인 경우 자동결재선 적용하지 않음
            		// 2. (옵션) 자동결재선 사용하는 경우 최종결재선 불러오지 않기 & 재사용인 경우에 결재선 초기화 후 자동결재선 적용
					// 임시저장 문서는 모두 자동결재선 적용하지 않음
            		var useAutoApvlineOption = Common.getBaseConfig("useAutoApvlineOption");
            		var bSetOption = false; // 자동결재선 셋팅여부
            		
            		// 자동결재선 옵션 처리를 적용 & 합의자, 협조자, 결재자, 사후참조자, 사전참조사 중 하나라도 설정되어 있는 경우
            		if(useAutoApvlineOption == "Y") {
            			if(getInfo("AutoApprovalLine.Agree.autoSet") == "Y" || getInfo("AutoApprovalLine.Assist.autoSet") == "Y" || getInfo("AutoApprovalLine.Approval.autoSet") == "Y" 
            				|| getInfo("AutoApprovalLine.CCAfter.autoSet") == "Y" || getInfo("AutoApprovalLine.CCBefore.autoSet") == "Y") {
            				// 자동결재선 옵션인경우(1), 재사용/임시저장이 아닌경우 최종결재선 삭제
							if((getInfo("Request.reuse") != "Y" && mode != "TEMPSAVE")) oGetApvList = {};
                			if(mode != "TEMPSAVE") bSetOption = true; // 임시저장이 아닌경우 자동결재선 적용	
            			}
            		}else if(getInfo("Request.reuse") != "Y" && mode != "TEMPSAVE"){ // 자동결재선 기본인경우(2), 재사용/임시저장이 아닌경우 자동결재선 적용(최종결재선에 추가)
						bSetOption = true;
					}
            		// ************************************* 자동결재선 옵션처리 ************************************* 

					var oSteps = {};
					var oDiv = {};
					var oDivTaskinfo = {};
					var oStep = {};
					var oOU = {};
					var oPerson = {};
					var oTaskinfo = {};
					
					$$(oDiv).attr("divisiontype", "send");
					$$(oDiv).attr("name", Common.getDic("lbl_apv_circulation_sent"));
					$$(oDiv).attr("oucode", sessionObj.ApprovalParentGR_Code);
					$$(oDiv).attr("ouname", sessionObj.ApprovalParentGR_Name);
					
					$$(oDivTaskinfo).attr("status", "inactive");
					$$(oDivTaskinfo).attr("result", "inactive");
					$$(oDivTaskinfo).attr("kind", "send");
					$$(oDivTaskinfo).attr("datereceived", new Date().format("yyyy-MM-dd hh:mm:ss"));
					
					$$(oDiv).attr("taskinfo", oDivTaskinfo);
					
					$$(oStep).attr("unittype", "person");
					$$(oStep).attr("routetype", "approve");
					$$(oStep).attr("name", Common.getDic("lbl_apv_writer"));
					
					$$(oOU).attr("code", getInfo("AppInfo.dpid_apv")); // sessionObj.ApprovalParentGR_Code
					$$(oOU).attr("name", getInfo("AppInfo.dpdn_apv")); // sessionObj.ApprovalParentGR_Name
					
					$$(oPerson).attr("code", getInfo("AppInfo.usid")); // sessionObj.USERID
					$$(oPerson).attr("name", getInfo("AppInfo.usnm_multi")); // sessionObj.UR_MultiName
					$$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi")); // sessionObj.UR_JobPositionCode , sessionObj.UR_MultiJobPositionName
					$$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi")); // sessionObj.UR_JobTitleCode , sessionObj.UR_MultiJobTitleName
					$$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi")); // sessionObj.UR_JobLevelCode , sessionObj.UR_MultiJobLevelName
					$$(oPerson).attr("oucode", getInfo("AppInfo.dpid")); // sessionObj.DEPTID
					$$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi")); // sessionObj.GR_MultiName
					$$(oPerson).attr("sipaddress", getInfo("AppInfo.ussip")); // sessionObj.UR_Mail
					
					$$(oTaskinfo).attr("status", "inactive");
					$$(oTaskinfo).attr("result", "inactive");
					$$(oTaskinfo).attr("kind", "charge");
					$$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone")); // new Date().format("yyyy-MM-dd hh:mm:ss")
					
					$$(oPerson).attr("taskinfo", oTaskinfo);
					
					$$(oOU).attr("person", oPerson);
					
					$$(oStep).attr("ou", oOU);
					
					$$(oDiv).attr("step", oStep);
					
					$$(oSteps).attr("division", oDiv);
					
					oApvList = {"steps" : oSteps};
					
					$("#APVLIST").val(JSON.stringify(oApvList));
					
					oCurrentOUNode = $$(oApvList).find("steps > division").has("taskinfo[status='inactive']").concat().eq(0);

					// 퇴직자 처리
					var nodesAllItems = $$(oGetApvList).find("steps>division[divisiontype='send']>step");
					if (nodesAllItems.exist() > 0) {
                        var oSteps = $$(oGetApvList).find("steps").concat().eq(0);
                        var oCheckSteps = chkAbsent(oSteps);
                        
                        if (oCheckSteps != "") {
                        	var absentType = oCheckSteps.split("@@@")[0];
                        	var absentMsg = oCheckSteps.split("@@@")[1];
                        	var absentCode = oCheckSteps.split("@@@")[2].split(",");
                        	                            		
                    		alert(absentMsg);
                    		
                    		if(absentType == "change") {
                        		$$(oSteps).find("division[divisiontype='send']>step").has("[unittype='person'],[unittype='role'],[unittype='ou']").each(function (i, enodeItem) {
                        			var isChanged = false; //인사정보 변경 여부
                    				for(var j = 0; j < absentCode.length; j++) {
                    					if(absentCode[j] != "") {
                        					if(absentCode[j] == $$(enodeItem).find("ou>person").attr("code")) {
                        						isChanged = true;
                        					}
                    					}
                    				}
                    				
                    				if(!isChanged) { //인사정보 변경되지 않은 결재자만 추가
                    					$$(oApvList).find("division[divisiontype='send']").append("step", enodeItem.json());
                    				}
                                });
                    		}
                        } else {
                            $$(oSteps).find("division[divisiontype='send']>step").has("[unittype='person'],[unittype='role'],[unittype='ou']").each(function (i, enodeItem) {
                                $$(oApvList).find("division[divisiontype='send']").append("step", enodeItem.json());
                            });
                        }
                    }
						
					// 퇴직자처리 - 참조                        
                    var elmRoot = $$(oGetApvList).find("steps");                  	
                	var chkAbsentCCInfo = chkAbsent(elmRoot, true, "ccinfo");
                	if (chkAbsentCCInfo != "") {
                		chkAbsentCCInfo = chkAbsentCCInfo.split("@@@");
                		absentType = chkAbsentCCInfo[0];
                		absentMsg = chkAbsentCCInfo[1];
                		absentCode = chkAbsentCCInfo[2].split(",");

                		alert(absentMsg);
                		
                		if(absentType == "absent") {
                	        $$(elmRoot).find("ccinfo").remove();
                		} else {
                			for(var i = 0; i < absentCode.length; i++) {
                				if(absentCode[i] != "") {
                					$$(oApvList).find("ccinfo>ou>person[code='"+absentCode[i]+"']").parent().parent().remove();
                   				}
                			}
                		}	
                	}
                	
					//부서장결재단계사용. 임시저장, 편집, 재사용시 진행하지 않음
					if(mode == "DRAFT" && getInfo("Request.reuse") != "Y"){
						var nodesAllItems3 = $$(oGetApvList).find("steps > step[unittype='role']");
						if (nodesAllItems3.length > 0) {
							var oSteps = $$(oGetApvList).find("steps").concat().eq(0);
							nodesAllItems3.each(function (i, enodeItem) {
								$$(oApvList).find("division[divisiontype='send']").append("step", enodeItem.json());
							});
						}
					}
					
					//양식 결재선에 수신처. (수신자, 수신부서)
                    if (getInfo("SchemaContext.scPRec.isUse") == "Y" || getInfo("SchemaContext.scPRecEnt.isUse") == "Y" || getInfo("SchemaContext.scPRecReg.isUse") == "Y"
						|| getInfo("SchemaContext.scDRec.isUse") == "Y" || getInfo("SchemaContext.scDRecEnt.isUse") == "Y" || getInfo("SchemaContext.scDRecReg.isUse") == "Y") {
						var isRec = false;
						
						// 타입별 수신자 가져오기
						var oaScPRecV = [];
                        if (getInfo("SchemaContext.scPRec.isUse") == "Y" && getInfo("SchemaContext.scPRec.value") != "") {
							var aScPRecVG = getInfo("SchemaContext.scPRec.value").split("||");
                        	for(var i=0;i<aScPRecVG.length ; i++){                             
	                            //var aScPRecV = getInfo("SchemaContext.scPRec.value").split("@@");
	                        	var aScPRecV =aScPRecVG[i].split("@@");
	                            if (aScPRecV.length > 2){
                                    var oScPRecV = $.parseJSON(aScPRecV[2]);
                                    oaScPRecV.push($$(oScPRecV).find("item").concat().json());
                                }
		                    }
						}else if (getInfo("SchemaContext.scPRecEnt.isUse") == "Y" && getInfo("SchemaContext.scPRecEnt.value") != "") {
							var sEtId = (document.getElementById("EntCode") == undefined) ? getInfo("FormInstanceInfo.EntCode") : document.getElementById("EntCode").value;
				            var oScPRecVGEnt = $.parseJSON(getInfo("SchemaContext.scPRecEnt.value"));
				            oaScPRecV = $$(oScPRecVGEnt).find("ENT_" + sEtId + " > item").json();
						}else if (getInfo("SchemaContext.scPRecReg.isUse") == "Y" && getInfo("SchemaContext.scPRecReg.value") != "") {
							var oScPRecVGReg = $.parseJSON(getInfo("SchemaContext.scPRecReg.value"));
							oaScPRecV = $$(oScPRecVGReg).find("REG_" + getInfo("AppInfo.regionid") + " > item").json();
						}
						
						// 수신자 셋팅
						$(oaScPRecV).each(function(idx,oRecPerson){
                            var oStep = {};
                            var oDivR = {};
                            var oDivTaskinfoR = {};
                            var oStepR = {};
                            var oOUR = {};
                            var oPersonR = {};
                            var oTaskinfoR = {};
                        	
                            $$(oDivR).attr("divisiontype", "receive");
                            $$(oDivR).attr("name", "담당결재");
                            $$(oDivR).attr("oucode", $$(oRecPerson).attr("RG"));
                            $$(oDivR).attr("ouname", $$(oRecPerson).attr("RGNM"));
                            
                            $$(oDivTaskinfoR).attr("status", "inactive");
                            $$(oDivTaskinfoR).attr("result", "inactive");
                            $$(oDivTaskinfoR).attr("kind", "receive");
                            
                            $$(oDivR).append("taskinfo", oDivTaskinfoR);
                            
                            $$(oStepR).attr("unittype", "person");
                            $$(oStepR).attr("routetype", "receive");
                            $$(oStepR).attr("name", "담당결재");
                            
                            // 공통 조직도 데이터 변경되면 수정 필요
                            $$(oOUR).attr("code", $$(oRecPerson).attr("RG"));
                            $$(oOUR).attr("name", $$(oRecPerson).attr("RGNM"));
                            
                            $$(oPersonR).attr("code", $$(oRecPerson).attr("AN"));
                            $$(oPersonR).attr("name", $$(oRecPerson).attr("DN"));
                            $$(oPersonR).attr("position", $$(oRecPerson).attr("po"));
                            $$(oPersonR).attr("title", $$(oRecPerson).attr("tl"));
                            $$(oPersonR).attr("level", $$(oRecPerson).attr("lv"));
                            $$(oPersonR).attr("oucode", $$(oRecPerson).attr("RG"));
                            $$(oPersonR).attr("ouname", $$(oRecPerson).attr("RGNM"));
                            $$(oPersonR).attr("sipaddress", $$(oRecPerson).attr("SIP"));
                            
                            $$(oTaskinfoR).attr("status", "inactive");
                            $$(oTaskinfoR).attr("result", "inactive");
                            $$(oTaskinfoR).attr("kind", "charge");
                            
                            $$(oPersonR).append("taskinfo", oTaskinfoR);
                            
                            $$(oOUR).append("person", oPersonR);
                            
                            $$(oStepR).append("ou", oOUR);
                            
                            $$(oDivR).append("step", oStepR);
                            
                            $$(oStep).append("division",oDivR);
        
                            //수신자 퇴직자 처리
                            var chkAbsentResult = chkAbsent(oStep);
                        	if (chkAbsentResult != "") {
                        		chkAbsentResult = chkAbsentResult.split("@@@");
                        		var absentType = chkAbsentResult[0];
                        		var absentMsg = chkAbsentResult[1];
                        		var absentCode = chkAbsentResult[2].split(",");
                        		alert(absentMsg);
                        		if(absentType != "absent") {
									$$(oApvList).find("steps").append("division", oDivR);
									isRec = true;
								}
                            }else{
                            	$$(oApvList).find("steps").append("division", oDivR);
								isRec = true;
                            }
						});

						// 타입별 수신부서 가져오기
						var oaScDRecV = [];
                        if (getInfo("SchemaContext.scDRec.isUse") == "Y" && getInfo("SchemaContext.scDRec.value") != "") {
							var aScDRecVG = getInfo("SchemaContext.scDRec.value").split("||");
                        	for(var i=0;i<aScDRecVG.length ; i++){                             
	                            //var aScPRecV = getInfo("SchemaContext.scPRec.value").split("@@");
	                        	var aScDRecV =aScDRecVG[i].split("@@");
	                            if (aScDRecV.length > 1){
                                    var oScDRecV = {};
									oScDRecV.AN = aScDRecV[0];
									oScDRecV.DN = aScDRecV[1];
                                    oaScDRecV.push(oScDRecV);
                                }
		                    }
						}else if (getInfo("SchemaContext.scDRecEnt.isUse") == "Y" && getInfo("SchemaContext.scDRecEnt.value") != "") {
							var sEtId = (document.getElementById("EntCode") == undefined) ? getInfo("FormInstanceInfo.EntCode") : document.getElementById("EntCode").value;
				            var oScDRecVGEnt = $.parseJSON(getInfo("SchemaContext.scDRecEnt.value"));
				            oaScDRecV = $$(oScDRecVGEnt).find("ENT_" + sEtId + " > item").json();
						}else if (getInfo("SchemaContext.scDRecReg.isUse") == "Y" && getInfo("SchemaContext.scDRecReg.value") != "") {
							var oScDRecVGReg = $.parseJSON(getInfo("SchemaContext.scDRecReg.value"));
							oaScDRecV = $$(oScDRecVGReg).find("REG_" + getInfo("AppInfo.regionid") + " > item").json();
						}
						
						// 수신부서 셋팅
						$(oaScDRecV).each(function(idx,oRecDept){
                            var oDivR = {};
                            var oDivTaskinfoR = {};
                            var oStepR = {};
                            var oOUR = {};
                            var oTaskinfoR = {};
                        	
                            $$(oDivR).attr("divisiontype", "receive");
                            $$(oDivR).attr("name", "담당부서수신");
                            $$(oDivR).attr("oucode", $$(oRecDept).attr("AN"));
                            $$(oDivR).attr("ouname", $$(oRecDept).attr("DN"));
                            
                            $$(oDivTaskinfoR).attr("status", "inactive");
                            $$(oDivTaskinfoR).attr("result", "inactive");
                            $$(oDivTaskinfoR).attr("kind", "receive");
                            
                            $$(oDivR).append("taskinfo", oDivTaskinfoR);
                            
                            $$(oStepR).attr("unittype", "ou");
                            $$(oStepR).attr("routetype", "receive");
                            $$(oStepR).attr("name", "담당부서수신");
                            
                            // 공통 조직도 데이터 변경되면 수정 필요
                            $$(oOUR).attr("code", $$(oRecDept).attr("AN"));
                            $$(oOUR).attr("name", $$(oRecDept).attr("DN"));
                            
                            $$(oTaskinfoR).attr("status", "inactive");
                            $$(oTaskinfoR).attr("result", "inactive");
                            $$(oTaskinfoR).attr("kind", "normal");
                            
                            $$(oOUR).append("taskinfo", oTaskinfoR);
                            
                            $$(oStepR).append("ou", oOUR);
                            
                            $$(oDivR).append("step", oStepR);
                            
                            //수신부서 삭제된 부서 처리
                            var oAbsentResult = chkAbsentGroupCall($$(oRecDept).attr("AN"));
							var aAbsentResult = oAbsentResult.map(g => g.GroupCode);
							if(aAbsentResult.includes($$(oRecDept).attr("AN"))){
								$$(oApvList).find("steps").append("division", oDivR);
								isRec = true;
							}else{
								var msg = Common.getDic("msg_apv_chkAbsentGroup") + '\n\n'; // 양식에 설정된 부서에 사용하지 않는 부서가 포함되어 적용되지 않습니다. 관리자에게 문의하세요.
								msg += Common.getDic("msg_apv_absentGroup") + " : " + CFN_GetDicInfo($$(oRecDept).attr("DN")); // 제외부서
								alert(msg);
							}
						});
						
						// 셋팅된 수신자,수신부서가 없으면 기존 결재선 유지
						if(!isRec){
							$$(oGetApvList).find("steps>division[divisiontype='receive']").has("step[routetype='receive']").has("step[unittype='ou'],[unittype='person']").each(function (i, enodeItem) {
                                $$(enodeItem).find("person>taskinfo").attr("result", "inactive");
                                $$(enodeItem).find("person>taskinfo").attr("status", "inactive");
                                $$(enodeItem).find("person>taskinfo").remove("datereceived");
                                $$(enodeItem.children().concat().eq(0)).attr("result", "inactive");
                                $$(enodeItem.children().concat().eq(0)).attr("status", "inactive");
                                $$(enodeItem.children().concat().eq(0)).remove("datereceived");
                                //$$(oApvList).append(enodeItem.key(), enodeItem);
                                $$(oApvList).find("steps").append("division", enodeItem.json());
                            });
						}
                    }
					
					//참조자 출력
					$$(oGetApvList).find("steps > ccinfo").concat().each(function (i, enodeItem) {
						$$(oApvList).find("steps").append("ccinfo", enodeItem.json());
					});
				}
				
				//양식오픈시 최종결재선에 visible값이 n이면 결재라인에서 삭제 
                if($$(oApvList).find("division[divisiontype='send'] > step > ou > person > taskinfo > [visible='n']").length > 0 ) {
                	$$(oApvList).find("division[divisiontype='send']>step").has("[unittype='person'],[unittype='role'],[unittype='ou']").each(function (i, enodeItem) {
                		if (i==0) $$(oApvList).find("division[divisiontype='send']").remove("step");
                		
                		if( !($$(enodeItem).find("ou>person>taskinfo>[visible='n']")).length > 0 ){
                			$$(oApvList).find("division[divisiontype='send']").append("step", enodeItem.json());
                		}
                	});
                }
                
                // ******************************************* (양식)자동결재선 적용 시작 ******************************************************//
					
					
				// 자동결재선 셋팅
				// 임시저장,재사용인 경우는 기존결재선에 중복체크 후 추가 나머지는 초기화(상단 oGetApvList = {};) 후 자동결재선만 추가
				// 합의자는 기안자 바로뒤에 추가, 나머지는 맨뒤에 추가
                if(bSetOption) {    
                    //자동합의자
                    if (getInfo("AutoApprovalLine.Agree.autoSet") == "Y") {
                        if (getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != undefined) {
                            var oAutoLineAgree = $.parseJSON(getInfo("AutoApprovalLine.Agree.WorkedApprovalLine"));
                            if ($$(oAutoLineAgree).find("step").length > 0) {
                                var oAppList = $$(oApvList).find("steps>division[divisiontype='send']>step[routetype='consult'][unittype='person']");
                                
                                //for (var i = 0; i < $$(oAppList).length; i++) {
                    			//	var oChkNode = $$(oAutoLineAgree).find("step").has("ou>person[code='" + $$($$(oAppList).concat().eq(i)).find("ou>person").attr("code") + "']");
                    			//	if (oChkNode.length > 0) {
                    			//		$$(oAutoLineAgree).find("step").remove(oChkNode.index());
                    			//	}
                    			//}
                                
                                for (var i = 0; i < $$(oAppList).find("ou").concat().length; i++) {
                                    var oChkNode = $$(oAutoLineAgree).find("step").has("ou>person[code='" + $$(oAppList).find("ou").concat().find("person").eq(i).attr("code") + "']");
                                    
                                    if($$(oAutoLineAgree).find("step>ou").concat().length > 1) {
                                		oChkNode = $$(oAutoLineAgree).find("step").find("ou").has("person[code='" + $$(oAppList).find("ou").concat().find("person").eq(i).attr("code") + "']");
                                		if (oChkNode.length > 0) {
                                			$$(oChkNode).remove();
                                		}
                                	}
                                	else if (oChkNode.length > 0) {
                                    	$$(oAutoLineAgree).find("step").remove(oChkNode.index());
                                    }
                                }
								
								if($$(oAutoLineAgree).find("step").concat().length > 0){
									var oCheckSteps = chkAbsent(oAutoLineAgree, false, "autoline");

									if (oCheckSteps != "") {
										var absentType = oCheckSteps.split("@@@")[0];
										var absentMsg = oCheckSteps.split("@@@")[1];
										var absentCode = oCheckSteps.split("@@@")[2].split(",");
																			
										alert(absentMsg);
										
										if(absentType == "absent") {
											$$(oAutoLineAgree).find("ou>person>taskinfo[kind!='charge']").parent().remove();
										} else {
											for(var i = 0; i < absentCode.length; i++) {
												if(absentCode[i] != "") {
													$$(oAutoLineAgree).find("ou>person[code='"+absentCode[i]+"']").remove();
												}	
											}
										}
									}
									
									// 기안자 (taskinfo가 charge) 바로 뒤에 자동합의자 데이터 넣기 위함 - 시작
									var tempChargeObj = {"step" : $$(oApvList).find("steps>division[divisiontype='send']>step").has("ou>person>taskinfo[kind='charge']").json()};
									var tempChargePath = "";
									
									if($$(tempChargeObj.step).exist()){
										tempChargePath = $$(oApvList).find("steps>division[divisiontype='send']>step").has("ou>person>taskinfo[kind='charge']").concat().eq(0).path();
										
										$$(oApvList).find("steps>division[divisiontype='send']>step").has("ou>person>taskinfo[kind='charge']").remove();
										
										if($$(oAutoLineAgree).find("step").length > 0) {
											$$(oAutoLineAgree).find("step").concat().each(function(i, elm){
												$$(tempChargeObj).append("step", elm.json());
											});
										}
										
										if($$(oApvList).find(tempChargePath.replace(/\//gi, ">")).parent().find("step").length > 0) {		// 기존 결재선이 기안자외에 결재선이 있을 경우
											if($$(oAutoLineAgree).find("step").length > 0) {
												$$(oApvList).find(tempChargePath.replace(/\//gi, ">")).parent().find("step").json().splice(0, 0, $$(tempChargeObj).find("step").json()[0], $$(tempChargeObj).find("step").json()[1]);
											}
											else {
												$$(oApvList).find(tempChargePath.replace(/\//gi, ">")).parent().find("step").json().splice(0, 0, $$(tempChargeObj).find("step").json());
											}
											
										}
										else {		// 기존 결재선이 기안자 외에 결재선이 없을 경우
											
											//ou값이 없는 경우에도 결재선데이터 추가되어 필터추가
											var filter = $$(tempChargeObj).find("step").json().filter(function(item){
												return item.ou && Object.keys(item.ou).length > 0  || item.ou && item.ou.length > 0;
											});
											
											if (tempChargePath.replace(/\//gi, ">").indexOf("division[") >= 0){
												$$(oApvList).find(tempChargePath.replace(/\//gi, ">").replace("division[0]>step", "division[divisiontype='send']")).append("step", filter );
											}
											else{
												$$(oApvList).find(tempChargePath.replace(/\//gi, ">").replace("division>step", "division[divisiontype='send']")).append("step", filter );
											}
										}
									}
									// 기안자 (taskinfo가 charge) 바로 뒤에 자동합의자 데이터 넣기 위함 - 끝
								}
                            }
                        }
                    }
                    //자동협조자
                    if (getInfo("AutoApprovalLine.Assist.autoSet") == "Y") {
                        if (getInfo("AutoApprovalLine.Assist.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Assist.WorkedApprovalLine") != undefined) {
                            var oAutoLineAssist = $.parseJSON(getInfo("AutoApprovalLine.Assist.WorkedApprovalLine"));
                            if ($$(oAutoLineAssist).find("step").length > 0) {
                                var oAppList = $$(oApvList).find("steps>division[divisiontype='send']>step[routetype='assist'][unittype='person']");
                                
                                //for (var i = 0; i < $$(oAppList).length; i++) {
                    			//	var oChkNode = $$(oAutoLineAssist).find("step").has("ou>person[code='" + $$($$(oAppList).concat().eq(i)).find("ou>person").attr("code") + "']");
                    			//	if (oChkNode.length > 0) {
                    			//		$$(oAutoLineAssist).find("step").remove(oChkNode.index());
                    			//	}
                    			//}
                                
                                for (var i = 0; i < $$(oAppList).find("ou").concat().length; i++) {
                                    var oChkNode = $$(oAutoLineAssist).find("step").has("ou>person[code='" + $$(oAppList).find("ou").concat().find("person").eq(i).attr("code") + "']");
                                    
                                    if($$(oAutoLineAssist).find("step>ou").concat().length > 1) {
                                		oChkNode = $$(oAutoLineAssist).find("step").find("ou").has("person[code='" + $$(oAppList).find("ou").concat().find("person").eq(i).attr("code") + "']");
                                		if (oChkNode.length > 0) {
                                			$$(oChkNode).remove();
                                		}
                                	}
                                	else if (oChkNode.length > 0) {
                                    	$$(oAutoLineAssist).find("step").remove(oChkNode.index());
                                    }
                                }

                                var oCheckSteps = chkAbsent(oAutoLineAssist, false, "autoline");

                                if (oCheckSteps != "") {
                                	var absentType = oCheckSteps.split("@@@")[0];
                                	var absentMsg = oCheckSteps.split("@@@")[1];
                                	var absentCode = oCheckSteps.split("@@@")[2].split(",");
                                	                            		
                            		alert(absentMsg);
                            		
                            		if(absentType == "absent") {
                            			$$(oAutoLineAssist).find("ou>person>taskinfo[kind!='charge']").parent().remove();
                            		} else {
                            			for(var i = 0; i < absentCode.length; i++) {
                            				if(absentCode[i] != "") {
                            					$$(oAutoLineAssist).find("ou>person[code='"+absentCode[i]+"']").remove();
                            				}	
                            			}
                            		}
                                }
                                
                                $$(oAutoLineAssist).find("step").concat().each(function(i, elm){
                                	$$(oApvList).find("steps>division[divisiontype='send']").append("step", elm.json());
                                });
                            }
                        }
                    }
                    //자동결재자
                    if (getInfo("AutoApprovalLine.Approval.autoSet") == "Y") {
                        if (getInfo("AutoApprovalLine.Approval.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Approval.WorkedApprovalLine") != undefined) {
                            var oAutoLineApproval = $.parseJSON(getInfo("AutoApprovalLine.Approval.WorkedApprovalLine"));
                            if ($$(oAutoLineApproval).find("step").length > 0) {
                                var oAppList = $$(oApvList).find("steps>division[divisiontype='send']>step[name!='reference'][routetype='approve'][unittype='person']");
                                for (var i = 0; i < $$(oAppList).length; i++) {
                                    var oChkNode = $$(oAutoLineApproval).find("step").has("ou > person[code='" + $$($$(oAppList).concat().eq(i)).find("ou > person").attr("code") + "']");
                                    if (oChkNode.length > 0) {
                                    	//$$(oChkNode).remove();
                                    	$$(oAutoLineApproval).find("step").remove(oChkNode.index());
                                    }
                                }

                                var oCheckSteps = chkAbsent(oAutoLineApproval, false, "autoline");

                                if (oCheckSteps != "") {
                                	var absentType = oCheckSteps.split("@@@")[0];
                                	var absentMsg = oCheckSteps.split("@@@")[1];
                                	var absentCode = oCheckSteps.split("@@@")[2].split(",");
                                	                            		
                            		alert(absentMsg);
                            		
                            		if(absentType == "absent") {
                            			$$(oAutoLineApproval).find("ou>person>taskinfo[kind!='charge']").parent().remove();
                            		} else {
                            			for(var i = 0; i < absentCode.length; i++) {
                            				if(absentCode[i] != "") {
                            					$$(oAutoLineApproval).find("ou>person[code='"+absentCode[i]+"']").remove();
                            				}	
                            			}
                            		}
                                }
                                
                                $$(oAutoLineApproval).find("step").concat().each(function(i, elm){
                                	$$(oApvList).find("steps>division[divisiontype='send']").append("step", elm.json());
                                });
                            }
                        }
                    }
                    //자동참조자
                    if (getInfo("AutoApprovalLine.CCAfter.autoSet") == "Y") {

                        if (getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != undefined) {
                            var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine"));
                            if ($$(oAutoLineCC).find("ccinfo").length > 0) {
                                $$(oApvList).find("steps>ccinfo[belongto='sender']").each(function (i, elm) {
                                    var oChkNode = $$(oAutoLineCC).find("ccinfo[belongto='sender']").has(">ou>person[code='" + $$(elm).find("ou > person").attr("code") + "']");
                                    if (oChkNode.length > 0) {
                                    	//$$(oChkNode).remove();
                                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
                                    }
                                    var oChkNode = $$(oAutoLineCC).find("ccinfo[belongto='sender']").has("> ou[code='" + $(elm).find("ou").attr("code") + "']");
                                    if (oChkNode.length > 0) {
                                    	//$$(oChkNode).remove();
                                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
                                    }
                                });	                            		

                                var oCheckSteps = chkAbsent(oAutoLineCC, false, "autoline");

                                if (oCheckSteps != "") {
                                	var absentType = oCheckSteps.split("@@@")[0];
                                	var absentMsg = oCheckSteps.split("@@@")[1];
                                	var absentCode = oCheckSteps.split("@@@")[2].split(",");
                                	                            		
                            		alert(absentMsg);
                            		
                            		if(absentType == "absent") {
                            	        $$(oAutoLineCC).find("ccinfo").remove();
                            		} else {
                            			for(var i = 0; i < absentCode.length; i++) {
                            				if(absentCode[i] != "") {
                            					$$(oAutoLineCC).find("ccinfo").remove($$(oAutoLineCC).find("ccinfo>ou>person[code='"+absentCode[i]+"']").parent().parent().index());
                            				}	
                            			}
                            		}	
                                }
                                
                                $$(oAutoLineCC).find("ccinfo").concat().attr("datereceived", "");
                                
                                $$(oAutoLineCC).find("ccinfo").concat().each(function(i, elm){
                                	$$(oApvList).find("steps").append("ccinfo", elm.json());
                                });
                            }
                        }
                    }
                    //자동참조자(사전)
                    if (getInfo("AutoApprovalLine.CCBefore.autoSet") == "Y") {
                        if (getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine") != undefined) {
                            var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine"));
                            if ($$(oAutoLineCC).find("ccinfo").length > 0) {
                                $$(oApvList).find("steps>ccinfo[belongto='sender'][beforecc='y']").each(function (i, elm) {
                                    var oChkNode = $$(oAutoLineCC).find("ccinfo[belongto='sender'][beforecc='y']").has(">ou>person[code='" + $$(elm).find("ou > person").attr("code") + "']");
                                    if (oChkNode.length > 0) {
                                    	//$$(oChkNode).remove();
                                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
                                    }
                                    var oChkNode = $$(oAutoLineCC).find("ccinfo[belongto='sender'][beforecc='y']").has(">ou[code='" + $(elm).find("ou").attr("code") + "']");
                                    if (oChkNode.length > 0) {
                                    	//$$(oChkNode).remove();
                                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
                                    }
                                });	                            		

                                var oCheckSteps = chkAbsent(oAutoLineCC, false, "autoline");

                                if (oCheckSteps != "") {
                                	var absentType = oCheckSteps.split("@@@")[0];
                                	var absentMsg = oCheckSteps.split("@@@")[1];
                                	var absentCode = oCheckSteps.split("@@@")[2].split(",");
                                	                            		
                            		alert(absentMsg);
                            		
                            		if(absentType == "absent") {
                            	        $$(oAutoLineCC).find("ccinfo").remove();
                            		} else {
                            			for(var i = 0; i < absentCode.length; i++) {
                            				if(absentCode[i] != "") {
                            					$$(oAutoLineCC).find("ccinfo").remove($$(oAutoLineCC).find("ccinfo>ou>person[code='"+absentCode[i]+"']").parent().parent().index());
                            				}	
                            			}
                            		}	
                                }
                                
                                $$(oAutoLineCC).find("ccinfo").concat().attr("datereceived", "");
                                
                                $$(oAutoLineCC).find("ccinfo").concat().each(function(i, elm){	                                    	
                                	$$(oApvList).find("steps").append("ccinfo", elm.json());
                                });
                            }
                        }
                    }
                }
                
                
                
                // ******************************************* (양식)자동결재선 적용 끝 ******************************************************// 

				return JSON.stringify(oApvList);
			}
        }
    }
}

function chkAutoApprovalLine(){
	
	//결재팝업 호출 여부
	var apvlinePopupYN; //결재선지정 팝업여부
	try{
		if(typeof chkAutopopup != "undefined" && chkAutopopup!='') apvlinePopupYN = true;
	}catch(e){
		coviCmn.traceLog(e);
	}
	
    //합의자 체크
    if (getInfo("AutoApprovalLine.Agree.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Agree.WorkedApprovalLine") != undefined) {
            var oAutoLineAgree = $.parseJSON(getInfo("AutoApprovalLine.Agree.WorkedApprovalLine"));
            if ($$(oAutoLineAgree).find("step").concat().length > 0) {
                var jsonApv;
				if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                else jsonApv = chkAutopopup.$$_m_oApvList;
                var oAppList = $$(jsonApv).find("steps>division[divisiontype='send']>step[routetype='consult'][unittype='person']");
                for (var i = 0; i < $$(oAppList).find("ou>person").concat().length; i++) {
                    var oChkNode = $$(oAutoLineAgree).find("step>ou").has("person>[code='" + $$(oAppList).find("ou>person").concat().eq(i).attr("code") + "']");
                    if (oChkNode.length > 0) {
                        $$(oChkNode).remove();
                    }
                }
                if ($$(oAutoLineAgree).find("step>ou>person").concat().length > 0) {
                    var sAlert = "[";
                    $$(oAutoLineAgree).find("step>ou>person").concat().each(function(i, elm){
                    	if (i > 0) sAlert += ", ";
                        sAlert += getLngLabel(elm.attr("name"), false);
						//sAlert += " " + getLngLabel(elm.attr("position"), true);
                        g_DisplayJobType && (sAlert += " " + getLngLabel(elm.attr(g_DisplayJobType), true));
                    });
                    
                    sAlert += "]";
					sAlert = Common.getDic("msg_apv_autoChkAgree").replace("{0}", sAlert);
					if(!apvlinePopupYN){
	                    Common.Inform(sAlert);
	                    return true;
					}else{
						chkAutopopup.Common.Inform(sAlert);
                    	return true;
					}
                }
            }
        }
    }
    //협조자 체크
    if (getInfo("AutoApprovalLine.Assist.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.Assist.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Assist.WorkedApprovalLine") != undefined) {
            var oAutoLineAssist = $.parseJSON(getInfo("AutoApprovalLine.Assist.WorkedApprovalLine"));
            if ($$(oAutoLineAssist).find("step").concat().length > 0) {
                var jsonApv;
				if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                else jsonApv = chkAutopopup.$$_m_oApvList;
                var oAppList = $$(jsonApv).find("steps>division[divisiontype='send']>step[routetype='assist'][unittype='person']");
                for (var i = 0; i < $$(oAppList).find("ou>person").concat().length; i++) {
                    var oChkNode = $$(oAutoLineAssist).find("step>ou").has("person>[code='" + $$(oAppList).find("ou>person").concat().eq(i).attr("code") + "']");
                    if (oChkNode.length > 0) {
                        $$(oChkNode).remove();
                    }
                }
                if ($$(oAutoLineAssist).find("step>ou>person").concat().length > 0) {
                    var sAlert = "[";
                    $$(oAutoLineAssist).find("step>ou>person").concat().each(function(i, elm){
                    	if (i > 0) sAlert += ", ";
                        sAlert += getLngLabel(elm.attr("name"), false);
						//sAlert += " " + getLngLabel(elm.attr("position"), true);
                        g_DisplayJobType && (sAlert += " " + getLngLabel(elm.attr(g_DisplayJobType), true));
                    });
                    
                    sAlert += "]";
					sAlert = Common.getDic("msg_apv_autoChkAssist").replace("{0}", sAlert);
					if(!apvlinePopupYN){
	                    Common.Inform(sAlert);
	                    return true;
					}else{
						chkAutopopup.Common.Inform(sAlert);
                    	return true;
					}
                }
            }
        }
    }
    //결재자 체크
    if (getInfo("AutoApprovalLine.Approval.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.Approval.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.Approval.WorkedApprovalLine") != undefined) {
            var oAutoLineApproval = $.parseJSON(getInfo("AutoApprovalLine.Approval.WorkedApprovalLine"));
            if ($$(oAutoLineApproval).find("step").concat().length > 0) {
                var jsonApv;
				if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                else jsonApv = chkAutopopup.$$_m_oApvList;
                var oAppList = $$(jsonApv).find("steps>division[divisiontype='send']>step[name!='reference'][routetype='approve'][unittype='person']");
                for (var i = 0; i < $$(oAppList).concat().length; i++) {
                    var oChkNode = $$(oAutoLineApproval).find("step").concat().has("ou > person[code='" + $$($$(oAppList).concat().eq(i)).find("ou > person").attr("code") + "']");
                    if (oChkNode.length > 0) {
                        //$$(oChkNode).remove();
                    	$$(oAutoLineApproval).find("step").remove(oChkNode.index());
                    }
                }
                if ($$(oAutoLineApproval).find("step").concat().length > 0) {
                    var sAlert = "[";
                    for (var i = 0; i < $$(oAutoLineApproval).find("step").concat().length; i++) {
                        if (i > 0) sAlert += ", ";
                        sAlert += getLngLabel($$($$(oAutoLineApproval).find("step").concat().eq(i)).find("ou > person").attr("name"), false);
						//sAlert += " " + getLngLabel($$($$(oAutoLineApproval).find("step").concat().eq(i)).find("ou > person").attr("position"), true);
                        g_DisplayJobType && (sAlert += " " + getLngLabel($$($$(oAutoLineApproval).find("step").concat().eq(i)).find("ou > person").attr(g_DisplayJobType), true));
                    }
                    sAlert += "]";
                    sAlert = Common.getDic("msg_apv_autoChkApproval").replace("{0}", sAlert);
                    if(!apvlinePopupYN){
	                    Common.Inform(sAlert);
	                    return true;
					}else{
						chkAutopopup.Common.Inform(sAlert);
                    	return true;
					}
                }
            }
        }
    }
    //참조자 체크
    if (getInfo("AutoApprovalLine.CCAfter.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine") != undefined) {
            var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCAfter.WorkedApprovalLine"));
            if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
                var jsonApv;
				if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                else jsonApv = chkAutopopup.$$_m_oApvList;
                var oAppList = $$(jsonApv).find("steps > ccinfo > ou > person");
                for (var i = 0; i < $$(oAppList).concat().length; i++) {
                    var oChkNode = $$(oAutoLineCC).find("ccinfo").has("ou > person[code='" + $$($$(oAppList).concat().eq(i)).attr("code") + "']");
                    if (oChkNode.length > 0) {
                        //$$(oChkNode).remove();
                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
                    }
                }
                oAppList = $$(jsonApv).find("steps > ccinfo > ou").not("person");
                for (var i = 0; i < $$(oAppList).concat().length; i++) {
                    var oChkNode = $$(oAutoLineCC).find("ccinfo").has("ou[code='" + $$($$(oAppList).concat().eq(i)).attr("code") + "']").not("person");
                    if (oChkNode.length > 0) {
                    	//$$(oChkNode).remove();
                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
                    }
                }
                if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
                    var sAlert = "[";
                    for (var i = 0; i < $$(oAutoLineCC).find("ccinfo").concat().length; i++) {
                        if (i > 0) sAlert += ", ";
                        if ($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").length == 0) {
                            sAlert += getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou").attr("name"), false);
                        } else {
                            sAlert += getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("name"), false);
							//sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("position"), true);
                            g_DisplayJobType && (sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr(g_DisplayJobType), true));
                        }
                    }
                    sAlert += "]";
                    sAlert = Common.getDic("msg_apv_autoChkCC").replace("{0}", sAlert);
                    if(!apvlinePopupYN){
	                    Common.Inform(sAlert);
	                    return true;
					}else{
						chkAutopopup.Common.Inform(sAlert);
                    	return true;
					}
                }
            }
        }
    }
    //참조자 체크(사전)
    if (getInfo("AutoApprovalLine.CCBefore.autoChk") == "Y") {
        if (getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine") != "" && getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine") != undefined) {
            var oAutoLineCC = $.parseJSON(getInfo("AutoApprovalLine.CCBefore.WorkedApprovalLine"));
            if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
                var jsonApv;
				if(!apvlinePopupYN) jsonApv = $.parseJSON(document.getElementById("APVLIST").value);
                else jsonApv = chkAutopopup.$$_m_oApvList;
                var oAppList = $$(jsonApv).find("steps > ccinfo > ou > person");
                for (var i = 0; i < $$(oAppList).concat().length; i++) {
                    var oChkNode = $$(oAutoLineCC).find("ccinfo").has("ou > person[code='" + $$($$(oAppList).concat().eq(i)).attr("code") + "']");
                    if (oChkNode.length > 0) {
                    	//$$(oChkNode).remove();
                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
                    }
                }
                oAppList = $$(jsonApv).find("steps > ccinfo > ou").not("person");
                for (var i = 0; i < $$(oAppList).concat().length; i++) {
                    var oChkNode = $$(oAutoLineCC).find("ccinfo").has("ou[code='" + $$($$(oAppList).concat().eq(i)).attr("code") + "']").not("person");
                    if (oChkNode.length > 0) {
                    	//$$(oChkNode).remove();
                    	$$(oAutoLineCC).find("ccinfo").remove(oChkNode.index());
                    }
                }
                if ($$(oAutoLineCC).find("ccinfo").concat().length > 0) {
                    var sAlert = "[";
                    for (var i = 0; i < $$(oAutoLineCC).find("ccinfo").concat().length; i++) {
                        if (i > 0) sAlert += ", ";
                        if ($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").length == 0) {
                            sAlert += getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou").attr("name"), false);
                        } else {
                            sAlert += getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("name"), false);
							//sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr("position"), true);
                            g_DisplayJobType && (sAlert += " " + getLngLabel($$($$(oAutoLineCC).find("ccinfo").concat().eq(i)).find("ou > person").attr(g_DisplayJobType), true));
                        }
                    }
                    sAlert += "]";
                    sAlert = Common.getDic("msg_apv_autoChkCC").replace("{0}", sAlert);
                    if(!apvlinePopupYN){
	                    Common.Inform(sAlert);
	                    return true;
					}else{
						chkAutopopup.Common.Inform(sAlert);
                    	return true;
					}
                }
            }
        }
    }
}

function chkAbsent(oSteps, isReuse, target) {
    var elmUsers;
    var sUsers = "";
    
    var person_str = "division>step>ou>person"; 
    if (target == "ccinfo") {
    	//참조자도 퇴직여부 확인
    	person_str = "ccinfo>ou>person";
    } else if (target == "autoline") {
    	//자동결재선 퇴직여부 확인 - 자동결재선은 steps가 아닌 step만을 넘김
    	person_str = "ou>person";
    }
    
    $$(oSteps).find(person_str).each(function (i, $$) {
        if (sUsers.length > 0) {
            var szcmpUsers = ";" + sUsers + ";";
            if (szcmpUsers.indexOf(";" + $$.concat().attr("code") + ";") == -1) { sUsers += ";" + $$.concat().attr("code"); }
        } else {
            sUsers += $$.concat().attr("code");
        }
    });
    
    var bReturn = "";
    
	if (sUsers != "") {
    $.ajax({
    	type:"POST",
    	url:"/approval/apvline/checkAbsentMember.do",
    	async:false,
    	data:{
    		"users":sUsers
    	},
    	success : function(data){
	              var sAbsentResult = "";
	              var sAbsentResultCode = "";
	              var sResult = "";
	              var sResultCode = "";
	              var oChkAbsentNode;
	    		  $$(oSteps).find(person_str).each(function (i, oUser) {
	    			  if($$(oUser).concat().length <= 1) { // 대결자 있는 경우 퇴사자로 인식하여 예외처리
		    			  sAbsentResult += getLngLabel($$(oUser).concat().attr("name"), false) + ",";
		    			  sAbsentResultCode += getLngLabel($$(oUser).concat().attr("code"), false) + ",";
		    			  sResult += getLngLabel($$(oUser).concat().attr("name"), false) + ",";
		    			  sResultCode += getLngLabel($$(oUser).concat().attr("code"), false) + ",";
		    			  
		                  $(data.list).each(function (idx, oChkAbsentNode) {
		                      if (oChkAbsentNode.PERSON_CODE == oUser.attr("code")) { //재직자
		                          if (oChkAbsentNode.UNIT_CODE == oUser.attr("oucode")) { //부서 변경 없음
		                              oUser.attr("oucode", oChkAbsentNode.UNIT_CODE);
		                              oUser.attr("ouname", oChkAbsentNode.UNIT_NAME);
		                              oUser.attr("position", oChkAbsentNode.JOBPOSITION_Z);
		                              oUser.attr("title", oChkAbsentNode.JOBTITLE_Z);
		                              oUser.attr("level", oChkAbsentNode.JOBLEVEL_Z);
		                              sResult = sResult.replace(getLngLabel(oUser.attr("name"), false) + ",", "");
		                              sResultCode = sResultCode.replace(getLngLabel(oUser.attr("code"), false) + ",", "");
		                          }
		
		                          sAbsentResult = sAbsentResult.replace(getLngLabel(oUser.attr("name"), false) + ",", "");
		                          sAbsentResultCode = sAbsentResultCode.replace(getLngLabel(oUser.attr("code"), false) + ",", "");
		                      }
		                  });
	    			  }
	              });	    		  
	    		  
	    		  if (sAbsentResult != "") {
	    			  var msg = Common.getDic("msg_apv_057").replace(/\\n/g, '\n'); //선택한 개인결재선 혹은 저장된 최종결재선에\n퇴직자가 포함되어 적용이 되지 않습니다.\n\n확인바랍니다.\n\n
	    			  if(isReuse) {
	    				  msg = Common.getDic("msg_apv_360").replace(/\\n/g, '\n'); //저장된 결재선에 퇴직자가 포함되어 적용이 되지 않습니다.
	    			  }
	    			  if(target == "autoline") {
	    				  msg = Common.getDic("msg_apv_361").replace(/\\n/g, '\n'); //자동결재선에 퇴직자가 포함되어 적용이 되지 않습니다.\n\n
	    			  }
	    			  if(target == "ccinfo") {
	    				  msg = msg.replace(Common.getDic("lbl_apv_approver"), Common.getDic("lbl_apv_cclisttitle")); //결재선 -> 참조목록
	    			  }
	    			  msg = msg + '\n' + Common.getDic("msg_apv_359") + " : " + sAbsentResult.substring(0, sAbsentResult.length - 1);
	                  bReturn = "absent@@@" + msg + "@@@" + sAbsentResultCode;
	              } else {
	                  if (sResult != "") {
		    			  var msg = Common.getDic("msg_apv_173").replace(/\\n/g, '\n'); //선택한 개인결재선 혹은 저장된 최종결재선의\n부서/인사정보가 최신정보와 일치하지 않아 적용이 되지 않습니다.\n\n---변경자--- \n\n
		    			  if(isReuse) {
		    				  msg = Common.getDic("msg_apv_357").replace(/\\n/g, '\n'); //저장된 결재선의 부서/인사정보가 최신정보와 일치하지 않아 제외됩니다.
		    			  }
		    			  if(target == "autoline") {
		    				  msg = Common.getDic("msg_apv_362").replace(/\\n/g, '\n'); //자동결재선의 부서/인사정보가 최신정보와 일치하지 않아 제외됩니다.
		    			  }
		    			  if(target == "ccinfo") {
		    				  msg = msg.replace(Common.getDic("lbl_apv_approver"), Common.getDic("lbl_apv_cclisttitle")); //결재선 -> 참조목록
		    			  }
		    			  msg = msg + '\n' + Common.getDic("msg_apv_358") + " : " + sResult.substring(0, sResult.length - 1);
		                  bReturn = "change@@@" + msg + "@@@" + sResultCode;
	                  } else {
	                	  bReturn = "";
	                  }
	              }
	    	},
	    	error:function(response, status, error){
				CFN_ErrorAjax("apvline/checkAbsentMember.do", response, status, error);
			}
	    	
	    });
	}
   
    return bReturn;
}

function getLngLabel(szLngLabel, szType, szSplit) {
    var rtnValue = "";
    if(szLngLabel != undefined){
	    if (szSplit != null) {
	        var ary = szLngLabel.split(";");
	        if (szSplit) { ary = szLngLabel.split(szSplit); }
	        var sValue02 = "";
	        for (var i = 0; i < ary.length; i++) {
	            sValue02 = sValue02 + ary[i] + ";";
	        }
	        if (szType) {
	            sValue02 = szLngLabel.substring(sValue.indexOf(";") + 1);
	        }
	        return CFN_GetDicInfo(sValue02);
	    } else {
	        var sValue02 = szLngLabel;
	        if (szType) {
	
	        	sValue02 = szLngLabel.substring(szLngLabel.indexOf(";") + 1);
	        }
	        return CFN_GetDicInfo(sValue02);
	    }
    }else{
    	return "";
    }
}

function openApvLinePopup() {
	var iHeight = 580; 
	var iWidth = 1100;
	var sUrl = "/approval/approvalline.do?openID=" + accountCtrl.getViewPageDivID(); 
	var sSize = "scrollbars=no,toolbar=no,resizable=no";
	
	document.getElementById("APVLIST").value = accountCtrl.getInfo("APVLIST_").val();
    CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
}

function openRuleApvPopup() {
	var iHeight = 400; 
	var iWidth = 1000;
	var sUrl = "/approval/getApprovalLinePopup.do?openID=" + accountCtrl.getViewPageDivID(); 
	var sSize = "scroll";
	
    CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
}

function __setInlineApvList() {
	accountCtrl.getInfo("APVLIST_").val(document.getElementById("APVLIST").value);
	var objGraphicList = ApvGraphicView.getGraphicData(document.getElementById("APVLIST").value);
	
	ApvGraphicView.conf.serialDisplayAnimation = false;
	accountCtrl.getInfo("graphicDiv").html("");
	accountCtrl.getInfo("graphicDiv").removeClass("apv-stat-init apv-stat-open");
	ApvGraphicView.initRender(accountCtrl.getInfo("graphicDiv"), objGraphicList, "account");
}

// oucode / personcode 가 없는 결재선 체크
// 1. 체크할 값을 aApprovalLine 에 바인딩.
// 2. 바인딩 된 데이터 기준 검사
function bool_ApvValidationCheck() {
	var bReturn = true;
	var aApprovalLine = new Array();
	try {
		var oApvList = $.parseJSON(accountCtrl.getInfo("APVLIST_").val());
		var nLength = $$(oApvList).find("steps>division>step").concat().length;
		
		// 1. 체크할 값을 aApprovalLine 에 바인딩.
		for (var k = 0; k < nLength; k++) {
        	var oStep = $$(oApvList).find("steps>division>step").concat().eq(k);
        	
        	var sStepPath = oStep.path();
			var sOUCode = "";
			var sPersonCode = "";
			if ((oStep.attr("ou") != null) &&
				(oStep.attr("ou").length == null)) { // ou가 1개
				if (oStep.attr("unittype") == "ou") {
					sOUCode = oStep.attr("ou").code;
					sPersonCode = "";
				}
				else if(oStep.find("role").length > 0){
					sOUCode =oStep.find("role").attr("oucode");
					sPersonCode = oStep.find("role").attr("code");
				}
				else {
					sOUCode = oStep.attr("ou").person.oucode;
					sPersonCode = oStep.attr("ou").person.code;
				}
				if (sOUCode == null) { sOUCode = ""; }
				if (sPersonCode == null) { sPersonCode = ""; }
				
				var aTemp = new Array();
				aTemp.push(sStepPath);
				aTemp.push(sOUCode);
				aTemp.push(sPersonCode);
				aApprovalLine.push(aTemp);
			}
			else { // ou가 n개(병렬)
				if (oStep.attr("unittype") == "ou") {
					for(var i = 0; i < oStep.attr("ou").length; i++) {
						sOUCode = oStep.attr("ou")[i].code;
						sPersonCode = "";
						if (sOUCode == null) { sOUCode = ""; }
						if (sPersonCode == null) { sPersonCode = ""; }
				
						var aTemp = new Array();
						aTemp.push(sStepPath);
						aTemp.push(sOUCode);
						aTemp.push(sPersonCode);
						aApprovalLine.push(aTemp);
					}
				}
				else {
					for(var i = 0; i < oStep.attr("ou").length; i++) {
						sOUCode = oStep.attr("ou")[i].person.oucode;
						sPersonCode = oStep.attr("ou")[i].person.code;
						if (sOUCode == null) { sOUCode = ""; }
						if (sPersonCode == null) { sPersonCode = ""; }
				
						var aTemp = new Array();
						aTemp.push(sStepPath);
						aTemp.push(sOUCode);
						aTemp.push(sPersonCode);
						aApprovalLine.push(aTemp);
					}
				}
			}
		}
		
		// 2. 바인딩 된 데이터 기준 검사
		for (var j = 0; j < aApprovalLine.length; j++) {
			var nDivision = 0;
			var nStartStep = 1;
			var sStepPath = aApprovalLine[j][0];
			var sDivision = sStepPath.split("/")[2];
			if (sDivision.indexOf("[") <= 0) {
				nDivision = -1;
			}
			else {
				if (sDivision.indexOf("[" + nDivision + "]") <= 0) {
					nDivision++;
					nStartStep = j + 1;
				}
			}
	
			if ((aApprovalLine[j][1] == "") &&
				(aApprovalLine[j][2] == "")) {
					
				/*var sMessage = "";
				if (nDivision !== -1 && nDivision === 0) {
					sMessage = "1 발신 ";
				}
				else {
					sMessage = (nDivision + 1).toString() + " 담당 ";
				}*/
				
				var sRank = "";
				if (j - nStartStep + 2 < 10) {
					//sRank = "0" + (j - nStartStep + 2).toString() + " 번째";
					sRank = "(" + Common.getDic("lbl_apv_no") + " : " + (j - nStartStep + 2).toString() + ") "; // (순번 : n) 
				}
				Common.Warning(sRank + Common.getDic("lbl_apv_lineNoneApprover"), "", function () { // 결재자가 설정되어 있지 않습니다.<br />결재선을 확인하여 주십시오.
					//document.getElementById("btLine").click();
					openApvLinePopup();
				});
				return false;
			}
		}
	}
	catch (ex) {
		Common.Warning(Common.getDic("lbl_apv_lineChkError") + "<br />" + ex.toString()); // 결재선 확인 중 오류
		bReturn = false;
	}
	return bReturn;
}

// 담당업무 정보 조회/수정 (전결규정에서 담당업무를 셋팅할때 사용)
function getChargeJob(){
	var pageObjName = accountCtrl.getViewPageObjectName();
	var pageObj = this.window[pageObjName];
	var requestType = pageObj.getRequestType();
	
	return accComm[requestType].pageExpenceFormInfo.ChargeJob;
}
function setChargeJob(pChargeJobInfo){
	var setChargeJobInfo = "";
	if(pChargeJobInfo && pChargeJobInfo.split("@").length > 1){
		setChargeJobInfo = pChargeJobInfo;
	} else{
		setChargeJobInfo = getInfo("SchemaContext.scChgr.value"); // 전결규정 담당업무가 없으면 양식 기본설정된 정보 이용 (setInfoAll 에서 전자결재 설정이 아닌 경비결재 담당업무 설정으로 변경된 데이터)
	}
	if(setChargeJobInfo && setChargeJobInfo.split("@").length > 1){
		var pageObjName = accountCtrl.getViewPageObjectName();
		var pageObj = this.window[pageObjName];
		var requestType = pageObj.getRequestType();
		var aChargeJob = setChargeJobInfo.split("^").map(pair => pair.split("@")[0]);
		var setChargeJob = aChargeJob.join("^");

		accComm[requestType].pageExpenceFormInfo.AccountChargeInfo = setChargeJob; // jfcode
		accComm[requestType].pageExpenceFormInfo.ChargeJob = setChargeJobInfo; // jfcode@jfname
		setInfo("AccountChargeInfo",setChargeJob); // jfcode
		setInfo("ChargeJob",setChargeJobInfo); // // jfcode@jfname
		//setInfo("SchemaContext.scChgr.value","jfcode@jfname");
		//setInfo("SchemaContext.scChgr.isUse","Y");
	}
}

function callInputAuditReason(propertyOtherApv, expAppObj, htmlBody, expAppId, requestType) {
	var hasValue = false;
	if(expAppObj.auditEvidList != null && expAppObj.auditEvidList.length > 0) {
		hasValue = true;
	} else if(expAppObj.auditCntMap != null && expAppObj.auditCntMap.length > 0) {
		hasValue = true;
	} else if(expAppObj.auditAppLimitList != null && expAppObj.auditAppLimitList.length > 0) {
		hasValue = true;
	}
	
	if(hasValue && Common.getBaseConfig("useAuditReason") == "Y") {
		Common.Prompt(Common.getDic("ACC_msg_AuditReason"), "", Common.getDic("ACC_lbl_inputReason"), function(result){
			//감사규칙 위반 사유 입력하지 않고 prompt창 닫았을 경우 신청 불가
			if(result == null || result == "") {
				Common.Warning(Common.getDic("ACC_msg_requiredAuditReason"));
				return false;
			} else {
				expAppObj.AuditReason = result;
				
				$.ajax({
					url	:"/account/expenceApplication/saveAuditReason.do",
					type: "POST",
					async: false,
					data: {
						"ExpenceApplicationID" : expAppObj.ExpenceApplicationID,
						"AuditReason" : expAppObj.AuditReason
					},
					success:function (data) {
						if(data.result == "ok"){
							if(propertyOtherApv == "Y"){
								callOpenForm(expAppObj, htmlBody, expAppId, requestType);
							} else {
								callAutoDraft(expAppObj, htmlBody, expAppId, requestType);
							}
						}
					},
					error:function (error){
						Common.Error(Common.getDic("ACC_msg_error")); // 오류가 발생했습니다. 관리자에게 문의바랍니다.
					}
				});	
			}
			return true;
		});
	} else {
		if(propertyOtherApv == "Y"){
			callOpenForm(expAppObj, htmlBody, expAppId, requestType);
		} else {
			callAutoDraft(expAppObj, htmlBody, expAppId, requestType);
		}
	}
}

function callOpenForm(expAppObj, htmlBody, expAppId, requestType) {	
	var sKey = expAppId;
	var sSubject = expAppObj.ApplicationTitle;
	var sLogonId = sessionObj["USERID"];
	var sLegacyFormID = accComm[requestType].pageExpenceFormInfo.ApprovalFormInfo;
	if(sLegacyFormID == undefined) {
		sLegacyFormID = Common.getBaseConfig("LegacyFormIDForEAccount");
	}
	var sDataType = "ALL"; //HTML, JSON, ALL
	var now = new Date();
	now = now.getFullYear() + '-' + XFN_AddFrontZero(now.getMonth() + 1) + '-' + XFN_AddFrontZero(now.getDate()) + " " 
			+ XFN_AddFrontZero(now.getHours()) + ":" + XFN_AddFrontZero(now.getMinutes()) + ":" + XFN_AddFrontZero(now.getSeconds());
	var sBodyContext = {
		LegacyFormID : sLegacyFormID,
		ERPKey : sKey,
		HTMLBody : htmlBody,
		JSONBody : expAppObj,
		InitiatedDate : now,
		InitiatorCodeDisplay : sessionObj["UR_Code"],
		InitiatorDisplay : sessionObj["UR_Name"],
		InitiatorOUDisplay : sessionObj["GR_Name"]
	};
	
	var url = document.location.protocol + "//" + document.location.host + "/approval/legacy/goFormLink.do";
	var form = document.createElement("form");
	form.method = "POST";
	form.target = "form";
	form.action = url;
	form.style.display = "none";

	var key = document.createElement("input");
	var mode = document.createElement("input");
	var logonId = document.createElement("input");
	var subject = document.createElement("input");
	var legacyFormID = document.createElement("input");
	var dataType = document.createElement("input");
	var bodyContext = document.createElement("input");
	var isTempSaveBtn = document.createElement("input");
		    
	key.type = "hidden";
	mode.type = "hidden";
	logonId.type = "hidden";
	subject.type = "hidden";
	legacyFormID.type = "hidden";
	dataType.type = "hidden";
	bodyContext.type = "hidden";
	isTempSaveBtn.type = "hidden";
		    
	key.name = "key";
	mode.name = "mode";
	logonId.name = "logonId";
	subject.name = "subject";
	legacyFormID.name = "legacyFormID";
	dataType.name = "dataType";
	bodyContext.name = "bodyContext";
	isTempSaveBtn.name = "isTempSaveBtn";
		    
	key.value = sKey;
	mode.value = "DRAFT";
	logonId.value = sLogonId;
	subject.value = sSubject;
	legacyFormID.value = sLegacyFormID;
	dataType.value = sDataType;
	bodyContext.value = JSON.stringify(sBodyContext);
	isTempSaveBtn.value = "N";
		    
	form.appendChild(key);
	form.appendChild(mode);
	form.appendChild(logonId);
	form.appendChild(subject);
	form.appendChild(legacyFormID);
	form.appendChild(dataType);
	form.appendChild(bodyContext);
	form.appendChild(isTempSaveBtn);

	document.body.appendChild(form);
	
    window.open("", "form", "toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=1,width="+(window.screen.width - 100)+",height="+(window.screen.height - 100));
	form.submit();
}

var commonWritePopupOnload;
function callAutoDraft(expAppObj, htmlBody, expAppId, requestType) {	
	commentPopupTitle = Common.getDic("btn_apv_draft");
    commentPopupButtonID = "btDraft";
    commentPopupReturnValue = false;
    
    commonWritePopupOnload = function(){ 		
    	//ToggleLoadingImage();
    		    		
		var sKey = expAppId;
		var sSubject = expAppObj.ApplicationTitle;
		var sLogonId = sessionObj["USERID"];
		var sDeptId = sessionObj["DEPTID"];
		var sLegacyFormID = accComm[requestType].pageExpenceFormInfo.ApprovalFormInfo;
		if(sLegacyFormID == undefined) {
			sLegacyFormID = Common.getBaseConfig("LegacyFormIDForEAccount");
		}
		var sDataType = "ALL"; //HTML, JSON, ALL
		var now = new Date().format("yyyy-MM-dd hh:mm:ss");
		var sBodyContext = {
			LegacyFormID : sLegacyFormID,
			ERPKey : sKey,
			HTMLBody : htmlBody,
			JSONBody : expAppObj,
			InitiatedDate : now,
			InitiatorCodeDisplay : sessionObj["UR_Code"],
			InitiatorDisplay : sessionObj["UR_Name"],
			InitiatorOUDisplay : sessionObj["GR_Name"]
		}; 
		
		var signImage = getUserSignInfo(sLogonId);
		
		var jsonApv = $.parseJSON(accountCtrl.getInfo("APVLIST_").val());
		var eml = $$(jsonApv).find("steps>division[divisiontype='send']>step>ou>person>taskinfo[kind='charge']");
		/* 엔진에서 처리하도록 변경
		if (document.getElementById("ACTIONCOMMENT").value != "") {
			//결재선에 <comment> 추가 후 의견 저장
			var oComment = { "comment" : {"#text" : document.getElementById("ACTIONCOMMENT").value} } ;
			var oCommentNode = oComment.comment;
            if (eml.length > 0) {
            	var emlComment = $$(eml).find("comment");
            	if ($$(emlComment).length > 0) {
            		$$(emlComment).remove();
            	}
            	$$(eml).append("comment", oCommentNode);
            }
            accountCtrl.getInfo("APVLIST_").val(JSON.stringify($$(jsonApv).concat().eq(0).json()));
		}
		*/
        if(signImage != ""){
        	//결재선에 기안자의 signimage 정보 저장
        	$$(eml).attr("customattribute1", signImage);
            accountCtrl.getInfo("APVLIST_").val(JSON.stringify($$(jsonApv).concat().eq(0).json()));
        }
		
		var apvLine = accountCtrl.getInfo("APVLIST_").val();

		var formData = new FormData();
		formData.append("key", sKey);
		formData.append("subject", sSubject);
		formData.append("logonId", sLogonId);
		formData.append("deptId", sDeptId);
		formData.append("legacyFormID", sLegacyFormID);
		formData.append("formID", getInfo("FormID"));
		formData.append("apvline", apvLine);
		formData.append("bodyContext", JSON.stringify(sBodyContext));
		formData.append("scChgrValue", expAppObj.ChargeJob);
		formData.append("attachFile[]", null);
		formData.append("actionComment", document.getElementById("ACTIONCOMMENT").value);
		formData.append("signImage", signImage);
		formData.append("g_authKey", _g_authKey || "");
		formData.append("g_password", _g_password || "");

		$.ajax({
			type:"POST",
			url:"/approval/legacy/draftForAccount.do",
			contentType: false,
			processData: false,
			async:false,
			data:formData,
			success:function (data) {
				if(data.status == "SUCCESS") {
					Common.Inform(Common.getDic("ACC_msg_draftComplete"), "Information Dialog", function(result) { //기안이 완료되었습니다.
						//ToggleLoadingImage();
						//탭 닫기
						$("#"+nowAjaxID+"TabDiv, #"+nowAjaxID+"TabAMoreItem").find("a[name=tabDivDeleteA], [name=tabAMoreItemDeleteA]").trigger('click');
						setAccountDocreadCount();
					});
				} else {
					//ToggleLoadingImage();
					Common.Error(data.message);							
				}
			},
			error:function (error){
				//ToggleLoadingImage();
				Common.Error(Common.getDic("ACC_msg_error")); //오류가 발생하였습니다. 관리자에게 문의바랍니다.
			}
	    });
	};

	setTimeout('Common.open("","CommentWritePop",Common.getDic("lbl_apv_comment_write"),"/approval/CommentWrite.do","540px","305px","iframe",true,null,null,true);', 500);
}

function callChangeBodyContext(expAppObj, htmlBody, requestType) {
	var sLegacyFormID = accComm[requestType].pageExpenceFormInfo.ApprovalFormInfo;
	if(sLegacyFormID == undefined) {
		sLegacyFormID = Common.getBaseConfig("LegacyFormIDForEAccount");
	}
	var sKey = expAppObj.ExpenceApplicationID;
	var sProcessID = expAppObj.ProcessID;
	var sUserCode = sessionObj["UR_Code"];
	var sBodyContext = {
		LegacyFormID : sLegacyFormID,
		ERPKey : sKey,
		HTMLBody : htmlBody,
		JSONBody : expAppObj
	};

	var formData = new FormData();
	formData.append("processID", sProcessID);
	formData.append("userCode", sUserCode);
	formData.append("bodyContext", JSON.stringify(sBodyContext));

	$.ajax({
		type:"POST",
		url:"/approval/legacy/changeBodyContext.do",
		contentType: false,
		processData: false,
		data:formData,
		success:function (data) {
			Common.Inform(Common.getDic("ACC_msg_editComplete"), "Information Dialog", function(result) { //수정이 완료되었습니다.
				//탭 닫기
				$("#"+nowAjaxID+"TabDiv").find("a[name=tabDivDeleteA]").trigger('click');
			});
		},
		error:function (error){
			Common.Error(Common.getDic("ACC_msg_error")); //오류가 발생하였습니다. 관리자에게 문의바랍니다.
		}
	});
}

function getUserSignInfo(usercode){
	var retVal = "";
	
	$.ajax({
	    url: "/approval/user/getUserSignInfo.do",
	    type: "POST",
	    data: {
			"UserCode" : usercode
		},
		async:false,
	    success: function (res) {
	    	if(res.status == 'SUCCESS'){
	    		retVal = res.data;
	    	} else if(res.status == 'FAIL'){
	    		Common.Error(res.message);
	    	}
        },
        error:function(response, status, error){
			CFN_ErrorAjax("getUserSignInfo.do", response, status, error);
		}
	});
	
	return retVal;
}

//로딩이미지 토글하기
function ToggleLoadingImage(self) {
	var divLoading;
	var overlay;
	if(self) { //팝업창 - 자기자신
		divLoading = $('#divLoading');
		overlay = $('#loading_overlay');
	} else if(opener == null) { //바닥창
		divLoading = accountCtrl.getInfo('divLoading');
		overlay = accountCtrl.getInfo('loading_overlay');
	} else { //팝업창 - 부모
		divLoading = opener.accountCtrl.getInfo('divLoading');
		overlay = opener.accountCtrl.getInfo('loading_overlay');
    }
	
    if (divLoading.is(':hidden')) {
    	overlay.show();
    	divLoading.show();
    }
    else {
        overlay.hide();
    	divLoading.hide();
    }
}

var gReqUserCode = "";
var gMode = "";
var gSubkind = "";
var gLoct = "";
var gGloct = "";

function initBtn(RegisterID) {
	//formData : mode, loct, gloct, Subkind, UserCode, reqUserCode, ExtInfo, SchemaContext
	var mode = getInfo("Request.mode");
	var loct = getInfo("Request.loct");
	var gloct = getInfo("Request.gloct");
	var Subkind = getInfo("ProcessInfo.SubKind");
	var UserCode = getInfo("ProcessInfo.UserCode");
	var reqUserCode = getInfo("ProcessInfo.UserCode");
	var extInfo = formJson.ExtInfo;
	var SchemaContext = formJson.SchemaContext;
	
    var usid = Common.getSession("USERID");
	
	gMode = mode;
	gReqUserCode = reqUserCode;
	gSubkind = Subkind;
	gLoct = loct;
	gGloct = gloct;
	
    /*if (ExtInfo.UseDocPopupBtn == "Y") {
    	document.getElementById("btDocPopup").style.display = "";
    }*/
    
    var strRecDept = SchemaContext == null ? "none" : SchemaContext.scIPub.isUse == "Y" ? SchemaContext.scDeployBtn.isUse : "none";
    var strPrint = "none";
    //document.getElementById("chk_urgent").disabled = true; 
    //document.getElementById("chk_secrecy").disabled = true;

    switch (loct) {
        case "PROCESS":
        case "COMPLETE":
        case "CANCEL":
        case "JOBDUTY":
        case "REVIEW":
        case "REJECT":
            displayBtn("none", "none", "none", "none", "", "none", "none", "none", "none", "none", "none", "none", "none", loct == "COMPLETE" ? "" : "none", "none", "none", "");
            strPrint = "";
            document.getElementById("btPrint").style.display = strPrint; //출력
            break;
        case "DRAFT":
        case "PREDRAFT":
        case "TEMPSAVE":
            displayBtn("", "none", "none", "none", "", strRecDept, "none", "none", "none", "", "none", "", "", "none", "none", "", "");
            /*if (ExtInfo.UseApproveSecret == "Y") {
                document.getElementById("chk_secrecy").checked = true;
                document.getElementById("chk_secrecy").value = "1";
                document.getElementById("chk_secrecy").disabled = true;
            } else {
                document.getElementById("chk_secrecy").disabled = false;
            }
            document.getElementById("chk_urgent").disabled = false;*/
            break;
        case "REDRAFT":
        case "SHARER":
        case "APPROVAL":
            switch (mode) {
                case "SHARER":
                case "APPROVAL": //일반결재
                    displayBtn("none", "none", "none", "none", "", strRecDept, "", "none", "none", "none", "", "none", "none", "none", "none", "none", ""); //모든 결재자 첨부파일 추가
                    break;
                case "AUDIT": //감사
                case "PCONSULT": //개인합의				 
                    displayBtn("none", "none", "none", "none", "", "none", "", "none", "none", "none", "", "none", "none", "", "", "none", "");
                    break;
                case "RECAPPROVAL": //수신결재
                    displayBtn("none", "none", "none", "none", "none", "none", "", "none", "", "none", "", "none", "none", "none", "none", "none", ""); //모든 결재자 첨부파일 추가
                    break;
                case "SUBAPPROVAL": //부서합의내결재
                    displayBtn("none", "none", "none", "none", "none", "none", "", "none", "", "none", "", "none", "none", "", "", "none", ""); break;
                case "DEPART": //부서
                    break;
                case "CHARGE": //담당자				 
                    displayBtn("none", "none", "none", "none", "none", "none", "", "none", "none", "none", "", "none", "none", "", "", "none", ""); break;
                case "REDRAFT": //재기안
                    var sdisplay = "";
                    var sAttDisplay = "";
                    if (Subkind == "T008") {
                        displayBtn("none", "none", "none", "none", "", "none", "", "none", "none", "none", "", ((SchemaContext != null && SchemaContext.scCHBis.isUse == "Y") ? "" : "none"), "none", "none", "none", "", "");
                    } else {
                        sAttDisplay = "";
                        //문서관리자 권한 설정
                        if (SchemaContext != null && SchemaContext.scRec.isUse == "Y") { //접수
                            sdisplay = "none";
                            sAttDisplay = "none";
                            
                            if (reqUserCode == UserCode) {
                                document.getElementById("btRec").style.display = "";
                                document.getElementById("btReject").style.display = "";
                                
                                var m_evalJSON_receive = $.parseJSON(document.getElementById("APVLIST").value);
                                var elmRoot_receive = $$(m_evalJSON_receive).find("steps");
                                var elmRouCount_receive = $$(elmRoot_receive).find("division[divisiontype='receive'][oucode='" + getInfo("AppInfo.dpid_apv") + "']>ou>person>taskinfo[kind != 'charge']").length;
                                if (elmRouCount_receive > 0) {
                                    document.getElementById("btRec").style.display = "none";
                                }
                            } else {
                                document.getElementById("btRec").style.display = "none";
                            }
                        }
                        if (SchemaContext != null && SchemaContext.scRecBtn.isUse == "Y") { //담당자
                        	sdisplay = ""; 
                        	sAttDisplay = ""; 
                        	document.getElementById("btCharge").style.display = ""; 
                        }
                        if (loct == "REDRAFT" && mode == "REDRAFT") {//신청서 수신함 조회 시
                            displayBtn("none", "none", "none", "none", "none", "none", "", "none", "", "none", "", "none", "none", "none", "none", "", ""); //모든 결재자 첨부파일 추가					

                            {   //수신함 편집 버튼 클릭시 재기안 버튼 처리
                            	var m_evalJSON_receive = $.parseJSON(document.getElementById("APVLIST").value);
                                var elmRoot_receive = $$(m_evalJSON_receive).find("steps");
                                var elmRouCount_receive = $$(elmRoot_receive).find("division[divisiontype='receive'][oucode='" + getInfo("AppInfo.dpid_apv") + "']>ou>person>taskinfo[kind != 'charge']").length;
                                if (elmRouCount_receive > 0) {
                                    document.getElementById("btDeptDraft").style.display = "";
                                }
                            }
                            //문서관리자 권한 설정
                            if (SchemaContext != null && SchemaContext.scRecBtn.isUse == "Y") {
                            	document.getElementById("btCharge").style.display = "";
                            }
                            document.getElementById("btLine").style.display = "";
                        } else {
                            displayBtn("none", "none", "none", "none", "none", "none", "none", "none", sdisplay, "none", "none", sAttDisplay, "none", "", "", "", "");
                        }
                    }
                    break;
            }

            //확인결재추가
            if (Subkind == "T019") {
            	//document.getElementById("btModify").style.display = "none";
            }
            
            //후결추가
            if (Subkind == "T005") {
                document.getElementById("btHold").style.display = "none"; 
                //document.getElementById("btRejectedto").style.display = "none"; 
                //document.getElementById("btForward").style.display = "none";
                //document.getElementById("btModify").style.display = "none";
            }
            break;
    }
    /*if (SchemaContext.scSecrecy.isUse) { 
    	document.getElementById("secrecy").style.display = ""; 
    }*/
    
    if (loct == "MONITOR" || loct == "PREAPPROVAL" || loct == "PROCESS" || loct == "COMPLETE" && mode != "REJECT") {
        if (loct == "PROCESS" && (mode == "PROCESS" || mode == "PCONSULT" || mode == "RECAPPROVAL" || mode == "SUBAPPROVAL" || mode == "AUDIT") && RegisterID == usid && Subkind == "T006") {
        	var m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
            var elmRoot = $(m_evalJSON).find("steps");
            var elmList = $$(elmRoot).find("division>step>ou>person").has("taskinfo[kind!='charge'])");
            var strDate;

            //$$(m_evalJSON).find("division>step>ou>person").has("taskinfo[kind!='charge']").each(function (i, elm) {
			$$(m_evalJSON).find("division[divisiontype='send']:has(taskinfo[status='pending'])>step>ou>person").concat().each(function (i, elm) {
                if(i > 0){
					var elmTaskInfo = $$(elm).find("taskinfo");
	                if ($$(elmTaskInfo).attr("datecompleted") != null) {
	                    strDate = $$(elmTaskInfo).attr("datecompleted");
	                }
				}
            });

            //사용자 문서 조회 및 수정
            //관리자 모드가 아닐때
            if (strDate == null) {
                if (gloct != "DEPART") {					//부서진행함 - 조건 없이 실행하던걸 if추가하여 안에 넣음
                    document.getElementById("btWithdraw").style.display = ""; //회수
                }

                //수신처 담당자가 pending 상태일 때는 회수 안됨,수신처 수신함에 pending 일 경우 회수 안됨
                elmList = $$(m_evalJSON).find("division").has("taskinfo[status='pending']").find("[divisiontype='receive'] > step > ou");

                if (elmList.length > 0) {
                    document.getElementById("btWithdraw").style.display = "none"; //회수
                }

            } else if (strDate != null && SchemaContext != null && SchemaContext.scDraftCancel != null && SchemaContext.scDraftCancel.isUse == "Y") {
                if ($$(m_evalJSON).find("division[divisiontype='receive']>step>ou>person[code='" + usid + "']").has("taskinfo[kind='charge']").concat().length == 0) {
                    document.getElementById("btAbort").style.display = "";		 //진행 중 문서도 취소가 됨
                }
            }
        }
    }
    
    // 수신처 담당자일 경우에만 재기안회수 버튼 활성화
    if (Subkind == "T006" && loct == "PROCESS" && mode == "RECAPPROVAL") {
    	var m_evalJSON = $.parseJSON(document.getElementById("APVLIST").value);
    	
    	var elmRoot = $$(m_evalJSON).find("steps");
        var elmList = $$(elmRoot).find("division[divisiontype='receive']").has("taskinfo[status='pending']").find(">step>ou>person").has("taskinfo[kind='charge']");

        if (elmList.length > 0) {
            if ($$(elmList).attr("code") == getInfo("AppInfo.usid")) {
                document.getElementById("btRejectedtoDept").style.display = "";
            }
        }
    }
    
    if (CFN_GetQueryString("bserial") == "true") {
    	$("#btHold").hide();
    	$("#btLine").hide();
    }
    
    // 읽기/쓰기모드 버튼제어
    if(getInfo("Request.templatemode") == "Read"){
    }else{
    	$("#btHold,#btForward,#btPrint").hide();
    }
    
}
function displayBtn(sDraft, schangeSave, sDoc, sPost, sLine, sRecDept, sAction, sDeptDraft, sDeptLine, sSave, sMail, sAttach, sPreview, sCommand, sRec, sTempMemo, sInfo) {
    document.getElementById("btLine").style.display = sLine;//"결재선관리"
    //document.getElementById("btRecDept").style.display = sRecDept;//"수신처지정"
    document.getElementById("btDeptDraft").style.display = sDeptDraft; //"재기안"
    //document.getElementById("btDeptLine").style.display = sDeptLine; //"내부결재선관리"
    //document.getElementById("btSave").style.display = "none"; //"임시저장"
    //document.getElementById("btPreView").style.display = "none";//"미리보기"

    /*//기밀문서 권한 지정
    if (getInfo("ProcessInfo.ProcessDescription.IsSecureDoc") == "Y") {
        document.getElementById("chk_secrecy").checked = true;
    }

    document.getElementById("urgent").style.display = "";//긴급결재 기안시 지정
    if (getInfo("ProcessInfo.ProcessDescription.Priority") == "5") document.getElementById("chk_urgent").checked = true;	//긴급결재 기안시 지정
    */
    
    var useHold = Common.getBaseConfig("useHold");
    var usid = Common.getSession("USERID");
    
    if (sAction == "")
    {
        var bReviewr = fn_GetReview(usid);
        if (gMode == "REDRAFT" || gMode == "SUBREDRAFT") {
        	if (gSubkind == "T008") { //담당자 재기안 경우 결재버튼 활성화
                document.getElementById("btApproved").style.display = "";
                if (!bReviewr) document.getElementById("btReject").style.display = "";
            }
        } else {
            //확인결재추가
            if (gSubkind == "T019" || gSubkind == "T005" || gSubkind == "T020") {//확인결재
            	document.getElementById("btApproved").text = Common.getDic("lbl_apv_Confirm");
                document.getElementById("btApproved").style.display = "";
            } else {
                document.getElementById("btApproved").style.display = "";
                if (!fn_GetReview(usid)) document.getElementById("btReject").style.display = "";
            }
        }
        switch (gMode) {
            case "AUDIT":
                if (useHold == "Y" && gReqUserCode == usid) { document.getElementById("btHold").style.display = ""; }
                break;
            case "PCONSULT":
                if (gSubkind == "T009") {
                	document.getElementById("btApproved").text = Common.getDic("lbl_apv_agree");
                    document.getElementById("btReject").text = Common.getDic("lbl_apv_disagree");
                }
            case "SUBAPPROVAL": //합의부서내 결재
                if (useHold == "Y" && gReqUserCode == usid && gSubkind != "T019") { document.getElementById("btHold").style.display = ""; }
                break;
            case "RECAPPROVAL": //수신부서내 결재
            case "APPROVAL":
                if (useHold == "Y" && gReqUserCode == usid && gSubkind != "T019") { if (!bReviewr) document.getElementById("btHold").style.display = ""; }
                break;
            case "CHARGE":
                break;
            case "REDRAFT":
                if (useHold == "Y" && gSubkind == "T008" && gLoct == "APPROVAL" && gGloct == "JOBFUNCTION") { document.getElementById("btHold").style.display = ""; }
                break;
        }
    }
    
    // [20-03-23] 후결인 경우 [확인] 버튼 활성화 되도록 임시조치
    /*if(gSubkind == "T005" && formJson.mode == "APPROVAL" && formJson.gloct == "APPROVAL"
    	&& formJson.taskID != "") {
    	document.getElementById("btApproved").text = Common.getDic("lbl_apv_Confirm");
        document.getElementById("btApproved").style.display = "";
    }*/
}

//후결여부 체크
function fn_GetReview(usid) {	
	var m_apvJSON = $.parseJSON(document.getElementById("APVLIST").value);
    var oReviewNode = $$(m_apvJSON).find("steps>division>step>ou>person").has("taskinfo[kind='review'][status='pending'])");
    if (oReviewNode.length != 0) {
        if (usid == $(oReviewNode).attr("code")) {
            return true;
        }
    }
    return false;
}

//보류 시 알림 발송 함수
function sendReservedMessage(res, apvList, Subject, RegisterID, FormInstID, FormName){
	if(res.status == "SUCCESS"){
		var MessageInfo = new Array();
		var ApproveCode = $$(apvList).find("step>ou").concat().has("taskinfo[result=reserved]").find("person").attr("code");
		
		$$(apvList).find("step>ou").concat().find("taskinfo[result=pending],[result=completed]").concat().each(function(i, elm){
			var messageInfoObj = {};
			
			$$(messageInfoObj).attr("UserId", $$(elm).parent().attr("code"));
			$$(messageInfoObj).attr("Subject", Subject);
			$$(messageInfoObj).attr("Initiator", RegisterID);
			$$(messageInfoObj).attr("Status", "HOLD");
			$$(messageInfoObj).attr("ProcessId", $$(elm).parent().parent().parent().parent().attr("processID"));
			$$(messageInfoObj).attr("WorkitemId", $$(elm).parent().parent().attr("wiid"));
			$$(messageInfoObj).attr("FormInstId", FormInstID);
			$$(messageInfoObj).attr("FormName", FormName); 
			$$(messageInfoObj).attr("Type", "UR");
			
			$$(messageInfoObj).attr("ApproveCode", ApproveCode);
			
			MessageInfo.push(messageInfoObj);
		});
		
		$.ajax({
	 		url:"/approval/legacy/setmessage.do",
	 		data: {
	 			"MessageInfo" : JSON.stringify(MessageInfo)
	 		},
	 		type:"post",
	 		dataType : "json",
	 		success:function (res) {
	 		},
	 		error:function(response, status, error){
	 			// 알림메일 발송 실패 시, 사용자한테 오류메세지 띄우지 않고 진행되도록 함.
				//CFN_ErrorAjax("legacy/setmessage.do", response, status, error);
			}	
	 	});
	}
}

function setSubjectHighlight(me) {

	//Form load 완료후 정상작동시 UnreadCount 갱신
	var openerObj;
	
	if(typeof opener != 'undefined' && opener != null){ //팝업 호출시 opener window 여부 확인
		openerObj = opener;
	}else if(typeof top != 'undefined' && top != null){ //미리보기시 top window 여부 확인
		openerObj = top;
	}else{
		return;
	}
	
	//페이지 갱신 method 확인
   	if(typeof openerObj.setAccountDocreadCount !== 'undefined' && typeof openerObj.setAccountDocreadCount === "function" && openerObj.setAccountDocreadCount != null){
   		openerObj.setAccountDocreadCount();

   		var parent_formSubject = ".taTit[onclick^=onClick][onclick*=Button][onclick*=\"" + getInfo("ProcessInfo.ProcessID") + "\"]";
    	
    	if(getInfo("Request.workitemID") != ""){
    		parent_formSubject += "[onclick*=\"" + getInfo("Request.workitemID") + "\"]";
    	}
    	if(getInfo("ProcessInfo.UserCode") != "" && getInfo("Request.gloct") != "TCINFO"){    
    	    parent_formSubject += "[onclick*=\"" + getInfo("ProcessInfo.UserCode") + "\"]";
    	}
    	
    	//단순히 인덱스로 구분하는 것이 아니라 제목으로 구분하고 css설정을 바꿔야 하기 때문에 regular expression을 이용하여 직접 접근 시도
	   	if(openerObj.$(parent_formSubject).css("font-weight") > 400){
	   		openerObj.$(parent_formSubject).css("font-weight", "400");
	   	}
   	}
}

function setInfoAll(pObj) {
	$.extend(pObj.SchemaContext.scChgr, {"value" : pObj.ChargeJob});	
	
	$.extend(pObj, {"FormInfo" : {
		"FormPrefix" : pObj.FormPrefix,
		"FormID" : pObj.FormID
	}});	

	$.extend(pObj, {"Request" : {
		"mode" : pObj.mode,
		"loct" : pObj.mode,
		"templatemode" : pObj.templatemode,
		"mobileyn" : "N"
	}});
	
	//연속결재시 Request.bserial값 필요
	if(getInfo("Request.bserial") == 'true') {
		pObj.Request.bserial = 'true';
	}
	
	// 사용자 세션정보 추가
	var AppInfo = {};
	AppInfo.usid = Common.getSession("USERID");
	AppInfo.usnm = Common.getSession("USERNAME");
	AppInfo.dpid = Common.getSession("DEPTID");
	AppInfo.dpnm = Common.getSession("DEPTNAME");
	AppInfo.dpid_apv = Common.getSession("ApprovalParentGR_Code");
	AppInfo.dpdn_apv = Common.getSession("ApprovalParentGR_Name");
	if(!AppInfo.dpdn_apv) AppInfo.dpdn_apv = Common.getSession("GR_MultiName");
	AppInfo.etnm = Common.getSession("DN_Name");
	AppInfo.etid = Common.getSession("DN_Code");
	AppInfo.ussip = Common.getSession("UR_Mail");
	AppInfo.sabun = Common.getSession("UR_EmpNo");
	AppInfo.uspc = Common.getSession("UR_JobPositionCode");
	AppInfo.uspn = Common.getSession("UR_JobPositionName");
	AppInfo.ustc = Common.getSession("UR_JobTitleCode");
	AppInfo.ustn = Common.getSession("UR_JobTitleName");
	AppInfo.uslc = Common.getSession("UR_JobLevelCode");
	AppInfo.usln = Common.getSession("UR_JobLevelName");
	AppInfo.grpath = Common.getSession("GR_GroupPath");
	AppInfo.grfullname = Common.getSession("GR_FullName");
	AppInfo.managercode = Common.getSession("UR_ManagerCode");
	AppInfo.managername = Common.getSession("UR_ManagerName");
	AppInfo.usismanager = Common.getSession("UR_IsManager");
	AppInfo.svdt = CFN_GetLocalCurrentDate();
	
	// GMT 기준시간 추가
	if(Common.getBaseConfig("useTimeZone") != "Y") {
		AppInfo["svdt_TimeZone"] = CFN_GetLocalCurrentDate();
	}
	else { // 타임존 사용하는 경우
		AppInfo["svdt_TimeZone"] = CFN_TransServerTime(CFN_GetLocalCurrentDate(), "", Common.getSession("UR_TimeZone"));
	}
	
	AppInfo.usit = ""; // 서명이미지
	
	AppInfo.usnm_multi = Common.getSession("UR_MultiName");
	AppInfo.uspn_multi = Common.getSession("UR_MultiJobPositionName");
	AppInfo.ustn_multi = Common.getSession("UR_MultiJobTitleName");
	AppInfo.usln_multi = Common.getSession("UR_MultiJobLevelName");
	AppInfo.dpnm_multi = Common.getSession("GR_MultiName");
	
	AppInfo.ustp = Common.getSession("PhoneNumber");
	AppInfo.usfx = Common.getSession("Fax");
	
	$.extend(pObj, {"AppInfo" : AppInfo});
	
	formJson = $.extend(formJson, pObj);
}

function getJFID() {
    var _return = "";
    if (getInfo("SchemaContext.scChgr.isUse") == "Y") {
        _return = getInfo("SchemaContext.scChgr.value");
    } else if (getInfo("SchemaContext.scChgrEnt.isUse") == "Y") {
        if (getInfo("SchemaContext.scChgrEnt.value") != "") {
            var oChgrEntV = $.parseJSON(getInfo("SchemaContext.scChgrEnt.value"));
            if ($$(oChgrEntV).attr("ENT_" + getInfo("AppInfo.etid")) != undefined) {
                _return = $$(oChgrEntV).attr("ENT_" + getInfo("AppInfo.etid"));
            }
        }
    } else if (getInfo("SchemaContext.scChgrReg.isUse") == "Y") {
        if (getInfo("SchemaContext.scChgrReg.value") != "") {
        	var oChgrRegV = $.parseJSON(getInfo("SchemaContext.scChgrReg.value"));
            if ($$(oChgrRegV).attr("REG_" + getInfo("AppInfo.regionid")) != undefined) {
                _return = $$(oChgrRegV).attr("REG_" + getInfo("AppInfo.regionid"));
            }
        }
    }

    return _return;
}

function getChargeOU() {
    var _return = "";
    if (getInfo("SchemaContext.scChgrOU.isUse") == "Y") {
		_return = chkAbsentGroup(getInfo("SchemaContext.scChgrOU.value"));
    	if (_return.indexOf('@@@') > -1) {
    		aChrgOU = _return.split('@@@');
    		_return = aChrgOU[0];
    		if (getInfo('Request.templatemode') == 'Write') alert(aChrgOU[1]);
    	}
    } else if (getInfo("SchemaContext.scChgrOUEnt.isUse") == "Y") {
        if (getInfo("SchemaContext.scChgrOUEnt.value") != "") {
            var sEtId = (document.getElementById("EntCode") == undefined) ? getInfo("FormInstanceInfo.EntCode") : document.getElementById("EntCode").value;
            var oChgrOUEntV = $.parseJSON(getInfo("SchemaContext.scChgrOUEnt.value"));
            if ($$(oChgrOUEntV).find("ENT_" + sEtId + " > item").length > 0) {
            	$$(oChgrOUEntV).find("ENT_" + sEtId + ">item").concat().each(function (i, element) {
            		if (i > 0) _return += "^";
            		_return += $$(element).attr("AN") + "@" + $$(element).attr("DN");
            	});
            }
            
        }
    } else if (getInfo("SchemaContext.scChgrOUReg.isUse") == "Y") {
        if (getInfo("SchemaContext.scChgrOUReg.value") != "") {
        	var oChgrOURegV = $.parseJSON(getInfo("SchemaContext.scChgrOUReg.value"));
            if ($(oChgrOURegV).find("REG_" + getInfo("AppInfo.regionid") + " > items > item").length > 0) {
                $(oChgrOURegV).find("REG_" + getInfo("AppInfo.regionid") + " > items > item").each(function (i, element) {
                    if (i > 0) _return += "^";
                    _return += $(element).find("AN").text() + "@" + $(element).find("DN").text();
                });
            }
        }
    }
    return _return;
}
function chkAbsentGroup(scGroups) {
	var resultGroup = "";
	var aResultGroup = []; //사용부서
	var aExceptGroup = []; //제외부서
	var aGroup = scGroups.split("^"); //부서
	var aGroupInfo = []; //부서정보
	
	//담당부서 객체배열 생성
	aGroup.forEach(function(sGroup) {
		var oInfo = {
				"GroupCode" : sGroup.split("@")[0],
				"GroupMultiName" : sGroup.split("@")[1]
		};
		aGroupInfo.push(oInfo);
	});
	
	if (aGroupInfo.length > 0) {
		var existGroups = chkAbsentGroupCall(aGroupInfo.map(g => g.GroupCode).join(';'));
		var aChkGroupCode = existGroups.map(g => g.GroupCode);
	    		
		$(aGroupInfo).each(function (idx, oInfo) {
			if (aChkGroupCode.includes(oInfo.GroupCode)) {
				var sGroup = oInfo.GroupCode + "@" + oInfo.GroupMultiName;
				aResultGroup.push(sGroup);
				return true;
			}
			aExceptGroup.push(CFN_GetDicInfo(oInfo.GroupMultiName));
		});
		
		resultGroup = aResultGroup.join('^');
			
		//제외부서 alert
		if(aExceptGroup.length > 0) {
			var msg = Common.getDic("msg_apv_chkAbsentGroup") + '\n\n';
			msg += Common.getDic("msg_apv_absentGroup") + " : " + aExceptGroup.join(', ');
			resultGroup += "@@@" + msg;
		}
	}
	
	return resultGroup;
}
// pGroups : existGroupCode;noneGroupcode;existGroupCode
// return : [{GroupCode:"existGroupCode..",MultiDisplayName:"name..."},{GroupCode:"existGroupCode..",MultiDisplayName:"name..."}]
function chkAbsentGroupCall(pGroups) {
	var rtnGroups = [];
	
	if(pGroups){
		$.ajax({
			type : "POST",
			url : "/approval/apvline/checkAbsentGroup.do",
			async : false,
			data : {
				"groups" : pGroups
			},
			success : function(data) {
				rtnGroups = data.list;
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("/approval/apvline/checkAbsentGroup.do", response, status, error);
			}
		});
	}
	
	return rtnGroups;
}

function setDeleteMarkingRejectList(WorkItemArchiveIDs) {
	$.ajax({
		url:"/approval/deleteTempSaveList.do",
		type:"post",
		data:{
				"FormInstId":"",
				"FormInstBoxId":"",
				"WorkItemId":WorkItemArchiveIDs,
				"type":"REJECT"
		},
		async:false,
		success:function (res) {
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/deleteTempSaveList.do", response, status, error);
		}
	});
}

function getApvList(strApv, reqMode) { //APVLIST_ , APVLIST
	var jsonApv = $.parseJSON(strApv);
	
    //결재선 임시 저장 관련 수정 - 기안자만 있는 경우 결재선을 넘기지 않는다.
    // 회수 및 기안취소 포함
    if (reqMode == "TEMPSAVE" || reqMode == "WITHDRAW" || reqMode == "ABORT") {
        var oFirstNodeList = $$(jsonApv).find("steps>division>step>ou>person");
        //기안자만 있는 경우 초기화  시키는데, 그럴경우 추가된 참조자도 사라짐.*/
        var oCurrentDivNode = $$(jsonApv).find("steps>division[divisiontype='send']");
        var oChargeNode = $$(oCurrentDivNode).find("step").has("ou>person>taskinfo[kind='charge']");
        
        if (oChargeNode.length != 0)
        	$$(oCurrentDivNode).find("step").has("ou>person>taskinfo[kind='charge']").concat().eq(0).remove();
        
        var oCurrentDivTaskinfo = $$(oCurrentDivNode).find("taskinfo");
        $$(oCurrentDivTaskinfo).attr("status", "inactive");
        $$(oCurrentDivTaskinfo).attr("result", "inactive");
        
        try { $$(oCurrentDivTaskinfo).remove("datereceived"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivTaskinfo).remove("datecompleted"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivTaskinfo).remove("customattribute1"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivTaskinfo).remove("wiid"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivTaskinfo).remove("mobileType"); } catch (e) { coviCmn.traceLog(e); }
        try { $$(oCurrentDivNode).find("step").concat().find("person").concat().find("taskinfo>comment").remove(); } catch (e) { coviCmn.traceLog(e); }
        
        $$(oCurrentDivNode).find("step").concat().each(function(i, elm){
        	if ($$(elm).attr("unittype") == "ou") {
                var oOU = $$(elm).find("ou");
                $$(oOU).concat().each(function (i, ouNode) {
                    $$(ouNode).children().remove();
                	
                    var newOuTaskinfo = {};
                    
                    if ($$(elm).attr("routetype") == "consult") { $$(newOuTaskinfo).attr("kind", "consult"); }
                    else if ($$(elm).attr("routetype") == "assist") { $$(newOuTaskinfo).attr("kind", "assist"); }
                    else { $$(newOuTaskinfo).attr("kind", "normal"); }

                    $$(ouNode).append("taskinfo", newOuTaskinfo);
                });
                $$(elm).find("taskinfo").remove("datereceived");
            }
        	
        	var oOU = $$(elm).find("ou").concat();
        	
        	$$(oOU).concat().each(function(i, ouObj){
	        	// 엔진에서 작성되는 값들 지우기
		        $$(ouObj).remove("pfid");
		        $$(ouObj).remove("taskid");
		        $$(ouObj).remove("widescid");
		        $$(ouObj).remove("wiid");
		
		        //division/step/ou/taskinfo
		        var oOUTaskinfo = $$(ouObj).find("taskinfo");
		        if ($$(oOUTaskinfo).length != 0) {
		            $$(oOUTaskinfo).attr("status", "inactive");
		            $$(oOUTaskinfo).attr("result", "inactive");
		            $(oOUTaskinfo).attr("datereceived", "");
		
		            if ($$(oOUTaskinfo).attr("datecompleted")) { $$(oOUTaskinfo).remove("datecompleted"); }
		            if ($$(oOUTaskinfo).attr("wiid")) { $$(oOUTaskinfo).remove("wiid"); }
		
		            if ($$(oOUTaskinfo).find("comment").concat().eq(0)) { $$(oOUTaskinfo).find("comment").remove(); }
		            if ($$(oOUTaskinfo).find("comment_fileinfo").concat().eq(0)) { $$(oOUTaskinfo).find("comment_fileinfo").remove(); }
		            
		            $$(oOUTaskinfo).remove("datereceived");
		        }
		        //division/step/person/taskinfo
		        var oPersonTaskinfo = $$(ouObj).find("person>taskinfo");
		        if ($$(oPersonTaskinfo).length != 0) {
		            $$(oPersonTaskinfo).attr("status", "inactive");
		            $$(oPersonTaskinfo).attr("result", "inactive");
		            if ($$(oPersonTaskinfo).attr("kind") == "charge") $$(oPersonTaskinfo).attr("datereceived", getInfo("AppInfo.svdt"));
		            else $$(oPersonTaskinfo).attr("datereceived", "");
		            
		            if ($$(oPersonTaskinfo).attr("datecompleted")) { $$(oPersonTaskinfo).remove("datecompleted"); }
		            if ($$(oPersonTaskinfo).attr("wiid")) { $$(oPersonTaskinfo).remove("wiid"); }
		            if ($$(oPersonTaskinfo).attr("customattribute1")) { $$(oPersonTaskinfo).remove("customattribute1"); }
		            if ($$(oPersonTaskinfo).attr("mobileType")) { $$(oPersonTaskinfo).remove("mobileType"); }
		
		            if ($$(oPersonTaskinfo).find("comment").concat().eq(0).json()) { $$(oPersonTaskinfo).find("comment").remove(); }
		            if ($$(oPersonTaskinfo).find("comment_fileinfo").concat().eq(0).json()) { $$(oPersonTaskinfo).find("comment_fileinfo").remove(); }
		        }
        	});
        });
        
        //참조 셋팅
        var oCcinfo = $$(jsonApv).find("steps>ccinfo");
        try {
        	if(oCcinfo.exist()){
	            $$(oCcinfo).concat().each(function (i, elm) {
	                $$(elm).attr("datereceived", "");
	            });
        	}
        } catch (e) { coviCmn.traceLog(e); }
    }
    return jsonApv;
}

function openFileList_comment(pObj, idx, pGubun){
	if(!axf.isEmpty($(pObj).parent().find('.file_box').html())){
		$(pObj).parent().find('.file_box').remove();
		return false;
	}
	$('.file_box').remove();
	
	var $file_box = $("<ul>", {"class":"file_box"}).append($("<li>", {"class":"boxPoint"}));	
	$file_box.append(
		g_commentAttachList[idx].map( function( item,idx ){ 
			return $("<li>").append(
				$("<a>", {"text":item.name}).data('item',item)
			)
		})
	).find('a').on('click',function(){ 
		var obj = $(this).data('item');
		Common.fileDownLoad(obj.id, obj.savedname, obj.FileToken);
	});	
	
	$(pObj).parent().append($file_box);
}

// 감사규칙 관련

//감사규칙 위반 내역 표시 (상단건수표시)
function displayAuditViolation(auditCntMap, AuditArea, isView, AuditReason) {		
	// 상단건수
	if(auditCntMap != null) {
		var cnt = 0;
		var sHtml = "<dl class='total_acooungting_dl'>&nbsp;<dt>" + Common.getDic("ACC_lbl_auditTarget") + " : </dt> ";
		$.each(auditCntMap, function(key, value){
			if(key.indexOf("Cnt") > 0) {
				if(value > 0) {
					if(cnt > 0) {
						sHtml += ", ";
					}
					sHtml += "<dd" + (isView ? " style='cursor:pointer;' onclick='displayAuditViolationColor(\""+key.replace("Cnt", "")+"\")'" : "") +">" + auditCntMap[key.replace("Cnt", "")+"RuleName"] + "</dd>";
					sHtml += " <dd>(" + value + ")</dd>";
					
					cnt++;
				}
			}
		});
		sHtml += "</dl>";
		
		// view 영역 > 위반사유 표시
		if(isView && AuditReason != null && AuditReason != "") {
			sHtml += "<dl class='total_acooungting_dl'>&nbsp;<dt>" + Common.getDic("ACC_lbl_violationReason") + " : " + AuditReason + "</dt> ";
		}
		
		if(cnt == 0) {
			sHtml = "";
		}
		
		if(AuditArea.toLowerCase().indexOf("view") < 0 && accountCtrl.getInfo(AuditArea).length > 0) {
			if(sHtml != "") {
				accountCtrl.getInfo(AuditArea).parent().show();
			} else {
				accountCtrl.getInfo(AuditArea).parent().hide();	
			}
			accountCtrl.getInfo(AuditArea).html(sHtml);
		} else {
			if(sHtml != "") {
				$("#"+AuditArea).parent().show();
			} else {
				$("#"+AuditArea).parent().hide();	
			}
			$("#"+AuditArea).html(sHtml);
		}
	}
}

var chkColorChange = {};
function displayAuditViolationColor(auditType) {
	
	auditType = auditType.toLowerCase();
	
	if(chkColorChange[auditType] == "Y") {
		chkColorChange[auditType] = "N";
	} else {
		chkColorChange[auditType] = "Y";
	}
	
	var auditEvid = CombineCostApplicationView.pageExpenceAppObj.auditEvidList;
	if(auditEvid != undefined && auditEvid.length > 0) {
		var styleMap = {
			"red" : "e_color01",
			"blue" : "e_color06",
			"yellow" : "e_color03",
			"orange" : "e_color02",
			"pink" : "e_color07",
			"lightblue" : "e_color05",
			"green" : "e_color04",
			"white" : ""
		};
		$(auditEvid).each(function(i, obj) {
			var color = obj[auditType+"Color"];
			var type = obj[auditType+"StdType"];
			if(color != "") {
				if(chkColorChange[auditType] != "Y") {
					color = "white";
				}
				/*
				if($("tr[name=evidItemAreaApv][listid="+obj.ExpenceApplicationListID+"]").find("td[stdtype="+type+"]").length > 0) {
					$("tr[name=evidItemAreaApv][listid="+obj.ExpenceApplicationListID+"]").find("td[stdtype="+type+"]").css("background-color", color);
				} else {
					$("tr[name=evidItemAreaApv][listid="+obj.ExpenceApplicationListID+"]").find("td").eq(0).css("background-color", color);
				}*/
				var className = styleMap[color] || '';
				$("tr[name=evidItemAreaApv][listid="+obj.ExpenceApplicationListID+"]").attr("class", className);
			}
		});
	}
}
//마감일자관리 - 기안통제여부
function checkDeadlineControl(pageExpenceAppEvidList, companyCode){
	var deadLine = {};
	var retVal = false; //true통제, false미통제
	$.ajax({
		url: "/account/deadline/getDeadlineInfo.do",
		type: "POST",
		data: {
			"companyCode" : companyCode
		},
		async: false,
		success: function(data) {
			if (data.status == "SUCCESS"){
				if(data.list.length > 0) { deadLine = data.list[0]; }
			} else {
				Common.Error(Common.getDic("ACC_msg_error")); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
				return false;
			}
		},
		error: function(error){
			Common.Error(Common.getDic("ACC_msg_error")); // 오류가 발생했습니다. 관리자에게 문의 바랍니다.
		}
	});
	//전체통제
	if (deadLine.Control == "All") {
		Common.Inform(Common.getDic("ACC_msg_controlOver")); // 현재 기안 통제상태로 기안이 불가합니다.
		retVal = true;
	//마감일자기준통제
	}else if (deadLine.Control == "Deadline") {
		//타임존 처리(한국시간 기준으로 통제) : 한국기준 YYYY-MM-DD 00:00:00 ~ YYYY-MM-DD 23:59:59 까지 기안가능
		var now = new Date(CFN_TransServerTime(CFN_GetLocalCurrentDate(), "", Common.getSession("UR_TimeZone")));
		var standardMonth = deadLine.StandardMonth;
		var nowMonth = now.getMonth() + 1;
		var deadlineStartDate = new Date(accComm.accFormatDate(deadLine.DeadlineStartDate));
		var deadlineEndDate = new Date(accComm.accFormatDate(deadLine.DeadlineFinishDate) + ' 23:59:59');
		
		for(var i = 0; i<pageExpenceAppEvidList.length; i++){
			var item = pageExpenceAppEvidList[i];
			var proofMonth = new Date(item.ProofDateStr).getMonth() + 1;
			//마감일자기준 - 전월 : 경비사용 월이 전월이아니거나 오늘날짜가 마감기간에 포함되지 않으면 기안통제
			if(standardMonth == '01') {
				if(proofMonth != nowMonth - 1  || (now < deadlineStartDate || now > deadlineEndDate)) {
					//경비마감일을 벗어난 항목이 있습니다
					//* 경비사용 기준월 : 전월
					//* n월 경비 신청가능일 : YYYY-MM-DD ~ YYYY-MM-DD
					var msg = Common.getDic("ACC_044") 
							+ "\n* 경비사용 기준월 : "  + (nowMonth - 1) + "월"
							+ "\n* "  + (nowMonth - 1) + "월 경비 신청가능일: " + deadLine.DeadlineStartDate + "~" + deadLine.DeadlineFinishDate; 
					Common.Inform(msg);
					retVal = true;
		   			break;
				}
			//마감일자기준 - 당월 : 경비사용 월이 당월이 아니거나 오늘날짜가 마감기간에 포함되지 않으면 기안통제
			}else if (standardMonth == '02'){
				if(proofMonth != nowMonth || (now < deadlineStartDate || now > deadlineEndDate)) {
					//경비마감일을 벗어난 항목이 있습니다
					//* 경비사용 기준월 : 당월
					//* n월 경비 신청가능일 : YYYY-MM-DD ~ YYYY-MM-DD
					var msg = Common.getDic("ACC_044") 
							+ "\n* 경비사용 기준월 : "  + nowMonth + "월"
							+ "\n* " + nowMonth + "월 경비 신청가능일: " + deadLine.DeadlineStartDate + "~" + deadLine.DeadlineFinishDate;  
					Common.Inform(msg);
					retVal = true;
		   			break;
				}
			}
		}
	}
	return retVal;
}
//감사규칙 validation check
function checkAuditRule(propertyOtherApv, expAppObj, htmlBody, expAppId, requestType, companyCode) {
	
	
	if(expAppObj.ApplicationType != "CO" && expAppObj.auditAppLimitList != null) {
			var auditInfoArr = accComm[requestType].pageExpenceFormInfo.AuditInfo;
			var auditInfo = [];
			if(auditInfoArr != undefined) {
				for(var i = 0; i < auditInfoArr.length; i++) {
					var info = auditInfoArr[i];
					if(info.DNCode == companyCode || info.DNCode == "ALL") {
						auditInfo = info.item;
					}
				}
			}
			
			var imps_msg = "";
			var warn_msg = "";
			for(var i = 0; i < expAppObj.auditAppLimitList.length; i++) { 
				//auditChkList : 감사규칙 위반한 증빙 목록 
				var chkItem = expAppObj.auditAppLimitList[i];
				for(var j = 0; j < auditInfo.length; j++) {
					var prefix = auditInfo[j];
					if(chkItem[prefix + "RuleCode"] == null || chkItem[prefix + "RuleCode"] == "") {
						continue;
					}
				
					var ruleName = chkItem[prefix + "RuleName"];
					var stdType = chkItem[prefix + "StdType"];
					var auditData = "";
					switch(stdType) {
					case "D": auditData = chkItem.ProofDateStr; break;
					case "T": auditData = chkItem.ProofTime; break;
					case "A": auditData = toAmtFormat(chkItem.AmountSumNum); break;
					}
			
					var ruleInfo = chkItem[prefix + "RuleInfo"];
					if(ruleInfo != null && ruleInfo != "") {
						if(ruleInfo.ControlLevel != null && ruleInfo.ControlLevel.length > 0) {	
							if(ruleInfo.ControlLevel[0] == "Impossible") {
								if(imps_msg == "") imps_msg += "----------------------------------------<br />";
								imps_msg += "[" + ruleName + "] " + auditData + "<br />";
							} else if(ruleInfo.ControlLevel[0] == "Warning") {
								if(warn_msg == "") warn_msg += "----------------------------------------<br />";
								warn_msg += "[" + ruleName + "] " + auditData + "<br />";
							}
						}
					}
				}
			}
			
			if(imps_msg != "") {
				imps_msg += "----------------------------------------<br />";
				imps_msg += "위와 같이 감사규칙 대상이 있습니다.<br />";
				imps_msg += "신청이 불가합니다.";
				
				Common.Warning(imps_msg);
			} else if(warn_msg != "") {
				warn_msg += "----------------------------------------<br />";
				warn_msg += "위와 같이 감사규칙 대상이 있습니다.<br />";
				warn_msg += "위 증빙을 포함하여 신청됩니다.";
				
				Common.Confirm(warn_msg, "Confirmation Dialog", function(result){
		       		if(result){
	       			callInputAuditReason(propertyOtherApv, expAppObj, htmlBody, expAppId, requestType);
		       		}
				});
			} else {
   			callInputAuditReason(propertyOtherApv, expAppObj, htmlBody, expAppId, requestType);
			}
		} else {
		callInputAuditReason(propertyOtherApv, expAppObj, htmlBody, expAppId, requestType);
	}
}

function openInvestStandardPopup() {
	var url =	"/account/investigation/InvestCrtrPop.do?popupName=InvestCrtr";
	Common.open("","",Common.getDic("ACC_lbl_investStandard"),url,"800px","410px","iframe",true,null,null,true);
}


//증빙 인쇄
function getEvidHTMLEAccount(evidList) {
	var corpCardHtml = "";
	var taxBillHtml = "";
	var receiptHtml = "";
	var etcEvidHtml = "";
	
	var corpCardList = [];
	var taxBillList = [];
	var receiptList = [];
	var etcEvidList = [];
	
	$(evidList).each(function(i, obj) {
	    if(obj.ProofCode == "CorpCard") {
	        corpCardList.push(obj);
	    } else if(obj.ProofCode == "TaxBill") { 
	    	taxBillList.push(obj);
	    } else if(obj.ProofCode == "Receipt") { 
	    	receiptList.push(obj);
	    } else if (obj.ProofCode == "EtcEvid") {
			etcEvidList.push(obj);
		}
	});
	
	$(corpCardList).each(function(i, obj) {
		if(i % 4 == 0) {
			corpCardHtml += "<div style='height: 100%;'>";
		}
		corpCardHtml += accComm.getCardReceiptInfo(obj.CardUID, 'print');
		if(i % 4 == 3) {
			corpCardHtml += "</div>";
		}
	});
	if(corpCardList.length % 4 != 0) {
		corpCardHtml += "</div>";
	}
	
	$(taxBillList).each(function(i, obj) {
		if(i % 2 == 0) {
			taxBillHtml += "<div style='height: 100%;'>";
		}
		taxBillHtml += accComm.getTaxInvoiceInfo(obj.TaxUID, 'print');
		if(i % 2 == 1) {
			taxBillHtml += "</div>";
		}
	});
	if(taxBillList.length % 2 != 0) {
		taxBillHtml += "</div>";
	}
	
	$(receiptList).each(function(i, obj) {
		if(i % 4 == 0) {
			receiptHtml += "<div style='height: 100%;'>";
		}
		receiptHtml += accComm.getReceiptInfo(obj.FullPath);
		if(i % 4 == 3) {
			receiptHtml += "</div>";
		}
	});
	if(receiptList.length % 4 != 0) {
		receiptHtml += "</div>";
	}
	
	var etcEvidNum = 0;
	$(etcEvidList).each(function(i, obj) {
		$(obj.fileInfoList).each(function(i, obj) {
			if (obj.SaveType != "IMAGE") {
				return true; // continue의 개념, 바로 다음 루프를 돌린다.
			}
			
			if(etcEvidNum % 4 == 0) {
				etcEvidHtml += "<div style='height: 100%;'>";
			}
			
			var pFilePath = obj.StorageFilePath.replace("{0}", obj.CompanyCode) + obj.FilePath + obj.SavedName;
			etcEvidHtml += '<img src="' + coviCmn.loadImage(pFilePath) + '" name="fileArea" alt="" style="width:300px; height:400px;">';
			
			if(etcEvidNum % 4 == 3) {
				etcEvidHtml += "</div>";
			}
			
			etcEvidNum += 1;
		});
	});
	if(etcEvidNum % 4 != 0) {
		etcEvidHtml += "</div>";
	}
	
	return corpCardHtml + taxBillHtml + receiptHtml + etcEvidHtml;
}

function attachFileDownLoadCall_comment(fileid, filename, filetoken) {
	Common.fileDownLoad(fileid, filename, filetoken);
}

function attachFilePreview(fileId, fileToken, extention) {
	accComm.accAttachFilePreview(fileId, fileToken, extention, 'comCostAppView_', 'View', true);
}

function alt(msg, _width, _height) {
    var _style = alt_div.style;
    msg = $(".acc_total_l").html();

    var divEl = $(".total_table");
    var divX = divEl.offset().left;
    var divY = divEl.offset().top;

    _style.left = (divX - 400) + "px";
    _style.top = (divY -30) + "px";
    
    if (msg != null) {
        alt_div.innerHTML = msg;
        _style.visibility = "visible";
        if (_width != null) {
            if (alt_div.offsetWidth > _width) {
                _style.width = _width;
            }
        }
        if (_height != null) {
            if (alt_div.offsetHeight > _height) {
                _style.height = _height;
            }
        }
    }
    else {
        _style.visibility = "hidden";
    }
}

function altOut() {
    var _style = alt_div.style;
    _style.visibility = "hidden";
}

function setDomainData() {
    /*자동 결재선 처리, 서버에서 진행됨*/
	
	/* 서버에서 만든 자동결재선 데이터 가져오기 처리 */
	var data = {};
	if(getInfo("WorkedAutoApprovalLine") != undefined)
		data = getInfo("WorkedAutoApprovalLine");
	/* 자동결재선 데이터를 파라미터로 넘김 */
	var domainData = receiveApvHTTP(data, getInfo("Request.mode"));
	$("#APVLIST").val(domainData);
}

function setApvList() {//대결일 경우 처리
    try {
        var jsonApv = $.parseJSON(getInfo("ApprovalLine"));

        if (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "PCONSULT" || getInfo("Request.mode") == "RECAPPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL" || getInfo("Request.mode") == "AUDIT" ) { //기안부서결재선 및 수신부서 결재선
            var oFirstNode; //step에서 taskinfo select로 변경

            if (getInfo("Request.mode") == "APPROVAL" || getInfo("Request.mode") == "SUBAPPROVAL") {
                oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[routetype='approve']>ou>person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'],step[routetype='approve']>ou>role:has(person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'])");
                
                if (getInfo("Request.mode") == "SUBAPPROVAL"  && oFirstNode.length == 0) {
                	oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[routetype!='approve']>ou>person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'], step[routetype!='approve']>ou>role:has(person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'])");
                }
                if (oFirstNode.length == 0) { //편집 후 결재 시 대결 오류로 인하여 소스 추가
                    oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[routetype='approve']>ou>person[code='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'][kind='substitute']");
                }
            }
            else if (getInfo("Request.mode") == "RECAPPROVAL") {
                oFirstNode = $$(jsonApv).find("steps>division[divisiontype='receive']>taskinfo[status=pending]").parent().find("step[routetype='approve']>ou>person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'],step[routetype='approve']>ou>role:has(person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'])");
                if (oFirstNode.length == 0) { //편집 후 결재 시 대결 오류로 인하여 소스 추가
                    oFirstNode = $$(jsonApv).find("steps>division[divisiontype='receive']>taskinfo[status=pending]").parent().find("step[routetype='approve']>ou>person[code='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'][kind='substitute']");
                }
            }
            else if (getInfo("Request.mode") == "PCONSULT") {
                oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step>ou>person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "']>taskinfo[status='pending'], step>ou>role>taskinfo:has(person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'])[status='pending']");
            } else if (getInfo("Request.mode") == "AUDIT") {
                oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[routetype='audit']>ou>person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'] > taskinfo[status='pending'],step[routetype='audit']>ou>role:has(person[code='" + getInfo("Request.userCode") + "'][code!='" + getInfo("AppInfo.usid") + "'])");
            } else {
                oFirstNode = $$(jsonApv).find("steps>division>taskinfo[status=pending]").parent().find("step[unittype='ou'][routetype='receive']>ou>person[code!='" + getInfo("AppInfo.usid") + "']>taskinfo[kind!='charge'][status='pending']");
            }
            if (oFirstNode.length != 0) {
            	Common.Warning(Common.getDic("msg_ApprovalDeputyWarning"));
            	
            	var elmOU; var elmPerson;
                switch (getInfo("Request.mode")) {
                    case "APPROVAL":
                    case "PCONSULT":
                    case "SUBAPPROVAL":
                    case "RECAPPROVAL":
                    case "AUDIT":
                        elmOU = $$(oFirstNode).parent().parent();
                        elmPerson = $$(oFirstNode).parent();
                        break;
                }
                var elmTaskInfo = $$(elmPerson).find("taskinfo");
                var skind = $$(elmTaskInfo).attr("kind");
                var sallottype = "serial";
                var elmStep = $$(elmOU).parent();
                try { if ($$(elmStep).attr("allottype") != null) sallottype = $$(elmStep).attr("allottype"); } catch (e) { coviCmn.traceLog(e); }
                //taskinfo kind에 따라 처리  일반결재 -> 대결, 대결->사용자만 변환, 전결->전결, 기존사용자는 결재안함으로
                // 전결을 유지하는 경우 원결재자가 완료함에서 문서 열람 불가함. 대결로 변경처리함.
                switch (skind) {
                    case "substitute": //대결
                        if (getInfo("Request.mode") == "APPROVAL") {
                            $$(elmOU).attr("code", getInfo("AppInfo.dpid_apv"));
                            $$(elmOU).attr("name", getInfo("AppInfo.dpdn_apv"));
                        }
                        $$(elmPerson).attr("code", getInfo("AppInfo.usid"));
                        $$(elmPerson).attr("name", getInfo("AppInfo.usnm_multi"));
                        $$(elmPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
                        $$(elmPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
                        $$(elmPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
                        $$(elmPerson).attr("oucode", getInfo("AppInfo.dpid"));
                        $$(elmPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
                        $$(elmPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
                        $$(elmTaskInfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        break;
                    case "consent": //합의 -> 후열
                    case "charge":  //담당 -> 후열
                    case "consult":
                    case "normal":  //일반결재 -> 후열
                    case "authorize"://전결 결재안함
                        $$(elmTaskInfo).attr("status", "inactive");
                        $$(elmTaskInfo).attr("result", "inactive");
                        $$(elmTaskInfo).attr("kind", "bypass");
                        $$(elmTaskInfo).remove("datereceived");
                        break;
                }
                if (skind == "authorize" || skind == "normal" || skind == "consent" || skind == "charge" || skind == "consult") {
                    var oStep = {};
                    var oOU = {};
                    var oPerson = {};
                    var oTaskinfo = {};
                    
                    $$(oTaskinfo).attr("status", "pending");
                    $$(oTaskinfo).attr("result", "pending");
                    //$$(oTaskinfo).attr("kind", (skind == "authorize") ? skind : "substitute");
                    $$(oTaskinfo).attr("kind", "substitute"); // 대결로 처리되는 경우 대결자 완료함에서 문서 열람이 가능해야 함!
                    $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                    
                    $$(oPerson).attr("code", getInfo("AppInfo.usid"));
                    $$(oPerson).attr("name", getInfo("AppInfo.usnm_multi"));
                    $$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
                    $$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
                    $$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
                    $$(oPerson).attr("oucode", getInfo("AppInfo.dpid"));
                    $$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
                    $$(oPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
                    
                    if(getInfo("Request.mode") == "SUBAPPROVAL") {
                    	$$(oPerson).attr("wiid", $$(elmPerson).attr("wiid"));
                    	$$(oPerson).attr("taskid", $$(elmPerson).attr("taskid"));
                    }
                    
                    $$(oPerson).append("taskinfo", oTaskinfo);
                    
                    $$(elmOU).append("person", oPerson);							// person이 object일 경우를 위해서 추가하여 배열로 만듬
                    
                    if(getInfo("Request.mode") == "SUBAPPROVAL") {
                    	// todo: person의 index 구하는 방법 변경할 수 있으면 다른방법으로 교체할 것
                    	$$(elmOU).find("person").json().splice(parseInt(oFirstNode.parent().path().substr(oFirstNode.parent().path().lastIndexOf("/")+8, 1)), 0, oPerson);
                    } else {
                    	$$(elmOU).find("person").json().splice(0, 0, oPerson);			// 다시 앞에 추가
                    }
                    $$(elmOU).find("person").concat().eq($$(elmOU).find("person").concat().length-1).remove();			// 배열로 만들기 위해서 추가했던 person을 지움
                    
                    if (skind == 'charge') {
                        oFirstNode = oStep;
                        
                        var oStep = {};
                        var oOU = {};
                        var oPerson = {};
                        var oTaskinfo = {};
                        
                        $$(oStep).attr("unittype", "person");
                        $$(oStep).attr("routetype", "approve");
                        $$(oStep).attr("name", Common.getDic("lbl_apv_writer"));
                        
                        $$(oOU).attr("code", getInfo("AppInfo.dpid_apv"));
                        $$(oOU).attr("name", getInfo("AppInfo.dpdn_apv"));
                        
                        $$(oPerson).attr("code", getInfo("AppInfo.usid"));
                        $$(oPerson).attr("name", getInfo("AppInfo.usnm_multi"));
                        $$(oPerson).attr("position", getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi"));
                        $$(oPerson).attr("title", getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi"));
                        $$(oPerson).attr("level", getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi"));
                        $$(oPerson).attr("oucode", getInfo("AppInfo.dpid"));
                        $$(oPerson).attr("ouname", getInfo("AppInfo.dpnm_multi"));
                        $$(oPerson).attr("sipaddress", getInfo("AppInfo.ussip"));
                        
                        $$(oTaskinfo).attr("status", "complete");
                        $$(oTaskinfo).attr("result", "complete");
                        $$(oTaskinfo).attr("kind", "charge");
                        $$(oTaskinfo).attr("datereceived", getInfo("AppInfo.svdt_TimeZone"));
                        $$(oTaskinfo).attr("datecompleted", getInfo("AppInfo.svdt_TimeZone"));
                        
                        $$(oPerson).append("taskinfo", oTaskinfo);
                        
                        $$(oOU).append("person", oPerson);
                        
                        $$(oStep).append("ou", oOU);
                        
                        $$(jsonApv).find("steps>division").append("step", oStep);
                        $$(jsonApv).find("steps>division>step").json().splice(0, 0, oStep);
                        $$(jsonApv).find("steps>division>step").concat().eq($$(jsonApv).find("steps>division>step").concat().length-1).remove();
                        
                    }
                }

                var oResult = $$(jsonApv).json();

                document.getElementById("APVLIST").value = JSON.stringify(oResult);
            }
            else {
                document.getElementById("APVLIST").value = getInfo("ApprovalLine");
            }
        }
        else {
            document.getElementById("APVLIST").value = getInfo("ApprovalLine");
        }
    }
    catch (e) {
        alert(e.message);
    }
}
