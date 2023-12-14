$(function(){
	$('.formList .lineBox').each(function(){
		$(this).find('input').on('focus',function(){
			$(this).closest('.inner').addClass('active');
		});
		
		$(this).find('input').on('blur',function(){
			$(this).closest('.inner').removeClass('active');
		});
	});

	$('.tabTypeBizCard li, .bizCardContWrap .tabCont').removeClass('active');
	$('.tabTypeBizCard li:first, .bizCardContWrap .tabCont:first').addClass('active');

	$('.tabTypeBizCard li a').on('click',function(){
		var idxNum = $(this).parent().index();
		var $crntLi = $(this).parent();
		var $cont = $(this).closest('.tabTypeBizCard').next('.tabContWrap');
		$crntLi.siblings().removeClass('active');
		$crntLi.addClass('active');
		$cont.find('.tabCont').removeClass('active');
		$cont.find('.tabCont').eq(idxNum).addClass('active');
	});

	// 파일첨부
	$('.inputFileForm input[type=file]').on('change',function(){
		var filename;
		
		if(window.FileReader){	// modern browser
			filename = $(this)[0].files[0].name;
		}else {	// old IE
			filename = $(this).val().split('/').pop().split('\\').pop();	// 파일명만 추출
		}
		$(this).siblings('.txtFileName').text(filename);
	});

	// 체크박스 전체선택
	$('.checkAll').each(function(){
		$(this).on('click',function(){			
			if($(this).find('input[type=checkbox]').is(':checked')){
				$(this).siblings('.checkboxWrap').find('input[type=checkbox]').prop('checked',true);
			}else{
				$(this).siblings('.checkboxWrap').find('input[type=checkbox]').prop('checked',false);
			}
		});
	});
	$('.checkboxWrap').each(function(){
		var checkList = $(this).find('.chkStyle06').length;
		$(this).find('.chkStyle06').on('click',function(){
			if($(this).closest('.checkboxWrap').find('input[type=checkbox]:checked').length == checkList) {
				$(this).closest('.checkboxWrap').siblings('.checkAll').find('input[type=checkbox]').prop('checked',true)
			}else{
				$(this).closest('.checkboxWrap').siblings('.checkAll').find('input[type=checkbox]').prop('checked',false)
			}
		});
	});

	// 리스트 그룹선택 접기
	$('.selectListWrap, .selectListWrap .btnMoreStyle01').addClass('active');
	$('.selectListWrap .btnMoreStyle01').on('click',function(e){
		e.preventDefault();
		if($(this).hasClass('active')) {
			$(this).removeClass('active').text('open list').closest('.selectListWrap').removeClass('active');
		}else {
			$(this).addClass('active').text('fold list').closest('.selectListWrap').addClass('active');
		}
	});

});

//카드형 보기 추가
var viewType = "List";

function changeBizCardBoardView(){
	$("#resultBoxWrapAlbum").hide();
	$("#resultBoxWrap").show();
	$("#albumView").removeClass("active");
	$("#listView").addClass("active");
	page = bizCardAlbum.page.pageNo;
	//sortBy = coviAlbum.page.sortBy;
	viewType = "List";
	$("#btnCopy").show();
	$("#btnMove").show();
	$("#btnDelete").show();
}

function changeBizCardAlbumView(){
	$("#resultBoxWrap").hide();
	$("#resultBoxWrapAlbum").show();
	$("#listView").removeClass("active");
	$("#albumView").addClass("active");
	page = bizCardGrid.page.pageNo;
	//sortBy = bizCardGrid.getSortParam("one").split("=").pop();
	viewType = "Album";
	$("#btnCopy").hide();
	$("#btnMove").hide();
	$("#btnDelete").hide();
}

//카드형 보기
if (!window.bizCardAlbum) {
    window.bizCardAlbum = {};
}

