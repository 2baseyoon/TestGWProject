<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="appBox" style="height: calc(100% - 66px);">
	<div class="appList_top_b searchBox02" style="left: auto;">
		<select id="selSearchType" class="selectType02" style="width: 100px;"></select>
		<input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ onClickSearchButton(); return false;}" style="margin-left: 5px">
		<a id="detailSearchBtn" onclick="onClickSearchButton()" class="btnTypeDefault btnSearchBlue nonHover" style="margin-left: 5px"><spring:message code="Cache.btn_search"/></a>
		
		<select id="selBaseYear" class="selectType02" style="width: 90px; margin-left: 5px"></select>
		<select id="subDeptList" class="selectType02" style="width: 90px; margin-left: 5px; display: none"></select>
		
		<select id="selRecordStatus" class="selectType02" style="width: 90px; margin-left: 5px">
			<option value=""><spring:message code='Cache.lbl_all'/></option> <!-- 선택 -->
			<option value="0"><spring:message code='Cache.lbl_blankRecordFile'/></option> <!-- 공철 -->
			<option value="1"><spring:message code='Cache.lbl_filingOngoing'/></option> <!-- 편철진행중 -->
			<option value="5"><spring:message code="Cache.lbl_abolition"/></option> <!-- 폐지 -->
		</select>
	
		<select id="selTakeover" class="selectType02" style="width: 90px; margin-left: 5px">
			<option value=""><spring:message code='Cache.lbl_all'/></option> <!-- 선택 -->
			<option value="0"><spring:message code='Cache.lbl_NotApplicable'/></option> <!-- 해당없음 -->
			<option value="1"><spring:message code='Cache.lbl_takeover'/></option> <!-- 인수 -->
			<option value="2"><spring:message code='Cache.lbl_handover'/></option> <!-- 인계 -->
		</select>
	</div>
	
	<div id="divSearchList_Main" class="appList" style="overflow: hidden; width: 100%; min-height: calc((100% - 30px) - 10px); max-height: calc((100% - 30px) - 10px);">
		<div id="recordListGrid"></div>
	</div>
	
	<div class="arrowBtn divTypeM" style="left: 74.5%; display: none">
		<input type="button" class="btnRight" value=">" onclick="sendRight()">
	</div>
	
	<div class="appSel divTypeM" style="width: 20%; margin-bottom: 0px; height: calc(100%); display: none">
		<div class="selTop" style="height: 100% !important;">
			<table class="tableStyle t_center hover infoTableBot">
				<colgroup>
					<col style="width:30px">
					<col style="width:*">
				</colgroup>
				<thead>
					<tr>
						<td colspan="2"><h3 class="titIcn"></h3></td>
					</tr>
				</thead>
				<tbody id="selectedData">
				</tbody>
			</table>
		</div>
	</div>
</div>

<div class="popBtn">
	<a id="btnSave" class="btnTypeDefault btnTypeChk"></a>
	<a id="btnClose" class="btnTypeDefault mr30" onclick="Common.Close(); return false;"><spring:message code='Cache.btn_apv_close' /></a> <!-- 닫기 -->
</div>

