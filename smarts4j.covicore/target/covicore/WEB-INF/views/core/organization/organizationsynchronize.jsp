<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
	.AXFormTable thead th {
		border: 1px solid #ddd !important;
		background-color: #f7f7f7;
	}
	
	.AXFormTable tbody td, #divMonitering tbody td {
		background-color: #FFFFFF;
	}

	.divpop_overlay {display:none;}
	
	.changed { font-weight: bold; color: red; }
	
	#divCompareGroup table thead tr th, 
	#divCompareGroup table tbody tr td,
	#divCompareUser table thead tr th, 
	#divCompareUser table tbody tr td,
	#divCompareAddjob table thead tr th, 
	#divCompareAddjob table tbody tr td {
	    border: 1px solid #ddd;
	    padding: 2px;
	    text-align: center;
	}
	
	#divCompareGroup table,
	#divCompareUser table,
	#divCompareAddjob table {
	    border-spacing: 0;
	    width: 100%;
	}
</style>

<script type="text/javascript" src="/groupware/resources/script/moment.min.js"></script>
	
<h3 class="con_tit_box">
   <span class="con_tit"><spring:message code='Cache.lbl_OrgSync'/></span>
	<!-- TODO 초기 페이지로 설정 향후 개발 (미구현 사항으로 숨김처리) -->
	<%-- <a href="#" class="set_box">
		<span class="set_initialpage"><p><spring:message code="Cache.btn_SettingFirstPage"/></p></span>
	</a> --%>