(function($) {
	var bizCardAlbum = {
		target: '',
		url : '',
		page : { 
			pageNo: 1,
			pageOffset: 0,
			pageCount: 1,
			pageSize: 10,
			listCount: 0,
			sortBy: "",
		}, 	//페이지 정보
		searchParam : {},
		renderAlbumList : function(data){
			var albumContent = $("#"+this.target);
			
        	albumContent.html("<div>조회할 목록이 없습니다.</div>");

        	var wrapAlbum = $("<ul class='bizcard_org_view_list03'>");
        	//개별호출-일괄호출
        	Common.getDicList(["lbl_Company","lbl_MobilePhone","lbl_Office_Line","lbl_Email2", "lbl_HomePhone", "lbl_Office_Fax", "lbl_Etc"]);
        	
        	if(data.list !== undefined){
				$.each(data.list, function(i, item){
					//즐겨찾기
					var IsFavorite = item.IsFavorite == "Y" ? "active" : "";
					var favorite = $('<span style="color:black;" onclick="ChangeFavoriteStatus(' + item.BizCardID + ',this)"><a href="#none" class="tblBtnFavorite ' + IsFavorite + '" style="z-index:10;">즐겨찾기</a></span>');
					if(item.BizCardType != 'BizCard'  ){
						favorite = "";
					}
					//사진, 이름, 팀명
					var photoPath = "";
					var storagePath = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code"));
					if(item.ImagePath != "" && item.ImagePath != undefined) {
						photoPath = coviCmn.loadImage(storagePath + item.ImagePath);
					} else {
						if(item.BizCardType == 'BizCard') {
							photoPath = "/covicore/resources/images/common/noImg.png";							
						} else {
							photoPath = "/covicore/resources/images/common/noGroupImg.png";
						}
					}
					var photoSpan = $('<span class="photo"><img src="' + photoPath + '" class="mCS_img_loaded"></span>');
					var nameSpan = $('</span><span class="tx_name ellip">' + item.Name + ' ' + item.JobTitle + '</span>');
					var deptSpan = $('<span class="tx_team ellip">' + item.DeptName + '</span>');
					var divUserInfo = "";
					var userInfo = "";
					if(item.BizCardType == 'BizCard'){
						divUserInfo = $('<div class="user_info" onclick="viewBizCardPop(' + item.BizCardID + '); return false;">').append(photoSpan, nameSpan, deptSpan);
						
						//회사, 핸드폰, 사내전화, 메일
						var homeDl = $('<dl><dt>' + coviDic.dicMap["lbl_HomePhone"] + '</dt><dd class="ellip">' + item.HomePhoneNum + '</dd>');						
						var phoneNumDl = $('<dl><dt>' + coviDic.dicMap["lbl_MobilePhone"] + '</dt><dd class="ellip">' + item.PhoneNum + '</dd></dl>');
						var companyDl = $('<dl><dt>' + coviDic.dicMap["lbl_Company"] + '</dt><dd class="ellip">' + item.ComName + '</dd>');
						var comPhoneNumDl = $('<dl><dt>' + coviDic.dicMap["lbl_Office_Line"] + '</dt><dd class="ellip">' + item.ComPhoneNum + '</dd></dl>');
						var faxPhoneNumDl = $('<dl><dt>' + coviDic.dicMap["lbl_Office_Fax"] + '</dt><dd class="ellip">' + item.FaxNum + '</dd></dl>');
						//var etcPhoneNumDl = $('<dl><dt>' + coviDic.dicMap["lbl_Etc"] + '</dt><dd class="ellip">' + item.EtcNum + '</dd></dl>');
						var emailDl = $('<dl><dt>' + coviDic.dicMap["lbl_Email2"] + '</dt><dd class="ellip">' + item.EMAIL + '</dd></dl>');
						
						var spanUserInfo = $('<span class="tx_info01">').append(homeDl, phoneNumDl, companyDl, comPhoneNumDl, faxPhoneNumDl, emailDl);
						
						userInfo = $('<a href="#">').append(divUserInfo, spanUserInfo);
	             	}else{
	             		divUserInfo = $('<div class="user_info" style="width: 100%;" onclick="modifyGroupPop(\'' + bizCardViewType + '\',' + item.BizCardID + '); return false;">').append(photoSpan, nameSpan, deptSpan);
	             		userInfo = $('<a href="#">').append(divUserInfo);
	             	}
					
					wrapAlbum.append($('<li />').append(favorite, userInfo));
	     		});

				if(data.list.length == 0){
					wrapAlbum.append($("<li>").text("조회할 목록이 없습니다."));
				}
				
				albumContent.html(wrapAlbum);

	        	bizCardAlbum.fnMakeNavi(this.target, data.page)
		 	}
		},
		fnMakeNavi : function(target, data){
			var divPageNaviID = target + "PageBody";	//앨범 Div targetID + pageBody ID생성
			$('#'+divPageNaviID).remove();				//기존 Page Div 삭제
			$('#'+target).after($('<div/>').attr('id', divPageNaviID).addClass('pagingBox cRContEnd'));
			
			var rowCount = $('<div class="AXgridStatus">').append($('<b>').text(data.listCount), '개');		//개수 표시 다국어 필요
			var divCustomNavi = $('<div>').attr('id', 'custom_navi_'+divPageNaviID).attr('style', 'text-align:center;margin-top:2px;');
			
	    	var list_offset = 5; // navigation에서 한번에 보여질 페이지 개수
	    	this.page = data;
	    	
	        // gypark 전체갯수가 한번 보여주는 갯수의 배일 경우 페이지가 하나 더 나오는 오류 수정
	        if(this.page.listCount != 0 && this.page.listCount % this.page.pageSize == 0){
	        	this.page.pageCount = (this.page.listCount / this.page.pageSize);
	        }
	        if(this.page.pageCount == 0){
	        	this.page.pageCount = 1;
	        }
	    	
	        var start_page = Math.ceil(this.page.pageNo / list_offset) * list_offset - (list_offset - 1);
	        var end_page = (start_page + list_offset - 1 > this.page.pageCount) ? this.page.pageCount : start_page + list_offset - 1;
	        
	        var pageCount = this.page.pageCount;//this.page.listCount == this.page.pageCount * this.page.pageSize ? this.page.pageCount - 1 : this.page.pageCount; 
//	        var inputPageMove = $('<div class=goPage>').append($('<input id="txtPageMove" type="text">'), $('<span>').text(" / 총 "), $('<span>').text(pageCount), $('<span>').text('페이지'), $('<a class="btnGo">').text("go"));
	        //페이징 표시용 DIV에 custom_navi div 추가
//	        $('#'+divPageNaviID).append(rowCount, divCustomNavi, inputPageMove);
	        //페이지 바로가기 숨김
	        $('#'+divPageNaviID).append(rowCount, divCustomNavi);
	        
	        var custom_navi_html = '';

	        custom_navi_html += "<input type=\"button\" id=\"AXPaging_begin\" class=\"AXPaging_begin\"/>";
	        custom_navi_html += "<input type=\"button\" id=\"AXPaging_prev\" class=\"AXPaging_prev\"/>";
	        
	        for (var i=start_page; i<= end_page; i++) {
	            custom_navi_html += "<input type=\"button\" id=\"AXPaging\" value=\"" + i + "\" style=\"width:20px;\" class=\"AXPaging " + (i == this.page.pageNo ? "Blue\"" : "\" ") + "/>";
	        }
	        custom_navi_html += "<input type=\"button\" id=\"AXPaging_next\" class=\"AXPaging_next\"/>";
	        custom_navi_html += "<input type=\"button\" id=\"AXPaging_end\" class=\"AXPaging_end\"/>";
	        $('#custom_navi_' + divPageNaviID).html(custom_navi_html);
	        
	        var pagemovefunc = function (pObj) {
            	bizCardAlbum.setList(pObj);
	        }
	        
	        $("#"+divPageNaviID).find(".AXPaging_begin").click(function () {
	        	this.page.pageNo = 1;
	        	pagemovefunc(this.searchParam);
	        }.bind(this));
	        
	        $("#"+divPageNaviID).find(".AXPaging_prev").click(function () {
	        	this.page.pageNo = start_page > 1 ? start_page - 1 : 1;
	        	pagemovefunc(this.searchParam);
	        }.bind(this));
	        
	        var obj = this;
	        $("#"+divPageNaviID).find(".AXPaging").each(function () {
	        	$(this).click(function () { 
	                var thisobjname =$(this).parents("div").parents("div").attr("id");
	                if($("#"+divPageNaviID).attr("id")==thisobjname){
	                	obj.page.pageNo = $(this).attr("value");           
	                    pagemovefunc(obj.searchParam);
	                   }             
	             });     
	        });
	        
	        $("#"+divPageNaviID).find(".AXPaging_next").click(function () {
	        	obj.page.pageNo = end_page < obj.page.pageCount ? end_page + 1 : end_page;
	        	pagemovefunc(obj.searchParam);
	        }.bind(this));
	        
	        $("#"+divPageNaviID).find(".AXPaging_end").click(function () {
	        	obj.page.pageNo = pageCount;
	        	pagemovefunc(obj.searchParam);
	        }.bind(this));
		},
		
		setList: function( pObj ){
			var url = this.url;		//coviAlbum.url 설정값
			pObj["pageNo"] = this.page.pageNo;
			pObj["pageSize"] = this.page.pageSize;
			pObj["sortBy"] = this.page.sortBy;
			this.searchParam = pObj;
			
			$.ajax({
				type:"POST",
			    async : false,
				url : url,
				data : this.searchParam,
				success: function(data){
					if(data.status=='SUCCESS'){
						bizCardAlbum.renderAlbumList(data);
						bizCardAlbum.page = data.page;
			   		}else{
			   			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
			   		}
			   	},
			   	error:function(response, status, error){
				     CFN_ErrorAjax(url, response, status, error);
				}
		   });
		}
	};
	window.bizCardAlbum = bizCardAlbum;
})(jQuery);

