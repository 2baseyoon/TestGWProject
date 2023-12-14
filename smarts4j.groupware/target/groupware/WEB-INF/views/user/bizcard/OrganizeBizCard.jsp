<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/groupware/resources/script/user/bizcard.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/groupware/resources/script/user/bizcard_list.js<%=resourceVersion%>"></script>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
</head>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_ArrangeContact' /></h2> <!-- 연락처 정리하기 -->
</div>
<div class="cRContBottom mScrollVH">
	<div class="bizcardAllCont">
		<div class="bizcardListBox listDuplication">
			<!-- 탭 -->
			<ul id="ulTabTray" class="tabType2 clearFloat">
				<li class="active">
					<a id="bizCardDuplicateTab" href="#" onclick="clickTab(this);" class="AXTab on" value="Name"><spring:message code='Cache.lbl_name'/></a> <!-- 이름 -->
				</li>
				<li>
					<a id="bizCardDuplicateTab" href="#" onclick="clickTab(this);" class="AXTab" value="Phone"><spring:message code='Cache.lbl_MobilePhone'/></a> <!-- 핸드폰 -->
				</li>
				<li>
					<a id="bizCardDuplicateTab" href="#" onclick="clickTab(this);" class="AXTab" value="Email"><spring:message code='Cache.lbl_Email2'/></a> <!-- 이메일 -->
				</li>
			</ul>
			<!-- // 탭 -->

			<div class="topInfoBox">
				<dl>
					<dt class="bulDashedTitle"><span class="colorTheme">*</span> <spring:message code="Cache.lbl_aboutContactArrange" /> <!-- 연락처 정리란? --> </dt>
					<dd>
						<ul class="bulDashedList">
							<li><spring:message code="Cache.msg_ArrangeContactDescription" /></li>  <!-- 유사한 연락처를 수정하거나 삭제하여 정리 할 수 있습니다. -->
						</ul>
					</dd>
				</dl>
			</div>

			<div class="tabCont">

				<!-- 목록보기-->
				<div class="tblList tblCont tblBizcardList mt30">
					
					<div id="AXGridTarget" style="height: auto;">
						<!-- Grid -->
						<div id="resultBoxWrap">
							<div id="bizCardGrid"></div>
						</div>
					</div>
					<div class="btnBttmWrap">
						<a href="#" d="btnDelete" class="btnTypeDefault btnTypeBg02" onclick="DeleteCheck(bizCardGrid,'A','Person');">
							<spring:message code="Cache.btn_delete" /> <!-- 삭제하기 -->
						</a> 
					</div>				
				</div>
				<!-- // 목록보기-->

			</div>

		</div>
	</div>												
</div>					


