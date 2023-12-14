<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>
<style>
.pad10 { padding:10px;}
</style>

<body>
	<div class="layer_divpop ui-draggable docPopLayer" id="" style="width:350px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent">
				<div id="Grid" class="pad10">
					<div id="ExpAppManFileGrid"></div>
				</div>
			</div>
		</div>
	</div>
</body>
<script>



	var expAppGridPanel = new coviGrid();
	var expAppFileHeaderData = [
	        			{ key:'FileName',		label : "<spring:message code='Cache.ACC_lbl_attachedFileName' />",		width:'70', align:'center'	//첨부파일명
					    	,formatter:function () {
			            		 return "<a href='javascript:void(0);' class='btn_File ico_file'  onClick=\"combCostAppFileListPopupDownload('"+escape(this.item.SavedName)+"','"+escape(this.item.FileName)+"','"+this.item.FileID+"')\"><font color='blue'><u>"+this.item.FileName+"</u></font></a>";
			            	}
	        			},
	        			{ key:'Size',		label : "<spring:message code='Cache.ACC_lbl_size' />", width:'70', align:'center'						//크기
					    	,formatter:function () {
			            		 return ckFileSize(this.item.Size);
			            	}
	        			}
	        		]

	var ExpAppListID = '${ExpAppListID}';
	
	ExpenceApplicationViewFilePopupLoad();

	function ExpenceApplicationViewFilePopupLoad() {		
		gridInit();
	};
	
	function gridInit() {
		expAppGridPanel.setGridHeader(expAppFileHeaderData);
		setGridConfig();
		searchExpAppFile();
	};

	function setGridConfig(){
		var configObj = {
			targetID : "ExpAppManFileGrid",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.ACC_lbl_count'/>", 	//개
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		expAppGridPanel.setGridConfig(configObj);
	}

	function searchExpAppFile(){		
		setGridConfig();
		
		expAppGridPanel.bindGrid({
			ajaxUrl:"/account/expenceApplication/searchExpenceApplicationFileList.do",
			ajaxPars: {
				ExpAppListID : ExpAppListID
			},
			onLoad:function(data){
				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
				expAppGridPanel.fnMakeNavi("myGrid");
			}
		});
	}
	
	function combCostAppFileListPopupDownload(SavedName, FileName, FileID) {
		accountFileCtrl.downloadFile(SavedName, FileName, FileID);
	}
	
	function ExpenceApplicationViewFilePopupClose() {
		var isWindowed = CFN_GetQueryString("CFN_OpenedWindow");
		
		if(isWindowed.toLowerCase() == "true") {
			window.close();
		} else {
			parent.Common.close('expAppManViewFile');
		}
	};
</script>
