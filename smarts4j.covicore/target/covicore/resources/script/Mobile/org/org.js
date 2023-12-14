// TODO: 임시 작성함


/*!
 * 
 * 
 * SmartS4j / MobileOffice / 모바일 조직도 js 파일
 * 함수명 : mobile_org_...
 * 
 * 
 */


/*!
 * 
 * 페이지별 init 함수
 * 
 */
var lang = mobile_comm_getSession("lang"); //다국어

//조직도 목록 페이지
$(document).on('pageinit', '#org_list_page', function () {
	if($("#org_list_page").attr("IsLoad") != "Y"){
		$("#org_list_page").attr("IsLoad", "Y");
		
	}
	lang = mobile_comm_getSession("lang"); //다국어
	setTimeout("mobile_org_ListInit()",10);
});

//조직도 상세 페이지
$(document).on('pageinit', '#org_view_page', function () {
	lang = mobile_comm_getSession("lang"); //다국어
	if($("#org_view_page").attr("IsLoad") != "Y"){
		$("#org_view_page").attr("IsLoad", "Y");
		setTimeout("mobile_org_ViewInit()",10);	
	}	
});


/*!
 * 
 * 조직도 목록
 * 
 */


var _mobile_org = {
	Mode: 'View',	//조직도 open 모드 : View-일반뷰/Select-부서,부서원선택/SelectUser-부서원선택
	Multi: 'Y',		//선택 모드 시 다중 선택 가능 여부
	AddTo: '',		//게시-BoardWriteReadAuth/BoardWriteDetailAuth,
	UserCode: '',
	IsTeams: 'N'
};


function mobile_org_ListInit(){
	var sURL = $(location).attr("href");
	if(window.sessionStorage['mode'] != undefined && window.sessionStorage['mode'] == "Select") {
		sURL = "/covicore/mobile/org/list.do";
	}
	
	if (mobile_comm_getQueryStringForUrl(sURL, 'mode') != 'undefined' && mobile_comm_getQueryStringForUrl(sURL, 'mode') != '') {
		_mobile_org.Mode = mobile_comm_getQueryStringForUrl(sURL, 'mode');
    } else if (window.sessionStorage['mode'] != undefined && window.sessionStorage['mode'] != '') {
		_mobile_org.Mode = window.sessionStorage['mode'];
    } else {
    	_mobile_org.Mode = 'View';
    	//alert("여기잖아");
    	//_mobile_org.Mode = 'Select';
    }
	
	if (window.sessionStorage['multi'] != undefined && window.sessionStorage['multi'] != '') {
		_mobile_org.Multi = window.sessionStorage['multi'];
    } else {
    	_mobile_org.Multi = 'N';
    }
	
	if (mobile_comm_getQueryStringForUrl(sURL, 'addto') != 'undefined' && mobile_comm_getQueryStringForUrl(sURL, 'addto') != '') {
		_mobile_org.AddTo = mobile_comm_getQueryStringForUrl(sURL, 'addto');
	} else {
		_mobile_org.AddTo = '';
	}
	
	if (mobile_comm_getQueryStringForUrl(sURL, 'OrgSearch') != 'undefined' && mobile_comm_getQueryStringForUrl(sURL, 'OrgSearch') != '' && mobile_comm_getQueryStringForUrl(sURL, 'OrgSearch') == "UserSearch") {
		mobile_org_changeGR();
		$("#org_search_input").val(window.localStorage.getItem("SearchOrgUser"));
		$("#divOrgVoiceListener").show();
		setTimeout(function () {
			$("#org_list_div_step").css("display", "none");
			$("#org_list_sublist").css("display", "none");
			$("#org_list_searchlist").css("display", "block");
			mobile_org_searchInput();
			mobile_org_getGRInfo('', '', $("#org_search_input").val(), 'search');
			if($("#org_list_searchlist li").length > 0) {
				mobile_orgVoiceCall();
			}
		}, 200)
		
	} else {
		// step 그리기 & 하위부서 조회 call
		mobile_org_changeGR();
	}
	
	//조직도 selected
	if (window.sessionStorage["userParams"] != undefined && window.sessionStorage["userParams"] != "") {
		mobile_org_userselected(mobile_comm_getSession('DN_Code'), mobile_comm_getSession('GR_Code'), 'sub');
	}
	
	if(_mobile_org.Mode.toUpperCase() != 'VIEW') {
		$('#org_list_back').attr('class', 'topH_close').show();
		$('#divOrgListMoreMenu').hide();
	} else {
		$('#org_list_back').attr('class', 'topH_close').hide();
		$('#divOrgListMoreMenu').show();
	}	
}

