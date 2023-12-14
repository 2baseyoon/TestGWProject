<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<script type="text/javascript">

(function() {
	var lang = Common.getSession("lang");
	var equipmentGrid = new coviGrid();
	
	var initFunc = function() {
		setSelectBox();  	// 검색 조건 select box 바인딩
		setGrid();			// 그리드 세팅
	} 
	
	var setSelectBox = function() {
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
			]
		});
	}
	
	//그리드 세팅
	var setGrid = function() {
		equipmentGrid.setGridHeader([	            
			{key:'chk', label:'chk', width:'4', align:'center', formatter: 'checkbox'}
			, {key:'IconPath', label:'<spring:message code="Cache.lbl_SmartIcon"/>', width:'6', align:'center' 		// 아이콘
		    	, formatter : function() {
					return '<img src="' + coviCmn.loadImage(Common.getBaseConfig("BackStorage").replace("{0}", this.item.CompanyCode) + this.item.IconPath) + '" width="16px" height="16px" onerror="coviCmn.imgError(this, false);">';
			}} // baseconfig EquipmentThumbnail_SavePath 경로의 파일을 조회(202205 현재는 해당 설정값이 없어서 루트경로에 들어감)
			, {key:'MultiEquipmentName', label:'<spring:message code="Cache.lbl_EquipmentName"/>', width:'40', align:'center'		// 장비명
				, formatter : function() {
					return "<a href='#' onclick='modifyEquipmentPopup(\""+this.item.EquipmentID+"\")'>" + CFN_GetDicInfo(this.item.MultiEquipmentName, lang); + "</a>";
			}}   
		    , {key:'SortKey', label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'7', align:'center', sort:"asc"}		// 우선순위
			, {key:'IsUse', label:'<spring:message code="Cache.lbl_selUse"/>', width:'10', align:'center'   						// 사용유무
				,formatter: function() { return formatSwitch(this); }
			}
		    , {key:'MultiRegisterName', label:'<spring:message code="Cache.lbl_Register"/>', width:'15', align:'center' 		// 등록자
				, formatter : function() {
					return CFN_GetDicInfo(this.item.MultiRegisterName, lang);
			}}
		    , {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDateHour"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'15', align:'center'
				, formatter: function() {
					return CFN_TransLocalTime(this.item.RegistDate);
			}}   // 등록일시 
		]);
		setGridConfig();
		searchConfig();				
	}
	
	// 그리드 Config 설정
	var setGridConfig = function() {
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
	
	// 검색(그리드 바인딩)
	this.searchConfig = function() {		
		var searchType = $("#searchTypeSelectBox").val();
		var searchWord = $("#searchWord").val();
		
		equipmentGrid.bindGrid({
			ajaxUrl:"/groupware/resource/manage/getEquipmentList.do",
			ajaxPars: {
				"domainID": confMenu.domainId,
				"searchType":searchType,
				"searchWord":searchWord
			}
 		});
	}
	
	// 새로고침
	this.gridRefresh = function() {
		$("#searchTypeSelectBox").bindSelectSetValue('');
		$("#searchWord").val('');
		equipmentGrid.reloadList();
	}
	
	// 추가 버튼에 대한 레이어 팝업
	this.addEquipment = function(pModal) {		 
		//자원장비 추가 | 자원장비를 추가합니다.
		Common.open("","addEquipment","<spring:message code='Cache.lbl_Equipment_01'/>|||<spring:message code='Cache.lbl_Equipment_02'/>","/groupware/resource/manage/goEquipmentManageSetPopup.do","550px","320px","iframe",true,null,null,true);
	}
	
	// 자원장비 수정 레이어 팝업
	this.modifyEquipmentPopup = function(equipmentID) {
		//자원장비 수정 | 자원장비 정보를 수정합니다.
		Common.open("","modifyEquipment","<spring:message code='Cache.lbl_Equipment_03'/>|||<spring:message code='Cache.lbl_Equipment_04'/>","/groupware/resource/manage/goEquipmentManageSetPopup.do?equipmentID="+equipmentID,"550px","340px","iframe",true,null,null,true);
	}
	
	//장비 사용여부 변경
	this.changeEquipmentIsUse = function(pEquipmentID, pIsUse, pTarget) {
		$.ajax({
        	type:"POST",
        	url:"/groupware/resource/manage/chnageEquipmentIsUse.do",
        	data:{
        		"equipmentID": pEquipmentID
        	},
        	success:function(data){
        		if(data.status === 'SUCCESS'){
					Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
				}else{
					Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
					
					if(pIsUse == 'Y'){
						$(pTarget).removeClass("on");
						$("#switch_"+pEquipmentID).val($("#switch_"+pEquipmentID).attr("off_value"));
					} else {
						$(pTarget).addClass("on");
						$("#switch_"+pEquipmentID).val($("#switch_"+pEquipmentID).attr("on_value"));
					}
				}
        	},
        	error:function(response, status, error){
        	     CFN_ErrorAjax("/groupware/resource/manage/chnageEquipmentIsUse.do", response, status, error);
        	}
        });
	}
	
	//자원장비 삭제
	var delEquipment = function() {
		var delEquipmentIDs = '';
		
		$.each(equipmentGrid.getCheckedList(0), function(i,obj) {
			delEquipmentIDs += obj.EquipmentID + ';'
		});
		
		if (delEquipmentIDs == '') {
			 Common.Warning("<spring:message code='Cache.msg_Common_03'/>", "Warning Dialog", function () { }); 	// 삭제할 항목을 선택하여 주십시오.
             return;
		}
		
		Common.Confirm("<spring:message code='Cache.msg_271'/> <br> <spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {       // 연결된 추가 장비 정보도 함께 삭제됩니다.  \n 선택한 항목을 삭제하시겠습니까?
			if (result) {
                $.ajax({
                	type:"POST",
                	url:"/groupware/resource/manage/deleteEquipmentData.do",
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
                	     CFN_ErrorAjax("/groupware/resource/manage/deleteEquipmentData.do", response, status, error);
                	}
                });
             }
         });
	}
	
	$(document).ready(function() {
		initFunc();		
	});
	
})();

function formatSwitch(pObj){
	var param = pObj.item;
	param.on = 'Y'; param.off = 'N';
	param.defVal = param[pObj.key];
	param.retVal = param.EquipmentID;
	return coviCmn.getCoviSwitch('switch_'+param.EquipmentID, param, 'changeEquipmentIsUse');
}
	
</script>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code='Cache.CN_141'/></h2>	<!-- 자원장비 관리 -->
</div>
<div class="cRContBottom mScrollVH">
<form id="form1">
	<div id="topitembar03" class="inPerView type02 sa04 active">
		<div>
			<select id="searchTypeSelectBox" class="selectType02"></select>
			<input name="searchWord" type="text" id="searchWord" onkeypress="if (event.keyCode==13){ searchConfig(); return false;}"/>
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="searchConfig();" class="AXButton"/><!--검색 -->
		</div>	
	</div>
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault"  id="add" onclick="addEquipment(false);"><spring:message code="Cache.btn_Add"/></a><!--추가-->
				<a class="btnTypeDefault"  id="del" onclick="delEquipment()"><spring:message code="Cache.btn_delete"/></a><!--삭제-->
			</div>	
	       	<div class="buttonStyleBoxRight">
				<button class="btnRefresh" id="btnRefresh" type="button" href="#"  onclick="gridRefresh();"></button>
			</div>
		</div>	
		<div id="equipmentGrid" class="tblList tblCont"></div>
	</div>
</form>
</div>