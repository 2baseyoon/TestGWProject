<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<body>
	<div class="sadmin_pop">
		<c:if test="${not fn:containsIgnoreCase(GroupType, 'JOBTITLE') && not fn:containsIgnoreCase(GroupType, 'JOBLEVEL') && not fn:containsIgnoreCase(GroupType, 'JOBPOSITION')&& not fn:containsIgnoreCase(GroupType, 'REGION')}">
		<div class="sadmin_pop_topCont">
			<div class="buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" 	id="btnAdd"	onclick="addMember();"><spring:message code="Cache.btn_Add"/></a>			
				<a class="btnTypeDefault btnSaRemove" 	id="btnDel"	onclick="deleteOrgGroup();"><spring:message code="Cache.btn_delete"/></a>	
				<a class="btnTypeDefault" 							onclick="syncSelectDomain();"><spring:message code="Cache.btn_CacheApply"/></a>			
			</div>
		</div>
		</c:if>
		<div class="tblList tblCont boradBottomCont StateTb">
			<div id="gridGroupMember" style='height:100%'></div>
		</div>
		
		<div style="width: 100%; text-align: center; margin-top: 10px;">
			<input type="button" id="btnClose" value="<spring:message code='Cache.btn_Close' />" onclick="closePopup();" class="AXButton" > <!-- 닫기 -->
		</div>
	</div>
</div>
	
</body>

