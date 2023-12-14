<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.CN_104"/></span> <!-- 사별 집계정보 -->
	</h2>
</div>

<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa04 active" id="DetailSearch">
		<div>
			<div class="selectCalView" id="topitembar02">
				<span><spring:message code="Cache.lbl_apv_select_period"/>(<spring:message code="Cache.lbl_Standard"/>:<spring:message code="Cache.lbl_apv_standard_enddate"/>)</span>
				<div class="dateSel type02">
					<input class="adDate" id="startDate" kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="endDate" />
					<span>~</span>
					<input class=" adDate" id="endDate" kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="startDate" />
				</div>
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchSTAT();"><spring:message code="Cache.btn_search"/></a>
				<!-- <input type="button" value="엑셀저장" onclick="ExcelDownload();" class="AXButton BtnExcel"/> -->
			</div>
			<div class="selectCalView" id="topitembar03" style="display: none">
				<span><spring:message code="Cache.lbl_apv_compareItem"/></span>				
				<select class="selectType02 w120p" name="selectCompareItem" id="selectCompareItem" ></select>
				<span style="margin-left:10px;"><spring:message code="Cache.lbl_Start"/>&nbsp;<spring:message code="Cache.lbl_apv_year"/>/<spring:message code="Cache.lbl_apv_month"/></span>
				<select class="selectType02 w70p" name="selectYear" id="selectYear"></select>
				<span><spring:message code="Cache.lbl_apv_year"/></span>
				<!-- <input type="button" value="<spring:message code="Cache.lbl_apv_SaveToExcel"/>" onclick="ExcelDownload();" class="AXButton BtnExcel"/> -->
			</div>
			<div id="topitembar01" class="selectCalView">
				<div class="radioStyle05"><input type="radio" id="Dept" name="radio" value="GetDept" onclick="ChageView(this);" checked="checked"><label for="Dept"><spring:message code="Cache.lbl_apv_DocCNT_total" /></label></div>
				<div class="radioStyle05"><input type="radio" id="Form" name="radio" value="GetForm" onclick="ChageView(this);"><label for="Form"><spring:message code="Cache.lbl_apv_ByForm"/> <spring:message code="Cache.lbl_apv_month_total" /></label></div>
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
			<div id="GetDeptgrid"></div>
			<div id="GetFormgrid"></div>
		</div>
		<input type="hidden" id="hidden_domain_val" value=""/>
		<input type="hidden" id="hidden_worktype_val" value=""/>
	</div>
</div>

