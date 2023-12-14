<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_approval_manageBizDoc"/></span>	 <!-- 업무문서함 관리 -->
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh(); return false;"/> <!-- 새로고침 -->
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addConfig(); return false;"/>	<!-- 추가 -->
		</div>	
		<div id="topitembar02" class="topbar_grid">
			<label for="selectUseAuthority" ><spring:message code="Cache.lbl_Domain"/> : </label>
			<select id="selectUseAuthority" name="selectUseAuthority" class="AXSelect">
			</select>
			<label for="BizDocType" ><spring:message code="Cache.lbl_BizSection" /> : </label> 
			<select id="BizDocType" name="BizDocType" class="AXSelect">
			</select>						
			<select class="AXSelect"  name="sel_Search" id="sel_Search" >
				<option selected="selected" value="BizDocName"><spring:message code="Cache.lbl_apv_BizDocName"/></option> <!-- 업무함 명칭 -->
				<option value="BizDocCode"><spring:message code="Cache.lbl_apv_BizDocCode"/></option>	<!-- 업무함 코드 -->	
			</select>
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" class="AXInput" />
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(); return false;" class="AXButton"/> <!-- 검색 -->
		</div>	
		<div id="bizDocGrid"></div>
	</div>
</form>

<script type="text/javascript">
	var bizDocGrid = new coviGrid();

	//ready 
	initBizDocList();
	
	function initBizDocList(){
		$("#selectUseAuthority").coviCtrl("setSelectOption", "/approval/common/getEntInfoListData.do", {"type" : "ID"});
		coviCtrl.renderAXSelect('JobFunctionType', 'BizDocType', 'ko', '', '', 'ORGROOT');
		$("#selectUseAuthority,#BizDocType").bindSelect({
			onchange: function(){
				searchConfig();
			}
		});
		selSelectbind();
		setGrid();
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[	            
						  {key:'EntName', label:'<spring:message code="Cache.lbl_Domain"/>', width:'100', align:'center'},
						  {key:'IsUse', label:'<spring:message code="Cache.lbl_apv_IsUse"/>', width:'55', align:'center'
		                	  , formatter:function(){
		                		  var IsUse;
		                		  if(this.item.IsUse=='Y'){
		                			  IsUse='<spring:message code="Cache.lbl_Use"/>';  //사용
		                		  }else if(this.item.IsUse=='N'){
		                			  IsUse='<spring:message code="Cache.lbl_UseN"/>'; //미사용
		                		  }
		                		return IsUse;  
		                	  }
		                  },
		                  {key:'BizDocName',  label:'<spring:message code="Cache.lbl_apv_BizDocName"/>', width:'115', align:'center'
		                	  , formatter:function(){
				                  return CFN_GetDicInfo(this.item.BizDocName);
			                	}
			              },	                  
		                  {key:'BizDocCode',  label:'<spring:message code="Cache.lbl_apv_BizDocCode"/>', width:'100', align:'center'},
		                  {key:'Description', label:'<spring:message code="Cache.lbl_apv_desc"/>', width:'100', align:'left'},
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE03"/>', width:'200', align:'left'},
		                  {key:'BizDocTypeName',  label:'<spring:message code="Cache.lbl_BizSection"/>', width:'80', align:'center'},
		                  {key:'UR_Name', label:'<spring:message code="Cache.lbl_apv_AdminName"/>', width:'200', align:'left'},	
		                  {key:'SortKey', label:'<spring:message code="Cache.lbl_apv_Sort"/>', width:'50', align:'center', sort:"asc"},
		                  {key:'InsertDate',  label:'<spring:message code="Cache.lbl_apv_formcreate_LCODE15"/>', width:'100', align:'center'
		                	  , formatter:function(){return CFN_TransLocalTime(this.item.InsertDate, "yyyy-MM-dd HH:mm:ss")}},
		                  {key:'', label:'<spring:message code="Cache.btn_apv_update"/>', width:'100', align:'center', sort: false,
		                	  formatter:function () {
		                		  return "<input class='ooBtn' type='button' value='<spring:message code='Cache.btn_apv_update'/>'  onclick='updateConfig( \""+ this.item.BizDocID +"\"); return false;'>";
			      				}}
		                  
			      		];
		
		bizDocGrid.setGridHeader(headerData);
		setGridConfig();
		searchConfig();				
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "bizDocGrid",
			height:"auto",
			body:{
				onclick: function(){
						if(this.c=='5'){							
							goBizDocForm(this.item.BizDocID,CFN_GetDicInfo(this.item.BizDocName),this.item.EntCode);
						}else if(this.c=='7'){							
							goBizDocMember(this.item.BizDocID,CFN_GetDicInfo(this.item.BizDocName),this.item.EntCode);
						}
				    }				
			}
		};
		bizDocGrid.setGridConfig(configObj);
	}
	

	
	// 검색
	function searchConfig(){		
		var sel_State = $("#sel_State").val();	
		var sel_Search = $("#sel_Search").val();
		var search = $("#search").val();
		var sel_Date = $("#sel_Date").val();
		var bizDocType = $("#BizDocType").val();
		var entCode = $("#selectUseAuthority").val();
		//var startdate = $("#startdate").val();
		//var enddate = $("#enddate").val();
		bizDocGrid.page.pageNo = 1;
		bizDocGrid.bindGrid({
				ajaxUrl:"/approval/admin/getBizDocList.do",
				ajaxPars: {
					"sel_State":sel_State,
					"sel_Search":sel_Search,
					"search":search,
					"sel_Date":sel_Date,
					"startDate":"",
					"endDate":"",
					"bizDocType":bizDocType,
					"entCode":entCode
				}
		});
	}	

	//담당 양식목록 팝업 
	function goBizDocForm(bizDocID, bizDocName, entCode){		
		Common.open("","updateBizForm","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||"+bizDocName,"/approval/admin/goBizDocForm.do?mode=modify&key="+bizDocID+"&entCode="+entCode,"750px","550px","iframe",true,null,null,true);
	}
	
	//담당자 목록 팝업 
	function goBizDocMember(bizDocID, bizDocName, entCode){		
		Common.open("","updateDocMember","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||"+bizDocName,"/approval/admin/goBizDocMember.do?mode=modify&key="+bizDocID+"&entCode="+entCode,"1000px","700px","iframe",true,null,null,true);
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateConfig(bizDocID){
		Common.open("","updateBizDocConfig","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||<spring:message code='Cache.lbl_apv_bdform_title_instruction'/>","/approval/admin/goBizDocListSetPopup.do?mode=modify&key="+bizDocID,"550px","390px","iframe",true,null,null,true);
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addConfig(){		 
		parent.Common.open("","addBizDoc","<spring:message code='Cache.lbl_apv_BizDocManage'/>|||<spring:message code='Cache.lbl_apv_bdform_title_instruction'/>","/approval/admin/goBizDocListSetPopup.do?mode=add","550px","390px","iframe",true,null,null,true);
	}

	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
	
	//axisj selectbox변환
	function selSelectbind(){
		//검색selectbind
		$("#sel_Search").bindSelect({
        	onChange: function(){
        		//toast.push(Object.toJSON(this));
        	}
        });
	}
</script>