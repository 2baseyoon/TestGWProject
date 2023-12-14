<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<form id="form1">
	<div class="sadmin_pop sadminContent" style="margin:0px;">
		<div class="tblList tblCont" style="margin:0px;">
			<div id="formsGrid">
			</div>
		</div>
	</div>
</form>
<script>
	var AggregationForm = function(){
	    var formsGrid = new coviGrid();
	    formsGrid.config.fitToWidthRightMargin = 0;
	    var entCode;
	    
	    var headerData = [
	        { key: 'FormName', label: '<spring:message code="Cache.lbl_apv_formcreate_LCODE03"/>', width: '1', align: 'center', formatter: function(){
	        	return CFN_GetDicInfo(this.item.FormName)
	        }},
	        { key: 'FormPrefix', label: '<spring:message code="Cache.lbl_apv_formcreate_LCODE02"/>', width: '1', align: 'center' },
	    ];

	    var configObj = {
	        targetID: "formsGrid",
	        height: "auto",
	        paging: false,
			body: {
				onclick: function(){
					var message = "<spring:message code='Cache.msg_confirmSetForm'/>"; // "양식[{0}]을 설정하시겠습니까?";
					var formData = this.item;
					parent.Common.Confirm(String.format(message, CFN_GetDicInfo(formData.FormName)), "", function(result){
						if(result){
							var commonFieldManage = parent.document.querySelector("#commonFieldManage_if");
							if(commonFieldManage){
								commonFieldManage.contentWindow.aggregationForm.bindFormData(CFN_GetQueryString("key"), formData);
								Common.Close();
							}
						}
					});
				}
			}
	    };
	    
	    formsGrid.setGridHeader(headerData);
	    formsGrid.setGridConfig(configObj);
	    
	    var init = function(){
	    	entCode = CFN_GetQueryString("entCode");
	    	
	    	if(entCode === "undefined"){
	    		parent.Common.Error("<spring:message code='Cache.msg_NoCompanySelected'/>"); /* 회사가 선택되지 않았습니다. 회사 선택 후 다시 시도해주세요. */
	    		return;
	    	}
	    	
	    	getFormsData(entCode);
	    };

	    var getFormsData = function(){
	    	formsGrid.page.pageNo = 1;
	    	formsGrid.bindGrid({
				ajaxUrl:"/approval/manage/aggregation/forms-using-subtable.do",
				ajaxPars: {
					"entCode":entCode
				},
				onLoad : function(){
					if(!formsGrid.isLoadByRedraw) {
						formsGrid.isLoadByRedraw = true;
						formsGrid.redrawGrid();
					}else{
						formsGrid.isLoadByRedraw = false;
					}
				}
			});
	    	formsGrid.windowResize();
	    }
	    
	    init();
	};
	
	new AggregationForm();

</script>