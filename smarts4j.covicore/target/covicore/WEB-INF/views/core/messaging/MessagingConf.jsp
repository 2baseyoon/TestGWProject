<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<style>
.WorkingStatus_popup {padding:20px;}
.WorkingStatusAdd_popup {padding:10px 0 20px 0;}
.WorkingStatus_top {}
.WorkingStatus_table_wrap {margin-top:12px;}
.WorkingStatus_table {width:100%;border-top:1px solid #969696; margin-bottom:7px;}
.WorkingStatus_table th {height:33px;line-height:33px;border-bottom:1px solid #ddd;}
.WorkingStatus_table td {padding:6px 13px;border-bottom:1px solid #ebebec;}

.onOffBtn {position:relative;right:0;padding:2px;display:inline-block;float:right;width:31px;height:14px;background:#cfcfcf;vertical-align:middle;text-indent:-9999px;border-radius:7px;}
.onOffBtn > span {position:absolute;display:block;left:2px;width:10px;height:10px;background:#fff;border-radius:5px;transition: left .2s;text-indent:-99999px;}
.onOffBtn.on > span {left:18px;}
.alarm.type01 {padding:0;display:inline-block;color:#000;}
.alarm.type01 > span {margin-right:5px;line-height:19px; vertical-align:middle; }
.onOffBtn {float:none; width:36px;height:20px;border-radius:10px; }
.onOffBtn > span {width:16px;height:16px;border-radius:8px; }


.onOffBtn.on {background:#6fb128;}
</style>
<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.CN_361'/></span>
</h3>
<div style="width:100%;min-height: 500px">
	<div id="topitembar01" class="topbar_grid">
		<div id="divTabTray" style="height:30px">
			<input type="button" id="refresh" class="AXButton" value="<spring:message code="Cache.btn_Refresh"/>" />
			<input type="button" id="cacheApply" class="AXButton" value="<spring:message code="Cache.btn_CacheApply"/>" />
		</div>
	</div>
	<div style="width:45%;float:left;min-height:230px;padding-right:10px" class="topbar_grid">
		<spring:message code='Cache.lbl_NoticeMedia' />
		<table class="WorkingStatus_table" id="tblNotifyMedia" cellpadding="0" cellspacing="0">
			<colgroup>
				<col width="100" style="">
				<col width="*" style="">
				<col width="40px" style="">
			</colgroup>
			<thead>
			<tr>
				<th><spring:message code="Cache.lbl_SettingValue"/></th>
				<th><spring:message code="Cache.lbl_Description"/></th>
				<th><spring:message code="Cache.lbl_Use"/></th>
			</tr>
			</thead>
			<tbody>
			</tbody>
		</table>
	</div>
	<div style="width:50%;float:right;min-height:120px"  class="topbar_grid">
		<spring:message code='Cache.lbl_TransQuantity'/>
		<table class="WorkingStatus_table" id="tblTrans" cellpadding="0" cellspacing="0">
			<colgroup>
				<col width="200" style="">
				<col width="80" style="">
				<col width="*" style="">
				<col width="40px" style="">
			</colgroup>
			<thead>
			<tr>
				<th><spring:message code="Cache.lbl_SettingKey"/></th>
				<th><spring:message code="Cache.lbl_SettingValue"/></th>
				<th><spring:message code="Cache.lbl_Description"/></th>
				<th><spring:message code="Cache.lbl_Use"/></th>
			</tr>
			</thead>
			<tbody>
			</tbody>
		</table>
	</div>
	<div style="width:50%;float:right"  class="topbar_grid">
		<spring:message code='Cache.lbl_RetrySending'/>
		<table class="WorkingStatus_table" id="tblRetry" cellpadding="0" cellspacing="0">
			<colgroup>
				<col width="200" style="">
				<col width="80" style="">
				<col width="*" style="">
				<col width="40px" style="">
			</colgroup>
			<thead>
			<tr>
				<th><spring:message code="Cache.lbl_SettingKey"/></th>
				<th><spring:message code="Cache.lbl_SettingValue"/></th>
				<th><spring:message code="Cache.lbl_Description"/></th>
				<th><spring:message code="Cache.lbl_Use"/></th>
			</tr>
			</thead>
			<tbody>
			</tbody>
		</table>
	</div>
	<div class="topbar_grid" style="width:100%;float:left">
		<span>PUSH알림</span> 
		<table class="WorkingStatus_table" id="tblAllow" cellpadding="0" cellspacing="0">
			<colgroup>
				<col width="200" style="">
				<col width="300" style="">
				<col width="*" style="">
				<col width="40px" style="">
			</colgroup>
			<thead>
			<tr>
				<th><spring:message code="Cache.lbl_SettingKey"/></th>
				<th><spring:message code="Cache.lbl_SettingValue"/></th>
				<th><spring:message code="Cache.lbl_Description"/></th>
				<th><spring:message code="Cache.lbl_Use"/></th>
			</tr>
			</thead>
			<tbody>
			</tbody>
		</table>
	</div>
</div>	
<script>
	var msgConfObj = {
		pageStart: function () {
			msgConfObj.util.searchType();
			$(document).off('click','#msgCodePopup').on('click','#msgCodePopup',function(){
				msgConfObj.event.openEditBaseCode(this);
		    });
			$(document).off('click','#msgConfPopup').on('click','#msgConfPopup',function(){
				msgConfObj.event.openEditBaseConfig(this);
		    });
			$(document).off('click','#msgCodeIsUse').on('click','#msgCodeIsUse',function(){
				msgConfObj.event.updateCodeIsUse(this);
		    });
			$(document).off('click','#msgConfIsUse').on('click','#msgConfIsUse',function(){
				msgConfObj.event.updateConfIsUse(this);
		    });
			$("#refresh").on( 'click',function(e){
				msgConfObj.util.searchType();
			});
			
			$('#cacheApply').on( 'click',function(e){
				msgConfObj.event.applyCache();
			});
		},
		util:{
			mediaType : '',
			searchType:function(){
            	$("#tblAllow tbody").empty();
            	$("#tblTrans tbody").empty();
            	$("#tblRetry tbody").empty();
            	$("#tblNotifyMedia tbody").empty();
				$.ajax({
					type:"POST",
					data:{"codeGroup" : "NotificationMedia"},
					url:"/covicore/basecode/getList.do",
					success:function (data) {
						$.each(data.list, function(index, item) {
							if (item.Code != "NotificationMedia") {
								$("#tblNotifyMedia tbody")
									.append($("<tr>",{"data":{codeId:item.CodeID,code:item.Code,codeGroup:item.CodeGroup}})
									.append($("<td>").append($("<a>",{"id":"msgCodePopup","text":item.CodeName})))
									.append($("<td>",{"text":item.Description}))
									.append($("<td>").append($("<a>",{"class":"onOffBtn "+(item.IsUse=="Y"?"on":""),"id":"msgCodeIsUse"}).append($("<span>")))));
							}
						});
					},
					error:function (error){
						Common.Error(error.message);
					}
				});
				
				var pConfigArray = "MaxEmailCountForOnce,MaxMDMCountForOnce,MaxMessengerCountForOnce"+
				                    ",MessengerRetryCount,MailRetryCount,MDMRetryCount"+
				                    ",MDMAllowWeek,MDMAllowStartTime,MDMAllowEndTime";
				
				 $.ajax({
		                url: "/covicore/baseconfig/getList.do",
		                data: {"configArray": pConfigArray,"domain":0},
		                type: "post",
		                async: false,
		                success: function (data) {
		                	
							$.each(data.list, function(index, item) {
								var drawId = "tblAllow"
								if (item.SettingKey.indexOf("CountForOnce")>-1){
									drawId = "tblTrans";
								}else if (item.SettingKey.indexOf("RetryCount")>-1){
									drawId = "tblRetry";
								}
								else{
									drawId = "tblAllow";
								}
								

								$("#"+drawId +" tbody").append($("<tr>",{"data":{seq:item.ConfigID}})
									.append($("<td>").append($("<a>",{"id":"msgConfPopup","text":item.SettingKey})))
									.append($("<td>",{"html":item.SettingKey=="MDMAllowWeek"?msgConfObj.util.convertFormatWeek(item.SettingValue):item.SettingValue}))
									.append($("<td>",{"text":item.Description}))
									.append($("<td>") 
											.append($("<a>",{"class":"onOffBtn "+(item.IsUse=="Y"?"on":""),"id":"msgConfIsUse"}).append($("<span>"))))
									);
							});
		                },
		                error: function (response, status, error) {
		                    CFN_ErrorAjax("/covicore/common/getBaseConfigList.do", response, status, error);
		                }
		         });
			},
			convertFormatWeek:function(val, format){
				var sRet= "";
				var pWeekArray = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
				for (var i=0; i < pWeekArray.length; i++){
					sRet += '<span class=""><input type="checkbox" id="workWeek'+pWeekArray[i]+'" value="1" '+(val.substring(i,i+1)=="1"?"checked":"")+'><label>'+ Common.getDic("lbl_WP"+pWeekArray[i])+'</label></span>';
					
				}
				return sRet;
			}
		},
		event:{
			openEditBaseConfig:function(obj){
				var sOpenName = "divBaseConfig";

				var sURL = "/covicore/baseconfig/goBaseConfigPopup.do";
				sURL += "?mode=modify";
				sURL += "&configID=" + $(obj).closest("tr").data("seq");
				sURL += "&OpenName=" + sOpenName;
				
				var sTitle = "<spring:message code='Cache.lbl_ConfigModify'/>";

				var sWidth = "600px";
				var sHeight = "310px";
				Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
			},
			openEditBaseCode:function(obj){
				var sOpenName = "divBaseCode";

				var sURL = "/covicore/basecode/goBaseCodePopup.do";
				sURL += "?mode=modify";
				sURL += "&code=" + $(obj).closest("tr").data("code");
				sURL += "&codeGroup=" + $(obj).closest("tr").data("codeGroup");
				sURL += "&domainID=" + "0";
				sURL += "&OpenName=" + sOpenName;
				
				var sTitle = "<spring:message code='Cache.lbl_CodeModify'/>";

				var sWidth = "500px";
				var sHeight = "350px";
				Common.open("", sOpenName, sTitle, sURL, sWidth, sHeight, "iframe", false, null, null, true);
			},
			updateCodeIsUse:function(obj){
				$(obj).toggleClass("on");
				var pDomainID = "0";
				$.ajax({
					type:"POST",
					data:{
						"Code" : $(obj).closest("tr").data("code"),
						"CodeGroup" : $(obj).closest("tr").data("codeGroup"),
						"DomainID" : pDomainID,
						"IsUse" : $(obj).hasClass("on")?"Y":"N"
					},
					url:"/covicore/basecode/modifyUse.do",
					success:function (data) {
						if(data.status != "SUCCESS"){
							Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/baseconfig/modifyUse.do", response, status, error);
					}
				});
			},
			updateConfIsUse:function(obj){
				$(obj).toggleClass("on");
				$.ajax({
					type:"POST",
					data:{
						"Seq" : $(obj).closest("tr").data("seq"),
						"IsUse" : $(obj).hasClass("on")?"Y":"N",
						"ModID" : ""
					},
					url:"/covicore/baseconfig/modifyUse.do",
					success:function (data) {
						if(data.status != "SUCCESS"){
							Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
						}
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/covicore/baseconfig/modifyUse.do", response, status, error);
					}
				});
			},
			applyCache:function(){
				coviCmn.reloadCache("BASECONFIG", "0");
				coviCmn.reloadCache("BASECODE", "0");
			}
		}
	};
	
$(function () {
	msgConfObj.pageStart();
});
</script>
