<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class='cRConTop titType'>
	<h2 class="title"></h2>
</div>
<div class="ATM_Config_Table_wrap" style="display:flex;height:800px;flex-direction:column;margin:30px;">
    <div style="flex:1">
    	<div class="ATM_Config_Table_wrap">
			<p class="ATM_Config_Title">model 설정<a href="#" id="saveBtn" class="btnTypeDefault btnBlueBoder" style="float:right;">저장</a></p>
			<div>
				<table class="ATM_Config_Table" cellpadding="0" cellspacing="0" style="min-width:0px;">
					<tbody>
						<tr >
							<td class="Config_TH"><p class="tx_TH">API Key</p></td>
							<td><input type="text" id="api_key" style="width:100%;"/></td>
							<td class="Config_TH"><p class="tx_TH">모델</p></td>
							<td><input type="text" id="model"/></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
    </div>
    <div style="flex:4;display:flex;">
    	<div style="flex:2;">
    		<div class="ATM_Config_Table_wrap">
				<p class="ATM_Config_Title">prompt 설정</p>
				<div>
					<table class="ATM_Config_Table" cellpadding="0" cellspacing="0" style="min-width:0px;">
						<tbody>
							<tr >
								<td class="Config_TH"><p class="tx_TH">오류탐지</p></td>
								<td><input type="text" id="findError" style="width:100%;"/></td>
							</tr>
							<tr >
								<td class="Config_TH"><p class="tx_TH">코드설명</p></td>
								<td><input type="text" id="explainCode" style="width:100%;"/></td>
							</tr>
							<tr >
								<td class="Config_TH"><p class="tx_TH">리펙터링</p></td>
								<td><input type="text" id="refactoring" style="width:100%;"/></td>
							</tr>
							<tr >
								<td class="Config_TH"><p class="tx_TH">주석생성</p></td>
								<td><input type="text" id="comment" style="width:100%;"/></td>
							</tr>
							<tr >
								<td class="Config_TH"><p class="tx_TH">소스비교</p></td>
								<td><input type="text" id="compare" style="width:100%;"/></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
    	</div>
    	<div style="flex:3;margin-left:30px;">
    		<div class="ATM_Config_Table_wrap">
				<p class="ATM_Config_Title">option 설정</p>
				<div>
					<table class="ATM_Config_Table" cellpadding="0" cellspacing="0" style="min-width:0px;">
						<tbody>
							<tr>
								<td class="Config_TH" style="width:20%;"><p class="tx_TH">Option Key</p></td>
								<td class="Config_TH" style="width:15%;"><p class="tx_TH">초기값</p></td>
								<td class="Config_TH"><p class="tx_TH">Option Key 설명</p></td>
							</tr>
							<tr>
								<td class="Config_TH"><p class="tx_TH">Temperature</p></td>
								<td><input type="text" id="temperature" style="width:100%;"/></td>
								<td><input type="text" id="exTemperature" style="width:100%;"/></td>
							</tr>
							<tr>
								<td class="Config_TH"><p class="tx_TH">Max Token</p></td>
								<td><input type="text" id="maxToken" style="width:100%;"/></td>
								<td><input type="text" id="exMaxToken" style="width:100%;"/></td>
							</tr>
							<tr>
								<td class="Config_TH"><p class="tx_TH">Top P</p></td>
								<td><input type="text" id="topP" style="width:100%;"/></td>
								<td><input type="text" id="exTopP" style="width:100%;"/></td>
							</tr>
							<tr>
								<td class="Config_TH"><p class="tx_TH">Presence penalty</p></td>
								<td><input type="text" id="presencePenalty" style="width:100%;"/></td>
								<td><input type="text" id="exPresencePenalty" style="width:100%;"/></td>
							</tr>
							<tr>
								<td class="Config_TH"><p class="tx_TH">Frequency penalty</p></td>
								<td><input type="text" id="frequencyPenalty" style="width:100%;"/></td>
								<td><input type="text" id="exFrequencyPenalty" style="width:100%;"/></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
    	</div>
    </div>
