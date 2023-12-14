<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp" />

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">	
		<div class="popContent" style="position:relative;">
			<div class="middle">
				<table class="tableTypeRow">
					<colgroup>
						<col style="width: 25%;">
						<col style="width: 75%;">
					</colgroup>
					<tbody>
						<tr>
							<th><font color="red">* </font><spring:message code="Cache.Approval_lbl_TargetFile" /></th> <!-- 대상기록물철 -->
							<td>
								<input type="text" id="targetRecordSubject" style="width: 90%; margin-left: 5px;" readonly>
								<input type="hidden" id="targetRecordClassNum">
								<button class="btnTblSearch" onclick="openRecordGFileListPopup('M');" style="display: inline-block;"></button>
							</td>
						</tr>
						<tr>
							<th><font color="red">* </font><spring:message code="Cache.Approval_lbl_IntegratedFile" /></th> <!-- 통합기록물철 -->
							<td>
								<input type="text" id="intergrationRecordSubject" style="width: 90%; margin-left: 5px;" readonly>
								<input type="hidden" id="intergrationRecordClassNum">
								<button class="btnTblSearch" onclick="openRecordGFileListPopup('S');" style="display: inline-block;"></button>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a id="btnSave" class="btnTypeDefault btnTypeChk"><spring:message code='Cache.btn_save' /></a> <!-- 저장 -->
				<a id="btnClose" class="btnTypeDefault" onclick="Common.Close(); return false;"><spring:message code='Cache.btn_apv_close' /></a> <!-- 닫기 -->
			</div>
		</div>
	</div>
</div>

<script>
	const openerID = CFN_GetQueryString("CFN_OpenLayerName");
	let selectType = '';
	document.getElementById('btnSave').addEventListener('click', () => {
		saveIntergrationRecord();
	});
	
	window.onload = init();
	function init() {
		const recordClassNum = CFN_GetQueryString('recordClassNum');
		const recordSubject = CFN_GetQueryString('recordSubject');
		
		document.getElementById('targetRecordSubject').value = decodeURIComponent(recordSubject).replace(/;\|\|;/ig, ', ');
		document.getElementById('targetRecordSubject').setAttribute('title', document.getElementById('targetRecordSubject').value);
		document.getElementById('targetRecordClassNum').value = recordClassNum;
	}
	
	// 저장
	function saveIntergrationRecord() {
		let targetRecordClassNum = document.getElementById('targetRecordClassNum').value;
		let intergrationRecordClassNum = document.getElementById('intergrationRecordClassNum').value;
		
		if (targetRecordClassNum == '') {
			Common.Warning('대상기록물철을 선택하세요.', 'Warning', function () {
				openRecordGFileListPopup('M');
			});
			return false;
		} else if (intergrationRecordClassNum == '') {
			Common.Warning('통합기록물철을 선택하세요.', 'Warning', function () {
				openRecordGFileListPopup('S');
			});
			return false;
		} else if (intergrationRecordClassNum == targetRecordClassNum) {
			Common.Warning('대상/통합기록물철이 동일합니다. 다시 확인하시기 바랍니다.', 'Warning', function () {
			});
			return false;
		} else {
			Common.Confirm('<spring:message code='Cache.msg_RUSave' />', 'Confirm', function(result) { // 저장하시겠습니까?
   				if (result) {
   					targetRecordClassNum = targetRecordClassNum.split(',').filter(item => item != intergrationRecordClassNum).join(); // 중복제외
	   				let url = '/approval/user/setRecordGFileIntergration.do';
	   		   		let params = { targetRecordClassNum, intergrationRecordClassNum };

	   		   		$.ajax({
	   					url: url,
	   					type: "POST",
	   					data: params,
	   					success: function(data){
	   						if(data.status == 'SUCCESS'){
	   							Common.Inform(data.message, 'Inform', function() {
	   								parent.Refresh();
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
	
	// 기록물철 검색 팝업 오픈
	function openRecordGFileListPopup(type) {
		selectType = type;
		const popupID = 'selectRecordGFilePopup';
		const popupName = '<spring:message code="Cache.Approval_lbl_FileSearch"/>'; // 기록물철 검색
		const selected = type == 'M' ? getSelectedValue() : '';
		const url = '/approval/user/getRecordGFileListSearchPopup.do?callType=integration&openerID=' + openerID + '&type=' + type + '&selected=' + selected + '&callBackFunc=integrationPopup_CallBack';
		
		parent.Common.open('', popupID, popupName, url, '1300px', '650px', 'iframe', true, null, null, true);
	}
	
	// 선택한 기록물철 정리
	function getSelectedValue() {
		const recordClassNum = document.getElementById('targetRecordClassNum').value;
		const recordSubject = document.getElementById('targetRecordSubject').value;
		let ret = [];
		
		recordClassNum.split(',').forEach((item, idx) => {
			ret.push({'RecordClassNum': item, 'RecordSubject': recordSubject.split(', ')[idx]});
		});
		return encodeURIComponent(JSON.stringify(ret));
	}
	
	// 통합 콜백 함수
	function integrationPopup_CallBack(data) {
		let recordClassNum = '';
		let recordSubject = '';
		
		data.forEach((item) => {
			if (item.recordclassnum != '') {
				recordClassNum += item.recordclassnum + ',';
				recordSubject += item.recordsubject + ', ';
			}
		});
		
		recordClassNum = recordClassNum.substr(0, recordClassNum.length - 1);
		recordSubject = recordSubject.substr(0, recordSubject.length - 2);
		
		if (selectType == 'M') {
			document.getElementById('targetRecordSubject').value = recordSubject;
			document.getElementById('targetRecordSubject').setAttribute('title', recordSubject);
			document.getElementById('targetRecordClassNum').value = recordClassNum;
		} else {
			document.getElementById('intergrationRecordSubject').value = recordSubject;
			document.getElementById('intergrationRecordSubject').setAttribute('title', recordSubject);
			document.getElementById('intergrationRecordClassNum').value = recordClassNum;
		}
	}
</script>