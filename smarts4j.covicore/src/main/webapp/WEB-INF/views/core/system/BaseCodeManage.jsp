<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_manage_baseCode"/></span>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addConfig(false);"/>
			<input type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="deleteConfig();"/>
			<input type="button" class="AXButton BtnExcel"  value="<spring:message code="Cache.btn_ExcelDownload"/>" onclick="ExcelDownload();"/>
			<input type="button" class="AXButton" value="<spring:message code="Cache.btn_CacheApply"/>" onclick="applyCache();"/>
		</div>
		
		<div id="topitembar02" class="topbar_grid">
			<span class=domain>
				<spring:message code="Cache.lbl_Domain"/>&nbsp;  	<!-- 도메인 -->
				<select name="" class="AXSelect" id="selectDomain"></select>
			</span>
			<spring:message code="Cache.lbl_BizSection"/>&nbsp; 	<!-- 업무구분 -->
			<select name="" class="AXSelect" id="selectBizSection"></select>
			
			<spring:message code="Cache.lbl_SearchCondition"/>&nbsp; 	<!-- 검색 조건 -->
			<select name="" class="AXSelect" id="selectSearch"></select>
			<input type="text" id="searchInput"  class="AXInput" onkeypress="if (event.keyCode==13){ getCodeGroupInfos(); return false;}"/>&nbsp;
			
			<spring:message code="Cache.lblSearchScope"/>&nbsp;<input type="text" id="startdate" style="width: 85px" class="AXInput" /> ~ 
			<input type="text" kind="twindate" date_startTargetID="startdate" id="enddate" style="width: 85px" class="AXInput" />
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="getCodeGroupInfos();" class="AXButton"/>
		</div>
		<div>
			<table style="width:100%">
				<tr>
					<td id="td01TblCodeGroup" style="vertical-align: top; width:450px; border-right-style: solid;"><div id="codeGroupGrid"></div></td>
					<td id="td02TblBaseCode" style="vertical-align: top;"><div id="basecodegrid" style="margin-left: 5px;"></div></td>
				</tr>
			</table>
		</div>
	</div>
</form>

