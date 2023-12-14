<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	.selected .cell-modify{
		background-image: url('/approval/resources/images/Approval/ico_research_join.gif');
		background-repeat:no-repeat;
		background-position:right 10px center;
	}
</style>

<div class="cRConTop titType AtnTop">
	<h2 class="title">
		<span><spring:message code="Cache.lbl_apv_AggregationManage"/></span> <!-- 집계함 관리 -->
	</h2>
</div>

<div class="cRContBottom mScrollVH">
	<div class="sadminContent">
		<!-- 상단버튼 영역 -->
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a id="btnFormAdd" class="btnTypeDefault btnPlusAdd" href="#"><spring:message code='Cache.btn_Add'/></a> <!-- 추가 -->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option>10</option>
					<option>20</option>
					<option>30</option>
				</select>
				<button id="btnRefresh" class="btnRefresh" type="button"></button> <!-- 새로고침 -->
			</div>
		</div>
		<div id="GridView" class="tblList"></div>
	</div>
	<input type="hidden" id="hidden_domain_val" value=""/>
</div>
<script>
var lang = 'ko';

var AggregationManage = function() {
    var formGrid;
    var formContainer = document.getElementById("formContainer");
    var formData;
    var eventedId;
    var companys = document.querySelector("#hidden_domain_val");

    var init = function(){
        formGrid = new coviGrid();
        
        formGrid.config.fitToWidthRightMargin = 0;
        initGrid();

        // 회사코드 셋팅
		if(confMenu.domainCode == undefined || confMenu.domainCode == "") $("#hidden_domain_val").val(Common.getSession("DN_Code"));
		else $("#hidden_domain_val").val(confMenu.domainCode);
        
        searchConfig(companys.value);
        document.querySelector("#btnFormAdd").addEventListener("click", addForm);
    };
    
    var drawFormContent = function(){
        formContainer.style.visibility = "visible";
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
		                		  return "<a class='btnTypeDefault'><spring:message code='Cache.lbl_Empowerment'/></a>"; // 권한부여
		                	  }
			      		  },
		                  {key:'aggFieldSetting', label:'<spring:message code="Cache.lbl_ComField"/>', width:'90', align:'center', sort:false , // 필드
		                	  formatter:function () {
		                		  return "<a class='btnTypeDefault'><spring:message code='Cache.lbl_ComFieldMapping'/></a>"; // 필드매핑
		                	  }
			      		  }
		];
		formGrid.setGridHeader(headerData);
		setGridConfig();
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
		formGrid.page.pageSize = $("#selectPageSize").val();
		formGrid.bindGrid({
 			ajaxUrl:"/approval/manage/aggregation/forms.do",
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
                    drawFormContent(data.info);
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
                "/approval/manage/aggregation/form/manage.do?entCode=" + companys.value,
                "450px","180px","iframe",true,null,null,true);
    };
    
    this.selectedForm;
    var modifyForm = function(item){
    	aggregationManage.selectedForm = item;
    	Common.open("","commonFieldManage",
                "<spring:message code='Cache.lbl_modifyAggregationForm'/>", /* 집계함 양식 수정 */
                "/approval/manage/aggregation/form/manage.do?entCode=" + companys.value
                		+ "&formId=" + item.aggFormId,
                "450px","180px","iframe",true,null,null,true);
    };
    
    /**
    * 집계함 권한대상 설정팝업
    */
    var goAuthSettingPop = function(aggFormId, entCode){	
    	var url = "/approval/common_popup/manage_approval_AggregationAuthManage.do"; //WEB-INF/veiws/manage/approval/AggregationAuthManage.jsp
		Common.open("","updateAggAuthMember","<spring:message code='Cache.lbl_Empowerment'/>", url + "?key="+aggFormId+"&entCode="+entCode,"700px","700px","iframe",true,null,null,true);
	};
	
    var goFieldSettingPop = function(aggFormId, entCode){	
    	var url = "/approval/common_popup/manage_approval_AggregationFieldManage.do"; //WEB-INF/veiws/manage/approval/AggregationAuthManage.jsp
		Common.open("","updateAggAuthMember","<spring:message code='Cache.lbl_ComFieldMapping'/>", url + "?id="+aggFormId+"&entCode="+entCode,"1110px","800px","iframe",true,null,null,true);
	}; 
    init();
}

var aggregationManage = new AggregationManage();

</script>