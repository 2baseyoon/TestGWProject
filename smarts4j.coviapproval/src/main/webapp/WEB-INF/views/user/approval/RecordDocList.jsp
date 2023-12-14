<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.coviframework.util.StringUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_apv_recordDocList'/></h2> <!-- 기록물 등록대장 -->
	<div class="searchBox02">
		<span>
			<input type="text" class="sm" id="searchInput" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
			<button id="simpleSearchBtn" type="button" onclick="onClickSearchButton();" class="btnSearchType01"><spring:message code="Cache.btn_search"/></button> <!-- 검색 -->
		</span>
		<a id="detailSchBtn" onclick="detailDisplay(this);" class="btnDetails"><spring:message code="Cache.lbl_apv_detail"/></a> <!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="inPerView type02 appSearch" id="DetailSearch" >
		<div class="selectCalView" style="width: 500px">
			<!--<span>* 제목+: 제목+기안자명+기안부서명 검색</span><br/>  todo: 다국어처리 필요 -->
			<span><spring:message code='Cache.lbl_Contents'/></span>	<!-- 내용 -->
			<div class="selBox" style="width: 100px;" id="selectsearchType"></div>
			<input type="text" id="titleNm" style="width: 177px;" onkeypress="if (event.keyCode==13){ $('#detailSearchBtn').click(); return false;}" >
			<a id="detailSearchBtn"  onclick="onClickSearchButton()" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code="Cache.btn_search"/></a>
		</div>
		<div class="selectCalView" style="width: 500px">
			<span><spring:message code='Cache.lbl_selection'/></span>	<!-- 선택 -->
			<select id="selectproductYear" class="selectType02"></select> <!--  년도 -->
			<select id="selectrecordDept" class="selectType02" style="display:none" onchange= "setSelectBox('1')"></select> <!-- 부서 -->
			 <!--<select id="selectreleaseCheck" class="selectType02"></select>
			<div class="selBox" style="width: 140px;" id="selectregistCheck"></div>  -->
			<select id="selectrecordseries" class="selectType02" onchange= "setSelectBox('2')"><option value="" >전체</option></select> <!-- 단위업무 -->
			<select id="selectrecordList" class="selectType02"><option value="">전체</option></select> <!-- 기록물철 -->
			<input type="hidden" id="functionCode" />
			<input type="hidden" id="functionLevel" />
		</div>
	</div>
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a id="writeBtn" class="btnTypeDefault" onclick="docFunc.WriteRecordDoc();"><spring:message code='Cache.btn_apv_register' /></a><!-- 등록 -->
				<a id="changeFileBtn" class="btnTypeDefault" onclick="docFunc.ChangeFile();"><spring:message code='Cache.btn_apv_changeFile' /></a> <!-- 편철변경 -->
				<!-- <a id="separationBtn" class="btnTypeDefault" onclick="docFunc.Separation();"><spring:message code='Cache.btn_apv_changeFile' /></a>분리 -->
				<a id="delBtn" class="btnTypeDefault" onclick="docFunc.DeleteRecordDoc();"><spring:message code='Cache.btn_apv_delete' /></a><!-- 삭제 -->
				<a id="saveExlBtn" class="btnTypeDefault btnExcel" onclick="docFunc.ExcelDownload();"><spring:message code='Cache.btn_SaveToExcel' /></a> <!-- 엑셀저장 -->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" onclick="docFunc.Refresh();"></button><!-- 새로고침 -->
			</div>
		</div>
		<div class="apprvalBottomCont">
			<div class="appRelBox">
				<div class="contbox">
					<div class="conin_list" style="width:100%;">
						<div style="display: inline-block; width: 20%;" class="treeList org_tree mScrollVH scrollVHType01" >
							<div id="treePage" class="treeList radio radioType02 org_tree" style="margin-top: 18px; overflow:hidden; border-right:1px solid black;"></div>
						</div>
						<div style="display: inline-block; width:80%;  position: absolute; margin: 25px;">
							<div id="recordDocListGrid" style="margin-right: 25px;overflow:hidden;"></div>
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
	let g_SearchYear = '';
	g_FuncObj.groupTree = new AXTree();
	
	let RecordAdmin = 'N';
	let isRecordDeptAdmin = 'N';

	
	init(true);
	
	detailDisplay(this);
	hasRecordAdmin();
	setRecordDeptAdmin();
	setDeptAdmin();
	
	// init
	function init(bLoad) {
		if (bLoad) {
			// tree height size 조정
			const offsetHeight = document.body.offsetHeight;
			document.getElementById(g_TreeID).style.height = String(offsetHeight - 230) + 'px';
			
			// 트리 기본 세팅
			setGroupTreeConfig();

		}
	}

	// 트리 데이터 조회
	function setInitGroupTreeData(){
		$.ajax({
			url: '/approval/user/getRecordGFileTreeData.do',
			type: 'POST',
			data: {
				'BaseYear': $("#selectproductYear").val(),
				'DeptId' : sessionObj.DEPTID,
				'RecordAdmin' : RecordAdmin
				},
			async: false,
			success: function(data){
				$this.groupTree.setList( data.list );
				// 전체 확장
				$this.groupTree.expandAll();
				
				// tr.div cursor pointer, mouseover, selected class 제거
				const itemsObj = document.querySelectorAll('.gridBodyTr');
				document.getElementById("treePage_AX_scrollYHandle").style.background = "transparent"
				itemsObj.forEach((item) => {
					$(item).off('mouseover');
					$(item).find('div.tdRelBlock').css('cursor', 'default');
					item.classList.remove('selected');
					
					const functionlevel = $(item).find('a[name="recordItem"]').attr('functionlevel');
					const haschild = $(item).find('a[name="recordItem"]').attr('haschild');
					const functionName = $(item).find('a[name="recordItem"]').html(); 
					
					if(functionName.indexOf('(폐기)') > 1) $(item).find('a[name="recordItem"]').html(functionName.replace('(폐기)','<b>(폐기)</b>'));
					
					// 아이콘 변경
					if ((functionlevel != '2' && haschild == 'N') ||
						(functionlevel == '1' && $(item).find('.noChild').length == 1)) {
						// 기록물철이 아니고 업무구분인 경우 아이콘 변경
						$(item).find('.bodyNodeIndent').removeClass('expand noChild');
						$(item).find('.bodyNodeIndent').hide();
					}
				});
			},
			error: function(response, status, error){
				Common.Error('<spring:message code='Cache.msg_apv_030' />');  // 오류가 발생했습니다.
			},
		});
	}
	
	function hasRecordAdmin(){
		$.ajax({
			url: '/approval/user/getRecordAdmin.do',
			type: 'POST',
			data: {'UserId': sessionObj.USERID},
			async: false,
			success: function(data){
				if(data.Cnt >0){
					RecordAdmin = 'Y';
					document.getElementById("selectrecordDept").style.display = '';
				}
			},
			error: function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			},
		});
	}
	
	function setRecordDeptAdmin(){
		$.ajax({
			url: '/approval/user/getRecordDeptAdmin.do',
			type: 'POST',
			data: {'UserId': sessionObj.USERID},
			async: false,
			success: function(data){
				if(data.Cnt >0){
					isRecordDeptAdmin = 'Y';
				}
			},
			error: function(response, status, error){
				Common.Error('<spring:message code='Cache.msg_apv_030' />');  // 오류가 발생했습니다.
			},
		});
	}
	
	function setDeptAdmin(){
		if(RecordAdmin != "Y" && isRecordDeptAdmin != "Y"){
				document.getElementById('changeFileBtn').style.display = "none";
				document.getElementById('delBtn').style.display = "none";	
		}
	}
	
	// 단위업무 데이터 조회
	function setRecordSeriesData(){
		var DeptId = sessionObj.DEPTID;
		if( RecordAdmin == 'Y') DeptId = $('#selectrecordDept').val();
		
		$.ajax({
			url: '/approval/user/selectRecordDocComboData.do',
			type: 'POST',
			data: {
				'BaseYear': $("#selectproductYear").val(),
				'DeptId' : DeptId,
				'UserId' : sessionObj.USERID,
				'RecordAdmin' : RecordAdmin
			},
			async: false,
			success: function(data){
				setRecordSeriesList(data);
				//setRecordList(data);
			},
			error: function(response, status, error){
				Common.Error('<spring:message code='Cache.msg_apv_030' />');  // 오류가 발생했습니다.
			},
		});
	}
	
	// 기록물철 데이터 조회
	function setRecordData(){
		var DeptId = sessionObj.DEPTID;
		if( RecordAdmin == 'Y') DeptId = $('#selectrecordDept').val();
		
		$.ajax({
			url: '/approval/user/selectRecordDocComboData.do',
			type: 'POST',
			data: {
				'BaseYear': $("#selectproductYear").val(),
				'DeptId' : DeptId,
				'UserId' : sessionObj.USERID,
				'RecordAdmin' : RecordAdmin,
				'SeriesCode' : $('#selectrecordseries').val(),
			},
			async: false,
			success: function(data){
				setRecordList(data);
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
			xscroll: true,
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
					anchorName.text(this.item.FunctionName + (this.item.HasDocCount != '0' ? '(' + this.item.HasDocCount + ')' : ''));
					anchorName.attr('onclick', 'setFunctionInfo(this)');
					anchorName.attr('functionLevel', this.item.FunctionLevel);
					anchorName.attr('hasChild', this.item.HasChild);
					anchorName.attr('name', 'recordItem');
					
					var str = anchorName.prop('outerHTML');
					return str;
				}
			}],								// tree 헤드 정의 값
			body: bodyConfig				// 이벤트 콜벡함수 정의 값
		});
	}

	// 트리 선택한 값으로 조회
	function setFunctionInfo(obj) {
		// 이전 선택된 값 제거
		if (document.querySelector('a[selected="true"]') != null) {
			document.querySelector('a[selected="true"]').removeAttribute('style');
			document.querySelector('a[selected="true"]').removeAttribute('selected');
		}
		
		let title = document.querySelector('h2.title').textContent;
		
		// 기존에 선택한 값이 아닐때만 검색
		if (document.getElementById('functionCode').value != obj.id) {
			document.getElementById('functionCode').value = obj.id;
			document.getElementById('functionLevel').value = obj.getAttribute('functionlevel');
			obj.style.backgroundColor = '#4abde1';
			obj.setAttribute('selected', 'true');
			
			title = title.split(' - ')[0] + ' - ' + (obj.getAttribute('functionlevel') == '4' ? '(<spring:message code='Cache.lbl_recordFile' />)' : '(<spring:message code='Cache.lbl_BizSection' />)') + obj.text;
		} else {
			// 기존에 선택한 값이면 선택 해제
			document.getElementById('functionCode').value = '';
			document.getElementById('functionLevel').value = '';
			
			title = title.split(' - ')[0];
		}
		
		document.querySelector('h2.title').textContent = title;
		docFunc.bindGrid();
	}
	
	var recordDocListFunction = function(){		
		var ListGrid = new coviGrid();
		
		var template = {
			subject : function(){ 
									return $("<a>", {
												"id" : "subject"	,
												"text" : this.value, 
												"onclick": "docFunc.openRecordDocDetailPopup('" + this.item.RecordDocumentID + "');" 
											}).get(0).outerHTML
								}		
			, userName : function(){ return CFN_GetDicInfo(this.value); }
			, receiveNo 	: function(){ return (this.value.indexOf(";") > -1 ? this.value.split(";")[0] : this.value); }
		};
					
		var header = [
				  {key:'chk', 				label:'chk',			width:'25',		align:'center', formatter:'checkbox',	sort:false }
				, {key:'RecordDocumentID',	label:'',				widht:'1',		align:'center',	display: false }
				, {key:'FunctionName',		label:'업무구분',			width:'100',	align:'center', formatter: template.subject}
				, {key:'RecordSubject',		label:'기록물철',			width:'150',	align:'center', formatter: template.subject}
				, {key:'RecordCheckName', 	label:'등록구분',		width:'150',	align:'center', formatter: template.subject}
				, {key:'DocSubject',		label:'제목',			width:'250',	align:'left', formatter: template.subject }
				, {key:'ProductDate',		label:'등록일자',			width:'150',	align:'center', formatter: template.subject}
				, {key:'ProductNum',		label:'등록번호',			width:'200',	align:'center', formatter: template.subject}
				, {key:'OldProductNum',		label:'문서번호',			width:'200',	align:'center', formatter: template.subject}
				, {key:'RecordProductName',	label:'처리과기관명',		width:'150',		align:'center', formatter: template.userName}
				, {key:'ProposalName',		label:'기안자',		width:'100',		align:'center', formatter: template.userName}	
// 				, {key:'ApprovalName',		label:'결재권자',			width:'100',		align:'center', formatter: template.userName}	 
				, {key:'ReceiptName',		label:'수신자(발신자)',		width:'200',		align:'center', formatter: template.userName}
		];
			
		var ajax = function(pUrl, param, bAsync){
			var deferred = $.Deferred();
			$.ajax({
				url: pUrl,
				type:"POST",
				data: param,
				async: bAsync,
				success:function (data) { deferred.resolve(data);},
				error:function(response, status, error){ deferred.reject(status); }
			});				
		 	return deferred.promise();	
		}
		
		var selectInit = function(){
			ajax("/approval/user/selectRecordDocComboData.do", {}, false)
				.done(function(data){
					$(".selBox").each(function(i, obj) {
						baseYear = new Date().getFullYear();
						var id = $(obj).attr("id");
						var width = "width: " + $(obj).css("width");
						var listName = id.replace("select", "") + "List";
						var list = data[listName];
						
						if(id == "selectsearchType") {
							list.unshift({"optionValue" : "ApprovalName", "optionText" : "<spring:message code='Cache.lbl_ApprovalUser'/>"});
							list.unshift({"optionValue" : "ProductNum", "optionText" : "<spring:message code='Cache.lbl_apv_RegisterNo'/>"});
							list.unshift({"optionValue" : "ProposalName", "optionText" : "<spring:message code='Cache.lbl_apv_writer'/>"});							
							list.unshift({"optionValue" : "DocSubject", "optionText" : "<spring:message code='Cache.lbl_Title'/>"});
						}else{
							list.unshift({"optionValue" : "", "optionText" : "<spring:message code='Cache.lbl_all'/>"});
						}
						
						searchHtml = "<span class=\"selTit\" ><a id=\"seSearchID_"+id.replace("select", "")+"\" target=\""+id+"\" onclick=\"clickSelectBox(this);\" value=\""+list[0].optionValue+"\" class=\"up\">"+list[0].optionText+"</a></span>"
						searchHtml += "<div class=\"selList\" style=\""+width+";display: none;\">";
						$(list).each(function(index){
							searchHtml += "<a class=\"listTxt\" value=\""+this.optionValue+"\" target=\""+id+"\" onclick=\"clickSelectBox(this); docFunc.changeSelectValue(this);\" id=\""+"sch_"+this.optionValue+"\">"+this.optionText+"</a>"
						});
						searchHtml += "</div>";
						
						$("#"+id).html(searchHtml);
					});
					setYearList(data);
					if(RecordAdmin == 'Y'){
						setDeptList(data); // 부서
					}else{
						setRecordSeriesData(); // 단위업무
					}
					setReleaseCheckList();
				})
				.fail(function(e){  
					//console.log(e);
				});
		}
		
		function setYearList(obj){
			baseYear = new Date().getFullYear();
			var list = obj["productYearList"];
			var baseYearHtml = "";
			var isAdmin = "";

			if(isAdmin == "Y"){
				subDeptOption += "<option value=''><spring:message code='Cache.lbl_Whole'/></option>"; //전체
			}else{
				selDept = Common.getSession("DEPTID");
			}

			$.each(list, function(idx, item){
				baseYearHtml += "<option value='"+item.optionValue+"'>"+item.optionText+"</option>";
			});
			
			$("#selectproductYear").html(baseYearHtml);
			$("#selectproductYear").val(baseYear);
			g_SearchYear = baseYear;
		}
		
		function setDeptList(obj){
			var subDeptList = obj["recordDeptList"];
			var subDeptOption = "";
			var selDept = "";
			var isAdmin = "Y";
					
			if(isAdmin == "Y"){
				subDeptOption += "<option value=''><spring:message code='Cache.lbl_Whole'/></option>"; //전체
			}else{
				selDept = Common.getSession("DEPTID");
			}
						
			$.each(subDeptList, function(idx, item){
				subDeptOption += "<option value='"+item.optionValue+"'>"+item.optionText+"</option>";
			});
					
			$("#selectrecordDept").html(subDeptOption);
			$("#selectrecordDept").val(selDept);
		}

		function setReleaseCheckList(){
			let subReleaseCheckList = ['ReleaseCheck'];
			let subReleaseCheckOption = "<option value=''><spring:message code='Cache.lbl_Whole'/></option>"; //전체
			
			Common.getBaseCodeList(subReleaseCheckList);
			
			$.each(coviCmn.codeMap['ReleaseCheck'], function(idx, item){
				subReleaseCheckOption += "<option value='"+item.Code+"'>"+item.CodeName+"</option>";
			});
					
			$("#selectreleaseCheck").html(subReleaseCheckOption);
		}
		
		this.changeSelectValue = function(obj) {
			if($(obj).attr("target") != "selectSearchType") {
				docFunc.bindGrid();
			}
		}
		
		/* 사용함수 */
		this.pageInit = function(){			
			selectInit();
						
			/* 검색옵션 이벤트  */
			$("#selectPageSize").on('change',function(){				
				ListGrid.page.pageSize = $(this).val();
				ListGrid.page.pageNo = 1;
				ListGrid.reloadList();
			});
			
			$('#simpleSearchBtn').on('click',function(){	
				ListGrid.page.pageNo = 1;

				docFunc.bindGrid();
			});
			
			$("#selectproductYear, #selectrecordDept, #selectrecordseries, #selectrecordList").on("change", onClickSearchButton);
			$("#searchInput").on('keypress', function(){ event.keyCode === 13 && $("#simpleSearchBtn").trigger('click'); });
			
			setInitGroupTreeData();
		}
		
		this.gridInit = function(){			
			ListGrid.setGridHeader(header);
			
			ListGrid.setGridConfig({
				targetID : "recordDocListGrid",
				height:"auto",
				xscroll: true,
				listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
				paging : true,
				fitToWidth  : false,
				page : {
					pageNo:1,
					pageSize:$("#selectPageSize").val()
				},
				notFixedWidth : 4,
				overflowCell : [],
				body: {
			    }
			});
			
			docFunc.bindGrid();
		}
		
		this.bindGrid = function() {			
			ListGrid.page.pageNo = 1;
			ListGrid.bindGrid({
				ajaxUrl : "/approval/user/getRecordDocList.do",
				ajaxPars : docFunc.getSelectParams(),
				onLoad: function(){
					$('.gridBodyTable > tbody > tr > td').css('background', 'white');
					$('.AXGrid').css('overflow','visible');
					coviInput.init();
					if(ListGrid.getCheckedList(1).length <= 0){ //일괄 승인시 최상위 체크 박스가 유지되는 문제 해결
						ListGrid.checkedColSeq(1, false);
					}
				}
			});
		}
		
		this.getSelectParams = function() {
			var params = {};
			$(".selBox").each(function(i, obj) {
				var key = $(obj).attr("id").replace("select", "");
				var value = $("#seSearchID_" + key).attr("value");
				params[key] = value;
			});

			if ($('#DetailSearch').css('display') == "none") { // all
				params.searchType = "all";
				params.searchText = $("#searchInput").val();
			} else if ($('#DetailSearch').css('display') == "block"){ // 상세검색
				params.searchType = params["searchType"];
				params.searchText = $("#titleNm").val();
			}
			params.recordDept = $("#selectrecordDept").val();
			params.productYear = $("#selectproductYear").val();
			params.releaseCheck = $("#selectreleaseCheck").val();
			params.functionCode = $("#functionCode").val();
			params.functionLevel = $("#functionLevel").val();
			params.recordSeries = $("#selectrecordseries").val();
			params.recordList = $("#selectrecordList").val();
			params.recordAdmin = RecordAdmin;
			return params;
		}
		
		
		this.ExcelDownload = function() {
			var title = "RecordDocList";
			
			var listCount = ListGrid.page.listCount;
			var selectParams = docFunc.getSelectParams();
			
			var headerKey = "";
			var headerName = "";
			var headerData = header;
			
			for(var i=0;i<headerData.length; i++){
				if(headerData[i].key != "RecordDocumentID"){
					if(headerData[i].formatter != "checkbox"){
						headerKey += headerData[i].key + ",";
						headerName += headerData[i].label + ";";
					}
				}
			}
			
			if(listCount == 0){
				Common.Warning("<spring:message code='Cache.msg_apv_279'/>");							//저장할 문서가 없습니다.
			} else {
				Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						location.href = "/approval/user/recordDocListExcelDownload.do?"
							+"selectParams="+encodeURIComponent(JSON.stringify(selectParams))
							+"&title="+title
							+"&headerkey="+encodeURIComponent(headerKey)
							+"&headername="+encodeURIComponent(encodeURIComponent(headerName))			// 한글 깨짐 문제 때문에 두번 encode
					}
				});
			}
		}
		
		this.DeleteRecordDoc = function() {
			var checkedList = ListGrid.getCheckedList(0);
			
			if (checkedList.length == 0) {
				Common.Warning("<spring:message code='Cache.msg_apv_003' />"); //선택된 항목이 없습니다.
			} else {
				Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (confirmResult) { //삭제하시겠습니까?
					if (confirmResult) {
				    	var ids = "";
						$(checkedList).each(function(i, v) {
							ids += v.RecordDocumentID + ",";
						});
						ids = ids.substring(0, ids.length-1);
						
						if (ids.length > 0) {
		 					$.ajax({
								url:"/approval/user/deleteRecordDoc.do",
								type:"post",
								data:{
									"RecordDocumentIDs" : ids
								},
								async:false,
								success:function (data) {
									ListGrid.reloadList(); //Grid만 reload되도록 변경
								},
								error:function(response, status, error){
									CFN_ErrorAjax("/approval/user/deleteRecordDoc.do", response, status, error);
								}
							});
						}
					} else {
						return false;
					}
				});
			}
		}
		
		this.WriteRecordDoc = function() {
			var iHeight = 800; 
			var iWidth = 1080;
			var sUrl = "/approval/user/goRecordDocWritePopup.do";
			var sSize = "scrollbars=yes,toolbar=no,resizable=yes";
			
			CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
		}
		
		this.openRecordDocDetailPopup = function(doc_id) {
			var iHeight = 800; 
			var iWidth = 1080;
			var sUrl = "/approval/user/goRecordDocViewPopup.do?doc_id="+doc_id;
			var sSize = "scrollbars=yes,toolbar=no,resizable=yes";
			
			CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
		}	
		
		this.ChangeFile = function() {
			var checkedList = ListGrid.getCheckedList(0);
			var targetID = "";
			
			$(checkedList).each(function(i, v) {
				targetID += v.RecordDocumentID + ",";
			});
			targetID = targetID.substring(0, targetID.length-1);
			
			if (checkedList.length == 0) {
				Common.Warning("<spring:message code='Cache.msg_apv_003' />"); //선택된 항목이 없습니다.
			} else {				
				var oApproveStep;
				var iHeight = 700; 
				var iWidth = 1050;
				var sUrl = "/approval/form/goRecordSelectPopup.do?targetID="+targetID;
				var sSize = "scrollbars=yes,toolbar=no,resizable=yes";
				
				CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
			}
		}
		
		// 분리
		this.Separation = function() {
			const checkedList = ListGrid.getCheckedList(0);
			if (checkedList.length == 0) {
				Common.Warning("<spring:message code='Cache.msg_apv_003' />"); //선택된 항목이 없습니다.
			} else {
				let recordClassNum = '';
				let ret = [];
				
				$(checkedList).each(function(i, v) {
					ret.push({'RecordDocumentID': v.RecordDocumentID, 'DocSubject': v.DocSubject});
					
					// 기록물철 멀티 체크
					if (recordClassNum == '') {
						recordClassNum = v.RecordClassNum;
					} else if (recordClassNum != v.RecordClassNum) {
						recordClassNum = 'ErrorMulti';
						return false;
					}
				});
				
				if (recordClassNum == 'ErrorMulti') {
					Common.Warning("<spring:message code='Cache.Approval_msg_Separation_PossibleOnlyOne' />"); // 분리는 하나의 기록물철의 기록물들만 가능합니다.
				} else {
					const popupID = 'selectRecordGFilePopup';
					const popupName = '<spring:message code="Cache.Approval_lbl_RecordDocSeparation"/>'; // 기록물 분리
					const selected = encodeURIComponent(JSON.stringify(ret));
					const url = '/approval/user/getRecordGFileListSearchPopup.do?callType=separation&recordClassNum=' + recordClassNum + '&selected=' + selected + '&callBackFunc=separation_CallBack';
					
					parent.Common.open('', popupID, popupName, url, '1300px', '650px', 'iframe', true, null, null, true);
				}
			}
		}
		
		this.setChangedFile = function(recordClassNum, targetID, KeepPeriod) {
			Common.Confirm("<spring:message code='Cache.msg_updateFiling' />", "Confirmation Dialog", function (confirmResult) { //편철을 변경하시겠습니까?
				if (confirmResult) {
					$.ajax({
						url:"/approval/user/changeFileOfRecordDoc.do",
						type:"post",
						data:{
							"RecordDocumentIDs" : targetID,
							"RecordClassNum" : recordClassNum,
							"KeepPeriod" : KeepPeriod
						},
						async:false,
						success:function (data) {
							ListGrid.reloadList(); //Grid만 reload되도록 변경
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/approval/user/changeFileOfRecordDoc.do", response, status, error);
						}
					});
				}
			});
		}
		
		this.Refresh = function() {
			ListGrid.reloadList(); 
		}
	}	

	//일괄 호출 처리
	var docFunc = new recordDocListFunction();
		docFunc.pageInit();
		docFunc.gridInit();
	
	function setRecord(returnData) {
		docFunc.setChangedFile(returnData.RecordClassNum, returnData.TargetID, returnData.KeepPeriod);
	}
	
	// 상세검색 열고닫기
	function detailDisplay(pObj){
		if($("#DetailSearch").hasClass("active")){
			$(pObj).removeClass("active");
			//$('#groupLiestDiv').hide();
			$('#DetailSearch').removeClass("active");
		}else{
			$(pObj).addClass("active");
			$('#DetailSearch').addClass("active");
		}
		
		$(".contbox").css('top', $(".content").height());
		coviInput.setDate();
	}
	
	function setRecordSeriesList(obj){
		var subDeptList = obj["recordSeriesList"];
		var subDeptOption = "";
		var selDept = "";
				
		subDeptOption += "<option value=''><spring:message code='Cache.lbl_Whole'/></option>"; //전체
					
		$.each(subDeptList, function(idx, item){
			subDeptOption += "<option value='"+item.optionValue+"'>"+item.optionText+"</option>";
		});
				
		$("#selectrecordseries").html(subDeptOption);
	}
	
	function setRecordList(obj){
		var subDeptList = obj["recordList"];
		var subDeptOption = "";
		var selDept = "";
		var isAdmin = "Y";
					
		subDeptOption += "<option value=''><spring:message code='Cache.lbl_Whole'/></option>"; //전체
					
		$.each(subDeptList, function(idx, item){
			subDeptOption += "<option value='"+item.optionValue+"'>"+item.optionText+"</option>";
		});
				
		$("#selectrecordList").html(subDeptOption);
	}
	
	function onClickSearchButton(){
		// 트리데이터는 년도가 바뀔때만 재 조회
		if (g_SearchYear != $('#selectproductYear').val()) {
			g_SearchYear = $('#selectproductYear').val();
			
			// 트리 선택한 데이터 제거
			document.getElementById('functionCode').value = '';
			document.getElementById('functionLevel').value = '';
			
			// 최상단 타이블 초기화
			let title = document.querySelector('h2.title').textContent;
			title = title.split(' - ')[0];
			document.querySelector('h2.title').textContent = title;
			
			// 트리 데이터 조회
			setInitGroupTreeData();
			if(RecordAdmin=='N') setRecordSeriesData();
		}
		docFunc.bindGrid();		
	}

	function setSelectBox(idx){
		if(idx == 1){
			setRecordSeriesData();
		}else if(idx ==2){
			setRecordData();
		}
	}
	
</script>
