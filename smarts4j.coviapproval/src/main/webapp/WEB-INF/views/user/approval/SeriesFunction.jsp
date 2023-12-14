<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");
	pageContext.setAttribute("isUseAccount", PropertiesUtil.getExtensionProperties().getProperty("isUse.account")); 
%>

<c:if test="${isUseAccount eq 'N'}"><link rel="stylesheet" type="text/css" href="<%=cssPath%>/eaccounting/resources/css/eaccounting.css"></c:if>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js"></script>

<style>
	.btn_search03 {background-color: white;}
	.name_box{font-size: 13px;}
</style>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_recordBusinessClassManage'/></h2> <!-- 업무구분 관리 -->
</div>
<div class="cRContBottom mScrollVH">
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault" onclick="openClassAddPopup('');"><spring:message code='Cache.lbl_CreateTopClass'/></a><!-- 최상위 업무구분 생성 -->
				<a class="btnTypeDefault" onclick="openSubClassAddPopup();"><spring:message code='Cache.lbl_CreateSubClass'/></a><!-- 하위 업무구분 생성 -->
			</div>
			<div class="buttonStyleBoxRight">
				<button class="btnRefresh" onclick="refresh();"></button>
			</div>
		</div>
		<div class="apprvalBottomCont">
			<div class="appRelBox">
				<div class="contbox">
					<div class="conin_list" style="width:100%;">
						<div style="display: inline-block; width: 25%;" class="treeList org_tree mScrollVH scrollVHType01" >
							<div id="treePage" class="treeList radio radioType02 org_tree" style="margin-top: 18px; overflow:hidden;"></div>
						</div>
						<div style="display: inline-block; position: absolute; margin: 25px;">
							<dl class="daeLeft">
								<dt class="daeTop">
									<span><spring:message code='Cache.lbl_TaskClassSet' /></span> <!-- 업무구분 설정 -->
								</dt>
								<dd class="daeBot">
		                      		<div class="t_padding">
				                      	<table>
					                        <colgroup>
						                          <col style="width:150px">
						                          <col style="width:*">
					                        </colgroup>
					                        <tbody>
			                        			<tr>
					                          		<td><spring:message code='Cache.Approval_TopClassName' /></td> <!-- 상위 업무구분명 -->
						                          	<td>
						                          		<input type="text" class="adTArea" id="txtParentFunctionName" disabled="disabled">
						                          		<input type="hidden" class="adTArea" id="hidParentFunctionCode">
						                          	</td>
						                        </tr>
			                        			<tr>
					                          		<td><spring:message code='Cache.Approval_ClassName' /></td> <!-- 업무구분명 -->
						                          	<td>
						                          		<input type="text" class="adTArea" id="txtFunctionName">
						                          	</td>
						                        </tr>
			                        			<tr>
					                          		<td><spring:message code='Cache.Approval_ClassCode' /></td> <!-- 업무구분코드 -->
						                          	<td>
						                          		<input type="text" class="adTArea" id="txtFunctionCode" disabled="disabled">
						                          		<input type="hidden" class="adTArea" id="hidFunctionCode">
						                          	</td>
						                        </tr>
			                        			<tr>
					                          		<td><spring:message code='Cache.lbl_apv_Sort' /></td> <!-- 정렬 -->
						                          	<td>
						                          		<input type="text" class="adTArea" id="txtSort" onkeyup="removeChar(this)" maxlength="4">
						                          	</td>
					                        	</tr>
				                      		</tbody>
			                      		</table>
		                      		</div>
								</dd>
							</dl>
							<div class="bottom" style="width: 700px; text-align: center; margin-top: 20px;">
								<a class="btnTypeDefault btnTypeChk" onclick="save();"><spring:message code='Cache.btn_save' /></a> <!-- 저장 -->
								<a class="btnTypeDefault" onclick="del();"><spring:message code='Cache.btn_apv_delete' /></a> <!-- 삭제 -->
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>

	</div>
</div>

