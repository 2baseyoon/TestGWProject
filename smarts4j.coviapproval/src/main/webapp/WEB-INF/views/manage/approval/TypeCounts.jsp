<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.CN_102"/></span> <!-- 유형별 건수 -->
	</h2>
</div>

<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa03 active" id="DetailSearch">
		<div>
			<!--<spring:message code="Cache.lbl_secAtt1" />
			<select  name="selectDdlCompany" class="AXSelect" id="selectDdlCompany"></select>-->
			<div class="selectCalView">
				<span><spring:message code="Cache.lbl_apv_DurPeriod" />(<spring:message code="Cache.lbl_apv_standard_enddate" />)</span>
				<div class="dateSel type02">
					<input class="adDate" id="startDate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="endDate" />
					<span>~</span>
					<input class=" adDate" id="endDate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startDate" />
				</div>
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchSTAT();"><spring:message code="Cache.btn_search"/></a>
			<div id="topitembar01" class="selectCalView ml15">
				<div class="radioStyle05"><input type="radio" id="Dept" name="radio" value="GetDept" onclick="ChageView();" checked="checked"><label for="Dept"><spring:message code="Cache.lbl_apv_ByDept" /></label></div>
				<div class="radioStyle05"><input type="radio" id="Form" name="radio" value="GetForm" onclick="ChageView();"><label for="Form"><spring:message code="Cache.lbl_apv_ByForm" /></label></div>
				<div class="radioStyle05"><input type="radio" id="Person" name="radio" value="GetPerson" onclick="ChageView();"><label for="Person"><spring:message code="Cache.lbl_apv_ByPerson" /></label></div>
			</div>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnExcel" href="#" onclick="ExcelDownload();"><spring:message code="Cache.lbl_apv_SaveToExcel"/></a>
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select class="selectType02 listCount" id="selectPageSize" onchange="searchSTAT(true);">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="GetDeptgrid" style=""></div>
			<div id="GetFormgrid" style=""></div>
			<div id="GetUsergrid" style=""></div>
		</div>
		<input type="hidden" id="hidden_domain_val" value=""/>
		<input type="hidden" id="hidden_worktype_val" value=""/>
	</div>
</div>

