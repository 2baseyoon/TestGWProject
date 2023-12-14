<%@page import="egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.DicHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	String promptType = request.getParameter("promptType");

	String menuTitle="";
	
	if("FindError".equals(promptType)) menuTitle = "오류탐지";
	else if("ExplainCode".equals(promptType)) menuTitle = "소스코드 설명";
	else if("Refactoring".equals(promptType)) menuTitle = "소스 리펙토링 제안";
	else if("Comment".equals(promptType)) menuTitle = "주석 자동생성";
	else if("Free".equals(promptType)) menuTitle = "자유 질의";
	else if("Compare".equals(promptType)) menuTitle = "소스코드 비교 분석";
%>
<link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/styles/atom-one-dark.min.css"/>
<script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/highlight.min.js"></script>
<div class='cRConTop titType'>
	<h2 class="title"><%=menuTitle%></h2>
</div>
<div class="cRContBottom mScrollVH">
	<div style="display:flex;">
		<div style="display:flex;flex:5;flex-direction:column;">
			<div style="flex:1;height:50%;">
				<ul class="tabMenu clearFloat">
					<li id="tab1" class="active"><a href="#">소스코드1</a></li>
					<li id="tab2" class="" style="display:none;"><a href="#">소스코드2</a></li>
					<a href="#" id="requestAnswerBtn" class="btnTypeDefault btnBlueBoder" style="margin:5px;float:right;">답변요청</a>
				</ul>
				<textarea id="question1" style="width:99%;margin:5px;height:86%;resize:none;border:1px solid gray;overflow-y:scroll"></textarea>
				<textarea id="question2" style="width:99%;margin:5px;height:86%;resize:none;border:1px solid gray;display:none;"></textarea>
			</div>
			<div style="flex:1;height:50%;">
				<ul class="tabMenu clearFloat">
					<li class="active"><a href="#">답변결과</a></li>
					<li style="float:right;"></li>
				</ul>
				<pre style="border:1px solid gray;width:99%;margin:5px;height:86%;">
					<code id="answer" style="white-space:pre-wrap;overflow:scroll;height:100%;margin-top:-14px;" class=""></code>
				</pre>
			</div>
		</div>
		<div style="flex:2;border:1px solid gray;">
			<div id="temperature" style="margin:5%;">
				<h3 class="cycleTitle">Temperature 
					<div class="collabo_help02">
				        <a href="#" class="help_ico"></a>	
				        <div id="ExTemperature" class="helppopup"></div>
		    		</div>
		    		<input type="text" readonly/>
	    		</h3>
				<div style="width:80%;margin-top:30px;margin-left:30px;"></div>
				<p style="margin-top:30px;margin-left:30px;">대화의 자유도를 결정합니다.</p>
			</div>
			<div id="maxToken" style="margin:5%;">
				<h3 class="cycleTitle">Max Token 
					<div class="collabo_help02">
				        <a href="#" class="help_ico"></a>	
				        <div id="ExMaxToken" class="helppopup"></div>
		    		</div>
					<input type="text" readonly/>
				</h3>
				<div style="width:80%;margin-top:30px;margin-left:30px;"></div>
				<p style="margin-top:30px;margin-left:30px;">질의/답변시의 최대 Token 수를 지정합니다.</p>
			</div>
			<div id="topP" style="margin:5%;">
				<h3 class="cycleTitle">Top P 
					<div class="collabo_help02">
				        <a href="#" class="help_ico"></a>	
				        <div id="ExTopP" class="helppopup"></div>
		    		</div>
					<input type="text" readonly/>
				</h3>
				<div style="width:80%;margin-top:30px;margin-left:30px;"></div>
				<p style="margin-top:30px;margin-left:30px;">top_p 확률 질량을 가진 토큰의 결과를 고려합니다.</p>
			</div>
			<div id="presencePenalty" style="margin:5%;">
				<h3 class="cycleTitle">Presence penalty 
					<div class="collabo_help02">
				        <a href="#" class="help_ico"></a>	
				        <div id="ExPresencePenalty" class="helppopup"></div>
		    		</div>
					<input type="text" readonly/>
				</h3>
				<div style="width:80%;margin-top:30px;margin-left:30px;"></div>
				<p style="margin-top:30px;margin-left:30px;">양수 값을 입력하면 모델이 새로운 주제에 대해 이야기할 가능성이 높아집니다.</p>
			</div>
			<div id="frequencyPenalty" style="margin:5%;">
				<h3 class="cycleTitle">Frequency penalty 
					<div class="collabo_help02">
				        <a href="#" class="help_ico"></a>	
				        <div id="ExFrequencyPenalty" class="helppopup"></div>
		    		</div>
					<input type="text" readonly/>
				</h3>
				<div style="width:80%;margin-top:30px;margin-left:30px;"></div>
				<p style="margin-top:30px;margin-left:30px;">양수 값을 입력하면 같은 줄을 그대로 반복할 가능성을 줄입니다.</p>
			</div>
		</div>
	</div>
