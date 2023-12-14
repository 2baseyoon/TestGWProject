<%@page import="java.util.Objects"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code="Cache.lblComm"/></h2>	
</div>
<div class="cRContBottom mScrollVH">
<input type="hidden" id ="hiddenCategory" value = ""/>
<input type="hidden" id ="DIC_Code_ko" value = ""/>
<input type="hidden" id ="DIC_Code_en" value = ""/>
<input type="hidden" id ="DIC_Code_ja" value = ""/>
<input type="hidden" id ="DIC_Code_zh" value = ""/>
<input type="hidden" id ="_hiddenMemberOf" value = ""/>	
	<div id="topitembar03" class="inPerView type02 sa04 active">
		<div>
			<div class="selectCalView"> 
				<spring:message code="Cache.lbl_apv_state"/>
				<select id="communityCdSelBox" class="selectType02"></select>
			</div>	
			<div class="selectCalView"> 
				<spring:message code="Cache.lbl_type"/>
				<select id="communityTySelBox" class="selectType02"></select>
			</div>	
			<div class="selectCalView"> 
				<spring:message code="Cache.lbl_JoiningMethod"/>
				<select id="communityJoSeltBox" class="selectType02"></select>
			</div>	
			<div class="selectCalView"> 
				<spring:message code="Cache.lbl_search"/>
				<select id="communitySeSelBox" class="selectType02">
					<option value="0"><spring:message code="Cache.btn_Select"/></option>
					<option value="1"><spring:message code="Cache.lbl_selCommunityName"/></option>
					<option value="3"><spring:message code="Cache.lbl_Operator"/></option>
				</select>
				<input name="search" type="text" id="searchValue"/>
				<div class="chkStyle10"><input type="checkbox" class="check_class" id="chk_IsUse" value="Y" ><label for="chk_IsUse"><span class="s_check"></span><spring:message code='Cache.btn_All' /></label> </div>
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover"  id="btnSearch" ><spring:message code="Cache.btn_search"/></a>
			</div>	
		</div>	
	</div>
	<div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" id="folderAdd"><spring:message code="Cache.btn_Add"/></a> <!-- 추가 -->
				<a class="btnTypeDefault" onclick="confCommunity.comuGrid.expandAll(); coviInput.setSwitch();"><spring:message code="Cache.lbl_OpenAll"/></a>
				<a class="btnTypeDefault" onclick="confCommunity.comuGrid.collapseAll(); coviInput.setSwitch();"><spring:message code="Cache.lbl_CloseAll"/></a>
				<a class="btnTypeDefault btnPlusAdd" onclick="confCommunity.addCommunity();"><spring:message code="Cache.lbl_MakeCommunity"/></a> <!-- 추가 -->	
			</div>
			<div class="buttonStyleBoxRight">
				<button class="btnRefresh" id="btnRefresh" type="button" href="#"></button>
			</div>
		</div>	
		<div id="gridDiv" class="tblList tblCont"></div>						
	</div>
