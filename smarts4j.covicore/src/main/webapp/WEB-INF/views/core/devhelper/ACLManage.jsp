<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div style="float:left;width:350px; height:400px; margin-right:30px;">
	<div style="margin-bottom:10px;">
		<select id="selDomain" class="selectType04" style="float: left; width: 140px; margin-right: 10px;" onchange="changeDomain(this)">
		</select>
		<button type="button" onclick="syncSelectDomain()" class="AXButton Classic">회사별 Sync</button>
		<button type="button" onclick="syncAllDomain()" class="AXButton Classic">전체 권한 Sync</button>
	</div>
	
	<div id="divSyncMap" style="width:350px; height:400px; border: 1px solid #d9d9d9; overflow-y:auto; overflow-x:hidden;">
	
	</div>
</div>

<div style="float:left;width:400px; height:400px;">
	<div style="margin-bottom:10px; text-align:right;">
		<button type="button" onclick="getSampleACL()" class="AXButton Classic">세션 권한데이터 조회(MN)</button>
		<button type="button" onclick="fromObjectACL()" class="AXButton Classic">권한 변환</button>
	</div>
	<div style="margin-bottom:10px; width:400px; height:150px; border: 1px solid #d9d9d9;">
		<textarea id="txtSerializeData" style="width:100%; height:100%; resize:none; outline:none; border:none;"></textarea>
	</div>
	<div id="aclDataView" style="width:400px; height:238px; border: 1px solid #d9d9d9; overflow-y:auto; padding:5px; box-sizing:border-box;">
	
	</div>
</div>

