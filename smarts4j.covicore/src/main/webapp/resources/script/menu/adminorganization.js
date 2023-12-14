
//새로고침
function Refresh() {
	//window.location.reload();
	orgGrid.reloadList();
}

// 팝업 닫기
function closePopup() {
	Common.Close();
}

// Select 바인딩
function bindSelect() {

	$.ajaxSetup({
		cache : false
	});
	
	$.ajax({
		async : false,
		type : "POST",
		data : {
			"domainCode" : $.urlParam('domainCode')
		},
		url : "/covicore/admin/orgmanage/getdomainlist.do",
		success : function(data) {
			if (data.status == "FAIL") {
				Common.Error(data.message);
				return;
			}

			$("#domainSelectBox").bindSelect({
				reserveKeys : {
					optionValue : "optionValue",
					optionText : "optionText"
				},
				options : data.list,
				ajaxAsync : false,
				onchange : function() {
					onClickSearchButton();
				}
			});
		},
		error : function(response, status, error) {
			// TODO 추가 오류 처리
			CFN_ErrorAjax("/covicore/admin/orgmanage/getdomainlist.do", response, status, error);
		}
	});

}

/**
 * 삭제 param : 그리드 객체
 */
function DeleteCheck(gridObj) {

	var checkCheckList = gridObj.getCheckedList(0);// 체크된 리스트 객체
	var TargetIDTemp = []; // 체크된 항목 저장용 배열
	var TargetID = ""; // 체크된 항목을 문장으로 나열 (A;B; . . ;)

	if (checkCheckList.length == 0) {
		Common.Inform(Common.getDic("msg_apv_003")); // 선택된 항목이 없습니다.
	} else if (checkCheckList.length > 0) {

		for (var i = 0; i < checkCheckList.length; i++) {
			TargetIDTemp.push(checkCheckList[i].GroupCode);
		}

		TargetID = TargetIDTemp.join(",");

		Common.Confirm(Common.getDic("msg_apv_093"), "Inform", function(result) {
			if (result) {
				$.ajax({
					url : "/covicore/admin/orgmanage/deletearbitrarygrouplist.do",
					type : "post",
					data : {
						"TargetID" : TargetID
					},
					async : false,
					success : function(res) {
						if(res.status == "FAIL") {
							Common.Warning(Common.getDic("msg_existGroupmember").replace("{0}",res.message));
						} else {
							gridObj.reloadList();
							// closeLayer();
						}
					},
					error : function(response, status, error) {
						CFN_ErrorAjax( "/covicore/admin/orgmanage/deletearbitrarygrouplist.do", response, status, error);
					}
				});
			}
		});
	} else {
		Common.Error(Common.getDic("msg_ScriptApprovalError"));
	}
}

// 위로 버튼 클릭시 실행되며, 해당 항목을 위로 이동합니다.
function moveUp(gridObj) {

	var checkCheckList = gridObj.getCheckedList(0);// 체크된 리스트 객체
	if (checkCheckList.length == 0) {
		Common.Inform(Common.getDic("msg_apv_003")); // 선택된 항목이 없습니다.
	} else if (checkCheckList.length > 0) {

		var sGroupCode_A = 0;
		var sGroupCode_B = 0;

		var oPrevTR = null;
		var oNowTR = null;

		var oResult = null;
		var bSucces = true;
		var sResult = "";
		var sErrorMessage = "";

		var nLength = gridObj.list.length;
		for (var i = 0; i < nLength; i++) {
			if (!gridObj.list[i].___checked[0]) {
				continue;
			}

			// 현재 행: 위에서부터 선택 되어 있는 행 찾기
			oNowTR = gridObj.list[i];

			// 이전 행 찾기: 현재 행 기준 위에서 선택 안되어 있는 행 찾기
			oPrevTR = null;
			for (var j = i - 1; j >= 0; j--) {
				if (gridObj.list[j].GroupCode == undefined) {
					break;
				}
				if (gridObj.list[j].___checked[0]) {
					continue;
				}
				oPrevTR = gridObj.list[j];
				break;
			}
			if (oPrevTR == null) {
				continue;
			}

			sGroupCode_A = oNowTR.GroupCode;
			sGroupCode_B = oPrevTR.GroupCode;

			$.ajax({
				url : "/covicore/admin/orgmanage/movesortkey.do",
				type : "post",
				data : {
					"pStrGR_Code_A" : sGroupCode_A,
					"pStrGR_Code_B" : sGroupCode_B
				},
				async : false,
				success : function(res) {
					/* 방법 1 : 그리드 로드 */
					gridObj.reloadList();

					/* 방법 2 : Jquery로 우선순위 값 및 행 위치 변경(미완성-gridObj 값도 변경 필요) */
					// 우선순위 값 변경
					/*
					 * sTemp = oNowTR.SortKey; oNowTR.SortKey = oPrevTR.SortKey;
					 * oPrevTR.SortKey = sTemp; //행 위치 변경 oNowTR =
					 * $('span').filter( function(){ return $(this).text() ==
					 * oNowTR.GR_Code; }).closest('tr'); oPrevTR =
					 * $('span').filter( function(){ return $(this).text() ==
					 * oPrevTR.GR_Code; }).closest('tr');
					 * oPrevTR.insertAfter(oNowTR);
					 */
				},
				error : function(response, status, error) {
					CFN_ErrorAjax("/covicore/admin/orgmanage/movesortkey.do", response, status, error);
				}
			});// ajax
		}// for
	}// if
}// func

