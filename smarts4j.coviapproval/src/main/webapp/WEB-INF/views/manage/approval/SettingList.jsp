<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<div class="cRConTop titType">
	<h2 class="title">결재 설정 관리</h2>
	<div class="searchBox02">
		<span><input id="searchInputSimple" type="text" onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}">
		<button type="button" id="simpleSearchBtn" class="btnSearchType01" onclick="searchList(this);"><spring:message code="Cache.btn_search"/></button></span>
		<a href="#" class="btnDetails" onclick="DetailDisplay(this);"><spring:message code="Cache.lbl_apv_detail"/></a>
	</div>
</div>
<div class="cRContBottom mScrollVH">
	<!-- 상세 검색영역 -->
	<div id="DetailSearch" class="inPerView type02 sa04">
		<div>
			<div class="selectCalView">
				<select class="selectType02" id="selectUseYN">
					<option selected="selected" value=""><spring:message code='Cache.lbl_Whole'/></option>
					<option value="Y"><spring:message code='Cache.lbl_UseY'/></option>
					<option value="N"><spring:message code='Cache.lbl_UseN'/></option>	
				</select>
				<select class="selectType02 w120p" id="selectSettingType">
					<option selected="selected" value=""><spring:message code='Cache.lbl_Whole'/></option>
					<option value="BaseCode"><spring:message code='Cache.lbl_hrMng_BaseCode'/></option>
					<option value="BaseConfig"><spring:message code='Cache.lbl_hrMng_BaseConfig'/></option>	
					<option value="PropetiesFile"><spring:message code='Cache.lbl_PropetiesFile'/></option>
					<option value="Form"><spring:message code='Cache.lbl_apv_form'/></option>	
					<option value="Schema"><spring:message code='Cache.lbl_apv_Schema'/></option>
				</select>
				<select class="selectType02" id="sel_Search">
					<option selected="selected" value="SettingKey"><spring:message code='Cache.lbl_SettingKey'/></option>
					<option value="SettingName"><spring:message code='Cache.lbl_SettingName'/></option>	
					<option value="SettingValue"><spring:message code='Cache.lbl_SettingValue'/></option>
					<option value="Description"><spring:message code='Cache.lbl_Description'/></option>	
				</select>
				<input type="text" value="" id="search" onKeyPress="if (event.keyCode == 13) {searchConfig();}">
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchConfig();"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<div class="sadminContent">
		<!-- 상단버튼 영역 -->
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<label id="settingDesc" style="display: inline-block; vertical-align: middle; font-size: 14px; line-height: 31px;"></label>
			</div>
			<div class="buttonStyleBoxRight">
				<a class="btnTypeDefault" onclick="synchronize();"><spring:message code="Cache.lbl_Synchronization"/></a>
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div id="GridViewSettingList" class="tblList"></div>
	</div>
</div>
<input type="hidden" id="hiddenGroupWord" value="" />
<script>
	var lang = Common.getSession("lang");
	var myGrid = new coviGrid();
	initSettingList();

	function initSettingList(){
		setSelect();		
		setGrid();			// 그리드 세팅
		
		$(".btnDetails").click();
	}
	
	//그리드 세팅
	function setGrid(){
		var headerData =[
			{key:'SettingGubun', label:'<spring:message code="Cache.lbl_ConfigType"/>', width:'45', align:'center',
          	  	formatter:function () {
          	  		var SettingGubun = "";
	          	  	switch(this.item.SettingType) {
		          		case 'BaseCode':
		          			SettingGubun = "<spring:message code='Cache.lbl_hrMng_BaseCode'/>";
		          	    	break;
		          		case 'BaseConfig':
		          			SettingGubun = "<spring:message code='Cache.lbl_hrMng_BaseConfig'/>";
		          	    	break;
		          		case 'PropetiesFile':
		          			SettingGubun = "<spring:message code='Cache.lbl_PropetiesFile'/>";
		          	    	break;
		          		case 'Form':
		          			SettingGubun = "<spring:message code='Cache.lbl_apv_form'/>";
		          	    	break;
		          		case 'Schema':
		          			SettingGubun = "<spring:message code='Cache.lbl_apv_Schema'/>";
		          	    	break;
		          	  	default:
		          	    	break;
		          	}
					return "<a>"+SettingGubun+"</a>";
				}
			},
			{key:'SettingKey',  label:'<spring:message code="Cache.lbl_SettingKey"/>', width:'45', align:'center'},
			{key:'SettingName', label:'<spring:message code="Cache.lbl_SettingName"/>', width:'45', align:'left'},
			{key:'SettingValue', label:'<spring:message code="Cache.lbl_SettingValue"/>', width:'45', align:'left'},
			{key:'Description',  label:'<spring:message code="Cache.lbl_Description"/>', sort:false, width:'150', align:'left'},
		];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();			
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "GridViewSettingList",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:300
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
	}

	function searchConfig(){
		var settingType = $("#selectSettingType").val();
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();
		var isUse = $("#selectUseYN").val();
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/manage/getSettingListData.do",
				ajaxPars: {
					"domainID":confMenu.domainId,
					"settingType":settingType,
					"sel_Search":sel_Search,
					"search":search,
					"isUse":isUse,
					"icoSearch":$("#searchInputSimple").val()
				},
				onLoad:function(){
					//아래 처리 공통화 할 것
					coviInput.setSwitch();
					//custom 페이징 추가
					$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    	myGrid.fnMakeNavi("myGrid");
				}
		});
	}
	
	// 상세검색 열고닫기
	function DetailDisplay(pObj){
		if($("#DetailSearch").hasClass("active")){
			$(pObj).removeClass("active");
			$('#DetailSearch').removeClass("active");
		}else{
			$(pObj).addClass("active");
			$('#DetailSearch').addClass("active");
		}
		
		$(".contbox").css('top', $(".content").height());
	}

	function searchList(pObj) {
		searchConfig();
	}
	
	// 새로고침
	function Refresh(){
		searchConfig();
	}
	
	// 동기화
	function synchronize(){		
		Common.Confirm("<spring:message code='Cache.msg_synchronize'/>", "Confirmation Dialog", function (result) {
			if(result) {
				$.ajax({
					url : "/approval/admin/synchronizeSetting.do",
					data: {},
					type : "POST",
					success : function(d) {
						if(d.status == "SUCCESS") {
							Common.Inform("<spring:message code='Cache.msg_apv_alert_006'/>", "Inform", function() {
								Refresh();
							});
						} else {
							Common.Warning("<spring:message code='Cache.msg_apv_030'/>", "Warning", function() {
								Refresh();
							});
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/approval/admin/synchronizeSetting.do", response, status, error);
					}
				});
			}
		});
	}
	
	// Select box 바인드
	function setSelect(){
		$("#selectSettingType").change(function(){
			searchConfig();
			if($("#selectSettingType").val() == "") {
				$("#settingDesc").text("");
			} else {
				$("#settingDesc").text(Common.getDic("ToolTip_setting_desc_" + $("#selectSettingType").val()));
			}
	    });

		//라디오버튼변경시
		$('#selectUseYN').change(function() {			
			 searchConfig();
		});
	}
</script>