<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.CN_131'/></span>	<!--포탈 관리-->
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
			<input id="refresh" type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="gridRefresh();"/><!--새로고침-->
			<input id="add" type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addWebpart(false);"/><!--추가-->
			<input id="del" type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="delWebpart()"/><!--삭제-->
			<input id="copy" type="button" class="AXButton"  value="<spring:message code="Cache.btn_Copy"/>" onclick="copyWebpart()"/><!--복사-->
		</div>	
		<div id="topitembar02" class="topbar_grid">
			<!--소유회사-->
			<spring:message code="Cache.lbl_OwnedCompany"/>:
			<select id="companySelectBox" class="AXSelect W100"></select>
			&nbsp;&nbsp;&nbsp;
			
			<!--업무구분-->
			<spring:message code="Cache.lbl_businessDivision"/>
			<select id="bizSectionSelectBox" class="AXSelect W100"></select>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			
			<spring:message code="Cache.lbl_Section"/>&nbsp; <!-- 표시여부  -->
				<select class="AXSelect" id="range">
					<option value=""><spring:message code="Cache.lbl_all"/></option> <!-- 전체  -->
					<option value="Portal">Portal</option>
					<option value="Public">Public	</option>
					<option value="MyContents">베이직-MyContents</option>
					<option value="MyPlace">스마트형-MyPlace</option>	
					<option value="Widget">퍼스널형-Widget</option>
					<option value="Contents">퍼스널형-Contents</option>
				</select>
		
			<select id="searchTypeSelectBox" class="AXSelect W100"></select>			
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" class="AXInput" />
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig(1);" class="AXButton"/><!--검색-->
			
			<span id="checkedFormOrDevice" style="display:none;">
				&nbsp;웹파트형태&nbsp; <!-- 웹파트형태  -->
				<select class="AXSelect" name="form">
					<option value="ALL" selected><spring:message code="Cache.lbl_all"/></option> <!-- 전체  -->
					<option value="FIX">고정</option>
					<option value="DEF">기본</option>
					<option value="">설정안함</option>
				</select>
				
				&nbsp;서비스장치&nbsp; <!-- 서비스장치  -->
				<select class="AXSelect" name="device">
					<option value="" selected><spring:message code="Cache.lbl_all"/></option> <!-- 전체  -->
					<option value="A">PC/Mobile</option>
					<option value="P">PC</option>
					<option value="M">Mobile</option>
				</select>
			</span>
		</div>	
		<div id="webpartGrid"></div>
	</div>
</form>

