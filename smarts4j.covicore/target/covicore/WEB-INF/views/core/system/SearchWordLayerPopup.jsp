<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/CoreInclude.jsp"></jsp:include>
<div>
	<table class="AXFormTable">
		<tr>
			<th><spring:message code="Cache.ObjectType_DN"/></th><!-- 도메인(회사) -->
			<td colspan="3">
				<select id="domainID" class="AXSelect" style="width:100px;"></select>
			</td>
		</tr>
		<tr>
			<th><font color="red">*</font><spring:message code="Cache.lbl_System"/></th><!-- 시스템 -->
			<td colspan="3">
				<input type="text" id="system" class="AXInput HtmlCheckXSS ScriptCheckXSS required" data-dic-code="lbl_System" style="width: 90%;"/>
			</td>
		</tr>
		<tr>
			<th><font color="red">*</font><spring:message code="Cache.lbl_SearchWord"/></th><!-- 검색어 -->
			<td colspan="3">
				<input type="text" id="searchWord" class="AXInput HtmlCheckXSS ScriptCheckXSS required" data-dic-code="lbl_SearchWord" style="width: 70%;"/>
				<input type="button" id="checkBtn" value="<spring:message code="Cache.btn_CheckDouble"/>" onclick="checkSearchWord(this);" data-checked="N" class="AXButton" />
			</td>
		</tr>
		<tr>
			<th><font color="red">*</font><spring:message code="Cache.lbl_SearchNum"/></th><!-- 검색수 -->
			<td>
				<input type="text" id="searchCount" mode="number" class="AXInput required" data-dic-code="lbl_SearchNum" style="width: 90%;" value="0"/>
			</td>
			<th><spring:message code="Cache.lbl_PointTitle"/></th><!-- 포인트 -->
			<td>
				<input type="text" id="recentlyPoint" mode="number" class="AXInput" style="width:90%;"/>
			</td>
		</tr>
		<tr>
			<th><spring:message code="Cache.lbl_FirstSearchDate"/></th><!-- 최초 검색일 -->
			<td>
				<input type="text" id="createDate" class="AXInput" style="width: 90%;" data-axbind="date" kind="date"/>
			</td>
			<th><spring:message code="Cache.lbl_LastSearchDate"/></th><!-- 최종 검색일 -->
			<td>
				<input type="text" id="searchDate" class="AXInput" style="width: 90%;" data-axbind="date" kind="date"/>
			</td>
		</tr>
	</table>
	<div align="center" style="padding-top: 10px">
		<input type="button" id="btn_create" value="<spring:message code="Cache.btn_Add"/>" onclick="setSearchWord('add');" class="AXButton red" />
		<input type="button" id="btn_modify" value="<spring:message code="Cache.btn_Edit"/>" onclick="setSearchWord('modify');" style="display: none"  class="AXButton red" />
		<input type="button" value="<spring:message code="Cache.btn_Close"/>" onclick="Common.Close();"  class="AXButton" />
	</div>
</div>
<script type="text/javascript">
var mode = CFN_GetQueryString("mode");
var searchWordID = CFN_GetQueryString("searchWordID");

//개별호출 일괄처리
var sessionObj = Common.getSession();

InitContent();

function InitContent(){
	if(mode == "modify"){
		$("#btn_create").hide();
		$("#btn_modify").show();
		$("#checkBtn").data("checked", "Y");
	}
	
	//SelectBox 셋팅
	coviCtrl.renderDomainAXSelect(
			"domainID"
			, sessionObj["lang"]
			, ""
			, "getSearchWordData"
			, sessionObj["DN_ID"]
		);
	
	$("#searchWord, #system").on("change", function(){
		$("#checkBtn").data("checked", "N");
	});
}

function getSearchWordData(){
	if(mode == "modify"){
		$.ajax({
			type:"POST",
			data:{
				"searchWordID" : searchWordID
			},
			url:"/covicore/searchWord/getData.do",
			success : function (result) {
				if(result.status == "SUCCESS"){
					$("#domainID").bindSelectSetValue(result.data.DomainID);
					$("#system").val(result.data.System);
					$("#searchWord").val(result.data.SearchWord);
					$("#searchCount").val(result.data.SearchCnt);
					$("#recentlyPoint").val(result.data.RecentlyPoint);
					$("#createDate").val(result.data.CreateDate);
					$("#searchDate").val(result.data.SearchDate);
				}else{
					Common.Error("<spring:message code='Cache.msg_apv_005'/> : "+result.message);
				}
			},
			error:function (error){
				CFN_ErrorAjax("/covicore/searchWord/getData.do", response, status, error);
			}
		});
	}
}

function setSearchWord(btnMode){
	var domainID = $("#domainID").val() == undefined ? "0" : $("#domainID").val();
	var system = $("#system").val();
	var searchWord = $("#searchWord").val();
	var searchCount = $("#searchCount").val();
	var recentlyPoint = $("#recentlyPoint").val();
	var createDate = $("#createDate").val();
	var searchDate = $("#searchDate").val();

	if (!XFN_ValidationCheckOnlyXSS(false)) { return; }
	
	if (!isValid()) { return false; }
	
	if ($("#checkBtn").data("checked") == 'N') {
		Common.Warning(Common.getDic('msg_CheckDoubleAlert'), "Warning", null);
		return false;
	}
	
	$.ajax({
		type:"POST",
		data:{
			"mode" : mode,
			"searchWordID" : searchWordID,
			"domainID" : domainID,
			"system" : system,
			"searchWord" : searchWord,
			"searchCount" : searchCount,
			"recentlyPoint" : recentlyPoint,
			"createDate" : createDate,
			"searchDate" : searchDate
		},
		url:"/covicore/searchWord/setData.do",
		success : function (result) {
			if(result.status == "SUCCESS"){
				Common.Inform("<spring:message code='Cache.msg_com_processSuccess'/>", "Inform", function(){
					Common.Close();
					parent.searchSearchWord();
				});
			}else{
				Common.Error("<spring:message code='Cache.msg_apv_005'/> : "+result.message);
			}
		},
		error:function (error){
			CFN_ErrorAjax("/covicore/searchWord/setData.do", response, status, error);
		}
	});
}

function isValid(){
	var isRequired = true;

	$.each($(".required"), function(idx, el){
		if (el.value == ''){
			Common.Warning("<spring:message code='Cache.msg_EnterTheRequiredValue'/>".replace("{0}", Common.getDic(el.dataset.dicCode)), "Warning", function(){
				$(el).focus();
			});
			
			return isRequired = false;
		}
	});
	
	return isRequired;
}

function checkSearchWord(obj){
	if (!XFN_ValidationCheckOnlyXSS(false)) { return false; }
	
	if (!isValid()) { return false; }
	
	$.ajax({
		type:"POST",
		data:{
			"domainID" : $("#domainID").val() == undefined ? "0" : $("#domainID").val(),
			"system" : $("#system").val(),
			"searchWord" : $("#searchWord").val()
		},
		url:"/covicore/searchWord/checkDouble.do",
		success : function (result) {
			if(result.status == "SUCCESS"){
				
				Common.Inform(((result.duplicated == 'N') ? Common.getDic('lbl_apv_useOK') : Common.getDic('msg_sns_doubled')), "Inform", function(){
					if(result.duplicated == 'N') $(obj).data("checked", 'Y');
				});
			}else{
				Common.Error(Common.getDic('msg_apv_005') + " : "+result.message);
			}
		},
		error:function (error){
			CFN_ErrorAjax("/covicore/searchWord/checkDouble.do", response, status, error);
		}
	});	
}
</script>