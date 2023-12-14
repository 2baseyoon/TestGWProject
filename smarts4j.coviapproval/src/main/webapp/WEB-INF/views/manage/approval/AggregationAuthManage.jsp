<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script type="text/javascript">
	var aggFormId =  ${param.key}
	$(document).ready(function (){
		setGrid();			// 그리드 세팅			
	});	
	// 헤더 설정
	var headerData =[
        { key: 'aggAuthId', label:"checkbox", width: '1', align: 'center', formatter: "checkbox"},
        { key: 'authType', label: '<spring:message code="Cache.lbl_type"/>', width: '5', align: 'center', formatter: function(){
        	var authType;
        	switch(this.item.authType){
        	case "U":
        		authType = Common.getDic("lbl_User");
        		break;
        	case "D":
        		authType = Common.getDic("lbl_dept");
        		break;
        	case "E":
        		authType = Common.getDic("lbl_company");
        		break;
       		default:
       			authType = this.item.authType;
        	}
        	return authType;
        }},
        { key: 'authTarget', label: '<spring:message code="Cache.lbl_aclTarget"/>', width: '5', align: 'center', formatter: function(){
            return this.item.displayTargetName;
        }}
	];
	
	var AggAuthGrid = new coviGrid();
	AggAuthGrid.config.fitToWidthRightMargin = 0;
	
	//그리드 세팅
	function setGrid(){
		AggAuthGrid.setGridHeader(headerData);
		setGridConfig();
		loadGrid();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "AggregationAuthGrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",
			paging : false,
			colHead:{},
			body:{
				onclick: function(){
				}
			}
		};
		
		AggAuthGrid.setGridConfig(configObj);
	}
	
	function loadGrid() {
		AggAuthGrid.setList({
			ajaxUrl:"/approval/manage/aggregation/form/authList.do",
			ajaxPars: {
				"aggFormId":aggFormId
			},
			onLoad:function(){
				if(!AggAuthGrid.isLoadByRedraw) {
					AggAuthGrid.isLoadByRedraw = true;
					AggAuthGrid.redrawGrid(); // y scroll 변경시 fitToWidth 재정렬
				}
			}
		});
	}
	
	function searchConfig(flag){
		AggAuthGrid.isLoadByRedraw = false;
		AggAuthGrid.reloadList();
	}	
	
	// 새로고침
	function Refresh(){
		searchConfig();
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addTarget(pModal){
    	var type = "D9";
		var treeKind = "Dept";
		var allCompany = "N"
		var width = "1060px";
		var height = "585px";
		var orgURL  = String.format("/covicore/control/goOrgChart.do?type={0}&treeKind={1}&allCompany={2}&callBackFunc=_CallBackMethod", type, treeKind, allCompany);
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>",orgURL,"1060px","580px","iframe",true,null,null,true);
	}
	
	parent._CallBackMethod = callBackOrgChartPopup;
    function callBackOrgChartPopup(result){
    	if(typeof result === "string"){
    		result = JSON.parse(result);
    	}
    	
    	var addAuthData = result.item.map(function(x) {
    	    var data = {};
    	    if(x.itemType === "user"){
    	    	data.authType = "U";	
    	    } else {
    	    	if(x.GroupType === "Company"){
    	    		data.authType = "E";
    	    	} else {
    	    		data.authType = "D";
    	    	}
    	    }
    	    data.authTarget = x.AN;
    	    data.entCode = x.ETID;
    	    data.aggFormId = aggFormId;
    	    return data;
    	});

   		$.ajax({
		    type:"POST",
		    data:JSON.stringify(addAuthData),
		    contentType: 'application/json; charset=utf-8',
		    url: "/approval/admin/aggregation/form/auth.do",
		    success:function (data) {
		        if(data.status === "SUCCESS"){
		            Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
		            	// aggregationManage.getFormData(formData.aggFormId);
		            	// refresh grid
		            	searchConfig();
		            });
		        } else {
		            Common.Error(data.message);
		        }
		    },
		    error:function(response){
		        if(response.status === 400 && response.responseJSON){
		            Common.Error(response.responseJSON.message);
		        } else {
		            CFN_ErrorAjax("/approval/admin/aggregation/form.do", response, response.status, response.statusText);
		        }
		    }
		});
    }
    
    function deleteFormAuth(){
        // 체크박스 선택 후
        var deleteRequestDatas = AggAuthGrid.getCheckedList(0).map(x => x.aggAuthId.toString());
        if (deleteRequestDatas.length == 0) {
			Common.Warning("<spring:message code='Cache.lbl_Mail_NoSelectItem' />");
			return;
		}
        Common.Confirm("<spring:message code='Cache.msg_apv_093'/>" , "" , function(result){ // 삭제하시겠습니까?
    		if(result){
	    		$.ajax({
				    type:"DELETE",
				    data:JSON.stringify(deleteRequestDatas),
				    contentType: 'application/json; charset=utf-8',
				    url: "/approval/admin/aggregation/form/auth.do",
				    success:function (data) {
				        if(data.status === "SUCCESS"){
				            Common.Inform("<spring:message code='Cache.msg_37'/>","Information",function(){ /*저장되었습니다.*/
				            	searchConfig();
				            });
				        } else {
				            Common.Error(data.message);
				        }
				    },
				    error:function(response){
				        if(response.status === 400 && response.responseJSON){
				            Common.Error(response.responseJSON.message);
				        } else {
				            CFN_ErrorAjax("/approval/admin/aggregation/form.do", response, response.status, response.statusText);
				        }
				    }
				});
    		}
    	});
    }
</script>
<div class="sadmin_pop sadminContent">
	<div class="selectCalView mb10" style="display:none;">			
		<label>
			<select class="selectType02 w150p"  name="sel_Search" id="sel_Search" >
				<option selected="selected" value="DEPT_NAME"><spring:message code="Cache.lbl_apv_AdminDept"/></option>
				<option value="UR_Name"><spring:message code="Cache.lbl_apv_AdminName"/></option>
				<option value="UR_Code"><spring:message code="Cache.lbl_apv_AdminID"/></option>														
			</select>
			<div class="dateSel type02">
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ cmdSearch(); return false;}" class="w200p" />
			</div>
			<a onclick="searchConfig(1);" class="btnTypeDefault btnSearchBlue nonHover" ><spring:message code="Cache.btn_search"/></a>
		</label>			
	</div>
	<div class="sadminMTopCont">
		<div class="pagingType02 buttonStyleBoxLeft">
			<a class="btnTypeDefault btnPlusAdd" href="#" onclick="addTarget(false);"><spring:message code="Cache.btn_Add" /></a>
			<a class="btnTypeDefault BtnDelete" onclick="deleteFormAuth()"><spring:message code='Cache.btn_Delete'/></a>
		</div>
		<div class="buttonStyleBoxRight">
			<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
		</div>
	</div>
	<div id="AggregationAuthGrid" class="tblList tblCont"></div>
</div>
<!-- 	<input type="hidden" id="hidden_domain_val" value=""/> -->
<!-- 	<input type="hidden" id="hidden_worktype_val" value=""/> -->