<script>
	$(function() {
		//document ready
		// 1. domainid mapping
		$.post("/covicore/aclhelper/getDomainList.do", {}, function(data){
			$.each(data.list, function(idx, obj) {
				$("#selDomain").append("<option value='" + obj.DomainID + "'>" + obj.DisplayName + "</option>");
			});
			// 2. synckey select
			var currentDomainID = $("#selDomain").val();
			getSyncKeyList(currentDomainID);
		});
		
		
		
	});
	
	function getSyncKeyList(pDomainID) {
		$("#divSyncMap").empty();
		$.post("/covicore/aclhelper/getSyncKeyList.do", {"DomainID" : pDomainID}, function(data) {
			$.each(data.list, function(idx, obj) {
				var appendBox = "<div id='div_" + obj.Key + "' style='width: 90%; height: 50px; margin: 3px; padding: 5px; border: 1px solid #d9d9d9; border-radius: 5px; background-color: #f9f9f9; position:relative;'>";
				appendBox += "<div style='min-width:50px; border:1px solid #f0f0f0; padding: 2px 10px;text-align:center; background: #222f3e; color: #fff; font-weight: bold; border-radius: 5px;'>";
				appendBox += obj.Key;
				appendBox += "</div>";
				appendBox += "<div style='margin-top: 3px; padding-left: 10px; font-size: 12px; color: #595959;'>";
				appendBox += obj.Value;
				appendBox += "</div>";
				appendBox += "<div>";
				appendBox += "<button type='button' class='AXButton Classic' style='position: absolute; bottom: 5px; right: 5px;' onclick='refreshSyncKey(\"" + obj.Key + "\", \"" + pDomainID + "\")'><i class='fa fa-refresh' aria-hidden='true'></i></button>";
				appendBox += "</div>";
				appendBox += "</div>";
				$("#divSyncMap").append(appendBox);		
			});
		});		
	}
	
	function changeDomain(obj) {
		var selDomain = $(obj).val();
		getSyncKeyList(selDomain);
	}
	
	function refreshSyncKey(pKey, pDomainID) {
		Common.Progress("처리중입니다.");
		$.post("/covicore/aclhelper/refreshSyncKey.do", {"DomainID" : pDomainID, "Key" : pKey}, function(data) {
			Common.AlertClose();
			$("#div_" + pKey).find(">div:nth-child(2)").text(data.syncKey);
		});
	}
	
	function syncSelectDomain() {
		var selDomain = $("#selDomain").val();
		Common.Progress("처리중입니다.");
		$.post("/covicore/aclhelper/refreshSyncKeyAll.do", {"DomainID" : selDomain}, function(data) {
			Common.AlertClose();
			getSyncKeyList(selDomain);
		});
	}
	
	function syncAllDomain() {
		var selDomain = $("#selDomain").val();
		Common.Progress("처리중입니다.");
		$.post("/covicore/aclhelper/refreshSyncKeyAll.do", {}, function(data) {
			Common.AlertClose();
			getSyncKeyList(selDomain);
		});
	}
	
	function getSampleACL() {
		$.get("/covicore/aclhelper/sampleACLData.do", {}, function(data) {
			$("#txtSerializeData").val(data.aclData);
		});
	}
	
	function fromObjectACL() {
		var serData = $("#txtSerializeData").val();
		$("#aclDataView").empty();
		if(serData != "") {
			$.post("/covicore/aclhelper/fromObjectACL.do", {aclData:serData}, function(data) {
				var appendBox = "<div>";
				appendBox += "<div>";
				appendBox += "<span style='display: inline-block; padding: 5px; border: 1px solid #d9d9d9; float: left; border-radius: 5px; background-color: #222; font-weight: bold; color: #fff;'>"; 
				appendBox += data.aclData.settingKey + "</span>";
				appendBox += "</div>";
				appendBox += "<div>";
				appendBox += "<span style='display: inline-block; padding: 5px; border: 1px solid #d9d9d9; margin-left: 10px; background-color: #e9e9e9; border-radius: 5px; font-weight: bold;'>"; 
				appendBox += data.aclData.syncKey + "</span>";
				appendBox += "</div>";
				appendBox += "<div>";
				appendBox += "<div style='width: 100%; border: 1px solid #d9d9d9; border-radius: 5px; min-height: 100px; padding: 3px; box-sizing: border-box; margin-top:5px;'>";
				appendBox += "<span style='width: 100%; box-sizing: border-box; display: inline-block; font-weight: bold; border-bottom: 1px solid #d0d0d0;'>Security</span>";
				appendBox += "<span style='display: block; width: 100%; word-break: break-word; font-size:12px;'>" + data.aclData.S + "</span>";
				appendBox += "</div>";
				appendBox += "<div style='width: 100%; border: 1px solid #d9d9d9; border-radius: 5px; min-height: 100px; padding: 3px; box-sizing: border-box; margin-top:5px;'>";
				appendBox += "<span style='width: 100%; box-sizing: border-box; display: inline-block; font-weight: bold; border-bottom: 1px solid #d0d0d0;'>Create</span>";
				appendBox += "<span style='display: block; width: 100%; word-break: break-word; font-size:12px;'>" + data.aclData.C + "</span>";
				appendBox += "</div>";
				appendBox += "<div style='width: 100%; border: 1px solid #d9d9d9; border-radius: 5px; min-height: 100px; padding: 3px; box-sizing: border-box; margin-top:5px;'>";
				appendBox += "<span style='width: 100%; box-sizing: border-box; display: inline-block; font-weight: bold; border-bottom: 1px solid #d0d0d0;'>Delete</span>";
				appendBox += "<span style='display: block; width: 100%; word-break: break-word; font-size:12px;'>" + data.aclData.D + "</span>";
				appendBox += "</div>";
				appendBox += "<div style='width: 100%; border: 1px solid #d9d9d9; border-radius: 5px; min-height: 100px; padding: 3px; box-sizing: border-box; margin-top:5px;'>";
				appendBox += "<span style='width: 100%; box-sizing: border-box; display: inline-block; font-weight: bold; border-bottom: 1px solid #d0d0d0;'>Modify</span>";
				appendBox += "<span style='display: block; width: 100%; word-break: break-word; font-size:12px;'>" + data.aclData.M + "</span>";
				appendBox += "</div>";
				appendBox += "<div style='width: 100%; border: 1px solid #d9d9d9; border-radius: 5px; min-height: 100px; padding: 3px; box-sizing: border-box; margin-top:5px;'>";
				appendBox += "<span style='width: 100%; box-sizing: border-box; display: inline-block; font-weight: bold; border-bottom: 1px solid #d0d0d0;'>Execute</span>";
				appendBox += "<span style='display: block; width: 100%; word-break: break-word; font-size:12px;'>" + data.aclData.E + "</span>";
				appendBox += "</div>";
				appendBox += "<div style='width: 100%; border: 1px solid #d9d9d9; border-radius: 5px; min-height: 100px; padding: 3px; box-sizing: border-box; margin-top:5px;'>";
				appendBox += "<span style='width: 100%; box-sizing: border-box; display: inline-block; font-weight: bold; border-bottom: 1px solid #d0d0d0;'>View</span>";
				appendBox += "<span style='display: block; width: 100%; word-break: break-word; font-size:12px;'>" + data.aclData.V + "</span>";
				appendBox += "</div>";
				appendBox += "<div style='width: 100%; border: 1px solid #d9d9d9; border-radius: 5px; min-height: 100px; padding: 3px; box-sizing: border-box; margin-top:5px;'>";
				appendBox += "<span style='width: 100%; box-sizing: border-box; display: inline-block; font-weight: bold; border-bottom: 1px solid #d0d0d0;'>Read</span>";
				appendBox += "<span style='display: block; width: 100%; word-break: break-word; font-size:12px;'>" + data.aclData.R + "</span>";
				appendBox += "</div>";
				appendBox += "</div>";
				appendBox += "</div>";
				
				$("#aclDataView").append(appendBox);
			});
		}
	}
</script>