<script type="text/javascript">
	//# sourceURL=BaseCodeManage.jsp

	var codeGroupGrid = new coviGrid(); 	// 코드그룹, 코드그룹이름 보여주는 1st Grid.
	var groupHeader = [
			  {key:'DomainID',  label:'<spring:message code="Cache.lbl_Domain"/>', width:'70', align:'center', display:false, hideFilter : 'Y'} 		
			, {key:'DomainName',  label:'<spring:message code="Cache.lbl_Domain"/>', width:'70', align:'center'} 							<!-- 도메인 -->
			, {key:'CodeGroup',  label:'<spring:message code="Cache.lbl_CodeGroup"/>', width:'150', align:'center', sort:false}   			<!-- 코드그룹 -->
		    , {key:'CodeGroupName',  label:'코드그룹명', width:'150', align:'center', sort:false} 											<!-- 코드그룹이름 -->
			, {key:'BizSectionName',  label:'<spring:message code="Cache.lbl_BizSection"/>', width:'80', align:'center', sort:false}		<!-- 업무구분 -->
	];
	
	var baseCodeGrid = new coviGrid();		// code정보가 보여지는 2nd Grid.
	
	// 단독 그리드와 엑셀다운로드 시 사용.
	var dtlOnlyHeaderData = [
		{key:'chk', label:'chk', width:'25', align:'center', formatter:'checkbox'}
		, {key:'DisplayName',  label:'<spring:message code="Cache.lbl_Domain"/>', width:'70', align:'center'}
		, {key:'BizSectionName',  label:'<spring:message code="Cache.lbl_BizSection"/>', width:'70', align:'center'}
		, {key:'CodeGroup',  label:'<spring:message code="Cache.lbl_CodeGroup"/>', width:'70', align:'center'}
		, {key:'Code', label:'<spring:message code="Cache.lbl_Code"/>', width:'70', align:'center',
			formatter:function () {
				return "<a href='#' onclick='updateConfig(false, \""+ this.item.CodeID +"\", \""+ this.item.Code +"\", \""+ this.item.CodeGroup +"\", \""+this.item.DomainID+"\"); return false;'>"+this.item.Code+"</a>";
			}}
		, {key:'CodeName',  label:'<spring:message code="Cache.lbl_codeNm"/>', width:'100', align:'center'}
		, {key:'SortKey', label:'<spring:message code="Cache.lbl_Sort"/>',  width:'30', align:'center'}
		, {key:'Description', label:'<spring:message code="Cache.lbl_Description"/>', sort:false, width:'100', align:'center'}
		, {key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>',  width:'70', align:'center'}
		, {key:'IsUse', label:'<spring:message code="Cache.lbl_Use"/>',   width:'70', align:'center',
			formatter:function () {
				return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch_"+this.item.CodeGroup.replaceAll(".", "_").replaceAll("#", "_")+"_"+this.item.Code.replaceAll(".", "_").replaceAll("#", "_")+"_"+this.item.DomainID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.CodeGroup+"\", \""+this.item.Code+"\", \""+this.item.DomainID+"\");' />";
			}}
		, {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', sort:"desc", 
			formatter: function(){
				return CFN_TransLocalTime(this.item.ModifyDate);
			}, dataType:'DateTime'
		}
	];
	
	initContent();
	
	function initContent(){ 
		setSelect();		// Select Box 세팅
		
		// 1st, codeGroupGrid.
		setCodeGroupGrid();
		getCodeGroupInfos();
	}
	
	// 1st, codeGroupGrid setting.
	function setCodeGroupGrid() {
		codeGroupGrid.setGridHeader(groupHeader);
		codeGroupGrid.setGridConfig({
			targetID : "codeGroupGrid",
			height : "auto",
			fitToWidth: false,
			sort : false,
			body : {
				onclick: function() {
					setDtlGrid();
					searchGrid( codeGroupGrid.getSelectedItem().item );
				}
			}
		});
	}

	// 1st, codeGroupGrid loading.
	function getCodeGroupInfos() {
		// 수정 이전의 내용과 동일하게 selectBizSection 값이 BizSection 이면 빈값으로 전달한다.
		var bizSection = document.getElementById("selectBizSection").value === "BizSection" ? "" : document.getElementById("selectBizSection").value;

		var searchType = "";
		// 조회 조건에 대해 1st Grid 표기 여부를 구분.
		if ( $("#selectSearch").val() === "CodeGroup") {
			if ( ($("#startdate").val() != "") && ($("#enddate").val() != "") ) {
				$("#td01TblCodeGroup").hide(); 		// 1st Grid 내용 숨김.
				setDtlGridOnly(); 					// 2nd Grid setting.
				searchGrid();
				return;
			}
			searchType = "CodeGroup";
			$("#td01TblCodeGroup").show(); 		// 숨겨져 있을 수 있으니, show().
		} else if ( $("#searchInput").val() === "" ) { 		// 검색어 없다면 1st Grid 조회값을 보여준다.
			if ( ($("#startdate").val() === "") && ($("#enddate").val() === "") ) {
				$("#td01TblCodeGroup").show();
			} else {
				$("#td01TblCodeGroup").hide(); 		// 1st Grid 내용 숨김.
				setDtlGridOnly(); 					// 2nd Grid setting.
				searchGrid();
				return;
			}
		} else {
			// 검색 조건이 '코드그룹'이 아닌 '설명','코드','코드명'일 경우.
			// 1st Grid 내용을 지우고, 2nd Grid에 도메인, 코드그룹, 코드그룹명, 업무구분을 추가로 붙여서 구분 없이 보여주기.
			$("#td01TblCodeGroup").hide(); 		// 1st Grid 내용 숨김.
			setDtlGridOnly(); 					// 2nd Grid setting.
			searchGrid();
			return;
		}
		
		var searchText = $("#searchInput").val();
		var domainID = document.getElementById("selectDomain").value;

		codeGroupGrid.page.pageNo = 1;
		codeGroupGrid.page.listOffset = 3;
		codeGroupGrid.bindGrid({
 			ajaxUrl:"/covicore/basecode/getCodeGroupList.do",
 			ajaxPars: {
 				"domainID" : domainID
 				, "bizSection" : bizSection
 				, "searchType" : searchType
 				, "searchText" : searchText
 			},
 			onLoad : function() { 	// 
 				// ajax 실행 완료 후 아래 함수가 호출되는 사이에 다른 화면으로 변경되어 basecodegrid 가 존재하지 않게 되면 다른 화면에 grid가 있을 경우 동작 이상이 발생.
 				// basecodegrid를 확인하는 부분 추가.
 				if ($("div[id=basecodegrid]").length > 0 ) {
 					// 1st Grid가 로딩되면, 데이터가 있을 시 첫번째 항목을 선택하고, 2nd Grid를 조회. 1st 항목이 없을 시 2nd 항목도 없을 것이기에 2nd 조회 결과 0.
 					if (codeGroupGrid.list.length > 0) {
 	 					codeGroupGrid.setFocus(0);
 	 				}
 					setDtlGrid();
 					searchGrid( codeGroupGrid.getSelectedItem().item );	
 				}
 			}
		});
	}
	
	// 2nd Grid(codeList infos) setting.
	function setDtlGrid() {
		dtlHeaderData = [
			{key:'chk', label:'chk', width:'25', align:'center', formatter:'checkbox'}
			, {key:'Code', label:'<spring:message code="Cache.lbl_Code"/>', width:'70', align:'center',
	       	 	formatter:function () {
	       		 	return "<a href='#' onclick='updateConfig(false, \""+ this.item.CodeID +"\", \""+ this.item.Code +"\", \""+ this.item.CodeGroup +"\", \""+this.item.DomainID+"\"); return false;'>"+this.item.Code+"</a>";
	       	}}, {key:'CodeName',  label:'<spring:message code="Cache.lbl_codeNm"/>', width:'100', align:'center'} 		<!-- 코드명 -->
	       	, {key:'SortKey', label:'<spring:message code="Cache.lbl_Sort"/>',  width:'30', align:'center'} 			<!-- 정렬 -->
	       	, {key:'IsUse', label:'<spring:message code="Cache.lbl_Use"/>',   width:'70', align:'center',
            	  formatter:function () {
            		  	// 22.02.28 : code값에 빈칸이 들어가 있는 경우가 있는데, id 생성 시 빈칸이 들어가면 오류가 생겨 빈칸을 replaceAll 처리 추가.
	      				return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch_"+this.item.CodeGroup.replaceAll(" ", "").replaceAll(".", "_").replaceAll("#", "_")+"_"+this.item.Code.replaceAll(" ", "").replaceAll(".", "_").replaceAll("#", "_")+"_"+this.item.DomainID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.CodeGroup+"\", \""+this.item.Code+"\", \""+this.item.DomainID+"\");' />";
	      			}}
	       	, {key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>',  width:'70', align:'center'} 	<!-- 등록자 -->
	        , {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', sort:"desc", 
		          formatter: function(){
	    			return CFN_TransLocalTime(this.item.ModifyDate);
	    		  }, dataType:'DateTime' }
		];
		
		baseCodeGrid.setGridHeader(dtlHeaderData);
		baseCodeGrid.setGridConfig({
			targetID : "basecodegrid",
			height:"auto"
		});
	}
	
	// 검색조건이 설명, 코드, 코드명 일 때는 상세내역 조회이므로 2nd Grid만 확장해서 보여준다.
	function setDtlGridOnly() {
		baseCodeGrid.setGridHeader(dtlOnlyHeaderData);
		baseCodeGrid.setGridConfig({
			targetID : "basecodegrid",
			height:"auto",
			fitToWidth: true
		});
	}
	
	// baseconfig 검색
	function searchGrid(pObj){
		var bizSection = document.getElementById("selectBizSection").value === "BizSection" ? "" : document.getElementById("selectBizSection").value;
		var domain = document.getElementById("selectDomain").value;
		var search = document.getElementById("selectSearch").value;
		var text = document.getElementById("searchInput").value;
		var strdate = document.getElementById("startdate").value;
		var enddate = document.getElementById("enddate").value;
		
		var strCodeGroup = "";
		if ( (typeof(pObj) != "undefined") && (typeof(pObj.CodeGroup) != "undefined") ) {
			strCodeGroup = pObj.CodeGroup;
			domain = pObj.DomainID;
		}
		
		baseCodeGrid.page.pageNo = 1;
		baseCodeGrid.bindGrid({
 			ajaxUrl:"/covicore/basecode/getList.do",
 			ajaxPars: {
 				"bizSection":bizSection,
 				"domain": domain,
 				"selectsearch":search,
 				"searchtext":text,
 				"startdate":strdate,
 				"enddate":enddate,
 				"codeGroup" : strCodeGroup
 			}
		});
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addConfig(pModal){
		parent.Common.open("","addbasecode","<spring:message code='Cache.lbl_CodeCreation'/>","/covicore/basecode/goBaseCodePopup.do?mode=add","600px","450px","iframe",pModal,null,null,true);
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey, pCode, pCodeGroup, pDomainID){
		parent.Common.open("","updatebasecode","<spring:message code='Cache.lbl_CodeModify'/>","/covicore/basecode/goBaseCodePopup.do?mode=modify&codeID="+configkey+"&code="+pCode+"&codeGroup="+pCodeGroup+"&domainID="+pDomainID,"600px","450px","iframe",pModal,null,null,true);
	}
	
	// 삭제
	function deleteConfig(){
		var deleteobj = baseCodeGrid.getCheckedList(0);
		if(deleteobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
			return;
		}else{
			Common.Confirm(Common.getDic("msg_Common_08"), "Confirmation Dialog", function(result){
				if(result){								
					var selVal = baseCodeGrid.getCheckedList(0).map(function(item){
					    return item.CodeGroup + "|" + item.Code + "|" + item.DomainID
					});
					
					$.ajax({
						type:"POST",
						data:{
							"selVal" : selVal.join(",")
						},
						url:"/covicore/basecode/remove.do",
						success:function (data) {
							if(data.result == "ok")
								Common.Inform("<spring:message code='Cache.msg_138'/>");
							codeGroupGrid.reloadList();
							baseCodeGrid.reloadList();
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/basecode/remove.do", response, status, error);
						}
					});
				}
			});
		}
	}
	
	// 엑셀 다운로드
	function ExcelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
       			var bizSection = document.getElementById("selectBizSection").value;
    			var domain = document.getElementById("selectDomain").value;
    			var search = document.getElementById("selectSearch").value;
    			var text = document.getElementById("searchInput").value;
    			var strdate = document.getElementById("startdate").value;
    			var enddate = document.getElementById("enddate").value;
    			
    			var headername = getHeaderNameForExcel();
    			var headerType = getHeaderTypeForExcel();

    			var sortKey = baseCodeGrid.getSortParam("one").split("=")[1].split(" ")[0];
    			var sortWay = baseCodeGrid.getSortParam("one").split("=")[1].split(" ")[1];
    			
    			location.href = "/covicore/basecode/downloadExcel.do?domain="+domain+"&bizSection="+bizSection+"&selectsearch="+search+"&startdate="+strdate+"&enddate="+enddate
    					+"&searchtext="+text+"&sortKey="+sortKey+"&sortWay="+sortWay+"&headername="+encodeURI(headername)+"&headerType="+encodeURI(headerType)+"&title=BaseCode";
       		}
		});
	}
	
	//엑셀 업로드
	function ExcelUpload(pModal){
		parent.Common.open("","excelupload","<spring:message code='Cache.lbl_ExcelUpload'/>","system/baseconfigexcelupload.do","300px","80px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		$("#selectDomain").bindSelectSetValue('');	
		$("#selectBizSection").bindSelectSetValue('BizSection');	
		$("#selectSearch").bindSelectSetValue('');	
		$("#searchInput").val('');
		$("#startdate").val('');
		$("#enddate").val('');
		
		setDtlGrid();
		searchGrid();
	}
	
	// 사용 스위치 버튼에 대한 값 변경
	function updateIsUse(pCodeGroup, pCode, pDomainID){
		
		// 22.02.28 : code값에 빈칸이 들어가 있는 경우가 있는데, id 생성 시 빈칸이 들어가면 오류가 생겨 빈칸을 replaceAll 처리 추가.
		var isUseValue = $("#AXInputSwitch_"+pCodeGroup.replaceAll(" ", "").replaceAll(".", "_").replaceAll("#", "_")+"_"+pCode.replaceAll(" ", "").replaceAll(".", "_").replaceAll("#", "_")+"_"+pDomainID).val();
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"CodeGroup" : pCodeGroup,
				"DomainID" : pDomainID,
				"IsUse" : isUseValue
			},
			url:"/covicore/basecode/modifyUse.do",
			success:function (data) {
				if(data.status != "SUCCESS"){
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/basecode/modifyUse.do", response, status, error);
			}
		});
	}
	
	// Select box 바인드
	function setSelect(){
		var l_lang = Common.getSession("lang");
		var l_AssignedDomain = "¶"+Common.getSession("AssignedDomain")
		
		// 그룹사 시스템 관리자라면 전체를 표시하기 위해
		if(l_AssignedDomain.indexOf("¶0¶") > -1){
			coviCtrl.renderDomainAXSelect('selectDomain', l_lang, 'getCodeGroupInfos', '', "", true);
		} else {
			coviCtrl.renderDomainAXSelect('selectDomain', l_lang, 'getCodeGroupInfos', '', Common.getSession("DN_ID"), false);
		}	
		
		coviCtrl.renderAXSelect('BizSection', 'selectBizSection', l_lang, 'getCodeGroupInfos', ''); 
		coviCtrl.renderAXSelect('Code_SeletType', 'selectSearch', l_lang, '', '');
	}
	
	function getHeaderNameForExcel(){
		var returnStr = "";
		
		for(var i=1;i<dtlOnlyHeaderData.length; i++){
			returnStr += dtlOnlyHeaderData[i].label + ";";
		}
		
		return returnStr;
	}
	
	function getHeaderTypeForExcel(){
		var returnStr = "";

	   	for(var i=1;i<dtlOnlyHeaderData.length; i++){
			returnStr += (dtlOnlyHeaderData[i].dataType != undefined ? dtlOnlyHeaderData[i].dataType:"Text") + "|";
		}
		return returnStr;
	}
	
	//캐쉬적용
	function applyCache(){
		coviCmn.reloadCache("BASECODE", $("#selectDomain").val());
	}
	
	
</script>