function BizcardOrgMapLayerPopup(target,openerID){
	parent.Common.open("","bizOrgMap_pop",Common.getDic("CPMail_OrganizationChart"),"/covicore/control/goBizcardOrgChart.do?callBackFunc=setBizcardAutoCallback&type=D9&bizcardKind=USER&openerID="+openerID,"1000px","610px","iframe",true,null,null,true);
}

//조직도에서 클릭
function setBizcardAutoCallback(data){
	var items = JSON.parse(data).item;
	var dupStr = ""; //중복된 데이터
	var noMailStr = ""; //메일 없는 데이터		
	for(var i = 0 ; i < items.length ;  i++){
		var arr = items[i];
		var itemType = arr.itemType;
		var dn	= arr.DN;
		var mail = arr.EM.split(';');
		var name = CFN_GetDicInfo(dn);
		var email = mail[0];
		var code = "";
		
		if(email == ""){
			noMailStr += name + ","
			continue;
		}
		
		if(typeof(itemType) == "undefined") {
			itemType = "bizcard";
			code = arr.ID;
		} else if(itemType == "user"){
			code = arr.UserCode;
		} else {
			code = arr.GroupCode;
		}

		var diffStr = "orgSelectedList_";
		var isOld = false;
		var oldSelectList_people = getSelectedBizcardData();	// 선택한 데이터 가져옴
		if (oldSelectList_people.length != 0) {
			for(var j=0; j<oldSelectList_people.length; j++){
				if(oldSelectList_people[j] == (diffStr + email)){
					dupStr += name +", "
					isOld = true;
					break;
				}
			}
		}
		
		if (!isOld) {
			var dataObj = {"itemType":""+itemType+"","BizCardID":"","Code":""+code+"","Name":""+name+"","EM":""+email+""};
			if (Common.getBaseConfig("CeoUserCode").indexOf(code + ";") > -1) email = "";
			
			var html = "";
				html += "<tr>";
				html += "	<td width='54' align='center'><input type='checkbox' class='BizGroupUser_add_chk' id='orgSelectedList_"+CFN_GetDicInfo(email,lang) +"' name='"+name+"' value='"+ Object.toJSON(dataObj) +"'/></td>";
				html += "	<td width='116' align='center' style='font-size: 10pt;'>" + name + "</td>";
				html += "	<td style='font-size: 10pt;'>" + email + "</td>";
				html += "</tr>";
		  	if( html != ""){
		  		$("#orgSelectedList").append(html); //type: people or dept
		  	}
		}
	}
	
	if(dupStr != ""){
		dupStr = dupStr.substr(0, dupStr.length-2);
		Common.Warning(dupStr +orgDic["msg_OrgMap06"]); //은(는) 이미 선택목록에 추가되어 있습니다.
	}
	if(noMailStr != ""){
		noMailStr = noMailStr.substr(0, noMailStr.length-2);
		Common.Warning(noMailStr +Common.getDic("msg_OrgMap07")); //은(는) 메일정보가 없습니다.
	}
}