</div>
<script type="text/javascript">
(function() {
	
	var setModel = function() {
		$.ajax({
			url: "/groupware/devWithGPT/getModel.do",
			type: "GET",
			async: false,
			success: function(result) {
				if(result.status == "SUCCESS") {
					$("#api_key").val(result.info.APIKey);
					$("#model").val(result.info.Model);
					$("#findError").val(result.prompt.FindError);
					$("#explainCode").val(result.prompt.ExplainCode);
					$("#refactoring").val(result.prompt.Refactoring);
					$("#comment").val(result.prompt.Comment);
					$("#compare").val(result.prompt.Compare);
					$("#temperature").val(result.option.Temperature);
					$("#exTemperature").val(result.option.ExTemperature);
					$("#maxToken").val(result.option.MaxToken);
					$("#exMaxToken").val(result.option.ExMaxToken);
					$("#topP").val(result.option.TopP);
					$("#exTopP").val(result.option.ExTopP);
					$("#presencePenalty").val(result.option.PresencePenalty);
					$("#exPresencePenalty").val(result.option.ExPresencePenalty);
					$("#frequencyPenalty").val(result.option.FrequencyPenalty);
					$("#exFrequencyPenalty").val(result.option.ExFrequencyPenalty);
				}
			}
		});
	};
	
	var addEvent = function() {
		$("#saveBtn").on("click", function() {
			if(!validationChk()) return;
			
			var data = {
				"api_key" : $("#api_key").val(),
				"model" : $("#model").val(),
				"findError" : $("#findError").val(),
				"explainCode" : $("#explainCode").val(),
				"refactoring" : $("#refactoring").val(),
				"comment" : $("#comment").val(),
				"compare" : $("#compare").val(),
				"temperature" : $("#temperature").val(),
				"exTemperature" : $("#exTemperature").val(),
				"maxToken" : $("#maxToken").val(),
				"exMaxToken" : $("#exMaxToken").val(),
				"topP" : $("#topP").val(),
				"exTopP" : $("#exTopP").val(),
				"presencePenalty" : $("#presencePenalty").val(),
				"exPresencePenalty" : $("#exPresencePenalty").val(),
				"frequencyPenalty" : $("#frequencyPenalty").val(),
				"exFrequencyPenalty" : $("#exFrequencyPenalty").val()
			};
			
			$.ajax({
				url: "/groupware/devWithGPT/updateModel.do",
				type: "POST",
				data: JSON.stringify(data),
				contentType: "application/json; charset=utf-8",
				success: function(result) {
					Common.Inform("<spring:message code='Cache.msg_Changed'/>");
				}
			});
		});
	};
	
	var validationChk = function() {
		var temperature = $("#temperature").val();
		var maxToken = $("#maxToken").val();
		var topP = $("#topP").val();
		var presencePenalty = $("#presencePenalty").val();
		var frequencyPenalty = $("#frequencyPenalty").val();
		
		if(!$.isNumeric(temperature) || !$.isNumeric(maxToken) || !$.isNumeric(topP) || !$.isNumeric(presencePenalty) || !$.isNumeric(frequencyPenalty)) {
			Common.Warning("Option 값은 숫자로만 입력해주세요.");
			return false;
		} else if(temperature < 0 || temperature > 2) {
			Common.Warnging("0과 2사이의 실수를 입력해주세요.");
			return false;
		} else if(maxToken < 10 || maxToken > 4000) {
			Common.Warnging("10과 4000사이의 정수를 입력해주세요.");
			return false;
		} else if(topP < 0 || topP > 1) {
			Common.Warnging("0과 1사이의 실수를 입력해주세요.");
			return false;
		} else if(presencePenalty < -2 || presencePenalty > 2) {
			Common.Warnging("-2과 2사이의 실수를 입력해주세요.");
			return false;
		} else if(frequencyPenalty < -2 || temperature > 2) {
			Common.Warnging("-2과 2사이의 실수를 입력해주세요.");
			return false;
		}
		
		return true;
	};
	
	setModel();
	addEvent();
	
})();
</script>