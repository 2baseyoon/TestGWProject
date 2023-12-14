<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js"></script>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.lbl_RuleMasterListTitle'/></span>
</h3>
<div style="width:100%;min-height: 500px">		
	<div id="topitembar02" class="topbar_grid">
		<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
		<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="popup('', '');"/>
		<select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select>
		&nbsp;&nbsp;		
		<select class="AXSelect"  name="sel_Search" id="sel_Search" ></select>
		<span id="GubunWrapper">
			<select class="AXSelect"  name="sel_Gubun" id="sel_Gubun"></select>
		</span>
		<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ search(); return false;}" class="AXInput" />
		<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="search(); return false;" class="AXButton"/> <!-- 검색 -->
	</div>		
	<div id="gridDiv"></div>
</div>

<script>
	var grid = new coviGrid();
	
	initMasterMgnList();
	
	function initMasterMgnList(){
		setSelect();		// 사용권한 selectbox
		setGrid();			// 그리드 세팅
		search();			// 검색
	}

	// 도메인 selectbox
	function setSelect() {
		$("#GubunWrapper").hide();
		
		$("#selectUseAuthority").coviCtrl("setSelectOption", "/approval/common/getEntInfoListAssignData.do");
		$("#selectUseAuthority").bindSelect({
			onchange: function(){
				search();		// 검색
			}
		});

		$("#sel_Search").bindSelect({
			options : [
				{"optionValue":"BizRuleName","optionText":"<spring:message code='Cache.lbl_apv_Name'/></option>"},
				{"optionValue":"BizRuleType","optionText":"<spring:message code='Cache.lbl_apv_gubun'/></option>"}
			],
			onchange: function(){
				$("#search").val("");
				switch(this.optionValue){
				case "BizRuleName":
					$("#search").show();
					$("#GubunWrapper").hide();
					break;
				case "BizRuleType":
					$("#sel_Gubun").bindSelect({
						options : [
							{"optionValue":"","optionText":"<spring:message code='Cache.lbl_apv_total'/></option>"},
							{"optionValue":"0","optionText":"<spring:message code='Cache.lbl_apv_teamleader'/></option>"},
							{"optionValue":"1","optionText":"<spring:message code='Cache.lbl_apv_headdepartment'/></option>"},
							{"optionValue":"2","optionText":"<spring:message code='Cache.lbl_apv_jobposition'/></option>"},
							{"optionValue":"3","optionText":"<spring:message code='Cache.lbl_apv_people'/></option>"},
							{"optionValue":"4","optionText":"<spring:message code='Cache.lbl_apv_dept'/></option>"},
							{"optionValue":"5","optionText":"<spring:message code='Cache.lbl_apv_rule03'/></option>"},
							{"optionValue":"6","optionText":"<spring:message code='Cache.btn_apv_chargebiz'/></option>"}
						],
						onchange: function(){
							$("#search").val(this.optionValue);
						}
					});
					
					$("#search").hide();
					$("#GubunWrapper").show();
					break;
				}				
			}
		});
	}
	
	// 그리드 세팅
	function setGrid() {
		// header
		var headerData = [		
		                  {key:'EntCode', label:'<spring:message code="Cache.lbl_Domain"/>', width:'50', align:'center', sort:"asc"},	                 
		                  {key:'RuleName', label:'<spring:message code="Cache.lbl_apv_Name"/>', width:'50', align:'center',
						   	  formatter:function () {
						   			var mappingName = typeof(this.item.MappingNames) == "undefined" ? "" : this.item.MappingNames;
						   		
						   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
						   				html += "<a class=\"taTit\" onclick='popup(\"RuleName\",\"" + this.item.RuleID + "," + this.item.RuleName + "," + this.item.RuleType + "," + this.item.MappingCode + "," + mappingName + "," + "\"); return false;'>" + this.item.RuleName + "</a>";
						   				html += "</div>";
						   			return html;
								}
		                  },
		                  {key:'RuleType',  label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'50', align:'center',
						   	  formatter:function () {
									var ruleTypeName = "";
									switch(this.item.RuleType){
									case "0":
										ruleTypeName = '<spring:message code="Cache.lbl_apv_teamleader"/>';
										break;
									case "1":
										ruleTypeName = '<spring:message code="Cache.lbl_apv_headdepartment"/>';
										break; 
									case "2":
										ruleTypeName = '<spring:message code="Cache.lbl_apv_jobposition"/>';
										break;
									case "3":
										ruleTypeName = '<spring:message code="Cache.lbl_apv_people"/>';
										break;
									case "4":
										ruleTypeName = '<spring:message code="Cache.lbl_apv_dept"/>';
										break;
									case "5":
										ruleTypeName = '<spring:message code="Cache.lbl_apv_rule03"/>';
										break;
									case "6":
										ruleTypeName = '<spring:message code="Cache.btn_apv_chargebiz"/>';
										break;
									}
							   	  
						   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
					   				html += "<span class=\"btn_emer\">" + ruleTypeName + "</span>";
						   			html += "</div>";
						   			return html;
								}},	      								
		                  {key:'MappingNames', label:'mapping', width:'150', align:'center', sort:false,
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
						   			var mappingName = typeof(this.item.MappingNames) == "undefined" ? "" : this.item.MappingNames;

									if(mappingName.indexOf("|") > 0){
										var tempMappingName = mappingName.split("|");
										$(tempMappingName).each(function(idx, item){
											tempMappingName[idx] = CFN_GetDicInfo(item);
										});
										mappingName = tempMappingName.join("|");
									} else {
										mappingName = CFN_GetDicInfo(mappingName);
									}
						   			
						   			if (mappingName == "" && (this.item.RuleType == 1 || this.item.RuleType == 2)) {
						   				html += "<a class=\"taTit\" onclick='popup(\"MappingNames\",\"" + this.item.RuleID + "," + this.item.RuleType + "," + this.item.DN_ID + "\"); return false;'>" + "선택하세요" + "</a>";
						   			} else if (this.item.RuleType == 3 || this.item.RuleType == 4 || this.item.RuleType == 5 || this.item.RuleType == 6) {
						   				html += "<span class=\"btn_emer\">" + mappingName + "</span>";
						   			} else {
						   				html += "<a class=\"taTit\" onclick='popup(\"MappingNames\",\"" + this.item.RuleID + "," + this.item.RuleType + "," + this.item.DN_ID + "\"); return false;'>" + mappingName + "</a>";
						   			}
						   			
						   			html += "</div>";
						   			return html;
								}
		                  }
			      		 ];
		grid.setGridHeader(headerData);
		
		// config
		var configObj = {
			targetID : "gridDiv",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",			
			paging : true,
			page : {
				pageNo:1,
				pageSize:10
			},
		};
		grid.setGridConfig(configObj);
	}

	// 검색
	function search() {
		// bind
		grid.page.pageNo = 1;
		grid.bindGrid({
			ajaxUrl : "/approval/admin/getMasterManagementList.do",
			ajaxPars : {
				"entCode" : $("#selectUseAuthority").val() ,
				"sel_Search" :   $("#sel_Search").val(),
				"search" :   $("#search").val()
				
			},
			onLoad : function() {
				//아래 처리 공통화 할 것
				coviInput.setSwitch();
				//custom 페이징 추가
				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
				grid.fnMakeNavi("grid");
			}
		});
	}	
	
	// 추가 버튼
	function popup(type, data) {
		var pModal = true;
		var entCode = $("#selectUseAuthority").val();
		
		parent.Common.open("","addPopup","<spring:message code='Cache.lbl_RuleMasterListTitle'/>","/approval/admin/getMasterManagementPopup.do?mode="+type+"&data="+encodeURIComponent(data)+"&entCode="+entCode,"550px","280px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh() {
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
</script>