// 아래로 버튼 클릭시 실행되며, 해당 항목을 아래로 이동합니다.
function moveDown(gridObj) {

	var checkCheckList = gridObj.getCheckedList(0);// 체크된 리스트 객체
	if (checkCheckList.length == 0) {
		Common.Inform(Common.getDic("msg_apv_003")); // 선택된 항목이 없습니다.
	} else if (checkCheckList.length > 0) {

		var sGroupCode = 0;
		var sGroupCode = 0;

		var oNextTR = null;
		var oNowTR = null;

		var oResult = null;
		var bSucces = true;
		var sResult = "";
		var sTemp = "";
		var sErrorMessage = "";

		var nLength = gridObj.list.length;
		for (var i = nLength - 1; i >= 0; i--) {
			if (!gridObj.list[i].___checked[0]) {
				continue;
			}

			// 현재 행: 아래에서부터 선택되어 있는 행 찾기
			oNowTR = gridObj.list[i];

			// 다음 행 찾기: 현재 행 기준 아래에서 선택 안되어 있는 행 찾기
			oNextTR = null;
			for (var j = i + 1; j < nLength; j++) {
				if (gridObj.list[j].GroupCode == undefined) {
					break;
				}
				if (gridObj.list[j].___checked[0]) {
					continue;
				}
				oNextTR = gridObj.list[j];
				break;
			}
			if (oNextTR == null) {
				continue;
			}

			let sGroupCode_A = oNowTR.GroupCode;
			let sGroupCode_B = oNextTR.GroupCode;

			$.ajax({
				url : "/covicore/admin/orgmanage/movesortkey.do",
				type : "post",
				data : {
					"pStrGR_Code_A" : sGroupCode_A,
					"pStrGR_Code_B" : sGroupCode_B
				},
				async : false,
				success : function(res) {
					/* 방법 1 : 그리드 로드 */
					gridObj.reloadList();

					/* 방법 2 : Jquery로 우선순위 값 및 행 위치 변경(미완성-gridObj 값도 변경 필요) */
					// 우선순위 값 변경
					/*
					 * sTemp = oNowTR.SortKey; oNowTR.SortKey = oNextTR.SortKey;
					 * oNextTR.SortKey = sTemp; //행 위치 변경 oNowTR =
					 * $('span').filter( function(){ return $(this).text() ==
					 * oNowTR.GR_Code; }).closest('tr'); oNextTR =
					 * $('span').filter( function(){ return $(this).text() ==
					 * oNextTR.GR_Code; }).closest('tr');
					 * oNowTR.insertAfter(oNextTR);
					 */
				},
				error : function(response, status, error) {
					CFN_ErrorAjax("/covicore/admin/orgmanage/movesortkey.do", response, status, error);
				}
			});// ajax
		}// for
	}// if
}// func

// 설정 변경(사용여부, 인사연동여부, 메일사용여부 등
function changeSetting(pType, pCode, pGroupType, gridObj) {
	if(pGroupType == undefined)
		pGroupType = "";
	$.ajax({
		url : "/covicore/admin/orgmanage/changearbitrarygroupsetting.do",
		type : "POST",
		data : {
			"type" : pType,
			"GroupType" : pGroupType,
			"targetCode" : pCode,
			"tobeValue" : $("#AXInputSwitch_" + pType + "_" + pCode).val()
		},
		async : false,
		success : function(data) {
			// 바인딩할 Selector, Param, DisplayName, width, align, checkbox, ? )
			if(data.status == "FAIL" && pType == "IsUse") {
				Common.Warning(Common.getDic("msg_existGroupmember").replace("{0}",data.message));
				gridObj.reloadList();
			} else {
				Common.Inform("성공적으로 갱신되었습니다.")
			}
		},
		error : function(error) {
			CFN_ErrorAjax("/covicore/admin/orgmanage/changearbitrarygroupsetting.do", response, status, error);
		}
	});
}