<script>
	let g_FuncObj = new Object();
	let $this = g_FuncObj;
	const g_TreeID = 'treePage';
	
	g_FuncObj.groupTree = new AXTree();
	
	// init
	function init(bLoad) {
		if (bLoad) {
			// tree height size 조정
			const offsetHeight = document.body.offsetHeight;
			document.getElementById(g_TreeID).style.height = String(offsetHeight - 230) + 'px';
			
			// 트리 기본 세팅
			setGroupTreeConfig();
		}
		
		// 트리 데이터 조회
		setInitGroupTreeData();
		// 입력컨트롤 초기화
		initControls();
	}

	// 트리 데이터 조회
	function setInitGroupTreeData(){
		$.ajax({
			url: '/approval/user/getSeriesFunctionTreeData.do',
			type: 'POST',
			data: {},
			async: false,
			success: function(data){
				$this.groupTree.setList( data.list );
				// 전체 확장
				$this.groupTree.expandAll();
				
				// tr.div cursor pointer, mouseover, selected class 제거
				var itemsObj = document.querySelectorAll('.gridBodyTr');
				itemsObj.forEach((item) => {
					$(item).off('mouseover');
					$(item).find('div.tdRelBlock').css('cursor', 'default');
					item.classList.remove('selected');
				});
			},
			error: function(response, status, error){
				Common.Error('<spring:message code='Cache.msg_apv_030' />');  // 오류가 발생했습니다.
			},
		});
	}

	// 트리 기본 세팅
	function setGroupTreeConfig(){
		const pid = g_TreeID;
		
		// tr, div 클릭 시 선택 class 제거
		const bodyConfig = {
			onclick: function(idx, item){
				$('.treeBodyTable tr').removeClass('selected');
			},
			onexpand: function(idx, item){ //[Function] 트리 아이템 확장 이벤트 콜백함수
				$('.treeBodyTable tr').removeClass('selected');
			}
		};
		
		$this.groupTree.setConfig({
			targetID : g_TreeID,					// HTML element target ID
			theme: 'AXTree_none',					// css style name (AXTree or AXTree_none)
			//height:"auto",
			xscroll: false,
			showConnectionLine:true,				// 점선 여부
			relation:{
				parentKey: 'ParentFunctionCode',	// 부모 아이디 키
				childKey: 'FunctionCode'			// 자식 아이디 키
			},
			persistExpanded: false,					// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
			persistSelected: false,					// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
			colGroup:[{
				key: 'FunctionName',				// 컬럼에 매치될 item 의 키
				//label:"TREE",						// 컬럼에 표시할 라벨
				width: '300', 						// 부서명 말줌임하지 않고 전체 표시시킬 경우 주석해제(긴 부서가 없을때도 스크롤 생기는 문제 있음)
				align: 'left',	
				indent: true,						// 들여쓰기 여부
				getIconClass: function(){			// indent 속성 정의된 대상에 아이콘을 지정 가능
					var iconNames = 'folder, AXfolder, movie, img, zip, file, fileTxt, company'.split(/, /g);
					var iconName = '';
					if(typeof this.item.type == 'number') {
						iconName = iconNames[this.item.type];
					} else if(typeof this.item.type == 'string'){
						iconName = this.item.type.toLowerCase(); 
					} 
					return iconName;
				},
				formatter:function(){
					var anchorName = $('<a />').attr('id', this.item.FunctionCode);
					anchorName.text(this.item.FunctionName);
					anchorName.attr('name', this.item.FunctionName);
					anchorName.attr('parentFunctionCode', this.item.ParentFunctionCode);
					anchorName.attr('parentFunctionName', this.item.ParentFunctionName);
					anchorName.attr('sort', this.item.Sort);
					anchorName.attr('onclick', 'setInfo(this)');
					
					var str = anchorName.prop('outerHTML');
					return str;
				}
			}],								// tree 헤드 정의 값
			body: bodyConfig				// 이벤트 콜벡함수 정의 값
		});
	}

	// 최상위 업무구분 생성
	function openClassAddPopup(parentCode, parentName) {
		let url = '/approval/user/SeriesFunctionAddPopup.do?parentCode=' + parentCode;
		let popupName = '';
		let height = '';
		
		if (parentCode == '') {
			popupName = '<spring:message code='Cache.lbl_CreateTopClass' />'; // 최상위 업무구분 생성
			height = '270px';
		} else {
			popupName = '<spring:message code='Cache.lbl_CreateSubClass' />'; // 하위 업무구분 생성
			url += '&parentName=' + parentName;
			height = '300px';
		}
		
		Common.open('', 'addSeriesFunction', popupName, url, '650px', height, 'iframe', true, null, null, true);
	}
	
	// 하위 업무구분 생성
	function openSubClassAddPopup() {
		const parentCode = document.getElementById('hidFunctionCode').value;
		const parentName = document.getElementById('txtFunctionName').value;
		var parentCnt = 0;
		var parentFunctionCode = document.getElementById('hidParentFunctionCode').value;
		
		//업무구분 단계 최대 3개로 제한
		while(parentFunctionCode)  {
			//상위 코드
			parentFunctionCode = document.getElementById(parentFunctionCode).getAttribute("parentfunctioncode");
			parentCnt += 1;
		}

		if (parentCode == '') {
			Common.Warning('<spring:message code='Cache.Approval_SelectTopClassCode' />'); // 상위 업무구분을 선택하세요.
		}else if(parentCnt == 2){
			Common.Warning('업무구분은 하위로 2단계 이상 추가 할 수 없습니다.');
		}else {
			openClassAddPopup(parentCode, encodeURIComponent(parentName));
		}
	}
	
	// 새로고침
	function refresh(){
		init(false);
	}
	
	// 저장
	function save() {
		if (validation()) {
   			Common.Confirm('<spring:message code='Cache.msg_RUSave' />', 'Confirm Dialog', function(result) { // 저장하시겠습니까?
   				if (result) {
	   				let url = '/approval/user/updateSeriesFunctionData.do';
	   		   		let params = {
	   		   				"FunctionCode": document.getElementById('txtFunctionCode').value,
	   		   				"FunctionName": document.getElementById('txtFunctionName').value,
	   		   				"Sort": document.getElementById('txtSort').value
	   		   			};
	   		   		
	   		   		$.ajax({
	   					url: url,
	   					type: "POST",
	   					data: params,
	   					success: function(data){
	   						if(data.status == 'SUCCESS'){
	   							Common.Inform(data.message, 'Inform Dialog', function() {
   									refresh();
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
	
   	// 저장 전 벨리데이션
   	function validation() {
   		let rtn = true;
   		
   		if ($.trim(document.getElementById('hidFunctionCode').value) == '') {
   			Common.Warning('<spring:message code='Cache.Approval_PleaseClassCodeSelect' />', 'Warning Dialog', function() { // 업무구분을 선택하세요.
   			});
   			rtn = false;
   		} else if ($.trim(document.getElementById('txtFunctionName').value) == '') {
   			Common.Warning('<spring:message code='Cache.Approval_EnterBusinessClassName' />', 'Warning Dialog', function() { // 업무구분명을 입력하세요.
   				document.getElementById('txtFunctionName').focus();
   			});
   			rtn = false;
   		} else if (isNaN(document.getElementById('txtSort').value)) {
   			Common.Warning('<spring:message code='Cache.msg_apv_249' />', 'Warning Dialog', function() { // 숫자만 입력가능합니다.
   				document.getElementById('txtSort').focus();
   			});
   			rtn = false;
   		}
   		return rtn;
   	}
   	
	// 삭제
	function del() {
		if ($.trim(document.getElementById('txtFunctionCode').value) == '') {
   			Common.Warning('<spring:message code='Cache.Approval_PleaseClassCodeSelect' />'); // 업무구분을 선택하세요.
   		} else {
			Common.Confirm('<spring:message code='Cache.msg_AreYouDelete' />', 'Confirm Dialog', function(result) { // 삭제하시겠습니까?
				if (result) {
					let url = '/approval/user/deleteSeriesFunctionData.do';
			   		let params = {
			   				"FunctionCode": document.getElementById('txtFunctionCode').value
			   			};
			   		
			   		$.ajax({
						url: url,
						type: "POST",
						data: params,
						success: function(data){
							if(data.status == 'SUCCESS'){
								Common.Inform(data.message, 'Inform Dialog', function() {
									refresh();
								});
							} else if(data.status == 'EXISTS'){
								Common.Warning(data.message);  // 하위 업무구분코드가 존재합니다. 삭제할 수 없습니다.
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
	
	// 트리 선택한 값 입력 폼에 바인딩
	function setInfo(obj) {
		// 입력컨트롤 초기화
		initControls();
		
		// 이전 선택된 값 제거
		if (document.querySelector('a[selected="true"]') != null) {
			document.querySelector('a[selected="true"]').removeAttribute('style');
			document.querySelector('a[selected="true"]').removeAttribute('selected');
		}
		
		// 신규 선택 설정
		document.getElementById('txtFunctionName').value = obj.text;
		document.getElementById('txtFunctionCode').value = obj.id;
		document.getElementById('hidFunctionCode').value = obj.id;
		document.getElementById('txtParentFunctionName').value = obj.getAttribute('parentFunctionName');
		document.getElementById('hidParentFunctionCode').value = obj.getAttribute('parentFunctionCode');
		document.getElementById('txtSort').value = obj.getAttribute('sort');
		obj.style.backgroundColor = '#4abde1';
		obj.setAttribute('selected', 'true');
	}
	
	// 입력컨트롤 초기화
	function initControls() {
		$('.adTArea').val('');
	}
	
	init(true);
	
</script>