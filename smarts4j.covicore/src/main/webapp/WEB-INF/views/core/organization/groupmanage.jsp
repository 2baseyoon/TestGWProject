<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.CN_146"/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>

<form>
	<div class="AXTabs">
		<div id="divTabTray" class="AXTabsTray" style="height:30px">
			<a id="groupSetTab" onclick="clickTab(this);" class="AXTab on" value="divgroup"><spring:message code='Cache.lbl_group' /></a> <!-- 부서 -->
			<a id="userSetTab"  onclick="clickTab(this);" class="AXTab" value="divuser"><spring:message code='Cache.lbl_User'/></a> <!-- 사용자 -->
			<p style="text-align: right; padding-bottom: 10px;">
				<label>
					<spring:message code="Cache.lbl_highDiv"/> : <span id="spnNavigationGroup"></span><select id="selCategory" class="AXSelect"></select>
				</label>
			</p>
		</div>
	</div>
	<div id="divgroup" style="margin-top: 5px; padding-top: 5px;">
		<div style="width:100%;">
			<div id="topitembar_1" class="topbar_grid">
				<input type="button" id="btnGroupRefresh" value="<spring:message code="Cache.lbl_Refresh"/>"  onclick="Refresh();" class="AXButton BtnRefresh"/> <!-- 새로고침 -->
				<input type="button" id="btnGroupAttribute" value="<spring:message code="Cache.lbl_Property"/>"  onclick="editOrggroup();" class="AXButton" /> <!-- 속성 -->
				<input type="button" id="btnGroupAdd" value="<spring:message code="Cache.btn_Add"/>"  onclick="addOrggroup(); return false;" class="AXButton BtnAdd" /> <!-- 추가 -->
				<input type="button" id="btnGroupDelete" value="<spring:message code="Cache.btn_delete"/>"  onclick="deleteOrggroup();" class="AXButton BtnDelete"/> <!-- 삭제 -->
				<input type="button" id="btnGroupMoveUp" value="<spring:message code="Cache.btn_UP"/>"  onclick="moveUp('group');" class="AXButton BtnUp"/> <!-- 위로 -->
				<input type="button" id="btnGroupMoveDown" value="<spring:message code="Cache.btn_Down"/>"  onclick="moveDown('group');" class="AXButton BtnDown"/> <!-- 아래로 -->
				<input type="button" id="btnGroupExcel" value="<spring:message code="Cache.btn_ExcelDownload"/>"  onclick="excelDownload('group');" class="AXButton BtnExcel"/> <!-- 엑셀 다운로드 -->
				<input type="button" id="btnCacheReload" value="<spring:message code="Cache.btn_CacheApply"/>"  onclick="syncSelectDomain();" class="AXButton"/> <!-- 캐시 초기화 -->
				<!-- 미구현 -->
				<!-- <input type="button" value="이동" onclick="moveMenu();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.lbl_OpenAll"/>" onclick="openAllMenu();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.lbl_CloseAll"/>" onclick="closeAllMenu();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.btn_CacheApply"/>" onclick="applyCache();"class="AXButton"/> -->
			</div>
			<div>
				<!-- 그룹 그리드 -->
				<p id="pNavigation"></p>
				<div id="orggroupgrid"></div>
			</div>
		</div>
	</div>

	<div id="divuser" style="margin-top: 5px; padding-top: 5px; display:none;">
		<div style="width:100%;">
			<div id="topitembar_2" class="topbar_grid">
				<input type="button"  id="btnUserAdd" value="<spring:message code="Cache.btn_Add"/>" onclick="addOrgUser(); return false;" class="AXButton BtnAdd" /> <!-- 추가 -->
				<input type="button"  id="btnUserDelete" value="<spring:message code="Cache.btn_delete"/>" onclick="deleteOrgUser();" class="AXButton BtnDelete"/> <!-- 삭제 -->
				<input type="button"  id="btnUserExcel" value="<spring:message code="Cache.btn_ExcelDownload"/>" onclick="excelDownload('user');" class="AXButton BtnExcel" style="display: none;"/> <!-- 엑셀 다운로드 -->
				<%-- <input type="button"  id="btnUserMoveUp" value="<spring:message code="Cache.btn_UP"/>" onclick="moveUp('user');"class="AXButton BtnUp"/> <!-- 위로 -->
				<input type="button"  id="btnUserMoveDown" value="<spring:message code="Cache.btn_Down"/>" onclick="moveDown('user');"class="AXButton BtnDown"/> <!-- 아래로 --> --%>
				<!-- 미구현 -->
				<!-- <input type="button" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.lbl_Property"/>" onclick="editOrggroup();" class="AXButton" /> 
				<input type="button" value="이동" onclick="moveMenu();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.lbl_OpenAll"/>" onclick="openAllMenu();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.lbl_CloseAll"/>" onclick="closeAllMenu();"class="AXButton"/>
				<input type="button" value="<spring:message code="Cache.btn_CacheApply"/>" onclick="applyCache();"class="AXButton"/> -->
				<input type="button" id="btnCacheReload" value="<spring:message code="Cache.btn_CacheApply"/>"  onclick="syncSelectDomain();" class="AXButton"/> <!-- 캐시 초기화 -->
			</div>
			<div>
				<!-- 사용자 그리드 -->
				<p id="pPagingNum"></p>
				<div id="orgusergrid"></div>
			</div>
		</div>
	</div>
</form>