// 임의그룹 코드, 임의그룹 명, 회사명 가져오기
function setGroupPopDefaultInfo(pDomainCode, pTypeName) {

	$.ajax({
		type : "POST",
		data : {
			"domainCode" : pDomainCode,
			"groupType" : pTypeName
		},
		url : "/covicore/admin/orgmanage/getdefaultsetinfo.do",
		success : function(data) {
			
			if (data.list.length > 0) {
				if (pTypeName != "Region") {
					$("#txtCompanyName").val(data.list[0].CompanyName);
					
					// 2021.11.22 직위/직급/직책의 prefix 사용 여부를 saas 여부와 분리.
					if(Common.getGlobalProperties("disablePrefix") != "Y") {
						if (pTypeName == "JobTitle") {
							$("#txtPfx").text("T"); 
						}
						else if (pTypeName == "JobPosition") {
							$("#txtPfx").text("P");
						}
						else if (pTypeName == "JobLevel") {
							$("#txtPfx").text("L");
						}
					}
					
					//Saas 지원 프로젝트인 경우 처리
					if(Common.getGlobalProperties("isSaaS") == "Y") {
						$("#txtSfx").text("_" + data.list[0].CompanyID);						
						$("#txtMailID").attr("readonly", "readonly");
						$("#selMailDomain").attr("disabled","disabled");
						$("#selMailDomain").val(data.list[0].CompanyURL);
					}
				} else {
					$("#selCompanyCode option[value='" + data.list[0].CompanyID + "']").prop("selected", true);
				}
				$("#hidCompanyID").val(data.list[0].CompanyID);
			}
		},
		error : function(response, status, error) {
			CFN_ErrorAjax("system/covicore/admin/orgmanage/getdefaultsetinfo.do", response, status, error);
		}
	});
}

// 숫자 형식 제한
var writeNum = function(obj) {
	// Validation Chk
	var inputKey = event.key;
	var inputBox = $(obj);
	var value = inputBox.val();

	if (_ie) {
		if (inputKey == "Decimal")
			inputKey = ".";
	}

	// 숫자 및 소수점이 아닌 문자 치환
	value = value.replace(/[^0-9.]/g, '');

	value = value == "" ? "0" : value;

	// 숫자형식으로 변경
	// 숫자형식이거나 event에 바인딩되어 넘어오지 않은경우
	if (inputKey != ".") {
		value = parseFloat(value); // 반올림 첫번째자리까지
		inputBox.val(value);
	} else if (inputKey == ".") {
		inputBox.val(value);
	}
	return false;
};

//엑셀 다운로드
function excelDownload(type){
	Common.Confirm(Common.getDic("msg_ExcelDownMessage"), "Confirmation Dialog", function(result){
   		if(result){
   			var headerName = getHeaderNameForExcel(type);
   			var	sortKey = "SortKey";
   			var	sortWay = "ASC";	
   			var domain = $("#domainCodeSelectBox :selected").val();
   			
   			if(type!='region'){
   				location.href = "/covicore/admin/orgmanage/orglistexceldownload.do?sortColumn=" + sortKey + "&sortDirection=" + sortWay + "&type=" + type + "&groupType=" + type + "&companyCode=" + domain + "&headerName=" + encodeURI(encodeURIComponent(headerName));
   			}
   			else{
   				location.href = "/covicore/admin/orgmanage/orglistexceldownload.do?sortColumn=" + sortKey + "&sortDirection=" + sortWay + "&type=" + type + "&groupType=" + type + "&companyCode=" + encodeURIComponent($("#domainCodeSelectBox").val()) + "&headerName=" + encodeURI(encodeURIComponent(headerName));
   			}
   		}
	});
}

//엑셀용 Grid 헤더정보 설정
function getHeaderNameForExcel(type){
	var msgHeaderData = getGridHeader(type);
	var returnStr = "";
	
   	for(var i=0;i<msgHeaderData.length; i++){
   	   	if(msgHeaderData[i].display != false && msgHeaderData[i].label != 'chk'){
			returnStr += msgHeaderData[i].label + ";";
   	   	}
	}
	
	return returnStr;
}

