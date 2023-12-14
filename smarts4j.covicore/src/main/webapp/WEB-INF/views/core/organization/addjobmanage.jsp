<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.CN_193"/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form>
	<div style="width:100%;min-height: 500px">
		<div id="topitembar_1" class="topbar_grid">
			<input type="button" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"class="AXButton BtnRefresh"/>
			<input type="button" value="<spring:message code="Cache.btn_Add"/>" onclick="viewAddJobPop('add',''); return false;" class="AXButton BtnAdd" />
			<input type="button" value="<spring:message code="Cache.btn_delete"/>" onclick="DeleteCheck(orgGrid);"class="AXButton BtnDelete"/>
			<input type="button" value="<spring:message code="Cache.btn_ExcelDownload"/>" onclick="excelDownload('addjob');"class="AXButton BtnExcel"/> <!-- 엑셀 다운로드 -->
		</div>
		<div class="topbar_grid">
			<span> <spring:message code="Cache.lbl_IsHR"/><!-- 인사연동여부 -->
				<select name="" class="AXSelect" id="IsHRType" onchange='onClickSearchButton();'>
					<option value="All"><spring:message code='Cache.lbl_all'/></option> <!-- 전체 -->
					<option value="Y">Y</option> <!-- Y -->
					<option value="N">N</option> <!-- N -->
				</select>
			</span>
			<span> <spring:message code="Cache.lbl_SearchCondition"/><!-- 검색 조건 -->
				<select name="" class="AXSelect" id="searchType">
					<option value="Users"><spring:message code='Cache.lbl_AddJob_User'/></option> <!-- 사용자 -->
					<option value="Company"><spring:message code='Cache.lbl_AddJob_Company'/></option> <!-- 겸직회사 -->
					<option value="Dept"><spring:message code='Cache.lbl_AddJob_Dept'/></option> <!-- 겸직부서 -->
					<option value="JobTitle"><spring:message code='Cache.lbl_AddJob_JobTitle'/></option> <!-- 겸직직책 -->
					<option value="JobPosition"><spring:message code='Cache.lbl_AddJob_JobPosition'/></option> <!-- 겸직직위 -->
					<option value="JobLevel"><spring:message code='Cache.lbl_AddJob_JobLevel'/></option> <!-- 겸직직급 -->
				</select>
				<input type="text" class="AXInput"	placeholder="<spring:message code='Cache.msg_apv_001' />"	id="searchText" onKeypress="if(event.keyCode==13) {onClickSearchButton(); return false;}"> 
				<input type="button" class="AXButton" onclick="onClickSearchButton();" value="<spring:message code='Cache.lbl_search'/>"> <!-- 검색 -->
			</span>
		</div>
		<!-- Grid -->
		<div id="resultBoxWrap">
			<div id="orgGrid"></div>
		</div>
	</div>
</form>