</h3>
<form id="form1">
	<div class="AXTabs">
		<div class="AXTabsTray" style="height:30px">
			<a id="agridtest" href="#" onclick="clickTab(this);" class="AXTab on"" value="gridtest"><spring:message code='Cache.lbl_SyncConfig'/></a>
			<a id="aloggridtest" href="#" onclick="clickTab(this);" class="AXTab" value="loggridtest"><spring:message code='Cache.menu_LogManage'/></a>
		</div>
		<div id="gridtest" style="">
			<div id="topitembar" style="width:100%;">
				<div style="width:100%;">
					<div id="topitembar_1" class="topbar_grid">
						<div>
							<!-- 
							<input type="button" value="<spring:message code='Cache.btn_ReadSyncData'/>" onclick="createSyncData();"class="AXButton"/>
							<input type="button" value="<spring:message code='Cache.btn_Synchronization'/>" onclick="synchronize();" class="AXButton" />
							<input type="button" value="<spring:message code='Cache.btn_SynchronizationAll'/>" onclick="synchronizeAll();" class="AXButton" />
							 -->
							<input type="button" value="인사데이터 연동" onclick="createSyncData();"class="AXButton"/>
							<input type="button" value="동기화" onclick="synchronize();" class="AXButton"/>
							<input type="button" value="<spring:message code='Cache.btn_SynchronizationAll'/>" onclick="synchronizeAll();" class="AXButton" />
						</div>
  
						<div style="margin-top: 10px;">
							<!-- <label><spring:message code='Cache.lbl_SyncTarget'/></label> -->
							<label>동기화 범위 설정</label>
							<table class="AXFormTable" style="border-top: 1px solid #dddddd;">
								<thead>
									<tr>
										<!-- 
										<th><spring:message code='Cache.lbl_IsSyncDB'/></th>
										<th><spring:message code='Cache.lbl_IsSyncApproval'/></th>
										<th><spring:message code='Cache.lbl_IsSyncIndi'/></th>
										<th><spring:message code='Cache.lbl_IsSyncTimeSquare'/></th>
										<th><spring:message code='Cache.lbl_IsUseAD'/></th>
										<th><spring:message code='Cache.lbl_IsSyncMail'/></th>
										<th><spring:message code='Cache.lbl_IsSyncMessenger'/></th>
										 -->
										<th style="display: none;">그룹웨어</th>
										<th>CoviMail</th>
										<th>Exchange Mail</th>
										<th>AD</th>
										<th>SFB</th>
									</tr>
								</thead>
								<tbody>
									<tr style="text-align: center;">
										<td style="display: none;"><input type="text" class="swOff" kind="switch" name="" on_value="Y" off_value="N" style="width:50px;height:20px;border:0px none;" id="IsSyncDB" value=""/></td>
										<td><input type="text" class="swOff" kind="switch" name="" on_value="Y" off_value="N" style="width:50px;height:20px;border:0px none;" id="IsSyncIndi" value=""/></td>
										<td><input type="text" class="swOff" kind="switch" name="" on_value="Y" off_value="N" style="width:50px;height:20px;border:0px none;" id="IsSyncMail" value=""/></td>
										<td><input type="text" class="swOff" kind="switch" name="" on_value="Y" off_value="N" style="width:50px;height:20px;border:0px none;" id="IsSyncAD" value=""/></td>
										<td><input type="text" class="swOff" kind="switch" name="" on_value="Y" off_value="N" style="width:50px;height:20px;border:0px none;" id="IsSyncMessenger" value=""/></td>
									</tr>
								</tbody>
							</table>
						</div>
					
						<!-- 조직도 동기화 설정 -->
						<div style="margin-top: 10px;">
							<label>연동 범위 설정</label>
							<!-- <label><spring:message code='Cache.lbl_SyncConfig'/></label> -->
					        <table class="AXFormTable" style="border-top: 1px solid #dddddd;" width="500px;">
								<tbody><tr>
									<th style="width: 145px;">부서</th>
									<td>
										<spring:message code='Cache.lbl_Add'/> :  <input name="chkDept" type="checkbox" value="chkDeptAdd" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_Edit'/> :  <input name="chkDept" type="checkbox" value="chkDeptMod" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_delete'/> :  <input name="chkDept" type="checkbox" value="chkDeptDel" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_Whole'/> :  <input name="chkDept" type="checkbox" value="chkDeptAll" onchange="ctrlChkBox(this,'ALL');" checked/>
									</td>
									<th style="width: 145px;"><spring:message code='Cache.lbl_JobTitle'/></th>
									<td>
										<spring:message code='Cache.lbl_Add'/> :  <input name="chkJobTitle" type="checkbox" value="chkJobTitleAdd" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_Edit'/> :  <input name="chkJobTitle" type="checkbox" value="chkJobTitleMod" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_delete'/> :  <input name="chkJobTitle" type="checkbox" value="chkJobTitleDel" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_Whole'/> :  <input name="chkJobTitle" type="checkbox" value="chkJobTitleAll" onchange="ctrlChkBox(this,'ALL');" checked/>
									</td>
								</tr>
								<tr>
									<th style="width: 145px;"><spring:message code='Cache.lbl_User'/></th>
									<td>
										<spring:message code='Cache.lbl_Add'/> :  <input name="chkUser" type="checkbox" value="chkUserAdd" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_Edit'/> :  <input name="chkUser" type="checkbox" value="chkUserMod" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_delete'/> :  <input name="chkUser" type="checkbox" value="chkUserDel" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_Whole'/> :  <input name="chkUser" type="checkbox" value="chkUserAll" onchange="ctrlChkBox(this,'ALL');" checked/>
									</td>
									<th style="width: 145px;"><spring:message code='Cache.lbl_JobPosition'/></th>
									<td>
										<spring:message code='Cache.lbl_Add'/> :  <input name="chkJobPosition" type="checkbox" value="chkJobPositionAdd" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_Edit'/> :  <input name="chkJobPosition" type="checkbox" value="chkJobPositionMod" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_delete'/> :  <input name="chkJobPosition" type="checkbox" value="chkJobPositionDel" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_Whole'/> :  <input name="chkJobPosition" type="checkbox" value="chkJobPositionAll" onchange="ctrlChkBox(this,'ALL');" checked/>
									</td>
								</tr>
								<tr>
									<th style="width: 145px;"><spring:message code='Cache.lbl_AddJob'/></th>
									<td>
										<spring:message code='Cache.lbl_Add'/> :  <input name="chkAddJob" type="checkbox" value="chkAddJobAdd" onchange="ctrlChkBox(this,'ONE');" checked />
										<!-- <spring:message code='Cache.lbl_Edit'/> :  <input name="chkAddJob" type="checkbox" value="chkAddJobMod" checked /> -->
										<spring:message code='Cache.lbl_delete'/> :  <input name="chkAddJob" type="checkbox" value="chkAddJobDel" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_Whole'/> :  <input name="chkAddJob" type="checkbox" value="chkAddJobAll" onchange="ctrlChkBox(this,'ALL');" checked />
									</td>
									<th style="width: 145px;"><spring:message code='Cache.lbl_JobLevel'/></th>
									<td>
										<spring:message code='Cache.lbl_Add'/> :  <input name="chkJobLevel" type="checkbox" value="chkJobLevelAdd" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_Edit'/> :  <input name="chkJobLevel" type="checkbox" value="chkJobLevelMod" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_delete'/> :  <input name="chkJobLevel" type="checkbox" value="chkJobLevelDel" onchange="ctrlChkBox(this,'ONE');" checked />
										<spring:message code='Cache.lbl_Whole'/> :  <input name="chkJobLevel" type="checkbox" value="chkJobLevelAll" onchange="ctrlChkBox(this,'ALL');" checked/>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
					<div class="AXTabsTray" style="height: 30px; margin-top: 10px;">
						<a id="asyncHistory" href="#" onclick="clickInnerTab(this);" class="AXTab on" data-role="inner" value="syncHistory">동기화 이력 조회</a>
						<a id="asyncTargetList" href="#" onclick="clickInnerTab(this);" class="AXTab" data-role="inner" value="syncTargetList">동기화 대상 조회</a>
					</div>
					<div id="divMonitering"></div>
				</div>
			</div>
		</div>
	</div>
		
	<div id="loggridtest" style="height:1000px; display:none;" >
		<div style="padding:10px;height:1000px;">
			<div id="topitembar_1" class="topbar_grid">
				<input type="button" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="refresh();"class="AXButton BtnRefresh"/>					
				&nbsp;&nbsp;<spring:message code='Cache.lbl_SearchByDate'/>&nbsp;&nbsp;
				<input type="text" class="AXInput adDate" id="txtFirstDate" date_separator="." kind="date" data-axbind="date" vali_early="true" vali_date_id="txtLastDate" onchange="changeLogTitleList(this.value,'');">
				&nbsp;~&nbsp;
				<input type="text" class="AXInput adDate" id="txtLastDate" date_separator="." kind="date" data-axbind="date"  vali_late="true" vali_date_id="txtFirstDate" onchange="changeLogTitleList('',this.value);">
			</div>	
			<div id="resultBoxWrap">
				<div id="orgLogListGrid"></div>
			</div>
		</div>
	</div>
</form>


