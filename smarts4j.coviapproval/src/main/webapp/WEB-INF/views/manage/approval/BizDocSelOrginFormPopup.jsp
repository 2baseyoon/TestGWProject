<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="sadmin_pop">
	<div class="selectCalView mb10">
		<select class="selectType02 w150p" name="sel_Search" id="sel_Search" >
			<option selected="selected" value="FormName"><spring:message code="Cache.lbl_apv_formcreate_LCODE03"/></option>
			<option value="FormPrefix"><spring:message code="Cache.lbl_apv_formcreate_LCODE02"/></option>									
		</select>
		<div class="dateSel type02">
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" class="w200p">
		</div>
		<a onclick="searchConfig();" class="btnTypeDefault"><spring:message code="Cache.btn_search"/></a>
	</div>	
	<div class="sadminMTopCont">
		<div class="buttonStyleBoxRight">
        	<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
        </div>
	</div>	
	<div id="BizDocFormAddGrid" class="tblList tblCont"></div>
	<div class="bottomBtnWrap">
		<a onclick="saveSubmit(); return false;" class="btnTypeDefault btnTypeBg" ><spring:message code='Cache.btn_apv_save'/></a>
		<a onclick="Common.Close(); return false;"  class="btnTypeDefault" ><spring:message code='Cache.btn_apv_close'/></a>
	</div>
</div>

<script  type="text/javascript">
	var paramBizDocID ="${key}";
	var paramBizEntCode = "${entCode}";
	
	var bizDocFormAddGrid = new coviGrid();
	bizDocFormAddGrid.config.fitToWidthRightMargin = 0;
	
	//ready  - 그리드 세팅
	setGrid();			
	
	//그리드 세팅
	function setGrid(){
		bizDocFormAddGrid.setGridHeader([
					{key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox', hideFilter : 'Y'},
     	            {key:'FormName',  label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE03"/>', width:'180', align:'left',
     	                formatter:function () {
				   			return CFN_GetDicInfo(this.item.FormName);
						}
     	            },	                
     	            {key:'FormPrefix',  label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE02"/>', width:'150', align:'left'},	                  
     	            {key:'FormClassName', label:'<spring:message code="Cache.lbl_FormCate"/>', width:'80', align:'center', sort:"asc", 
     	            	formatter : function (){
     	            		return CFN_GetDicInfo(this.item.FormClassName);	
     	            	}
     	            }
     		]);
		
		setGridConfig();
		searchConfig();
	}
	
	// 그리드 설정
	function setGridConfig(){
		var configObj = {
			targetID : "BizDocFormAddGrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:8
			}
		};
		
		bizDocFormAddGrid.setGridConfig(configObj);
	}
	
	// 검색
	function searchConfig(){
		bizDocFormAddGrid.page.pageNo = 1;
		bizDocFormAddGrid.bindGrid({
				ajaxUrl:"/approval/manage/getBizDocSelOrginFormList.do",
				ajaxPars: {
					"bizDocID" : paramBizDocID,
					"bizEntCode" : paramBizEntCode,
					"SearchType": $("#sel_Search").val(),
					"SearchWord": $("#search").val()
				}
		});
	}	

	// 새로고침
	function Refresh(){
		$("#search").val("");
		$("#sel_Search").val($("#sel_Search").find("option").eq(0).val());
		searchConfig();
	}
		
	//저장
	function saveSubmit(){
		var formArray = bizDocFormAddGrid.getCheckedList(0);
		if(formArray.length == 0){
			Common.Warning("<spring:message code='Cache.msg_apv_003'/>");// 선택된 항목이 없습니다.
			return false;
		}
		
		Common.Confirm("<spring:message code='Cache.msg_RUAdd' />", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				save();
			}else{
				return;
			}
		});
	}
	
	function save(){
		var BizDocFormArray = bizDocFormAddGrid.getCheckedList(0);
		
		//insert 호출
		$.ajax({
			type:"POST",
			data:{				
				"BizDocID" : paramBizDocID,
				"BizDocForm" : JSON.stringify(BizDocFormArray)
			},
			url:"insertBizDocForm.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
// 					parent.Common.Inform("<spring:message code='Cache.msg_apv_137'/>", "", function() {
					coviCmn.getParentFrameObj("updateBizForm").searchConfig();
					Common.Close();
// 					});
				}else{
					parent.Common.Warning(data.message);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("insertBizDocForm.do", response, status, error);
			}
		});
	}

	
</script>