<script>

	//새로고침
	function Refresh(){
		orgGrid.reloadList();
		//window.location.reload();
	}

	var orgGrid = new coviGrid();
	
	window.onload = initContent();
	
	function initContent(){
		setGrid(); 
	}
	
	//Grid 관련 사항 추가 -
	//Grid 생성 관련
	function setGrid(){
		orgGrid.setGridHeader([
							  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
							  {key:'UserName', label:"<spring:message code='Cache.lbl_AddJob_User'/>" , width:'70', align:'center', formatter : function(){
								  return "<a href='#' onclick='viewAddJobPop(\"modify\",\""+ this.item.NO +"\"); return false;'>"+ "<span name='code'>" + this.item.UserName + "</span>"+"</a>";
							  }}, //사용자
							  {key:'CompanyName', label:"<spring:message code='Cache.lbl_AddJob_Company'/>" , width:'70', align:'center', formatter : function(){
								  return "<a href='#' onclick='viewAddJobPop(\"modify\",\""+ this.item.NO +"\"); return false;'>"+ "<span name='code'>" + this.item.CompanyName + "</span>"+"</a>";
							  }}, //겸직회사
			                  {key:'DeptName',  label:"<spring:message code='Cache.lbl_AddJob_Dept'/>" , width:'70', align:'center', formatter : function(){
								  return "<a href='#' onclick='viewAddJobPop(\"modify\",\""+ this.item.NO +"\"); return false;'>"+ "<span name='code'>" + this.item.DeptName + "</span>"+"</a>";
							  }}, //겸직부서
			                  {key:'JobTitleName',  label:"<spring:message code='Cache.lbl_AddJob_JobTitle'/>" , width:'40', align:'center', formatter : function(){
								  return "<a href='#' onclick='viewAddJobPop(\"modify\",\""+ this.item.NO +"\"); return false;'>"+ "<span name='code'>" + this.item.JobTitleName + "</span>"+"</a>";
							  }}, //겸직직책
			                  {key:'JobPositionName',  label:"<spring:message code='Cache.lbl_AddJob_JobPosition'/>" , width:'40', align:'center', formatter : function(){
								  return "<a href='#' onclick='viewAddJobPop(\"modify\",\""+ this.item.NO +"\"); return false;'>"+ "<span name='code'>" + this.item.JobPositionName + "</span>"+"</a>";
							  }}, //겸직직위
			                  {key:'JobLevelName',  label:"<spring:message code='Cache.lbl_AddJob_JobLevel'/>" , width:'40', align:'center', formatter : function(){
								  return "<a href='#' onclick='viewAddJobPop(\"modify\",\""+ this.item.NO +"\"); return false;'>"+ "<span name='code'>" + this.item.JobLevelName + "</span>"+"</a>";
							  }}, //겸직직급
			                  {key:'IsHR', label:"<spring:message code='Cache.lbl_IsHR'/>" , width:'70', align:'center', display:'none', formatter : function() {
			                	    var str =  '<input type="text" class="swOff" kind="switch" name="" on_value="Y" off_value="N" style="width:50px;height:20px;border:0px none;"  id="AXInputSwitch_IsHR_';
			                  	    str += this.item.NO;
			                  	    str += '"  onchange="changeSetting(\'' + this.item.NO +  '\');" value="' +  this.item.IsHR + '"/>';
			                		return  str;
			                  }} //인사연동여부
				      		]);
		setGridConfig();
		bindGridData();
	}
	
	//Grid 설정 관련
	function setGridConfig(){
		var configObj = {
			targetID : "orgGrid",
			height:"auto",
			xscroll:true,
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		// Grid Config 적용
		orgGrid.setGridConfig(configObj);
	}	

	function bindGridData() {	
		
		var IsHRType = $("#IsHRType").val();
		var searchText = $("#searchText").val();
		var searchType = $("#searchType").val();
		var companyCode;
		var ty = "one";
		
		if(Common.getGlobalProperties("isSaaS") == "Y")
		{
			companyCode = $("#domainCodeSelectBox").val();
		}
		
		orgGrid.page.pageNo = 1;

		orgGrid.bindGrid({
			ajaxUrl:"/covicore/admin/orgmanage/getaddjoblist.do",
			ajaxPars: {
				IsHR : IsHRType,
				searchText : searchText,
				searchType : searchType,
				sortBy: orgGrid.getSortParam(ty),
				CompanyCode : companyCode
			}
		});
	}
		
	function onClickSearchButton(){
		bindGridData();
	}
	
	
	function viewAddJobPop(pMode, pUser, pCompany, pGroup, pType, pTitle, pPosition, pLevel){    //겸직 속성
		if(pMode == 'add'){
			var title = "<spring:message code='Cache.lbl_AddJobAdd'/>" ;
		} else{
			var title = "<spring:message code='Cache.lbl_AddJobEdit'/>" ;
		}
		Common.open("", "ViewAddJob", title, "/covicore/addjobinfopop.do?mode=" + pMode + "&id=" + encodeURIComponent(pUser), "700px", "290px", "iframe", true, null, null, true);
		return;
	}
	
	 //설정 변경(인사연동여부)
	function changeSetting(pID){
		$.ajax({
			url:"/covicore/admin/orgmanage/changeaddjobsetting.do",
			type:"POST",
			data:{
				"id" : pID,
				"tobeValue" : $("#AXInputSwitch_IsHR_" + pID).val()
			},
			async:false,
			success:function (data) {
				//바인딩할 Selector, Param, DisplayName, width, align, checkbox, ? )
			},
			error:function (error){
				CFN_ErrorAjax("/covicore/admin/orgmanage/changeaddjobsetting.do", response, status, error);
			}
		});
	}
	
	/**
	 * 삭제
	 * param : 그리드 객체
	 */
	function DeleteCheck(gridObj){
		
		var checkCheckList 		= gridObj.getCheckedList(0);// 체크된 리스트 객체
		var TargetIDTemp 		= []; //체크된 항목 저장용 배열
		var TargetID 				= ""; //체크된 항목을 문장으로 나열 (A;B; . . ;)

		if(checkCheckList.length == 0){
			Common.Inform("<spring:message code='Cache.msg_apv_003'/>"); 
			return false;
		}else if(checkCheckList.length > 0){

			for(var i = 0; i < checkCheckList.length; i++){
				TargetIDTemp.push(checkCheckList[i].NO);
			}
			
			TargetID = TargetIDTemp.join(",");
			
			Common.Confirm("<spring:message code='Cache.msg_apv_093'/>" , "Inform", function (result) { //삭제하시겠습니까?
				if (result) {
					$.ajax({
						url: "/covicore/admin/orgmanage/deleteaddjob.do",
						type:"post",
						data:{
			 				"TargetID":TargetID
							},
						async:false,
						success:function (res) {
								gridObj.reloadList();
								//closeLayer();
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/orgmanage/deleteaddjob.do", response, status, error);
						}
					});
				}
			}); 
		}else{
			Common.Inform("<spring:message code='Cache.msg_ScriptApprovalError'/>"); 
			return false;
		}
	}
	
	//엑셀 다운로드
	function excelDownload(type){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
       			var headerName = getHeaderNameForExcel(type);
    			var	sortKey = "SortKey";
    			var	sortWay = "ASC";				  	
    			
    			location.href = "/covicore/admin/orgmanage/orglistexceldownload.do?sortColumn=" + sortKey + "&sortDirection=" + sortWay + "&type=" + type + "&groupType=" + type + "&headerName=" + encodeURI(encodeURIComponent(headerName));
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
	
	//엑셀 - Grid Header 항목 시작
	function getGridHeader( pHeaderType ){
		var headerData = [
									{key:'UserName', label:"<spring:message code='Cache.lbl_AddJob_User'/>" , width:'70', align:'center'},
									{key:'CompanyName', label:'<spring:message code="Cache.lbl_CompanyName"/>', width:'80', align:'center'},
									{key:'GroupName',  label:'<spring:message code="Cache.lbl_AddJob_Dept"/>', width:'100', align:'center'},
									{key:'JobTitleName',  label:'<spring:message code="Cache.lbl_JobTitleName"/>', width:'100', align:'center'}, 
									{key:'JobPositionName',  label:'<spring:message code="Cache.lbl_JobPositionName"/>', width:'100', align:'center'}, 
									{key:'JobLevelName',  label:'<spring:message code="Cache.lbl_JobLevelName"/>', width:'100', align:'center'}, 
									{key:'IsHR', label:'<spring:message code="Cache.lbl_IsHR"/>',   width:'70', align:'center'}
				               ];
		return headerData;
	}
	
</script>