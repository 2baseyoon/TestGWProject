<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="sadmin_pop sadminContent">
	<div class="selectCalView mb10">
		<label>
			<select class="selectType02 w150p" name="sel_Search" id="sel_Search" >
				<option selected="selected" value="FormName"><spring:message code="Cache.lbl_apv_formcreate_LCODE03"/></option>
				<option value="FormPrefix"><spring:message code="Cache.lbl_apv_formcreate_LCODE02"/></option>									
			</select>
			<div class="dateSel type02">
				<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" class="w200p">
			</div>
			<a onclick="searchConfig();" class="btnTypeDefault"><spring:message code="Cache.btn_search"/></a>
		</label>			
	</div>	
	<div class="sadminMTopCont">
		<div class="pagingType02 buttonStyleBoxLeft">
			<a class="btnTypeDefault btnPlusAdd" onclick="addConfig(false);" ><spring:message code="Cache.btn_Add"/></a>
		</div>
		<div class="buttonStyleBoxRight">
        	<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
        </div>
	</div>	
	<div id="BizDocFormgrid" class="tblList tblCont"></div>
</div>

<script type="text/javascript">
	// 업무문서함 - 양식 목록 조회 화면
	//# sourceURL=BizDocForm.jsp 
	var mode =CFN_GetQueryString("mode");
	var paramBizDocID = CFN_GetQueryString("key");
	var paramEntCode = CFN_GetQueryString("entCode");
	var bizDocFormGrid = new coviGrid();
	bizDocFormGrid.config.fitToWidthRightMargin = 0;
	
	//ready  - 그리드 세팅
	setGrid();			
	
	//그리드 세팅
	function setGrid(){
		bizDocFormGrid.setGridHeader([	
		        	                  {key:'FormName',  label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE03"/>', width:'150', align:'left',
		        	                	  formatter:function () {		
									   			return "<a href='#' class='txt_underline'>"+ CFN_GetDicInfo(this.item.FormName) + "</a>";
										  }
		        	                  },
		        	                  {key:'FormPrefix',  label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE02"/>', width:'150', align:'left'},	                  
		        	                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_SortKey"/>', width:'50', align:'center', sort:"asc"}	                  
		        		      		]);
		setGridConfig();
		searchConfig();
	}
	
	// 그리드 설정
	function setGridConfig(){
		var configObj = {
			targetID : "BizDocFormgrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			body:{
				onclick: function(){				
					updateConfig(this.item.BizDocFormID);
			    }				
			}
		};
		
		bizDocFormGrid.setGridConfig(configObj);
	}
	
	// 검색
	function searchConfig(){
		bizDocFormGrid.page.pageNo = 1;
		bizDocFormGrid.bindGrid({
				ajaxUrl:"/approval/manage/getBizDocFormList.do",
				ajaxPars: {
					"BizDocID":paramBizDocID,
					"SearchType": $("#sel_Search").val(),
					"SearchWord": $("#search").val()
				}
		});
	}	

	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(bizDocFormID){
		parent.Common.open("","updateBizDocFormConfig","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||<spring:message code='Cache.lbl_apv_bdform_title_instruction'/>","/approval/manage/goBizDocFormDetailPopup.do?mode=modify&key="+bizDocFormID,"530px","240px","iframe",true,null,null,true);
	}
	
	// 새로고침
	function Refresh(){
		$("#search").val("");
		$("#sel_Search").val($("#sel_Search").find("option").eq(0).val());
		searchConfig();
	}
	
	// 추가 버튼에 대한 레이어 팝업
	var _selectDataList = new Array();
	
	parent._CallBackMethod1 = searchConfig;
	function addConfig(pModal){
		var selectData = {};
		$$(selectData).append("selectData", bizDocFormGrid.list);
		
		_selectDataList =$$(selectData).find("selectData").concat().attr("FormPrefix");
		
		parent.Common.open("","addBizDocForm","<spring:message code='Cache.lbl_apv_formchoice'/>","/approval/manage/goBizDocSelOrginFormPopup.do?key="+paramBizDocID+"&entCode="+paramEntCode+"&data=_selectDataList","720px","650px","iframe",true,null,null,true);
	}
	
</script>
