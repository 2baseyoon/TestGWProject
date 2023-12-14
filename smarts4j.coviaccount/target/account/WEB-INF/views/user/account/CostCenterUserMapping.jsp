<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

	<style>
		.pad10 { padding:10px;}
	</style>
	<!-- 상단 끝 -->
	<div class="cRConTop titType">
		<h2 id="headerTitle" class="title"></h2>
	</div>
	<div class='cRContBottom mScrollVH'>
		<!-- 컨텐츠 시작 -->
		<div class="eaccountingCont">
			<div class="eaccountingTopCont">
				<!-- 상단 버튼 시작 -->
				<div class="pagingType02 buttonStyleBoxLeft">
					<!-- 엑셀다운로드 -->
					<a class="btnTypeDefault btnExcel" onclick="CostCenterUserMapping.excelDownload();" id="btnExcelDown"><spring:message code="Cache.ACC_btn_excelDownload"/></a>
					<!-- 엑셀업로드 -->
					<a class="btnTypeDefault btnExcel_upload" onclick="CostCenterUserMapping.excelUpload();" id="btnExcelUp"><spring:message code="Cache.ACC_lbl_excelUpload"/></a>
					<!-- 동기화 -->
					<%-- <a class="btnTypeDefault" onclick="CostCenterUserMapping.costCenterUserMappingSync();" id="btnSync"><spring:message code="Cache.ACC_btn_sync"/></a> --%>
				</div>
			</div>
			<div class="bodysearch_Type01">
				<div class="inPerView type07">
					<div style="width:900px;">
						<div class="inPerTitbox">
							<span class="bodysearch_tit">
								<spring:message code='Cache.ACC_lbl_company'/>	<!-- 회사 -->
							</span>
							<!-- <select id="companySelect" class="treeSelect" onchange="CostCenterUserMapping.getTreeDept()"></select> -->
							<span id="companySelect" class="selectType02 listCount" onchange="CostCenterUserMapping.getTreeDept()">
							</span>
						</div>
					</div>
				</div>
			</div>
			
			<div class="codemapping_wrap">
				<div class="codemapping_conin">
					<div class="codemapping_left">
						<div class="codemapping_tit">
							<h3><spring:message code='Cache.ACC_lbl_dept'/></h3>	<!-- 부서 -->
						</div>
						<div id="treeGridArea" class="codemapping_list_wrap typecode radio radioType02 org_tree">
						</div>
					</div>
					<div class="codemapping_middle" style="width:50px;">
					</div>
					<div class="codemapping_right">
						<div class="codemapping_tit">
							<h3><spring:message code='Cache.ACC_lbl_mapping'/></h3>	<!-- 매핑 -->
							<div class="codemapping_tit_btn">
							<a class="btnTypeDefault btnTypeChk"	onclick="CostCenterUserMapping.updateCostCenterUserMappingInfo()"><spring:message code='Cache.ACC_btn_save'/></a>
						</div>
						</div>
						<div class="codemapping_list_wrap typecode">
							<table cellpadding="0" cellspacing="0" border="0" class="codemapping_list">
								<tbody id="costCenterUserMappingRightList">
								</tbody>
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- 컨텐츠 끝 -->
	</div>