<script type="text/javascript">
	var headerData1 = null;
	var headerData2 = null;
	var headerData3 = null;

	var myGrid1 = new coviGrid();
	var myGrid2 = new coviGrid();
	var myGrid3 = new coviGrid();
	myGrid1.config.fitToWidthRightMargin = 0;
	myGrid2.config.fitToWidthRightMargin = 0;
	myGrid3.config.fitToWidthRightMargin = 0;

	initTypeCounts();
	
	function initTypeCounts() {
		setControl(); // 초기 셋팅
		setGrid();			// 그리드 세팅
		searchSTAT();
	}
	
	// 초기 셋팅
	function setControl(){ 
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
	}
	
	//그리드 세팅
	function setGrid() {
		// 헤더 설정
		headerData1 =[
	                  {key:'UNIT_NAME', label:'<spring:message code="Cache.lbl_apv_DeptName"/>', width:'400', align:'center',sort:"asc"},
	                  {key:'A_Count',  label:'<spring:message code="Cache.lbl_apv_dept_count"/>', width:'200', align:'center'},
	                  {key:'REQCMP_count',  label:'<spring:message code="Cache.lbl_apv_complete_count"/>', width:'200', align:'center'},
	                  {key:'document_leadtime', label:'<spring:message code="Cache.lbl_apv_average_time"/>', width:'200', align:'center'}
		      		];
		headerData2 =[
	                  {key:'FormName', label:'<spring:message code="Cache.lbl_apv_formname"/>', width:'500', align:'center',sort:"asc"
	                	  , formatter:function(){return CFN_GetDicInfo(this.item.FormName)}},
	                  {key:'document_Count',  label:'<spring:message code="Cache.lbl_apv_com_count"/>', width:'200', align:'center'},
	                  {key:'document_leadtime',  label:'<spring:message code="Cache.lbl_apv_average_time"/>', width:'200', align:'center'}
		      		];
		headerData3 =[
	                  {key:'DISPLAY_NAME', label:'<spring:message code="Cache.lbl_apv_person_code"/>', width:'200', align:'center',sort:"asc"},
	                  {key:'UNIT_NAME',  label:'<spring:message code="Cache.lbl_apv_DeptName"/>', width:'200', align:'center'},
	                  {key:'Draft_Count',  label:'<spring:message code="Cache.lbl_apv_app_count"/>', width:'200', align:'center'},
	                  {key:'Approval_Count', label:'<spring:message code="Cache.lbl_apv_complete_counts"/>', width:'200', align:'center'},
	                  {key:'Approval_leadtime', label:'<spring:message code="Cache.lbl_apv_average_time"/>', width:'200', align:'center'}
		      		];
		
		myGrid1.setGridHeader(headerData1);
		myGrid2.setGridHeader(headerData2);
		myGrid3.setGridHeader(headerData3);

		setGridConfig1();
		setGridConfig2();
		setGridConfig3();
		
	}
	
	// 그리드 Config 설정
	function setGridConfig1(){
		var configObj = {
			targetID : "GetDeptgrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			colHead:{},
			body:{}
		};
		
		myGrid1.setGridConfig(configObj);
	}
	
	// 그리드 Config 설정
	function setGridConfig2(){
		var configObj = {
			targetID : "GetFormgrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			colHead:{},
			body:{}
		};
		
		myGrid2.setGridConfig(configObj);
	}
	
	// 그리드 Config 설정
	function setGridConfig3(){
		var configObj = {
			targetID : "GetUsergrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			colHead:{},
			body:{}
		};
		
		myGrid3.setGridConfig(configObj);
	}
	
	// GetDeptgrid 검색
	function searchConfig1(flag){
		var EntCode = $("#hidden_domain_val").val();
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		myGrid1.page.pageNo = 1;
		myGrid1.bindGrid({
			ajaxUrl:"/approval/manage/getStatDeptList.do",
			ajaxPars: {
				"EntCode":EntCode,
				"startDate":startDate,
				"endDate":endDate
			},
			onLoad:function(){
				//아래 처리 공통화 할 것
				coviInput.setSwitch();
				//custom 페이징 추가
				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid1.fnMakeNavi("myGrid1");
			}
		});
	}
	
	// GetFormgrid 검색
	function searchConfig2(flag){
		var EntCode = $("#hidden_domain_val").val();
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		myGrid2.page.pageNo = 1;
		myGrid2.bindGrid({
			ajaxUrl:"/approval/manage/getStatFormList.do",
			ajaxPars: {
				"EntCode":EntCode,
				"startDate":startDate,
				"endDate":endDate
			},
			onLoad:function(){
				//아래 처리 공통화 할 것
				coviInput.setSwitch();
				//custom 페이징 추가
				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid2.fnMakeNavi("myGrid2");
			}
		});
	}

	// GetUsergrid 검색
	function searchConfig3(flag){
		var EntCode = $("#hidden_domain_val").val();
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		myGrid3.page.pageNo = 1;
		myGrid3.bindGrid({
			ajaxUrl:"/approval/manage/getStatPersonList.do",
			ajaxPars: {
				"EntCode":EntCode,
				"startDate":startDate,
				"endDate":endDate
			},
			onLoad:function(){
				//아래 처리 공통화 할 것
				coviInput.setSwitch();
				//custom 페이징 추가
				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid3.fnMakeNavi("myGrid3");
			}
		});
	}

	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	function ChageView() {
		//$("#startDate").val("");
		//$("#endDate").val("");
		//$("#selectDdlCompany").bindSelectSetValue("ORGROOT");
		
		searchSTAT(true);
    }
	
	function searchSTAT(bChangeConfig){
		//검색
		var radioval = $("#DetailSearch input[name=radio]:checked").val();
		if (radioval == "GetDept") {
			$("#GetDeptgrid").show();
    		$("#GetFormgrid").hide();
    		$("#GetUsergrid").hide();    	
			if(bChangeConfig) setGridConfig1();
			searchConfig1();
        } else if (radioval == "GetForm") {
    		$("#GetDeptgrid").hide();
    		$("#GetFormgrid").show();
    		$("#GetUsergrid").hide();
    		if(bChangeConfig) setGridConfig2();
    		searchConfig2();
        } else {
    		$("#GetDeptgrid").hide();
    		$("#GetFormgrid").hide();
    		$("#GetUsergrid").show();
    		if(bChangeConfig) setGridConfig3();
    		searchConfig3();
        }
	}
	
	// 엑셀 다운로드
	function ExcelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage' />", "Confirmation Dialog", function(result){
			if(result){
				var radioval = $("#DetailSearch input[name=radio]:checked").val();
				var EntCode = $("#hidden_domain_val").val();
				var startDate = $("#startDate").val();
				var endDate = $("#endDate").val();
				
				var headerName = getHeaderNameForExcel();
				
				var sortKey;
				var sortWay;
				
				if (radioval == "GetDept") {
					sortKey = myGrid1.getSortParam("one").split("=")[1].split(" ")[0];
					sortWay = myGrid1.getSortParam("one").split("=")[1].split(" ")[1];
		        } else if (radioval == "GetForm") {
		        	sortKey = myGrid2.getSortParam("one").split("=")[1].split(" ")[0];
		        	sortWay = myGrid2.getSortParam("one").split("=")[1].split(" ")[1];
		        } else {
		        	sortKey = myGrid3.getSortParam("one").split("=")[1].split(" ")[0];
		        	sortWay = myGrid3.getSortParam("one").split("=")[1].split(" ")[1];
		        }

				var sURL = "/approval/manage/typeCountsExcelDownload.do";
				sURL += "?radioval=" + radioval;
				sURL += "&EntCode=" + EntCode;
				sURL += "&startDate=" + startDate;
				sURL += "&endDate=" + endDate;
				sURL += "&sortKey=" + sortKey;
				sURL += "&sortWay=" + sortWay;
				sURL += "&headerName=" + encodeURIComponent(encodeURIComponent(headerName));
				
				location.href = sURL;
			}
		});
	}
	
	function getHeaderNameForExcel(){
		var returnStr = "";
		
		var radioval = $("#DetailSearch input[name=radio]:checked").val();
		if (radioval == "GetDept") {
			for(var i=0;i<headerData1.length; i++){
				returnStr += headerData1[i].label + ";";
			}
        } else if (radioval == "GetForm") {
        	for(var i=0;i<headerData2.length; i++){
    			returnStr += headerData2[i].label + ";";
    		}
        } else {
        	for(var i=0;i<headerData3.length; i++){
    			returnStr += headerData3[i].label + ";";
    		}
        }
		
		return returnStr;
	}
	
</script>