<script type="text/javascript">

	var _companyCode = "${DomainCode}";
	var _gr_code = "${GR_Code}";
	var _domainId = "${DomainId}";
	var _gridHeaderData;
	var _myGrid;
	var _isModify=false;
	var _callBackFunc = CFN_GetQueryString("callBackFunc") == "undefined" ? "" : CFN_GetQueryString("callBackFunc");

	var sessionObj = Common.getSession();
	
	
	$(document).ready(function () {
		_myGrid = new coviGrid();
		_gridHeaderData =[ {key:'chk', label:'chk', width:'40', align:'center', formatter:'checkbox'},
							//구분
							{key:'TYPE',  label:"<spring:message code='Cache.lbl_Gubun'/>", width:'100', align:'center'},
							//코드
							{key:'CODE',  label:"<spring:message code='Cache.lbl_Code'/>", width:'180', align:'center'},
							//코드명
							{key:'CODENAME',  label:"<spring:message code='Cache.lbl_codeNm'/>", width:'130', align:'center'},
							//메일
							{key:'MAILADDRESS',  label:"<spring:message code='Cache.lbl_Mail'/>", width:'230', align:'center'}
						];
		
		setGroupGrid();
		bindGrid();
	});
	function setGroupGrid(){
		var configObj = {
				targetID : "gridGroupMember",
				height:"auto",
				xscroll:true,
				page : {
					pageNo:1,
					pageSize:10
				},
				paging : true,
				sort : false,
				fitToWidth:false
			};
		_myGrid.setGridHeader(_gridHeaderData);
		_myGrid.setGridConfig(configObj);
	}
	
	function bindGrid() {
		if($.isEmptyObject(_domainId)||_domainId=='')
			return;
		if($.isEmptyObject(_gr_code)||_gr_code=='')
			return;
		
		url = "/covicore/manage/conf/getGroupMemberList.do";
		params = {
			"DomainId":_domainId,
			"GroupCode":_gr_code
		};
		_myGrid.bindGrid({
			ajaxUrl:url,
			ajaxPars: params
		});
	}
	function addMember(){
		//////////D9:부서/사용자 type=B9 > user만 선택 가능  
		if(Common.getGlobalProperties("isSaaS") == "Y")
			parent.Common.open("","orgmap_pop"  ,"<spring:message code='Cache.btn_OrgManage'/>" ,"/covicore/control/goOrgChart.do?openerID=divgroupMemberInfo&callBackFunc=addMemberCallBack&companyCode=" + _companyCode,"1060px","580px","iframe",true,null,null,true);
		else
			parent.Common.open("","orgmap_pop"  ,"<spring:message code='Cache.btn_OrgManage'/>" ,"/covicore/control/goOrgChart.do?openerID=divgroupMemberInfo&callBackFunc=addMemberCallBack","1060px","580px","iframe",true,null,null,true);
		
	}
	function addMemberCallBack(data) {

		var urCodeList = ""; 
        var grCodeList = "";   
        
		var jsonData = JSON.parse(data);
		
		jsonData.item.forEach(function(obj){
			// 선택된 UR 코드를 꺼낸다.
			 var sObjectType = $(obj).attr("itemType");
			 if (sObjectType.toUpperCase() == "USER") {
	                urCodeList += $(obj).attr("UserCode") + ";";
	          }
		});
		
		jsonData.item.forEach(function(obj){
			// 선택된 GR 코드를 꺼낸다.
			 var sObjectType = $(obj).attr("itemType");
			 if (sObjectType.toUpperCase() == "GROUP") {
				 grCodeList += $(obj).attr("GroupCode") + ";";
	         }
		});			 
	     
		$.ajax({
			type:"POST",
			data:{
				"GroupCode" : _gr_code, 
				"URList" : urCodeList,
				"GRList" : grCodeList
			},
			url:"/covicore/manage/conf/addGroupMember.do",
			success:function (data) {
				if(data.status == "FAIL") {
					Common.Warning(data.message);
				} else {
					_isModify = true;
					Common.Inform("<spring:message code='Cache.msg_37'/>", "Information Dialog", function(result) {
						if(result) {
							_myGrid.reloadList();
						}
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/manage/conf/addGroupMember.do", response, status, error);
			}
		});
	}
		
	function deleteOrgGroup(){
		
		var checkCheckList 		= _myGrid.getCheckedList(0);// 체크된 리스트 객체
		var TargetUserTemp 		= []; //체크된 항목 저장용 배열
		var TargetUser 				= ""; //체크된 항목을 문장으로 나열 (A;B; . . ;)
		var TargetGroupTemp 		= []; //체크된 항목 저장용 배열
		var TargetGroup 				= ""; //체크된 항목을 문장으로 나열 (A;B; . . ;)

		if(checkCheckList.length == 0){
			Common.Inform("<spring:message code='Cache.msg_apv_003'/>" );				//선택된 항목이 없습니다.
		}else if(checkCheckList.length > 0){

			for(var i = 0; i < checkCheckList.length; i++){
				if(checkCheckList[i].TYPE.toUpperCase() == "USER"){
					TargetUserTemp.push(checkCheckList[i].MEMBERID);
				} else {
					TargetGroupTemp.push(checkCheckList[i].MEMBERID);
				}
			}
			
			TargetUser = TargetUserTemp.join(",");
			TargetGroup = TargetGroupTemp.join(",");
			
			Common.Confirm("<spring:message code='Cache.msg_apv_093'/>" , "Inform", function (result) { //삭제하시겠습니까?
				if (result) {
					$.ajax({
						url: "/covicore/manage/conf/deleteGroupMember.do",
						type:"post",
						data:{
			 				"TargetUser": TargetUser,
			 				"TargetGroup": TargetGroup
						},
						async:false,
						success:function (res) {
							_isModify = true;
							Common.Inform("<spring:message code='Cache.msg_50'/>", "Information Dialog", function(result) {
								if(result) {
									_myGrid.reloadList();
								}
							});
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/manage/conf/deleteGroupMember.do", response, status, error);
						}
					});
				}
			}); 
		}else{
			Common.Error("<spring:message code='Cache.msg_ScriptApprovalError'/>"); // 오류 발생
		}
	}
	
		
	function closePopup(){
		XFN_CallBackMethod_Call("",_callBackFunc,_isModify);
		Common.Close();
	}
	function syncSelectDomain() {
		Common.Progress("<spring:message code='Cache.msg_Processing'/>");
		$.post("/covicore/aclhelper/refreshSyncKeyAll.do", {"DomainID" : _domainId}, function(data) {
			Common.AlertClose();
		});
	}
</script>