$(function() {
});

var bizCardGrid = new coviGrid();

/*

case "이름" : ko_en = 'Name'; break;
	case "기념일" : ko_en = 'AnniversaryText'; break;
	case "이메일" : ko_en = 'Email'; break;
	case "메신저" : ko_en = 'MessengerID'; break;
	case "메모" : ko_en = 'Memo'; break;
	case "핸드폰" : ko_en = 'CellPhone'; break;
	case "자택전화" : ko_en = 'HomePhone'; break;
	case "사무실전화" : ko_en = 'TelPhone'; break;
	case "FAX" : ko_en = 'FAX'; break;
	case "홈페이지" : ko_en = 'ComWebsite'; break;
	case "회사" : ko_en = 'ComName'; break;
	case "부서" : ko_en = 'DeptName'; break;
	case "직책" : ko_en = 'JobTitle'; break;
	case "회사우편번호" : ko_en = 'ComZipcode'; break;
	case "회사주소" : ko_en = 'ComAddress'; break;
 */

//Grid 관련 사항 추가 -
//Grid 생성 관련
function setGrid(object) {
	bizCardGrid.setGridHeader([ {key : 'chk', label : 'chk', width : '20', align : 'center', formatter : 'checkbox'}, 
								{key : 'Name', label : "<spring:message code='Cache.lbl_name'/>", width : '30', align : 'center'}, //이름
						        {key : 'CellPhone', label : "<spring:message code='Cache.lbl_MobilePhone'/>", width : '70', align : 'center'}, //핸드폰
								{key : 'HomePhone',  label:'자택 전화', width:'70', align:'center'},
								{key : 'Email', label :  "<spring:message code='Cache.lbl_Email2'/>", width : '70', align : 'center'}, //이메일
								{key : 'MessengerID', label:'메신저', width:'30', align:'center'},
								{key : 'ComName', label : "<spring:message code='Cache.lbl_Company'/>", width : '50', align : 'center'},  //회사
								{key : 'DeptName', label : "<spring:message code='Cache.lbl_dept'/>", width : '50', align : 'center'},  //부서
								{key : 'JobTitle', label : "<spring:message code='Cache.lbl_JobTitle'/>", width : '50', align : 'center'}, //직책
								{key : 'Memo', label:'메모', width:'100', align:'center'}
								
								//{key:'AnniversaryText',  label:'기념일', width:'30', align:'center'},
								//{key:'TelPhone',  label:'사무실 전화', width:'70', align:'center'},
								//{key:'FAX',  label:'FAX', width:'70', align:'center'},
								//{key:'ComWebsite',  label:'홈페이지', width:'70', align:'center'},									
								//{key:'ComZipcode', label:'회사 우편번호', width:'20', align:'center'},
								//{key:'ComAddress', label:'회사 주소', width:'100', align:'center'}
	]);

	setGridConfig();
	bindGridData(object);
}

function bindGridData(object) {

	bizCardGrid.bindGrid({
		ajaxUrl : "/groupware/bizcard/getImportedBizCardList.do",
		ajaxPars : {
			objectData : object
		}
	});
}

//Grid 설정 관련
function setGridConfig() {
	var configObj = {
		targetID : "bizCardGrid", // grid target 지정
		height : "auto",
		paging : false
	};

	// Grid Config 적용
	bizCardGrid.setGridConfig(configObj);
}

