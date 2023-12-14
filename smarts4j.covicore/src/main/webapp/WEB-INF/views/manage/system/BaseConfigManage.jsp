<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code="Cache.tte_BaseConfigManage"/></h2>	
	<div class="searchBox02">
	    <span><input type="text" id="searchText"><button type="button" class="btnSearchType01"  id="btnSearch"><spring:message code='Cache.btn_search' /></button></span> <!-- 검색 -->
	</div>
</div>	

<form id="form1">
	<div class='cRContBottom mScrollVH'>
		<div class="sadminContent">
			<div class="sadminMTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					<a class="btnTypeDefault"  id="btnExcel"><spring:message code="Cache.btn_ExcelDownload"/></a>
				</div>
				<div class="buttonStyleBoxRight">
					<select id="selectPageSize" class="selectType02 listCount">
						<option value="10">10</option>
						<option value="15">15</option>
						<option value="20">20</option>
						<option value="30">30</option>
						<option value="50">50</option>
					</select>
					<button class="btnRefresh" type="button" href="#"  id="btnRefresh"></button>
				</div>
			</div>	
			<div class="tblList tblCont">
				<div id="baseconfiggrid"></div>
			</div>	
		</div>
</form>
<script type="text/javascript">
var confConfig = {
	baseConfigGrid:new coviGrid(),
	headerData:[{key:'BizSectionName',  label:'<spring:message code="Cache.lbl_BizSection"/>', width:'70', align:'center'},
	             {key:'SettingKey', label:'<spring:message code="Cache.lbl_SettingKey"/>', width:'100', align:'left'},
        		 {key:'SettingValue',  label:'<spring:message code="Cache.lbl_SettingValue"/>', width:'90', align:'left'},
        		 {key:'ConfigType',  label:'<spring:message code="Cache.lbl_ConfigType"/>', display:false},
        		 {key:'ConfigName',  label:'<spring:message code="Cache.lbl_ConfigName"/>', width:'90', align:'left'},
	             {key:'Description', label:'<spring:message code="Cache.lbl_Description"/>', sort:false, width:'100', align:'left'},
			     {key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>',  width:'50', align:'center'},
	             {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', sort:"desc", 
      				formatter: function(){
      					return CFN_TransLocalTime(this.item.ModifyDate);
  					}, dataType:'DateTime'
 				 }
		      	],
    initLoad:function(){ 
		confConfig.setGrid();			// 그리드 세팅
		//검색
		$("#searchText").on( 'keydown',function(){
			if(event.keyCode=="13"){
				confConfig.searchConfig();

			}
		});	
		$("#btnSearch").on( 'click',function(){
			confConfig.searchConfig();
		});
		
		$("#btnExcel").on("click",function(){
			confConfig.excelDownload();
		});
		
		$("#btnRefresh").on("click",function(){
			confConfig.searchConfig();
		});
		$('#selectPageSize').on('change', function(e) {
			confConfig.baseConfigGrid.page.pageSize = $(this).val();
			confConfig.searchConfig();
		});
		confConfig.searchConfig();
	},
	setGrid:function(){
		this.baseConfigGrid.setGridHeader(this.headerData);
		this.baseConfigGrid.setGridConfig({
			targetID : "baseconfiggrid",
			height:"auto"
		});
	},
	searchConfig:function(){
		var domain = confMenu.domainId ;
		this.baseConfigGrid.page.pageNo = 1;
		this.baseConfigGrid.bindGrid({
 			ajaxUrl:"/covicore/manage/baseConfig/getList.do",
 			ajaxPars: {
 				"domain":domain,
 				"configTypeArray":"InitSetRequired,Mutable",
 				"selectsearch":"All",
 				"searchtext":$("#searchText").val(),
 			}
		});
	},
	excelDownload:function(){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
       			location.href = "/covicore/manage/baseConfig/excelDown.do?domain="+confMenu.domainId+"&configTypeArray=InitSetRequired,Mutable&selectsearch=All&searchtext="+$("#searchText").val()+"&"+confConfig.baseConfigGrid.getSortParam();
       		}
		});
	}
}
window.onload = confConfig.initLoad();
</script>