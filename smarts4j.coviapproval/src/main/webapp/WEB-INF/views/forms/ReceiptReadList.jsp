<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script>

	var ListGrid = new coviGrid();

	var FormInstID = ${FormInstID};
	var ProcessID = ${ProcessID};
	var headerData;
	var lang = Common.getSession("lang");
	
	var openID =  CFN_GetQueryString("openID")=="undefined"? "":CFN_GetQueryString("openID");
	var GovDocs =  CFN_GetQueryString("GovDocs");
	
	$(document).ready(function () {	
		if(GovDocs == "distribution"){$("#btSend").hide(); $("#btDelete").hide();}
		setGrid();
		
		if (openID != "") {//Layer popup 실행
	        if ($("#" + openID + "_if", opener.document).length > 0) {
	            m_oInfoSrc = $("#" + openID + "_if", opener.document)[0].contentWindow;
	        } else { //바닥 popup
	            m_oInfoSrc = opener;
	        }
	    } else {
	        m_oInfoSrc = top.opener;
	    }
		
		//버튼 활성화
        //발신부서원일 경우 삭제 및 추가 발송 버튼 활성화. 그 외는 사용 불가
		if (m_oInfoSrc.getInfo("FormInstanceInfo.InitiatorUnitID") == m_oInfoSrc.getInfo("AppInfo.dpdn_apv")){
            document.getElementById("btSend").style.display = "";
            document.getElementById("btDelete").style.display = "";
            document.getElementById("btExcel").style.display = "";
        }
	});
	
	
	function setGrid(){
		setGridHeader();
		setGridConfig();
		setListData();
	}
	
	function setGridHeader(){

		if(GovDocs != "undefined" && GovDocs == "distribution"){
			headerData =[{key:'chk', label:'chk', width: '5', align: 'center', formatter: 'checkbox', disabled:function(){
					 if(parseInt(this.item.WorkItemState) > 500 || this.item.PerformerState == "0"){
							return true;
						}else{
							return false;
						}
				   }},
			      {key:'UserName', label:'<spring:message code="Cache.lbl_apv_RecvDept"/>', width:'12', align:'center', formatter: //수신처
			    	  function (){
			    	  	var userName = '';
					    	  	if(this.item[0].UserName != null && this.item[0].UserName.split('^').length >1)
					    	  		userName = CFN_GetDicInfo(this.item[0].UserName.split('^')[0],lang);
					    	  	else 
					    	  		userName = CFN_GetDicInfo(this.item[0].UserName,lang);
					    	  	
					    	    // 2022-11-11 플라워 네임 적용
								if (typeof (setUserFlowerName) == 'function' && this.item[0].ActualKind == '0') {
									return setUserFlowerName(this.item[0].UserCode, userName, 'AXGrid');
								} else {
									return userName;
								}
			      }},						
		         {key:'ChargeName', label:'<spring:message code="Cache.lbl_apv_receiver"/>',  width:'12', align:'center', formatter: //수신자
		       	 function(){
		       	  if(this.item[0].UserName != null && this.item[0].UserName.split('^').length >1)
			    	  		return CFN_GetDicInfo(this.item[0].UserName.split('^')[1],lang);
			    	  	else 
			    	  		return CFN_GetDicInfo(this.item[0].ChargeName,lang);
		         }},
			      {key:'stateName', label:'<spring:message code="Cache.lbl_ReceiptProgress_status"/>',  width:'18', align:'center', formatter: //접수여부/진행상태
		       	 function(){
		       	  if(this.item[0].stateName != null && this.item[0].stateName.split('^').length >1)
			    	  		return CFN_GetDicInfo(this.item[0].stateName.split('^')[1],lang);
			    	  	else 
			    	  		return CFN_GetDicInfo(this.item[0].stateName,lang);
		         }},
			      /* {key:'BusinessStateName', label:'<spring:message code="Cache.lbl_apv_result_approve"/>',  width:'12', align:'center', foormatter: //결재결과
		       	 function(){
		       	  if(this.item[0].BusinessStateName != null && this.item[0].BusinessStateName.split('^').length >1)
			    	  		return CFN_GetDicInfo(this.item[0].BusinessStateName.split('^')[1],lang);
			    	  	else 
			    	  		return CFN_GetDicInfo(this.item[0].BusinessStateName,lang);
		         }}, */
			      {key:'WorkItemFinished', label:'<spring:message code="Cache.lbl_apv_receipt_time"/>',  width:'20', align:'center', formatter: //접수시간
			    	  function(){
			    	  	if(this.item[0].WorkItemFinished != null)
			    	  		return CFN_TransLocalTime(this.item[0].WorkItemFinished)
			    	  	else 
			    	  		return "";
			      }},
			      {key:'ProcessFinished', label:'<spring:message code="Cache.lbl_apv_complete_time"/> ',  width:'20', align:'center', formatter: //완료시간
			    	  function(){
			    	  	if(this.item[0].ProcessFinished != null)
			    	  		return CFN_TransLocalTime(this.item[0].ProcessFinished)
			    	  	else 
			    	  		return "";
			      }}
			      ,
			      {key:'UserOpinion', label:'<spring:message code="Cache.lbl_govdoc_receiveDoc"/> ',  width:'20', align:'center', formatter: //수신문서
			    	  function(){
			    	  		if( ProcessID != this.item[0].ProcessID) return '<button type="button" class="AXButton" onclick="opinion_Click(\''+ this.item[0].ProcessID +'\');"><spring:message code='Cache.lbl_govdoc_receiveDoc'/></button>';
					}
			       }]; 
		}else{
			headerData =[{key:'chk', label:'chk', width: '5', align: 'center', formatter: 'checkbox', disabled:function(){
				 if(parseInt(this.item.WorkItemState) > 500 || this.item.PerformerState == "0"){
						return true;
					}else{
						return false;
					}
			   }},
		      {key:'UserName', label:'<spring:message code="Cache.lbl_apv_RecvDept"/>', width:'12', align:'center', formatter: //수신처
		    	  function (){
		    	  	var userName = '';
					    	  	if(this.item.UserName != null && this.item.UserName.split('^').length >1)
					    	  		userName = CFN_GetDicInfo(this.item.UserName.split('^')[0],lang);
					    	  	else 
					    	  		userName = CFN_GetDicInfo(this.item.UserName,lang);
					    	  	
					    	    // 2022-11-11 플라워 네임 적용
								if (typeof (setUserFlowerName) == 'function' && this.item.ActualKind == '0') {
									return setUserFlowerName(this.item.UserCode, userName, 'AXGrid');
								} else {
									return userName;
								}
		      }},						
             {key:'ChargeName', label:'<spring:message code="Cache.lbl_apv_receiver"/>',  width:'12', align:'center', formatter: //수신자
           	 function(){
           	  if(this.item.UserName != null && this.item.UserName.split('^').length >1)
		    	  		return CFN_GetDicInfo(this.item.UserName.split('^')[1],lang);
		    	  	else 
		    	  		return CFN_GetDicInfo(this.item.ChargeName,lang);
             }},
		      {key:'stateName', label:'<spring:message code="Cache.lbl_ReceiptProgress_status"/>',  width:'18', align:'center'}, //접수여부/진행상태
		      //밑에 State랑 같이 한 행으로 합쳐져야함
		      {key:'BusinessStateName', label:'<spring:message code="Cache.lbl_apv_result_approve"/>',  width:'12', align:'center'}, //결재결과
		      {key:'WorkItemFinished', label:'<spring:message code="Cache.lbl_apv_receipt_time"/>',  width:'20', align:'center', formatter: //접수시간
		    	  function(){
		    	  	if(this.item.WorkItemFinished != null)
		    	  		return CFN_TransLocalTime(this.item.WorkItemFinished)
		    	  	else 
		    	  		return "";
		      }},
		      {key:'ProcessFinished', label:'<spring:message code="Cache.lbl_apv_complete_time"/> ',  width:'20', align:'center', formatter: //완료시간
		    	  function(){
		    	  	if(this.item.ProcessFinished != null)
		    	  		return CFN_TransLocalTime(this.item.ProcessFinished)
		    	  	else 
		    	  		return "";
		      }}
		      ,
		      {key:'UserOpinion', label:'<spring:message code="Cache.lbl_govdoc_receiveDoc"/> ',  width:'20', align:'center', formatter: //수신문서
		    	  function(){
		    	  		if( ProcessID != this.item.ProcessID) return '<button type="button" class="AXButton" onclick="opinion_Click(\''+ this.item.ProcessID +'\');"><spring:message code='Cache.lbl_govdoc_receiveDoc'/></button>';
				}
		       }
		      ];
		} 		

		 ListGrid.setGridHeader(headerData);	
	}
	
	function setGridConfig(){
		var configObj = {
				targetID : "ListGrid",
				height:"340",
				listCountMSG:"<b>{listCount}</b> 개",
				resizeable:false,
                page: {
                	display: false,
					paging: false
                },
                body:{
                	onclick:function(){
                		if(this.c == 1)
                			openFormDraft(this.list[this.index].FormID);
                	}
                }
		}
		
		ListGrid.setGridConfig(configObj);
	}
	
	function ExcelDownLoad(){			
		
		var headerArr = getHeaderDataForExcel();
		
		if(confirm("<spring:message code='Cache.msg_ExcelDownMessage'/>")){
			
			var Params = {
					ProcessID : ProcessID, 
					FormIstID : FormInstID
			};
			
			location.href = "receiptReadListExcelDownload.do?"
				+"selectParams="+JSON.stringify(Params)
				+"&title="+"ReceiptReadList"
				+"&headerkey="+headerArr[0]
				+"&headername="+headerArr[1];			
		}
	}

	function getHeaderDataForExcel(){
		var returnArr = new Array();
		var headerKey = "";
		var headerName = "";

		for(var i=0;i<headerData.length; i++){
			if(headerData[i].formatter != "checkbox"){
				headerKey += headerData[i].key + ",";
				headerName += headerData[i].label + ";";
			}
		}
		returnArr.push(headerKey.slice(0,-1));
		returnArr.push(headerName);

		return returnArr;
	}
	
	function setListData(){		
		
		var Params = {
				ProcessID : ProcessID, 
				FormIstID : FormInstID,
				GovDocs : GovDocs
		};
		
		ListGrid.bindGrid({
			ajaxUrl: (GovDocs == "distribution")? "getGovDocReceiptReadListData.do" : "getReceiptReadListData.do",//조회 컨트롤러
			ajaxPars: Params,
			onLoad: function(){
				//setGridCount();
			}
		});
	}
	
	// 추가발송, 중복발송
	function btSend_Click() {
		_CallBackMethod = OrgMap_CallBack;
    	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod&szObject=&type="+"D9"+"&setParamData=_setParamdata", "", "1060px", "580px");
    }
    function OrgMap_CallBack(pStrItemInfo) {
        var oJsonOrgMap = $.parseJSON(pStrItemInfo);
        
        if (oJsonOrgMap != null) {
        	m_oInfoSrc.m_bFrmExtDirty = true; 
        	
        	var objArr_person = new Array();
        	var objArr_ou = new Array();
        	
        	var dataInfo = {};
        	var dataInfoStr = "";
        	dataInfo.piid = m_oInfoSrc.getInfo("ProcessInfo.ParentProcessID") == "0" ? m_oInfoSrc.getInfo("ProcessInfo.ProcessID") : m_oInfoSrc.getInfo("ProcessInfo.ParentProcessID");
        	dataInfo.approvalLine = JSON.stringify(m_oInfoSrc.getApvList());
        	dataInfo.docNumber = m_oInfoSrc.getInfo("FormInstanceInfo.DocNo");
        	dataInfo.context = JSON.stringify(m_oInfoSrc.getDefaultJSON());
        	
            var strflag = true;

            var oChildren = $$(oJsonOrgMap).find("item");
            $$(oChildren).concat().each(function (i, oChild) {
            	var dataInfo_receiptList = {};
            	
                var cmpoucode = ";" +  $$(oChild).attr("AN") + ";";
                if (m_oInfoSrc.document.getElementById("ReceiptList").value.indexOf(cmpoucode) > -1) {
                    strflag = false;
                }
                var currNode = {};
                if ($$(oChild).attr("itemType") == "user") {
                	$$(dataInfo_receiptList).attr("code", $$(oChild).attr("AN"));
                	$$(dataInfo_receiptList).attr("name", $$(oChild).attr("DN"));
                	$$(dataInfo_receiptList).attr("type", "1");
                	$$(dataInfo_receiptList).attr("status", "inactive");
                	
                	objArr_person.push(dataInfo_receiptList);
                } else {
                	$$(dataInfo_receiptList).attr("code", $$(oChild).attr("AN"));
                	$$(dataInfo_receiptList).attr("name", $$(oChild).attr("DN"));
                	$$(dataInfo_receiptList).attr("type", "0");
                	$$(dataInfo_receiptList).attr("status", "inactive");
                	
                	objArr_ou.push(dataInfo_receiptList);
                }
            });
            
            var sMsg = Common.getDic("msg_apv_191");//"해당 항목들을 발송하시겠습니까?"
            if(strflag == false) sMsg = Common.getDic("msg_apv_345");

            Common.Confirm(sMsg, "Confirmation Dialog", function (result) {
                if (result) {
                	if(objArr_person.length > 0) { // 사용자
                		dataInfo.receiptList = objArr_person;
                		dataInfo.type = "1";
                		
                		dataInfoStr = JSON.stringify(dataInfo);
                		
                		startDistribution(dataInfoStr);
                	}
                	
                	if(objArr_ou.length > 0) { // 부서
                		dataInfo.receiptList = objArr_ou;
                		dataInfo.type = "0";
                		
                		dataInfoStr = JSON.stringify(dataInfo);
                		
                		startDistribution(dataInfoStr);
                	}
                }
            });
        }
    }
	
    function startDistribution(dataInfo) {
    	setTimeout(function () {
    		Common.Progress("", function () { 
		    	$.ajax({
					type:"POST",
					url : "/approval/legacy/startDistribution.do",
					data : {
						"DistributionInfo": dataInfo
					},
					dataType: "json", // 데이터타입을 JSON형식으로 지정
					success:function(res){
						if(res.result == 'ok'){
							Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />");		//성공적으로 처리 되었습니다.
							setTimeout("document.location.reload()", 1000);
		    			} else {
		    				Common.Error(res.message);
		    			}	
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/approval/legacy/startDistribution.do", response, status, error);
					}
				});
    		}, 100);
    	}, 1000);

    }
    
    function checkAll(obj) {
        var chklist = document.getElementsByName("chk");

        if (chklist.length == null || chklist.length == "0") {
        }
        else {
            if (obj.checked == true) {
                for (var i = 0; i < chklist.length; i++) {
                    chklist[i].checked = true;
                }
            }
            else {
                for (var i = 0; i < chklist.length; i++) {
                    chklist[i].checked = false;
                }
            }
        }
    }
    
    function deleteClick() {
    	var dataInfo = {};
    	var items = new Array();
        var strflag = false;

        if (document.getElementsByName("chk").length != null && document.getElementsByName("chk").length != 0) {
            for (var i = 0; i < document.getElementsByName("chk").length; i++) {
            	var item = {};
            	
                if (document.getElementsByName("chk")[i].checked == true) {
                	item.wiid = ListGrid.list[i].WorkItemID;
                    item.piid = ListGrid.list[i].ProcessID;
                    
                    items.push(item);
                    strflag = true;
                }
            }
            
            dataInfo.item = items;
        }

        if (strflag == false) {
            Common.Warning(Common.getDic("msg_apv_003"));
            return;
        } else {
        	//"해당 항목들을 발송 취소하시겠습니까?"
        	Common.Confirm(Common.getDic("msg_apv_190"), "Confirmation Dialog", function (result) {
                if (result) {
                	$.ajax({
    	    			type:"POST",
    	    			url : "/approval/legacy/deleteDistribution.do",
    	    			data : {
    	    				"Items": JSON.stringify(dataInfo)
    	    			},
    	    			dataType: "json", // 데이터타입을 JSON형식으로 지정
    	    			success:function(res){
    	    				if(res.result == 'ok'){
    	    					Common.Inform("<spring:message code='Cache.msg_apv_alert_006' />");		//성공적으로 처리 되었습니다.
    	    					setTimeout("document.location.reload()", 1000);
    	        			} else {
    	        				Common.Error(res.message);
    	        			}	
    	    			},
    	    			error:function(response, status, error){
    	    				CFN_ErrorAjax("/approval/legacy/deleteDistribution.do", response, status, error);
    	    			}
    	    		});
                }
            });
        }
    }
    
    function opinion_Click(processID){
		CFN_OpenWindow("/approval/approval_Form.do?mode=COMMENT&processID="+processID, "", 790, (window.screen.height - 100), "resize");
    }
    
	function btnClose_Click(){
		Common.Close();
	}