//중복 확인-메일
function checkDuplicateMail(mode, codeName) {
	var stringRegx = /[\s\{\}\[\]?,;:|\)*~`!^\+┼<>@\#$%&\\(\=\'\"]/;
	var stringRegx2 = /[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/;
	var mailAddress= $('#txtMailID').val() + '@' + $('#selMailDomain').val();
	var userId = $('#txtLogonIDSaaS').val() + '@' + $('#selMailDomain').val();
	var isSaaS = Common.getGlobalProperties("isSaaS");
										  
	if($('#txtMailID').val() == "" || $('#selMailDomain').val() == "") {
		Common.Warning(Common.getDic("msg_NeedMailUrl"));//Mail 주소를 입력해 주십시오.
		check_dupMail = "N";
	} else{
		if(stringRegx.test($("#txtMailID").val())) {
			Common.Warning(Common.getDic("msg_specialNotAllowed"), 'Warning Dialog', function() {
				$("#txtMailID").focus();
			});
			return false;
		} else if(stringRegx2.test($("#txtMailID").val())) {
			Common.Warning(Common.getDic("msg_KoreanNotAllowed"), 'Warning Dialog', function() {
				$("#txtMailID").focus();
			});
			return false;
		} else if(isSaaS == "N" && $("#txtUserDisplayName").val() == "") {
			Common.Warning(Common.getDic("msg_ObjectUR_08"), 'Warning Dialog', function() {
				$("#txtUserDisplayName").focus();
			});
			return false;
		}

		var userData = {
						"selectedEmail" : mailAddress,
						"selectedEmailAlias" : mailAddress,
						"selectedEmailAliasPrefix" : "",
						"selectedEmailAliasPostFix" : "",
						"userName" : $('#txtUserDisplayName').val(),
						"codeName" : codeName
					   };
		
		var deptData = {
						"selectedEmail" : mailAddress,
						"selectedEmailAlias" : mailAddress,
						"selectedEmailAliasPrefix" : "",
						"selectedEmailAliasPostFix" : "",
						"codeName" : codeName
					   };
		
		$.ajax({
			type:"POST",
			data:{
				"MailAddress" : mailAddress,
				"Code" : mode == "add"? '' : $("#txt"+codeName+"Code").val()//$('#txtUserCode').val() 또는 $('#txtDeptCode').val() 또는 $('#txtGroupCode').val()
			},
			url:"/covicore/admin/orgmanage/getisduplicatemail.do",
			success:function (data) {
				if(data.status != "FAIL") {
					if(data.list[0].isDuplicate > 0) {
						Common.Warning(Common.getDic("msg_exist_mailaddress"));//이미 존재하는 메일주소 입니다.
						$('#txtGroupCode').focus();
						check_dupMail = "N";
					} else {
						/*Common.Inform("<spring:message code='Cache.msg_allow_mail'/>" );//사용 가능한 메일 주소 입니다.
						check_dupMail = "Y";
						return true;*/
						 if("Y" == Common.getBaseConfig('IsSyncIndi')){
								$.ajax({
									type:"GET",
									url:"/mail/manageMailBox/isExistMailBoxAlias.do",
									data:(codeName == "User") ? userData : deptData,
									success:function (datamail) {
										if(datamail.status == "FAIL"){
											Common.Warning(Common.getDic("CPMail_AnErrorOccurred"), Common.getDic("CPMail_warning_msg"));//Msg : 오류가 발생했습니다.
											check_dupMail = "N";
										}else{
											if(datamail.aliasListSize > 0) {
												var valid = false;
												$.each(datamail.aliasList,function(idx,item){									
													if((item.email_alias != item.email)) {
														valid= true;
														return false;
													}
												});
												if(valid){
													Common.Warning(Common.getDic("msg_exist_mailaddress"));		//이미 존재하는 메일입니다.
													check_dupMail = "N";
												}
												else{
													Common.Inform(Common.getDic("msg_possible_mailaddress")); 	//사용 가능한 메일주소 입니다.
													check_dupMail = "Y";	
												}
											}else {
												Common.Inform(Common.getDic("msg_possible_mailaddress")); 	//사용 가능한 메일주소 입니다.
												check_dupMail = "Y";	
											}	
										}
									},
									error:function (error){
										Common.Error(error.message);
									}
								});							
						    }else{
								Common.Inform(Common.getDic("msg_possible_mailaddress")); //사용 가능한 메일주소 입니다.
								check_dupMail = "Y";							
						    }
					}
				} else {
					Common.Warning(data.message);
					check_dupMail = "N";
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/admin/orgmanage/getisduplicatemail.do", response, status, error);
			}
		});
	}
}