<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!doctype html>
<html>
<head>
<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
<meta http-equiv='cache-control' content='no-cache'> 
<meta http-equiv='expires' content='0'> 
<meta http-equiv='pragma' content='no-cache'>
</head>
<body style="overflow : hidden;">
<div style="padding:10px;">
	<!-- 탭 -->
	<div id="tabBox" class="AXTabs">
		<div class="AXTabsTray">
			<div class="trayScroll">
				<a id="manageTab" href="#" class="AXTab" onclick="changeTab(this)">구분/분류 관리</a>
				<span class="AXTabSplit"></span>
				<a id="settingTab" href="#" class="AXTab" onclick="changeTab(this)">구분별 분류 설정</a>
				<span class="AXTabSplit"></span>
			</div>
		</div>
	</div>
	
	<!-- 구분 / 분류 관리 -->
	<div id="manageTabPage" class="tabPages" style="display:none; padding : 10px;">
		<div class="filterWrap" style="margin-bottom : 10px;">
			<select id="selManageValue" onchange="changeCate();">
				<option value="division">업무 구분 관리</option>
				<option value="type">업무 분류 관리</option>
			</select>
		</div>
		
		<!-- 구분 -->
		<div id="manageResultBoxWrap">
			<div style="margin-bottom: 5px; width:640px; text-align:right; height:30px;">
				<input type="text" id="txtCateCode" class="AXInput W100" placeholder="코드" onkeyup="chkduplicate(this)"/>
				<input type="text" id="txtCateName" class="AXInput W200" placeholder="분류명"/>
				<input type="hidden" id="hidDuplicateChk" value="0" />
				<button type="button" id="btnAdd" class="AXButton" onclick="cateRegist()">추가</button>
			</div>
			<div id="cateGrid" style="width:640px; display:inline-block;"></div>
		</div>
	</div>
	
	<!-- 구분 별 분류 관리 -->
	<div id="settingTabPage" class="tabPages" style="display:none; padding : 10px 10px 0px 10px;">
		<div style="margin-bottom:10px;">
			<span>업무구분 : </span>
			<select id="selDivision" style="min-width:150px;" onchange="divisionChange(this)"></select>
			
			<button type="button" class="AXButtonSmall Red" onclick="acceptWorkType()">저장</button>
		</div>
		
		<div>
			<div style="border : 1px solid #c9c9c9; width:300px; height:380px; display:inline-block; float:left;">
				<div style="width:100%; height:30px; background-color : #f8f8f8;">
					<h3 class="titIcn" style="font-size:12px!important;">분류 전체</h3>
					<span style="float:right; padding:0px 6px 0px 0px;">
						<input type="checkbox" data-chkname='chkalltype' class='allchkcls' onchange="selctAllType(this)"/>
						<span style='font-size:11px;'>전체선택</span>
					</span>
				</div>
				<div style="overflow:auto; height:350px; width:100%;" id="allTypeListBox">
					
				</div>
			</div>
			<div style="width:50px; display:inline-block; height:380px; float:left;">
				<input type="button" style="margin:160px 0 5px 13px!important;" class="btnRight" value=">" onclick="setWorkCateType();">
	      		<input type="button" style="margin:0 0 0 13px!important;" class="btnLeft" value="<" onclick="deleteWorkCateType();">
			</div>
			<div style="border : 1px solid #c9c9c9; width:300px; height:380px; display:inline-block; float:left;">
				<div style="width:100%; height:30px; background-color : #f8f8f8;">
					<h3 class="titIcn" style="font-size:12px!important;">선택 분류</h3>
					<span style="float:right; padding:0px 6px 0px 0px;">
						<input type="checkbox" data-chkname='chkseltype' class='allchkcls' onchange="selctAllType(this)"/>
						<span style='font-size:11px;'>전체선택</span>
					</span>
				</div>
				<div style="overflow:auto; height:350px; width:100%;" id="selectTypeListBox">
					
				</div>
			</div>
		</div>
		
		
		<textarea id="hidOldSelectType" style="display:none;"></textarea>
		<textarea id="hidNewSelectType" style="display:none;"></textarea>
		<textarea id="hidDelSelectType" style="display:none;"></textarea>
	</div>