<script>

	var isMailDisplay = true;
	var setBtnDisplayGroup = ""; 
	var setBtnDisplayUser = ""; 
	var paramTabType = $.urlParam("tab_type");
	var tabType;
	
	var myGrid;
	
	// 개별호출 일괄처리	
	var lang = Common.getSession("lang");
	Common.getBaseConfigList(["IsSyncMail"]);
	
	// 탭 선택
	function clickTab(pObj){
		$("#divTabTray .AXTab").attr("class","AXTab");
		$(pObj).addClass("AXTab on");
		
		var str = $(pObj).attr("value");
		
		$("#divgroup").hide();
		$("#divuser").hide();
		
		$("#" + str).show();
        coviInput.init();
        
        tabType = str.replace("div", "").toLowerCase();
        
		myGrid = new coviGrid();
        
        setGrid(tabType);
        bindGrid(tabType);
	}
	
	function setBtnDisplay(){
		
		var sGroupType = $.urlParam('group_type') != null ? $.urlParam('group_type').toUpperCase() : "";
		var sGrCode = $.urlParam('gr_code') != null ? $.urlParam('gr_code').toUpperCase() : "";
		
		// 지역, 직위, 직급, 직책, 배포그룹 등은 하위에 그룹을 생성 할 수 없다.
		if (sGroupType == "JOBLEVEL" || sGroupType == "JOBTITLE" || sGroupType == "JOBPOSITION" || sGroupType == "COMPANY" || sGroupType == "REGION" || sGroupType == "DISTRIBUTE" || sGrCode.indexOf("_DIVISION") != -1
			|| sGrCode.indexOf("_JOBLEVEL") != -1 || sGrCode.indexOf("_JOBTITLE") != -1 || sGrCode.indexOf("_JOBPOSITION") != -1)
		{
			setBtnDisplayGroup = "none";
		}
		$("#btnGroupAdd").css("display", setBtnDisplayGroup);
		$("#btnGroupDelete").css("display", setBtnDisplayGroup);
		
		// 지역, 직위, 직급, 직책, 배포그룹, 퇴직부서는 하위에 구성원(사용자)를 생성 할 수 없다.
        if (sGroupType == "JOBLEVEL" || sGroupType == "JOBTITLE" || sGroupType == "JOBPOSITION"
            || sGroupType == "COMPANY" || sGroupType == "REGION" || sGroupType == "DISTRIBUTE" || sGroupType == "COMMUNITY"
            || (sGrCode.indexOf("_DIVISION") != -1) || (sGrCode.indexOf("_JOBLEVEL") != -1) || (sGrCode.indexOf("_JOBTITLE") != -1) || (sGrCode.indexOf("_JOBPOSITION") != -1)
            || (sGrCode.indexOf("_REGION") != -1) || (sGrCode.indexOf("_DISTRIBUTE") != -1) || (sGrCode.indexOf("_COMMUNITY") != -1) || (sGrCode.indexOf("_RETIREDEPT") != -1))
        {
        	setBtnDisplayUser = "none";
        }
        $("#btnUserAdd").css("display", setBtnDisplayUser);
		$("#btnUserDelete").css("display", setBtnDisplayUser);	
		$("#btnUserAdd").parents("div.topbar_grid").css("display", setBtnDisplayUser);        		
	}
	
	function setNavigationUser() {
		var parentPath = "";
		
		if($.urlParam('gr_code') != null) {
			$.ajax({
				type:"POST",
				data:{
					"gr_code" : $.urlParam('gr_code') != null ? $.urlParam('gr_code') : "",
					"grouptype" : $.urlParam('group_type') != null ? $.urlParam('group_type') : ""
				},
				url:"/covicore/admin/orgmanage/getgroupname.do",
				success:function (data) {
					$("#spnNavigationUser").text(data.parentName + data.displayName);
					$("#spnNavigationGroup").text(data.rootName);
					parentPath = data.parentPath;
					
					if(parentPath != "" && parentPath.split(';').length > 0) {
						for(var i = parentPath.split(';').length-2; i >= 0 ; i--) {
							var obj_id = "selParentCategory_" + (i+1);
							$("#spnNavigationGroup").after("<select id='" + obj_id + "' class='AXSelect'></select>");
							setNavigationSelect(obj_id, parentPath.split(';')[i]);
							$("#" + obj_id).after("<span> > </span>");
						}
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/covicore/admin/orgmanage/getgroupname.do", response, status, error);
				}
			});
		} else {
			$("#spnNavigationUser").text($("#domainCodeSelectBoxGroup:selected").text());	
		}
	}
	
	function setNavigationSelect(obj_id, pCode) {
		$.ajax({
			async:false,
			type:"POST",
			data: {
				"gr_code" : pCode != undefined ? pCode : $.urlParam('gr_code'),
				"grouptype" : 'group' //$.urlParam('group_type')
			},
			url:"/covicore/admin/orgmanage/getgrouplistforselect.do",
			success:function(data){
				if(data.status == "FAIL") {
					Common.Error(data.message);
					return;
				}

				$("#" + obj_id).bindSelect({
					reserveKeys: {
						optionValue: "GroupCode",
						optionText: "GroupName"
					},
					options: data.list
				});
				$("#" + obj_id).css("visibility", "");
				$("#AXselect_AX_" + obj_id).remove();
				

				$(document).on("change", "#" + obj_id, function() {
					gotoSelectedCategory($("#" + obj_id + " option:selected").val());
				});
				
				
			},
			error:function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("/covicore/admin/orgmanage/getgrouplistforselect.do", response, status, error);
			}
		});
		
		$("#selCategory").val($.urlParam('gr_code'));
	}
	
	function gotoSelectedCategory(groupCode) {
		var href = $(location).attr('href');
		href = href.replace($.urlParam("gr_code"), groupCode)
		$(location).attr('href', href);
	}
	
	var groupHeaderData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
	                  {key:'GroupCode',  label:'<spring:message code="Cache.lbl_grCode"/>', width:'100', align:'center',
	                	  formatter:function () {
		      					return "<a href='#' onclick='editOrggroup(\""+ this.item.GroupCode +"\", \"" + this.item.GroupType + "\"); return false;'>"+this.item.GroupCode+"</a>";
		      				}},
	                  {key:'SortKey',  label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'70', align:'center'},
	                  {key:'MultiDisplayName', label:'<spring:message code="Cache.lbl_grCodeNm"/>', width:'100', align:'center',
	                	  formatter:function () {
		      					return CFN_GetDicInfo(this.item.MultiDisplayName, lang);
		      				}},
	                  {key:'MultiShortName',  label:'<spring:message code="Cache.lbl_Organization_ShortName"/>', width:'100', align:'center',
	                	  formatter:function () {
		      					return CFN_GetDicInfo(this.item.MultiShortName, lang);
		      				}}, //추후 ShortName으로 변경
	                  {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>', width:'80', align:'center',
	                	  formatter:function () {
		      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsUse"+this.item.GroupCode+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.GroupCode+"\", \"group\", \""+this.item.GroupType+"\");' />";
		      		  		}},
	      		  	  {key:'IsDisplay', label:'<spring:message code="Cache.lbl_n_att_vacTypeDisplay"/>', width:'80', align:'center',
		                  formatter:function () {
				      			return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsDisplay"+this.item.GroupCode+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsDisplay+"' onchange='updateIsDisplay(\""+this.item.GroupCode+"\", \"group\", \""+this.item.GroupType+"\");' />";
				       		}},
	                  {key:'IsMail', label:'<spring:message code="Cache.lbl_IsMail"/>',   width:'70', display: isMailDisplay, align:'center',
	                	  formatter:function () {
		      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsMail"+this.item.GroupCode+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsMail+"' onchange='updateIsMail(\""+this.item.GroupCode+"\",\"group\");' />";
		      		  		}},
		      		  {key:'PrimaryMail', label:'<spring:message code="Cache.lbl_Mail"/>', width:'80', align:'center'}]; //추후 PrimaryMail로 변경
	
	var userHeaderData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		                  {key:'UserCode',  label:'<spring:message code="Cache.lbl_User_Id"/>', width:'90', align:'center', 
		                	  formatter:function () {
			      					return "<a href='#' onclick='editOrgUser(\""+ this.item.UserCode +"\"); return false;'>"+this.item.UserCode+"</a>";
			      				}},
	      				  {key:'MultiDisplayName', label:'<spring:message code="Cache.lbl_User"/>', width:'90', align:'center',
		                	  formatter:function () {
			      					return CFN_GetDicInfo(this.item.MultiDisplayName, lang);
			      				}},
		                  {key:'JobTitle',  label:'<spring:message code="Cache.lbl_JobTitle"/>', width:'70', align:'center',
		                	  formatter:function () {
		                		  	return CFN_GetDicInfo(this.item.JobTitle.split("&")[1] == undefined ? "" :this.item.JobTitle.split("&")[1], lang);
		      					}},
		                  {key:'JobPosition',  label:'<spring:message code="Cache.lbl_JobPosition"/>', width:'70', align:'center',
		                	  formatter:function () {
		                		  	return CFN_GetDicInfo(this.item.JobPosition.split("&")[1] == undefined ? "" : this.item.JobPosition.split("&")[1], lang);
			      				}},
		                  {key:'JobLevel',  label:'<spring:message code="Cache.lbl_JobLevel"/>', width:'70', align:'center',
		                	  formatter:function () {
		                		  	return CFN_GetDicInfo(this.item.JobLevel.split("&")[1] ==  undefined ? "" : this.item.JobLevel.split("&")[1],lang);
			      				}},
		                  {key:'IsHR', label:'<spring:message code="Cache.lbl_IsHR"/>',  width:'80', align:'center',
		                	  formatter:function () {
			      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsHR"+this.item.UserCode.replaceAll(".", "")+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsHR+"' onchange='updateIsHR(\""+this.item.UserCode+"\", \"User\");' />";
			      		  }},
			      		/* {key:'IsAD', label:'<spring:message code="Cache.lbl_IsUseAD"/>',   width:'70', align:'center', //추후 IsUseAD로 변경
		                	  formatter:function () {
			      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsUseAD"+this.item.UserCode.replaceAll(".", "")+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsAD+"' onchange='updateIsUseAD(\""+this.item.UserCode+"\");' />";
			      		  }}, */
			      		  {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>', width:'80', align:'center',
		                	  formatter:function () {
			      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsUse"+this.item.UserCode.replaceAll(".", "")+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsUse(\""+this.item.UserCode+"\", \"User\");' />";
			      		  }},
			      		  {key:'IsMail', label:'<spring:message code="Cache.lbl_IsMail"/>', width:'80', align:'center',
		                	  formatter:function () {
			      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsMail"+this.item.UserCode.replaceAll(".", "")+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsMail(\""+this.item.UserCode+"\", \"User\");' />";
			      		  }},
			      		 /*  {key:'IsMessenger', label:'<spring:message code="Cache.lbl_IsMessenger"/>', width:'80', align:'center',
		                	  formatter:function () {
			      					return "<input type='text' kind='switch' on_value='Y' off_value='N' id='IsMessengerl"+this.item.UserCode.replaceAll(".", "")+"' style='width:50px;height:20px;border:0px none;' value='"+this.item.IsUse+"' onchange='updateIsMessenger(\""+this.item.UserCode+"\", \"User\");' />";
			      		  }}, */
			      		  {key:'MailAddress', label:'<spring:message code="Cache.lbl_Mail"/>', width:'80', align:'center'}];
		      		  
	var memberHeaderData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		                  {key:'Type',  label:'<spring:message code="Cache.lbl_Gubun"/>', width:'90', align:'center', 
		                	  formatter:function () {
			      					if(this.item.Type.toUpperCase() == "USER") 
			      						return "<a href='#' onclick='editOrgUser(\""+ this.item.Code +"\"); return false;'>"+this.item.Type+"</a>";
		      						else
			      						return "<a href='#' onclick='editOrggroup(\""+ this.item.Code +"\", \"" + 'Dept' + "\"); return false;'>"+this.item.Type+"</a>";
			      				}},
	      				  {key:'Code', label:'<spring:message code="Cache.lbl_Code"/>', width:'90', align:'center',
			      				formatter:function () {
			      					if(this.item.Type.toUpperCase() == "USER") 
			      						return "<a href='#' onclick='editOrgUser(\""+ this.item.Code +"\"); return false;'>"+this.item.Code+"</a>";
		      						else
			      						return "<a href='#' onclick='editOrggroup(\""+ this.item.Code +"\", \"" + 'Dept' + "\"); return false;'>"+this.item.Code+"</a>";
			      				}},
		                  {key:'CodeName',  label:'<spring:message code="Cache.lbl_CodeName"/>', width:'70', align:'center',
		                	  formatter:function () {
			      					if(this.item.Type.toUpperCase() == "USER") 
			      						return "<a href='#' onclick='editOrgUser(\""+ this.item.Code +"\"); return false;'>"+CFN_GetDicInfo(this.item.CodeName, lang)+"</a>";
		      						else
			      						return "<a href='#' onclick='editOrggroup(\""+ this.item.Code +"\", \"" + 'Dept' + "\"); return false;'>"+CFN_GetDicInfo(this.item.CodeName, lang)+"</a>";
			      				}},
			      		  {key:'MailAddress', label:'<spring:message code="Cache.lbl_Mail"/>', width:'80', align:'center',
				                	  formatter:function () {
					      					if(this.item.Type.toUpperCase() == "USER") 
					      						return "<a href='#' onclick='editOrgUser(\""+ this.item.Code +"\"); return false;'>"+this.item.MailAddress+"</a>";
				      						else
					      						return "<a href='#' onclick='editOrggroup(\""+ this.item.Code +"\", \"" + 'Dept' + "\"); return false;'>"+this.item.MailAddress+"</a>";
			      						}
			      		  }];	  
	
	function setGrid(type){
		if(type == undefined) {
			type = paramTabType;
		}
		if(type == null) {
			type = "group";
		}
		
		if(type == "group")
			myGrid.setGridHeader(groupHeaderData);
		else {
			if(setBtnDisplayUser == "none")  
				myGrid.setGridHeader(userHeaderData);
			else
				myGrid.setGridHeader(memberHeaderData);
		}
		
		setGridConfig(type);
	}
	
	function setGridConfig(type){
		var configObj = {
				targetID : "org"+type+"grid",
				height:"auto",
				xscroll:true,
				page : {
					pageNo:1,
					pageSize:10
				},
				paging : true,
				sort:false
			};
		
		myGrid.setGridConfig(configObj);
	}
	
	function bindGrid(type) {
		var url;
		var gr_code;
		var grouptype;
		var domainCode;
		var sortBy;
		var params;
		
		if(type == undefined) {
			type = paramTabType;
		}
		if(type == null) {
			type = "group";
		}
		
		switch(type) {
		case "group":
			url = "/covicore/admin/orgmanage/getsubgrouplist.do";
			gr_code = $.urlParam('gr_code') != null ? $.urlParam('gr_code') : "";
			grouptype = $.urlParam('group_type') != null ? $.urlParam('group_type') : "";
			sortBy = myGrid.getSortParam();
			params = {
					"gr_code":gr_code,
					"grouptype":grouptype,
					"sortBy":sortBy
			};
			break;
		case "user":
			if(setBtnDisplayUser == "none")
				url = "/covicore/admin/orgmanage/getgroupuserlist.do";
			else
				url = "/covicore/admin/orgmanage/getgroupmemberlist.do";
			
			gr_code = $.urlParam('gr_code') != null ? $.urlParam('gr_code') : "";
			domainCode = $.urlParam('domainCode') != null ? $.urlParam('domainCode') : "";
			sortBy = myGrid.getSortParam();
			params = {
					"gr_code":gr_code,
					"domainCode":domainCode,
					"sortBy":sortBy
			};
			break;
		}
		
		myGrid.bindGrid({
 			ajaxUrl:url,
 			ajaxPars: params
		});
	}
	
	// 사용여부 스위치 버튼에 대한 값 변경
	function updateIsUse(pCode, pType,pGroupType){
		var now = new Date();
		var isUseValue = $("#IsUse"+pCode).val();
		var sGroupType = "";
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		var sURL = "";
		
		if(pType == "group") {
			sURL = "/covicore/admin/organization/updateisusegroup.do";
			sGroupType = pGroupType;
		} else {
			sURL = "/covicore/admin/organization/updateisuseuser.do";
		}
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"Type"     : sGroupType,
				"IsUse" : isUseValue,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:sURL,
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_137'/>", "Information Dialog", function(result) {
						if(result) {
							myGrid.reloadList();
						}
					});
			},
			error:function(response, status, error){
				CFN_ErrorAjax(sURL, response, status, error);
			}
		});
	}
	
	// 인사연동여부 스위치 버튼에 대한 값 변경
	function updateIsHR(pCode, pType){
		var now = new Date();
		var isHRValue = $("#IsHR"+pCode).val();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		var sURL = "";
		
		sURL = "/covicore/admin/organization/updateishruser.do";
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"IsHR" : isHRValue,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:sURL,
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_137'/>", "Information Dialog", function(result) {
						if(result) {
							myGrid.reloadList();
						}
					});
			},
			error:function(response, status, error){
				CFN_ErrorAjax(sURL, response, status, error);
			}
		});
	}
	
	// 표시여부 스위치 버튼에 대한 값 변경
	function updateIsDisplay(pCode){
		var now = new Date();
		var isDisplayValue = $("#IsDisplay"+pCode).val();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"IsDisplay" : isDisplayValue,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:"/covicore/admin/organization/updateisdisplaygroup.do",
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_137'/>", "Information Dialog", function(result) {
						if(result) {
							myGrid.reloadList();
						}
					});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/admin/organization/updateisdisplaygroup.do", response, status, error);
			}
		});
	}
	
	// 메일사용여부 스위치 버튼에 대한 값 변경
	function updateIsMail(pCode, pType){
		var now = new Date();
		var isMailValue = $("#IsMail"+pCode).val();
		now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
		
		var sURL = "";
		
		if(pType == "group") {
			sURL = "/covicore/admin/organization/updateismailgroup.do";
		} else {
			sURL = "/covicore/admin/organization/updateismailuser.do";
		}
		
		$.ajax({
			type:"POST",
			data:{
				"Code" : pCode,
				"IsMail" : isMailValue,
				"ModID" : "",				// 세션 값
				"ModDate" : now
			},
			url:sURL,
			success:function (data) {
				if(data.result == "ok")
					Common.Inform("<spring:message code='Cache.msg_137'/>", "Information Dialog", function(result) {
						if(result) {
							myGrid.reloadList();
						}
					});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/admin/organization/updateismailgroup.do", response, status, error);
			}
		});
	}

	function Refresh() {
		myGrid.reloadList();
		/*
		var url = location.href;
		if(url.indexOf("tab_type=group") > -1) {
			url = url.replace("tab_type=group", "tab_type=user");
		} else if(url.indexOf("tab_type=user") > -1) {
			url = url.replace("tab_type=user", "tab_type=group");
		} else {
			url = url.replace('#', '') + "&tab_type=" + tabType;
		}
		
		location.href = url;
		*/
	}
	
	function addOrggroup(){
		var sOpenName = "divgroupInfo";
		var sGR_Code = "";
		var sDN_Code = $.urlParam("domainCode");
		var sMemberOf = $.urlParam("gr_code");
		var sGroupType = $.urlParam("group_type");

		var sURL = "/covicore/groupmanageinfopop.do";
		sURL += "?gr_code=" + sGR_Code;
		sURL += "&domainCode=" + sDN_Code
		sURL += "&memberOf=" + sMemberOf;
		sURL += "&GroupType=" + sGroupType;
		sURL += "&mode=add";
		sURL += "&OpenName=" + sOpenName;
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_OrganizationGroupAdd'/>"  + " ||| " + "<spring:message code='Cache.msg_OrganizationGroupAdd'/>" ;

		var sWidth = "530px";
		var sHeight = "560px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
	
	function deleteOrggroup(){
		var deleteObject = myGrid.getCheckedList(0);
		if(deleteObject.length == 0 || deleteObject == null){
			Common.Inform("<spring:message code='Cache.msg_selectTargetDelete'/>"); 
			return false;
		}else{
			Common.Confirm("<spring:message code='Cache.msg_152'/>", "Confirmation Dialog", function (result) {
				if(result) {
					var deleteSeq = "";
					
					for(var i=0; i < deleteObject.length; i++){
						if(i==0){
							deleteSeq = deleteObject[i].GroupCode;
						}else{
							deleteSeq = deleteSeq + "," + deleteObject[i].GroupCode;
						}
					}
					
					$.ajax({
						type:"POST",
						data:{
							"deleteData" : deleteSeq
						},
						url:"/covicore/admin/organization/deletegroup.do",
						success:function (data) {
							if(data.status == "FAIL") {
								if(data.message.indexOf("|")) Common.Warning(Common.getDic(data.message.split("|")[0]).replace("{0}",data.message.split("|")[1]));
								else Common.Warning(data.message);
							} else {
								Common.Inform("<spring:message code='Cache.msg_138'/>", "Information Dialog", function(result) {
									if(result) {
										myGrid.reloadList();
									}
								});
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/organization/deletegroup.do", response, status, error);
						}
					});
				}
			});
		}
	}
	
	function editOrggroup(pStrGR_Code, pStrGroupType){
		var sOpenName = "divgroupInfo";
		var sGR_Code = pStrGR_Code == undefined ? $.urlParam("gr_code") : pStrGR_Code;
		var sDN_Code = $.urlParam("domainCode");
		var sMemberOf = "";
		var sGroupType = pStrGroupType == undefined ? $.urlParam("group_type") : pStrGroupType;

		var sURL = "/covicore/groupmanageinfopop.do";
		sURL += "?gr_code=" + sGR_Code;
		sURL += "&domainCode=" + sDN_Code
		sURL += "&memberOf=" + sMemberOf;
		sURL += "&GroupType=" + sGroupType;
		sURL += "&mode=modify";
		sURL += "&OpenName=" + sOpenName;
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_OrganizationGroupInfo'/>"  + " ||| " + "<spring:message code='Cache.msg_OrganizationGroupInfo'/>" ;

		var sWidth = "530px";
		var sHeight = "560px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
	
	function addOrgUser(){
		//type=B9 > user만 선택 가능
		Common.open("","orgmap_pop","<spring:message code='Cache.lbl_DeptOrgMap'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B9","1060px","580px","iframe",true,null,null,true);
	}
	
	var _CallBackMethod2 = function(data) { //조직도 콜백함수 구현

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
				"GroupCode" : $.urlParam('gr_code'),
				"URList" : urCodeList,
				"GRList" : grCodeList
			},
			url:"/covicore/admin/organization/addgroupmember.do",
			success:function (data) {
				if(data.status == "FAIL") {
					Common.Warning(data.message);
				} else {
					Common.Inform("<spring:message code='Cache.msg_37'/>", "Information Dialog", function(result) {
						if(result) {
							myGrid.reloadList();
						}
					});
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/admin/organization/addgroupmember.do", response, status, error);
			}
		});
	}
	
	function deleteOrgUser(){
		
		var checkCheckList 		= myGrid.getCheckedList(0);// 체크된 리스트 객체
		var TargetUserTemp 		= []; //체크된 항목 저장용 배열
		var TargetUser 				= ""; //체크된 항목을 문장으로 나열 (A;B; . . ;)
		var TargetGroupTemp 		= []; //체크된 항목 저장용 배열
		var TargetGroup 				= ""; //체크된 항목을 문장으로 나열 (A;B; . . ;)

		if(checkCheckList.length == 0){
			Common.Inform("<spring:message code='Cache.msg_apv_003'/>"); 
			return false;			
		}else if(checkCheckList.length > 0){

			for(var i = 0; i < checkCheckList.length; i++){
				if(checkCheckList[i].Type.toUpperCase() == "USER"){
					TargetUserTemp.push(checkCheckList[i].MemberID);
				} else {
					TargetGroupTemp.push(checkCheckList[i].MemberID);
				}
			}
			
			TargetUser = TargetUserTemp.join(",");
			TargetGroup = TargetGroupTemp.join(",");
			
			Common.Confirm("<spring:message code='Cache.msg_apv_093'/>" , "Inform", function (result) { //삭제하시겠습니까?
				if (result) {
					$.ajax({
						url: "/covicore/admin/orgmanage/deletegroupmember.do",
						type:"post",
						data:{
			 				"TargetUser": TargetUser,
			 				"TargetGroup": TargetGroup
						},
						async:false,
						success:function (res) {
							myGrid.reloadList();
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/orgmanage/deletegroupmember.do", response, status, error);
						}
					});
				}
			}); 
		}else{
			Common.Inform("<spring:message code='Cache.msg_ScriptApprovalError'/>"); 
			return false;
		}
	}
	
	function editOrgUser(pStrUR_Code){
		var sOpenName = "divUserInfo";
		var sUR_Code = pStrUR_Code;
		var sDN_Code = $.urlParam("domainCode");
		
		var sURL = "/covicore/usermanageinfopop.do";
		sURL += "?ur_code=" + sUR_Code
		sURL += "&domainCode=" + sDN_Code;
		sURL += "&mode=modify";
		sURL += "&OpenName=" + sOpenName;
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_OrganizationUserEdit'/>"  + " ||| " + "<spring:message code='Cache.msg_OrganizationUserEdit'/>" ;

		var sWidth = "830px";
		var sHeight = "500px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
	
	/*
	<잔여사항>
	1. 위로, 아래로 - SortKey 값 업데이트로 대체
	2. 이동 - 필요 시 MemberOf 값 업데이트로 대체 가능
	3. 전체 열기, 닫기 
	4. 다국어 처리
	*/
	// 위로 버튼 클릭시 실행되며, 해당 항목을 위로 이동합니다.
    function moveUp(type) {
		
		var checkCheckList = "";
		var gridObj = myGrid;
		/* if(type == "group") {
			gridObj = groupGrid;
		} else if(type == "user") {
			gridObj = userGrid;
		} */
		checkCheckList = gridObj.getCheckedList(0);// 체크된 리스트 객체
		if(checkCheckList.length == 0){
			Common.Inform("<spring:message code='Cache.msg_apv_003'/>"); 
			return false;
		}else if(checkCheckList.length > 0){

	        var sCode_A = 0;
	        var sCode_B = 0;
	
	        var oPrevTR = null;
	        var oNowTR = null;
	
	        var oResult = null;
	        var bSucces = true;
	        var sResult = "";
	        var sErrorMessage = "";
	
	        var nLength = gridObj.list.length;
	        for (var i = 0; i < nLength; i++) {
	        	if (!gridObj.list[i].___checked[0]) {
	                continue;
	            }
	
	            // 현재 행: 위에서부터 선택 되어 있는 행 찾기
	            oNowTR = gridObj.list[i];
	
	            // 이전 행 찾기: 현재 행 기준 위에서 선택 안되어 있는 행 찾기
	            oPrevTR = null;
	            for (var j = i - 1; j >= 0; j--) {
	                if (gridObj.list[j].GroupCode == undefined && gridObj.list[j].UserCode == undefined) {
	                    break;
	                }
	                if (gridObj.list[j].___checked[0]) {
	                    continue;
	                }
	                oPrevTR = gridObj.list[j];
	                break;
	            }
	            if (oPrevTR == null) {
	                continue;
	            }
	            
	            if(oNowTR.SortKey == oPrevTR.SortKey){
	            	Common.Inform("<spring:message code='Cache.msg_ChangePriority'/>"); 
	    			return false;
				}
				
	            if(type == "group") {
		            sCode_A = oNowTR.GroupCode;
		            sCode_B = oPrevTR.GroupCode;
	            } else if(type == "user") {
	            	sCode_A = oNowTR.UserCode;
		            sCode_B = oPrevTR.UserCode;
	            }
	
	            $.ajax({
					url: "/covicore/admin/orgmanage/movesortkey_groupuser.do",
					type:"post",
					data:{
		 				"pStrCode_A":sCode_A,
		 				"pStrCode_B":sCode_B,
		 				"pStrType":type
						},
					async:false,
					success:function (res) {
						gridObj.reloadList();
						//window.location.reload();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/admin/orgmanage/movesortkey_groupuser.do", response, status, error);
					}
				});
			}
	    }
	}
	
	// 아래로 버튼 클릭시 실행되며, 해당 항목을 아래로 이동합니다.
    function moveDown(type) {
		
    	var checkCheckList = "";
		var gridObj = myGrid;
		/* if(type == "group") {
			gridObj = groupGrid;
		} else if(type == "user") {
			gridObj = userGrid;
		} */
		var checkCheckList 		= gridObj.getCheckedList(0);// 체크된 리스트 객체
		if(checkCheckList.length == 0){
			Common.Inform("<spring:message code='Cache.msg_apv_003'/>"); 
			return false;
		}else if(checkCheckList.length > 0){

	        var sCode_A = 0;
	        var sCode_B = 0;
	
	        var oNextTR = null;
	        var oNowTR = null;
	
	        var oResult = null;
	        var bSucces = true;
	        var sResult = "";
	        var sTemp = "";
	        var sErrorMessage = "";
	
	        var nLength = gridObj.list.length;
	        for (var i = nLength-1; i >= 0; i--) {
	        	if (!gridObj.list[i].___checked[0]) {
	                continue;
	            }
	
	         // 현재 행: 아래에서부터 선택되어 있는 행 찾기
	            oNowTR = gridObj.list[i];
	
	         // 다음 행 찾기: 현재 행 기준 아래에서 선택 안되어 있는 행 찾기
	            oNextTR = null;
	            for (var j = i + 1; j < nLength; j++) {
	                if (gridObj.list[j].GroupCode == undefined && gridObj.list[j].UserCode == undefined) {
	                    break;
	                }
	                if (gridObj.list[j].___checked[0]) {
	                    continue;
	                }
	                oNextTR = gridObj.list[j];
	                break;
	            }
	            if (oNextTR == null) {
	                continue;
	            }
	            
	            if(oNowTR.SortKey == oNextTR.SortKey){
	            	Common.Inform("<spring:message code='Cache.msg_ChangePriority'/>"); 
	    			return false;
				}
	
	            if(type == "group") {
		            sCode_A = oNowTR.GroupCode;
		            sCode_B = oNextTR.GroupCode;
	            } else if(type == "user") {
	            	sCode_A = oNowTR.UserCode;
		            sCode_B = oNextTR.UserCode;
	            }
	
	            $.ajax({
					url: "/covicore/admin/orgmanage/movesortkey_groupuser.do",
					type:"post",
					data:{
		 				"pStrCode_A" : sCode_A,
		 				"pStrCode_B" : sCode_B,
		 				"pStrType":type
						},
					async:false,
					success:function (res) {
						gridObj.reloadList();
						//window.location.reload();
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/admin/orgmanage/movesortkey_groupuser.do", response, status, error);
					}
				});
			}
	    }
	}
	
  	//엑셀 다운로드
	function excelDownload(type){
		Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
       		if(result){
       			var headerName = getHeaderNameForExcel(type);
    			var	sortKey = "SortKey";
    			var	sortWay = "ASC";				  	
    			
    			if(setBtnDisplayUser != "none")  
    				type = "groupmember";
    			
    			location.href = "/covicore/admin/orgmanage/orglistexceldownload.do?sortColumn=" + sortKey + "&sortDirection=" + sortWay + "&type=" + type + "&groupCode=" + $.urlParam("gr_code") +"&groupType=" + $.urlParam("group_type") + "&companyCode=" + $.urlParam("domainCode") + "&headerName=" + encodeURI(encodeURIComponent(headerName));
       		}
		});
	}

	//엑셀용 Grid 헤더정보 설정
	function getHeaderNameForExcel(type){
		var msgHeaderData = getGridHeader(type);
		var returnStr = "";
		
	   	for(var i=0;i<msgHeaderData.length; i++){
	   	   	if(msgHeaderData[i].display != false && msgHeaderData[i].label != 'chk'){
				returnStr += msgHeaderData[i].label + ";";
	   	   	}
		}
		
		return returnStr;
	}
	
	//Grid Header 항목 시작
	function getGridHeader( pHeaderType ){
		var headerData;
		switch( pHeaderType ){
			case "group":
				headerData = [
			                  {key:'GroupCode',  label:'<spring:message code="Cache.lbl_grCode"/>', width:'100', align:'center'},
			                  {key:'SortKey',  label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'70', align:'center'},
			                  {key:'DisplayName', label:'<spring:message code="Cache.lbl_grCodeNm"/>', width:'100', align:'center'},
			                  {key:'ShortName',  label:'<spring:message code="Cache.lbl_CompanyShortName"/>', width:'100', align:'center'},
			                  {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>', width:'80', align:'center'},
			                  {key:'IsMail', label:'<spring:message code="Cache.lbl_IsMail"/>',   width:'70', align:'center'},
				      		  {key:'PrimaryMail', label:'<spring:message code="Cache.lbl_Mail"/>', width:'80', align:'center'}
		               ];
				break;
			case "user":
				if(setBtnDisplayUser == "none") {
					headerData = [
				                  {key:'UserCode',  label:'<spring:message code="Cache.lbl_User_Id"/>', width:'90', align:'center'},
				                  {key:'SortKey',  label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'70', align:'center'},
				                  {key:'DisplayName', label:'<spring:message code="Cache.lbl_User"/>', width:'90', align:'center'},
				                  {key:'MultiDisplayName', label:'<spring:message code="Cache.lbl_User"/>(<spring:message code="Cache.lbl_MultiLang2"/>)', width:'90', align:'center'},
				                  {key:'JobTitleCode',  label:'<spring:message code="Cache.lbl_JobTitleCode"/>', width:'70', align:'center'},
				                  {key:'JobTitleName',  label:'<spring:message code="Cache.lbl_JobTitleName"/>', width:'70', align:'center'},
				                  {key:'JobPositionCode',  label:'<spring:message code="Cache.lbl_JobPosition_Code"/>', width:'70', align:'center'},
				                  {key:'JobPositionName',  label:'<spring:message code="Cache.lbl_JobPositionName"/>', width:'70', align:'center'},
				                  {key:'JobLevelCode',  label:'<spring:message code="Cache.lbl_JobLevel_Code"/>', width:'70', align:'center'},
				                  {key:'JobLevelName',  label:'<spring:message code="Cache.lbl_JobLevelName"/>', width:'70', align:'center'},
				                  {key:'IsUse', label:'<spring:message code="Cache.lbl_IsUse"/>', width:'80', align:'center'},
				                  {key:'IsHR', label:'<spring:message code="Cache.lbl_IsHR"/>',  width:'80', align:'center'},
					      		  {key:'MailAddress', label:'<spring:message code="Cache.lbl_Mail"/>', width:'80', align:'center'},
	/* 				      		  {key:'DeptCode', label:'<spring:message code="Cache.lbl_DeptCode"/>', width:'80', align:'center'},
					      		  {key:'DeptName', label:'<spring:message code="Cache.lbl_DeptName"/>', width:'80', align:'center'},
					      		  {key:'MultiDeptName', label:'<spring:message code="Cache.lbl_DeptName"/>(<spring:message code="Cache.lbl_MultiLang2"/>)', width:'80', align:'center'}, */
					      		  {key:'CompanyCode', label:'<spring:message code="Cache.lbl_companyCode"/>', width:'80', align:'center'},
				      	  		  {key:'CompanyName', label:'<spring:message code="Cache.lbl_CompanyName"/>', width:'80', align:'center'},
					      	  	  {key:'MultiCompanyName', label:'<spring:message code="Cache.lbl_CompanyName"/>(<spring:message code="Cache.lbl_MultiLang2"/>)', width:'80', align:'center'}
						    ];
				} else {
					headerData = [
					              {key:'Type',  label:'<spring:message code="Cache.lbl_Gubun"/>', width:'90', align:'center'},
					              {key:'Code', label:'<spring:message code="Cache.lbl_Code"/>', width:'90', align:'center'},
					              {key:'CodeName',  label:'<spring:message code="Cache.lbl_CodeName"/>', width:'70', align:'center'},
					              {key:'MailAddress', label:'<spring:message code="Cache.lbl_Mail"/>', width:'80', align:'center'}
				            ];	  
				}
				break;
		}
		return headerData;
	}
	
	function syncSelectDomain() {
		var selDomainCode = $("#domainCodeSelectBox").val();
		Common.Progress("<spring:message code='Cache.msg_Processing'/>");
		$.post("/covicore/aclhelper/refreshSyncKeyAllByCode.do", {"DomainCode" : selDomainCode}, function(data) {
			Common.AlertClose();
		});
	}
	
	$(document).ready(function () {

		myGrid = new coviGrid();

		//그룹 타입 및 코드에 의한 버튼 display 처리
		setBtnDisplay();
		
		//기초설정에 따른 메일 표기 여부
		if(coviCmn.configMap["IsSyncMail"] == null |  coviCmn.configMap["IsSyncMail"] == 'N'){
			$("#IsMailType").closest('span').css("display","none");
			isMailDisplay = false;
		}

		if(paramTabType != "" && paramTabType != null && paramTabType != undefined) {
			clickTab($("#" + paramTabType + "SetTab"));
		} else {
			setGrid();
			bindGrid();
		}
		
		setNavigationUser();
		if($.urlParam('gr_code') != null && $.urlParam("group_type") != "Company") {
			setNavigationSelect("selCategory");
		} else {
			$("#spnNavigationGroup").closest("p").css("display", "none");
		}
		
	});
	
</script>