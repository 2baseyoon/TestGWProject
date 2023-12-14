<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<h3 class="con_tit_box">
	<span class="con_tit">결재 설정 관리</span>	
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton" value="<spring:message code="Cache.lbl_Synchronization"/>" onclick="synchronize();"/>
			<label style="float: right;" id="settingDesc"></label>
		</div>
		<div id="topitembar02" class="topbar_grid">
			<spring:message code='Cache.lbl_UseAuthority'/>:
			<select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select>
			&nbsp;&nbsp;&nbsp;&nbsp;		
			&nbsp;&nbsp;
			<spring:message code='Cache.lbl_ConfigType'/>:
			<select class="AXSelect" name="selectSettingType" id="selectSettingType" >
				<option selected="selected" value=""><spring:message code='Cache.lbl_Whole'/></option>
				<option value="BaseCode"><spring:message code='Cache.lbl_hrMng_BaseCode'/></option>
				<option value="BaseConfig"><spring:message code='Cache.lbl_hrMng_BaseConfig'/></option>	
				<option value="PropetiesFile"><spring:message code='Cache.lbl_PropetiesFile'/></option>
				<option value="Form"><spring:message code='Cache.lbl_apv_form'/></option>	
				<option value="Schema"><spring:message code='Cache.lbl_apv_Schema'/></option>	
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;	
			<select class="AXSelect" name="sel_Search" id="sel_Search" >
				<option selected="selected" value="SettingKey"><spring:message code='Cache.lbl_SettingKey'/></option>
				<option value="SettingName"><spring:message code='Cache.lbl_SettingName'/></option>	
				<option value="SettingValue"><spring:message code='Cache.lbl_SettingValue'/></option>
				<option value="Description"><spring:message code='Cache.lbl_Description'/></option>	
			</select>	
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" class="AXInput" />				
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(1);" class="AXButton"/>
			&nbsp;&nbsp;&nbsp;&nbsp;                  
			<input name="rdblUseYN" id="rdblUseYN_0" type="radio" value="">
			<label for="rdblUseYN_0"><spring:message code='Cache.lbl_Whole'/></label>
			<input name="rdblUseYN" id="rdblUseYN_1" type="radio" checked="checked" value="Y">
			<label for="rdblUseYN_1"><spring:message code='Cache.lbl_UseY'/></label>					
			<input name="rdblUseYN" id="rdblUseYN_2" type="radio" value="N">
			<label for="rdblUseYN_2"><spring:message code='Cache.lbl_UseN'/></label>
			
		</div>	
		<div id="GridViewSettingList"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
	<input type="hidden" id="hidden_worktype_val" value=""/>
</form>
<script type="text/javascript">
	var myGrid = new coviGrid();
	var baseConfigGrid = new coviGrid();
	initSettingList();

	function initSettingList(){
		setSelect();		
		setGrid();			// 그리드 세팅
		
		baseConfigGrid = myGrid;
	}
	
	//그리드 세팅
	function setGrid(){
		var headerData =[             
			{key:'SettingKey',  label:'<spring:message code="Cache.lbl_SettingKey"/>', width:'45', align:'center',
	           	formatter:function(){
	           		if(this.item.SettingType == "BaseConfig") {
	           			return "<a onclick='updateSetting(true, \""+ this.item.SettingID +"\"); return false;'>"+this.item.SettingKey+"</a>";
	           		} else {
	           			return this.item.SettingKey;
	           		}
	           	}
			},
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

	// baseconfig 검색
	function searchConfig(flag){
		var domainID = $("#selectUseAuthority").val();
		var settingType = $("#selectSettingType").val();
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();
		var isUse = $("input[name=rdblUseYN]:checked").val();
		myGrid.page.pageNo = 1;
		myGrid.bindGrid({
				ajaxUrl:"/approval/admin/getSettingListData.do",
				ajaxPars: {
					"domainID":domainID,
					"settingType":settingType,
					"sel_Search":sel_Search,
					"search":search,
					"isUse":isUse
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

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateSetting(pModal, pSettingID){
		parent.Common.open("","updatebaseconfig","설정수정","/covicore/baseconfig/goBaseConfigPopup.do?mode=modify&configID="+pSettingID,"600px","310px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
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
	
	//엔터검색
	function cmdSearch(){
		searchConfig();
	}
	
	// Select box 바인드
	function setSelect(){
		$("#selectUseAuthority").coviCtrl("setSelectOption", "/approval/common/getEntInfoListData.do", {"type" : "ID"});
		$("#selectUseAuthority").bindSelect({
			onchange: function(){
				searchConfig();
			}
		});
		
		$("#selectSettingType").bindSelect({
			onchange: function(){
				searchConfig();
				if($("#selectSettingType").val() == "") {
					$("#settingDesc").text("");
				} else {
					$("#settingDesc").text(Common.getDic("ToolTip_setting_desc_" + $("#selectSettingType").val()));
				}
			}
		});

		//라디오버튼변경시
		$('input[type=radio][name=rdblUseYN]').change(function() {			
			 searchConfig();
		});
	}
	
</script>