</div>
<script>
	// Grid 변수 추가
	var cateGrid = new coviGrid();


	var changeTab = function(pTarget) {
		var targetObj = $(pTarget);
		var targetID = targetObj.attr("id");
		
		// 구분별 분류 설정 탭으로 이동 시 selectBox Binding
		if(targetID == "settingTab") {
			bindOption();
			// reload
			divisionChange($("#selDivision")[0]);
		}
		
		// on 모두 제거
		$("#tabBox .AXTab").removeClass("on");
		
		// 선택된 탭에 on 모드 추가
		targetObj.addClass("on");
		
		// page hide & show
		$(".tabPages").hide();
		$("#" + targetID + "Page").show();
	};


	// Grid 관련
	//Grid 생성 관련
	function setGrid(){
		cateGrid.setGridHeader([
			                  {key:'code',  label:'코드', width:'200', align:'center'},
			                  {key:'name',  label:'분류', width:'200', align:'center'},
			                  {key:'refcnt', label:'삭제', width:'200', align:'center',
			                	  formatter : function() {
			                		  if(this.item.refcnt == 0) {
			                		  	return '<button type=\'button\' class="AXButtonSmall" onclick=\'deleteCate("' + this.item.code + '")\'>삭제</button>';
			                		  } else {
			                			return "<span style='color:red;'>삭제불가</span>"
			                		  }
			                	  }}
				      		]);
		setGridConfig();
	}
	
	
	function bindGridData(pUrl) {
		cateGrid.bindGrid({
			ajaxUrl : pUrl,
			onLoad : function () {
				cateGrid.fnMakeNavi("cateGrid");
			}
		});
	}

	//Grid 설정 관련
	function setGridConfig(){
		var configObj = {
			targetID : "cateGrid",		// grid target 지정
			sort : false,		// 정렬
			colHeadTool : false,	// 컬럼 툴박스 사용여부
			fitToWidth : true,		// 자동 너비 조정 사용여부
			colHeadAlign : 'center',
			height:'auto',
			page : {
				pageNo : 1,
				pageSize : 6
			},
			paging : true
		};
		
		// Grid Config 적용
		cateGrid.setGridConfig(configObj);
	}
	
	
	var changeCate = function() {
		var pObj = $(event.target);
		var selValue = pObj.val();
		
		if(selValue.toLowerCase() == "type") {
			bindGridData("WorkReportCateTypeList.do");
		} else if(selValue.toLowerCase() == "division") {
			bindGridData("WorkReportCateDivList.do");
		}
		
		// Control 초기화
		$("#txtCateCode").val("");
		$("#txtCateName").val("");
		$("#hidDuplicateChk").val(0);
		$("#txtCateCode").css("border-color", "#c6c6c6");
		$("#txtCateCode").css("background-color", "#fff");
	};
	
	var cateRegist = function() {
		var selCate = $("#selManageValue").val();
		var cateName = $("#txtCateName").val();
		var cateCode = $("#txtCateCode").val();
		
		var dup = $("#hidDuplicateChk").val();
		
		if(selCate == "" || cateName == "" || cateCode == "") {
			Common.Inform("입력값이 누락되었습니다. 확인해주세요", "알림");
			return;
		}
		
		if(dup != 1) {
			Common.Inform("이미 사용된 코드입니다. 다른 코드를 사용해 주세요", "알림");
			$("#txtCateCode").focus();
			return;
		} else {
			// 코드 등록
			$.post("AddWorkReportCate.do", {
				cate : selCate,
				name : cateName,
				code : cateCode
			}, function() {
				cateGrid.reloadList();
				$("#txtCateName").val("");
				$("#txtCateCode").val("");
				$("#hidDuplicateChk").val("0");
				$("#txtCateCode").css("border-color", "#c6c6c6");
				$("#txtCateCode").css("background-color", "#fff");
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("AddWorkReportCate.do", response, status, error);
			});
		}
	};
	
	var chkduplicate = function(pObj) {
		var selCate = $("#selManageValue").val();
		var pCode = $(pObj).val();
		
		if(pCode != "") {
			//hidDuplicateChk
			var flag = false;
			var matchStr = pCode.match(/[a-z]{1,2}/i);
			
			if(!matchStr) flag = false;
			else flag = (pCode == matchStr);
			
			// 1~2글자 영문일경우에만
			if(flag) {
				$.getJSON("DuplicateWorkCate.do",{cate : selCate, code : pCode }, function(d) {
					var cnt = d.cnt;
					if(cnt == 0) {
						// 사용가능
						$("#txtCateCode").css("border-color", "#55c866");
						$("#txtCateCode").css("background-color", "#c8ffc8");
						
						$("#hidDuplicateChk").val("1");
					} else {
						// 사용불가
						$("#txtCateCode").css("border-color", "#c85566");
						$("#txtCateCode").css("background-color", "#ffc8c8");
						
						$("#hidDuplicateChk").val("0");
					}
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("DuplicateWorkCate.do", response, status, error);
				});
			} else {
				$(pObj).val("");
				$("#txtCateCode").css("border-color", "#c6c6c6");
				$("#txtCateCode").css("background-color", "#fff");
				
				Common.Inform("사용할 수 없는 코드 형식입니다.<br/>1~2글자 사이의 알파벳만 사용 가능합니다.","알림");
			}
		} else {
			// pCode가 빈값이라면 흰색배경으로 세팅
			$("#txtCateCode").css("border-color", "#c6c6c6");
			$("#txtCateCode").css("background-color", "#fff");
		}
	};
	
	var deleteCate = function(code) {
		Common.Confirm("삭제하시겠습니까?", "알림", function(result){
			if(result) {
				var selVal = $("#selManageValue").val();
				$.get("workreportdeletecate.do", {
					cate : selVal,
					code : code
				}, function(d) {
					cateGrid.reloadList();
				}).error(function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("workreportdeletecate.do", response, status, error);
				});
			}
		});
	};
	
	var bindOption = function() {
		var jQObj = $("#selDivision");
		$(jQObj).empty().append("<option value=''>선택</option>");
		$("#allTypeListBox").empty();
		$.getJSON("getWorkReportDiv.do", {}, function(d){
			
			var listData = d.list;
			$(listData).each(function(idx, data) {
				jQObj.append("<option value='" + data.code + "'>" + data.name + "</option>");	
			});
			
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getWorkReportDiv.do", response, status, error);
		});
		
		$.getJSON("getWorkReportType.do", {}, function(d) {
			var resultList = d.list;
			$(resultList).each(function(idx, data) {
				var sHtml = "<div data-code='" + data.code + "' data-name='" + data.name + "' style='border-bottom:1px solid #c9c9c9;'>";
				sHtml += "<span style='display:inline-block; width:30px; text-align:center; border-right:1px solid #c9c9c9;'>"
				sHtml += "<input type='checkbox' name='chkalltype'/></span>";
				sHtml += "<span style='display:inline-block; padding-left:15px; font-size:12px; font-weight:500;'>"
				sHtml += "[ <font style='font-weight:700;'>" + data.code + "</font> ] "+ data.name + "</span>"; 
				sHtml += "</div>";	
				$("#allTypeListBox").append(sHtml);
			});
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getWorkReportType.do", response, status, error);
		});
	};
	
	var divisionChange = function(obj) {
		var jQObj = $(obj);
		var selVal = jQObj.val();
		
		$("#selectTypeListBox").empty();
		
		if(jQObj.val() != '') {
			$("#selectTypeListBox").empty();
			$.getJSON("getWorkReportTypeSel.do", {"code" : selVal.toString()}, function(d) {
				var resultList = d.list;
				var oldCodeList = "";
				$(resultList).each(function(idx, data) {
					var sHtml = "<div data-code='" + data.code + "' data-name='" + data.name + "' style='border-bottom:1px solid #c9c9c9;'>";
					sHtml += "<span style='display:inline-block; width:30px; text-align:center; border-right:1px solid #c9c9c9;'>"
					sHtml += "<input type='checkbox' name='chkseltype'/></span>";
					sHtml += "<span style='display:inline-block; padding-left:15px; font-size:12px; font-weight:500;'>"
					sHtml += "[ <font style='font-weight:700;'>" + data.code + "</font> ] "+ data.name + "</span>"; 
					sHtml += "</div>";	
					$("#selectTypeListBox").append(sHtml);
					
					if(oldCodeList == "")
						oldCodeList += data.code;
					else
						oldCodeList += ("," + data.code);
				});
				
				$("#hidNewSelectType").text("");
				$("#hidDelSelectType").text("");
				$("#hidOldSelectType").text(oldCodeList);
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("getWorkReportTypeSel.do", response, status, error);
			});
			
		}
	};
	
	var selctAllType = function(pObj) {
		var selName = $(pObj).attr("data-chkname");
		
		$("input[name='" + selName + "']").prop("checked", pObj.checked);
	};
	
	var setWorkCateType = function() {
		var chkVal = $("input[name='chkalltype']:checked");
		var chkAll = $("input[class='allchkcls']:checked");
		
		if(chkAll.length > 0) {
			chkAll.prop("checked", false);
		}
		
		if(chkVal.length == 0) {
			Common.Inform("선택된 분류가 없습니다.", "알림");
		} else {
			var newCodes = "";
			var arrOldCodes = $("#hidOldSelectType").text().split(',');
			var arrDelCodes = $("#hidDelSelectType").text().split(',');
			var currentNewCode = $("#hidNewSelectType").text();
			var dupCodes = "";
			
			if(currentNewCode.length > 0) {
				newCodes = currentNewCode;
			}
			
			$(chkVal).each(function(idx, data) {
				var selDiv = $(data).parent().parent();
				var strCode = selDiv.attr("data-code");
				var strName = selDiv.attr("data-name");
				
				var dupFlag = false;
				
				// 중복 체크
				$("#selectTypeListBox>div").each(function(idx, dupData) {
					if($(dupData).attr("data-code") == strCode) {
						dupFlag = true;
						return false;
					}
				});
				
				if(dupFlag) {
					if(dupCodes == "") 
						dupCodes += "[ " + strCode + " ] " + strName;
					else 
						dupCodes += ", [ " + strCode + " ] " + strName;
				} else {
					var flag = false;
					
					// 기존에 추가된 코드의 경우 추가하지 않음
					if(arrOldCodes.length > 0) {
						arrOldCodes.forEach(function(d){
							if(strCode == d) {
								flag = true;
								return false;
							}
						});
					}
					
					// 기존에 추가된 코드가 삭제 대상으로 등록된 경우 대상에서 제거
					if(arrDelCodes.length > 0 && flag) {
						var index = arrDelCodes.indexOf(strCode);
						if(index > -1) {
							arrDelCodes.splice(index, 1);
						}
					}
					
					if(!flag) {
						if(newCodes.length == 0)
							newCodes += strCode;
						else 
							newCodes += ("," + strCode);
					}
					
					// box 생성
					var sHtml = "<div data-code='" + strCode + "' data-name='" + strName + "' style='border-bottom:1px solid #c9c9c9;'>";
					sHtml += "<span style='display:inline-block; width:30px; text-align:center; border-right:1px solid #c9c9c9;'>"
					sHtml += "<input type='checkbox' name='chkseltype'/></span>";
					sHtml += "<span style='display:inline-block; padding-left:15px; font-size:12px; font-weight:500;'>"
					sHtml += "[ <font style='font-weight:700;'>" + strCode + "</font> ] "+ strName + "</span>"; 
					sHtml += "</div>";	
					$("#selectTypeListBox").append(sHtml);
				}
			});
			
			if(dupCodes.length > 0) {
				Common.Inform(dupCodes + "는 이미 선택되어 있습니다.", "알림");
			}
			
			$("#hidNewSelectType").text(newCodes);
			$("#hidDelSelectType").text(arrDelCodes.join(","));
			
			chkVal.prop("checked", false);
		}
	};
	
	var deleteWorkCateType = function() {
		var chkVal = $("input[name='chkseltype']:checked");
		var chkAll = $("input[class='allchkcls']:checked");
		
		if(chkAll.length > 0) {
			chkAll.prop("checked", false);
		}
		if(chkVal.length == 0) {
			Common.Inform("선택된 분류가 없습니다.", "알림");
		} else {
			var strOldDel = "";
			var strNewDel = "";
			var arrNewCodes = $("#hidNewSelectType").text().split(',');
			
			var currentOldDelCode = $("#hidDelSelectType").text();
			
			if(currentOldDelCode.length > 0) {
				strOldDel = currentOldDelCode;
			}
			
			$(chkVal).each(function(idx, data) {
				var selDiv = $(data).parent().parent();
				var strCode = selDiv.attr("data-code");
				var strName = selDiv.attr("data-name");
				
				var flag = false;
				
				if(arrNewCodes.length > 0) {
					arrNewCodes.forEach(function(d){
						if(strCode == d) {
							flag = true;
							return false;
						}
					});
				}
				
				if(!flag) {
					if(strOldDel.length == 0)
						strOldDel += strCode;
					else 
						strOldDel += ("," + strCode);
				}
				else 
					strNewDel += strCode + ",";
					
				selDiv.remove();
			});
			
			var arrOldDel = strOldDel.split(',');
			var reduceDel = arrOldDel.reduce(function(newArr, data){
				// 같은배열원소가 존재하지 않는 배열 생성
				if(newArr.indexOf(data) < 0) newArr.push(data);
				return newArr;
			}, []);
			
			$("#hidDelSelectType").text(reduceDel.join(','));
			var arrDelNewCodes = strNewDel.split(',');
			var arrFilterNewCodes;
			
			if(arrDelNewCodes.length > 0) {
				arrFilterNewCodes = arrNewCodes.filter(function(d){
					var filterFlag = true;
					arrDelNewCodes.forEach(function(del) {
						if(d == del) {
							filterFlag = false;
							return false;
						}
					});
					
					return filterFlag;
				});
				
				$("#hidNewSelectType").text(arrFilterNewCodes.join(","));
			}
		}
	};
	
	var acceptWorkType = function () {
		var newData = $("#hidNewSelectType").text();
		var delData = $("#hidDelSelectType").text();
		var selDiv = $("#selDivision").val();
		
		if(selDiv == "") {
			Common.Inform("업무구분을 선택해주세요.", "알림");
		} else {
			$.post("acceptworktype.do", {
				seldiv : selDiv,
				newcode : newData,
				delcode : delData
			}, function(d) {
				console.dir(d);
				if(d.result == "success") {
					Common.Inform("변경사항이 적용되었습니다.", "알림");
					// reload
					divisionChange($("#selDivision")[0]);
				}
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("acceptworktype.do", response, status, error);
			});
		}
	}
	
	$(function() {
		$.ajaxSetup({
			cache : false
		});
		$("#manageTab").trigger("click");
		setGrid();
		bindGridData("WorkReportCateDivList.do");
	});

</script>
</body>
</html>