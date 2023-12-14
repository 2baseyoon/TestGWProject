<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.CN_257"/></span><!-- 검색어 관리 -->
</h3>
<div style="width:100%;min-height: 500px">
	<div id="topitembar01" class="topbar_grid">
		<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
		<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addSearchWord();"/>
		<input type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="deleteSearchWord();"/>
		<label style="float: right;">
			<spring:message code="Cache.msg_searchWord_pointRule"/>
	       <!-- * 포인트는 15일 내에 동일한 검색어가 검색 되었을 경우, 1씩 증가합니다. --> 
	    </label>
	</div>
	<div id="topitembar02" class="topbar_grid">
		<spring:message code="Cache.lbl_Domain"/>&nbsp;
		<select id="domainSelectBox" class="AXSelect" style="width:100px;"></select>
		<spring:message code="Cache.lbl_SearchCondition"/>&nbsp;
		<select id="selectSearch" name="selectSearch" class="AXSelect" style="width:100px;">
			<option selected="selected"  value="BizSection"><spring:message code='Cache.lbl_System' /></option> <!-- 시스템 -->
			<option value="SearchWord"><spring:message code='Cache.lbl_SearchWord' /></option> <!-- 검색어 -->
		</select>
		<input type="text" id="searchInput"  class="AXInput" onkeypress="if (event.keyCode==13){ searchSearchWord(); return false;}" />&nbsp;
		<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchSearchWord();" class="AXButton"/>
	</div>
	<div id="searchWordGrid"></div>
</div>
<script type="text/javascript">

var wordGrid = new coviGrid();

InitContent();

function InitContent(){
	var l_AssignedDomain = "¶"+Common.getSession("AssignedDomain")
	
	// 그룹사 시스템 관리자라면 전체를 표시하기 위해
	if(l_AssignedDomain.indexOf("¶0¶") > -1){
		coviCtrl.renderDomainAXSelect('domainSelectBox', Common.getSession("lang"), 'setGrid', '', '', true);
	} else {
		coviCtrl.renderDomainAXSelect('domainSelectBox', Common.getSession("lang"), 'setGrid', '', Common.getSession("DN_ID"), false);
	}
	
	$("#selectSearch").bindSelect();
	
	setGrid();
}

function setGrid(){
	// 헤더 설정
	var headerData =[
					  {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
	                  {key:"DomainName",  label:"<spring:message code='Cache.lbl_Domain'/>", width:"100", align:"center"},
	                  {key:"System",  label:"<spring:message code='Cache.lbl_System'/>", width:"100", align:"center"},
	                  {key:"SearchWord", label:"<spring:message code='Cache.lbl_SearchWord'/>", width:"100", align:"center"},
	                  {key:"SearchCnt",  label:"<spring:message code='Cache.lbl_SearchNum'/>", width:"70", align:"center"},
	                  {key:"RecentlyPoint", label:"<spring:message code='Cache.lbl_PointTitle'/>", width:"70", align:"center"},
	                  {key:"CreateDate",  label:"<spring:message code='Cache.lbl_FirstSearch'/>" + Common.getSession("UR_TimeZoneDisplay"), width:"100", align:"center",
						formatter: function(){
							return CFN_TransLocalTime(this.item.CreateDate, "yyyy-MM-dd");
		                }
					  },
	                  {key:"SearchDate",  label:"<spring:message code='Cache.lbl_FinalSearch'/>" + Common.getSession("UR_TimeZoneDisplay"), width:"100", align:"center", sort:"desc",
					  	formatter: function(){
							return CFN_TransLocalTime(this.item.SearchDate, "yyyy-MM-dd");
		                }
					  }
		      		];
	
	wordGrid.setGridHeader(headerData);
	setGridConfig();
	searchSearchWord();		
}

//그리드 Config 설정
function setGridConfig(){
	var configObj = {
		targetID : "searchWordGrid",
		height:"auto",
		body:{
			onclick: function(){
				if(!(Object.toJSON(this.c).replaceAll("\"", "")=='9')){
					updateSearchWord(Object.toJSON(this.item.SearchWordID).replaceAll("\"", ""));
				}
			}
		}
	};
	
	wordGrid.setGridConfig(configObj);
}

function searchSearchWord(){
	var domainID = $("#domainSelectBox").val();
	var searchType = $("#selectSearch").val();
	var searchWord = $("#searchInput").val();
	
	wordGrid.page.pageNo = 1;
	
	wordGrid.bindGrid({
		ajaxUrl:"/covicore/searchWord/getList.do",
		ajaxPars: {
			"domainID":domainID,
			"searchType":searchType,
			"searchWord":searchWord
		},
		objectName: 'wordGrid',
		callbackName: 'searchSearchWord'
	});
}

function Refresh(){
	searchSearchWord();
}

function addSearchWord(){
	parent.Common.open("","addSearchWord","<spring:message code='Cache.lbl_SearchWordAdd'/>","/covicore/searchWord/goAddLayerPopup.do?mode=add","600px","250px","iframe",true,null,null,true);		// 검색어 추가
}

function updateSearchWord(SearchWordID){
	parent.Common.open("","updateSearchWord","<spring:message code='Cache.lbl_SearchWordModify'/>","/covicore/searchWord/goAddLayerPopup.do?mode=modify&searchWordID="+SearchWordID,"600px","250px","iframe",true,null,null,true);		// 검색어 수정
}

function deleteSearchWord(){
	var deleteobj = wordGrid.getCheckedList(0);
	if(deleteobj.length == 0){
		Common.Warning("<spring:message code='Cache.msg_CheckDeleteObject'/>");
		return;
	}else{
		var deleteSeq = "";
		for(var i=0; i<deleteobj.length; i++){
			if(i==0){
				deleteSeq = deleteobj[i].SearchWordID;
			}else{
				deleteSeq = deleteSeq + "|" + deleteobj[i].SearchWordID;
			}
		}
		$.ajax({
			type:"POST",
			data:{
				"DeleteData" : deleteSeq
			},
			url:"/covicore/searchWord/deleteData.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_DeleteResult'/>");
					searchSearchWord();
				}
			},
			error:function(response, status, error){
	    	     CFN_ErrorAjax("/covicore/searchWord/deleteData.do", response, status, error);
	    	}
		});
	}
}
</script>