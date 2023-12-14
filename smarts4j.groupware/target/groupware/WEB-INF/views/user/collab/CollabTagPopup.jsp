<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="spring-commons-validator" uri="http://www.springmodules.org/tags/commons-validator" %>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>


<style type="text/css">
	.AXGrid .AXgridScrollBody .AXGridColHead .colHeadTable tbody tr td.colHeadTdLast {
		background: none;
	}

	.AXGrid .AXgridScrollBody .AXGridBody .gridBodyTable tbody tr td.isTdEnd {
		background-image: none;
	}
</style>

<script id="jscode">
	AXConfig.AXGrid.fitToWidthRightMargin = -1;
	var pageID = "AXGrid";
	var AXGrid_instances = [];
	var fnObj = {
		pageStart: function () {
			fnObj.grid.bind();
			myGrid.setHeight(700);
		},
		grid: {
			target: new AXGrid(),
			bind: function () {
				window.myGrid = fnObj.grid.target;
				myGrid.setConfig({
							targetID: "AXGridTarget",
							sort: false,
							fixedColSeq: 3,
							colGroup: [
								{key: "ManagementSeq", label: "<spring:message code='Cache.lbl_Num' />", width: "50", align: "center", formatter: "checkbox"}, //번호
								{
									key: "_CUD", label: "<spring:message code='Cache.lbl_Status' />", width: "50", align: "center" //상태
								},
								{
									key: "TagName", label: "<spring:message code='Cache.lbl_TagName' />", width: "400",align: "center", //태그명
									formatter: "TagName",
									editor: {
										type: "String",
										updateWith: ["TagName", "_CUD"]
									}
								},
								{
									key: "DisplayName", label: "<spring:message code='Cache.lbl_Register' />", width: "200",align: "center", //등록자
								},
							],
							colHeadAlign: "center", // 헤드의 기본 정렬 값 ( colHeadAlign 을 지정하면 colGroup 에서 정의한 정렬이 무시되고 colHeadAlign : false 이거나 없으면 colGroup 에서 정의한 속성이 적용됩니다.
							body: {
								onclick: function () {
								}
					},
					contextMenu: {
						theme:"AXContextMenu", // 선택항목
						width:"150", // 선택항목
						menu:[
							{
								userType:1, label:"<spring:message code='Cache.lbl_AddIt' />", className:"plus", onclick:function(){ //추가하기
									myGrid.appendList(null);
									//myGrid.appendList(item, index);
									/*
                                    var removeList = [];
                                        removeList.push({no:this.sendObj.item.no});
                                    myGrid.removeList(removeList); // 전달한 개체와 비교하여 일치하는 대상을 제거 합니다. 이때 고유한 값이 아닌 항목을 전달 할 때에는 에러가 발생 할 수 있습니다.
                                    */
								}
							},
							{
								userType:1, label:"<spring:message code='Cache.lbl_DeleteIt' />", className:"minus", onclick:function(){ //삭제하기
									if(this.sendObj){
										if(!confirm("<spring:message code='Cache.lbl_apv_alert_delete' />")) return; //정말 삭제 하시겠습니까?
										var removeList = [];
										removeList.push({no:this.sendObj.item.no});
										myGrid.removeList(removeList); // 전달한 개체와 비교하여 일치하는 대상을 제거 합니다. 이때 고유한 값이 아닌 항목을 전달 할 때에는 에러가 발생 할 수 있습니다.
									}
								}
							},
							{
								userType:1, label:"<spring:message code='Cache.lbl_FixingIt' />", className:"edit", onclick:function(){ //수정하기
									//trace(this);
									if(this.sendObj){
										myGrid.setEditor(this.sendObj.item, this.sendObj.index);
									}
								}
							}
						],
						filter:function(id){
							return true;
						}
						}
					}
				);
				fnObj.grid.search();
			},

			append : function (v){
				if($("#tag").val()!= null && $("#tag").val() != ''){
					fnObj.grid.mod(v);
				} else {
					alert("<spring:message code='Cache.msg_PleaseTag' />"); //태그명을 입력해주세요.
					$("#tag").focus();
					return false;
				}
				//myGrid.appendList(null);
			},
			mod: function (v) {
				var checkedList;
				var TagNameList = new Array();
				var ManagementSeq = new Array();
				switch (v) {
					case 'C' :
								TagNameList.push($("#tag").val());
								ManagementSeq.push('1');
								break;
					case 'D' : checkedList = myGrid.getCheckedList(0);
						if(checkedList.length > 0){
							if (confirm("<spring:message code='Cache.msg_ReallyDelete' />")) { //정말 삭제하시겠습니까?
								$.each(checkedList,function(){
									TagNameList.push(this.TagName);
									ManagementSeq.push(this.ManagementSeq);
								});
							}
						} else {
							alert("<spring:message code='Cache.msg_PleaseCheckbox' />"); //체크박스를 선택해주세요.
							return;
						}
					break;
					case 'U' : checkedList = myGrid.getList();
						$.each(checkedList,function(){
							if(this._CUD === 'U'){
								TagNameList.push(this.TagName);
								ManagementSeq.push(this.ManagementSeq);
							}
						});
					break;
				}
				//ajax 호출
				$.ajax({
					url : "/groupware/collab/todo/todoTagMod.do",
					type        :   "post",
					traditional: true,
					data:{
							"type" : v ,
							"tagNameList" : TagNameList,
							"managementSeq" : ManagementSeq,
					},
					success : function(res){
						if(res.result === 'ok'){
							fnObj.grid.search();
							alert(res.msg);
							if(v === 'C')$("#tag").val('');
						}
					},
					error : function(request, status, error){
						coviCmn.traceLog("AJAX_ERROR");
					}
				});
			},
			search: function () {
				var url ="/groupware/collab/todo/todoTagList.do";
				$.ajax({
					type : "POST",
					url : url,
					data : null,
					success : function(res){
						if(res.result === 'ok'){
							myGrid.setList(res.tagList, null, "reload");
						}
					},
					error : function(XMLHttpRequest, textStatus, errorThrown){ // 비동기 통신이 실패할경우 error 콜백으로 들어옵니다.
						alert("<spring:message code='Cache.msg_ComFailed' />"); //실패하였습니다.
					}
				});
			},
		}
	};
	jQuery(document.body).ready(function () {
		fnObj.pageStart();
	});
</script>
</head>
<body>
<div id="AXPage">
	<div id="AXPageBody" class="SampleAXSelect">
		<div id="demoPageTabTarget" class="AXdemoPageTabTarget"></div>
		<div class="AXdemoPageContent">
			<div id="grid0">
				<div id="AXGridTarget" style="height:300px;"></div>
				<div>태그명 : <input type="text" name="tag" id="tag" size="100%"></div>
				<div style="padding:10px;">
					<input type="button" value="<spring:message code='Cache.lbl_Regist' /> " class="AXButton" onclick="fnObj.grid.append('C');"/> <!-- 등록 -->
					<input type="button" value="<spring:message code='Cache.btn_Edit' />" class="AXButton" onclick="fnObj.grid.mod('U');"/> <!-- 수정 -->
					<input type="button" value="<spring:message code='Cache.btn_delete' />" class="AXButton" onclick="fnObj.grid.mod('D');"/> <!-- 삭제 -->
				</div>
			</div>
			<pre id="pretty" class="prettyprint linenums"></pre>
			<div id="printout"></div>
		</div>
	</div>
</div>
</body>
</html>