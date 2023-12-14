<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class='cRConTop titType'>
	<h2 class="title"></h2>
</div>
<div style="height:800px;display:flex;margin:30px;">
	<div style="flex:1;"></div>
	<div style="flex:3;display:flex;flex-direction:column;">
		<div style="flex:1;">
			<h3 class="cycleTitle">월별 총 토큰 사용량</h3>
			<div style="margin:25px;">
				<p style="font-size:24px;text-align:center;">
					<input id="selectMonth" type="month"/>
					<strong id="monthUsage" style="margin-left:20px;"></strong>
				</p>
			</div>
		</div>
		<div style="flex:5;">
			<div class="ATM_Config_Table_wrap">
				<p class="ATM_Config_Title">질의 별 토큰 사용량</p>
				<div>
					<table class="ATM_Config_Table" cellpadding="0" cellspacing="0" style="min-width:0px;">
						<tbody>
							<tr>
								<td class="Config_TH" style="width:10%;"><p class="tx_TH">질의</p></td>
								<td class="Config_TH" style="width:10%;"><p class="tx_TH">토큰 사용량</p></td>
							</tr>
							<tr >
								<td class="Config_TH"><p class="tx_TH">오류탐지</p></td>
								<td><p class="Config_mp" style="text-align: center;"><strong id="FindError"></strong></p></td>
							</tr>
							<tr >
								<td class="Config_TH"><p class="tx_TH">코드설명</p></td>
								<td><p class="Config_mp" style="text-align: center;"><strong id="ExplainCode"></strong></p></td>
							</tr>
							<tr >
								<td class="Config_TH"><p class="tx_TH">리펙터링</p></td>
								<td><p class="Config_mp" style="text-align: center;"><strong id="Refactoring"></strong></p></td>
							</tr>
							<tr >
								<td class="Config_TH"><p class="tx_TH">주석생성</p></td>
								<td><p class="Config_mp" style="text-align: center;"><strong id="Comment"></strong></p></td>
							</tr>
							<tr >
								<td class="Config_TH"><p class="tx_TH">자유질의</p></td>
								<td><p class="Config_mp" style="text-align: center;"><strong id="Free"></strong></p></td>
							</tr>
							<tr >
								<td class="Config_TH"><p class="tx_TH">소스비교</p></td>
								<td><p class="Config_mp" style="text-align: center;"><strong id="Compare"></strong></p></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
	<div style="flex:1;"></div>
	<div style="flex:5;">
		<h3 class="cycleTitle">사용자 별 토큰 사용량</h3>
		<div class="tblList" style="margin-top:50px;">
			<div id="usageGrid"></div>
		</div>
	</div>
</div>
<script type="text/javascript">
(function() {
	$("#selectMonth").val(new Date().toISOString().slice(0, 7));
	
	var usageGrid = new coviGrid();
	
	var userUsage = function() {
		usageGrid.setGridHeader([
			{key:"UserName", label:"사용자", width:'50', align:"center"},
			{key:"UsageTokens", label:"토큰 사용량", width:'50', align:"center"}
		]);
		
		usageGrid.setGridConfig({
			targetID : "usageGrid",
			height:"auto",
			page:{pageSize:10,pageNo:1},
		});
		
		usageGrid.bindGrid({
 			ajaxUrl:"/groupware/devWithGPT/getUserUsage.do",
 			ajaxPars: {
 				"companyCode":Common.getSession("DN_Code")
 			}
		});
	};
	
	var monthUsage = function() {
		$.ajax({
			url:"/groupware/devWithGPT/getMonthUsage.do",
			type:"GET",
			data:{"domainID":Common.getSession("DN_ID"), "selectedMonth": $("#selectMonth").val()},
			success:function(result) {
				$("#monthUsage").text(result.MonthUsage.UsageTokens + " Tokens");
			}
		});
	}
	
	var promptUsage = function() {
		$.ajax({
			url:"/groupware/devWithGPT/getPromptUsage.do",
			type:"GET",
			data:{"domainID":Common.getSession("DN_ID")},
			success:function(result) {
				$.each(result.PromptUsage, function(idx, item) {
					$("#" + item.Prompt).text(item.UsageTokens);
				});
			}
		});
	};
	
	var addEvent = function() {
		$("#selectMonth").on("change", function() {
			monthUsage();
		});
	};
	
	monthUsage();
	promptUsage();
	userUsage();
	addEvent();
})();
</script>