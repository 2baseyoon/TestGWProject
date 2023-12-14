<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_apv_CommonFieldManage"/></span> <!-- 공통필드 관리 -->
	</h2>
</div>

<div class="cRContBottom mScrollVH">
	<!-- 컨텐츠 시작 -->
	<!-- <select name="Companys" class="AXSelect" id="Companys"></select> -->
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a id="btnFieldAdd" class="btnTypeDefault btnPlusAdd" href="#"><spring:message code="Cache.btn_Add"/></a>
				<a style="visibility:hidden;"></a>
			</div>
			<div class="buttonStyleBoxRight">
				<button class="btnRefresh" type="button" href="#" onclick="refresh();"></button>
			</div>
		</div>
		<div class="tblList tblCont">
			<div id="commonFieldGrid"></div>
		</div>
		<!-- <input type="hidden" id="hidden_domain_val" value=""/>  -->
	</div>
</div>

<script>
    // grid
    //var companys = document.querySelector("#Companys");
    var ListGrid = new coviGrid();
    ListGrid.config.fitToWidthRightMargin = 0;
    
    setControl();
    
    // 초기 셋팅
	function setControl(){
    	setGrid(); // 그리트셋팅
    	setList(); // 그리드조회
    	
    	// event handling
	    //document.querySelector('input.BtnRefresh').addEventListener('click', refresh);
		 
	    document.querySelector('#btnFieldAdd').addEventListener('click', function(){ 
	    	Common.open("","commonFieldManage",
	    			"<spring:message code='Cache.lbl_addCommonFields'/>", /* 공통필드 추가 */
	    			"/approval/manage/aggregation/form/commonFieldManage.do??mode=a&entCode=" + confMenu.domainCode,
					"520px","380px","iframe",true,null,null,true);
	    });
	    
	    /*
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
		*/
    }
    
    
    function setGrid(){
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
			    			"/approval/manage/aggregation/form/commonFieldManage.do?mode=m&key="+this.item.aggFieldId,
							"520px","380px","iframe",true,null,null,true);
				}
			}
	    };
	    
	    ListGrid.setGridHeader(headerData);
	    ListGrid.setGridConfig(configObj);
    }
    
    
    function setList(){
		ListGrid.page.pageNo = 1;
		ListGrid.bindGrid({
			ajaxUrl:"/approval/manage/aggregation/form/commonfields.do",
			ajaxPars: {
				"entCode":confMenu.domainCode
			},
			onLoad : function(){
				
			}
		});
    }
    
    
	function refresh(){
        CoviMenu_GetContent(location.href.replace(location.origin, ""),false);		
	}

	
</script>