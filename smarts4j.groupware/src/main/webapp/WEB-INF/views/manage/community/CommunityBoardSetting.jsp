<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<div class="cRConTop titType AtnTop">
	<h2 class="title">기본게시판설정</h2>
</div>
<div class="cRContBottom mScrollVH">
	<input type="hidden" id ="hiddenCategory" value = ""/>
	<input type="hidden" id ="DIC_Code_ko" value = ""/>
	<input type="hidden" id ="DIC_Code_en" value = ""/>
	<input type="hidden" id ="DIC_Code_ja" value = ""/>
	<input type="hidden" id ="DIC_Code_zh" value = ""/>
	<div id="topitembar03" class="inPerView type02 sa04 active">
		<div>
			<div class="selectCalView"> 
				<spring:message code="Cache.lbl_CommunityType"/> <!-- 커뮤니티 유형 -->
				<select id="communityCmSelBox" class="selectType02"></select>
			</div>	
			<div class="selectCalView"> 
				<spring:message code="Cache.lbl_BoardNm"/> <!-- 게시판명 -->
				<input name="search" type="text" id="searchValue"  />
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover"  id="searchBtn" ><spring:message code="Cache.btn_search"/></a>
			</div>	
		</div>	
	</div>	
    <div class="sadminContent">
		<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<a class="btnTypeDefault btnPlusAdd" onclick="confCommuBoard.boardProperty('','C');"><spring:message code="Cache.btn_Add"/></a>
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<button class="btnRefresh" type="button" href="#" id="btnRefresh"></button>
			</div>
		</div>	
		<div id="gridDiv" class="tblList"></div>
	</div>