function mobile_org_userselected(dn_code, gr_code, type){
	var sHtml = "";
	var deptCode = gr_code;
	var url = "/covicore/mobile/org/getSubList.do";	
	var searchType = "";
	
	//타계열사 표시 안하는 경우 회사코드 지정
	if(type == "search" && dn_code == "" && mobile_comm_getBaseConfig("ORGDisplayOtherCompany") != "Y") {
		dn_code = mobile_comm_getSession('DN_Code');
	}
	
	$.ajax({
		url : url,
		data : {
			"companyCode": dn_code,
			"groupType": "dept",
			"deptCode": deptCode,
			"searchType": "usercodes",
			"searchText": window.sessionStorage["userParams"],
			"type" : type
		},
		type : "post",
		async : false,
		success : function(res) {
			if (res.status == "SUCCESS" && res.userlist.length > 0) {
				$(res.userlist).each(function (i, list){
					mobile_org_setCheckedArea(list, list.UserCode.replace(".","_"), 'user', 'selected');
				});
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
}

//음성인식 호출
function mobile_orgVoiceCall(){
	if($("#divOrgVoiceListener").hasClass("used")) {
		$("#divOrgVoiceListener").removeClass("used").addClass("act");
		// 음성인식 시작
		mobile_comm_callappvoicerecognition(mobile_OrgVoiceCallBack);
	} else if($("#divOrgVoiceListener").hasClass("act")) {
		$("#divOrgVoiceListener").removeClass("act").addClass("used");
		mobile_VoiceCallback = null;
		// 음성인식 취소
		mobile_comm_callappstopvoicerecognition();
	}
}

//음성인식 콜백
function mobile_OrgVoiceCallBack(pResult){
	$("#divOrgVoiceListener").removeClass("act").addClass("used");
	if(pResult != ""){
		if(pResult.length >= 1) {
			pResult = pResult[0];
		}
		if(pResult.indexOf("조회") > -1 || pResult.indexOf("상세") > -1){
			$("#org_list_searchlist li").eq(0).find("a")[0].click();
		} else if(pResult.indexOf("전화") > -1 || pResult.indexOf("연결") > -1){
			var searchUser = pResult.replace("전화연결", "").replace("전화해 줘", "").replace("전화해줘", "").replace("전화", "").replace("연결", "").replace(" ", "").replace(" ", "");
			if(searchUser != ""){
				if($("a[org_user_name='"+searchUser+"']").length > 0){
					alert(searchUser+"에게 전화연결합니다.")
					$("a[org_user_name='"+searchUser+"']")[0].click();
				} else {
					alert(searchUser+"를 찾지 못했습니다. 다시 입력하십시요.");
					mobile_orgVoiceCall();
				}	
			} else {
				alert("첫번째 사용자에게 전화연결 합니다.");
				$("#org_list_searchlist li").eq(0).find("a")[1].click();
			}
		} else if(pResult.indexOf("검색") > -1){
			$("#org_search_input").val(pResult.replace("사용자", "").replace("검색해 줘", "").replace("검색해줘", "").replace("검색", "").replace(" 죠", "").replace(" 조", "").replace(" ", "").replace(" ", ""));
			mobile_org_getGRInfo('', '', $("#org_search_input").val(), 'search');
			mobile_orgVoiceCall();
		} else if(pResult.indexOf("닫기") > -1 || pResult.indexOf("취소") > -1){
			mobile_comm_back();
		} else if(pResult.indexOf("포탈") > -1 || pResult.indexOf("포털") > -1 || pResult.indexOf("홈") > -1){
			mobile_comm_go("/groupware/mobile/portal/main.do");
		} else {
			if(pResult == "**no_match" || pResult == "**no_speech"){
				// 리슨너 재호출
				setTimeout("mobile_orgVoiceCall()", 100);
			} else if(pResult == "**stop"){
				//alert("음성인식이 중지되었습니다.");
			} else {
				alert("지원하지 않는 기능입니다." +pResult);
				setTimeout("mobile_orgVoiceCall()", 100);
			}
		}
	}
}

//음성인식 활성 비활성 처리
$(document).on('taphold', "#divOrgVoiceListener", function(e) {
	if($("#divOrgVoiceListener").hasClass("notused")){ // 음성인식 사용
		$("#divOrgVoiceListener").removeClass("notused").addClass("used");
		window.localStorage.setItem("mobileVoiceOrgListUse", "true");
	} else if($("#divOrgVoiceListener").hasClass("used")){ // 음성인식 비사용
		$("#divOrgVoiceListener").removeClass("used").addClass("notused");
		window.localStorage.setItem("mobileVoiceOrgListUse", "false");
	} else if($("#divOrgVoiceListener").hasClass("act")){ // 음성인식 가이드 표시
		$("#divOrgReadVoiceGuidePop").show();
	}
});

function mobile_org_TeamsList(){
	_mobile_org.Mode = 'SelectUser';
	_mobile_org.Multi = 'Y';
	_mobile_org.IsTeams = 'Y';
	// step 그리기 & 하위부서 조회 call
	mobile_org_changeGR();
	
	if(_mobile_org.Mode.toUpperCase() != 'VIEW') {
		$('#org_list_back').attr('class', 'topH_close').show();
	} //else {
//		$('#org_list_back').attr('class', 'btn_back').show();
//	}
	
}

/* 중복 함수 비활성화 처리
function mobile_org_EditList(){
	_mobile_org.Mode = 'Select';
	_mobile_org.Multi = 'Y';
	
	// step 그리기 & 하위부서 조회 call
	mobile_org_changeGR();
	
	if(_mobile_org.Mode.toUpperCase() != 'VIEW') {
		$('#org_list_back').attr('class', 'topH_close').show();
	} //else {
//		$('#org_list_back').attr('class', 'btn_back').show();
//	}
	
}*/

function mobile_org_EditList(){
	_mobile_org.Mode = 'Select';
	_mobile_org.Multi = 'Y';
	
//	var sURL = $(location).attr("href");
//	if(window.sessionStorage['mode'] != undefined && window.sessionStorage['mode'] == "Select") {
//		sURL = "/covicore/mobile/org/list.do";
//	}
//	
//	if (mobile_comm_getQueryStringForUrl(sURL, 'mode') != 'undefined' && mobile_comm_getQueryStringForUrl(sURL, 'mode') != '') {
//		_mobile_org.Mode = mobile_comm_getQueryStringForUrl(sURL, 'mode');
//    } else if (window.sessionStorage['mode'] != undefined && window.sessionStorage['mode'] != '') {
//		_mobile_org.Mode = window.sessionStorage['mode'];
//    } else {
//    	_mobile_org.Mode = 'Select';
//    	//alert("여기잖아");
//    	//_mobile_org.Mode = 'Select';
//    }
//	
//	if (window.sessionStorage['multi'] != undefined && window.sessionStorage['multi'] != '') {
//		_mobile_org.Multi = window.sessionStorage['multi'];
//    } else {
//    	_mobile_org.Multi = 'Y';
//    }
//	
//	if (mobile_comm_getQueryStringForUrl(sURL, 'addto') != 'undefined' && mobile_comm_getQueryStringForUrl(sURL, 'addto') != '') {
//		_mobile_org.AddTo = mobile_comm_getQueryStringForUrl(sURL, 'addto');
//	} else {
//		_mobile_org.AddTo = '';
//	}
	
	// step 그리기 & 하위부서 조회 call
	mobile_org_changeGR(window.tmpGrouppath,window.tmpGroupcode, window.tmpCompanycode);
	
	if(_mobile_org.Mode.toUpperCase() != 'VIEW') {
		$('#org_list_back').attr('class', 'topH_close').show();
	} //else {
//		$('#org_list_back').attr('class', 'btn_back').show();
//	}
	
}

//부서 변경
function mobile_org_changeGR(grouppath,companycode, groupcode) {
	
	//상단 step을 그리고 하위 부서 목록을 조회
	
	//mobile_comm_getSession('GR_GroupPath')
	//ORGROOT;HEADOFFICE;U20000003;
	
	//mobile_comm_getSession('GR_FullName')
	//그룹사(공용)@본사@경영전략
	
	var sHtml = "";
	
	if(grouppath == undefined || groupcode == undefined) {
		grouppath = mobile_comm_getSession('GR_GroupPath');
		groupcode = mobile_comm_getSession('GR_Code');
		companycode = mobile_comm_getSession('DN_Code');
	}
	
	window.tmpGrouppath  = grouppath;
	window.tmpGroupcode  = companycode;
	window.tmpCompanycode= groupcode;
	
	mobile_org_pathinfo(grouppath,groupcode);
	mobile_org_getGRInfo(companycode, groupcode, '', 'sub');
}

// 하위부서/부서원 조회
function mobile_org_getGRInfo(dn_code, gr_code, searchText, type) {
	var sHtml = "";
	var deptCode = gr_code;
	var searchText = searchText;
	var url = "/covicore/mobile/org/getSubList.do";	
	var searchType = "";
	
	//타계열사 표시 안하는 경우 회사코드 지정
	if(type == "search" && dn_code == "" && mobile_comm_getBaseConfig("ORGDisplayOtherCompany") != "Y") {
		dn_code = mobile_comm_getSession('DN_Code');
	}
	
	$.ajax({
		url : url,
		data : {
			"companyCode": dn_code,
			"groupType": "dept",
			"deptCode": deptCode,
			"searchType": "all",
			"searchText": searchText,
			"type" : type
		},
		type : "post",
		async : false,
		success : function(res) {
			if (res.status == "SUCCESS") {
				if(_mobile_org.Mode.toUpperCase() != "VIEW") {
					$(".org_list").addClass("select");
					$("#btn_SetOrgConfirm").show();
					$("#btn_SetOrgAllCheck").show();
				}
				
				if(res.userlist.length < 1 && res.deptlist < 1){
					sHtml += "<div class=\"no_list\">";
					sHtml += "    <p>" + mobile_comm_getDic("msg_NoDataList") + "</p>";//조회할 목록이 없습니다.
					sHtml += "</div>";
				} else {
					sHtml += mobile_org_getGRInfoHtml(res.userlist, "user", deptCode,type);
					sHtml += mobile_org_getGRInfoHtml(res.deptlist, "dept", deptCode,type);
				}			
				
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});
	
	if(type == "search")
		$('#org_list_searchlist').html(sHtml).trigger("create");
	else
		$('#org_list_sublist').html(sHtml).trigger("create");
	if(_mobile_org.IsTeams == 'Y'){
		SetTeamsPresence();
	}
}

// 전체 선택 & 전체 해재
function mobile_org_allCheck() {
	
	var isAllCheck = $("#org_list_sublist").find("input[type=checkbox]").length == $("#org_list_sublist").find("input[type=checkbox]:checked").length ? true : false ;

	$("#org_list_sublist").find("input[type=checkbox]").each(function(inx, chkObj){
		if(!isAllCheck && !$(chkObj).is(":checked") ){
			$(chkObj).click();
		}	

		if(isAllCheck && $(chkObj).is(":checked") ){
			$(chkObj).click();
		}
	});
}

//하위부서/부서원 html
function mobile_org_getGRInfoHtml(infolist, type, deptcode,target) {//type: dept-하위부서, user-부서원, deptcode-조회하는부서코드, target : search-검색
	
	var sHtml = "";
	var sInfo = "";
	
	var multiRepJobTypeConfig = mobile_comm_getBaseConfig("MultiRepJobType");
	
	if(type == "user") {
		$(infolist).each(function (i, list){
			sInfo = "";
			
			sHtml += "<li class=\"staff\">";
			sHtml += "    <a onclick=\"mobile_org_viewDetail('" + list.AN + "');\" class=\"con_link\">";
			sHtml += "        <span class=\"photo\" style=\"background-image:url('" + mobile_comm_getimg(list.PhotoPath) + "'), url('" + mobile_comm_noperson() + "')\"></span>";
			if(_mobile_org.IsTeams == 'Y'){
				sHtml += "<span id='spanTeamsPresence_" + list.AN + "' class='pState pState06'></span>";
			}
			sHtml += "        <div class=\"info\">";
			sHtml += "            <p class=\"name\">" + mobile_comm_getDicInfo(list.DN) + "</p>";//TODO: 다국어 처리
			sHtml += "            <p class=\"detail\">";
			if(list.ExGroupName != undefined && list.ExGroupName != null && list.ExGroupName != "")
				sInfo += "            <span>" + mobile_comm_getDicInfo(list.ExGroupName) + "</span>";
			if(multiRepJobTypeConfig != null && multiRepJobTypeConfig != ""){
				multiRepJobTypeConfig.split(";").forEach(function(e){
					if(e == "TN"){
						if(list.TL != undefined && list.TL != null && list.TL.split("|")[1] != undefined && list.TL.split("|")[1] != "")
							sInfo += "            <span> " + (sInfo.length > 0 ? "|" : "") + " " + mobile_comm_getDicInfo(list.TL.split("|")[1]) + "</span>";
					} else if(e == "PN"){
						if(list.PO != undefined && list.PO != null && list.PO.split("|")[1] != undefined && list.PO.split("|")[1] != "")
							sInfo += "            <span> " + (sInfo.length > 0 ? "|" : "") + " " + mobile_comm_getDicInfo(list.PO.split("|")[1]) + "</span>";
					} else if(e == "LN"){
						if(list.LV != undefined && list.LV != null && list.LV.split("|")[1] != undefined && list.TL.split("|")[1] != "")
							sInfo += "            <span> " + (sInfo.length > 0 ? "|" : "") + " " + mobile_comm_getDicInfo(list.LV.split("|")[1]) + "</span>";
					}
				});
			} else{
				if(list.TL != undefined && list.TL != null && list.TL.split("|")[1] != undefined && list.TL.split("|")[1] != "")
					sInfo += "            <span> " + (sInfo.length > 0 ? "|" : "") + " " + mobile_comm_getDicInfo(list.TL.split("|")[1]) + "</span>";
				if(list.LV != undefined && list.LV != null && list.LV.split("|")[1] != undefined && list.TL.split("|")[1] != "")
					sInfo += "            <span> " + (sInfo.length > 0 ? "|" : "") + " " + mobile_comm_getDicInfo(list.LV.split("|")[1]) + "</span>";
			}

			sHtml += sInfo;
			sHtml += "            	<span>&nbsp;</span>";
			sHtml += "            </p>";
			sHtml += "        </div>";
			sHtml += "    </a>";
			
			if(_mobile_org.Mode.toUpperCase() != "VIEW") {	
				var sTargetID = "org_list_selectuser_" + list.UserCode.replace(".","_");
				if(target == "search")
					sTargetID = "org_list_selectsearchuser_" + list.UserCode.replace(".","_")+"_"+i;
				sHtml += "<div class=\"check\">";
				sHtml += "    <input type=\"checkbox\" name=\"\" value=\"" + list.AN +  "\" id=\""+sTargetID+ "\" onchange=\"mobile_org_setCheckedArea(" + JSON.stringify(list).replace(/\"/gi, "'") + ", '" + list.UserCode.replace(".","_") + "', 'user','"+target+"',this);\">";
				sHtml += "    <label for=\"" + sTargetID + "\"></label>";
				sHtml += "</div>";
			} else {
				if(list.Mobile != "") {
					sHtml += "    <a org_user_name='" + mobile_comm_getDicInfo(list.DN) + "' href=\"tel: " + list.Mobile + "\" class=\"btn_call\"><span><i></i></span></a>";	
				}
			}
			sHtml += "</li>";
		});
	} else if(type == "dept") {
		$(infolist).each(function (i, list){
			if(list.MemberOf == deptcode || deptcode == '') {
				sHtml += "<li class=\"folder\">";
				if(target == "search") {
					sHtml += "    <a href=\"javascript: mobile_org_changeDisplay(); mobile_comm_closesearch(); mobile_org_changeGR('" + list.GroupPath + "','" + list.CompanyCode+ "','" + list.GroupCode + "');\" class=\"con_link\">";
				}
				else {
					sHtml += "    <a href=\"javascript: mobile_org_changeGR('" + list.GroupPath + "','" + list.CompanyCode+ "','" + list.GroupCode + "');\" class=\"con_link\">";
				}
				sHtml += "        <i class=\"ico_folder\"></i>";
				sHtml += "        <span class=\"folder_name\">" + mobile_comm_getDicInfo(list.DN) + "</span>";
				sHtml += "    </a>";
				if(_mobile_org.Mode.toUpperCase() == "SELECT") {
//				if(_mobile_org.Mode.toUpperCase() != "VIEW") {
					var sTargetID = "org_list_selectdept_" + list.GroupCode;
					if(target == "search")
						sTargetID = "org_list_selectsearchdept_" + list.GroupCode;
					sHtml += "<div class=\"check\">";
					if(_mobile_org.Mode.toUpperCase() != "VIEW")
						sHtml += "    <input type=\"checkbox\" name=\"\" value=\"\" id=\"" + sTargetID + "\" onchange=\"mobile_org_setCheckedArea(" + JSON.stringify(list).replace(/\"/gi, "'") + ", '" + list.GroupCode + "', 'dept','"+target+"');\">";
					else
						sHtml += "    <input type=\"checkbox\" name=\"\" value=\"\" id=\"" + list.sTargetID + "\" onchange=\"mobile_org_setCheckedArea(" + JSON.stringify(list).replace(/\"/gi, "'") + ", '" + list.GroupCode + "', 'dept','"+target+"');\">";
					sHtml += "    <label for=\"" + sTargetID + "\"></label>";
					sHtml += "</div>";
				}
				sHtml += "</li>";
			}
		});
	}
	
	return sHtml;
}

// 사용자 상세조회 화면으로 이동
function mobile_org_viewDetail(usercode) {
	if(_mobile_org.Mode.toUpperCase() == "VIEW") {
		var sUrl = "/covicore/mobile/org/view.do";
		window.sessionStorage["usercode"] = usercode;
		
		mobile_comm_go(sUrl, 'Y');
	}
}

// 부서 상위로 이동
function mobile_org_goTop(obj) {
	var oli = $("#org_list_step").find("li");
	var li_len = oli.length;
	$(oli).eq(li_len-2).find("a")[0].click();
}

//확장메뉴 show or hide
function mobile_org_showORhide(obj) {
	if($(obj).parent().hasClass("show")) {
		$(obj).parent().removeClass("show");
	} else {
		$(obj).parent().addClass("show");
	}
}

/*!
 * 
 * 조직도 선택
 * 
 */

// 선택된 부서/부서원 선택영역에 바인딩
function mobile_org_setCheckedArea(data, code, type, target, obj) {	
	code = code.replace(".","_");
	var name = mobile_comm_getDicInfo(data.DN, lang);
	var photo = (type == "user" ? data.PhotoPath : "");
	var position = (type == "user" ? mobile_comm_getDicInfo(data.PO.split("|")[1], lang) : "");
	var targetID = "";
	if(target == "search"){
		//targetID = "org_list_selectsearch" + type + "_" + code;
		targetID = obj.id;
	}else{
		targetID = "org_list_select" + type + "_" + code;
	}
	if(target == "selected" && window.sessionStorage["userParams"].includes(code)){
		$("#"+targetID).prop("checked",true);
	}
	
	if($("#"+targetID).is(":checked")) {
		if(_mobile_org.Multi == "Y" || $("#org_list_selected").find("ul").find("li").length < 1) {
			if($("#org_list_selecteditems").val() == "" || _mobile_org.Multi == "N") {
				$("#org_list_selecteditems").val(JSON.stringify(data));
			} else {
				if($("#org_item_select"+type+"_"+code).length >0){
					$("#"+targetID).prop("checked", false).checkboxradio("refresh");
					return;
				}
				$("#org_list_selecteditems").val($("#org_list_selecteditems").val() + ", " + JSON.stringify(data));
			}
			
			if($("#org_list_selecteditems").val() == "") {
				$("#org_list_selected").css("display", "none");
			} else {
				$("#org_list_selected").css("display", "block");
			}
			$("#org_list_selected").find("ul").append(mobile_org_setCheckedAreaHtml(code, name, photo, type));
		} else {
			alert(mobile_comm_getDic("msg_com_NotMultiSelect")); //다중 선택은 불가합니다.
			$("#"+targetID).prop("checked", false).checkboxradio("refresh");
		}
	} else {
		mobile_org_delSelected($("#org_item_select" + type + "_" + code).siblings(".del"), type, code);
	}
}

function mobile_org_setCheckedAreaHtml(code, name, photo, type) {
	var sHtml = "";
	
	if(type == "user") {
		sHtml += "<li>";
		sHtml += "	<a href=\"\">";
		sHtml += "		<span class=\"photo\" style=\"background-image: url('" + mobile_comm_getimg(photo) + "'), url('" + mobile_comm_noperson() + "')\"></span>";
		sHtml += "		<p class=\"name\" id=\"org_item_selectuser_" + code + "\">" + name + "</p>"; //DN = MultiDisplayName
		sHtml += "		<span class=\"del\" onclick=\"javascript: mobile_org_delSelected(this, '" + type + "', '" + code + "');\"></span>";
		sHtml += "	</a>";
		sHtml += "</li>";
	} else if(type == "dept") {
		sHtml += "<li>";
		sHtml += "	<a href=\"\">";
		sHtml += "		<span class=\"ico_folder\"></span>";
		sHtml += "		<p class=\"name\" id=\"org_item_selectdept_" + code + "\">" + name + "</p>"; //DN = MultiDisplayName
		sHtml += "		<span class=\"del\" onclick=\"javascript: mobile_org_delSelected(this, '" + type + "', '" + code + "');\"></span>";
		sHtml += "	</a>";
		sHtml += "</li>";
	}
	
	return sHtml;
}

// 선택된 부서/부서원 선택 해제(x 버튼 누를 시 실행)
function mobile_org_delSelected(obj, type, code) {
	var id = code;
	var json_string = "[" + $("#org_list_selecteditems").val() + "]";
	var json_obj = JSON.parse(json_string);
	var cnt = json_obj.length;
	for(var i = 0; i < cnt; i++) {
		if(json_obj[i].AN == code) {
			json_obj.splice(i, 1);
			break;
		}
	}
	
	if(json_obj.length > 0) {
		$("#org_list_selecteditems").val(JSON.stringify(json_obj).replace("[", "").replace("]", ""));
	} else {
		$("#org_list_selecteditems").val("");
	}
	
	$(obj).closest("li").remove();
	$("#org_list_select" + type + "_" + code).prop("checked", false).checkboxradio("refresh");
	
	if($("#org_list_selected").find("ul").find("li").length < 1) {
		$("#org_list_selected").css("display", "none");
	}
}


// 선택된 부서/부서원 목록 반환
function mobile_org_setconfirm() {
	//TODO: 게시/결재 등에서 선택된 부서/부서원 반환하기

	window.sessionStorage["userinfo"] = $("#org_list_selecteditems").val();
	new Function (window.sessionStorage["callback"]).apply();
	
	window.sessionStorage["mode"] = "View";

	$("#org_list_selected").find("ul").html('');
	$("#org_list_selected").hide();
	$("#org_list_sublist").find("input[type=checkbox]").prop("checked", false).checkboxradio("refresh");
	
	mobile_comm_back();
}

//선택된 부서/부서원 목록 반환
function mobile_org_syncContact(pObj) {
	//TODO: 게시/결재 등에서 선택된 부서/부서원 반환하기	
	
	// ConfirmAlert
	var confirmMessage;
	var varUA = navigator.userAgent.toLowerCase(); // userAgent 값 얻기

	if (mobile_comm_isAndroidApp()) { // 안드로이드
		confirmMessage = confirm("연락처 동기화 시, 등록된 연락처 정보가 수정될 수 있습니다.\n\n계속 하시겠습니까?\n\n(동기화 데이터가 많을수록 시간이 오래 걸릴 수 있습니다.)");
	} else if (mobile_comm_isiOSApp()) { // IOS
		confirmMessage = confirm("연락처 동기화 시, 등록된 연락처 정보가 수정될 수 있습니다.\n\n계속 하시겠습니까?");
	} else { // 아이폰, 안드로이드 외
		confirmMessage = confirm("연락처 동기화 시, 등록된 연락처 정보가 수정될 수 있습니다.\n\n계속 하시겠습니까?\n\n(동기화 데이터가 많을수록 시간이 오래 걸릴 수 있습니다.)");
	}

	if(confirmMessage) {
		alert("연락처 동기화를 진행합니다.")
		
		var temp = $(pObj);
		var sSyncGroupData = "";
		var sSyncUserData = ""
		
		var json_string = "[" + $(temp).parent().parent().parent().parent().find('#org_orgList_content').find('#org_list_selecteditems').val() + "]";
		json_string = json_string.replace(/&quot/gi, "\"");
	//	alert(json_string);
		
		var json_obj = JSON.parse(json_string);
		var cnt = json_obj.length;
		
		for(var i=0; i<cnt; i++) {
			if(json_obj[i].itemType == 'group') {
				sSyncGroupData = sSyncGroupData + json_obj[i].GroupCode + ",";
			}
			else {
				sSyncUserData = sSyncUserData + json_obj[i].UserCode + ",";
			}
		}
		mobile_comm_syncuserphonenumber(sSyncUserData, sSyncGroupData);
		
	//	alert(sSyncUserData + "/" + sSyncGroupData);
	
		mobile_common_void_reload();
	} else {
		alert("연락처 동기화를 취소했습니다.")
		mobile_common_void_reload();
	}

}

/*!
 * 
 * 조직도 검색
 * 
 */

// 조직도 검색 버튼 click
function mobile_org_searchInput() {
	$("#org_div_search").css("display", "block");
}

// 조직도 검색 enter key press
function mobile_org_searchEnter(e) {
	if(e.keyCode === 13) {
		mobile_org_search();
	}
	return false;
}

// 조직도 검색
function mobile_org_search() {
	if($("#org_search_input").val() == "") {
		alert(mobile_comm_getDic("msg_EnterSearchword"));
	} else if ($("#org_search_input").val().length < 2) {
		alert(mobile_comm_getDic("msg_Common_07"));  // 검색어는 2글자 이상 입력하여 주십시오.
    } else {
    	$("#org_list_div_step").css("display", "none");
		$("#org_list_sublist").css("display", "none");
		$("#org_list_searchlist").css("display", "block");
		
		mobile_org_getGRInfo('', '', $("#org_search_input").val(), 'search');
	}
}



// 조직도 검색 닫기
function mobile_org_changeDisplay() {
	$("#org_list_searchlist").css("display", "none");
	$("#org_list_div_step").css("display", "block");
	$("#org_list_sublist").css("display", "block");
	$("#divOrgVoiceListener").hide();	
	mobile_org_resetSearchInput();
}

// 조직도 검색 input reset
function mobile_org_resetSearchInput() {
	$("#org_search_input").val("");
}

/*!
 * 
 * 조직도 상세
 * 
 */

function mobile_org_ViewInit() {
	if (mobile_comm_getQueryString('usercode') != 'undefined' && mobile_comm_getQueryString('usercode') != '') {
		_mobile_org.UserCode = mobile_comm_getQueryString('usercode');
    } else {
    	_mobile_org.UserCode = window.sessionStorage.getItem("usercode");
    }
	
	// 상세 정보 setting
	mobile_org_setUserInfo();
	
	$("#org_view_header").children("a").remove(); //이상한 a 태그가 추가되는 현상 임시 조치
}

function mobile_org_setUserInfo() {
	var userCode = _mobile_org.UserCode;
	
	$.ajax({
		type : "POST",
		data : {
			"UserCode" : userCode,
			"gr_code" : ""
		},
		url : "/covicore/mobile/org/getOrgInfo.do",
		success : function(data) {
			var userlist = data.userlist[0];
			var sContact = "";
			
			//주소록 저장
			var contactinfo = mobile_comm_getDicInfo(userlist.MultiDisplayName, lang) + "|";
			contactinfo += userlist.JobLevelName + "|";
			contactinfo += mobile_comm_getDicInfo(userlist.MultiDeptName, lang) + "|";
			contactinfo += mobile_comm_getDicInfo(userlist.MultiCompanyName, lang) + "|";
			contactinfo += userlist.PhoneNumber + "|";
			contactinfo += userlist.Mobile + "|";
			contactinfo += userlist.MailAddress;
			
			$('#org_view_hid_info').val(contactinfo);
			
			if(mobile_comm_isMobileApp()) {
				$('#org_view_addcontact').show();
			}
			
			var sRepJobTypeConfig = mobile_comm_getBaseConfig("RepJobType");
	        var sRepJobType = userlist.JobLevelName;
	        if(sRepJobTypeConfig == "PN"){
	        	sRepJobType = userlist.JobPositionName;
	        } else if(sRepJobTypeConfig == "TN"){
	        	sRepJobType = userlist.JobTitleName;
	        } else if(sRepJobTypeConfig == "LN"){
	        	sRepJobType = userlist.JobLevelName;
	        }
			
			//$("#org_view_a_title").text(mobile_comm_getDicInfo(userlist.MultiDisplayName, lang));
			$("#org_view_a_title").text(mobile_comm_getDic("lbl_DetailView")); //상세보기
			$("#org_view_photo").css("background-image", "url('" + mobile_comm_getimg(userlist.PhotoPath) + "'), url('" + mobile_comm_noperson() + "')");
			$("#org_view_span_deptname").text(mobile_comm_getDicInfo(userlist.MultiDeptName, lang));
			$("#org_view_span_joblevel").text(sRepJobType);
			$("#org_view_li_displayname").html(mobile_comm_getDicInfo(userlist.MultiDisplayName, lang));
			$("#org_view_li_mobile").html(userlist.Mobile);
			$("#org_view_li_email").html(userlist.MailAddress);
			$("#org_view_li_office").html(userlist.PhoneNumber);
			
			if(userlist.Mobile != "") {
				sContact += "<li><a href=\"" + "tel:" + userlist.Mobile + "\" id=\"org_view_btn_call\"><i class=\"ico_call\"></i></a><span>Call</span></li>";
				sContact += "<li><a href=\"" + "sms:" + userlist.Mobile + "\" id=\"org_view_btn_sms\"><i class=\"ico_sms\"></i></a><span>SMS</span></li>";
			}
			if(userlist.MailAddress != "") {
				if((mobile_comm_getBaseConfig("LinkToMailWrite") == "Y") && (mobile_comm_getBaseConfig("isUseMail") == "Y")) //메일 사용 여부 기초설정으로 변경하였습니다.(LinkToMailWrite => isUseMail) 
					sContact += "<li><a href=\"javascript:mobile_org_sendmail('" + userlist.MailAddress + "', '"+ mobile_comm_getDicInfo(userlist.MultiDisplayName, lang) +"');\" id=\"org_view_btn_mail\"><i class=\"ico_mail\"></i></a><span>Mail</span></li>";
				else
					sContact += "<li><a href=\"" + "mailto:" + userlist.MailAddress + "\" id=\"org_view_btn_mail\"><i class=\"ico_mail\"></i></a><span>Mail</span></li>";
			}
			/*if(userlist.UserCode != "") { //메신저 기능 완성 후 주석 해제 예정
				sContact += "<li><a href=\"\" id=\"org_view_btn_messenger\"><i class=\"ico_messenger\"></i></a><span>Messenger</span></li>";
			}*/
			
			$("#org_view_contact").append(sContact);
		},
		error : function(reponse, status, error) {
			mobile_comm_ajaxerror("/covicore/mobile/org/getOrgInfo.do", response, status, error);
		}
	});
	
}

// 메일 작성페이로 이동
function mobile_org_sendmail(pMailAddress, pMailName){
	if(mobile_comm_getBaseConfig("isUseExchMail") == "Y" && mobile_comm_getBaseConfig("isUseMail") == "Y"){
		//window.sessionStorage.setItem("m_userMail",mobile_comm_getSession("UR_Mail"));
		//window.sessionStorage.setItem("m_ismailusernm",mobile_comm_getSession("USERNAME"));
		var url = "/WebSite/MobileNew/Mail/MailWrite.aspx"; //  URL
		url = url + "?system=Mail&Mode=ORG&MailtoName=" + encodeURIComponent(pMailName) + "&Mailto=" + encodeURIComponent(pMailAddress);
	
		mobile_comm_mailopen(url);
	} else {
		window.sessionStorage.setItem("m_userMail",mobile_comm_getSession("UR_Mail"));
		window.sessionStorage.setItem("m_ismailusernm",mobile_comm_getSession("USERNAME"));
	
		mobile_comm_go("/mail/mobile/mail/Write.do?mailto="+ encodeURIComponent(pMailName + "<"+ pMailAddress +">"), "Y");
	}
}


function mobile_org_addContact () {
	var info = $('#org_view_hid_info').val();
	try {
		
		if(mobile_comm_isAndroidApp()) {
			window.covimoapp.callAddContact(info);
		} else if(mobile_comm_isiOSApp()) {
			window.webkit.messageHandlers.callbackHandler.postMessage({ type:'coviaddcontact', info: encodeURIComponent(info) }); 
		} else {
			alert(mobile_comm_getDic('msg_NotSupport'));
		}
	} catch (e) {mobile_comm_log(e);
	}
}

//조직도 상단 path 정보 표시
function mobile_org_pathinfo(grouppath, groupcode) {
var url = "/covicore/mobile/org/getOrgPathInfo.do";
	
	$.ajax({
		url : url,
		data : {
			"GroupPath": grouppath,
			"GroupCode": groupcode
		},
		type : "post",
		async : true,
		success : function(res) {
			if (res.status == "SUCCESS") {
				var list = res.data.list;				
				var subLink = "";
				var sHtml = "";
				var cnt = list.length;
				var displayOtherComany = mobile_comm_getBaseConfig("ORGDisplayOtherCompany");
				$(list).each(function(i,info){
					if(info.GroupPath != "") {
						//타계열사 표시 안하는 경우 orgroot표시 예외처리
						if((i == 0 && (displayOtherComany == "Y" || info.GroupCode == mobile_comm_getSession('DN_Code'))) || cnt == 1 || i > 0 ) {
							subLink = "#";
							if(cnt-1 != i) {
								subLink = "javascript: mobile_org_changeGR('" + info.GroupPath + "', '" + info.CompanyCode+ "', '" + info.GroupCode + "');";
							}
							
							sHtml += "<li><a href=\"" + subLink + "\">" + info.DisplayName + "</a></li>";//TODO: 클릭 처리
						}
					}
				});
				$('#org_list_step').html(sHtml);
				
				// 부서 dept 가 깊은 경우 우측 정렬
				$('.scr_h').scrollLeft($('.scr_h').width());
			}
		},
		error:function(response, status, error){
			mobile_comm_ajaxerror(url, response, status, error);
		}
	});

}

/*조직도 편집 (선택)*/ 
function mobile_org_orgList_viewChang(pObj){
	if($(pObj).attr("adata") != null && $(pObj).attr("adata") != ""){
		$("a[name='orgListEdit_pg_tit']").html("");
		mobile_org_viewChange($(pObj).attr("adata"));
	}
}

// 편집 > 조회
function mobile_org_orgList_listViewChang(pObj){
	if($(pObj).attr("adata") != null && $(pObj).attr("adata") != ""){
		$("#org_list_selected ul").html("");
		$("#org_list_selecteditems").val("");
		$("a[name='orgListEdit_pg_tit']").html("");
		mobile_org_viewChange($(pObj).attr("adata"));
		mobile_org_ListInit();
		mobile_common_void_reload();
	}
}

// 조회 > 편집
function mobile_org_orgList_editViewChang(pObj){
	if($(pObj).attr("adata") != null && $(pObj).attr("adata") != ""){
		$("a[name='orgListEdit_pg_tit']").html("");
		mobile_org_viewChange($(pObj).attr("adata"));
		
//		mobile_org_EditList();
	}
	mobile_org_EditList();
}

/*뷰 변경*/
function mobile_org_viewChange(type, mode){
	if(type == "CHECK"){
		$(".MailShell").removeClass("checkBG");
		
		$("div[name='org_orgList_divOrgList']").hide();
		$("div[name='org_orgList_divOrgListCheck']").show();
		
		if(!$(".header").hasClass("edit")){
			$(".header").addClass("edit");
		} 
		
		if(mode = undefined || mode != "More"){
			$('label[name="labelCheckList"]').each(function(){
				if($(this).hasClass("ui-checkbox-on")){
					$(this).removeClass("ui-checkbox-on");
					$(this).addClass("ui-checkbox-off");
				}
			});
		}
		
	}else if(type == "LIST"){
		$(".MailShell").removeClass("checkBG");
		
		$("div[name='org_orgList_divOrgList']").show();
		$("div[name='org_orgList_divOrgListCheck']").hide();
		
		$(".header").removeClass("edit"); 
	}
}

// 편집모드(전체 선택)
function mobile_org_orgList_aEditAllBtn(pObj){
	if($(pObj).attr("adata") != null && $(pObj).attr("adata") != ""){
		mobile_org_headerBtnFun($(pObj).attr("adata"));
	}
}//);

/*헤더에서 버튼 선택*/
function mobile_org_headerBtnFun(type){
	//전체선택
	if(type == "ALL"){
		var checkTy = "uncheck";
		if($("a[name='org_orgList_aEditAllBtn']").hasClass("ac")){
			$("a[name='org_orgList_aEditAllBtn']").removeClass("ac");
		}else{
			$("a[name='org_orgList_aEditAllBtn']").addClass("ac");
			checkTy = "check"
		}
		
		var count = 0;
		
		$("label[name='labelCheckList']").each(function(index, element){
			if(checkTy == "check"){
				if($(this).hasClass("ui-checkbox-off")){
					$(this).removeClass("ui-checkbox-off").addClass("ui-checkbox-on");					
					
					$($(this).closest(".MailShell")).addClass("checkBG");
				}
				
				count += 1;
				
			}else{
				if($(this).hasClass("ui-checkbox-on")){
					$(this).removeClass("ui-checkbox-on").addClass("ui-checkbox-off");					
					
					$($(this).closest(".MailShell")).removeClass("checkBG");
				}
			}
		});
		
		$($("div[name='org_orgList_divOrgListCheck']").find("a[name='orgListEdit_pg_tit']")).text(count);
		
	//삭제	버튼 클릭시 완전삭제인지 삭제인지 선택하는 팝업 호출
	}else if(type == "MD" || type == "D" || type == "FMD" || type == "Junk"){
		mobile_org_orgDeleteMove(type)
	}
}