</script>
<form>
<div class="layer_divpop ui-draggable" id="testpopup_p" style="width: 100%; min-width:840px; /*height: 741px;*/ z-index: 51;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
  <div class="divpop_contents">
	    <div class="pop_header" id="testpopup_ph">
	      <h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico"><spring:message code='Cache.lbl_apv_receipt_view'/></span></h4>
	      <!--<a class="divpop_close" id="testpopup_px" style="cursor: pointer;"></a><a class="divpop_window" id="testpopup_LayertoWindow" style="cursor: pointer;" onclick="Common.LayerToWindow('layerpopuptest.do?as=ads', 'testpopup', '331px', '270px', 'both')"></a><a class="divpop_full" style="cursor: pointer;" onclick="Common.ScreenFull('testpopup', $(this))"></a><a class="divpop_mini" style="cursor: pointer;" onclick="Common.ScreenMini('testpopup', $(this))"></a>-->
	    </div>
	    <!-- 팝업 Contents 시작 -->
	    <div class="popBox">
		    <div class="coviGrid">
				<div id="ListGrid"></div>
			</div>
			<div class="popBtn">
				<a class="ooBtn" href="#ax" onclick="btSend_Click(); return false;" id="btSend"><spring:message code='Cache.btn_apv_addsend'/></a>
				<a class="ooBtn" href="#ax" onclick="deleteClick(); return false;" id="btDelete"><spring:message code='Cache.btn_apv_sendcancel'/></a>
				<a class="ooBtn" href="#ax" onclick="ExcelDownLoad(); return false;" id="btExcel" style="display: none;"><spring:message code='Cache.lbl_apv_SaveToExcel'/></a>
				
				<a class="owBtn" href="#ax" onclick="btnClose_Click(); return false;"><spring:message code='Cache.btn_apv_close'/></a>
			</div>
		</div>
  </div>
</div>
</form>