</div>
<script type="text/javascript">
var confCommuBoard = {
		commuBoard: new coviGrid(),
		msgHeaderData: [	
			{key:'CommunityTypeName', label:'<spring:message code="Cache.lbl_CommunityType"/>', width:'80', align:'center'}, /* 커뮤니티 유형 */
	        {key:'BoardName', label:'<spring:message code="Cache.lbl_BoardNm"/>', width:'150', align:'left', formatter:function(){
				var html = "";
				if(this.item.DN_ID == confMenu.domainId){
					html = String.format("<a href='#' onclick='javascript:confCommuBoard.boardProperty({1},{2});' style='text-decoration:none'>{0}</a>", this.item.BoardName, this.item.MenuID, '');
				} else{
					html = String.format("<span disabled='disabled'>{0}</span>", this.item.BoardName);
				}
				return html;
			}}, 			/* 게시판명 */
			{key:'FolderTypeName', label:'<spring:message code="Cache.lbl_FolderType"/>', width:'80', align:'center'},		/* 폴더유형 */
			{key:'Description', sort:false, label:'<spring:message code="Cache.lbl_Description"/>', width:'300', align:'left'},
			{key:'IsUse', label:'<spring:message code="Cache.lbl_Use"/>', width:'50', align:'center', formatter : function () { /* 사용 */
				return confCommuBoard.formatSwitch(this);
			}},
			{key:'SortKey', label:'정렬', width:'50', align:'center', sort:'asc'},
			{key:'', label:"<spring:message code='Cache.lbl_action'/>", width:'100', align:'center', display:true, sort:false,
				formatter:function(){
					var html = '<div class="btnActionWrap">';
					if(this.item.DN_ID == confMenu.domainId){
						html += '<a href="javascript:;" class="btnTypeDefault btnMoveUp" onclick="confCommuBoard.moveFolder(\'up\', this);"><spring:message code="Cache.lbl_apv_up"/></a>';
						html += '<a href="javascript:;" class="btnTypeDefault btnMoveDown" onclick="confCommuBoard.moveFolder(\'down\', this);"><spring:message code="Cache.lbl_apv_down"/></a>';
					} else{
						html += '<a href="javascript:;" style="color: #999;" class="btnTypeDefault btnMoveUp"><spring:message code="Cache.lbl_apv_up"/></a>';
						html += '<a href="javascript:;" style="color: #999;" class="btnTypeDefault btnMoveDown"><spring:message code="Cache.lbl_apv_down"/></a>';
					}
					html += '</div>';
					return html;
				}
			}
			
		], 
		initLoad:function(){
			this.event();
			this.setCommunityGrid();
		},
		setCommunityGrid:function(){
			this.commuBoard.setGridHeader(this.msgHeaderData);
			this.commuBoard.setGridConfig({targetID : "gridDiv",
				listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
				height:"auto",
				page : {
					pageNo : 1 ,
					pageSize : 10
				},
				colHead:{},
				body:{
					<%--// 스위치는 msgHeaderData 에서 세팅을 해주므로 아래 항목 주석처리 함.
						// for 안의 실행 구문에서 오류발생하여 스크립트 진행 멈춤. 페이징 처리가 안됨.
					onchangeScroll: function(){
                        for(var i=this.startIndex;i<this.endIndex+1;i++){
                            $("#AXInputSwitch"+confCommuBoard.commuBoard.list[i]["MenuID"]).bindSwitch({off:"N", on:"Y"});
                        }}
					--%>
				}
			});
			
			this.selectCommunityList();				
		},
		selectCommunityList:function(){
			//폴더 변경시 검색항목 초기화
			this.commuBoard.bindGrid({
				ajaxUrl:"/groupware/manage/community/selectCommunityBoardSettingGridList.do",
				ajaxPars: {
					 domainID : confMenu.domainId,
					 code : $("#communityCmSelBox").val(),
					 searchValue : $("#searchValue").val(),
				},
				onLoad:function(){
					$("span[disabled]").closest("tr").css("background","#ffc");
				}
			});
		},
		event:function(){
			coviCtrl.renderAXSelect('CommunityDefaultBoardType', 'communityCmSelBox', lang, '', '', '', false, true);
			
			$("#searchValue").on( 'keydown',function(){
				if(event.keyCode=="13"){
					confCommuBoard.selectCommunityList();

				}
			});	
			
			$("#searchBtn").on("click",function(){
				confCommuBoard.selectCommunityList();
			});
			
			$('#selectPageSize').on('change', function(e) {
				confCommuBoard.commuBoard.page.pageSize = $(this).val();
				confCommuBoard.selectCommunityList();
			});

			$("#communityCmSelBox").change(function(){
				confCommuBoard.selectCommunityList();
			});
			$("#btnRefresh").on("click",function(){
				confCommuBoard.selectCommunityList();
			});

			
		},
		updateIsCheck:function(pMenuID, pIsUse, pTarget){
			$.ajax({
				type:"POST",
				data:{
					"MenuID" : pMenuID,
					"IsUse" : pIsUse
				},
				url:"/groupware/manage/community/boardSettingUseChange.do",
				success:function (data) {
					if(data.status == "SUCCESS"){
						Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
					}else{ 
						Common.Error("<spring:message code='Cache.msg_changeFail'/>");
						
						if(pIsUse == 'Y'){
							$(pTarget).removeClass("on");
							$("#switch_"+pMenuID).val($("#switch_"+pMenuID).attr("off_value"));
						} else {
							$(pTarget).addClass("on");
							$("#switch_"+pMenuID).val($("#switch_"+pMenuID).attr("on_value"));
						}
					}				
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("/groupware/manage/community/boardSettingUseChange.do", response, status, error);
				}
			}); 
			
		},
		boardProperty:function(MenuID, Type){
			var url = "";
			
			if(Type == "" || Type == null){
				Type = "E";
			}
			
			url = "/groupware/manage/community/communityBoardSettingProperty.do?DN_ID="+confMenu.domainId+"&MenuID="+MenuID+"&mode="+Type;
			Common.open("", "CommunityBoardSettingPopup", "<spring:message code='Cache.lbl_CommuntyBoardSetting'/>", url, "650px", "300px", "iframe", true, null, null, true);
		},
		moveFolder: function(pMode, elem){
			var idx = $("#gridDiv .gridBodyTr").index($(elem).parents('tr:first'));
			var selectedItem = confCommuBoard.commuBoard.list[idx];
			console.log(selectedItem);
			$.ajax({
				type: "POST",
				url: "/groupware/manage/community/moveFolder.do",
				dataType: 'json',
				data: {
					"domainID": confMenu.domainId,
					"menuID": selectedItem.MenuID,
					"communityType": selectedItem.CommunityType,
					"sortKey": selectedItem.SortKey,
					"mode": pMode
				},
				success: function(data){
					if(data.status === 'SUCCESS'){
						if(data.message){
							Common.Inform(data.message); // 최상위, 최하위 항목의 경우에는 변경 불가 메시지 표시
						} else {
							Common.Inform("<spring:message code='Cache.msg_Changed'/>"); // 변경했습니다.
						}
						
						confCommuBoard.refresh();
					}else{
						Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
					}
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/board/manage/moveFolder.do", response, status, error);
				}
			});
		},
		refresh: function(){
			confCommuBoard.selectCommunityList();
		},
		formatSwitch: function(pObj){
			var html = "";
			var param = pObj.item;
			
			if(param.DN_ID == confMenu.domainId){
				param.on = 'Y'; param.off = 'N';
				param.defVal = param[pObj.key];
				param.retVal = param.MenuID;
				html = coviCmn.getCoviSwitch('switch_'+param.MenuID, param, 'confCommuBoard.updateIsCheck');
			} else{
				html = param.IsUse;
			}
			return html;
		}
}
window.onload = confCommuBoard.initLoad();
</script>