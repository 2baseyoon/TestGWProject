<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<style type="text/css">
.divSelectBox{
	float: right;
    display: inline-block;
    width: 36%;
    min-width: 485px;
    border: 1px solid #e8e8e8;
    box-shadow: 1px 1px 4px #ccc;
    border-radius: 3px;
		
}

.dtSelectBox{
	font-size: 14px;
    font-weight: bold;
    height: 44px;
    padding-left: 13px;
    line-height: 42px;
    background-color: #fafbfd;
}

.ddSelectBox{
	width: 100%;
    margin: 0px;
    padding: 0px;
}

.ddSelectBox select option{
	border-bottom: 1px solid #c9c9c9;
	padding : 5px 0 5px 12px;
    border-right: 1px solid #c9c9c9;
    font-size : 12px;
}


.clsJobNode {
	width : 100%;
	height : 30px;
	line-height : 30px;
	padding-left : 10px;
	box-sizing : border-box;
	border-bottom : 1px solid #c9c9c9;
	cursor : pointer;
	
	-ms-user-select: none; 
   	-moz-user-select: -moz-none;
   	-khtml-user-select: none;
   	-webkit-user-select: none;
   	user-select: none;
}

.clsJobNode:hover {
	background-color : #f0f0f0;
}

.clsTypeNode {
	width : 100%;
	height : 30px;
	line-height : 30px;
	padding-left : 10px;
	box-sizing : border-box;
	border-bottom : 1px solid #c9c9c9;
	cursor : pointer;
	
	-ms-user-select: none; 
   	-moz-user-select: -moz-none;
   	-khtml-user-select: none;
   	-webkit-user-select: none;
   	user-select: none;
}

.clsTypeNode:hover {
	background-color : #f0f0f0;
}

.clsMyWorkNode {
	width : 100%;
	height : 30px;
	line-height : 30px;
	padding-left : 10px;
	box-sizing : border-box;
	border-bottom : 1px solid #c9c9c9;
	cursor : pointer;
	
	-ms-user-select: none; 
   	-moz-user-select: -moz-none;
   	-khtml-user-select: none;
   	-webkit-user-select: none;
   	user-select: none;
}

.clsMyWorkNode:hover {
	background-color : #f0f0f0;
}

</style>

