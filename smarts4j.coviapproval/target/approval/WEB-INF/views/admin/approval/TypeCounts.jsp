<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit">유형별 건수</span>
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
			<input type="radio" id="Dept" name="radio" value="GetDept" style="border:0;" onclick="ChageView();" checked="checked" /><label for="Dept">&nbsp;<spring:message code="Cache.lbl_apv_ByDept" /></label>&nbsp;&nbsp;
			<input type="radio" id="Form" name="radio" value="GetForm" style="border:0;" onclick="ChageView();" /><label for="Form">&nbsp;<spring:message code="Cache.lbl_apv_ByForm" /></label>&nbsp;&nbsp;
			<input type="radio" id="Person" name="radio" value="GetPerson" style="border:0;" onclick="ChageView();" /><label for="Person">&nbsp;<spring:message code="Cache.lbl_apv_ByPerson" /></label>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<spring:message code="Cache.lbl_secAtt1" />
			<select  name="selectDdlCompany" class="AXSelect" id="selectDdlCompany"></select>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<spring:message code="Cache.lbl_apv_DurPeriod" />(<spring:message code="Cache.lbl_apv_standard_enddate" />)
			<input class="AXInput" id="startDate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="endDate">
		    ~
			<input class="AXInput" id="endDate" style="width: 85px" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startDate">
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchSTAT();" class="AXButton"/>
			<input type="button" value="<spring:message code="Cache.lbl_apv_SaveToExcel"/>" onclick="ExcelDownload();" class="AXButton BtnExcel"/>
		</div>
		<div id="GetDeptgrid" style=""></div>
		<div id="GetFormgrid" style=""></div>
		<div id="GetUsergrid" style=""></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>

<script type="text/javascript">
	var headerData1 = null;
	var headerData2 = null;
	var headerData3 = null;

	var myGrid1 = new coviGrid();
	var myGrid2 = new coviGrid();
	var myGrid3 = new coviGrid();

	initTypeCounts();
	
	function initTypeCounts() {
		setSelect();
		setGrid();			// 그리드 세팅
		searchSTAT();
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
		
		$("#sel_State").change(function(){
			searchConfig();
	    });
	}
	
	// 그리드 Config 설정
	function setGridConfig1(){
		var configObj = {
			targetID : "GetDeptgrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
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
				pageSize:10
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
				pageSize:10
			},
			paging : true,
			colHead:{},
			body:{}
		};
		
		myGrid3.setGridConfig(configObj);
	}
	
	// GetDeptgrid 검색
	function searchConfig1(flag){
		var EntCode = $("#selectDdlCompany").val();
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		myGrid1.page.pageNo = 1;
		myGrid1.bindGrid({
			ajaxUrl:"/approval/admin/getStatDeptList.do",
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
		var EntCode = $("#selectDdlCompany").val();
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		myGrid2.page.pageNo = 1;
		myGrid2.bindGrid({
			ajaxUrl:"/approval/admin/getStatFormList.do",
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
		var EntCode = $("#selectDdlCompany").val();
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		myGrid3.page.pageNo = 1;
		myGrid3.bindGrid({
			ajaxUrl:"/approval/admin/getStatPersonList.do",
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

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(pModal, configkey){
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	//엔터검색
	function cmdSearch(){
		searchConfig(1);
	}

	// Select box 바인드
	function setSelect(){
		$("#selectDdlCompany").bindSelect({
			reserveKeys: {
				options: "list",
				optionValue: "optionValue",
				optionText: "optionText"
			}
			,ajaxUrl: "/approval/common/getEntInfoListAssignData.do"
			,ajaxAsync:false
			,onchange: function() {
				searchSTAT();
			}
		});
	}

	function ChageView() {
		$("#startDate").val("");
		$("#endDate").val("");
		//$("#selectDdlCompany").bindSelectSetValue("ORGROOT");
		
		searchSTAT();
    }
	
	function searchSTAT(){
		//검색
		var radioval = $("input[type=radio]:checked").val();
		if (radioval == "GetDept") {
			searchConfig1();
    		$("#GetDeptgrid").show();
    		$("#GetFormgrid").hide();
    		$("#GetUsergrid").hide();    	
        } else if (radioval == "GetForm") {
    		searchConfig2();
    		$("#GetDeptgrid").hide();
    		$("#GetFormgrid").show();
    		$("#GetUsergrid").hide();
        } else {
    		searchConfig3();
    		$("#GetDeptgrid").hide();
    		$("#GetFormgrid").hide();
    		$("#GetUsergrid").show();
        }
	}
	
	// 엑셀 다운로드
	function ExcelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage' />", "Confirmation Dialog", function(result){
			if(result){
				var radioval = $("input[type=radio]:checked").val();
				var EntCode = $("#selectDdlCompany").val();
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

				var sURL = "/approval/admin/typeCountsExcelDownload.do";
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
		
		var radioval = $("input[type=radio]:checked").val();
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