<script>
	
	if (!window.CostCenterUserMapping) {
		window.CostCenterUserMapping = {};
	}
	
	(function(window) {
		var CostCenterUserMapping = {
				
				params : {
					groupTree	: null,
					userID		: '',
					deptCode	: ''
				},
				
				pageInit : function(){
					var me = this;
					setHeaderTitle('headerTitle');
					//me.setSelectBind(); //실제 회사코드
					me.setSelectCombo(); //e-Accounting 기초코드의 회사코드
					me.appendHtmlTreeGridArea();
					me.getTreeDept();
				},
				
				pageView : function() {
					//accountCtrl.refreshAXSelect("companySelect");
				},
				
				setSelectCombo : function(){
					var AXSelectMultiArr = [	
							{'codeGroup':'CompanyCode',	'target':'companySelect', 'lang':'ko', 'onchange':'', 'oncomplete':'', 'defaultVal':''}
	   					]
					accountCtrl.renderAXSelectMulti(AXSelectMultiArr);
				},
				
				setSelectBind : function(){
					var me = this;
					/* var allCompany = Common.getBaseConfig("useAffiliateSearch");
					if(Common.getGlobalProperties("isSaaS") == "Y") {
						allCompany = "N";
					}
					
					$.ajax({
						type:"POST",
						url : "/covicore/admin/orgmanage/getdomainlist.do",
						data : {
							"allCompany": allCompany
						},
						async: false, 
						success : function(data){
							var sHtml = "";
							
							$.each(data.list, function(idx, obj){
								sHtml += "<option value='"+obj.GroupCode+"'>"+obj.DisplayName+"</option>";
							});
							
							accountCtrl.getInfo("companySelect").html(sHtml);
						}
					}); */
					
					accountCtrl.getInfo("companySelect").coviCtrl("setSelectOption", "/covicore/admin/orgmanage/getdomainlist.do");
				},
				
				appendHtmlTreeGridArea : function(){
					var me = this;
					var viewPageDivID = accountCtrl.getViewPageDivID();
					
					var appendStr  = "";
						appendStr += "<div id=\""+viewPageDivID+"groupTree\" style=\"height:100%;\"></div>"
						accountCtrl.getInfo("treeGridArea").append(appendStr);
				},
				
				getTreeDept : function(){
					try{
						var me = this;
						var domain = accountCtrl.getComboInfo("companySelect").val();
						me.params.companyCode = domain;
						me.clearRow();
						me.params.groupTree = new coviTree();
						$.ajax({
							url:"/account/costCenter/getCostCenterUserMappingDeptList.do",
							type:"POST",
							data:{
								"companyCode" : domain
							},
							async:false,
							success:function (data) {
								var List = data.list;
								var bodyConfig = {
										onclick:function(idx, item){
											CostCenterUserMapping.getUserOfGroupList(item.GroupCode);
										}
								};
								
								var viewPageDivID = accountCtrl.getViewPageDivID();
								
								CostCenterUserMapping.params.groupTree.setTreeList(viewPageDivID+"groupTree", List, "nodeName", "170", "left", true, false, bodyConfig);
								CostCenterUserMapping.params.groupTree.expandAll(1);
								CostCenterUserMapping.params.groupTree.displayIcon(true);
							},
							error:function(response, status, error){
								Common.Inform(error)
							}
						});
						
						CostCenterUserMapping.groupTree.displayIcon(false);
					}catch (e) {
						// TODO: handle exception
						coviCmn.traceLog(e);
					}
				},
				
				getUserOfGroupList : function(deptCode){
					var me = this;
					me.clearRow();
					me.params.deptCode	= deptCode;
					$.ajax({
						type:"POST",
						data:{
							"deptCode" : deptCode
						},
						async:false,
						url:"/account/costCenter/getCostCenterUserMappingUserList.do",
						success:function (data) {
							CostCenterUserMapping.addRow(data.list);
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/control/getUserList.do", response, status, error);
						}
					});
				},
				
				clearRow : function(){
					var rows = accountCtrl.getInfo("costCenterUserMappingRightList").children('tr');
					rows.remove();
				},
				
				addRow : function(info){
					var list = info.list;
					if(list.length == 0){
						return;
					}
					
					for(var i=0; i<list.length; i++){
						var rowInfo				= list[i];
						var companyCode			= getStr(rowInfo.ETID);
						var userID				= getStr(rowInfo.UserID);
						var userCode			= getStr(rowInfo.UserCode);
						var userName			= getStr(rowInfo.DN.split(';')[0]);
						var userCostCenterID	= getStr(rowInfo.UserCostCenterID);
						var costCenterName		= getStr(rowInfo.CostCenterName);
						var costCenterCode		= getStr(rowInfo.CostCenterCode);
						
						var appendStr	=  "<tr id='"+userID+"'>"
										+		"<td class='codemapping_td01'>"
										+		"</td>"
										+		"<td class='codemapping_td02'>"
										+			"<div class='codemapping_list_con' id='"+userID+"userName'>"
										+				userName
										+			"</div>"
										+		"</td>"
										+		"<td class='codemapping_td02'>"
										+			"<div class='codemapping_list_con' id='"+userID+"CostCenterName'>"
										+				costCenterName
										+			"</div>"
										+		"</td>"
										+		"<td class='codemapping_td02'>"
										+			"<span	onclick='CostCenterUserMapping.costCenterCodeDel(\""+ userID	+ "\")'	class='ui-icon ui-icon-close'></span>"
										+			"<a		onclick='CostCenterUserMapping.costCenterSearch(\""	+ userID	+ "\")'	class='btnMoreStyle02'></a>"
										+		"</td>"
										+		"<td hidden>"
										+			"<input id=\""+userID+"UserCostCenterID\" readOnly>"
										+		"</td>"
										+		"<td hidden>"
										+			"<input id=\""+userID+"CompanyCode\" readOnly>"
										+		"</td>"
										+		"<td hidden>"
										+			"<input id=\""+userID+"CostCenterCode\" readOnly>"
										+		"</td>"
										+		"<td hidden>"
										+			"<input id=\""+userID+"UserCode\" readOnly>"
										+		"</td>"
										+		"<td hidden>"
										+			"<input id=\""+userID+"ChangeData\" readOnly>"
										+		"</td>"
										+	"</tr>"

						accountCtrl.getInfo("costCenterUserMappingRightList").append(appendStr);
						accountCtrl.getInfo(userID+"UserCostCenterID").val(userCostCenterID);
						accountCtrl.getInfo(userID+"CompanyCode").val(companyCode);
						accountCtrl.getInfo(userID+"UserCode").val(userCode);
						accountCtrl.getInfo(userID+"CostCenterCode").val(costCenterCode);
						accountCtrl.getInfo(userID+"ChangeData").val('N');
					}
				},
				
				costCenterCodeDel : function(userID){
					var me = this;
					accountCtrl.getInfo(userID + "CostCenterCode").val('');
					accountCtrl.getInfo(userID + "CostCenterName")[0].textContent = '';
					accountCtrl.getInfo(userID + "ChangeData").val('Y');
				},
				
				costCenterSearch : function(userID){
					var me = this;
					me.params.userID	= userID;
					
					var companyCode	= 	me.params.companyCode;
					var popupName	=	"CostCenterSearchPopup";
					var popupID		=	"costCenterSearchPopup";
					var openerID	=	"CostCenterUserMapping";
					var popupTit	=	"<spring:message code='Cache.ACC_lbl_costCenter' />";	//CostCenter
					var popupYN		=	"N";
					var callBack	=	"costCenterSearchPopup_CallBack";
					var url			=	"/account/accountCommon/accountCommonPopup.do?"
									+	"popupID="		+	popupID		+	"&"
									+	"popupName="	+	popupName	+	"&"
									+	"openerID="		+	openerID	+	"&"
									+	"popupYN="		+	popupYN		+	"&"
									+	"companyCode="	+	companyCode	+	"&"
									+	"callBackFunc="	+	callBack;
					Common.open("",popupID,popupTit,url,"600px","730px","iframe",true,null,null,true);
				},
				
				costCenterSearchPopup_CallBack : function(info){
					var me = this;
					accountCtrl.getInfo(me.params.userID + "CostCenterCode").val(info.CostCenterCode);
					accountCtrl.getInfo(me.params.userID + "CostCenterName")[0].textContent = info.CostCenterName;
					accountCtrl.getInfo(me.params.userID + "ChangeData").val('Y');
				},
				
				updateCostCenterUserMappingInfo : function(){
					var me = this;
					
					var params	= new Object();
					var infoArr	= [];
					
					var rList	= accountCtrl.getInfo("costCenterUserMappingRightList").children();
					if(rList.length > 0){
						for(var i=0; i<rList.length; i++){
							var nowID	= rList[i].id;
							
							var chgChk	= accountCtrl.getInfo(nowID+"ChangeData").val()
							if(chgChk == 'Y'){
								var companyCode			= accountCtrl.getInfo(nowID+"CompanyCode").val()
								var userCode			= accountCtrl.getInfo(nowID+"UserCode").val();
								var costCenterCode		= accountCtrl.getInfo(nowID+"CostCenterCode").val();
								var userCostCenterID	= accountCtrl.getInfo(nowID+"UserCostCenterID").val();
								
								var obj = {	"companyCode"		: companyCode
										,	"userCode"			: userCode
										,	"costCenterCode"	: costCenterCode
										,	"userCostCenterID"	: userCostCenterID};
								infoArr.push(obj)
							}
						}
					}
					
					if(infoArr.length==0){
						Common.Inform("<spring:message code='Cache.ACC_msg_noChange' />");
						return
					}
					
					params.rList = infoArr;
					
					$.ajax({
						url			: "/account/costCenter/updateCostCenterUserMappingInfo.do",
						type		: "POST",
						data		: JSON.stringify(params),
						dataType	: "json",
						contentType	: "application/json",
						success:function(data){
							Common.Inform("<spring:message code='Cache.ACC_msg_saveComp'/>");	//저장되었습니다
							CostCenterUserMapping.getUserOfGroupList(CostCenterUserMapping.params.deptCode)
						}
					});
				},
				
				excelDownload : function() {
					var me = this;
					Common.Confirm("<spring:message code='Cache.ACC_msg_excelDownMessage'/>", "<spring:message code='Cache.ACC_btn_save' />", function(result){
			       		if(result){
							var headerName	= "회사명†사용자코드†사용자명†CostCenter코드";
							var headerKey	= "CompanyName,UserCode,UserName,CostCenterCode";
							var headerType	= "Text|Text|Text|Text";
							var companyCode = me.params.companyCode || "";
							
							var	locationStr		= "/account/costCenter/costCenterUserMappingExcelDownload.do?"
												//+ "headerName="		+ encodeURI(headerName)
												+ "headerName="		+ encodeURIComponent(encodeURIComponent(headerName))
												+ "&headerKey="		+ encodeURI(headerKey)
												+ "&title="			+ encodeURI(accountCtrl.getInfo("headerTitle").text())
												+ "&headerType=" + encodeURI(headerType)
												+ "&companyCode=" + encodeURI(companyCode);
							
							location.href = locationStr;
						}
					});					
				},
				
				excelUpload : function() {
					var popupID		= "costCenterUserMappingExcelPopup";
					var openerID	= "CostCenterUserMapping";
					var popupTit	= "CostCenter User Mapping Excel UpLoad";
					var popupYN		= "N";
					var callBack	= "costCenterUserMappingExcelPopup_CallBack";
					var popupUrl	= "/account/costCenter/costCenterUserMappingExcelPopup.do?"
									+ "popupID="		+ popupID	+ "&"
									+ "openerID="		+ openerID	+ "&"
									+ "popupYN="		+ popupYN	+ "&"
									+ "callBackFunc="	+ callBack;
					
					Common.open("", popupID, popupTit, popupUrl, "500px", "220px", "iframe", true, null, null, true);
				},
				
				costCenterUserMappingExcelPopup_CallBack : function(){
					var me = this;
					me.refresh();
				},
				
				costCenterUserMappingSync : function() {
					var me = this;
					
					$.ajax({
						url	: "/account/costCenter/costCenterUserMappingSync.do",
						type: "POST",
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Inform("<spring:message code='Cache.ACC_msg_syncComp' />"); //동기화되었습니다
								me.refresh();
							}else{
								Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 	
							}
						},
						error:function (error){
							Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
						}
					});					
				},
				
				refresh : function(){
					accountCtrl.pageRefresh();
				}
		}
		window.CostCenterUserMapping = CostCenterUserMapping;
	})(window);
</script>