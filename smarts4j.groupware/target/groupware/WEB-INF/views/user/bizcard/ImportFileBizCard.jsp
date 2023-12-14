<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<head>
<script type="text/javascript" src="/groupware/resources/script/user/bizcard.js"></script>
<script type="text/javascript" src="/groupware/resources/script/user/bizcard_list.js"></script>
<script type="text/javascript" src="/groupware/resources/script/user/xlsx.full.min.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv='cache-control' content='no-cache'>
<meta http-equiv='expires' content='0'>
<meta http-equiv='pragma' content='no-cache'>
<style>
.wrap_div {
	width: 100%;
	margin: 13px;
}

.divExplain {
	color: gray;
	line-height: 23px;
	margin-top: 10px;
}

.divContent {
	margin-top: 15px;
}

.file {
	height: 34px;
	width: 97%;
	line-height: 25px;
	border: 1px solid #bababa;
	background: #fff;
	z-index: 10;
}

.file_txt {
	display: inline-block;
	padding: 3px 0 0 13px;
}

.file_img {
	width: 18px;
	height: 18px;
}
</style>
</head>

<div> <!--  class="commContRight" -->
	<div class="cRConTop titType">
		<h2 class="title"><spring:message code='Cache.lbl_bizcard_importContact' /></h2>
	</div>
	<div class="cRContBottom mScrollVH">
		<div class="bizcardAllCont">
			<div class="bizcardListBox">
				<div class="topInfoBox">
					<ul class="bulDashedList">
						<li><span class="icoTheme icoInputFile"></span> <spring:message code='Cache.lbl_bizcard_importContactExplain1' /></li>
						<li><spring:message code='Cache.lbl_bizcard_importContactExplain2' /></li>
						<li><spring:message code='Cache.lbl_bizcard_importContactExplain3' /> : Outlook Express, Outlook, Excel</li><!--  : Outlook Express, Outlook, Excel -->
					</ul>
					
					<div style="padding-top: 7px;">
						<a onclick="templateDownload('CSV_EX');" class="btnTypeDefault btnExcel">CSV(Express) Template</a>
						<a onclick="templateDownload('CSV');" class="btnTypeDefault btnExcel">CSV Template</a>
						<a onclick="templateDownload('EXCEL');" class="btnTypeDefault btnExcel">Excel Template</a>
					</div>
					
					<!-- 파일 불러오기 -->
					<div class="grayBox02">
						<input type="file" id="importedFile" style="display: none;" accept=".csv, .xls, .xlsx" onchange="changeAttachFile()"><!-- accept=".csv, .xls, .xlsx, .txt"  -->
						<div class="inputFileForm" onclick="clickAttachFile(this);">
							<strong class="txtFileName" id="importedFileText"></strong>
							<span class="btnTypeDefault btnIco btnThemeLine btnInputFile"></span>
						</div>
					</div>
					<div class="btnArea">
						<a class="btnTypeDefault btnThemeBg" id="btnImport" onclick="showListImportedBizCard();"><spring:message code='Cache.btn_fileOpen' /></a>
					</div>
					<!-- // 파일 불러오기 -->
				</div>

				<div class="bizcardTopCont">
					<select class="selectType02 size102" id="selDivision" onchange="selDivisionChange(this)">
						<option value=""><spring:message code='Cache.lbl_SelectDivision2' /></option> <!-- 구분 선택 -->
						<option value="P"><spring:message code='Cache.lbl_ShareType_Personal' /></option> <!-- 개인 -->
						<option value="D"><spring:message code='Cache.lbl_ShareType_Dept' /></option> <!-- 부서 -->
						<option value="U"><spring:message code='Cache.lbl_ShareType_Comp' /></option> <!-- 회사 -->
					</select>
					<select class="selectType02 size102" id="selGroup" style="display: none;" onchange="selGroupChange(this)">
					</select>
					<input type="text" id="txtNewGroupName" placeholder="<spring:message code='Cache.lbl_bizcard_enterNewGroupName' />" style="float: unset; display: none;"/>
				</div>

				<!-- 목록보기-->
				<div class="divContent divImportedBizCard" style="display: none; clear: both;">
					<div id="bizCardGrid"></div>
				</div>
				<div class="btnBttmWrap">
					<a class="btnTypeDefault btnTypeChk" onclick="importBizCard(bizCardGrid, '');"><spring:message code='Cache.lbl_bizcard_registToContact' /></a>
				</div>
				<!-- // 목록보기-->

				<div class="bottomInfoBox">
					<dl>
						<dt class="bulDashedTitle"><span class="colorTheme">*</span> <spring:message code='Cache.lbl_bizcard_incomingContact' /></dt>
						<dd>
							<ul class="bulDashedList">
								<li><spring:message code='Cache.lbl_bizcard_incomingContactExplain1' /></li>
								<li><spring:message code='Cache.lbl_bizcard_incomingContactExplain2' /></li>
								<li><spring:message code='Cache.lbl_bizcard_incomingContactExplain3' /></li>
							</ul>
						</dd>
					</dl>
				</div>
			</div>
		</div>												
	</div>					
