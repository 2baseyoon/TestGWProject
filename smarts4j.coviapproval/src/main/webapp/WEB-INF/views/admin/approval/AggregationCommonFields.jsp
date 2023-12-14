<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>

<h3 class="con_tit_box">
	<span class="con_tit">공통필드 관리</span>
</h3>
<form id="form1">
	<div id="topitembar01" class="topbar_grid">
		<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" />
		<!-- 새로고침 -->
		<input type="button" class="AXButton BtnAdd" value="<spring:message code="Cache.btn_Add"/>" />
		<!-- 추가 -->
	</div>
	<div id="topitembar02" class="topbar_grid">
		<select name="Companys" class="AXSelect" id="Companys"></select>
	</div>
	<div id="commonFieldGrid"></div>
</form>
<script>
    // grid
    var companys = document.querySelector("#Companys");
    var ListGrid = new coviGrid();
    var headerData = [
        { key: 'fieldName', label: '<spring:message code="Cache.lbl_FieldNm"/>', width: '1', align: 'center', formatter: function(){
        	return CFN_GetDicInfo(this.item.fieldName)
        }},
        { key: 'fieldId', label: '<spring:message code="Cache.lbl_FieldId"/>', width: '1', align: 'center' },
        { key: 'dataFormat', label: '<spring:message code="Cache.lbl_otherProcessing"/>', width: '1', align: 'center', formatter: function(){
        	var dataFormatName;
        	switch(this.item.dataFormat){
        	case "dictionary":
        		dataFormatName = "<spring:message code='Cache.lbl_MultiLang2'/>";
        		break;
        	case "dateFormat":
        		dataFormatName = "<spring:message code='Cache.lbl_date'/>(YYYY-MM-DD)";
        		break;
        	case "formOpen":
        		dataFormatName = "<spring:message code='Cache.lbl_openApprovalDoc'/>";
        		break;
       		case "linkFile":
        		dataFormatName = "<spring:message code='Cache.lbl_apv_filelink'/>";
        		break;
       		default:
       			dataFormatName = "";
        	}
        	return dataFormatName;
        }},
        { key: 'sortKey', label: '<spring:message code="Cache.lbl_apv_Sort"/>', width: '1', align: 'center' },
    ];

    var configObj = {
        targetID: "commonFieldGrid",
        height: "auto",
        paging: false,
		body: {
			onclick: function(){
				Common.open("","commonFieldManage",
		    			"<spring:message code='Cache.lbl_modifyCommonFields'/>", /* 공통필드 수정 */
		    			"/approval/admin/aggregation/form/commonFieldManage.do?mode=m&key="+this.item.aggFieldId,
						"520px","350px","iframe",true,null,null,true);
			}
		}
    };
    
    ListGrid.setGridHeader(headerData);
    ListGrid.setGridConfig(configObj);
	
    var setList = function(){
		ListGrid.page.pageNo = 1;
		ListGrid.bindGrid({
			ajaxUrl:"/approval/admin/aggregation/form/commonfields.do",
			ajaxPars: {
				"entCode":companys.value
			},
			onLoad : function(){
				
			}
		});
    }
    
	$("#Companys").bindSelect({
		reserveKeys: {
			options: "list",
			optionValue: "optionValue",
			optionText: "optionText"
		},
		ajaxUrl: "/approval/common/getEntInfoListAssignData.do",			
		ajaxAsync:false,
		onchange: setList,
		onLoad : setList
	});
	
	var refresh = function(){
        CoviMenu_GetContent(location.href.replace(location.origin, ""),false);		
	}

	 // event handling
    document.querySelector('input.BtnRefresh').addEventListener('click', refresh);
	 
    document.querySelector('input.BtnAdd').addEventListener('click', function(){ 
    	Common.open("","commonFieldManage",
    			"<spring:message code='Cache.lbl_addCommonFields'/>", /* 공통필드 추가 */
    			"/approval/admin/aggregation/form/commonFieldManage.do??mode=a&entCode=" + companys.value,
				"520px","350px","iframe",true,null,null,true);
    });
</script>