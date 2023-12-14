<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.CN_127'/></span>	
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
			<input id="refresh" type="button" class="AXButton BtnRefresh" value="새로고침" onclick="gridRefresh();"/><!--새로고침-->
			<input id="add" type="button" class="AXButton BtnAdd"  value="추가" onclick="addlayout(false);"/><!--추가-->
			<input id="del" type="button" class="AXButton BtnDelete"  value="삭제" onclick="delLayout()"/><!--삭제-->
		</div>	
		<div id="topitembar02" class="topbar_grid">
			<select id="searchTypeSelectBox" class="AXSelect W80"></select>		 	
			<input name="search" type="text" id="search" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}" class="AXInput" />
			<input type="button" value="검색" onclick="searchConfig();" class="AXButton"/>
		</div>	
		<div id="layoutGrid"></div>
	</div>
</form>

<script type="text/javascript">
	//# sourceURL=LayoutManage.jsp
	var layoutGrid = new coviGrid();

	//ready 
	init();
	
	function init(){
		setSelectBox();		// 검색 select box 바인딩
		setGrid();			// 그리드 세팅			
	}
	
	function setSelectBox(){
		$("#searchTypeSelectBox").bindSelect({
			options: [
				{optionValue:'', optionText:"선택"}, /*선택*/
				{optionValue:'DisplayName', optionText:"레이아웃명"}, /*레이아웃*/
				{optionValue:'RegisterName', optionText:"등록자"} /*등록자 */
			]
		});		
	}
	
	
	//그리드 세팅
	function setGrid(){
		var BackStorage = Common.getBaseConfig("BackStorage").replace("{0}", Common.getSession("DN_Code")); // baseconfig LayoutThumbnail_SavePath 경로의 파일 조회
		// 헤더 설정
		layoutGrid.setGridHeader([	            
		    	                  {key:'chk', label:'chk', width:'5', align:'center', formatter: 'checkbox'},
		    	                  {key:'LayoutID',  label:'ID', width:'6', align:'center'},	   /*ID*/
		    	                  {key:'DisplayName',  label:'<spring:message code="Cache.lbl_layoutName"/>', width:'25', align:'left',
		    	                	  formatter:function(){
		    	                		  return "<a href='#' onclick='modifyLayoutPopup(\""+this.item.LayoutID+"\")'>" + this.item.DisplayName + "</a>";
		    	                	  }
		    	                  },	     /*포탈명칭*/
		    	                  {key:'LayoutThumbnail',  label:'<spring:message code="Cache.lbl_image"/>', width:'10', align:'center',           //미리보기
		    	                	  formatter:function () {
	    		                		  return "<img src='"+ coviCmn.loadImage(BackStorage + this.item.LayoutThumbnail)+"' onerror='coviCmn.imgError(this);' width='35px' height='35px'/>";
		    		      			  }
		    	                  },
		    	                  {key:'SortKey', label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'10', align:'center', sort:"asc"},     			   /*우선순위*/
		    	                  {key:'MultiDisplayName',  label:'<spring:message code="Cache.lbl_Register"/>', width:'10', align:'center',
		    	                	  formatter:function(){
		    	                	      return CFN_GetDicInfo(this.item.MultiDisplayName);  
		    	                  	  }
		    	                  },     /*등록자*/
		    	                  {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'10', align:'center', formatter: function(){
		    	  						return CFN_TransLocalTime(this.item.RegistDate, "yyyy-MM-dd");
		    	  				  }},        /*등록일*/ 
		    	                  {key:'IsDefault', label:'<spring:message code="Cache.lbl_DefaultUsage"/>', width:'12', align:'center'
		    	                	/*   formatter:function () {
		    		      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.LayoutID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsDefault+"' onchange='ChangelayoutIsDefault(\""+this.item.LayoutID+"\");' />";
		    		      			  } */
		    	                  },      /*기본 사용여부*/
		    	                  {key:'IsCommunity', label:'<spring:message code="Cache.WebmoduleRange_CuHome"/>', width:'12', align:'center' /* 커뮤니티 홈용  */
		    	                	/*   formatter:function () {
		    		      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='AXInputSwitch"+this.item.LayoutID+"' style='width:50px;height:21px;border:0px none;' value='"+this.item.IsDefault+"' onchange='ChangelayoutIsDefault(\""+this.item.LayoutID+"\");' />";
		    		      			  } */
		    	                  } 
		    		      		]);
		
		
		setGridConfig();
		searchConfig();				
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "layoutGrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			colHead:{},
		};
		
		layoutGrid.setGridConfig(configObj);
	}
	

	//그리드 바인딩
	function searchConfig(){		
		var searchType = $("#searchTypeSelectBox").val();
		var searchWord = $("#search").val();
		layoutGrid.bindGrid({
				ajaxUrl:"/groupware/portal/getLayoutList.do",
				ajaxPars: {
					"searchType":searchType,
					"searchWord":searchWord
				}
		});
	}	
	
	
	// 새로고침
	function gridRefresh(){
		$("#searchTypeSelectBox").bindSelectSetValue('');
		$("#search").val('');
		searchConfig();
	}
	
	//추가 버튼에 대한 레이어 팝업
	function addlayout(pModal){		 
		Common.open("","addlayout","<spring:message code='Cache.lbl_layoutManage_01'/>|||<spring:message code='Cache.lbl_layoutManage_02'/>","/groupware/portal/goLayoutManageSetPopup.do","620px","550px","iframe",pModal,null,null,true);
	}
	
	//수정 레이어 팝업 호출 
	function modifyLayoutPopup(layoutID){
		Common.open("","modifylayout","<spring:message code='Cache.lbl_layoutManage_03'/>|||<spring:message code='Cache.lbl_layoutManage_04'/>","/groupware/portal/goLayoutManageSetPopup.do?layoutID="+layoutID,"620px","550px","iframe",true,null,null,true);
	}
	
	//기본 사용여부 변경
