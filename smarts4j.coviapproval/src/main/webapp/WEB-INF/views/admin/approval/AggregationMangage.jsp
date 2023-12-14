<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<style>
	.selected .cell-modify{
		background-image: url('/approval/resources/images/Approval/ico_research_join.gif');
		background-repeat:no-repeat;
		background-position:right 10px center;
	}
</style>
<h3 class="con_tit_box">
	<span class="con_tit">집계함 관리</span>	
</h3>
<div style="width:100%;min-height: 500px">
	<div id="topitembar02" class="topbar_grid">
		<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="aggregationManage.refreshGrid();"/>
		<input id="btnFormAdd" type="button" class="AXButton BtnAdd" value="<spring:message code="Cache.btn_Add"/>" onclick="Refresh();"/><!-- 추가 -->
		<select name="Companys" class="AXSelect" id="Companys"></select>
	</div>
	<div id="GridView"></div>
</div>
<script>
var lang = 'ko';

var AggregationManage = function() {
    var formGrid;
    var formContainer = document.getElementById("formContainer");
    var formData;
    var eventedId;
    var companys = document.querySelector("#Companys");

    var init = function(){
        formGrid = new coviGrid();

        $("#Companys").bindSelect({
            reserveKeys: {
                options: "list",
                optionValue: "optionValue",
                optionText: "optionText"
            },
            ajaxUrl: "/approval/common/getEntInfoListAssignData.do",			
            ajaxAsync:false,
            onchange: function(){
            	aggregationManage.refreshGrid();
            },
            onLoad: function(){
            	initGrid();
            }
        });

        document.querySelector("#btnFormAdd").addEventListener("click", addForm);
    };
    
    var drawFormContent = function(){
    };

    /* formTree */
    var initGrid = function(){
		// 헤더 설정
		var headerData =[		
				  		  {key:'aggFormId', label:'ID', width:'50', align:'center'}, // ID
						  {key:'CompanyName', label:'<spring:message code="Cache.lbl_Domain"/>', width:'100', align:'center', // 도메인
							  formatter:function(){
				                  return CFN_GetDicInfo(this.item.CompanyName);
				          }}, 
		                  {key:'formName', label:'<spring:message code="Cache.lbl_apv_formname"/>', width:'250', align:'left', // 양식명
				        	  formatter:function(){
				        		  return "<a class='txt_underline'>"+CFN_GetDicInfo(this.item.formName) + "</a>";
				          }}, 
			              {key:'formPrefix', label:'<spring:message code="Cache.lbl_FormID"/>', width:'140', align:'left', sort:false}, // 양식키 
			              {key:'displayYN', label:'<spring:message code="Cache.lbl_isDisplayInAggBox"/>', width:'80', align:'center' // 집계함표시여부
		                	  , formatter:function(){
		                		  if(this.item.displayYN=='N') return '<spring:message code="Cache.lbl_notExposure"/>'; // 미노출
		                		  else return '<spring:message code="Cache.lbl_exposure"/>'; // 노출
		                	  }
		                  },
		                  {key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>', width:'100', align:'center', // 등록자
		                	  formatter:function(){
				                  return CFN_GetDicInfo(this.item.RegisterName);
				          }},
		                  {key:'aggAuthSetting', label:'<spring:message code="Cache.lbl_Empowerment"/>', width:'90', align:'center', sort:false ,
		                	  formatter:function () {
		                		  return "<input type='button' class='smButton' value='<spring:message code='Cache.lbl_Empowerment'/>'/>"; // 권한부여
		                	  }
			      		  },
		                  {key:'aggFieldSetting', label:'<spring:message code="Cache.lbl_ComField"/>', width:'90', align:'center', sort:false , // 필드
		                	  formatter:function () {
		                		  return "<input type='button' class='smButton' value='<spring:message code='Cache.lbl_ComFieldMapping'/>'/>"; // 필드매핑
		                	  }
			      		  }
		];
		formGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig(companys.value);
    };

	// 그리드 Config 설정
	var setGridConfig = function(){
		var configObj = {
			targetID : "GridView",
			height:"auto",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",			
			page : {
				pageNo: 1,
				pageSize: 10
			},	
			paging : true,
			//notFixedWidth:3,
			colHead:{},
			body:{
				 onclick: function(){				    
				    	var itemName = formGrid.config.colGroup[this.c].key;
				    	if(itemName == 'formName'){
				    		modifyForm(this.item);
				    	}else if(itemName == 'aggFieldSetting'){
				    		goFieldSettingPop(this.item.aggFormId, this.item.entCode);
				    	}else if(itemName == 'aggAuthSetting'){
				    		goAuthSettingPop(this.item.aggFormId, this.item.entCode);
				    	}
					 }
			}
		};
		
		formGrid.setGridConfig(configObj);
	};
	
	var 	searchConfig = function (companyCode){
		//searchText
		var isDetail = $('#DetailSearch').hasClass('active') ? true : false;
		formGrid.page.pageNo = 1;
		formGrid.bindGrid({
 			ajaxUrl:"/approval/admin/aggregation/forms.do",
 			ajaxPars: {
 				"entCode":companyCode
 			},
 			onLoad:function(){
 			}
		});
	};
    
    this.refreshGrid = function(){
        searchConfig(companys.value);
    };
    
    /* form */
    this.getFormData = function(aggFormId){
    	if(aggFormId == undefined) aggFormId = formData.aggFormId;
        $.ajax({
            type:"GET",
            url:"/approval/admin/aggregation/form/" + aggFormId + ".do",
            success:function (data) {
                if(data.status === "SUCCESS"){
                    formData = data.info;
                } else {
                    Common.Error(data.message);
                }
            },
            error:function(response){
                if(response.status === 400 && response.responseJSON){
                    Common.Error(response.responseJSON.message);
                } else {
                    CFN_ErrorAjax("/approval/admin/aggregation/forms.do", response, response.status, response.statusText);
                }
            }
        });
    };
    
    var addForm = function(){
        Common.open("","commonFieldManage",
                "<spring:message code='Cache.lbl_addAggregationForm'/>", /* 집계함 양식 추가 */
                "/approval/admin/aggregation/form/manage.do?entCode=" + companys.value,
                "450px","180px","iframe",true,null,null,true);
    };
    
    this.selectedForm;
    var modifyForm = function(item){
    	aggregationManage.selectedForm = item;
    	Common.open("","commonFieldManage",
                "<spring:message code='Cache.lbl_modifyAggregationForm'/>", /* 집계함 양식 수정 */
                "/approval/admin/aggregation/form/manage.do?entCode=" + companys.value
                		+ "&formId=" + item.aggFormId,
                "450px","180px","iframe",true,null,null,true);
    };
    
    /**
    * 집계함 권한대상 설정팝업
    */
    var goAuthSettingPop = function(aggFormId, entCode){	
    	var url = "/approval/common_popup/admin_approval_AggregationAuthManage.do"; 
		Common.open("","updateAggAuthMember","<spring:message code='Cache.lbl_Empowerment'/>", url + "?key="+aggFormId+"&entCode="+entCode,"700px","700px","iframe",true,null,null,true);
	};
	
    var goFieldSettingPop = function(aggFormId, entCode){	
    	var url = "/approval/common_popup/admin_approval_AggregationFieldManage.do"; 
		Common.open("","updateAggAuthMember","<spring:message code='Cache.lbl_ComFieldMapping'/>", url + "?id="+aggFormId+"&entCode="+entCode,"1110px","800px","iframe",true,null,null,true);
	};
	
    init();
}

var aggregationManage = new AggregationManage();

</script>