</div>
<script type="text/javascript">
(function() {
	var modelPrompt;
	var modelOption = [];
	var answerResult = "Prompt Token : {0} Completion Token : {1} Total Token : {2} 대화 종료 이유 : {3}";
	
	var addEvent = function() {
		if(CFN_GetQueryString("promptType") == "Compare") {
			$("#tab2").show();
			
			$("#tab1").on("click", function() {
				$("#tab2").removeClass("active");
				$("#question2").hide();
				
				$("#tab1").addClass("active");
				$("#question1").show();
			});
			
			$("#tab2").on("click", function() {
				$("#tab1").removeClass("active");
				$("#question1").hide();
				
				$("#tab2").addClass("active");
				$("#question2").show();
			});
		}
		
		/* 답변 요청 */
		$("#requestAnswerBtn").on("click", function() {
			
			var messages = [];
			var messageObj = {};
			var prompt;
			
			if(CFN_GetQueryString("promptType") == "Compare") {
				prompt = modelPrompt.replace("{0}", $("#question1").val()).replace("{1}", $("#question2").val());
			} else {
				prompt = modelPrompt.replace("{0}", $("#question1").val());
			}
			
			messageObj["role"] = "user";
			messageObj["content"] = prompt;
			
			messages.push(messageObj);
			
			var data =  {
					"messages" : messages,
					"promptType" : CFN_GetQueryString("promptType"),
					"temperature": $("#temperature > h3 > input").val(),
					"max_tokens": $("#maxToken > h3 > input").val(),
					"top_p" : $("#topP > h3 > input").val(),
					"presence_penalty" : $("#presencePenalty > h3 > input").val(),
					"frequency_penalty" : $("#frequencyPenalty > h3 > input").val()
				};
			
			$.ajax({
				url:"/groupware/devWithGPT/requestToGPT.do",
				type:"POST",
				contentType: "application/json; charset=utf-8",
				data: JSON.stringify(data),
				timeout: 60000, 
				disableProgress:true,
				beforeSend: function() {
					Common.Progress("Loading ... ");		
				},
				success:function(result) {
					setTimeout(function(){Common.AlertClose();});
					
					if(result.status == "SUCCESS") {
						var choice = result.data.choices[0];
						var usage = result.data.usage;
						
						var finish_reason = choice.finish_reason == "length" ? "토큰 수 초과" :choice.finish_reason;
						
						var resultStr = answerResult.replace("{0}", usage.prompt_tokens)
								.replace("{1}", usage.completion_tokens)
								.replace("{2}", usage.total_tokens)
								.replace("{3}", finish_reason);
						
						sessionStorage.setItem("modelOption", JSON.stringify(data));

						$("#answer").text("");
						$("#answer").text(choice.message.content.replaceAll(/```[a-z][A-Z]*\n/, ""));
						
						$("#answer").parent("pre").siblings("ul").children("li").eq(1).text(resultStr);

						hljs.highlightAll();
					} else if(result.status == "FAIL") {
						var error = result.error;
						var message = "";
						
						if(error.rawStatusCode == 401) {
							message = "권한이 없습니다.";
						} else {
							message = error.responseBodyAsString;
							message = JSON.parse(message).error.message;
						}
						
						Common.Warning(message);
					}
				},
				error:function(result) {
					setTimeout(function(){Common.AlertClose();});
					
					Common.Warning("응답시간 초과");
				}
			});
		});
		
		$(".help_ico").on("click", function() {
			if($(this).hasClass("active")) $(this).removeClass("active");
			else $(this).addClass("active");
		});
	};
	
	var setOption = function() {
		$.ajax({
			url : "/groupware/devWithGPT/getModelOptionAndPrompt.do",
			type : "GET",
			async : false,
			data : {
				"promptType" : CFN_GetQueryString("promptType")
			},
			success:function(result) {
				modelPrompt = result.data.prompt == undefined ? "{0}" : result.data.prompt;
				
				if(sessionStorage.getItem("modelOption") != null) {
					var tmpOption = JSON.parse(sessionStorage.getItem("modelOption"));
					
					modelOption["Temperature"] = tmpOption.temperature;
					modelOption["MaxToken"] = tmpOption.max_tokens;
					modelOption["TopP"] = tmpOption.top_p;
					modelOption["PresencePenalty"] = tmpOption.presence_penalty;
					modelOption["FrequencyPenalty"] = tmpOption.frequency_penalty;
				} else {
					modelOption = result.data.option;
				}
				
				$("#ExTemperature").text(result.data.option.ExTemperature);
				$("#ExMaxToken").text(result.data.option.ExMaxToken);
				$("#ExTopP").text(result.data.option.ExTopP);
				$("#ExPresencePenalty").text(result.data.option.ExPresencePenalty);
				$("#ExFrequencyPenalty").text(result.data.option.ExFrequencyPenalty);
				
				$("#temperature > h3 > input").val(modelOption.Temperature);
				$("#maxToken > h3 > input").val(modelOption.MaxToken);
				$("#topP > h3 > input").val(modelOption.TopP);
				$("#presencePenalty > h3 > input").val(modelOption.PresencePenalty);
				$("#frequencyPenalty > h3 > input").val(modelOption.FrequencyPenalty);
			}
		});
	};
	
	var setSlider = function() {
		$("#temperature > div").slider({
			range: "min",
			value: modelOption.Temperature,
		    orientation: "horizontal",
		    min:0,
		    max:2,
		    step:0.01,
		    animate: true,
		    slide: function( event, ui ) {
		    	$("#temperature > h3 > input").val(ui.value);
		    }
		});
		$("#maxToken > div").slider({
			range: "min",
			value: modelOption.MaxToken,
		    orientation: "horizontal",
		    min:10,
		    max:4000,
		    step:1,
		    animate: true,
			slide: function( event, ui ) {
				$("#maxToken > h3 > input").val(ui.value);
		    }
		});
		$("#topP > div").slider({
			range: "min",
			value: modelOption.TopP,
		    orientation: "horizontal",
		    min:0,
		    max:1,
		    step:0.01,
			slide: function( event, ui ) {
				$("#topP > h3 > input").val(ui.value);
		    }
		});
		$("#presencePenalty > div").slider({
			range: "min",
			value: modelOption.PresencePenalty,
		    orientation: "horizontal",
		    min:-2.0,
		    max:2.0,
		    step:0.01,
			slide: function( event, ui ) {
				$("#presencePenalty > h3 > input").val(ui.value);
		    }
		});
		$("#frequencyPenalty > div").slider({
			range: "min",
			value: modelOption.FrequencyPenalty,
		    orientation: "horizontal",
		    min:-2.0,
		    max:2.0,
		    step:0.01,
			slide: function( event, ui ) {
				$("#frequencyPenalty > h3 > input").val(ui.value);
		    }
		});
	};
	
	setOption();
	setSlider();
	addEvent();
})();
</script>