// 	function ChangelayoutIsDefault(layoutID){
// 		$.ajax({
//         	type:"POST",
//         	url:"/groupware/portal/changeLayoutIsDefault.do",
//         	data:{
//         		"layoutID":layoutID
//         	},
//         	success:function(data){
//         		if(data.status!='SUCCESS'){
//         			Common.Warning("오류가 발생했습니다.");//오류가 발생헸습니다.
//         		}
//         	},
//         	error:function(response, status, error){
//         	     //TODO 추가 오류 처리
//         	     CFN_ErrorAjax("/groupware/portal/changeLayoutIsDefault.do", response, status, error);
//         	}
        	
//         });
// 	}
	
	//레이아웃 삭제 기능 
	function delLayout(){
		var layoutIDInfos = '';
		
		$.each(layoutGrid.getCheckedList(0), function(i,obj){
			layoutIDInfos += obj.LayoutID + ';'
		});
		
		if(layoutIDInfos == ''){
			 Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { });          // 삭제할 항목을 선택하여 주십시오.
             return;
		}
		
		 Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 선택한 항목을 삭제하시겠습니까?
             if (result) {
                $.ajax({
                	type:"POST",
                	url:"/groupware/portal/deleteLayoutData.do",
                	data:{
                		"layoutID":layoutIDInfos
                	},
                	success:function(data){
                		if(data.status=='SUCCESS'){
                			//포탈에서 사용하는 레이아웃은 삭제 불가
                			if(data.notRemove!=""){
                				Common.Warning("ID=["+data.notRemove+"] "+"포탈에서 해당 레이아웃을 사용 중이므로 삭제할 수 없습니다.","Warning",function(){ //포탈에서 해당 레이아웃을 사용 중이므로 삭제할 수 없습니다.
		                			Common.Warning(data.remove+"개 삭제되었습니다."); // 삭제되었습니다.
		                			layoutGrid.reloadList();
                				}); //포탈에서 해당 레이아웃을 사용 중이므로 삭제할 수 없습니다.
                			}else{
                				Common.Warning("삭제되었습니다."); //삭제되었습니다.
	                			layoutGrid.reloadList(); 
                			}
                		}else{
                			Common.Warning("오류가 발생했습니다.");//오류가 발생헸습니다.
                		}
                	},
                	error:function(response, status, error){
                	     CFN_ErrorAjax("/groupware/portal/deleteLayoutData.do", response, status, error);
                	}
                	
                });
             }
         });
	}
</script>
