<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js"></script>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_RuleMasterListTitle"/></span> <!-- 마스터 관리 -->
	</h2>
</div>

<div class="cRContBottom mScrollVH">
	<div class="inPerView type02 sa02 active" id="DetailSearch">
		<div>
			<!-- <select  name="selectUseAuthority" class="AXSelect" id="selectUseAuthority"></select> -->
			<div class="selectCalView">
				<select class="selectType02 w120p" name="sel_Search" id="sel_Search" ></select>
				<span id="GubunWrapper"><select class="selectType02 w120p" name="sel_Gubun" id="sel_Gubun" ></select></span>
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchList(); return false;}" />
			</div>
			<a href="#" class="btnTypeDefault btnSearchBlue nonHover" onclick="searchList();"><spring:message code="Cache.btn_search"/></a>
		</div>
	</div>
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a id="btnFormAdd" class="btnTypeDefault btnPlusAdd" href="#" onclick="popup('', '');"><spring:message code="Cache.btn_Add"/></a>
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select class="selectType02 listCount" id="selectPageSize" onchange="searchList();">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="gridDiv"></div>
		</div>
		<input type="hidden" id="hidden_domain_val" value=""/>
	</div>
</div>

<script>
	var grid = new coviGrid();
	grid.config.fitToWidthRightMargin = 0;
	
	initMasterMgnList();
	
	function initMasterMgnList(){
		setControl()	// 초기 셋팅
		setSelect();		// 사용권한 selectbox
		setGrid();			// 그리드 세팅
		searchList();			// 검색
	}

	// 초기 셋팅
	function setControl(){ 
		// 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
	}

	// selectbox
	function setSelect() {
		$("#GubunWrapper").hide();
		
		$("#sel_Search").find("option").remove();
		$("#sel_Search").append("<option value='BizRuleName'>" + "<spring:message code='Cache.lbl_apv_Name'/>" + "</option>");
		$("#sel_Search").append("<option value='BizRuleType'>" + "<spring:message code='Cache.lbl_apv_gubun'/>" + "</option>");
		
		$("#sel_Search").change(function(){
			$("#search").val("");
			switch(this.value){
				case "BizRuleName":
					$("#search").show();
					$("#GubunWrapper").hide();
					break;
				case "BizRuleType":
					$("#sel_Gubun").find("option").remove();
					$("#sel_Gubun").append("<option value=''>" + "<spring:message code='Cache.lbl_apv_total'/>" + "</option>");
					$("#sel_Gubun").append("<option value='0'>" + "<spring:message code='Cache.lbl_apv_teamleader'/>" + "</option>");
					$("#sel_Gubun").append("<option value='1'>" + "<spring:message code='Cache.lbl_apv_headdepartment'/>" + "</option>");
					$("#sel_Gubun").append("<option value='2'>" + "<spring:message code='Cache.lbl_apv_jobposition'/>" + "</option>");
					$("#sel_Gubun").append("<option value='3'>" + "<spring:message code='Cache.lbl_apv_people'/>" + "</option>");
					$("#sel_Gubun").append("<option value='4'>" + "<spring:message code='Cache.lbl_apv_dept'/>" + "</option>");
					$("#sel_Gubun").append("<option value='5'>" + "<spring:message code='Cache.lbl_apv_rule03'/>" + "</option>");
					$("#sel_Gubun").append("<option value='6'>" + "<spring:message code='Cache.btn_apv_chargebiz'/>" + "</option>");
					
					/*$("#sel_Gubun").change(function(){
						$("#search").val(this.value);
					});*/
					
					$("#search").val("");
					$("#search").hide();
					$("#GubunWrapper").show();
					break;
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
						   			if (this.item.RuleType == 1 || this.item.RuleType == 2) {
						   				mappingName = "";// 불필요
						   			}
						   			var html = "<div class=\"tableTxt\" style=\"width : 95%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden\";>";
						   				html += "<a style='text-decoration: underline;' class=\"taTit\" onclick='popup(\"RuleName\",\"" + this.item.RuleID + "," + this.item.RuleName + "," + this.item.RuleType + "," + this.item.MappingCode + "," + mappingName + "," + "\"); return false;'>" + this.item.RuleName + "</a>";
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
					   				//html += "<span class=\"btn_emer\">" + ruleTypeName + "</span>";
					   				html += ruleTypeName;
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
						   				html += "<a style='text-decoration: underline;' class=\"taTit\" onclick='popup(\"MappingNames\",\"" + this.item.RuleID + "," + this.item.RuleType + "," + this.item.DN_ID + "\"); return false;'>" + "선택하세요" + "</a>";
						   			} else if (this.item.RuleType == 3 || this.item.RuleType == 4 || this.item.RuleType == 5 || this.item.RuleType == 6) {
						   				//html += "<span class=\"btn_emer\">" + mappingName + "</span>";
						   				html += mappingName;
						   			} else {
						   				html += "<a style='text-decoration: underline;' class=\"taTit\" onclick='popup(\"MappingNames\",\"" + this.item.RuleID + "," + this.item.RuleType + "," + this.item.DN_ID + "\"); return false;'>" + mappingName + "</a>";
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
	function searchList() {
		// bind 
		grid.page.pageNo = 1;
		grid.page.pageSize = $("#selectPageSize").val();
		grid.bindGrid({
			ajaxUrl : "/approval/manage/getMasterManagementList.do",
			ajaxPars : {
				"entCode" : $("#hidden_domain_val").val() ,
				"sel_Search" :   $("#sel_Search").val(),
				"search" :   ($("#sel_Search").val() == "BizRuleType") ? $("#sel_Gubun").val() : $("#search").val()
				
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
		var entCode = $("#hidden_domain_val").val();
		
		parent.Common.open("","addPopup","<spring:message code='Cache.lbl_RuleMasterListTitle'/>","/approval/manage/getMasterManagementPopup.do?mode="+type+"&data="+encodeURIComponent(data)+"&entCode="+entCode
				,"550px","325px","iframe",pModal,null,null,true);
	}
	
	// 새로고침
	function Refresh() {
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
</script>