</div>
<script type="text/javascript">
var confCommunity = {
		 comuGrid : new coviTree(),
		 comuGridHeader: [{key: "CommunityName",			// 컬럼에 매치될 item 의 키
		    				indent: true,				// 들여쓰기 여부
		    				label:'<spring:message code="Cache.lbl_selCommunityName"/>',
		    				width: "170",
		    				align: "left",		
		    				getIconClass: function(){	// indent 속성 정의된 대상에 아이콘을 지정 가능
		    					return this.item.CU_ID==""?"ic_folder":"ic_file";
		    				},
		    				formatter:function(){
		      		        	var html ="";
		      		        	if (this.item.CU_ID=="")
		      		        		html = this.item.CommunityName+"<a href='#' class='newWindowPop' onclick='confCommunity.subProperty(\"E\",\""+this.item.FolderType+"\",\""+this.item.FolderID+"\")'></a>"
	      		        		else
		      		        		html = String.format("<a href='#' onclick='javascript:confCommunity.subCommunity({1});' style='text-decoration:none'>{0}</a>", this.item.CommunityName, this.item.CU_ID);
	      		        		return html;
		    				}
		    			},  
						{key:'CU_Code', label:"<spring:message code='Cache.lbl_CommunityID'/>",width:'130', align:'center', display:true,formatter:function(){
	      		        	return (this.item.CU_ID==""?"":this.item.CU_Code);
	    				}},
						{key:'SortKey',  label:"<spring:message code='Cache.lbl_PriorityOrder'/>",width:'50',align:'center',display:true },  
						{key:'CuAppDetail',  label:"<spring:message code='Cache.lbl_State'/>",width:'100',display:true},  
						{key:'CommunityType',  label:"<spring:message code='Cache.lbl_type'/>",width:'100',align:'center',display:true},  
						{key:'CommunityJoin',  label:"<spring:message code='Cache.lbl_JoiningMethod'/>",width:'100',align:'center',display:true},  
						{key:'Point',  label:'Point',width:'50',align:'center',display:true},  
						{key:'MembersCount',  label:"<spring:message code='Cache.lbl_User_Count'/>",width:'50',align:'center',display:true},  
						{key:'Grade',  label:"<spring:message code='Cache.lbl_RankTitle'/>",width:'50',align:'center',display:true},  
						{key:'MsgCount',  label:"<spring:message code='Cache.lbl_noticeCount'/>",width:'50',align:'center',display:true},  
						{key:'OperatorName',  label:"<spring:message code='Cache.lbl_Operator'/>",width:'100',align:'center',display:true},  
						{key:'RegProcessDate',  label:"<spring:message code='Cache.lbl_Establishment_Day'/>" +Common.getSession("UR_TimeZoneDisplay"),width:'150',display:true,
							formatter:function(){
								return CFN_TransLocalTime(this.item.RegProcessDate,_StandardServerDateFormat);
							}	
						},
						{key:'IsUse', label:'<spring:message code="Cache.lbl_Use"/>', width:'60', align:'center',formatter:function(){
 			        		return confCommunity.formatSwitch(this); 
						}},								// 사용
						{key:'CommunityView', label:"<spring:message code='Cache.lbl_view'/>", width:'240',align:'left',display:true,formatter:function() {
							var html = "<div class='btnActionWrap'>";
							if (this.item.CU_ID == "") {
								if (this.item.IsUse == 'Y'){
									html += '<a href="javascript:;" class="btnTypeDefault btnPlusAdd" onclick="confCommunity.subProperty(\'C\', \'Folder\',' + '\'' + this.item.CU_Code + '\',' + '\'' + this.item.CommunityName + '\',' +');"><spring:message code="Cache.btn_apv_Person"/></a>'; // 추가	
								}
								html += '<a href="javascript:;" class="btnTypeDefault btnSaRemove" onclick="confCommunity.delProperty(\''+this.item.FolderID+'\',\''+this.item.hasChild+'\');"><spring:message code="Cache.lbl_delete"/></a>'; // 삭제
								//html += '<a href="javascript:;" class="btnTypeDefault btnMoveUp" onclick="confCommunity.moveProperty(\'up\', \''+this.item.FolderID+'\');"><spring:message code="Cache.lbl_apv_up"/></a>'; // 위로
								//html += '<a href="javascript:;" class="btnTypeDefault btnMoveDown" onclick="confCommunity.moveProperty(\'down\', \''+this.item.FolderID+'\');"><spring:message code="Cache.lbl_apv_down"/></a>'; // 아래로
								if(!(Common.getGlobalProperties("isSaaS") == "N" && this.item.FolderType == "Root")){
									html += '<a href="javascript:;" class="btnTypeDefault btnMoveDown" onclick="confCommunity.moveProperty(\'down\', \''+this.item.FolderID+'\');"><spring:message code="Cache.lbl_Move"/></a>'; // 이동	
								}	
							}
							else{//RA:개설신청RD:개설거분ㅍUV:폐새승인
								if (this.item.AppStatus == "RA" || this.item.AppStatus == "RD" || this.item.AppStatus == "UV") {
									html += "";
								} else {
									html += String.format("<a class='btnTypeDefault' onclick='javascript:confCommunity.goCommunitySite({1});'>{0}</a>", "<spring:message code='Cache.lbl_view'/>", this.item.CU_ID);
								}
							
								if (this.item.AppStatus == "RV"||this.item.AppStatus == "RS"||this.item.AppStatus == "RF"){//개설승인,복원,활동중지
									html += String.format("<a class='btnTypeDefault' onclick='confCommunity.communityClose({1});'>{0}</a>", "<spring:message code='Cache.btn_ForcedClosure'/>", this.item.CU_ID);
								}
								if (this.item.AppStatus == "UV"|| this.item.AppStatus == "UF"){//폐새승인, 강제폐쇄
									html += String.format("<a class='btnTypeDefault' onclick='confCommunity.communityRestore({1});'>{0}</a>", "<spring:message code='Cache.lbl_Restore'/>", this.item.CU_ID);
								}
							}
							html += '</div>';
							return html;
						}}
		    		],
		initContent:function(){
			this.setCommunityGrid();
			
			coviCtrl.renderAXSelect('CuAppDetail', 'communityCdSelBox', lang, '', '','',true,true);
			coviCtrl.renderAXSelect('CommunityType', 'communityTySelBox', lang, '', '','',true,true);
			coviCtrl.renderAXSelect('CommunityJoin', 'communityJoSeltBox', lang, '', '','',true,true);

			$("#folderAdd").on("click",function(){
				confCommunity.subProperty('C', 'Root')
			});

			$("#searchValue").on( 'keydown',function(){
				if(event.keyCode=="13"){
					confCommunity.selectCommunityList();
	
				}
			});	

			$("#btnSearch").on("click",function(){
				confCommunity.selectCommunityList();
			});
			
			$("#btnRefresh").on("click",function(){
				confCommunity.selectCommunityList();
			});
		},
		setCommunityGrid:function(){

			this.comuGrid.setConfig({
				targetID: "gridDiv",	// HTML element target ID
				theme: "AXTree_none",
				colGroup: this.comuGridHeader,	// tree 헤드 정의 값
				showConnectionLine: true,	// 점선 여부
				relation: {
					parentKey: "CategoryID",	// 부모 아이디 키
					childKey: "CU_Code"	// 자식 아이디 키
				},
				persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
				persistSelected: false,		// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
				showConnectionLine: true,	// 점선 여부
				colHead: {
					display:true
				},
				height: "auto",
				fitToWidth: true			// 너비에 자동 맞춤
			});
			this.selectCommunityList();				
		},
		selectCommunityList:function(){

			$.ajax({
				url:"/groupware/manage/community/selectCommunityTreeDataAll.do",
				type:"POST",
				data:{
					"domain" :confMenu.domainId,
					"searchValue" : $("#searchValue").val(),
					"searchOption" : $("#communitySeSelBox").val(),
					"communityJoin" : $("#communityJoSeltBox").val(),
					"communityType" : $("#communityTySelBox").val(),
					"communityDetail" : $("#communityCdSelBox").val(),
					"isAll": "Y"		// 미사용 커뮤니티를 재사용으로 변경이 불가능하여 모두 포함하여 조회
				},				
				async:false,
				success:function (data) {
					var List = data.list;
					
					confCommunity.comuGrid.setList(List);
					if ($("#searchValue").val() != "") confCommunity.comuGrid.expandAll()
					
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/resource/selectCommunityTreeData.do", response, status, error);
				}
			});
		},
		subProperty:function(mode,pType, _categoryID, _categoryName){
			Common.open("","communityProperty","<spring:message code='Cache.lbl_ClassificationAttribute'/>","/groupware/manage/community/communityProperty.do?DN_ID="+confMenu.domainId+"&mode="+mode+"&pType="+pType+"&CategoryID="+_categoryID+"&CategoryName="+_categoryName,"550px","380px","iframe",true,null,null,true);
		},
		subCommunity:function(id){
			Common.open("","createCommunity","<spring:message code='Cache.lbl_communityInFoM'/>","/groupware/manage/community/modifyCommunity.do?CU_ID="+id,"640px","680px","iframe",true,null,null,true);
		},
		addCommunity:function(){
			Common.open("","createCommunity","<spring:message code='Cache.lbl_MakeCommunity'/>","/groupware/manage/community/createCommunity.do?DN_ID="+confMenu.domainId,"620px","680px","iframe",true,null,null,true);
		},
		goCommunitySite:function(community){
			 var specs = "left=10,top=10,width=1050,height=900";
			 specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
			 window.open("/groupware/layout/userCommunity/communityMain.do?C="+community, "community", specs);
		},
		delProperty:function(FolderID, hasNode){
			// 삭세 확인 절차 1. 삭제하려는 분류명에 하위 분류가 있을 시 파리미터인 hasNode(hasChild) 값이 0 보다 크므로 삭제를 못하게 함.
			if (hasNode != "0"){
				Common.Inform("<spring:message code='Cache.msg_apv_existFolder' />"); 	// 하위폴더가 존재합니다. 삭제할 수 없습니다.
				return;
			}
			// 삭세 확인 절차 2. 삭제하려는 분류명에 하위 분류는 없지만(hasNode=0) 해당 분류에 속하는 커뮤니티가 존재할 경우, 해당 분류의 커뮤니티들은 강제폐쇄한다.
			Common.Confirm("<spring:message code='Cache.apv_msg_rule02' />", "Confirmation Dialog", function (confirmResult) { 	// 하위 노드가 존재하면 같이 삭제 됩니다. 선택한 항목을 삭제 하시겠습니까?
				if (confirmResult) {
					$.ajax({
						url:"/groupware/manage/community/deleteCategory.do",
						type:"post",
						data:{
							"paramArr" : FolderID
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Warning("<spring:message code='Cache.msg_50' />");
								confCommunity.selectCommunityList();
							}else{ 
								Common.Warning("<spring:message code='Cache.msg_51' />");
								confCommunity.selectCommunityList();
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/groupware/manage/community/deleteCategory.do", response, status, error);
						}
					}); 
				} else {
					return false;
				}
			});			
		},
		moveProperty:function(moveType, FolderID){
			var url = "";
			url += "/groupware/manage/community/CommunityCategoryMove.do?paramArr="+FolderID+"&DN_ID="+confMenu.domainId;
			Common.open("", "ParentCommunityMovePopup", "<spring:message code='Cache.lbl_highDiv'/>", url, "300px", "290px", "iframe", true, null, null, true);
		},
		communityClose:function(CU_ID){
			Common.Confirm("<spring:message code='Cache.msg_SelectedCommunityClosureQ'/>", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					$.ajax({
						url:"/groupware/manage/community/closeCommunity.do",
						type:"post",
						data:{
							"paramArr" : CU_ID
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Warning("<spring:message code='Cache.msg_Changed'/>");
								confCommunity.selectCommunityList();
							}else{ 
								Common.Warning("<spring:message code='Cache.msg_FailProcess'/>");
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/groupware/layout/community/closeCommunity.do", response, status, error); 
						}
					}); 		
				}
			});
		},
		communityRestore:function(CU_ID){
			Common.Confirm("<spring:message code='Cache.msg_AreYouRestoreSelectedItemQ'/>", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					$.ajax({
						url:"/groupware/manage/community/restoreCommunity.do",
						type:"post",
						data:{
							"paramArr" : CU_ID
						},
						success:function (data) {
							if(data.status == "SUCCESS"){
								Common.Warning("<spring:message code='Cache.msg_Changed'/>");
								confCommunity.selectCommunityList();
							}else{ 
								Common.Warning("<spring:message code='Cache.msg_FailProcess'/>");
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/groupware/layout/community/restoreCommunity.do", response, status, error); 
						}
					}); 		
				}
			});
		},
		updateIsUse: function(pCategoryID, pIsUse, pTarget){
			$.ajax({
				type:"POST",
				data:{
					"CategoryID" : pCategoryID,
					"IsUse" : pIsUse
				},
				url:"/groupware/layout/community/categoryUseChange.do",
				success:function (data) {
					if(data.status === 'SUCCESS'){
						Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
						
						if (pIsUse == 'Y') {
							$("#switch_"+pCategoryID).val($("#switch_"+pCategoryID).attr("off_value"));
							$(pTarget).removeClass("on");
						} else {
							$("#switch_"+pCategoryID).val($("#switch_"+pCategoryID).attr("on_value"));
							$(pTarget).addClass("on");
						}
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/layout/community/categoryUseChange.do", response, status, error); 
				}
			});
			
		},
		formatSwitch: function (pObj) {
			var returnStr = '';
			var param = pObj.item;
			
			if (param.FolderID){
				param.on = 'Y'; param.off = 'N';
				param.defVal = param[pObj.key];
				param.retVal = param.FolderID;
				returnStr = coviCmn.getCoviSwitch('switch_'+param.FolderID, param, 'confCommunity.updateIsUse');
			}
			
			return returnStr;
		}
}

this.gridRefresh = function() {
	confCommunity.selectCommunityList();
}
window.onload = confCommunity.initContent();
</script>