var selDivisionChange = function(obj) {
	var ShareType = $(obj).val();

	if (ShareType != "") {

		$("#selGroup").css('display', '');

		$("#txtNewGroupName").css("display", "none");
		$("#selGroup").find("option").remove();
		//$("#selGroup").append('<option value="">' + "<spring:message code='Cache.lbl_SelectGroup2'/>" + '</option>'); //그룹 선택
		//$("#selGroup").append('<option value="new">' + "<spring:message code='Cache.lbl_newGroup'/>" + '</option>'); //새 그룹
		//$("#selGroup").append('<option value="X">' + "<spring:message code='Cache.lbl_NotSelect'/>" + '</option>'); //선택 안 함
		$("#selGroup").append('<option value="">' + Common.getDic("lbl_SelectGroup2") + '</option>'); //그룹 선택
		$("#selGroup").append('<option value="new">' + Common.getDic("lbl_newGroup") + '</option>'); //새 그룹
		$("#selGroup").append('<option value="X">' + Common.getDic("lbl_NotSelect") + '</option>'); //선택 안 함

		$.ajaxSetup({
			async : true
		});
		$.ajaxSetup({
			// Disable caching of AJAX responses
			cache : false
		});

		$.getJSON('/groupware/bizcard/getGroupList.do', {ShareType : ShareType}, function(d) {
					d.list.forEach(function(d) { 
						$("#selGroup").append('<option value="' + d.GroupID + '">'+ d.GroupName + '</option>');
					});
				}).error(function(response, status, error) {
			//TODO 추가 오류 처리
			CFN_ErrorAjax("getGroupList.do", response, status, error);
		});
	} else {
		$("#selGroup").css('display', 'none');
		$("#txtNewGroupName").css("display", "none");
	}
}

var selGroupChange = function(obj) {
	var selValue = $(obj).val();

	if (selValue == "new") {
		$("#txtNewGroupName").css("display", "");
	} else {
		$("#txtNewGroupName").css("display", "none");
	}
}

var clickAttachFile = function (obj) {
	$("#importedFile").trigger('click');
}

var changeAttachFile = function () {
	if($("#importedFile").val() != "") {
		chkExtension();
	}
}

function chkExtension() {
	var ext = $("#importedFile").val().slice($("#importedFile").val().indexOf(".") + 1).toLowerCase();
	if (ext != "csv" && ext != "xls" && ext != "xlsx" && ext != "txt" && ext != "vcf") {
		//Common.Warning("<spring:message code='Cache.msg_cannotLoadExtensionFile'/>"); //불러올 수 없는 확장자 파일입니다.
		Common.Warning(Common.getDic("msg_cannotLoadExtensionFile"), ""); //불러올 수 없는 확장자 파일입니다.
		
		if (_ie) { // ie
			$("#importedFile").replaceWith($("#importedFile").clone(true));
		} else { // 타브라우저
			$("#importedFile").val("");
		}
	} else {
		$("#importedFileText").text($("#importedFile").val());
	}
}

var type = "";

