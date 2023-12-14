<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<style>
.AXGrid input:disabled{background-color:#Eaeaea}
</style>

<div class="layer_divpop ui-draggable taskPopLayer" id="testpopup_p" style="width:500px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent taskAppointedContent">
			<!--팝업 내부 시작 -->
			<div class="selectSearchBox">
				<span><spring:message code='Cache.lbl_USER_NAME_01'/></span> <!-- 사용자명 -->
				<span><input id="searchWord" type="text"><a id="btnSearch" class="btnSearchType01"></a></span>
				<button id="btnRefresh" class="btnRefresh" type="button"></button>					
			</div>
			<div class="surTargetBtm">
				<div class="tblList">
					<div id="grid"></div>
				</div>
			</div>
			<div class="bottom">
				<a id="btnConfirm" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.lbl_Confirm'/></a> <!-- 확인 -->
				<a id="btnCancel" class="btnTypeDefault"><spring:message code='Cache.lbl_Cancel'/></a> <!-- 취소 -->
			</div>
			<!--팝업 내부 끝 -->
		</div>
	</div>
</div>

<script type="text/javascript">
	
	(function(param){
		var grid = new coviGrid();
		
		var init = function(){
			setEvent();
			setGridConfig();
			setGrid();
		}
		
		var setEvent = function(){
			$("#searchWord").on("keypress", function(){
				if(event.keyCode === 13) search();
			});
			
			$("#btnSearch").on("click", search);
			
			$("#btnRefresh").on("click", refresh);
			
			$("#btnConfirm").on("click", function(){
				setPerformer();
			});
			
			$("#btnCancel").on("click", function(){
				Common.Close();
			});
		}
		
		// 그리드 Config 설정
		var setGridConfig = function(){
			grid.setGridHeader([	            
  				{key:'chk', label:'chk', width:'10', align:'center', formatter: 'checkbox', formatter:'checkbox', disabled: function (){
  	        	    return this.item.IsAlloc == this.item.UserCode;
  		           }}, 
				{key:'PhotoPath', label:" ", width:'15', align:'right', sort: false, formatter: function(){
					var $div = $("<div />", {"class": "perPhoto"});
					$div.append($("<img />", {"src": coviCmn.loadImage(this.item.PhotoPath), "style": "width:100%; height:100%;", "onerror": "coviCmn.imgError(this, true);"}));
					
					return $div.prop("outerHTML");
				}},
				{key:'DisplayName', label:"<spring:message code='Cache.lbl_name'/>", width:'30', align:'center', sort: "asc"},  /*이름*/
				{key:'DeptName', label:"<spring:message code='Cache.lbl_dept'/>", width:'50', align:'center'} /*부서*/
			]);
			
			var configObj = {
				targetID: "grid",
				height: "auto",
				paging: true,
				page: {
					pageNo: 1,
					pageSize: 8
				}
			};
			
			grid.setGridConfig(configObj);
		}
		
		//그리드 세팅
		var setGrid = function(){
			grid.bindGrid({
				ajaxUrl: "/groupware/collabProject/getProjectMemberTagList.do",
				ajaxPars: {
					"prjSeq"	: param.prjSeq,
					"userCodes"	: param.userCodes,
					"searchWord": $("#searchWord").val()
				}
			});			
		}
		
		var refresh = function(){
			grid.reloadList();
		}
		
		var search = function(){
			grid.page.pageNo = 1;
			setGrid();
		}
		
		var setPerformer = function(){
			var result = {
				  "currentDiv":	param.currentDiv
				, "list":		grid.getCheckedList(0)
			};
			
			window.parent.postMessage({
				  "functionName": param.callback
				, "params": result
			}, '*');
			
			Common.Close();
		}
		
		init();
		
	})({
		  userCodes:		"${userCodes}"
		, callback:			"${callback}"
	});
</script>