<script>

	var bizCardViewType = "P";
	var bizCardGrid = new coviGrid();

	//***************************************************************************************************************************/
	
	// 새로고침
	function refresh(){
		bindGridData();
	}

	//닫기
	var closeBizCard = function() {
		if (document.referrer) { 			
			window.history.back(); // 뒤로가기
		} else { // 히스토리가 없으면,
			window.location.href='bizcardhome.do'; // 메인 페이지로
		}
	}
	
	//***************************************************************************************************************************/
	
	//Grid 생성 관련
	function setGrid(){		
			bizCardGrid.setGridHeader([
							  {key:'chk', label:'chk', width:'20', align:'center', sort:false, formatter: 'checkbox'},
			                  {key:'Name',  label:"<spring:message code='Cache.lbl_name'/>", width:'100', align:'center', sort:false, //이름
			                	  formatter : function() {
			      					  return this.item.Name;
			                  }},
			                  {key:'PhoneNum',  label:"<spring:message code='Cache.lbl_MobilePhone'/>", width:'70', align:'center', sort:false, formatter : function() { //핸드폰
			                		var strTarget = this.item.Target;
			                		var strReturn = "";
			                		if(this.item.PhoneNum != null){
			                			strReturn = "<div class=\"ellipsis\">";
			                			var arrPhone = this.item.PhoneNum.split("|");
			                			 arrPhone.forEach(function(strValue){
		                					   strReturn += strValue;
			                				   strReturn += "<br/>";
			                				}//function 
			                			)//forEach
			                			strReturn += "</div>";
			                		}//if
			                		return strReturn;
         					  }},
         					  {key:'EMAIL', label:"<spring:message code='Cache.lbl_Email2'/>", width:'70', align:'center', sort:false, formatter : function() { //이메일
         						  var strTarget = this.item.Target;
			                	  var strReturn = "";
			                		if(this.item.EMAIL != null){
			                			strReturn = "<div class=\"ellipsis\">";
			                			var arrEMAIL = this.item.EMAIL.split("|");
			                			arrEMAIL.forEach(function(strValue){
				                				strReturn += strValue;
				                				strReturn += "<br/>";
			                				}//function 
			                			)//forEach
			                			strReturn += "</div>";
			                		}//if
			                		return strReturn;
			                  }},
			                  {key:'ComName',  label:"<spring:message code='Cache.lbl_Company'/>", width:'50', align:'center', sort:false}, //회사
			                  {key:'JobTitle', label:"<spring:message code='Cache.lbl_JobTitle'/>", width:'50', align:'center', sort:false}, //직책
			                  {key:'ShareType',  label:"<spring:message code='Cache.lbl_Division'/>", width:'50', align:'center', sort:false, formatter : function() { //구분
			                	  var shareType = "";
			                	  switch(this.item.ShareType) {
			                	  case 'P' : shareType = "<spring:message code='Cache.lbl_ShareType_Personal'/>"; break; //개인
			                	  case 'D' : shareType = "<spring:message code='Cache.lbl_ShareType_Dept'/>"; break; //부서
			                	  case 'U' : shareType = "<spring:message code='Cache.lbl_ShareType_Comp'/>"; break; //회사
			                	  }
			                	  return shareType;
		                	  }},
		                	  {key:'BizCardID',  label:"<spring:message code='Cache.lbl_Modify'/>", width:'40', align:'center', sort:false, formatter : function() {
			                	  return '<button id="btnModify" type="button" class="AXButton btnThemeLine" onclick="modifyBizCard('+this.item.BizCardID+');"><spring:message code="Cache.btn_Edit" /></button>'; //<!-- 수정 -->
		                	  }}
				      		]);
		setGridConfig();
		bindGridData();
	}
	
	//Grid 설정 관련
	function setGridConfig(){
		var configObj = {
			targetID : "bizCardGrid",		// grid target 지정
			height:"auto",
			paging : false
		};
		
		// Grid Config 적용
		bizCardGrid.setGridConfig(configObj);
	}	

	//Grid 값 바인딩
	function bindGridData() {	
		
		var tabFilter = $('#ulTabTray').find(".active").children().attr('value');

		bizCardGrid.bindGrid({
			ajaxUrl:"/groupware/bizcard/getBizCardSimilarList.do",
			ajaxPars: {
				type : tabFilter,
			},
			onLoad:function () {
				$("input[type=checkbox]:not([class])").prop("checked", true);
				$("input[type=checkbox]:not([class])").click(function() {
					$("input[value=" + this.value + "]:not([class])").prop("checked", this.checked);
				});
			}
		});
	}
		
	//탭 선택(그리드 헤더 변경)
	function clickTab(pObj){
		bizCardGrid = new coviGrid();	

		$("#ulTabTray").find("li").removeClass("active");
		$(pObj).parent().addClass("active");
		

		setGrid();	//탭선택에 따른 그리드  변경을 위해 setGrid()호출
	}
	
	function modifyBizCard(pID) {
		Common.open("", "ModifyBizCardPersonPop", "<spring:message code='Cache.lbl_ModifyBizCard'/>", "/groupware/bizcard/ModifyBizCardPersonPop.do?BizCardID=" + encodeURIComponent(pID) + "&TypeCode=P", "1000px", "880px", "iframe", true, null, null, true);
		
		console.dir(event);
		// 이벤트 기본동작 방지
		event.preventDefault ? event.preventDefault() : (event.returnValue = false);	
		// 버블링 방지
		event.stopPropagation ? event.stopPropagation() : (event.cancelBubble = true);	
		
		return false;
	}

	window.onload = initContent();
		
	function initContent(){
		//그리드 설정
		setGrid();
	}

</script>