var showListImportedBizCard = function() {
	if ($('#importedFile').val() == "") {
		//Common.Warning("<spring:message code='Cache.msg_FileNotAdded'/>", ""); //파일이 추가되지 않았습니다.
		Common.Warning(Common.getDic("msg_FileNotAdded"), ""); //파일이 추가되지 않았습니다.
		
		return false;
	}

	$(".divImportedBizCard").css("display", "");
	$("#BizCardList").empty();

	var file = $('#importedFile');
	var fileObj = file[0].files[0];
	var ext = file.val().split(".").pop().toLowerCase();
	
	if (fileObj != undefined) {
		var reader = new FileReader();
		if (ext == "csv") {
			reader.onload = function(e) {
				var csvResult = e.target.result.split(/\r?\n|\r/);
				var arrIndex = new Array();
				var tempStr = "";
				for (var i = 0; i < csvResult.length; i++) {
					var strResult = csvResult[i].replaceAll("\"", "").replaceAll("\t", "").replaceAll(", ", ",").replaceAll(" ,", ",");
					if (i == 0) {
						arrIndex = setIndex(strResult, ext);
					}
					var tempResult = strResult.split(',');
					for (var j = 0; j < tempResult.length; j++) {
						for (var k = 0; k < arrIndex.length; k++) {
							if (arrIndex[k] == j) {
								tempStr += tempResult[j] + "†";
							}
						}
					}
					tempStr = tempStr.slice(0, -1);
					tempStr += "§";
				}
				setGrid(tempStr);
			}
			reader.readAsText(fileObj, "EUC-KR");
		} else if(ext == "vcf") {
			var url = "/groupware/bizcard/getImportVCardBizCardPerson.do";
			
			var formData = new FormData();
			var file = $('#importedFile');
			var fileObj = file[0].files[0];
			
			formData.append("fileObj", fileObj);
			
			$.ajax({
				url : url,
				type : "POST",
				data : formData,
				dataType : 'json',
				processData : false,
				contentType : false,
				success : function(result) {
					try {
						if(result.status == "SUCCESS") {
							var csvResult = result.data;
							var arrIndex = new Array();
							var tempStr = "";
							for (var i = -1; i < csvResult.length; i++) {
								var tempResult;
								if (i == -1) {
									var strResult = ("이름,이메일,핸드폰,회사,부서,직함");
									
									arrIndex = setIndex(strResult, ext);
									tempResult = strResult.split(',');
									
									for(var j = 0; j < arrIndex.length; j++) {
										tempStr += tempResult[j] + "†";
									}
									
									tempStr = tempStr.slice(0, -1);
									tempStr += "§";
								} else {
									tempResult = csvResult[i];
									
									tempStr += tempResult.Name + "†";
									tempStr += tempResult.Email + "†";
									tempStr += tempResult.CellPhone + "†";
									tempStr += tempResult.ComName + "†";
									tempStr += tempResult.DeptName + "†";
									tempStr += tempResult.JobTitle + "§";
								}
							}
							setGrid(tempStr);
						} else {
							Common.Warning(result.msessage);
						}
					} catch (e) {
						Common.Warning("<spring:message code='Cache.msg_ErrorRegistBizCard'/>"); //연락처 등록 오류가 발생하였습니다.
					}
				},
				error : function(response, status, error) {
					//TODO 추가 오류 처리
					CFN_ErrorAjax(url, response, status, error);
				}
			});
		} else {
			var reader = new FileReader();
		    
		    reader.onload = function (e) {
		        var data = reader.result;
		        var workBook = XLSX.read(data, { type: 'binary' });
		        
		        var tempStr = "";
		        workBook.SheetNames.forEach(function (sheetName) {
		            var rows = XLSX.utils.sheet_to_json(workBook.Sheets[sheetName]);
		            
		            if(rows.length > 0) {
		            	//var keys = Object.keys(rows[0]);
						 var keys = ["이름","핸드폰","자택전화","이메일","메신저","회사","부서","직책","메모"];
					
						for (var j = 0; j < keys.length; j++) {
							var key = keys[j];
			            	tempStr += key + "†";
						}
						
						tempStr = tempStr.slice(0, -1);
						tempStr += "§";
			            
			            for(var i = 0; i < rows.length; i++) {
							//var keys = Object.keys(rows[i]);
							
							for (var j = 0; j < keys.length; j++) {
								var key = keys[j];
				            	if(rows[i][key] != undefined){
									tempStr += rows[i][key] + "†";
								} else{
									tempStr += "†";
								}
							}
							
							tempStr = tempStr.slice(0, -1);
							tempStr += "§";
			            }
		            } 
		        });
		        
		        setGrid(tempStr);
		    };
		    reader.readAsBinaryString(fileObj);
		}			
	}
}

function setIndex(str, ext) {
	//모든 따옴표 제거
	if (str[0] == '"')
		str = str.substring(1, str.length - 1);

	//마지막 문자가 따옴표이면 삭제
	if (str[str.length - 1] == '"')
		str = str.substring(0, str.length - 1);

	//","을 콤마로 변경
	//str = str.replaceAll('\",\"', ',').replaceAll(',\"', ',').replaceAll('\",', ',').replaceAll('\t', '').replaceAll(', ', '');
	var arrTemp = str.split(',');
	var returnArr = new Array();
	var type = ext.toUpperCase();
	
	if(type != "VCF") {
		if (arrTemp[0].trim() == "이름") {
			type = "CSV_EX";
		} else {
			type = "CSV";
		}
	}
	
	for (var i = 0; i < arrTemp.length; i++) {
		if (type == "CSV_EX") {
			switch (arrTemp[i].trim()) {
			case "전체 이름":
				returnArr.push(i);
				break;
			case "전자 메일 주소":
				returnArr.push(i);
				break;
			case "전화":
				returnArr.push(i);
				break;
			case "휴대폰":
				returnArr.push(i);
				break;
			case "주소(회사)":
				returnArr.push(i);
				break;
			case "우편 번호(회사)":
				returnArr.push(i);
				break;
			case "회사 웹 페이지":
				returnArr.push(i);
				break;
			case "회사 전화":
				returnArr.push(i);
				break;
			case "회사 팩스":
				returnArr.push(i);
				break;
			case "회사":
				returnArr.push(i);
				break;
			case "직함":
				returnArr.push(i);
				break;
			case "부서":
				returnArr.push(i);
				break;
			case "메모":
				returnArr.push(i);
				break;
			case "기념일":
				returnArr.push(i);
				break;
			case "메신저":
				returnArr.push(i);
				break;
			}
		} else if (type == "VCF") {
			switch (arrTemp[i].trim()) {
			case "이름":
				returnArr.push(i);
				break;
			case "이메일":
				returnArr.push(i);
				break;
			case "핸드폰":
				returnArr.push(i);
				break;
			case "회사":
				returnArr.push(i);
				break;
			case "부서":
				returnArr.push(i);
				break;
			case "직함":
				returnArr.push(i);
				break;	
			}
		} else {
			switch (arrTemp[i].trim()) {
			case "이름":
				returnArr.push(i);
				break;
			case "회사":
				returnArr.push(i);
				break;
			case "부서":
				returnArr.push(i);
				break;
			case "직함":
				returnArr.push(i);
				break;
			case "근무지 주소 번지":
				returnArr.push(i);
				break;
			case "근무지 우편 번호":
				returnArr.push(i);
				break;
			case "근무지 팩스":
				returnArr.push(i);
				break;
			case "근무처 전화":
				returnArr.push(i);
				break;
			case "집 전화 번호":
				returnArr.push(i);
				break;
			case "휴대폰":
				returnArr.push(i);
				break;
			case "메모":
				returnArr.push(i);
				break;
			case "웹 페이지":
				returnArr.push(i);
				break;
			case "전자 메일 주소":
				returnArr.push(i);
				break;
			case "기념일":
				returnArr.push(i);
				break;
			case "메신저":
				returnArr.push(i);
				break;
			default:
				if(arrTemp[i].trim().indexOf("전자 메일") > -1
					&& arrTemp[i].trim().indexOf("주소") > -1){
					returnArr.push(i);
				}
			}
		}
	}

	return returnArr;
}

