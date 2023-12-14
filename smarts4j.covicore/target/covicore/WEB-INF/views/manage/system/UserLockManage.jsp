<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="covi" uri="/WEB-INF/tlds/covi.tld"%>
<div class="cRConTop titType AtnTop">
	<h2 class="title"><spring:message code="Cache.lbl_lockUser"/></h2>	
	<div class="searchBox02">
		<span><input type="text" id="searchText"><button type="button" id="icoSearch" class="btnSearchType01"></button></span>
	</div>
</div>	

<form id="form1">
	<div class='cRContBottom mScrollVH'>
		<div class="sadminContent">
			<div class="sadminMTopCont">
				<div class="pagingType02 buttonStyleBoxLeft">
					<a class="btnTypeDefault"  id="btnUnLock"><spring:message code="Cache.lbl_UnLock"/></a>
					<a class="btnTypeDefault"  id="btnExcel"><spring:message code="Cache.btn_ExcelDownload"/></a>
				</div>
				<div class="buttonStyleBoxRight">
					<select id="selectPageSize" class="selectType02 listCount">
						<option value="10">10</option>
						<option value="20">20</option>
						<option value="30">30</option>
					</select>
					<button class="btnRefresh" type="button" href="#"  id="btnRefresh" ></button>
				</div>
			</div>	
			<div class="tblList tblCont">
				<div id="userLockGrid"></div>
			</div>	
		</div>
		<!-- 승인 의견 레이어 팝업 시작-->
		<div class="layer_divpop" style="width:440px; left:170px; z-index:104;display:none"  id="divWork">
			<div class="divpop_contents">
				<div class="pop_header"><h4 class="divpop_header"><span class="divpop_header_ico"><spring:message code="Cache.lbl_apv_comment_write"/></span></h4><a onclick='$("#divWork").hide()'  class="divpop_close" style="cursor:pointer;"></a></div>
				<div class="divpop_body" style="overflow:hidden; padding:0;">
					<div class="ATMgt_popup_wrap">
						<div class="ATMgt_opinion_wrap">
							<table class="ATMgt_popup_table" cellpadding="0" cellspacing="0">
								<tbody>
									<tr>	
										<td class="ATMgt_T_th"><spring:message code="Cache.lbl_comment"/></td>
										<td><textarea id="Comment" name="Comment" class="ATMgt_Tarea"  cols="30" rows="40"></textarea>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="bottom">
							<a href="#" class="btnTypeDefault  btnTypeBg btnAttAdd" id="btnSaveApproval"><spring:message code="Cache.lbl_UnLock"/></a>
							<a href="#" class="btnTypeDefault" onclick='$("#divWork").hide()'><spring:message code="Cache.btn_Close"/></a>
						</div>
					</div>
				</div>
			</div>
		</div>	
		<!-- 템플릿 선택 레이어 팝업 끝 -->