<script>
	const ListGrid = new coviGrid();
	const callType = CFN_GetQueryString('callType'); // 호출한 화면의 기능타입 (integration:통합, seperation:분리)
	const opentype = CFN_GetQueryString('type');
	let isAdmin = '';
	let seriesHeaderData;
	
	window.onload = init();
	function init() {
		if (callType == 'integration') { // 통합
			document.querySelector('h3.titIcn').textContent = '<spring:message code='Cache.Approval_lbl_SelectedArchives' />'; <!-- 선택된 기록물철 -->
			document.getElementById('btnSave').innerText = '<spring:message code='Cache.btn_ok' />'; <!-- 확인 -->
			
			document.getElementById('btnSave').addEventListener('click', () => {
				confirmData();
			});
			
			if (opentype == 'S') {
				document.getElementById('divSearchList_Main').style.width = '100%';
			} else {
				document.getElementById('divSearchList_Main').style.width = '75%';
				document.querySelectorAll('div.divTypeM').forEach((div) => { div.style.display = '' });
				
				// 부모창에 선택된 기록물철이 있는 경우 우츨 "선택된 기록물철" 영역에 세팅
				setSelectedData(CFN_GetQueryString('selected'), true);
			}
		} else if (callType == 'separation') { // 분리
			document.querySelector('h3.titIcn').textContent = '<spring:message code='Cache.Approval_lbl_SelectedRecordDoc' />'; <!-- 선택된 기록물 -->
			document.getElementById('btnSave').innerText = '<spring:message code='Cache.btn_save' />'; <!-- 저장 -->

			document.getElementById('btnSave').addEventListener('click', () => {
				saveData();
			});
			
			document.getElementById('divSearchList_Main').style.width = '75%';
			document.querySelector('div.appSel').style.width = '24%';
			document.querySelector('div.appSel').style.marginLeft = '10px';
			document.querySelector('div.appSel').style.display = '';
			
			// 부모창에 선택된 기록물철이 있는 경우 우츨 "선택된 기록물철" 영역에 세팅
			setSelectedData(CFN_GetQueryString('selected'), true);
		}
		
		// 조회용 select set
		setSearchTypeList();
		setDeptList();
		setYearList();
		
		// 목록 grid set
		setGrid();
		
		// 조회용 select event set
		$("#selBaseYear, #subDeptList, #selRecordStatus, #selTakeover").on("change", onClickSearchButton);
	}
	
	// 조회조건용 조건 조회
	function setSearchTypeList(){
		$.ajax({
			url: "/approval/user/selectRecordDocComboData.do",
			type: "POST",
			dataType: "json",
			async: false,
			success: function(data){
				let list = data.searchTypeList;
				let listOption = "";
				
				$.each(list, function(idx, item){
					listOption += "<option value='"+item.optionValue+"'>"+item.optionText+"</option>";
				});
				
				$("#selSearchType").html(listOption);
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
			}
		});
	}

	// 조회조건용 부서 조회
	function setDeptList(){
		$.ajax({
			url: "/approval/user/getDeptSchList.do",
			type: "POST",
			dataType: "json",
			async: false,
			success: function(data){
				isAdmin = data.isAdmin;
				let subDeptList = data.list;
				let subDeptOption = "";
				let selDept = "";
				
				if(isAdmin == "Y"){
					subDeptOption += "<option value=''><spring:message code='Cache.lbl_Whole'/></option>"; //전체
				}else{
					selDept = Common.getSession("DEPTID");
				}
					
				$.each(subDeptList, function(idx, item){
					subDeptOption += "<option value='"+item.GroupCode+"'>"+item.TransMultiDisplayName+"</option>";
				});
				
				if (subDeptList.length > 0) {
					$("#subDeptList").show();
				}
				
				$("#subDeptList").html(subDeptOption);
				$("#subDeptList").val(selDept);
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
			}
		});
	}
	
	// 조회조건용 년도 조회
	function setYearList() {
		$.ajax({
			url: "/approval/user/getRecordBaseYearList.do",
			type: "POST",
			dataType: "json",
			async: false,
			success: function(data){
				baseYear = new Date().getFullYear();
				const list = data.list;
				let baseYearHtml = '';
				if(isAdmin == "Y"){
					list.unshift({"BaseYear" : "<spring:message code='Cache.lbl_all'/>"});
				}
				
				$.each(list, function(idx, item){
					baseYearHtml += "<option value='"+item.BaseYear+"'>"+item.BaseYear+"</option>";
				});
				
				$("#selBaseYear").html(baseYearHtml);
				$("#selBaseYear").val(baseYear);
			},
			error: function(error){
				Common.Error("<spring:message code='Cache.msg_apv_030' />"); // 오류가 발생했습니다.
			}
		});
	}
	
	// 그리드 조회
	function setGrid() {
		setGridConfig();
		setRecordGFileListData();
	}

	// 그리드 환경 세팅
	function setGridConfig() {
		const headerData = [
							{key:'chk', label:'chk', width:'10', align:'center', formatter:'checkbox', sort:false},
							{key:'RecordSubject', label:'<spring:message code="Cache.lbl_recordFileTitle"/>', width:'30', align:'center'}, // 기록물철 제목
							{key:'RecordStatusTxt', label:'<spring:message code="Cache.lbl_recordState"/>', width:'20', align:'center'}, // 기록물철 상태
							{key:'RCnt', label:'<spring:message code="Cache.lbl_recordNumber"/>', width:'20', align:'center'}, // 기록물 건수
							{key:'RecordProductName', label:'<spring:message code="Cache.lbl_oldRecordProductName"/>', width:'30', align:'center'}, // 기록물생산기관명
							{key:'SeriesName', label:'<spring:message code="Cache.lbl_unitTaskName"/>', width:'30', align:'center'}, // 단위업무명
							{key:'EndYear', label:'<spring:message code="Cache.lbl_endYear"/>', width:'15', align:'center'}, // 종료연도
							{key:'KeepPeriodTxt', label:'<spring:message code="Cache.lbl_preservationPeriod"/>', width:'15', align:'center'}, // 보존기간
							{key:'TakeoverCheckTxt', label:'<spring:message code="Cache.lbl_handoverClass"/>', width:'20', align:'center'}, // 인수인계 구분
							{key:'RecordSeq', label:'<spring:message code="Cache.lbl_apv_SerialNo"/>', width:'20', align:'center'} // 일련번호
						];
		
		seriesHeaderData = headerData;
		ListGrid.setGridHeader(headerData);
		
		const configObj = {
			targetID: "recordListGrid",
			height: "auto",
			listCountMSG: "<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", // 개
			body: {
				onclick: function(){
					const url = "/approval/user/getRecordGFileAddPopup.do?mode=R&recordClassNum=" + this.item.RecordClassNum;
					const popupName = "<spring:message code='Cache.lbl_inquiryRecordFile' />"; // 기록물철 조회
					
					parent.Common.open("", "addRecord", popupName, url, "400px", "460px", "iframe", true, null, null, true);
				}
			},
			page: {
				pageNo: 1,
				pageSize: 10
			},
			paging: true,
		};
		
		ListGrid.setGridConfig(configObj);
	}
	
	// 기록물철 검색
	function onClickSearchButton() {
		ListGrid.page.pageNo = 1;
		setRecordGFileListData();
	}
	
	// 기록물철 검색할 파라미터 정리
	function setSelectParam() {
		let params = {};
		
		params.searchType = document.getElementById('selSearchType').value;
		params.searchWord = document.getElementById('searchInput').value;
		params.searchMode = "NotFile";
		params.takeOverCheck = document.getElementById('selTakeover').value;
		params.recordStatus = document.getElementById('selRecordStatus').value;
		params.baseYear = document.getElementById('selBaseYear').value == "전체" ? "" : document.getElementById('selBaseYear').value;
		params.deptCode = document.getElementById('subDeptList').value;
		
		return params;
	}
	
	// 기록물철 검색
	function setRecordGFileListData() {
		var selectParams = setSelectParam();
		
		ListGrid.bindGrid({
			ajaxUrl: "/approval/user/getRecordGFileListData.do",
			ajaxPars: selectParams,
			onLoad: function(){
				$(".gridBodyTable > tbody > tr").css("cursor", "pointer");
				coviInput.init();
			}
		});
	}
	
	// 부모창에서 선택된 데이터 세팅
	function setSelectedData(data, isLoad) {
		const dataArray = isLoad ? $.parseJSON(decodeURIComponent(data)) : data;
		const selectedData = document.getElementById('selectedData');
		const delImg = '<td onclick="this.parentNode.remove();"><img src="/HtmlSite/smarts4j_n/covicore/resources/images/common/bul_x_btn.png" alt="" /></td>';
		
		if (callType == 'integration') { // 통합 : 기록물철
			dataArray.forEach((item) => {
				if (item.RecordClassNum != '') {
					$(selectedData).append('<tr data-recordsubject="' + item.RecordSubject + '" data-recordclassnum="' + item.RecordClassNum + '">' + delImg + '<td class="subject">' + item.RecordSubject + '</td></tr>');
				}
			});
		} else {
			dataArray.forEach((item) => { // 분리 : 기록물
				if (item.RecordDocumentID != '') {
					$(selectedData).append('<tr data-docsubject="' + item.DocSubject + '" data-recorddocumentid="' + item.RecordDocumentID + '">' + delImg + '<td class="subject">' + item.DocSubject + '</td></tr>');
				}
			});
		}
	}
	
	// 선택된 기록물철 우측으로 넘기기
	function sendRight() {
		const checkedList = ListGrid.getCheckedList(0);
		
		if (checkedList.length == 0) {
			Common.Warning("<spring:message code='Cache.msg_apv_003' />"); //선택된 항목이 없습니다.
		} else {
			const selectedRecordGFile = document.getElementById('selectedData');
			const selectedRecordGFileList = Array.from(selectedRecordGFile.getElementsByTagName('tr'));
			let dupMsg = '';
			let isDup = false;
			let isRevoke = false;
			let selectedData = [];
			
			checkedList.forEach((item) => {
				if(item.RecordStatus == "5") {
					isRevoke = true;
				} else {
					isDup = false;
					// 중복 체크
					selectedRecordGFileList.some((tr) => { 
						if (tr.dataset.recordclassnum == item.RecordClassNum) {
							isDup = true;
							dupMsg += item.RecordSubject + ', ';
							return true;
						}
					});
					if (!isDup) {
						selectedData.push(item);
					}
				}
			});
			
			if (dupMsg != '') {
				dupMsg = dupMsg.substr(0, dupMsg.length - 2);
				Common.Warning('[' + dupMsg + ']<br/><spring:message code='Cache.Approval_msg_FileAlreadySelected' />'); // 이미 선택된 기록물철입니다.
			} else if (isRevoke) {
				Common.Warning('<spring:message code='Cache.Approval_msg_NotRecordGFile' />'); // 폐지된 기록물철은 통합할 수 없습니다. 선택에서 제외 되었습니다.
			}
			
			// 선택된 기록물철로 넘기기
			setSelectedData(selectedData);
			
			// 체크 해제
			if (document.querySelector('[name="checkAll"]').checked) {
				document.querySelector('[name="checkAll"]').click();
			} else {
				document.querySelectorAll('[name="chk"]:checked').forEach((obj) => { obj.click(); });
			}
		}
	}
	
	// 선택된 기록물철 전달
	function confirmData() {
		let rtn = [];
		let bChk = true;
		
		if (opentype == 'M') {
			const selectedRecordGFileList = Array.from(selectedData.getElementsByTagName('tr'));
			selectedRecordGFileList.forEach((tr) => {
				rtn.push(Object.assign({}, tr.dataset));
			});
		} else {
			const checkedList = ListGrid.getCheckedList(0);
			
			if (checkedList.length == 0) {
				Common.Warning("<spring:message code='Cache.msg_apv_003' />"); // 선택된 항목이 없습니다.
				bChk = false;
			} else if (checkedList.length > 1) {
				Common.Warning("<spring:message code='Cache.msg_SelectOne' />"); // 한개만 선택되어야 합니다
				bChk = false;
			} else if (checkedList[0].RecordStatus == "5") {
				Common.Warning("<spring:message code='Cache.msg_alreadyAbolishRecordFile' />"); // 이미 폐지된 기록물철입니다.
				bChk = false;
			} else {
				rtn.push({'recordsubject':checkedList[0].RecordSubject, 'recordclassnum':checkedList[0].RecordClassNum});
			}
		}
		
		if (bChk) {
			XFN_CallBackMethod_Call(CFN_GetQueryString('openerID'), CFN_GetQueryString('callBackFunc'), rtn);
			Common.Close();
		}
	}

	// 선택된 기록물철로 기록물 분리
	function saveData() {
		const checkedList = ListGrid.getCheckedList(0);
		const recordClassNum = CFN_GetQueryString('recordClassNum');
		const selectedRecordDocList = [];
		Array.from(selectedData.getElementsByTagName('tr')).forEach((tr) => {
			selectedRecordDocList.push(tr.dataset.recorddocumentid);
		});
		
		if (checkedList.length == 0) {
			Common.Warning("<spring:message code='Cache.msg_apv_003' />"); // 선택된 항목이 없습니다.
		} else if (selectedRecordDocList.length == 0) {
			Common.Warning("<spring:message code='Cache.Approval_msg_NotSelectedRecordDoc' />"); // 선택된 기록물이 없습니다.
		} else if (checkedList.length > 1) {
			Common.Warning("<spring:message code='Cache.msg_SelectOne' />"); // 한개만 선택되어야 합니다
		} else if (checkedList[0].RecordStatus == "5") {
			Common.Warning("<spring:message code='Cache.msg_alreadyAbolishRecordFile' />"); // 이미 폐지된 기록물철입니다.
		} else if (checkedList[0].RecordClassNum == recordClassNum) {
			Common.Warning("<spring:message code='Cache.Approval_msg_NotSameRecordGFile' />"); // 동일한 기록물철로 분리가 불가능합니다. 다른 기록물철을 선택하세요.
		} else {
			const recordSubject = checkedList[0].RecordSubject;
			Common.Confirm('<spring:message code='Cache.Approval_msg_RURecordGFile_SeparationRecordDoc' />'.replace(/\{0\}/g, recordSubject), 'Confirm', function(result) { // [{0}] 기록물철로 선택한 기록물들을 분리하겠습니까?
				if (result) {
					const params = {'recordclassnum':checkedList[0].RecordClassNum, 'selectedRecordDoc': selectedRecordDocList.join()};
					const url = '/approval/user/updateRecordDocSeparation.do';

	   		   		$.ajax({
	   					url: url,
	   					type: "POST",
	   					data: params,
	   					success: function(data){
	   						if(data.status == 'SUCCESS'){
	   							Common.Inform(data.message, 'Inform', function() {
	   								parent.onClickSearchButton();
   									Common.Close();
	   							});
	   						} else {
	   							Common.Error('<spring:message code='Cache.msg_apv_030' />');  // 오류가 발생했습니다.
	   						}
	   					},
	   					error: function(error){
	   						Common.Error('<spring:message code='Cache.msg_apv_030' />');  // 오류가 발생했습니다.
	   					}
	   				});
				}
			});
		}
	}
</script>