var importBizCard = function(gridObj,saveType) {
	var checkCheckList = gridObj.getCheckedList(0); // 체크된 리스트 객체
	var wholeList = gridObj.getList();

	if ($("#selDivision").val() == "") {
		//Common.Warning("<spring:message code='Cache.msg_SelectDivision2'/>", ""); //구분을 선택하세요.
		Common.Warning(Common.getDic("msg_SelectDivision2"), ""); //구분을 선택하세요.
		return false;
	} else if ($("#selGroup").val() == "") {
		//Common.Warning("<spring:message code='Cache.msg_SelectGroup2'/>", ""); //그룹을 선택하세요.
		Common.Warning(Common.getDic("msg_SelectGroup2"), ""); //그룹을 선택하세요.
		return false;
	} else if ($("#selGroup").val() == "new"
			&& $("#txtNewGroupName").val() == "") {
		//Common.Warning("<spring:message code='Cache.msg_EnterNewGroupName'/>", ""); //새 그룹명을 입력하세요.
		Common.Warning(Common.getDic("msg_EnterNewGroupName"), ""); //새 그룹명을 입력하세요.
		return false;
	} else if (saveType != 'A' && checkCheckList.length == 0) {
		Common.Warning(Common.getDic("msg_apv_003")); //선택된 항목이 없습니다.
		return false;
	}

	var formData = new FormData();
	var length = 0;
	var list;
	
	if(saveType == 'A') {
		length = wholeList.length;
		list = wholeList;
	} else {
		length = checkCheckList.length;
		list = checkCheckList;
	}
	
	for (var i = 0; i < length; i++) {
		formData.append("Data[" + i + "].Name", list[i].Name);
		if (list[i].AnniversaryText != undefined)
			formData.append("Data[" + i + "].AnniversaryText", list[i].AnniversaryText);
		if (list[i].Email != undefined)
			formData.append("Data[" + i + "].Email", list[i].Email.replaceAll(", ", ":"));
		if (list[i].MessengerID != undefined)
			formData.append("Data[" + i + "].MessengerID", list[i].MessengerID);
		if (list[i].Memo != undefined)
			formData.append("Data[" + i + "].Memo", list[i].Memo.replaceAll("|", "\r\n"));
		if (list[i].CellPhone != undefined)
			formData.append("Data[" + i + "].CellPhone", list[i].CellPhone);
		if (list[i].HomePhone != undefined)
			formData.append("Data[" + i + "].HomePhone", list[i].HomePhone);
		if (list[i].TelPhone != undefined)
			formData.append("Data[" + i + "].TelPhone", list[i].TelPhone);
		if (list[i].FAX != undefined)
			formData.append("Data[" + i + "].FAX", list[i].FAX);
		if (list[i].ComWebsite != undefined)
			formData.append("Data[" + i + "].ComWebsite", list[i].ComWebsite);
		if (list[i].ComName != undefined)
			formData.append("Data[" + i + "].ComName", list[i].ComName);
		if (list[i].DeptName != undefined)
			formData.append("Data[" + i + "].DeptName", list[i].DeptName);
		if (list[i].JobTitle != undefined)
			formData.append("Data[" + i + "].JobTitle", list[i].JobTitle);
		if (list[i].ComZipcode != undefined)
			formData.append("Data[" + i + "].ComZipcode", list[i].ComZipcode);
		if (list[i].ComAddress != undefined)
			formData.append("Data[" + i + "].ComAddress", list[i].ComAddress);
	}	

	formData.append("ShareType", $("#selDivision").val());
	formData.append("GroupID", $("#selGroup").val());
	formData.append("GroupName", $("#txtNewGroupName").val());

	var url = "/groupware/bizcard/RegistImportBizCardPerson.do";
	var message = Common.getDic("msg_SuccessRegistClearDuplicate"); //정상적으로 등록되었습니다.\n중복 연락처를 정리하시겠습니까?\n\n[확인]->[중복 제거],\n[닫기]->[중복 포함]

	$.ajax({
		url : url,
		type : "POST",
		data : formData,
		dataType : 'json',
		processData : false,
		contentType : false,
		success : function(d) {
			try {
				if (d.result == "OK") {
					Common.Confirm(message, 'Information Dialog', function(result) {
						if(result) {
							window.location.href = "/groupware/layout/bizcard_OrganizeBizCard.do?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard";
						} else {
							parent.window.location.reload();
						}
						
					});
				} else if (d.result == "FAIL") {
					Common.Warning("<spring:message code='Cache.msg_ErrorRegistBizCard'/>"); //연락처 등록 오류가 발생하였습니다.
				}
			} catch (e) {
				coviCmn.traceLog(e);
			}
		},
		error : function(response, status, error) {
			//TODO 추가 오류 처리
			CFN_ErrorAjax(url, response, status, error);
		}
	});
}

