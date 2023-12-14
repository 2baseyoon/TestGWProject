<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
<script>
	var url = decodeURI(location.search.substring(1));
	var param = url.split('&');
	//var param = location.search.substring(1).split('&');
	var value =param[0].split('=')[1];
	
	$(document).ready(function(){
		setDictionaryData();
	});
	
	function closeLayer(){
		Common.Close();
	}
	
	function saveDic(){
		parent._CallBackMethod(getDictionaryData());
		Common.Close();
	}
	
	function setDictionaryData(){
		var decodedVal = decodeURIComponent(value);
		var dicData = decodedVal.split(';');
		if(dicData.length > 1)
			$("input[type=text]").each(function(index){
				$(this).val(dicData[index]);
			});
		else
			document.getElementById("ko").value = value;
	}
	
	function getDictionaryData(){
		var returnvalue = "";
		$("input[type=text]").each(function(){
			returnvalue = returnvalue+this.value+";";
		});
		
		return returnvalue;
	}
	
	function bingtranslate(pObj){
		var text = "";
		var src_lang = "ko";
		
		//영어 텍스트가 있을시 영어, 아니면 한글을 통해 번역 시도
		if($("#en").val() != "" && $("#ko").val() == ""){
			text = $("#en").val();
			src_lang = "en";
		} else if ($("#ko").val() != ""){
			text = $("#ko").val();
			src_lang = "ko";
		}
		
		$.ajax({
			url:"translate.do",
			data:{
				"text":text,
				"src_lang":src_lang,
				"dest_lang":$(pObj).attr("lang")
			},
			type:"post",
			success:function (data) {
				if(data.result == "ok"){
					$("#" + $(pObj).attr("lang")).val(data.text);	
				}
			},
			error:function (error) {
				Common.Error(error);
			}
		});
	}
</script>
<form>
	<div>
		<table  class="AXFormTable">
			<colgroup>
				<col width="30%"/>
				<col width="70%"/>
			</colgroup>
			<tr>
				<th>한국어</th>
				<td>
					<input type="text" id="ko"  style="width: 70%;height:25px" class="AXInput"/>
					<input type="button" value="<spring:message code="Cache.btn_dicTrans"/>"  value="Trans" lang="ko"  onclick="bingtranslate(this); return false;" class="AXButton"  />
				</td>
			</tr>
			<tr>
				<th>English</th>
				<td>
					<input type="text" id="en"  style="width: 70%;height:25px" class="AXInput" />
					<input type="button" value="<spring:message code="Cache.btn_dicTrans"/>"  value="Trans" lang="en"  onclick="bingtranslate(this); return false;" class="AXButton"  />
				</td>
			</tr>
			<tr>
				<th>日本語</th>
				<td>
					<input type="text" id="ja"  style="width: 70%;height:25px" class="AXInput" />
					<input type="button" value="<spring:message code="Cache.btn_dicTrans"/>"  value="Trans" lang="ja"  onclick="bingtranslate(this); return false;" class="AXButton"  />
				</td>
			</tr>
			<tr>
				<th>中國語</th>
				<td>
					<input type="text" id="zh"  style="width: 70%;height:25px" class="AXInput" />
					<input type="button" value="<spring:message code="Cache.btn_dicTrans"/>"  value="Trans" lang="zh"  onclick="bingtranslate(this); return false;" class="AXButton"  />
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_addLanguage"/>1</th>
				<td>
					<input type="text" id="dic_addlang1"  style="width: 70%;height:25px" class="AXInput" />
					<input type="button" value="<spring:message code="Cache.btn_dicTrans"/>" onclick="" class="AXButton"   />
				</td>
			</tr>
			<tr>
				<th><spring:message code="Cache.lbl_addLanguage"/>2</th>
				<td>
					<input type="text" id="dic_addlang2"  style="width: 70%;height:25px" class="AXInput" />
					<input type="button" value="<spring:message code="Cache.btn_dicTrans"/>" onclick="" class="AXButton"  />
				</td>
			</tr>
			<%-- <tr>
				<th>추가언어3</th>
				<td>
					<input type="text" id="dic_addlang3"  style="width: 70%;height:25px" class="AXInput"  disabled="disabled"/>
					<input type="button" value="<spring:message code="Cache.btn_dicTrans"/>" onclick="" class="AXButton"  disabled="disabled" />
				</td>
			</tr>
			<tr>
				<th>추가언어4</th>
				<td>
					<input type="text" id="dic_addlang4"  style="width: 70%;height:25px" class="AXInput"  disabled="disabled"/>
					<input type="button" value="<spring:message code="Cache.btn_dicTrans"/>" onclick="" class="AXButton"  disabled="disabled" />
				</td>
			</tr>
			<tr>
				<th>추가언어5</th>
				<td>
					<input type="text" id="dic_addlang5"  style="width: 70%;height:25px" class="AXInput"  disabled="disabled"/>
					<input type="button" value="<spring:message code="Cache.btn_dicTrans"/>" onclick="" class="AXButton"  disabled="disabled" />
				</td>
			</tr>
			<tr>
				<th>추가언어6</th>
				<td>
					<input type="text" id="dic_addlang6"  style="width: 70%;height:25px" class="AXInput"  disabled="disabled"/>
					<input type="button" value="<spring:message code="Cache.btn_dicTrans"/>" onclick="" class="AXButton"  disabled="disabled"/>
				</td>
			</tr> --%>
		</table>
		<div align="center" style="padding-top: 10px">
			<input type="button" value="<spring:message code="Cache.btn_save"/>" onclick="saveDic()" class="AXButton red"/>
			<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="closeLayer()" class="AXButton"/>
		</div>
	</div>
</form>