<script type="text/javascript">

	//# sourceURL=WebpartManage.jsp
	var webpartGrid = new coviGrid();
	var lang = Common.getSession("lang");
	
	//ready 
	init();
	
	function init(){
		if(Common.getBaseConfig("IsUsePersonalPortal") == "Y") $("#checkedFormOrDevice").show();
		
		setSelectBox();
		setGrid();			// 그리드 세팅
		addEvent();
	}
	
	//selectbox 컨트롤 바인딩
	function setSelectBox(){
		coviCtrl.renderCompanyAXSelect("companySelectBox",lang,true,"","",'')
		coviCtrl.renderAXSelect("BizSection","bizSectionSelectBox",lang,"", 	"", "");
		$("#searchTypeSelectBox").bindSelect({ //검색 조건
			options: [{'optionValue':'','optionText':'선택'},{'optionValue':'WebpartName','optionText':'웹파트명'},{'optionValue':'RegisterName','optionText':'등록자'},{'optionValue':'Description','optionText':'설명'}]
		});
	}
	
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		webpartGrid.setGridHeader([	            
		     	                  {key:'chk', label:'chk', width:'3', align:'center', formatter: 'checkbox'},
		    	                  {key:'WebpartID',  label:'ID', width:'4', align:'center'},	   /*ID*/
		    	                  {key:'CompanyName',  label:'<spring:message code="Cache.lbl_OwnedCompany"/>', width:'9', align:'center', 
		    	                	  formatter: function(){
		    	                		  return CFN_GetDicInfo(this.item.CompanyName);
		    	                	  }
		    	                  },	   /*소유회사*/
		    	                  {key:'BizSectionName',  label:'<spring:message code="Cache.lbl_businessDivision"/>', width:'7', align:'center'},	   /*업무영역*/
		    	                  {key:'Range',  label:'<spring:message code="Cache.lbl_businessDivision"/>', width:'7', align:'center'},	   /*업무영역*/
		    	                  {key:'DisplayName',  label:'<spring:message code="Cache.lbl_WebPartName"/>', width:'26', align:'left',
		    	                	  formatter:function(){
		    	                		  var rangeStr = "";
		    	                		  
		    	                		  if(this.item.Range == "MyContents" || this.item.Range == "MyPlace"){
		    	                			  rangeStr = "<font color='red'>[" + this.item.Range + "]</font> ";
		    	                		  }
		    	                		  
		    	                		  return "<a href='#' onclick='modifyWebpartPopup(\""+this.item.WebpartID+"\")'>"+ rangeStr + this.item.DisplayName + "</a>";
		    	                	  }
		    	                  },	     /*웹파트 이름*/
		    	                  {key:'Description',  label:'<spring:message code="Cache.lbl_Description"/>', sort:false, width:'26', align:'left'},	   /*설명*/
		    	                  {key:'RegisterName',  label:'<spring:message code="Cache.lbl_Register"/>', width:'7', align:'center',
		    	                	  formatter:function(){
		    	                	      return CFN_GetDicInfo(this.item.RegisterName);  
		    	                  	  }
		    	                  },     /*등록자*/
		    	                  {key:'IsUse', label:'<spring:message code="Cache.lbl_selUse"/>', width:'9', align:'center',
		    	                	  formatter:function () {
		    		      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.WebpartID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsUse+"' onchange='changeIsUseWebpart(\""+this.item.WebpartID+"\");' />";
		    		      			  }
		    	                  },      /*사용유무*/
		    	                  {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'9', align:'center', sort:'desc', formatter: function(){
		    	  						return CFN_TransLocalTime(this.item.RegistDate, "yyyy-MM-dd");
		    	  				  }}          /*등록일*/
		    		      		]);
		
		setGridConfig();
		searchConfig();				
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "webpartGrid",
			height:"auto"
		};
		
		webpartGrid.setGridConfig(configObj);
	}
	


	//그리드 바인딩
	function searchConfig(){		
		var companyCode = $("#companySelectBox").val();	
		var bizSection = $("#bizSectionSelectBox").val();
		var searchType = $("#searchTypeSelectBox").val();
		var searchWord = $("#search").val();

		webpartGrid.bindGrid({
				ajaxUrl:"/groupware/portal/getWebpartList.do",
				ajaxPars: {
					"companyCode":companyCode,
					"bizSection":bizSection,
					"searchType":searchType,
					"searchWord":searchWord,
					"range":$("#range").val(),
					"reserved1":$("#checkedFormOrDevice select[name=form] option:selected").val(),
					"reserved2":$("#checkedFormOrDevice select[name=device] option:selected").val()
				}
		});
	}	
	
	
	// 새로고침
	function gridRefresh(){
		$("#companySelectBox").bindSelectSetValue('');
		$("#bizSectionSelectBox").bindSelectSetValue('');
		$("#searchTypeSelectBox").bindSelectSetValue('');
		$("#checkedFormOrDevice select[name=form] option").eq(0).prop("selected", true);
		$("#checkedFormOrDevice select[name=device] option").eq(0).prop("selected", true);
		$("#search").val('');
		searchConfig();
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addWebpart(){		 
		Common.open("","settingWebpart","<spring:message code='Cache.lbl_WebPartManage_02'/>|||<spring:message code='Cache.msg_WebPartManage_02'/>","/groupware/portal/goWebpartManageSetPopup.do","620px","500px","iframe",true,null,null,true);
	}
	
	// 수정 버튼에 대한 레이어 팝업
	function modifyWebpartPopup(webpartID){
		Common.open("","settingWebpart","<spring:message code='Cache.lbl_WebPartManage_03'/>|||<spring:message code='Cache.msg_WebPartManage_08'/>","/groupware/portal/goWebpartManageSetPopup.do?webpartID="+webpartID,"620px","500px","iframe",true,null,null,true);
	}
	
	// 복사 버튼에 대한 레이어 팝업
	// mode=copy로 호출
	function copyWebpart(){
		var webpartID;
		if(webpartGrid.getCheckedList(0).length>1){
			Common.Warning("<spring:message code='Cache.lbl_Mail_SelectOneItem'/>","Warning",function(){ //1개의 항목만 선택해 주세요.
				return false;
			});
		}else if(webpartGrid.getCheckedList(0).length < 1){
			Common.Warning("<spring:message code='Cache.msg_SelItemCopy'/>","Warning",function(){ //복사할 항목을 선택하세요
				return false;
			});
		}else{
			webpartID = webpartGrid.getCheckedList(0)[0].WebpartID;			
			Common.open("","settingWebpart","<spring:message code='Cache.lbl_WebPartManage_04'/>|||<spring:message code='Cache.msg_WebPartManage_12'/>","/groupware/portal/goWebpartManageSetPopup.do?webpartID="+webpartID+"&mode=copy","620px","500px","iframe",true,null,null,true);
		}
	}
	
	//사용여부 변경
	function changeIsUseWebpart(webpartID){
		$.ajax({
        	type:"POST",
        	url:"/groupware/portal/chnageWebpartIsUse.do",
        	data:{
        		"webpartID":webpartID
        	},
        	success:function(data){
        		if(data.status!='SUCCESS'){
        			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
        		}
        	},
        	error:function(response, status, error){
        	     //TODO 추가 오류 처리
        	     CFN_ErrorAjax("/groupware/portal/chnageWebpartIsUse.do", response, status, error);
        	}
        	
        });
	}
	
	//Wepbart 삭제
	function delWebpart(){
		var webpartIDInfos = '';
		
		$.each(webpartGrid.getCheckedList(0), function(i,obj){
			webpartIDInfos += obj.WebpartID + ';'
		});
		
		if(webpartIDInfos == ''){
			 Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
             return;
		}
		
		 Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
             if (result) {
                $.ajax({
                	type:"POST",
                	url:"/groupware/portal/deleteWebpartData.do",
                	data:{
                		"webpartID":webpartIDInfos
                	},
                	success:function(data){
                		if(data.status=='SUCCESS'){
               				Common.Warning("<spring:message code='Cache.msg_50'/>"); //삭제되었습니다.
                			webpartGrid.reloadList();
                		}else{
                			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
                		}
                	},
                	error:function(response, status, error){
                	     //TODO 추가 오류 처리
                	     CFN_ErrorAjax("/groupware/portal/deleteWebpartData.do", response, status, error);
                	}
                	
                });
             }
         });
	}
	
	function addEvent() {
		$("#checkedFormOrDevice select[name=form], #checkedFormOrDevice select[name=device]").on("change", function() {
			searchConfig();
		});
	}
</script>
