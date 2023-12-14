<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<script type="text/javascript">

 	var lang = Common.getSession("lang");
	var equipmentGrid = new coviGrid();

	$(document).ready(function (){
		setSelectBox();  	// 검색 조건 select box 바인딩
		setGrid();			// 그리드 세팅			
	});
	
	
	// 헤더 설정
	var headerData =[	            
	                  {key:'chk', label:'chk', width:'4', align:'center', formatter: 'checkbox'},
	                  {key:'IconPath',  label:'<spring:message code="Cache.lbl_SmartIcon"/>', width:'6', align:'center',  									/*아이콘*/
	                	  formatter:function(){
	                		  return '<img src="' + this.item.IconPath + '" width="16px" height="16px" onerror="this.src=\'/HtmlSite/smarts4j_n/covicore/resources/images/covision/noimg_s.gif\'">';
	                	  }
	                  },	  
	                  {key:'MultiEquipmentName',  label:'<spring:message code="Cache.lbl_EquipmentName"/>', width:'40', align:'center', 		   /*장비명*/
	                	  formatter:function(){
	                		  return "<a href='#' onclick='modifyEquipmentPopup(\""+this.item.EquipmentID+"\")'>" + CFN_GetDicInfo(this.item.MultiEquipmentName, lang); + "</a>";
	                	  }
	                  },   
	                  {key:'SortKey',  label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'7', align:'center', sort:"asc"},     			   /*우선순위*/
	                  {key:'IsUse', label:'<spring:message code="Cache.lbl_selUse"/>', width:'10', align:'center',   											/*사용유무*/
	                	  formatter:function () {
		      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.EquipmentID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='changeEquipmentIsUse(\""+this.item.EquipmentID+"\");' />";
		      			  }
	                  },   
	                  {key:'MultiRegisterName',  label:'<spring:message code="Cache.lbl_Register"/>', width:'15', align:'center',				    /*등록자*/
	                	  formatter:function(){
	                		  return CFN_GetDicInfo(this.item.MultiRegisterName, lang);
	                	  }
	                  },	 
	                  {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'15', align:'center', 
	                	  formatter: function(){
	  						return CFN_TransLocalTime(this.item.RegistDate);
	  					  }
	                  }/*등록일*/ 
	  				          
		      		];
	
	
	function setSelectBox(){
		$("#searchTypeSelectBox").bindSelect({
			reserveKeys : {
				optionValue : "value",
				optionText : "name"
			},
			options : [ 
			            {
							"name" : "<spring:message code='Cache.lbl_Select'/>" ,  //선택
							"value" : ""
						}, 
						{
							"name" : "<spring:message code='Cache.lbl_EquipmentName'/>",    //장비명
							"value" : "MultiEquipmentName"
						},
						{
							"name" : "<spring:message code='Cache.lbl_Register'/>",   //등록자
							"value" : "MultiRegisterName"
						}
			],
		});
		
		coviCtrl.renderDomainAXSelect('companySelectBox', lang, 'setGrid', '', Common.getSession("DN_ID"), true);
	}
	
	
	//그리드 세팅
	function setGrid(){
		equipmentGrid.setGridHeader([	            
		       	                  {key:'chk', label:'chk', width:'4', align:'center', formatter: 'checkbox'},
		    	                  {key:'IconPath',  label:'<spring:message code="Cache.lbl_SmartIcon"/>', width:'6', align:'center',  									/*아이콘*/
		    	                	  formatter:function(){
		    	                		  return '<img src="' + coviCmn.loadImage(Common.getBaseConfig("BackStorage").replace("{0}", this.item.CompanyCode) + this.item.IconPath) + '" width="16px" height="16px" onerror="this.src=\'/HtmlSite/smarts4j_n/covicore/resources/images/covision/noimg_s.gif\'">';
		    	                	  } // baseconfig EquipmentThumbnail_SavePath 경로의 파일을 조회(202205 현재는 해당 설정값이 없어서 루트경로에 들어감)
		    	                  },	  
		    	                  {key:'MultiEquipmentName',  label:'<spring:message code="Cache.lbl_EquipmentName"/>', width:'40', align:'center', 		   /*장비명*/
		    	                	  formatter:function(){
		    	                		  return "<a href='#' onclick='modifyEquipmentPopup(\""+this.item.EquipmentID+"\")'>" + CFN_GetDicInfo(this.item.MultiEquipmentName, lang); + "</a>";
		    	                	  }
		    	                  },   
		    	                  {key:'SortKey',  label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'7', align:'center', sort:"asc"},     			   /*우선순위*/
		    	                  {key:'IsUse', label:'<spring:message code="Cache.lbl_selUse"/>', width:'10', align:'center',   											/*사용유무*/
		    	                	  formatter:function () {
		    		      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.EquipmentID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='changeEquipmentIsUse(\""+this.item.EquipmentID+"\");' />";
		    		      			  }
		    	                  },   
		    	                  {key:'MultiRegisterName',  label:'<spring:message code="Cache.lbl_Register"/>', width:'15', align:'center',				    /*등록자*/
		    	                	  formatter:function(){
		    	                		  return CFN_GetDicInfo(this.item.MultiRegisterName, lang);
		    	                	  }
		    	                  },	 
		    	                  {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDateHour"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'15', align:'center', 
		    	                		formatter: function(){
		    	                			return CFN_TransLocalTime(this.item.RegistDate);
		    	                		}
		    	                  }          /*등록일시*/ 
		    		      		]);
		setGridConfig();
		searchConfig();				
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "equipmentGrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
		};
		
		equipmentGrid.setGridConfig(configObj);
	}
	

	//그리드 바인딩
	function searchConfig(){		
		var searchType = $("#searchTypeSelectBox").val();
		var searchWord = $("#searchWord").val();
		equipmentGrid.bindGrid({
				ajaxUrl:"/groupware/resource/getEquipmentList.do",
				ajaxPars: {
					"domainID": $("#companySelectBox").val(),
					"searchType":searchType,
					"searchWord":searchWord
				}
 		});
	}	
	
	// 새로고침
	function gridRefresh(){
		$("#searchTypeSelectBox").bindSelectSetValue('');
		$("#searchWord").val('');
		equipmentGrid.reloadList();
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addEquipment(pModal){		 
		//자원장비 추가 | 자원장비를 추가합니다.
		parent.Common.open("","addEquipment","<spring:message code='Cache.lbl_Equipment_01'/>|||<spring:message code='Cache.lbl_Equipment_02'/>","/groupware/resource/goEquipmentManageSetPopup.do","550px","320px","iframe",pModal,null,null,true);
	}
	
	// 자원장비 수정 레이어 팝업
	function modifyEquipmentPopup(equipmentID){
		//자원장비 수정 | 자원장비 정보를 수정합니다.
		parent.Common.open("","modifyEquipment","<spring:message code='Cache.lbl_Equipment_03'/>|||<spring:message code='Cache.lbl_Equipment_04'/>","/groupware/resource/goEquipmentManageSetPopup.do?equipmentID="+equipmentID,"550px","340px","iframe",true,null,null,true);
	}
	
	
	//장비 사용여부 변경
	function changeEquipmentIsUse(equipmentID){
		$.ajax({
        	type:"POST",
        	url:"/groupware/resource/chnageEquipmentIsUse.do",
        	data:{
        		"equipmentID":equipmentID
        	},
        	success:function(data){
        		if(data.status!='SUCCESS'){
        			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
        		}
        	},
        	error:function(response, status, error){
        	     //TODO 추가 오류 처리
        	     CFN_ErrorAjax("/groupware/resource/chnageEquipmentIsUse.do", response, status, error);
        	}
        });
	}
	
	//자원장비 삭제
	function delEquipment(){
		var delEquipmentIDs = '';
		
		$.each(equipmentGrid.getCheckedList(0), function(i,obj){
			delEquipmentIDs += obj.EquipmentID + ';'
		});
		
		if(delEquipmentIDs == ''){
			 Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
             return;
		}
		
		 Common.Confirm("<spring:message code='Cache.msg_271'/> <br> <spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 연결된 추가 장비 정보도 함께 삭제됩니다.  \n 선택한 항목을 삭제하시겠습니까?
             if (result) {
                $.ajax({
                	type:"POST",
                	url:"/groupware/resource/deleteEquipmentData.do",
                	data:{
                		"equipmentID":delEquipmentIDs
                	},
                	success:function(data){
                		if(data.status=='SUCCESS'){
                			Common.Inform("<spring:message code='Cache.msg_50'/>"); // 삭제되었습니다.
                			equipmentGrid.reloadList();
                		}else{
                			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
                		}
                	},
                	error:function(response, status, error){
                	     //TODO 추가 오류 처리
                	     CFN_ErrorAjax("/groupware/resource/deleteEquipmentData.do", response, status, error);
                	}
                });
             }
         });
	}
	
	
</script>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.CN_141'/></span>	<!--자원장비 관리-->
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
			<input id="refresh" type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="gridRefresh();"/><!--새로고침-->
			<input id="add" type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addEquipment(true);"/><!--추가-->
			<input id="del" type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="delEquipment()"/><!--삭제-->
		</div>	
		<div id="topitembar02" class="topbar_grid">
			<span class="domain">
				<spring:message code='Cache.lbl_OwnedCompany'/><!--소유회사-->
				<select id="companySelectBox" class="AXSelect W100"></select>
				&nbsp;&nbsp;&nbsp;
			</span>
			<select id="searchTypeSelectBox" class="AXSelect W100"></select>
			<input name="searchWord" type="text" id="searchWord" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" class="AXInput" />
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig();" class="AXButton"/><!--검색 -->
		</div>	
		<div id="equipmentGrid"></div>
	</div>
</form>