// 템플릿 파일 다운로드
function templateDownload(type) {  
		if (confirm(Common.getDic("msg_bizcard_downloadTemplateFiles"))) {
			
			if(type == "EXCEL"){
			location.href = '/groupware/bizcard/excelTemplateDownload.do?fileType='+type;
			}else{
				location.href = '/groupware/bizcard/csvTemplateDownload.do?fileType='+type;
			}
			
	}
}

/*메일 쓰기 이동*/
function goWriteMail(obj){
	if(Common.getBaseConfig("isUseMail") == "Y" && Common.getBaseConfig("isUseExchMail") == "Y"){
		// param setting
		var popupId = "write_"+sessionStorage.getItem("writePopupCount");
		
		// 그리드 선택된 사용자 메일 정보.
		var checkCheckList = bizCardGrid.getCheckedList(0);
		if(checkCheckList == 0){
			Common.Inform(Common.getDic("msg_mail_selectRecipient"), Common.getDic("CPMail_info_msg")); // 수신인을 선택해주세요.
			return;
		} else {
			var isMail = false;		
			for(var i=0; i<checkCheckList.length; i++){
				var user = checkCheckList[i];
				if(user.EMAIL != "") {
					isMail = true;
				}
			}
			
			var mailToList = excMailSet(checkCheckList);
			
			if(mailToList.length > 0) {
			// 전송 데이터 세팅
				MailJsonData = {
				  "Token": GetEncryptToken(), // 인증용 JWT 토큰
				  "Subject": "", // 메일 제목
				  "Body": "", // 메일 본문
				  "To": excMailSet(checkCheckList), // 받는 사람
				  "Cc": [], // 참조
				  "Bcc": [], // 숨은 참조
				  "Attachment": [] // 첨부 파일
				};
				
				exch_mailSend(MailJsonData);
			} else {
				Common.Inform(Common.getDic("msg_mail_chk_email"), Common.getDic("CPMail_info_msg")); // 선택한 연락처에 이메일이 없습니다.
				return;	
			}
		}
	} else {
		// param setting
		var popupId = "write_"+sessionStorage.getItem("writePopupCount");
		
		// 그리드 선택된 사용자 메일 정보.
		var checkCheckList = bizCardGrid.getCheckedList(0);
		if(checkCheckList == 0){
			Common.Inform(Common.getDic("msg_mail_selectRecipient"), Common.getDic("CPMail_info_msg")); // 수신인을 선택해주세요.
			return;
		} else {
			var isMail = false;		
			for(var i=0; i<checkCheckList.length; i++){
				var user = checkCheckList[i];
				if (user.BizCardType == "BizCard"){
				// 일반 등록 사용자 체크
					if(user.EMAIL != "") {
						isMail = true;
					}
				}else if (user.BizCardType == "Group"){
					// 그룹 사용자 체크				
					// 전체보기일 경우 BizCardID. 그룹보기일 경우 GroupID
					var groupID = user.BizCardID ? user.BizCardID : user.GroupID;
					// 그룹 사용자 메일주소 확인
					$.ajax({
						type: "POST",
						async: false,
						data: {
							groupID: groupID
						},
						url: "/groupware/bizcard/getBizCardGroupMemberList.do",
						success: function(data) {
							if (data.list != null && data.list.length > 0 && data.list.length != null) {
								$(data.list).each(function(nIdx, oElm) {
									if(oElm.EMAIL != "") {
										isMail = true;
									}
								});
							}
						}
					});
				}
			}
			
			if(isMail) {
				window.open("/mail/bizcard/goMailWritePopup.do?"
					+"callBackFunc=mailWritePopupCallback"
					+"&callMenu=" + "BizCard"
					+ "&userMail=" + Common.getSession("UR_Mail") 
					+ "&inputUserId=" + Common.getSession().DN_Code + "_" + Common.getSession().UR_Code
					+ "&popup=Y"
					+ "&popupId="+popupId
					+ "&bizCardSendType="+"S",
					"MailWriteCommonPopup", "height=800, width=1000, resizable=yes");
			} else {
				Common.Inform(Common.getDic("msg_mail_chk_email"), Common.getDic("CPMail_info_msg")); // 선택한 연락처에 이메일이 없습니다.
				return;	
			}
		}
	}
}