<div>
	<h3 class="con_tit_box">
		<span class="con_tit">나의 업무 설정</span>
	</h3>
	
	<!-- 검색 바 -->
	<div>
		<select id="selDivision" onchange="divisionChange(this)"></select>
		<span style="margin-left : 5px;">업무 명</span> 
		<input type="text" id="txtJobName" class="AXInput W200" />
		<button type="button" id="btnSearch" class="AXButton" onclick="bindProject()">검색</button>
	</div>

	<div id="resultBoxWrap" style="margin-top : 20px; min-height:420px; width:100%;">		
		<div style="float:left; width:500px; border : 1px solid #c9c9c9; min-height : 430px; box-sizing:border-box;">
			<div style='width:100%; height:40px; background-color : #fafbfd; border-bottom : 1px solid #c9c9c9; line-height:40px; padding-left : 10px;'>
				<span style='font-weight:bold;'>전체 업무 목록</span>
			</div>
			<div style='width:100%; height:390px;'>
				<div id='workJobList' style='width:328px; height:390px; overflow-y : auto; float:left; border-right: 1px solid #c9c9c9;'>
				
				</div>
				<div id='workTypeList' style='width:170px; height:390px; overflow-y : auto; float:left;'>
				
				</div>
			</div>
		</div>
		<div style="width:50px; display:inline-block; height:430px; float:left;">
				<button type="button" style="margin:160px 0 5px 13px!important;text-indent:unset;" class="btnRight" onclick="setWorkCateType();">&gt;</button>
	      		<button type="button" style="margin:0 0 0 13px!important;text-indent:unset;" class="btnLeft" onclick="deleteWorkCateType();">&lt;</button>
		</div>
		<div style="float:left; width:400px; border : 1px solid #c9c9c9; min-height : 430px; box-sizing:border-box;">
			<div style='width:100%; height:40px; background-color : #fafbfd; border-bottom : 1px solid #c9c9c9; line-height:40px; padding-left : 10px;'>
				<span style='font-weight:bold;'>선택 업무 목록</span>
				<span style='display:inline-block; float:right; line-height:0px; margin:5px;'>
					<button type="button" onclick="acceptWorkType();" class="AXButton">저장</button>
				</span>
			</div>
			
			<div id='myWorkList' style='width:100%; height:390px; overflow-y : auto;'>
				
			</div>
		</div>
	</div>
	
	<!-- 
	<div id="resultBoxWrap" style="margin-top : 20px; height:420px;">		
		<div style="float:left; position:relative; margin-right:20px;">
			<dl id="divProject"  class="divSelectBox" style="float:left; position:relative;">
				<dt class="dtSelectBox">전체 업무 목록</dt>
				<dd class="ddSelectBox">
					<select id="selProject"  onchange="projectChange(this)" style="width:278px; height:350px;"></select>
					<select id="selCategory" multiple="multiple" style="width:205px; margin-left:-5px; height:350px;"></select>
				</dd>
			</dl>
		</div>
		<div style="width:50px; display:inline-block; height:380px; float:left;">
				<input type="button" style="margin:160px 0 5px 13px!important;" class="btnRight" value=">" onclick="setWorkCateType();">
	      		<input type="button" style="margin:0 0 0 13px!important;" class="btnLeft" value="<" onclick="deleteWorkCateType();">
		</div>
		<div style="float:left; position:relative; margin-left:20px;">
			<dl id="divProject"  class="divSelectBox" style="float:left;position:relative;">
				<dt class="dtSelectBox">선택 업무 목록</dt>
				<dd class="ddSelectBox">
					<select id="selMyProject" multiple="multiple" onchange="myprojectChange(this)" style="width:483px; height:350px;"></select>
				</dd>
			</dl>
		</div>
	</div>
	
	
	<div id="SaveBtnBoxWrap" style="text-align:center; margin-top:10px;">
		<button type="button" onclick="acceptWorkType();" class="AXButton">저장</button>
	</div>
	
	 -->	
</div>


<textarea id="hidOldSelectType" style="display:none;"></textarea>
<textarea id="hidNewSelectType" style="display:none;"></textarea>
<textarea id="hidDelSelectType" style="display:none;"></textarea>


