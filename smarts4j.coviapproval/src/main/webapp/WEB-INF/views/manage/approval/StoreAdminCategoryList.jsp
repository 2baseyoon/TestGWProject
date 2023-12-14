<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_CateMng' /></h2> <!-- 분류관리 -->
</div>
<div class="cRContBottom mScrollVH">
	<!-- 컨텐츠 시작 -->
	<div class="sadminContent appstoreContent">
		<!-- 상단 버튼 시작 -->
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" href="#" onclick="addCategory(true);"><spring:message code="Cache.btn_Add"/></a><!-- 분류추가 -->
				<a class="btnTypeDefault btnSaRemove" href="#" onClick="deleteCategory();"><spring:message code="Cache.btn_delete"/></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option>10</option>
					<option>20</option>
					<option>30</option>
				</select>
				
				<button class="btnRefresh" type="button" href="#" onclick="Refresh();"></button>
			</div>
		</div>
		<div id="processListGrid" class="tblList"></div>
	</div>
</div>	
<script type="text/javascript">
	var myGrid = new coviGrid();
	myGrid.config.fitToWidthRightMargin = 0;
	
	initAStoreCategoryList();

	function initAStoreCategoryList(){
		setGrid();			// 그리드 세팅
		$("#selectPageSize").change(function(){
			setGridConfig();
		});
	}
	
	//그리드 세팅
	function setGrid(){
		// 헤더 설정
		var headerData =[
							{key:'chk', label:'chk', width:'40', align:'center', formatter:'checkbox',sort:false,},
							{key:'Seq', label:'<spring:message code="Cache.lbl_apv_Sort"/>', width:'50', align:'center'},//정렬
							{key:'CategoryName', label:'<spring:message code="Cache.lbl_subject"/>', width:'200', align:'center',
								formatter:function () {
									return "<a class='txt_underline' onclick='updateCategory(true, \""+ this.item.CategoryID +"\"); return false;'>"+CFN_GetDicInfo(this.item.CategoryName)+"</a>";
								}},//제목
							{key:'FormsCnt', label:'<spring:message code="Cache.lbl_FormsCnt"/>', width:'100', align:'center'}, //양식수
							{key:'IseUse', label:'<spring:message code="Cache.lbl_IsUse"/>', width:'100', align:'center',
								formatter:function () {
									var onOffClass = this.item.IseUse == "Y" ? "on" : "off";
									return "<div class='alarm type01'><a class='onOffBtn "+ onOffClass +"' onclick='updateIsUse(this, \""+this.item.CategoryID+"\")'><span></span></a></div>";
								}},//사용여부
							{key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistrationDate"/>',   width:'150', align:'center', display:true,
								formatter:function () {
									return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.RegistDate)
				      			}}//생성일자
						];
		
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "processListGrid", 
			height:"auto",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
		
		setCategoryGridData();
	}
	
	// data bind
	function setCategoryGridData(){
		myGrid.bindGrid({
 			ajaxUrl:"/approval/manage/getCategoryList.do",
 			/*ajaxPars:{
 				"DomainID" : DomainId
 			}*/
		});
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addCategory(pModal){
		parent.Common.open("","CategoryDetailPopup","<spring:message code='Cache.lbl_AddCategory'/>","/approval/manage/storeAddCategoryPopup.do?mode=add","708px","300px","iframe",pModal,null,null,true);
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateCategory(pModal, CategoryID){
		parent.Common.open("","CategoryDetailPopup","<spring:message code='Cache.lbl_modifyCategory'/>","/approval/manage/storeAddCategoryPopup.do?mode=modify&id="+CategoryID,"708px","300px","iframe",pModal,null,null,true);
	}
	
	// 사용여부 스위치 버튼에 대한 값 변경
	function updateIsUse(obj, pCategroyID){
		$(obj).toggleClass("on");
		var isUse = $(obj).hasClass("on");
		
		var now = new Date();
		var iseUseValue = isUse ? "Y" : "N";
		var sURL = "/approval/manage/updateIsUseCategory.do";
		
		$.ajax({
			type:"POST",
			data:{
				"CategoryID" : pCategroyID,
				"IseUse" : iseUseValue,
			},
			url:sURL,
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform(data.message, "Information Dialog");
				}else{
					Common.Warning("<spring:message code='Cache.msg_ErrorOccurred'/>", data.message); // 오류가 발생했습니다.
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax(sURL, response, status, error);
			}
		});
	}
	
	function deleteCategory(){
		var CategoryCodes=[];
		var deleteObject = myGrid.getCheckedList(0);
		if(deleteObject.length == 0 || deleteObject == null){
			Common.Inform("<spring:message code='Cache.msg_CheckDeleteObject'/>"); //msg_CheckDeleteObject
			return;
		}
		$.each(deleteObject, function(i,obj){
			CategoryCodes.push(obj.CategoryID)
		});
		CategoryCodes = CategoryCodes.join(",");
		
		Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) {//선택한 항목을 삭제하시겠습니까?
             if (result) {
                $.ajax({
                	type:"POST",
                	url:"/approval/manage/deleteCategory.do",
                	data:{
                		"CategoryCodes" : CategoryCodes
                	},
                	success:function(data){
        				if(data.result == "ok"){
        					Common.Inform(data.message, "Information Dialog", function(){
	                			setCategoryGridData();
        					});
        				}else{
        					Common.Warning(data.message, "<spring:message code='Cache.msg_ErrorOccurred'/>"); // 오류가 발생했습니다.
        				}
                	},
                	error:function(response, status, error){
                	     CFN_ErrorAjax("/approval/manage/deleteCategory.do", response, status, error);
                	}
                });
			}
		});
		 
	}
	

	// 새로고침
	function Refresh(){
		CoviMenu_GetContent(location.href.replace(location.origin, ""),false);
	}
</script>