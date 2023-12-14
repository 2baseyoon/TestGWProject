<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_ACLManage"/></span> <!-- 권한 관리  -->
</h3>
<div id="divAclManage">
	<div style="width:100%">
		<div id="topitembar02" class="topbar_grid">
			<span class=domain1>
				<spring:message code="Cache.lbl_Domain"/>&nbsp;<!-- 도메인 -->
				<select name="" class="AXSelect" id="selectDomain"></select>
			</span>
			<spring:message code="Cache.lbl_AclCondition"/>&nbsp;
			<select name="" class="AXSelect" id="aclType"></select>
			<input type="text" id="aclText" class="AXInput"  onkeypress="if(event.keyCode==13){ aclManage.searchAclData(1); return false;}"/>
			<input type="button" value="<spring:message code="Cache.btn_search"/>" onclick="aclManage.searchAclData(1);" class="AXButton"/><!-- 검색 -->
			<input type="button" id="addBtn" class="AXButton" value="<spring:message code="Cache.btn_Add"/>"/><!-- 추가 -->
			<input type="button" id="refreshBtn" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>"/><!-- 새로고침 -->
			<input type="button" id="cacheBtn" class="AXButton" value="<spring:message code="Cache.lbl_CacheInitialization"/>"/><!-- 검색 -->
		</div>
	</div>
	<table>
		<colgroup>
			<col width="400px"/>
			<col width=*/>
		</colgroup>
		<tr><td style="vertical-align: top;">
			<div id="gridAclDiv"></div>
			</td>
			<td style="vertical-align:top;width:100%;padding-left:10px" id=tdData>
				<div class="AXTabsLarge" style="margin-bottom: 10px">
					<div class="AXTabsTray">
						<a data-type="USER" class="AXTab on" value="divDomainBasicInfo"><spring:message code="Cache.lbl_hrMng_targetUser"/></a><!--대상자-->
						<a data-type="MN" class="AXTab" value="divDomainBasicInfo"><spring:message code="Cache.lbl_Menu"/></a><!--메뉴-->
						<a data-type="FD" class="AXTab" value="divDomainBasicInfo"><spring:message code="Cache.lbl_Folder"/></a><!--폴더-->
						<a data-type="PT" class="AXTab" value="divDomainBasicInfo"><spring:message code="Cache.lbl_portal"/></a><!--포탈-->
						<a data-type="CU" class="AXTab" value="divDomainBasicInfo"><spring:message code="Cache.lbl_Community"/></a><!--커뮤니티-->
					</div>
				</div>
				<div id="divDomainBasicInfo">
					<div id="topitembar01" class="topbar_grid">
						<span class='star'>※공통과 사용자는 대상자가 조회되지 않습니다.</span>
						<span id="isAdminArea" style="display:none">
							<spring:message code='Cache.lbl_User'/>/<spring:message code='Cache.lbl_admin'/>&nbsp;
							<select id="selectIsAdmin" class="AXSelect W100"></select>
						</span>
						<span id="folderTypeArea" style="display:none">
							<spring:message code="Cache.lbl_FolderType"/>&nbsp; <!-- 폴더유형 -->
							<select id="folderType" class="AXSelect W100"></select>
						</span>
						<span id="searchArea" style="display:none">
							Name&nbsp;
							<input type="text" id="searchText" class="AXInput" />
							<input type="button" id="searchBtn" class="AXButton" value="<spring:message code="Cache.btn_search"/>"/><!-- 검색 -->
						</span>
						<input type="button" class="AXButton BtnAdd" style="display:none" value="<spring:message code="Cache.btn_Add"/>" />
						<input type="button" class="AXButton BtnDelete" style="display:none" value="<spring:message code="Cache.btn_delete"/>"/>
					</div>
					<div id="gridAclDetailDiv"></div>
				</div>
			</td>
		</tr>
	</table>