</form>
<script type="text/javascript">
var confLock = {
	userLockGrid : new coviGrid(),		//게시글 Grid 
	headerData : [{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
					  {key:'UpDeptName', label:'<spring:message code="Cache.lbl_ParentDeptName" />', width:'60', align:'center', sort:false},
					  {key:'DeptName', label:'<spring:message code="Cache.lbl_dept" />', width:'60', align:'left'},
					  {key:'UserCode',  label:'<spring:message code="Cache.lbl_User_Id"/>', width:'90', align:'center', formatter:function () {
								return "<a href='#' onclick='confLock.editOrgUser(\""+ this.item.UserCode + "\", \"" + this.item.DeptCode + "\"); return false;'>"+this.item.UserCode+"</a>";
						  }},
					  {key:'DisplayName', label:'<spring:message code="Cache.lbl_User"/>', width:'90', align:'center'},
					  {key:'JobTitle',  label:'<spring:message code="Cache.lbl_JobTitle"/>', width:'70', align:'center'},
					  {key:'JobPosition',  label:'<spring:message code="Cache.lbl_JobPosition"/>', width:'70', align:'center'},
					  {key:'JobLevel',  label:'<spring:message code="Cache.lbl_JobLevel"/>', width:'70', align:'center'},
					  {key:'login_fail_count',  label:'<spring:message code="Cache.SecurityType_LoginFailCount"/>', width:'40', align:'center'},
					  {key:'password_change_date',  label:'<spring:message code="Cache.lbl_PasswordChange"/>'+ Common.getSession("UR_TimeZoneDisplay"), width:'70', align:'center', 
		              		formatter: function(){
		            			return (this.item.password_change_date);
		            		}},
					  {key:'latest_login_date', label:'<spring:message code="Cache.lbl_LastLogoutTime"/>' , width:'80', align:'center'},
		              {key:'통계보기', label:'<spring:message code="Cache.btn_processingHistory"/>', width:'60', align:'center', sort:false,
					   	  formatter:function () {
					   			return "<a href='javascript:;' class='btnTypeDefault' onclick='confLock.openLockHistoryPop(\"" + this.item.UserCode + "\")'><spring:message code='Cache.btn_processingHistory'/></a>";
							}}			
		            		 ],
	domainID :confMenu.domainId,
	initContent:function (){
		this.userLockGrid.setGridHeader(this.headerData);
		this.userLockGrid.setGridConfig({
			targetID : "userLockGrid",
			height:"auto"
		});
		this.searchGrid();
		
		// 새로고침
		$("#btnRefresh").on('click', function(){
			confLock.searchGrid();
		});
		
		$("#selectPageSize").on('change', function(){
			confLock.searchGrid();
		});
		
		//검색
		$("#searchText").on( 'keydown',function(){
			if(event.keyCode=="13"){
				$('#icoSearch').trigger('click');

			}
		});	
		$("#icoSearch").on( 'click',function(){
			confLock.searchGrid();
		});		
		
		$("#btnExcel").on("click",function(){
			Common.Confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>", "Confirmation Dialog", function(result){
	       		if(result){
	       			location.href = "/covicore/manage/user/excelDown.do?DomainID="+confMenu.domainId+"&searchtext="+$("#searchText").val();	
	       		}
			});
		});
		
		$("#btnUnLock").on( 'click',function(){
			
			var listobj = confLock.userLockGrid.getCheckedList(0);
			if(listobj.length == 0){
				Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>");
				return false;
			}
			$("#Comment").val("");
			$("#divWork").show();
		});
		
		$("#btnSaveApproval").click(function(){
			Common.Confirm("<spring:message code='Cache.msg_166' />", "Confirmation Dialog", function (confirmResult) {
				if (confirmResult) {
					var aJsonArray = new Array();
					var selectObj = confLock.userLockGrid.getCheckedList(0);
					for(var i=0; i<selectObj.length; i++){
                        aJsonArray.push(selectObj[i].UserCode);
					}
					var now = new Date();
					now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now);
					$.ajax({
						type:"POST",
						contentType:'application/json; charset=utf-8',
						dataType   : 'json',
						data:JSON.stringify({"dataList" : aJsonArray  , "ApprovalRemark":$("#Comment").val(),  "ModDate" : now}),
						url:"/covicore/manage/user/saveUserLock.do",
						success:function (data) {
							if(data.status=='SUCCESS'){
								Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>");	//저장되었습니다.
								confLock.searchGrid();
								$("#divWork").hide();
							}else{
			            		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
								$("#divWork").hide();
				            }	
						},
						error:function (request,status,error){
							Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
						}
					});
				}	
			});				
		});
		
		
		$("#userRefresh").on( 'click',function(){
			this.searchGrid();
		});
	//# sourceURL=BaseConfigManage.jsp
	},
	searchGrid:function(){
		var domainID = confMenu.domainId;
		this.userLockGrid.page.pageNo = 1;
		this.userLockGrid.page.pageSize = $("#selectPageSize").val();
		this.userLockGrid.bindGrid({
 			ajaxUrl:"/covicore/manage/user/getUserLock.do",
 			ajaxPars: {
 				"domainID":domainID,
 				"searchText":$("#searchText").val()
 			}
		});

	},
	openLockHistoryPop:function(userCode){
		var url = "/covicore/manage/user/UserLockHistoryPopup.do";
		url += "?domainID=" + confMenu.domainId;
		url += "&UserCode=" + userCode;
		Common.open("","divResourceInfo","<spring:message code='Cache.btn_processingHistory'/>",url,"600px","600px","iframe",false,null,null,true);
	},
	
	// 사용자ID 클릭 팝업.
	editOrgUser : function(pStrUR_Code, pGroupCode) {
		var sOpenName = "divUserInfo";

		var sURL = "/covicore/UserManageInfoPop.do";
		sURL += "?groupCode=" + pGroupCode;
		sURL += "&mode=modify";
		sURL += "&domainId=" + confMenu.domainId;
		sURL += "&userCode=" + pStrUR_Code;
		sURL += "&domainCode=" + confMenu.domainCode;
		sURL += "&OpenName=" + sOpenName;
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_OrganizationUserEdit'/>"  + " ||| " + "<spring:message code='Cache.msg_OrganizationUserEdit'/>" ;
		
		var sWidth = "830px";
		var sHeight = "500px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
	}
}

$(document).ready(function(){
	confLock.initContent();
});

</script>