<script type="text/javascript">	
	var _syncStart = false;
	var _syncStop = false;
	var _syncErrorStop = false;
	var _lastSyncMasterID = 0;
	var orgLogListGrid = new coviGrid();
	
	// 개별호출 일괄처리
	Common.getBaseConfigList(["IsSyncDB", "IsSyncApproval", "IsSyncIndi", "IsSyncTimeSquare", "IsSyncAD", "IsSyncMail", "IsSyncMessenger"]);
	var _UserCols = ['LogonID','EmpNo','DisplayName','CompanyCode','DeptCode','JobTitleCode','JobPositionCode','JobLevelCode','RegionCode','SortKey','IsDisplay','EnterDate','RetireDate','BirthDiv','BirthDate','MailAddress','ExternalMailAddress','ChargeBusiness','PhoneNumberInter','PhoneNumber','Mobile','Fax','Reserved1','Reserved2','Reserved3','Reserved4','Reserved5'];
	var _GroupCols = ['CompanyCode','GroupType','MemberOf','DisplayName','MultiDisplayName','SortKey','IsDisplay','IsMail','PrimaryMail','SecondaryMail','ManagerCode','Reserved1','Reserved2','Reserved3','Reserved4','Reserved5'];
	var _AddJobCols = ['CompanyCode','DeptCode','JobTitleCode','JobPositionCode','JobLevelCode','RegionCode','SortKey','Reserved1','Reserved2','Reserved3','Reserved4','Reserved5'];
	var _tempTableCompareUser='';
	var _tempTableCompareGroup='';
	var _tempTableCompareAddJob='';
	function makeTemplate(){
		
		$(_UserCols).each(function(idx, item) {
			_tempTableCompareUser += '<th>'+item+'</th>';
		});
		$(_GroupCols).each(function(idx, item) {
			_tempTableCompareGroup += '<th>'+item+'</th>';
		});
		$(_AddJobCols).each(function(idx, item) {
			_tempTableCompareAddJob += '<th>'+item+'</th>';
		});
		
		
		_tempTableCompareUser	= '<table style="white-space: nowrap;">'
								+ 	'<thead>'	
								+ 		'<tr>'		
								+ 			'<th><input type="checkbox" onclick="CheckAll(this, \'User\')"></th>'			
								+ 			'<th><a href="javascript:DeleteSyncPreDataItem(\'User\',\'chk\');" title="Remove"><font color="red">Remove Multi</font></a></th>'			
								+ 			'<th>SyncType</th>'			
								+ 			'<th>UserCode</th>'			
								+ 			_tempTableCompareUser
								+ 		'</tr>'		
								+ 	'</thead>'	
								+ 	'<tbody></tbody>'	
								+ '</table>'
								;
						
				
		_tempTableCompareGroup	= '<table style="white-space: nowrap;">'
								+ 	'<thead>'	
								+ 		'<tr>'		
								+ 			'<th><input type="checkbox" onclick="CheckAll(this, \'Group\')"></th>'			
								+ 			'<th><a href="javascript:DeleteSyncPreDataItem(\'Group\',\'chk\');" title="Remove"><font color="red">Remove Multi</font></a></th>'			
								+ 			'<th>SyncType</th>'			
								+ 			'<th>GroupCode</th>'			
								+ 			_tempTableCompareGroup
								+ 		'</tr>'		
								+ 	'</thead>'	
								+ 	'<tbody></tbody>'	
								+ '</table>'
								;
								
		_tempTableCompareAddJob	= '<table style="white-space: nowrap;">'
								+ 	'<thead>'	
								+ 		'<tr>'		
								+ 			'<th><input type="checkbox" onclick="CheckAll(this, \'Addjob\')"></th>'			
								+ 			'<th><a href="javascript:DeleteSyncPreDataItem(\'Addjob\',\'chk\');" title="Remove"><font color="red">Remove Multi</font></a></th>'			
								+ 			'<th>SyncType</th>'			
								+ 			'<th>UserCode</th>'				
								+ 			'<th>JobType</th>'			
								+ 			_tempTableCompareAddJob
								+ 		'</tr>'		
								+ 	'</thead>'	
								+ 	'<tbody></tbody>'	
								+ '</table>'
								;
	}
	$(document).ready(function(){
		$.ajaxSetup({
		    beforeSend: function (xhr){
		       var overlay = $('<div id="dupe_overlay" class="divpop_overlay" style="display:none;position:fixed;z-index:100;top:0px;left:0px;width:100%;height:100%;background:rgb(0,0,0);opacity:0;"></div>');
		       overlay.appendTo(document.body);
		    },
		    complete : function(xhr){
		    	$('#dupe_overlay').remove();
		    	$(".divpop_overlay").remove();
		    }
		});
		makeTemplate();
		setSyncConfig();
		coviInput.setSwitch();		// oviInput.init(); 이 2.5초 지연 실행되도록 되어있음. CommonControls.js, 스위치 변환 스크립트 바로 실행
		showSyncHistory();
	});	
	
	function refresh(){
		orgLogListGrid.reloadList();
	}
	
	function setSyncConfig() {
		if (coviCmn.configMap["IsSyncDB"] == null | coviCmn.configMap["IsSyncDB"] == '' |  coviCmn.configMap["IsSyncDB"] == 'N'){ $("#IsSyncDB").val("N").prop("selected", true); } 
		else { $("#IsSyncDB").val("Y").prop("selected", true); }
			
		if (coviCmn.configMap["IsSyncIndi"] == null | coviCmn.configMap["IsSyncIndi"] == '' |  coviCmn.configMap["IsSyncIndi"] == 'N'){ $("#IsSyncIndi").val("N").prop("selected", true); } 
		else { $("#IsSyncIndi").val("Y").prop("selected", true); }
		
		if (coviCmn.configMap["IsSyncAD"] == null | coviCmn.configMap["IsSyncAD"] == '' |  coviCmn.configMap["IsSyncAD"] == 'N'){ $("#IsSyncAD").val("N").prop("selected", true); }
		else { $("#IsSyncAD").val("Y").prop("selected", true); }
		
		if (coviCmn.configMap["IsSyncMail"] == null | coviCmn.configMap["IsSyncMail"] == '' |  coviCmn.configMap["IsSyncMail"] == 'N'){ $("#IsSyncMail").val("N").prop("selected", true); }
		else { $("#IsSyncMail").val("Y").prop("selected", true); }
		
		if (coviCmn.configMap["IsSyncMessenger"] == null | coviCmn.configMap["IsSyncMessenger"] == '' |  coviCmn.configMap["IsSyncMessenger"] == 'N'){ $("#IsSyncMessenger").val("N").prop("selected", true); }
		else { $("#IsSyncMessenger").val("Y").prop("selected", true); }
	}
	
	function ctrlChkBox(obj, type) {
        if (type == "ALL") {
            if ($(obj).prop("checked"))
                $(obj).parent().find('input[type=checkbox]').prop("checked", true);
            else
                $(obj).parent().find('input[type=checkbox]').prop("checked", false);
        }
        else if (type == "ONE") {
        	if ($(obj).prop("checked")) {
        		if ($(obj).parent().find('input[type=checkbox]:not(:checked)').not(':last').length == 0)
        			$(obj).parent().find('input[type=checkbox]').last().prop("checked", true);
        	}
        	else {
        		$(obj).parent().find('input[type=checkbox]').last().prop("checked", false);
        	}
        }
    }
	
	// 인사데이터 읽어오기
	function createSyncData(){
		Common.Confirm("<spring:message code='Cache.msg_153'/>", "Confirmation Dialog", function (result) { 
			if(result) {
				$.ajax({
					url: "/covicore/admin/orgmanage/createsyncdata.do",
					type: "POST",
					data: { Web: "Y" },
					success: function(d) {
						console.info(d);
						if(d.status == "SUCCESS") {
							$("#asyncTargetList").click();
							Common.Inform("인사데이터를 가져오는 데 성공하였습니다. \n [그룹 : " + d.compareList.compareGroupCnt + " 건][사용자 : " + d.compareList.compareUserCnt + " 건][겸직 : " + d.compareList.compareAddJobCnt + "] 건"); 
						} 
						else {
							Common.Warning(d.message, "Warning");				
						}				
					},
					error: function(response, status, error) {			
						var err = new Function ("return (" + response.responseText + ")").apply();	
						Common.Error("[ERROR] - createSyncData:" + err.Message);
					}
				});
			}
		});
	}
	
	// 인사데이터 동기화
	function synchronize(){		
		Common.Confirm("<spring:message code='Cache.msg_154'/>", "Confirmation Dialog", function (result) {
			if(result) {
				var sChkBoxConfig = "";
				$('input[type="checkbox"]:checked').each(function () {
					sChkBoxConfig += $(this).val() + ";";
				});
				
				setTimeout(function() { 
					if (!_syncStart) _lastSyncMasterID = 0;
					_syncStart = true;
					moniterCompareCount();
			    	 
			    	 $.ajax({
							url: "/covicore/admin/orgmanage/synchronizeByweb.do",
							data: {
								sChkBoxConfig: sChkBoxConfig,
								IsSyncDB: $("#IsSyncDB").val(),
								IsSyncIndi: $("#IsSyncIndi").val(),
								IsSyncAD: $("#IsSyncApproval").val(),
								IsSyncMail: $("#IsSyncMail").val(),
								IsSyncMessenger: $("#IsSyncMessenger").val(),
							},
							type: "POST",
							success: function(d) {
								_syncStart = false;
								if(d.status == "SUCCESS") {						
									Common.Inform(d.status, "Inform", function() {
										parent.Refresh();
										Common.Close();
									});
								} 
								else {
									if(d.isStopped == "N") {
										_syncErrorStop=true;
										Common.Warning(d.message, "Warning", function() {
											parent.Refresh();
											Common.Close();
										});
									}
									else {
										_syncErrorStop=false;
										_syncStop = true;
									}
								}
							},
							error:function(response, status, error){
								_syncStart = false;
								CFN_ErrorAjax("/covicore/admin/orgmanage/synchronize.do", response, status, error);
							}
						});
			    }, 1000);
			}
		});
	}
	
	// 동기화 일시중지
	function stopSync() {
		if(_syncStart){
			$.ajax({
				url: "/covicore/admin/orgmanage/stopSync.do",
				data: {},
				type: "POST",
				success: function(d) {},
				error: function(response, status, error) {}
			});
		}
	} 
	
	// 동기화 대상 잔여건수 표시 
	function moniterCompareCount(){
		if(_syncStart){
			$.ajax({
				url: "/covicore/admin/orgmanage/MoniterSyncStatus.do",
				type: "POST",
				success: function(d) {
					if(d.status == "SUCCESS") {
						if (d.SyncMasterID == _lastSyncMasterID && _lastSyncMasterID != 0){
							Common.Progress("동기화 처리대상 잔여건 \n [그룹 : " + d.GR_Cnt +" 건][사용자 : " + d.UR_Cnt +" 건][겸직 : " + d.Add_Cnt +" 건]<br><button class=\"AXButton\" onclick=\"javascript:stopSync();\">동기화 중지</button>");
							showSyncHistory();
							
							setTimeout(function() { moniterCompareCount(); }, 3000);
						}
						else {
							showSyncHistory();
							setTimeout(function() { moniterCompareCount(); }, 1000);
						}
					}
					else {
						Common.Warning("동기화 처리건을 가져오는데 실패하였습니다. \n" + d.message);					
					}				
				},
				error: function(response, status, error) {				
					var err =new Function ("return (" + response.responseText + ")").apply();	
					Common.Error("[ERROR] - createSyncData:" + err.Message);				}
			});
		}
		else {
			if (_syncStop) {
				Common.Inform("동기화가 중단되었습니다.");
				_syncStop = false;
			}
			else if (_syncErrorStop) {
				_syncErrorStop=false;
			}
			else {
				Common.Inform("동기화가 종료되었습니다.");
			}
			
			showSyncHistory();
		}		
	}
	
	// 전체 동기화
	function synchronizeAll() {
		Common.Confirm("<spring:message code='Cache.msg_157'/>", "Confirmation Dialog", function (result) { 
			if(result) {
				setTimeout(function() {
					if (!_syncStart) _lastSyncMasterID = 0;
					_syncStart = true;
					moniterCompareCount();

					$.ajax({
						url: "/covicore/admin/orgmanage/organizationsynchronize.do",
						data: {},
						type: "POST",
						success: function(d) {
							console.info('synchronizeAll', d);	
							_syncStart = false;
							if(d.status == "SUCCESS") {						
								Common.Inform(d.status, "Inform", function() {
									Common.Close();
								});
							} 
							else {
								if(d.isStopped == "N") {
									_syncErrorStop=true;
									Common.Warning(d.message, "Warning", function() {
										Common.Close();
									});
								}
								else {
									_syncErrorStop=false;
									_syncStop = true;
								}
							}
						},
						error: function(response, status, error) {
							CFN_ErrorAjax("/covicore/admin/orgmanage/organizationsynchronize.do", response, status, error);
							_syncStart = false;
						}
					});
				}, 1000);
			}
		});
	}
	
	function clickTab(pObj) {
		$(".AXTab[data-role!=inner]").attr("class","AXTab");
		$(pObj).addClass("AXTab on");

		var str = $(pObj).attr("value");
		$(".AXTab[data-role!=inner]").each(function() {
			if ($(this).attr("class") == "AXTab on") {
				$("#" + $(this).attr("value")).show();
				setLogGridConfig();
			}
			else {
				$("#" + $(this).attr("value")).hide();
			}
		});
	}
	
	function clickInnerTab(target) {
		$(".AXTab[data-role=inner]").attr("class","AXTab");
		$(target).addClass("AXTab on");

		$(".AXTab[data-role=inner]").each(function() {
			if ($(this).attr("class") == "AXTab on") {
				$("#" + $(this).attr("value")).show();
			} else {
				$("#" + $(this).attr("value")).hide();
			}
		});
		
		var str = $(target).attr("value");
		if (str == 'syncTargetList') {
			showCompareList();
		}
		else if (str == 'syncHistory') {
			showSyncHistory();
		}
	}
	
	//Grid 관련 사항 추가 -
	function setLogGridConfig() {
		setLogListGrid();
		
		var configObj = {
			targetID: "orgLogListGrid", // grid target 지정
			height: "auto",
			page: {
				pageNo: 1,
				pageSize: 15
			},
			paging: true
		};
		
		// Grid Config 적용
		orgLogListGrid.setGridConfig(configObj);
		
		bindLogListGridData();
	}
	
	//Grid 생성 관련	
	function setLogListGrid(){
		orgLogListGrid.setGridHeader([
			{key:'SyncMasterID', label:'SyncID', width:'20',  align:'center', formatter : function(){
				return "<a href='#' onclick='viewLogList(\""+this.item.SyncMasterID+"\",\"GR\",\"INSERT\", \"" + this.item.InsertDate + "\"); return false;'><span name='code'>" + this.item.SyncMasterID + "</span></a>";
			}},
			{key:'GRInsertCnt', label:'그룹추가', width:'20', align:'center', formatter : function(){
				return "<a href='#' onclick='viewLogList(\""+this.item.SyncMasterID+"\",\"GR\",\"INSERT\", \"" + this.item.InsertDate + "\"); return false;'><span name='code'>" + this.item.GRInsertCnt + " 건</span></a>";
			}}, 
			{key:'GRUpdateCnt', label:'그룹수정', width:'20', align:'center', formatter : function(){
				return "<a href='#' onclick='viewLogList(\""+this.item.SyncMasterID+"\",\"GR\",\"UPDATE\", \"" + this.item.InsertDate + "\"); return false;'><span name='code'>" + this.item.GRUpdateCnt + " 건</span></a>";
			}}, 
			{key:'GRDeleteCnt', label:'그룹삭제', width:'20', align:'center', formatter : function(){
				return "<a href='#' onclick='viewLogList(\""+this.item.SyncMasterID+"\",\"GR\",\"DELETE\", \"" + this.item.InsertDate + "\"); return false;'><span name='code'>" + this.item.GRDeleteCnt + " 건</span></a>";
			}}, 
			{key:'URInsertCnt', label:'사용자추가', width:'20', align:'center', formatter : function(){
				return "<a href='#' onclick='viewLogList(\""+this.item.SyncMasterID+"\",\"UR\",\"INSERT\", \"" + this.item.InsertDate + "\"); return false;'><span name='code'>" + this.item.URInsertCnt + " 건</span></a>";
			}}, 
			{key:'URUpdateCnt', label:'사용자수정', width:'20', align:'center', formatter : function(){
				return "<a href='#' onclick='viewLogList(\""+this.item.SyncMasterID+"\",\"UR\",\"UPDATE\", \"" + this.item.InsertDate + "\"); return false;'><span name='code'>" + this.item.URUpdateCnt + " 건</span></a>";
			}}, 
			{key:'URDeleteCnt', label:'사용자삭제', width:'20', align:'center', formatter : function(){
				return "<a href='#' onclick='viewLogList(\""+this.item.SyncMasterID+"\",\"UR\",\"DELETE\", \"" + this.item.InsertDate + "\"); return false;'><span name='code'>" + this.item.URDeleteCnt + " 건</span></a>";
			}}, 
			{key:'AddJobInsertCnt', label:'겸직추가', width:'20', align:'center', formatter : function(){
				return "<a href='#' onclick='viewLogList(\""+this.item.SyncMasterID+"\",\"AddJob\",\"INSERT\", \"" + this.item.InsertDate + "\"); return false;'><span name='code'>" + this.item.AddJobInsertCnt + " 건</span></a>";
			}}, 
			{key:'AddJobUpdateCnt', label:'겸직수정', width:'20', align:'center', formatter : function(){
				return "<a href='#' onclick='viewLogList(\""+this.item.SyncMasterID+"\",\"AddJob\",\"UPDATE\", \"" + this.item.InsertDate + "\"); return false;'><span name='code'>" + this.item.AddJobUpdateCnt + " 건</span></a>";
			}}, 
			{key:'AddJobDeleteCnt', label:'겸직삭제', width:'20', align:'center', formatter : function(){
				return "<a href='#' onclick='viewLogList(\""+this.item.SyncMasterID+"\",\"AddJob\",\"DELETE\", \"" + this.item.InsertDate + "\"); return false;'><span name='code'>" + this.item.AddJobDeleteCnt + " 건</span></a>";
			}},  
			{key:'InsertDate', label:'일자', width:'50', align:'center', formatter : function(){
				return "<span name='code'>" + CFN_TransLocalTime(this.item.InsertDate) + "</span>";
			}}
		]);
	}
	
	function bindLogListGridData(pFirstDate, pLastDate) {	
		var ty = "one";
		orgLogListGrid.bindGrid({	
			ajaxUrl:"/covicore/admin/orgmanage/getTitleLogList.do",
			ajaxPars: {
				FirstDate: pFirstDate,
				LastDate: pLastDate,
				sortBy: orgLogListGrid.getSortParam(ty)
			}
		});		
	}
	
	function changeLogTitleList(pFirstDate, pLastDate) {
		var strFirstDate = pFirstDate;
		var strLastDate = pLastDate;
		
		if(pFirstDate == '') {
			strFirstDate = $("#txtFirstDate").val();
		}
		
		if(pLastDate == '') {
			strLastDate = $("#txtLastDate").val();
		}
	
		bindLogListGridData(strFirstDate, strLastDate);
	}
	
	function viewLogList(pStrSyncMasterID,pStrObjectType,pStrSyncType, pStrInsertDate) {
		var sOpenName = "divLogList";

		var sURL = "/covicore/loglistpop.do";
		sURL += "?ObjectType=" + pStrObjectType;
		sURL += "&SyncType=" + pStrSyncType;
		sURL += "&SyncMasterID=" + pStrSyncMasterID;		
		sURL += "&InsertDate=" + pStrInsertDate;
		sURL += "&OpenName=" + sOpenName;
		
		var sTitle = "";
		sTitle = "<spring:message code='Cache.lbl_LogList'/>" + " ||| " + "<spring:message code='Cache.lbl_PrintLogList'/>";

		var sWidth = "1000px";
		var sHeight = "680px";
		Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);		
	}
	
	// 동기화 이력 조회
	function showSyncHistory() {
		$.ajax({
			async: true,
			type: "POST",
			data: { Cnt: 20 },
			url: "/covicore/admin/orgmanage/selectSyncHitory.do",
			success: function(data) {
				if (data.status == "FAIL") {
					Common.Error(data.message);
					return;
				}
				
				var varIdx = 0
				var varLastLog = 0;
				var strContent = "<table style=\"width: 100%; margin-top: 10px; border-spacing: 0; display: block; height: 430px; overflow: hidden;\"><tr><td style='vertical-align: top; width: 550px; height: 420px;'><ui id='log_list'>";
				
				$(data.list).each(function(idx, obj) {
					if (idx == 0) { _lastSyncMasterID = obj.SyncMasterID; }
					strContent += "<li id=\"log_"+obj.SyncMasterID+"\" onclick=\"javascript:showSyncItemLog(\'tdItemLogList\',\'" + obj.SyncMasterID + "');\" style=\" padding: 0 5px;\">"; 
					if(varLastLog == 0) {
						varLastLog = obj.SyncMasterID;
					}
					var x = new moment(obj.StartDate);
					var y = new moment(obj.EndDate);
					var dif = y.diff(x, 'seconds');
					var difstr = (isNaN(dif)) ? ((_syncStart) ? ' (처리중) ' : ' (중단) ') : " ("+ dif+"s) ";
					
					strContent += "<strong>" + obj.SyncMasterID + ".</strong> ";
					strContent += obj.StartDate + difstr;
					strContent += " 그룹(" + Number(Number(obj.GRInsertCnt)+Number(obj.GRUpdateCnt)+Number(obj.GRDeleteCnt)) +"), ";
					strContent += " 사용자(" + Number(Number(obj.URInsertCnt)+Number(obj.URUpdateCnt)+Number(obj.URDeleteCnt)) +"), ";
					strContent += " 겸직(" + Number(Number(obj.AddJobInsertCnt)+Number(obj.AddJobUpdateCnt)+Number(obj.AddJobDeleteCnt)) +"), ";
					strContent += "</li>";
				});
				strContent += "</ui></td><td id='tdItemLogList' style='vertical-align:top; width: 1000px; padding: 5px; background-color: #d0d0d0;'></td></tr></table>";
				$("#divMonitering").html(strContent);
				// 최종로그 조회
				showSyncItemLog("tdItemLogList", varLastLog);
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("/covicore/admin/orgmanage/selectSyncHitory.do", response, status, error);
			}
		});
	}
	
	// 동기화 실행 회차별 로그 조회 
	function showSyncItemLog(pTarget, pSyncMasterID){
		$("#log_list li").css("background-color", "white");
		$("#log_"+pSyncMasterID).css("background-color", "#d0d0d0");
		
		$.ajax({
			async : false,
			type : "POST",
			data : { "SyncMasterID" : pSyncMasterID },
			url : "/covicore/admin/orgmanage/selectSyncItemLog.do",
			success : function(data) {
				if (data.status == "FAIL") {
					Common.Error(data.message);
					return;
				}
				
				var varIdx = 0
				var varLastLog = 0;
				var strContent = "";
				strContent += '<table style="width: 100%">';
				strContent += '<tbody style="display: block; max-height: 420px; overflow-y: auto;">';
				$(data.list).each(function(idx, obj) {
					strContent += '<tr>';
					strContent += '<td style="width: 50px; background-color: transparent; vertical-align: top;"><strong>' + obj.Seq + '.</strong></td>';
					strContent += '<td style="width: 50px; background-color: transparent; vertical-align: top;">' + ((obj.LogType == 'Error') ? '<span style="color: red; font-weight: bold;">' : '') + obj.LogType + ((obj.LogType == 'Error') ? '</span>' : '') + '</td>';
					strContent += '<td style="background-color: transparent;">' + obj.LogMessage + '</td>';
					strContent += '</tr>';
				});
				strContent += '</tbody>';
				strContent += '</table>';
				$("#"+pTarget).html(strContent);
				window.scrollTo(0,document.body.scrollHeight); 
				$("#tdItemLogList table tbody").scrollTop($("#tdItemLogList table tbody")[0].scrollHeight);
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("/covicore/admin/orgmanage/selectSyncItemLog.do", response, status, error);
			}
		});
	}
	
	function showCompareList(){
		$("#divMonitering").html("");
		$("#divMonitering").append(
			"<div id=\"divCompareGroup\" style=\"width: 100%; overflow-x: auto;\"></div>"+
			"<div style=\"border: 1px dashed gray; margin: 10px 0;\"></div>"+
			"<div id=\"divCompareUser\" style=\"width: 100%; overflow-x: auto;\"></div>"+
			"<div style=\"border: 1px dashed gray; margin: 10px 0;\"></div>"+
			"<div id=\"divCompareAddjob\"></div>"
		);
		
		showCompareGroupList();
		showCompareUserList();
		showCompareAddjobList();
	}
	
	function showCompareGroupList(){
		$("#divMonitering #divCompareGroup").html('');
		$("#divMonitering #divCompareGroup").append(_tempTableCompareGroup);
		$.ajax({
			async: true,
			type: "POST",
			url: "/covicore/admin/orgmanage/selectCompareList.do",
			data: { type: 'Group' },
			success: function(data) {
				if (data.status == "FAIL") {
					Common.Error(data.message);
					return;
				}
				var bChange = false;
				$("#divMonitering #divCompareGroup").prepend("<span><b>Group ("+data.list.length+")</b></span>");
				$(data.list).each(function(idx, obj) {
					var strContent = "<tr id='trGroup_"+obj.GroupCode+"'><td><input type=\"checkbox\" name='chkGroupItem'/ code='"+obj.GroupCode+"'></td>";
					strContent += "<td><b>" + (idx+1) + "-<a href=\"javascript:DeleteSyncPreDataItem('Group','"+(obj.GroupCode)+"');\" title=\"Remove\"><font color=\"red\">Remove</font></a></b></td>";
					strContent += "<td>" + obj.SyncType + "</td>";
					strContent += "<td>" + obj.GroupCode + "</td>";
					$(_GroupCols).each(function(idx2, colName) {
						bChange = (obj.SyncType == 'UPDATE' && obj[colName]!= obj[colName+"_Before"])?true:false; 
						strContent += "<td>" + (bChange ? ("<span class=\"changed\">"+obj[colName+"_Before"]+" -> ") : "")+ obj[colName]+ (bChange ? "</span>" : "") + "</td>";
					});
					strContent+="</tr>";
					$("#divMonitering #divCompareGroup table tbody").append(strContent);
				});
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("/covicore/admin/orgmanage/selectCompareList.do", response, status, error);
			}
		});
	}
	
	function showCompareUserList(){
		$("#divMonitering #divCompareUser").html('');
		$("#divMonitering #divCompareUser").append(_tempTableCompareUser);
		$.ajax({
			async: true,
			type: "POST",
			url: "/covicore/admin/orgmanage/selectCompareList.do",
			data: { type: 'User' },
			success: function(data) {
				if (data.status == "FAIL") {
					Common.Error(data.message);
					return;
				}
				var bChange = false;
				$("#divMonitering #divCompareUser").prepend("<span><b>User ("+data.list.length+")</b></span>");
				$(data.list).each(function(idx, obj) {
					var strContent = "<tr id='trUser_"+obj.UserCode+"'><td><input type=\"checkbox\" name='chkUserItem'/ code='"+obj.UserCode+"'></td>";
					strContent += "<td><b>" + (idx+1) + "-<a href=\"javascript:DeleteSyncPreDataItem('User','"+(obj.UserCode)+"');\" title=\"Remove\"><font color=\"red\">Remove</font></a></b></td>";
					strContent += "<td>" + obj.SyncType + "</td>";
					strContent += "<td>" + obj.UserCode + "</td>";
					$(_UserCols).each(function(idx2, colName) {
						bChange = (obj.SyncType == 'UPDATE' && obj[colName]!= obj[colName+"_Before"])?true:false; 
						strContent += "<td>" + (bChange ? ("<span class=\"changed\">"+obj[colName+"_Before"]+" -> ") : "")+ obj[colName]+ (bChange ? "</span>" : "") + "</td>";
					});
					strContent+="</tr>";
					$("#divMonitering #divCompareUser table tbody").append(strContent);
				});
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("/covicore/admin/orgmanage/selectCompareList.do", response, status, error);
			}
		});
	}
	
	function showCompareAddjobList(){
		$("#divMonitering #divCompareAddjob").html('');
		$("#divMonitering #divCompareAddjob").append(_tempTableCompareAddJob);

		$.ajax({
			async: true,
			type: "POST",
			url: "/covicore/admin/orgmanage/selectCompareList.do",
			data: { type: 'Addjob' },
			success: function(data) {
				if (data.status == "FAIL") {
					Common.Error(data.message);
					return;
				}
				var bChange = false;
				$("#divMonitering #divCompareAddjob").prepend("<span><b>AddJob ("+data.list.length+")</b></span>");
				$(data.list).each(function(idx, obj) {
					var strContent = "<tr id='trAddjob_"+obj.Seq+"'><td><input type=\"checkbox\" name='chkAddjobItem'/ code='"+obj.Seq+"'></td>";
					strContent += "<td><b>" + (idx+1) + "-<a href=\"javascript:DeleteSyncPreDataItem('Addjob','"+(obj.Seq)+"');\" title=\"Remove\"><font color=\"red\">Remove</font></a></b></td>";
					strContent += "<td>" + obj.SyncType + "</td>";
					strContent += "<td>" + obj.UserCode + "</td>";
					strContent += "<td>" + obj.JobType + "</td>";
					$(_AddJobCols).each(function(idx2, colName) {
						strContent += "<td>" + obj[colName] + "</td>";
					});
					strContent+="</tr>";
					$("#divMonitering #divCompareAddjob table tbody").append(strContent);
				});
			},
			error : function(response, status, error) {
				CFN_ErrorAjax("/covicore/admin/orgmanage/selectCompareList.do", response, status, error);
			}
		});
	}
	 // 동기화 전 데이터 Item 삭제
    function DeleteSyncPreDataItem(pSyncType,pCode) {
        var CodeList = "";
		if (pCode == "chk") {
			if($("[name='chk" + pSyncType + "Item']:checked").length==0)
			{
		        Common.Inform("<spring:message code='Cache.msg_apv_003'/>");
		        return;
			}
			
		    $("[name='chk" + pSyncType + "Item']:checked").each(function (i, e) {
				if (CodeList != "") {
					CodeList += ";" + $(this).attr("Code");
				} else {
					CodeList = $(this).attr("Code");
				}
		    });
		}
        if (CodeList != "") {
            Common.Confirm((CodeList.split(";").length) + " Items - " + "<spring:message code='Cache.msg_Common_08'/>", 'Confirmation Dialog', function (result) { // 선택한 항목을 삭제하시겠습니까?
                if (result) {
					$.ajax({
						url: "/covicore/admin/orgmanage/deleteCompareObject.do",
						type: "POST",
						data: {ObjectType:pSyncType , Codes: CodeList},
						success: function(d) {
							if (d.status == "SUCCESS") {
								if(pSyncType=='Group')showCompareGroupList();
								if(pSyncType=='User')showCompareUserList();
								if(pSyncType=='Addjob')showCompareAddjobList();
								//var arrSeq = CodeList.split(";");
                                //for (var i = 0; i < CodeList.split(";").length; i++) {
                                //    $("#tr" + pSyncType + "_" + arrSeq[i]).remove();
                                //}
							} 	
						},
						error: function(response, status, error) {			
							CFN_ErrorAjax("/covicore/admin/orgmanage/deleteCompareObject.do", response, status, error);
						} 
					});
                }
            });          
        } 
		else {
			$.ajax({
					url: "/covicore/admin/orgmanage/deleteCompareObject.do",
					type: "POST",
					data: {ObjectType:pSyncType , Codes: pCode},
					success: function(d) {
						if (d.status == "SUCCESS") {
							$("[id='tr" + pSyncType + "_" + pCode+"']").remove();
						} 		
					},
					error: function(response, status, error) {			
						CFN_ErrorAjax("/covicore/admin/orgmanage/deleteCompareObject.do", response, status, error);
					}
			});
        }
        
    }

    // 삭제대상 선택
    function CheckAll(pObj, pType) {
        var bChecked = true;
        bChecked = $(pObj).prop("checked");
        $("[name='chk" + pType + "Item']").prop("checked", bChecked);
    }

</script>