</form>
<script type="text/javascript">
var aclManage = {
		gridAcl : new coviGrid(),
		gridAclDetail : new coviGrid(),
		headerAcl :([{key:'DisplayName',  label:'Name', width:'200', align:'left', formatter:function(){
						return (this.item.GroupType!= null && this.item.GroupType== "Dept" ?aclManage.getFormatPath(this.item.OUPath,2):this.item.DisplayName); 
					}},
		              {key:'MnCnt', label:'MN', width:'45', align:'center'},
		              {key:'FdCnt', label:'FD', width:'45', align:'center'},
		              {key:'PtCnt', label:'PT', width:'45', align:'center'},
		              {key:'CuCnt', label:'Cu', width:'45', align:'center'}
		      	]),
		headerAclDetail :{
					"USER":[{key:'num', label:"<spring:message code='Cache.lbl_Number'/>",width:'50', align:'center', display:true, formatter:function(){ return this.index+1}, sort:false},
      		              {key:'DeptName',  label:'<spring:message code="Cache.lbl_dept"/>', width:'150', align:'left', formatter:function(){
  							return aclManage.getFormatPath(this.item.OUPath,2)
      					  }},
      		              {key:'JobPositionName', label:'<spring:message code="Cache.lbl_JobPosition"/>', width:'100', align:'center'}, /* 직위 */
      		              {key:'JobLevelName', label:'<spring:message code="Cache.lbl_JobLevel"/>', width:'100', align:'center'}, /* 직급 */
      		              {key:'JobTitleName', label:'<spring:message code="Cache.lbl_JobTitle"/>', width:'100', align:'center'}, /* 직책 */
      		              {key:'DisplayName', label:'<spring:message code="Cache.lbl_username"/>', width:'80', align:'center'}]
      		        ,"MN":[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox', sort:false },
			              {key:'BizSection',  label:'BizSection', width:'200', align:'left'},
			              {key:'DisplayName',  label:'Name', width:'200', align:'left'},
			              {key:'Security', label:'<spring:message code="Cache.lbl_ACL_Security"/>', width:'50', align:'center', sort:false, formatter:function(){
			            	  return (this.item.AclList!= null && this.item.AclList.substring(0,1)== "S" ? "O":"X"); 
			              }}, /* 보안 */
			              {key:'Create', label:'<spring:message code="Cache.lbl_ACL_Generation"/>', width:'50', align:'center', sort:false, formatter:function(){
			            	  return (this.item.AclList!= null && this.item.AclList.substring(1,2)== "C" ? "O":"X"); 
			              }}, /* 생성 */
			              {key:'Delete', label:'<spring:message code="Cache.lbl_ACL_Delete"/>', width:'50', align:'center', sort:false, formatter:function(){
			            	  return (this.item.AclList!= null && this.item.AclList.substring(2,3)== "D" ? "O":"X"); 
			              }}, /* 삭제 */
			              {key:'Modify', label:'<spring:message code="Cache.lbl_ACL_Edit"/>', width:'50', align:'center', sort:false, formatter:function(){
			            	  return (this.item.AclList!= null && this.item.AclList.substring(3,4)== "M" ? "O":"X"); 
			              }}, /* 수정 */
			              {key:'Execute', label:'<spring:message code="Cache.lbl_ACL_Execute"/>', width:'50', align:'center', sort:false, formatter:function(){
			            	  return (this.item.AclList!= null && this.item.AclList.substring(4,5)== "E" ? "O":"X"); 
			              }}, /* 실행 */
			              {key:'View', label:'<spring:message code="Cache.lbl_ACL_Views"/>', width:'50', align:'center', sort:false, formatter:function(){
			            	  return (this.item.AclList!= null && this.item.AclList.substring(5,6)== "V" ? "O":"X"); 
			              }}, /* 조회 */
			              {key:'Read', label:'<spring:message code="Cache.lbl_ACL_Read"/>', width:'50', align:'center', sort:false, formatter:function(){
			            	  return (this.item.AclList!= null && this.item.AclList.substring(6,7)== "R" ? "O":"X"); 
			              }}, /* 읽기*/
			              {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>',   width:'50', align:'center', formatter:function(){
			            	  return (this.item.IsUse!= null && this.item.IsUse== "Y" ? "<spring:message code='Cache.lbl_Use'/>":"<spring:message code='Cache.lbl_UseN'/>"); 
		              }}]
					,"FD":[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox', sort:false },
					       {key:'FullPath',  label:'Path', width:'200', align:'left'},
					       {key:'DisplayName',  label:'Name', width:'200', align:'left'},
					       {key:'Security', label:'<spring:message code="Cache.lbl_ACL_Security"/>', width:'50', align:'center', sort:false, formatter:function(){
					     	  return (this.item.AclList!= null && this.item.AclList.substring(0,1)== "S" ? "O":"X");
					       }}, /* 보안 */
					       {key:'Create', label:'<spring:message code="Cache.lbl_ACL_Generation"/>', width:'50', align:'center', sort:false, formatter:function(){
					     	  return (this.item.AclList!= null && this.item.AclList.substring(1,2)== "C" ? "O":"X");
					       }}, /* 생성 */
					       {key:'Delete', label:'<spring:message code="Cache.lbl_ACL_Delete"/>', width:'50', align:'center', sort:false, formatter:function(){
					     	  return (this.item.AclList!= null && this.item.AclList.substring(2,3)== "D" ? "O":"X");
					       }}, /* 삭제 */
					       {key:'Modify', label:'<spring:message code="Cache.lbl_ACL_Edit"/>', width:'50', align:'center', sort:false, formatter:function(){
					     	  return (this.item.AclList!= null && this.item.AclList.substring(3,4)== "M" ? "O":"X");
					       }}, /* 슈종 */
					       {key:'Execute', label:'<spring:message code="Cache.lbl_ACL_Execute"/>', width:'50', align:'center', sort:false, formatter:function(){
					     	  return (this.item.AclList!= null && this.item.AclList.substring(4,5)== "E" ? "O":"X");
					       }}, /* 실행 */
					       {key:'View', label:'<spring:message code="Cache.lbl_ACL_Views"/>', width:'50', align:'center', sort:false, formatter:function(){
					     	  return (this.item.AclList!= null && this.item.AclList.substring(5,6)== "V" ? "O":"X");
					       }}, /* 조회 */
					       {key:'Read', label:'<spring:message code="Cache.lbl_ACL_Read"/>', width:'50', align:'center', sort:false, formatter:function(){
					     	  return (this.item.AclList!= null && this.item.AclList.substring(6,7)== "R" ? "O":"X");
					       }}, /* 읽기*/
					       {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>',   width:'50', align:'center', formatter:function(){
					     	  return (this.item.IsUse!= null && this.item.IsUse== "Y" ? "<spring:message code='Cache.lbl_Use'/>":"<spring:message code='Cache.lbl_UseN'/>");
					       }}]
					,"PT":[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox', sort:false },
					       {key:'DisplayName',  label:'Name', width:'200', align:'left'},	//aclList, 0, 'S'btn_Reject
					       {key:'View', label:'<spring:message code="Cache.lbl_ACL_Views"/>', width:'80', align:'center', sort:false, formatter:function(){
					     	  return (this.item.AclList!= null && this.item.AclList.substring(5,6)== "V" ? "O":"X");
					       }},
					       {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>',   width:'50', align:'center', formatter:function(){
					     	  return (this.item.IsUse!= null && this.item.IsUse== "Y" ? "<spring:message code='Cache.lbl_Use'/>":"<spring:message code='Cache.lbl_UseN'/>");
					       }}]
					,"CU":[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox', sort:false },
					       {key:'DisplayName',  label:'Name', width:'200', align:'left'},	//aclList, 0, 'S'btn_Reject
					       {key:'View', label:'<spring:message code="Cache.lbl_ACL_Views"/>', width:'50', align:'center', sort:false, formatter:function(){
					     	  return (this.item.AclList!= null && this.item.AclList.substring(5,6)== "V" ? "O":"X");
					       }}, /* 조회 */]
		      	},
      	objectInit : function(){
			coviCtrl.renderCompanyAXSelect('selectDomain', Common.getSession("lang"), '', '', '', true);
			$("#divAclManage #tdData").width($("#divAclManage #tdData").width()-400);
			this.setFolderType();
			this.addEvent();
//			this.searchData(1);
		},
		addEvent : function(){
			//탭 클릭
			$("#divAclManage .AXTabsTray a").on('click', function(e){
				$("#divAclManage .AXTabsTray a").removeClass("on");
				$(this).addClass("on");
				
				var selType = $(this).data("type");
				
				if (selType === "USER") {
					$("#divAclManage .star").show();
					$("#divAclManage .BtnAdd").hide();
					$("#divAclManage .BtnDelete").hide();
					
					$("#folderTypeArea").hide();
					$("#isAdminArea").hide();
					$("#searchArea").hide();
				} else {
					$("#divAclManage .star").hide();
					$("#divAclManage .BtnAdd").show();
					$("#divAclManage .BtnDelete").show();
					
					$("#searchArea").show();
					$("#folderTypeArea").hide();
					$("#isAdminArea").hide();
					
					switch (selType) {
						case "FD":
							$("#folderTypeArea").show();
							break;
						case "MN":
							$("#isAdminArea").show();
							break;
					}
					
					$("#searchText").val("");
					$("#aclType").bindSelect({}); // AXSeclect 적용을 위한 함수 호출
				}
				
				if (aclManage.gridAcl.getSelectedItem().item) aclManage.searchAclDetail(aclManage.gridAcl.getSelectedItem().item, 1);
			});
			
			// 추가
			$("#divAclManage .BtnAdd").off("click").on("click", function(){
				var selectedItem = aclManage.gridAcl.getSelectedItem().item;
				
				if (selectedItem) {
					aclManage.openAddPopup($("#divAclManage .AXTabsTray a.on").data("type"), selectedItem.SubjectType, selectedItem.SubjectCode);
				} else {
					Common.Inform("<spring:message code='Cache.msg_apv_003'/>"); // 선택된 항목이 없습니다.
				}
			});
			
			//삭제
			$("#divAclManage .BtnDelete").click(function(){
				Common.Confirm("<spring:message code='Cache.msg_Common_08'/>", "Confirmation Dialog", function(confirmResult){ // 선택한 항목을 삭제하시겠습니까?
					if (confirmResult) {
						var aJsonArray = new Array();
						var selectObj = aclManage.gridAclDetail.getCheckedList(0);
						for(var i=0; i<selectObj.length; i++){
	                        aJsonArray.push(selectObj[i].AclID);
						}
						$.ajax({
							type: "POST",
							contentType: 'application/json; charset=utf-8',
							dataType: 'json',
							data: JSON.stringify({"aclList" : aJsonArray}),
							url: "/covicore/aclManage/deleteAcl.do",
							success: function(data){
								if(data.status=='SUCCESS'){
									Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_com_processSuccess'/>");	// 건 / 저장되었습니다.
									aclManage.searchAclData(1);
									aclManage.searchAclDetail(aclManage.gridAcl.getSelectedItem().item, 1);
								}else{
									Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
								}
							},
							error: function(request, status, error){
								CFN_ErrorAjax("/covicore/aclManage/deleteAcl.do", response, status, error);
							}
						});
					}	
				});
			});
			
			//그리드 세팅
			this.gridAcl.setGridConfig({
				targetID: "gridAclDiv",
				height: "400px",
				width: "400px",
				fitToWidth: false,
				colHeadTool: false,
				page: {
					  pageNo: 1
					, pageSize: 10
				},
				colGroup: this.headerAcl,
				colHead: this.headerAcl,
				body: {
					onclick: function(){
						aclManage.searchAclDetail(aclManage.gridAcl.getSelectedItem().item, 1);
					}
				}
			});
			
			this.gridAcl.page.listOffset=3;
			
			this.gridAclDetail.setGridConfig({
				targetID: "gridAclDetailDiv",
				height: "400px",
				width: "100%",
				fitToWidth: true,
				colHeadTool: false,
				page: {
					  pageNo: 1
					, pageSize: 10
				},
				colGroup: this.headerAclDetail["USER"],
				colHead: this.headerAclDetail["USER"],
				body: {
					onclick: function(){
						if(this.item.AclID) aclManage.openEditPopup(this.item.AclID, this.item.ObjectType);
					}
				}
			});
			
			$("#aclType").bindSelect({
				options: [
				 {'optionValue':'Cm','optionText':'공통'}
				,{'optionValue':'Dept','optionText':'부서'}
				,{'optionValue':'JobPosition','optionText':'직위'}
				,{'optionValue':'JobLevel','optionText':'직급'}
				,{'optionValue':'JobTitle','optionText':'직책'}
				,{'optionValue':'Manage','optionText':'관리'}
				,{'optionValue':'User','optionText':'사용자'}
			]});
			
			$("#selectIsAdmin").bindSelect({
				reserveKeys: {optionValue: "value", optionText: "name"},
				options: [
					  {"name": "<spring:message code='Cache.lbl_User'/>", "value": "N"}
					, {"name": "<spring:message code='Cache.lbl_admin'/>", "value": "Y"}
				],
				onchange: function(){
					if (aclManage.gridAcl.getSelectedItem().item) aclManage.searchAclDetail(aclManage.gridAcl.getSelectedItem().item, 1);
				}
			});
			
			// 추가
			$("#addBtn").off("click").on("click", function(){
				aclManage.openTargetAddPopup();
			});
			
			// 새로고침
			$("#refreshBtn").off("click").on("click", function(){
				aclManage.refresh();
			});
			
			// 캐시 초기화
			$("#cacheBtn").off("click").on("click", function(){
				aclManage.resetAclCache();
			});
			
			// 권한 상세 목록 - 검색
			$("#searchBtn").off("click").on("click", function(){
				if (aclManage.gridAcl.getSelectedItem().item) aclManage.searchAclDetail(aclManage.gridAcl.getSelectedItem().item, 1);
			});
			
			$("#searchText").off("keypress").on("keypress", function(e){
				if (e.keyCode === 13 && aclManage.gridAcl.getSelectedItem().item) aclManage.searchAclDetail(aclManage.gridAcl.getSelectedItem().item, 1);
			});
		},
		searchAclData: function(pageNo){
			var params = {"domain": $('#divAclManage #selectDomain').val()
					, "aclType": $('#divAclManage #aclType').val()
					, "aclText": $('#divAclManage #aclText').val()
					, "pageNo": pageNo};
			
			this.gridAcl.bindGrid({
				ajaxPars : params,
				ajaxUrl:"/covicore/aclManage/getAclList.do"
			});
			
		},
		searchAclDetail: function(rowData, pageNo){
			var selectedType = $("#divAclManage .AXTabsTray a.on").data("type");
			var params = {
				  "objectType": selectedType
				, "subjectType": rowData.SubjectType
				, "subjectCode": rowData.SubjectCode
				, "searchText": $("#searchText").val()
			};
			
			if (selectedType === "USER" && ["Cm", "User"].includes($('#aclType').val())) {
				this.gridAclDetail.setDataSet({});
				this.gridAclDetail.redrawDataSet();
				this.gridAclDetail.list = [];
				
				this.gridAclDetail.setConfig({
					colGroup : this.headerAclDetail[selectedType],
					colHead : this.headerAclDetail[selectedType],
					fitToWidth : false
				});
				
				return;
			} else {
				this.gridAclDetail.setConfig({
					colGroup : this.headerAclDetail[selectedType],
					colHead : this.headerAclDetail[selectedType],
					fitToWidth : false
				});
			}
			
			this.gridAclDetail.page.pageNo = pageNo;
			var sendUrl;
			
			switch(selectedType){
				case "USER":
					params["subjectType"] = $('#aclType').val();
					sendUrl = "/covicore/aclManage/getAclTarget.do";
					break;
				case "FD":
					params["folderType"] = $("#folderType").val();
				case "MN":
					params["isAdmin"] = $("#selectIsAdmin").val();
				default:
					sendUrl = "/covicore/aclManage/getAclDetail.do";
			}
			
			this.gridAclDetail.bindGrid({
				ajaxPars : params,
				ajaxUrl: sendUrl
			});
		},
		getFormatPath: function(ouPath, i){
			var arryList = ouPath.split(";");
			if (i == -1) return arryList.join(">");
			else {
				arryList.splice(0, i);
				return arryList.join(">").substring(0, arryList.join(">").length-1);
			}
		},
		refresh: function(){
			this.searchAclData(this.gridAcl.page.pageNo);
			if (this.gridAcl.getSelectedItem().item) this.searchAclDetail(this.gridAcl.getSelectedItem().item, this.gridAclDetail.page.pageNo);
		},
		resetAclCache: function(){
			$.ajax({
				url: "/covicore/aclManage/resetAclCache.do",
				type: "POST",
				data: {
					domain: $("#selectDomain").val()
				},
				success: function(data){
					if(data.status === "SUCCESS"){
						Common.Inform("<spring:message code='Cache.msg_Processed'/>", "Information", function(result){ // 처리 되었습니다
							if(result){
								aclManage.refresh();
							}
						});
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/covicore/aclManage/resetAclCache.do", response, status, error);
				}
			});
		},
		setFolderType: function(){
			$.ajax({
				url: "/covicore/aclManage/getFolderType.do",
				type: "POST",
				data: "",
				success: function(data){
					if(data.status === "SUCCESS"){
						if(data.list.length > 0){
							var optionList = [];
							
							optionList.push({optionValue: "", optionText: "<spring:message code='Cache.lbl_Whole'/>"}); // 전체
							
							$(data.list).each(function(idx, item){
								var option = new Object();
								
								option.optionValue = item.ObjectType;
								option.optionText = item.ObjectName;
								
								optionList.push(option);
							});
							
							$("#folderType").bindSelect({
								  options: optionList
								, onchange: function(){
									if (aclManage.gridAcl.getSelectedItem().item) aclManage.searchAclDetail(aclManage.gridAcl.getSelectedItem().item, 1);
								}
							});
						}
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/covicore/aclManage/getFolderType.do", response, status, error);
				}
			});
		},
		openAddPopup: function(objType, sType, sCode){
			var title = "<spring:message code='Cache.lbl_AuthorityAdd'/>"; // 권한 추가
			var url = "/covicore/aclManage/goAclManageAddPopup.do"
					+ "?objType=" + objType
					+ "&folderType=" + $("#folderType").val()
					+ "&sType=" + sType
					+ "&sCode=" + sCode
					+ "&isAdmin=" + $("#selectIsAdmin").val()
					+ "&domain=" + $("#selectDomain").val();
			var height = ["MN", "FD"].includes(objType) ? "400px" : "630px";
			
			Common.open("", "aclManageAddPopup", title, url, "550px", height, "iframe", false, null, null, true);
		},
		openEditPopup: function(aclID, objType){
			var title = "<spring:message code='Cache.lbl_updateAuthority'/>"; // 권한 수정
			var url = "/covicore/aclManage/goAclManageEditPopup.do"
					+ "?aclID=" + aclID
					+ "&objType=" + objType
					+ "&domain=" + $("#selectDomain").val();
			
			Common.open("", "aclManageEditPopup", title, url, "240px", "290px", "iframe", false, null, null, true);
		},
		openTargetAddPopup: function(){
			var title = "<spring:message code='Cache.lbl_Add'/>"; // 추가
			var url = "/covicore/aclManage/goAclTargetAddPopup.do"
					+ "?aclType=" + $("#aclType").val()
					+ "&domain=" + $("#selectDomain").val();
			
			Common.open("", "aclTargetAddPopup", title, url, "460px", "620px", "iframe", false, null, null, true);
		},
		addACLRows: function(selData){
			selData.forEach(function(item){
				item["MnCnt"] = 0;
				item["FdCnt"] = 0;
				item["PtCnt"] = 0;
				item["CuCnt"] = 0;
			});
			
			aclManage.gridAcl.pushList(selData);
		}
}
$(document).ready(function(){
	aclManage.objectInit();
});

</script>