</div>

<script>
	$(function() {
	});

	var bizCardGrid = new coviGrid();

	function setGrid(object) {
		bizCardGrid.setGridHeader([ {key : 'chk', label : 'chk', width : '20', align : 'center', formatter : 'checkbox'}, 
		                            {key : 'Name', label : "<spring:message code='Cache.lbl_name'/>", width : '30', align : 'center'}, 				// 이름
		                            {key : 'CellPhone', label : "<spring:message code='Cache.lbl_MobilePhone'/>", width : '70', align : 'center'}, 	// 핸드폰									
									{key : 'Email', label : "<spring:message code='Cache.lbl_Email2'/>", width : '70', align : 'center'}, 			// 이메일
									{key : 'MessengerID', label: "<spring:message code='Cache.lbl_Messanger'/>", width:'30', align:'center'}, 		// 메신저
									{key : 'ComName', label : "<spring:message code='Cache.lbl_Company'/>", width : '100', align : 'center'},  		// 회사
									{key : 'ComPhone', label : "<spring:message code='Cache.lbl_Office_Line'/>", width : '50', align : 'center'},  	// 사무실전화
									{key : 'FAX', label : "<spring:message code='Cache.lbl_Office_Fax'/>", width : '50', align : 'center'},  		// 팩스
									{key : 'DeptName', label : "<spring:message code='Cache.lbl_dept'/>", width : '100', align : 'center'},  		// 부서
									{key : 'JobTitle', label : "<spring:message code='Cache.lbl_JobTitle'/>", width : '50', align : 'center'}, 		// 직책
									{key : 'Memo', label: "<spring:message code='Cache.lbl_Memo'/>", width:'100', align:'center'},					// 메모
									{key : 'EtcPhone', label: "<spring:message code='Cache.lbl_EtcPhone'/>", width:'50', align:'center'},			// 기타전화
									{key : 'HomePhone',  label: "<spring:message code='Cache.lbl_HomePhone'/>", width:'70', align:'center'}, 		// 자택전화
									{key : 'DirectPhone', label: "<spring:message code='Cache.lbl_DirectPhone'/>", width:'80', align:'center'}		// 직접입력전화
		]);

		setGridConfig();
		bindGridData(object);
	}
	
	function setCSVGrid(object) {
		bizCardGrid.setGridHeader([ {key : 'chk', label : 'chk', width : '20', align : 'center', formatter : 'checkbox'}, 
		                            {key : 'Name', label : "<spring:message code='Cache.lbl_name'/>", width : '30', align : 'center'}, 				// 이름
		                            {key : 'CellPhone', label : "<spring:message code='Cache.lbl_MobilePhone'/>", width : '70', align : 'center'}, 	// 핸드폰									
									{key : 'Email', label : "<spring:message code='Cache.lbl_Email2'/>", width : '70', align : 'center'}, 			// 이메일
									{key : 'MessengerID', label: "<spring:message code='Cache.lbl_Messanger'/>", width:'30', align:'center'}, 		// 메신저
									{key : 'ComName', label : "<spring:message code='Cache.lbl_Company'/>", width : '100', align : 'center'},  		// 회사
									{key : 'ComPhone', label : "<spring:message code='Cache.lbl_Office_Line'/>", width : '50', align : 'center'},  	// 사무실전화
									{key : 'FAX', label : "<spring:message code='Cache.lbl_Office_Fax'/>", width : '50', align : 'center'},  		// 팩스
									{key : 'DeptName', label : "<spring:message code='Cache.lbl_dept'/>", width : '100', align : 'center'},  		// 부서
									{key : 'HomePhone',  label: "<spring:message code='Cache.lbl_HomePhone'/>", width:'70', align:'center'}, 		// 자택전화
									{key : 'JobTitle', label : "<spring:message code='Cache.lbl_JobTitle'/>", width : '50', align : 'center'}, 		// 직책
									{key : 'Memo', label: "<spring:message code='Cache.lbl_Memo'/>", width:'100', align:'center'}					// 메모
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
			$("#selGroup").append('<option value="">' + "<spring:message code='Cache.lbl_SelectGroup2'/>" + '</option>'); //그룹 선택
			$("#selGroup").append('<option value="new">' + "<spring:message code='Cache.lbl_newGroup'/>" + '</option>'); //새 그룹
			$("#selGroup").append('<option value="X">' + "<spring:message code='Cache.lbl_NotSelect'/>" + '</option>'); //선택 안 함

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
		if (ext != "csv" && ext != "xls" && ext != "xlsx" && ext != "txt") {
			Common.Warning("<spring:message code='Cache.msg_cannotLoadExtensionFile'/>"); //불러올 수 없는 확장자 파일입니다.
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
			Common.Warning("<spring:message code='Cache.msg_FileNotAdded'/>", ""); //파일이 추가되지 않았습니다.
			return false;
		}

		$(".divImportedBizCard").css("display", "");
		$("#BizCardList").empty();

		var file = $('#importedFile');
		var fileObj = file[0].files[0];
		var ext = file.val().split(".").pop().toLowerCase();
		var thtd = "";
		
		var l_HtmlCheckValue = false;
		var l_ScriptCheckValue = false;

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
							arrIndex = setIndex(strResult);
						}
						var tempResult = strResult.split(',');
						for (var j = 0; j < tempResult.length; j++) {
							for (var k = 0; k < arrIndex.length; k++) {
								if (arrIndex[k] == j) {									
									if (XFN_CheckHTMLinText(tempResult[j])) {
										l_HtmlCheckValue = true;
									}
									
									if (XFN_CheckInputLimit(tempResult[j])) {
										l_ScriptCheckValue = true;
									}
									
									if(l_HtmlCheckValue || l_ScriptCheckValue) {
										if (l_ScriptCheckValue) { 	// 스크립트 입력불가
											l_WarningMsg = Common.getDic("msg_ThisPageLimitedScript");
										} else {  					// HTML 테그 입력 불가
											l_WarningMsg = Common.getDic("msg_ThisPageLimitedHTMLTag");
										}
										
										Common.Warning(l_WarningMsg, "");
										return false;
									}
									
									tempStr += tempResult[j] + "†";
								}
							}
						}
						tempStr = tempStr.slice(0, -1);
						tempStr += "§";
					}
					
					setCSVGrid(tempStr);
				}
				reader.readAsText(fileObj, "EUC-KR");
			} else {
			    var reader = new FileReader();
			    
			    reader.onload = function (e) {
			        var data = reader.result;
			        var workBook = XLSX.read(data, { type: 'binary' });
			        
			        var tempStr = "";
			        workBook.SheetNames.forEach(function (sheetName) {
			            var rows = XLSX.utils.sheet_to_json(workBook.Sheets[sheetName]);
			            
			            if(rows.length > 0) {
							var keys = [Common.getDic("lbl_name"),Common.getDic("lbl_MobilePhone"),Common.getDic("lbl_Email2"),Common.getDic("lbl_Messanger"),Common.getDic("lbl_Company"),Common.getDic("lbl_Office_Line"),Common.getDic("lbl_Office_Fax"),Common.getDic("lbl_dept"),Common.getDic("lbl_JobTitle"),Common.getDic("lbl_Memo"),Common.getDic("lbl_EtcPhone"),Common.getDic("lbl_HomePhone"),Common.getDic("lbl_DirectPhone")];
			            	
							for (var j = 0; j < keys.length; j++) {
								var key = keys[j];
				            	tempStr += key + "†";
							}
							
							tempStr = tempStr.slice(0, -1);
							tempStr += "§";
				            
				            for(var i = 0; i < rows.length; i++) {								
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

	var keyValueArr = new Array();

	function setIndex(str) {
		//모든 따옴표 제거
		if (str[0] == '"')
			str = str.substring(1, str.length - 1);

		//마지막 문자가 따옴표이면 삭제
		if (str[str.length - 1] == '"')
			str = str.substring(0, str.length - 1);

		var arrTemp = str.split(',');
		var _nIndexCnt = arrTemp.length;
		var returnArr = new Array();

		if (arrTemp[0].trim() == "이름") {
			type = "CSV_EX";
		} else {
			type = "CSV";
		}

		for (var i = 0; i < arrTemp.length; i++) {
			if (type == "CSV_EX") {
				switch (arrTemp[i].trim()) {
				case "전체 이름":
					keyValueArr.push({'Name' : i});
					returnArr.push(i);
					break;
				case "전자 메일 주소":
					keyValueArr.push({'Email' : i});
					returnArr.push(i);
					break;
				case "전화":
					keyValueArr.push({'HomePhone' : i});
					returnArr.push(i);
					break;
				case "휴대폰":
					keyValueArr.push({'CellPhone' : i});
					returnArr.push(i);
					break;
				case "주소(회사)":
					keyValueArr.push({'ComAddress' : i});
					returnArr.push(i);
					break;
				case "우편 번호(회사)":
					keyValueArr.push({'ComZipcode' : i});
					returnArr.push(i);
					break;
				case "회사 웹 페이지":
					keyValueArr.push({'ComWebsite' : i});
					returnArr.push(i);
					break;
				case "회사 전화":
					keyValueArr.push({'TelPhone' : i});
					returnArr.push(i);
					break;
				case "회사 팩스":
					keyValueArr.push({'FAX' : i});
					returnArr.push(i);
					break;
				case "회사":
					keyValueArr.push({'ComName' : i});
					returnArr.push(i);
					break;
				case "직함":
					keyValueArr.push({'JobTitle' : i});
					returnArr.push(i);
					break;
				case "부서":
					keyValueArr.push({'DeptName' : i});
					returnArr.push(i);
					break;
				case "메모":
					keyValueArr.push({'Memo' : i});
					returnArr.push(i);
					break;
				case "기념일":
					keyValueArr.push({'AnniversaryText' : i});
					returnArr.push(i);
					break;
				case "메신저":
					keyValueArr.push({'MessengerID' : i});
					returnArr.push(i);
					break;
				}
			} else {
				switch (arrTemp[i].trim()) {
				case "이름":
					keyValueArr.push({'Name' : i});
					returnArr.push(i);
					break;
				case "회사":
					keyValueArr.push({'ComName' : i});
					returnArr.push(i);
					break;
				case "부서":
					keyValueArr.push({'DeptName' : i});
					returnArr.push(i);
					break;
				case "직함":
					keyValueArr.push({'JobTitle' : i});
					returnArr.push(i);
					break;
				case "근무지 주소 번지":
					keyValueArr.push({'ComAddress' : i});
					returnArr.push(i);
					break;
				case "근무지 우편 번호":
					keyValueArr.push({'ComZipcode' : i});
					returnArr.push(i);
					break;
				case "근무지 팩스":
					keyValueArr.push({'FAX' : i});
					returnArr.push(i);
					break;
				case "근무처 전화":
					keyValueArr.push({'TelPhone' : i});
					returnArr.push(i);
					break;
				case "집 전화 번호":
					keyValueArr.push({'HomePhone' : i});
					returnArr.push(i);
					break;
				case "휴대폰":
					keyValueArr.push({'CellPhone' : i});
					returnArr.push(i);
					break;
				case "메모":
					keyValueArr.push({'Memo' : i});
					returnArr.push(i);
					break;
				case "웹 페이지":
					keyValueArr.push({'ComWebsite' : i});
					returnArr.push(i);
					break;
				case "전자 메일 주소":
					keyValueArr.push({'Email' : i});
					returnArr.push(i);
					break;
				case "기념일":
					keyValueArr.push({'AnniversaryText' : i});
					returnArr.push(i);
					break;
				case "메신저":
					keyValueArr.push({'MessengerID' : i});
					returnArr.push(i);
					break;
				default:
					if(arrTemp[i].trim().indexOf("전자 메일") > -1
						&& arrTemp[i].trim().indexOf("주소") > -1){
						keyValueArr.push({'Email' : i});
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
			Common.Warning("<spring:message code='Cache.msg_SelectDivision2'/>", ""); //구분을 선택하세요.
			return false;
		} else if ($("#selGroup").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_SelectGroup2'/>", ""); //그룹을 선택하세요.
			return false;
		} else if ($("#selGroup").val() == "new"
				&& $("#txtNewGroupName").val() == "") {
			Common.Warning("<spring:message code='Cache.msg_EnterNewGroupName'/>", ""); //새 그룹명을 입력하세요.
			return false;
		} else if (saveType != 'A' && checkCheckList.length == 0) {
			Common.Warning("<spring:message code='Cache.msg_apv_003'/>"); //선택된 항목이 없습니다.
			return false;
		}

		formData = new FormData();
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
			if (list[i].Email != undefined){
				var emailCheck = list[i].Email.split(":");
			    var regex=/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([A-Za-z]{2,6}(?:\.[A-Za-z]{2})?)$/;
			    for(var j=0; j<emailCheck.length; j++){
		        if(list[i].Email != '' && regex.test(emailCheck[j]) === false) {
		           Common.Warning(list[i].Name+"("+emailCheck[j]+") : "+"<spring:message code='Cache.msg_bizcard_invalidEmailFormat'/>","");
		           return false;
		           }
		        }
				formData.append("Data[" + i + "].Email", list[i].Email.replaceAll(",", ":"));
			}
			if (list[i].MessengerID != undefined)
				formData.append("Data[" + i + "].MessengerID", list[i].MessengerID);
			if (list[i].Memo != undefined)
				formData.append("Data[" + i + "].Memo", list[i].Memo.replaceAll("|", "\r\n"));
			if (list[i].CellPhone != undefined)
				formData.append("Data[" + i + "].CellPhone", list[i].CellPhone);
			if (list[i].HomePhone != undefined)
				formData.append("Data[" + i + "].HomePhone", list[i].HomePhone);
			if (list[i].ComPhone != undefined)
				formData.append("Data[" + i + "].ComPhone", list[i].ComPhone);
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
			if (list[i].EtcPhone != undefined)
				formData.append("Data[" + i + "].EtcPhone", list[i].EtcPhone);
			if (list[i].DirectPhone != undefined)
				formData.append("Data[" + i + "].DirectPhone", list[i].DirectPhone);
		}	

		formData.append("ShareType", $("#selDivision").val());
		formData.append("GroupID", $("#selGroup").val());
		formData.append("GroupName", $("#txtNewGroupName").val());

		url = "/groupware/bizcard/RegistImportBizCardPerson.do";

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
						Common.Confirm(Common.getDic("msg_SuccessRegistClearDuplicate"), 'Information Dialog', function(result) { // 정상적으로 등록되었습니다.\n중복 연락처를 정리하시겠습니까?\n\n[확인]->[중복 제거],\n[닫기]->[중복 포함]
							if(result) {
								window.location.href = "/groupware/layout/bizcard_OrganizeBizCard.do?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard";
							} else {
								parent.window.location.reload();
							}
							
						});
					} else if (d.result == "FAIL") {
						if(d.type == "Phone"){
							Common.Warning(Common.getDic("msg_ErrorRegistPhone").replace("{0}", d.data.Name)); //{0}의 전화번호 등록 중 오류가 발생하였습니다.
						} else if(d.type == "Email"){
							Common.Warning(Common.getDic("msg_ErrorRegistEmail").replace("{0}", d.data.Name)); //{0}의 이메일 등록 중 오류가 발생하였습니다.
						} else if(d.type == "Anniversary"){
							Common.Warning(Common.getDic("msg_ErrorRegistAnniversary").replace("{0}", d.data.Name)); //{0}의 기념일 정보 등록 중 오류가 발생하였습니다.
						} else{
							Common.Warning("<spring:message code='Cache.msg_ErrorRegistBizCard'/>"); //연락처 등록 오류가 발생하였습니다.
						}
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
		Common.Confirm("<spring:message code='Cache.msg_bizcard_downloadTemplateFiles'/>", "Confirm Dialog", function(result){
	 		if (result) { 			
	 			if(type == "EXCEL"){
					location.href = '/groupware/bizcard/excelTemplateDownload.do?fileType='+type;
	 			}else{
	 				location.href = '/groupware/bizcard/csvTemplateDownload.do?fileType='+type;
	 			}
	 			
			}
		});
	}
</script>