<script>
	var boolShift = false;


	function bindDefaultData() {		
		
		bingCategory();  //카테고리 바인딩
		bindProject();   //프로젝트 바인딩
		bindMyProject(); //나의 업무 바인딩		

	}

	function bingCategory(){		
		//대분류
		$.getJSON("myworksettingdivision.do", {}, function(d) {
			var resultList = d.list;
			var shtml = "";
			shtml += "<option value='All' selected='selected'>전체</option>";
			$(resultList).each(function(idx, data) {
				shtml += "<option value='" + data.divisionCode + "'>" + data.displayName + "</option>";				
			});
			$("#selDivision").html(shtml);
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("myworksettingdivision.do", response, status, error);
		});

	}
	
	function bindProject(){
		
		var pSearchText = $("#txtJobName").val();
		var selCate = $("#selDivision").val();
		if(selCate == null ) selCate = "All";

		//프로젝트 바인딩  
		$.post("myworksettingproject.do",{"code" : selCate , "searchText" : pSearchText },function(d){
			var resultList = d.list;
			var resultCnt = d.cnt;

			// var shtml = "";
			
			var sHTML = "";
			
			$(resultList).each(function(idx, data) {
				// shtml += "<option value='" + data.JobID + "' jobDivision='" + data.JobDivision + "'>" + data.JobName + "</option>";
				
				sHTML += "<div class='clsJobNode' data-jobid='" + data.JobID + "' data-jobDivision='" + data.JobDivision + "'>";
				sHTML += "<span style='width:300px; display:inline-block; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;'>";
				sHTML += data.JobName;
				sHTML += "</span>";
				sHTML += "</div>";
			});
			// $("#selProject").html(shtml);
			
			$("#workJobList").html(sHTML);
			
			// $("#selProject").attr("size",resultCnt);
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("myworksettingproject.do", response, status, error);
		});				
	}
	
	function bindMyProject(){
		var oldCodeList = "";
		//나의 프로젝트 바인딩  
		$.getJSON("myworksettingmyjob.do",{},function(d){
			var resultList = d.list;
			
			// var shtml = "";
			var sHTML = "";
			$(resultList).each(function(idx, data) {
				/*
				shtml += "<option value='" + data.JobID + "' id='" + data.JobID + "-" + data.TypeCode.toString() + "' >" + data.JobName.toString() + " - " + data.DisplayName.toString() + "</option>";				
				*/
				
				sHTML += "<div class='clsMyWorkNode' data-jobid='" + data.JobID + "' data-id='" + data.JobID + "-" + data.TypeCode.toString() + "'>";
				sHTML += "<span style='width:350px; display:inline-block; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;'>";
				sHTML += data.JobName.toString() + " - " + data.DisplayName.toString();
				sHTML += "</span>";
				sHTML += "</div>";
				
				if(oldCodeList == "") 
					oldCodeList += data.JobID + "-" + data.TypeCode.toString();
				else
					oldCodeList += ("," + data.JobID + "-" + data.TypeCode.toString());
			});
			// $("#selMyProject").html(shtml);
			
			$("#myWorkList").html(sHTML);
			$("#hidNewSelectType").text("");
			$("#hidDelSelectType").text("");
			$("#hidOldSelectType").text(oldCodeList);
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("myworksettingmyjob.do", response, status, error);
		});	
	}
	
	var projectChange = function(obj) {
		var selVal = $("#selProject option:selected").attr("jobDivision");
		var setID = $("#selProject option:selected").val();
		
		$("#selCategory").empty();

		$.getJSON("myworksettingcategory.do", {"code" : selVal.toString() }, function(d) {
			var resultList = d.list;
			var shtml = "";
			$(resultList).each(function(idx, data) {
				shtml += "<option value='" + data.typeCode.toString() + "' id='" + setID + "-"+ data.typeCode.toString() + "'>" + data.displayName.toString() + "</option>";		
			
			});
			$("#selCategory").html(shtml);			
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("myworksettingcategory.do", response, status, error);
		});
	};
	
	var myprojectChange = function(obj) {
		var selVal = $("#selMyProject option:selected").val();
		var oldCodeList = "";
		
		$("#selMyCategory").empty();

		$.getJSON("myworksettingmycategory.do", {"jobID" : selVal.toString() }, function(d) {
			var resultList = d.list;
			var shtml = "";

			$(resultList).each(function(idx, data) {
				shtml += "<option value='" + data.TypeCode.toString() + "' id='" + selVal  + "-" + data.TypeCode.toString() + "'>" + data.DisplayName.toString() + "</option>";		
			
				if(oldCodeList == "")
					oldCodeList += data.JobID;
				else
					oldCodeList += ("," + data.JobID);
			});
			$("#selMyCategory").html(shtml);
			$("#hidNewSelectType").text("");
			$("#hidDelSelectType").text("");
			$("#hidOldSelectType").text(oldCodeList);
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("myworksettingmycategory.do", response, status, error);
		});

	};
	
	
	var divisionChange = function(obj) {
		var jQObj = $(obj);
		var selVal = jQObj.val();
		var oldCodeList = "";
		
		// $("#selProject").empty();
		
		$("#workJobList").empty();
		$("#workTypeList").empty();
		
		if(jQObj.val() != '') {
			// $("#selProject").empty();
			
			$("#workJobList").empty();
			
			$.post("myworksettingproject.do", {"code" : selVal.toString() }, function(d) {
				var resultList = d.list;
				// var shtml = "";
				var sHTML = "";
				$(resultList).each(function(idx, data) {
					// shtml += "<option value='" + data.JobID + "' jobDivision='" + data.JobDivision + "'>" + data.JobName + "</option>";		
				
					sHTML += "<div class='clsJobNode' data-jobid='" + data.JobID + "' data-jobDivision='" + data.JobDivision + "'>";
					sHTML += "<span style='width:300px; display:inline-block; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;'>";
					sHTML += data.JobName;
					sHTML += "</span>";
					sHTML += "</div>";
					
					if(oldCodeList == "")
						oldCodeList += data.JobID;
					else
						oldCodeList += ("," + data.JobID);
				});
				
				// $("#selProject").html(shtml);
				$("#workJobList").html(sHTML);
				$("#hidNewSelectType").text("");
				$("#hidDelSelectType").text("");
				$("#hidOldSelectType").text(oldCodeList);
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("myworksettingproject.do", response, status, error);
			});
			
		}
	};
	
	
	var setWorkCateType = function() {
		
			var newCodes = "";
			var arrOldCodes = $("#hidOldSelectType").text().split(',');
			var arrDelCodes = $("#hidDelSelectType").text().split(',');
			var currentNewCode = $("#hidNewSelectType").text();
			var dupCodes = "";
			
			if(currentNewCode.length > 0) {
				newCodes = currentNewCode;
			}
			
			
			$.each($(".clsTypeNode[data-selected='true']"), function(idx,data){
				
				/*
				var strCode = $("#selProject").val() + "-" + $(this).val();
				var strName = $("#selProject :selected").text() + " - " + $(this).text();
				*/
				
				var strCode = $(".clsJobNode[data-selected='true']").attr("data-jobid") + "-" + $(".clsTypeNode[data-selected='true']").attr("data-typeCode");
				var strName = $(".clsJobNode[data-selected='true']>span").text() + "-" + $(".clsTypeNode[data-selected='true']>span").text();
				
				var dupFlag = false;
				
				// 중복 체크
				/*
				$("#selMyProject option").each(function(idx , dupdata) {
					if($(this).attr("id").toString() == strCode) {
						dupFlag = true;
						return false;
					}
				});
				*/
				
				$("#myWorkList .clsMyWorkNode").each(function(idx, dupdata) {
					if($(this).attr("data-id").toString() == strCode) {
						dupFlag = true;
						return false;
					}
				});
				
				if(dupFlag) {
					if(dupCodes == "") 
						dupCodes += "[ " + strName + " ] ";
					else 
						dupCodes += "\r\n[ " + strName + " ]";
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
					/*
					var sHtml = "<option value='" + strCode.split('-')[0] + "' id='" + strCode + "'>" + strName + "</option>";		
					$("#selMyProject").append(sHtml);
					*/
					
					var sHTML = "";
					sHTML += "<div class='clsMyWorkNode' data-jobid='" + strCode.split('-')[0] + "' data-id='" + strCode + "'>";
					sHTML += "<span style='width:300px; display:inline-block; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;'>";
					sHTML += strName;
					sHTML += "</span>";
					sHTML += "</div>";
					
					$("#myWorkList").append(sHTML);
				}			
			});		
			
			if(dupCodes.length > 0) {
				Common.Inform(dupCodes + " 은(는) 이미 선택되어 있습니다.", "알림");
			}	
			
			$("#hidNewSelectType").text(newCodes);
			$("#hidDelSelectType").text(arrDelCodes.join(","));
	};
	
	var deleteWorkCateType = function() {
		
			var strOldDel = "";
			var strNewDel = "";
			var arrNewCodes = $("#hidNewSelectType").text().split(',');
			
			var currentOldDelCode = $("#hidDelSelectType").text();
			
			if(currentOldDelCode.length > 0) {
				strOldDel = currentOldDelCode;
			}
			
			$.each($(".clsMyWorkNode[data-selected='true']"), function(idx,data){
				/*
				var strCode = $(this).attr("id".toString());
				var strName = $(this).text();
				*/
				
				var strCode = $(this).attr("data-id".toString());
				var strName = $(this).text();
				
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
					
				// $("#selMyProject :selected").remove();
	
				$(this).remove();
				
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
			});
	};
	
	var acceptWorkType = function () {
		var newData = $("#hidNewSelectType").text();
		var delData = $("#hidDelSelectType").text();

		$.post("saveMyJob.do", {
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
		     CFN_ErrorAjax("saveMyJob.do", response, status, error);
		});

	}
	
	$(function() {
		bindDefaultData();
		
		$("#workJobList").on("click", ".clsJobNode", function(){ 
			$(".clsJobNode").css("background-color", "#fff")
							.attr("data-selected", "false");
			
			$(this).css("background-color", "#f0f0f0")
				   .attr("data-selected", "true");
			
			var jobId = $(this).attr("data-jobid");
			var division = $(this).attr("data-jobDivision");
			
			$("#workTypeList").empty();
			
			$.getJSON("myworksettingcategory.do", {"code" : division }, function(d) {
				var resultList = d.list;
				var sHTML = "";
				$(resultList).each(function(idx, data) {					
					sHTML += "<div class='clsTypeNode' data-typeCode='" + data.typeCode + "' data-id='" + jobId + "-" + data.typeCode + "'>";
					sHTML += "<span style='width:150px; display:inline-block; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;'>";
					sHTML += data.displayName;
					sHTML += "</span>";
					sHTML += "</div>";
				});
				$("#workTypeList").html(sHTML);			
			}).error(function(response, status, error){
			     //TODO 추가 오류 처리
			     CFN_ErrorAjax("myworksettingcategory.do", response, status, error);
			});
			
		});
		
		$("#workTypeList").on("click", ".clsTypeNode", function(e){
			$(".clsTypeNode").css("background-color", "#fff")
			 				 .attr("data-selected", "false");
			$(this).css("background-color", "#f0f0f0")
		   	   	   .attr("data-selected", "true");
		});
		
		$("#myWorkList").on("click", ".clsMyWorkNode", function(e) {
			$(".clsTypeNode").css("background-color", "#fff")
			 				 .attr("data-selected", "false");
			$(".clsJobNode").css("background-color", "#fff")
							.attr("data-selected", "false");
			
			
			

			if(!boolShift) {
				$(".clsMyWorkNode").css("background-color", "#fff")
								   .attr("data-selected", "false");
			}
			
			boolShift = e.shiftKey || e.ctrlKey;
			
			if(!boolShift) {
				$(".clsMyWorkNode").css("background-color", "#fff")
								   .attr("data-selected", "false");
			}
			
			if(boolShift && e.shiftKey) {
				$(this).css("background-color", "#f0f0f0")
					   .attr("data-selected", "true");
				
				// 범위 확인 및 선택 처리
				var minIdx = -1;
				var selectedLen = $(".clsMyWorkNode[data-selected='true']").length;
				
				
				$(".clsMyWorkNode").each(function(idx, node) {
					var isSelected = $(this).attr("data-selected");
					
					if(selectedLen <= 0)
						return false;
					
					if(isSelected.toLowerCase() == 'true') {
						if(minIdx == -1) {
							minIdx = idx;
						}
						
						--selectedLen;
					} else {
						if(minIdx > -1) {
							$(this).css("background-color", "#f0f0f0")
							   	   .attr("data-selected", "true");
						}
					}
					
					
				});
				
				
				
			} else {
				$(this).css("background-color", "#f0f0f0")
				   	   .attr("data-selected", "true");
			}
		});		
	});
</script>
</form>