<script type="text/javascript">
	var headerData1 = null;
	var headerData2 = null;

	var myGrid1 = new coviGrid();
	var myGrid2 = new coviGrid();
	myGrid1.config.fitToWidthRightMargin = 0;
	myGrid2.config.fitToWidthRightMargin = 0;
	
	initAffiliatesInform();

	function initAffiliatesInform() {
		setControl(); // 초기 셋팅
		setGrid();			// 그리드 세팅	
		//SetddlView();
		searchSTAT();
	}

	// 초기 셋팅
	function setControl(){ 
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
		
		// 비교항목 셋팅
		$("#selectCompareItem").change(function(){
			searchSTAT();
	    });
		
		// 년도 셋팅
		$("#selectYear").change(function(){
			searchSTAT();
	    });
	}
	
	// 비교항목 셋팅
	function SetddlView(){
		var objSelect = $("#selectCompareItem");
		$(objSelect).find("option").remove();
		$(objSelect).append("<option value='A'>" + "<spring:message code='Cache.lbl_apv_approval_count'/>" + "</option>")
    	$(objSelect).append("<option value='B'>" + "<spring:message code='Cache.lbl_apv_receive_count'/>" + "</option>")
	}
	
	// 년도 셋팅
	function SetYear() {
		var Today = new Date();
		var Year = Today.getFullYear();
		var objSelect = $("#selectYear");
		
		for (var i = 0; i < 10; i++)
        {
			var option = $("<option>");
			$(option).attr("value",Year);
			$(option).text(Year);
			$(objSelect).append(option);
			Year--;
        }
		$(objSelect).val(Today.getFullYear());
	}
	
	//그리드 세팅
	function setGrid() {
		// 헤더 설정
		headerData1 =[	            
	                  {key:'DN_Name', label:'<spring:message code="Cache.lbl_CorpName"/>', width:'500', align:'center',sort:"asc"},
	                  {key:'A_Count',  label:'<spring:message code="Cache.lbl_apv_approval_count"/>', width:'250', align:'center'},
	                  {key:'REQCMP_count',  label:'<spring:message code="Cache.lbl_apv_receive_count"/>', width:'250', align:'center'},
	                  {key:'document_leadtime', label:'<spring:message code="Cache.lbl_apv_average_time"/>', width:'200', align:'center'}
		      		];
		
		headerData2 =[	            
	                  {key:'DN_Name', label:'<spring:message code="Cache.lbl_CorpName"/>', width:'200', align:'center',sort:"asc"},
	                  {key:'Month1',  label:'<spring:message code="Cache.lbl_apv_Month_1"/>', width:'50', align:'center'},
	                  {key:'Month2',  label:'<spring:message code="Cache.lbl_apv_Month_2"/>', width:'50', align:'center'},
	                  {key:'Month3',  label:'<spring:message code="Cache.lbl_apv_Month_3"/>', width:'50', align:'center'},
	                  {key:'Month4',  label:'<spring:message code="Cache.lbl_apv_Month_4"/>', width:'50', align:'center'},
	                  {key:'Month5',  label:'<spring:message code="Cache.lbl_apv_Month_5"/>', width:'50', align:'center'},
	                  {key:'Month6',  label:'<spring:message code="Cache.lbl_apv_Month_6"/>', width:'50', align:'center'},
	                  {key:'Month7',  label:'<spring:message code="Cache.lbl_apv_Month_7"/>', width:'50', align:'center'},
	                  {key:'Month8',  label:'<spring:message code="Cache.lbl_apv_Month_8"/>', width:'50', align:'center'},
	                  {key:'Month9',  label:'<spring:message code="Cache.lbl_apv_Month_9"/>', width:'50', align:'center'},
	                  {key:'Month10',  label:'<spring:message code="Cache.lbl_apv_Month_10"/>', width:'50', align:'center'},
	                  {key:'Month11',  label:'<spring:message code="Cache.lbl_apv_Month_11"/>', width:'50', align:'center'},
	                  {key:'Month12',  label:'<spring:message code="Cache.lbl_apv_Month_12"/>', width:'50', align:'center'}
		      		];
		
		myGrid1.setGridHeader(headerData1);
		myGrid2.setGridHeader(headerData2);
		
		setGridConfig1();
		setGridConfig2();
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
	
	// GetDeptgrid 검색
	function searchConfig1(flag){
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		myGrid1.page.pageNo = 1;
		myGrid1.bindGrid({
			ajaxUrl:"/approval/manage/getEntCountList.do",
			ajaxPars: {
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
		var CompareItem = $("#selectCompareItem").val();
		var Year = $("#selectYear").val();
		myGrid2.page.pageNo = 1;
		myGrid2.bindGrid({
			ajaxUrl:"/approval/manage/getEntMonthlyCountList.do",
			ajaxPars: {
				"CompareItem":CompareItem,
				"Year":Year
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

	
	
	function ChageView(value) {
		$("#GetDeptgrid").hide();
    	$("#GetFormgrid").hide();
    	
    	if(value.value=="GetDept") {
    		$("#topitembar02").show();
    		$("#topitembar03").hide(); 
    	}else if (value.value == "GetForm") {
    		$("#topitembar02").hide();
    		$("#topitembar03").show();
    		SetddlView(); // 비교항목 셋팅
    		SetYear(); // 년도 셋팅
        }
    	
    	searchSTAT(true);
    }
	
	
	
	function searchSTAT(bChangeConfig){
		//검색
		var radioval = $("#DetailSearch input[name=radio]:checked").val();
		if (radioval == "GetDept") {
    		$("#GetDeptgrid").show();
    		$("#GetFormgrid").hide();
    		if(bChangeConfig) setGridConfig1();
			searchConfig1();
        } else if (radioval == "GetForm") {
    		$("#GetDeptgrid").hide();
    		$("#GetFormgrid").show();
    		if(bChangeConfig) setGridConfig2();
    		searchConfig2();
        }
	}
	
	// 엑셀 다운로드
	function ExcelDownload(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage' />", "Confirmation Dialog", function(result) {
			if(result){
				var radioval = $("#DetailSearch input[name=radio]:checked").val();
				var startDate = $("#startDate").val();
				var endDate = $("#endDate").val();
				var CompareItem = $("#selectCompareItem").val();
				var Year = $("#selectYear").val();
				
				var headerName = getHeaderNameForExcel();
				
				var sortKey;
				var sortWay;
				
				if (radioval == "GetDept") {
					sortKey = myGrid1.getSortParam("one").split("=")[1].split(" ")[0];
					sortWay = myGrid1.getSortParam("one").split("=")[1].split(" ")[1];
		        } else if (radioval == "GetForm") {
		        	sortKey = myGrid2.getSortParam("one").split("=")[1].split(" ")[0];
		        	sortWay = myGrid2.getSortParam("one").split("=")[1].split(" ")[1];
		        }
				
				var sURL = "/approval/manage/affiliatesAggregateInformationExcelDownload.do";
				sURL += "?radioval=" + radioval;
				sURL += "&startDate=" + startDate;
				sURL += "&endDate=" + endDate;
				sURL += "&CompareItem=" + CompareItem;
				sURL += "&Year=" + Year;
				sURL += "&sortKey=" + sortKey;
				sURL += "&sortWay=" + sortWay;
				sURL += "&headerName=" + encodeURIComponent(encodeURIComponent(headerName));
				
				location.href = sURL;
			}
		});
	}
	
	function getHeaderNameForExcel() {
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
        } 
		
		return returnStr;
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
</script>