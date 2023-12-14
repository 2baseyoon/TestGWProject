<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="popContent vmExcelUploadPopup" >
	<div class="">
		<div class="top">
			<%-- <ul class="noticeTextGrayBox">
				<li>※ <spring:message code="Cache.lbl_vacationMsg28" /></li>
				<li>※ <spring:message code="Cache.lbl_vacationMsg29" /></li>
			</ul> --%>
			<div class="ulList type02 mt20">
				<ul>
					<li class="listCol">
						<div><strong><spring:message code="Cache.lbl_File" /></strong></div>
						<div>
							<input type="text" id="uploadfileText" placeholder="<spring:message code='Cache.lbl_vacationMsg30' />"><a href="#" class="btnTypeDefault" onclick="$('#uploadfile').click();"><spring:message code="Cache.lbl_SelectFile" /></a>
							<a href="#" class="btnTypeDefault btnTypeBg" onclick="excelUpload()"><spring:message code="Cache.btn_Upload" /></a>
							<div style="width:0px; height:0px; overflow:hidden;"><input type="file" id="uploadfile" ></div>
						</div>
					</li>								
				</ul>							
			</div>
		</div>
		<div class="surTargetBtm">
			<div class="tblList">
				<div id="gridDiv" >
				</div>					
			</div>
		</div> 
		<div class="bottom" style="text-align: center;">
			<a href="#" id="registBtn" onclick="saveExcelData();" class="btnTypeDefault btnTypeBg" style="display:none"><spring:message code='Cache.lbl_Regist' /></a>
			<a href="#" class="btnTypeDefault" onclick="parent.Common.Close('AttendExcelPopup');"><spring:message code='Cache.btn_Close' /></a>
		</div>
	</div>
</div>
			
<script>

	var grid = new coviGrid();
	var excelList ;
	
	initContent();

	function initContent() {
		// 파일 선택, 취소
		$('#uploadfile').on('change', function(e) {
			var file = $(this)[0].files[0];
			
			if (typeof(file) == 'undefined') $('#uploadfileText').val(''); else $('#uploadfileText').val(file.name);
		});
		
		setGrid();	// 그리드 세팅
	}
	
	// 엑셀 업로드
	function excelUpload() {
		
	    if($("#uploadfile").val() == ""){
			Common.Error("<spring:message code='Cache.msg_SelectFile' />"); 
	        return false;
	    }
	    
		
		var formData = new FormData();
		formData.append("uploadfile",$('#uploadfile')[0].files[0]);
		
		$.ajax({
			url: '/groupware/attendAdmin/workInfoExcelUpload.do',
			processData: false,
			contentType: false,
			data: formData,
			type: 'POST',
			success: function(result) {
				if(result.status == "SUCCESS"){
					setGridData(result);
					if(result.uploadYn=="Y"){
						$("#registBtn").removeAttr("style");
						excelList = result.list;
					}else{
						$("#registBtn").attr("style","display:none");
						excelList = "";
					}
				}else{
					Common.Error("<spring:message code='Cache.ACC_msg_error' />"); 
				}
				
			}
		});
	}	
	
	//엑셀업로드 팝업호출
	function excelUploadListPopup(exList){
		
		var url = "/groupware/attendAdmin/goWorkInfoByExcelUploadList.do";
		parent.Common.open("","excel_list","<spring:message code='Cache.lbl_ExcelUpload' />",url,"900","500","iframe",true,null,null,true);
	}
	
	// 그리드 세팅
	function setGrid() {
		// header
		var	headerData = [
				{key:'UserCode', label:'<spring:message code="Cache.lbl_apv_user_code" />', width:'80', align:'center', sort:false,
					formatter:function () {
						var html = "<div class='tblLink'; ";
						if(this.item.userCode_validYn!="Y"){
							html += "style='color: red;'";
						}
						html += ">";
						html += this.item.UserCode;
						html += "</div>";
						return html;
					}
				} ,
				{key:'UserName', label:'<spring:message code="Cache.lbl_username" />', width:'80', align:'center', sort:false,
					formatter:function () {
						var html = "<div class='tblLink'; ";
						if(this.item.userCode_validYn!="Y"){
							html += "style='color: red;'";
						}
						html += ">";
						html += this.item.UserName
						html += "</div>";
						return html;
					}
		        } ,
				{key:'ex_WorkWeek', sort:false, label:'<spring:message code="Cache.lbl_n_att_workingWeek" />', width:'100', align:'center', sort:false,
					formatter:function () {
						var html = "<div class='tblLink'; ";
						if(this.item.WorkWeek_valid!="Y"){
							html += "style='color: red;'";
						}
						html += ">";
						html += this.item.ex_WorkWeek;
						html += "</div>";
						return html;
					}
		        } , 
				{key:'ex_WorkRule',  label:'<spring:message code="Cache.lbl_n_att_workingRule" />', width:'100', align:'center', sort:false,
					formatter:function () {
						var html = "<div class='tblLink'; ";
						if(this.item.WorkRule_valid!="Y"){
							html += "style='color: red;'";
						}
						html += ">";
						html += this.item.ex_WorkRule;
						html += "</div>";
						return html;
					}
		        } ,   
				{key:'ex_MaxWorkRule',  label:'<spring:message code="Cache.lbl_n_att_workingMaxRule" />', width:'100', align:'center', sort:false,
					formatter:function () {
						var html = "<div class='tblLink'; ";
						if(this.item.MaxWorkRule_valid!="Y"){
							html += "style='color: red;'";
						}
						html += ">";
						html += this.item.ex_MaxWorkRule;
						html += "</div>";
						return html;
					}
		        } ,   
				{key:'ApplyDate',  label:'<spring:message code="Cache.lbl_n_att_applyDate" />', width:'100', align:'center', sort:false,
					formatter:function () {
						var html = "<div class='tblLink'; ";
						if(this.item.applyDate_validYn!="Y"){
							html += "style='color: red;'";
						}
						html += ">";
						html += this.item.ApplyDate;
						html += "</div>";
						return html;
					}
		        }    
		];
		
		grid.setGridHeader(headerData);
		
		var gridStatusHtml = ""; //pageCnt

		// config
		var configObj = {
			targetID : "gridDiv",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			height:"auto",			
			paging : false
		};
		grid.setGridConfig(configObj);
	}

	// 검색
	function setGridData(exList) {
		grid.bindGrid(exList);
	}	
	
	
	//엑셀 데이터 일괄 등록
	function saveExcelData(){
		Common.Confirm("<spring:message code='Cache.msg_RURegist'/>", "Confirmation Dialog", function (confirmResult) {
			if (confirmResult) {
				var params = {
						"excelList" : JSON.stringify(excelList)
				}
				$.ajax({
					dataType : "json",
					type : "POST",
					data : params,
					url : "/groupware/attendAdmin/insertWorkInfoListByExcel.do",
					success:function (data) {
						if(data.status == 'SUCCESS') {
							Common.Inform("<spring:message code='Cache.msg_apv_170' />", "Inform", function() {
								parent.Common.Close("AttendExcelPopup");
								parent.search(); 
							});
		          		} else {
		          			Common.Warning("<spring:message code='Cache.msg_apv_030' />");
		          		}
					},
					error:function(response, status, error) {
						coviCmn.traceLog(error);
						CFN_ErrorAjax(url, response, status, error);
					}
		 		});
			}else {
				return false;
			}
		});
	}


</script>
