/**
 * 
 * AUDIT 적용 참고 case "user"
 * 
 */
var expAppCommon = {
	pivotHeaderData : [],	
		
	//Grid Header 항목 시작
	getGridHeader: function( pHeaderType ){
		var headerData;
		switch( pHeaderType ){
		case "list":
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_title","ACC_lbl_noTitle","ACC_lbl_aprvWriter","ACC_lbl_aprvDate","ACC_lbl_payDay","ACC_lbl_proofDate","ACC_lbl_proofTime",
			                   "ACC_lbl_evidType","ACC_lbl_vendorName","ACC_lbl_taxValue","ACC_lbl_supplyValue","ACC_lbl_eviTotalAmt","ACC_billReqAmt","ACC_lbl_processStatus","ACC_lbl_docNo",
			                   "ACC_lbl_addFile","ACC_lbl_viewEvid","ACC_lbl_requestType","ACC_lbl_chargeJob","ACC_lbl_company","ACC_lbl_useHistory2"]);
			headerData = [
					{ key:'chk',						label:'chk',		width:'30',		align:'center',	formatter:'checkbox'},
					{ key:'CompanyCode',			label:Common.getDic("ACC_lbl_companyCode"),		width:'120',		align:'center', display: false},	
					{ key:'CompanyName',			label:Common.getDic("ACC_lbl_company"),			width:'120', align:'center'},		//회사	
					{ key:'ApplicationTitle',			label : Common.getDic("ACC_lbl_title"),				width:'200', align:'left'
						, formatter:function () {
							var retStr = "";
							var title = "("+Common.getDic("ACC_lbl_noTitle")+")";
							
							if(!isEmptyStr(this.item.ApplicationTitle)){
								title = this.item.ApplicationTitle;
							}
							
							if(this.item.ApplicationStatus=="T"){
								retStr = "<a href='#' onClick=\"ExpenceApplicationManage.expAppMan_viewEvidTempPopup('"+this.item.ExpenceApplicationID+"', '"+this.item.ApplicationType+"', '"+this.item.RequestType+"', '" + this.item.RegisterID + "')\"><font color='blue'><u>"+title+"</u></font></a>";										
							}else{
								retStr = "<a href='#' onClick=\"ExpenceApplicationManage.expAppMan_viewEvidPopup('"+this.item.ExpenceApplicationID+"', '"+this.item.ProcessID+"')\"><font color='blue'><u>"+title+"</u></font></a>";
							}
							
							return retStr;
						}
					},
					{ key:'RegisterName',				label : Common.getDic("ACC_lbl_aprvWriter"),			width:'100', align:'center'},	//기안자
					{ key:'ApplicationDate',			label : Common.getDic("ACC_lbl_aprvDate")+Common.getSession("UR_TimeZoneDisplay"),		width:'100', align:'center',
						formatter:function(){
							return CFN_TransLocalTime(this.item.ApplicationDate,_ServerDateSimpleFormat);
						}, dataType:'DateTime'
					},
					{ key:'ApplicationStatusName',		label : Common.getDic("ACC_lbl_processStatus"),		width:'100', align:'center'},	//처리상태
					{ key:'RequestTypeName',			label : Common.getDic("ACC_lbl_requestType"),			width:'150', align:'center'},	//신청유형
					{ key:'PayDate',					label : Common.getDic("ACC_lbl_payDay"),				width:'100', align:'center'},	//지급일
					{ key:'ProofDate',					label : Common.getDic("ACC_lbl_proofDate"),			width:'100', align:'center'		//증빙일자
						, formatter:function () {
							var getDateStr = this.item.ProofDate;
							
							var auditColor = "";
							if(this.item.WeekendColor != null && this.item.WeekendColor != "") 
								auditColor = this.item.WeekendColor;
							else if(this.item.HolidayColor != null && this.item.HolidayColor != "") 
								auditColor = this.item.HolidayColor;
							else if(this.item.VacationColor != null && this.item.VacationColor != "") 
								auditColor = this.item.VacationColor;
							
							var str = "<div style='background-color:"+auditColor+"'>"+getDateStr+"</div>"
							return str;
						}
					},
					{ key:'ProofTime',					label : Common.getDic("ACC_lbl_proofTime"),			width:'100', align:'center'		//증빙시간
						, formatter:function () {
							var getTimeStr = this.item.ProofTime;
							if(getTimeStr != null && getTimeStr.length > 8) {
								getTimeStr = getTimeStr.substring(0, 8);
							}
							
							var auditColor = "";
							if(this.item.MidnightColor != null && this.item.MidnightColor != "") 
								auditColor = this.item.MidnightColor;
							
							var str = "<div style='background-color:"+auditColor+"'>"+getTimeStr+"</div>"
							return str;
						}
					},
					{ key:'ProofCodeName',				label : Common.getDic("ACC_lbl_evidType"),				width:'100', align:'center'},	//증빙유형
					{ key:'VendorName',					label : Common.getDic("ACC_lbl_vendorName"),			width:'150', align:'center'},	//거래처명
					{ key:'StoreName',				label : "가맹점명",		width:'150', align:'center'},
					{ key:'UsageComment',				label : Common.getDic("ACC_lbl_useHistory2"),			width:'200', align:'left'		//적요
						, formatter: function() {		
							var comment = this.item.UsageComment;
							if(comment) comment = comment.replace(/<br>/gi, '\r\n');
							return "<div title='"+comment+"'>"+comment+"</div>";
						}
					},
					{ 
						key:'TaxAmount',				
						label : Common.getDic("ACC_lbl_taxValue"),				
						width:'100', 
						align:'right',
						formatter: function() {
							return toAmtFormat(Number(AmttoNumFormat(this.item.TaxAmount)));
						}
					},		
					{ 
						key:'RepAmount',
						label : Common.getDic("ACC_lbl_supplyValue"),
						width:'100',
						align:'right',
						formatter: function() {
							return toAmtFormat(Number(AmttoNumFormat(this.item.RepAmount)));
						}
					},	
					{ 
						key:'TotalAmount',
						label : Common.getDic("ACC_lbl_eviTotalAmt"),			
						width:'100', 
						align:'right',
						formatter: function() {
							return toAmtFormat(Number(AmttoNumFormat(this.item.TotalAmount)));
						}
					},
					{ 
						key:'AmountSum',				
						label : Common.getDic("ACC_billReqAmt"),				
						width:'100', 
						align:'right', 
						formatter:function () {
							// var setAmt = this.item.AmountSum == "" ? 0 : this.item.AmountSum;
							var setAmt = toAmtFormat(Number(AmttoNumFormat(this.item.AmountSum)));
							var auditColor = "";
							if(this.item.AmountSumColor != null && this.item.AmountSumColor != "") 
								auditColor = this.item.AmountSumColor;
							
							var str = "<div style='background-color:"+auditColor+"'>"+setAmt+"</div>";
							return str;
						}
					},
					{ key:'DocNo',						label : Common.getDic("ACC_lbl_docNo"),				width:'100', align:'center'},	//전표번호
					{ key:'FileCnt',					label : Common.getDic("ACC_lbl_addFile"),				width:'70', align:'center'		//첨부파일
						, formatter:function () {
							var str = "";
							if(this.item.FileCnt>0){
								str= '<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">'
									+'<span class="tblIcAttFile" onClick="ExpenceApplicationManage.expAppMan_expAppManViewFile(\''+this.item.ExpenceApplicationListID+'\')"></span>'
									+'</div>'
							}
							
							return str;
						}
						, sort: false
					},
					{ key:'DocCnt',						label : Common.getDic("ACC_lbl_viewEvid"),				width:'150', align:'center'
						, formatter:function () {
							var str = "";
							if(this.item.ProofCode=="CorpCard"){
								str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManage.expAppMan_viewEvidListItem(\''
									+this.item.ProofCode+'\', \''+nullToBlank(this.item.CardReceiptID)+'\')">'
									+Common.getDic("ACC_lbl_viewEvid")+'</a>';
							}
							else if(this.item.ProofCode=="TaxBill"){
								str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManage.expAppMan_viewEvidListItem(\''
									+this.item.ProofCode+'\', \''+nullToBlank(this.item.TaxInvoiceID)+'\')">'
									+Common.getDic("ACC_lbl_viewEvid")+'</a>';
							}
							else if(this.item.ProofCode=="Receipt"){
								str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManage.expAppMan_viewEvidListItem(\''
									+this.item.ProofCode+'\', \''+nullToBlank(this.item.ReceiptFileID)+'\')">'
									+Common.getDic("ACC_lbl_viewEvid")+'</a>';
							}
							return str;
						}
						, sort: false
					},
					
					// 은행정보 추가(증빙별 보기시)
					{ key:'BankName',				label : Common.getDic("ACC_lbl_BankName"),					width:'100', align:'center'},	//은행
					{ key:'BankAccountNo',			label : Common.getDic("ACC_lbl_BankAccount"),				width:'150', align:'center'},	//계좌번호
					{ key:'BankAccountName',		label : Common.getDic("ACC_lbl_BankAccountHolder"),			width:'150', align:'center'}	//예금주
				]
			break;
		case "div":
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_title","ACC_lbl_noTitle","ACC_lbl_aprvWriter","ACC_lbl_aprvDate","ACC_lbl_payDay","ACC_lbl_proofDate","ACC_lbl_proofTime",
			                   "ACC_lbl_evidType","ACC_lbl_vendorName","ACC_lbl_taxValue","ACC_lbl_supplyValue","ACC_billReqAmt","ACC_lbl_eviTotalAmt","ACC_lbl_processStatus","ACC_lbl_docNo",
			                   "ACC_lbl_account","ACC_lbl_costCenter","ACC_lbl_projectName","ACC_standardBrief","ACC_lbl_addFile","ACC_lbl_viewEvid","ACC_lbl_requestType",
			                   "ACC_lbl_chargeJob","ACC_lbl_company","ACC_lbl_useHistory2"]);			
			headerData = [
							{ key:'chk',					label:'chk',		width:'30',		align:'center',	formatter:'checkbox'},
							{ key:'CompanyCode',			label:Common.getDic("ACC_lbl_companyCode"),		width:'120',		align:'center', display: false},	
							{ key:'CompanyName',			label:Common.getDic("ACC_lbl_company"),			width:'120', align:'center'},		//회사	
							{ key:'ApplicationTitle',		label : Common.getDic("ACC_lbl_title"),		width:'200', align:'left'
								, formatter:function () {
									var retStr = "";
									var title = "("+Common.getDic("ACC_lbl_noTitle")+")";
									
									if(!isEmptyStr(this.item.ApplicationTitle)){
										title = this.item.ApplicationTitle;
									}
									
									if(this.item.ApplicationStatus=="T"){
										retStr = "<a href='#' onClick=\"ExpenceApplicationManage.expAppMan_viewEvidTempPopup('"+this.item.ExpenceApplicationID+"', '"+this.item.ApplicationType+"', '"+this.item.RequestType+"', '" + this.item.RegisterID + "')\"><font color='blue'><u>"+title+"</u></font></a>";										
									}else{
										retStr = "<a href='#' onClick=\"ExpenceApplicationManage.expAppMan_viewEvidPopup('"+this.item.ExpenceApplicationID+"', '"+this.item.ProcessID+"')\"><font color='blue'><u>"+title+"</u></font></a>";
									}
										
									return retStr;
								}
							},
							{ key:'RegisterName',			label : Common.getDic("ACC_lbl_aprvWriter"),	width:'100', align:'center'},
							{ key:'ApplicationDate',		label : Common.getDic("ACC_lbl_aprvDate")+Common.getSession("UR_TimeZoneDisplay"),		width:'100', align:'center',
								formatter:function(){
									return CFN_TransLocalTime(this.item.ApplicationDate,_ServerDateSimpleFormat);
								}, dataType:'DateTime'
							},
							{ key:'ApplicationStatusName',	label : Common.getDic("ACC_lbl_processStatus"),width:'100', align:'center'},
							{ key:'RequestTypeName',		label : Common.getDic("ACC_lbl_requestType"),	width:'150', align:'center'},	//신청유형
							{ key:'PayDate',				label : Common.getDic("ACC_lbl_payDay"),		width:'100', align:'center'},
							{ key:'ProofDate',				label : Common.getDic("ACC_lbl_proofDate"),	width:'100', align:'center'},
							{ key:'ProofCodeName',			label : Common.getDic("ACC_lbl_evidType"),		width:'100', align:'center'},
							{ key:'VendorName',				label : Common.getDic("ACC_lbl_vendorName"),	width:'150', align:'center'},
							{ key:'UsageComment',			label : Common.getDic("ACC_lbl_useHistory2"),	width:'200', align:'left'		//적요
								, formatter: function() {
									var comment = this.item.UsageComment;
									if(comment) comment = comment.replace(/<br>/gi, '\r\n');
									return "<div title='"+comment+"'>"+comment+"</div>";
								}
							},
							{ 
								key:'TaxAmount',				
								label : Common.getDic("ACC_lbl_taxValue"),			
								width:'100', 
								align:'right',
								formatter: function() {
									return toAmtFormat(Number(AmttoNumFormat(this.item.TaxAmount)));
								}
							},		
							{ 
								key:'RepAmount',				
								label : Common.getDic("ACC_lbl_supplyValue"),		
								width:'100', 
								align:'right',
								formatter: function() {
									return toAmtFormat(Number(AmttoNumFormat(this.item.RepAmount)));
								}
							},
							{ 
								key:'TotalAmount',			
								label : Common.getDic("ACC_lbl_eviTotalAmt"),		
								width:'100', 
								align:'right',
								formatter: function() {
									return toAmtFormat(Number(AmttoNumFormat(this.item.TotalAmount)));
								}
							},
							{ 
								key:'Amount',					
								label : Common.getDic("ACC_billReqAmt"),			
								width:'100', 
								align:'right',
								formatter: function() {
									return toAmtFormat(Number(AmttoNumFormat(this.item.Amount)));
								}
							},
							{ key:'CostCenterName',			label : Common.getDic("ACC_lbl_costCenter"),	width:'150', align:'center'},
							{ key:'IOName',					label : Common.getDic("ACC_lbl_projectName"),	width:'150', align:'center'},
							{ key:'AccountName',			label : Common.getDic("ACC_lbl_account"),		width:'150', align:'center'},
							{ key:'StandardBriefName',		label : Common.getDic("ACC_standardBrief"),	width:'150', align:'center'},
							{ key:'FileCnt',				label : Common.getDic("ACC_lbl_addFile"),		width:'70', align:'center'
								, formatter:function () {									
									var str = "";
									if(this.item.FileCnt>0){
										str= '<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">'
											+'<span class="tblIcAttFile" onClick="ExpenceApplicationManage.expAppMan_expAppManViewFile(\''+this.item.ExpenceApplicationListID+'\')"></span>'
											+'</div>'
									}
									
									return str;
								}
								, sort: false
							},
							{ key:'DocCnt',					label : Common.getDic("ACC_lbl_viewEvid"),		width:'150', align:'center'
								, formatter:function () {
									var str = "";
									if(this.item.ProofCode=="CorpCard"){
										str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManage.expAppMan_viewEvidListItem(\''
											+this.item.ProofCode+'\', \''+nullToBlank(this.item.CardReceiptID)+'\')">'
											+Common.getDic("ACC_lbl_viewEvid")+'</a>';
									}
									else if(this.item.ProofCode=="TaxBill"){
										str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManage.expAppMan_viewEvidListItem(\''
											+this.item.ProofCode+'\', \''+nullToBlank(this.item.TaxInvoiceID)+'\')">'
											+Common.getDic("ACC_lbl_viewEvid")+'</a>';
									}
									else if(this.item.ProofCode=="Receipt"){
										str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManage.expAppMan_viewEvidListItem(\''
											+this.item.ProofCode+'\', \''+nullToBlank(this.item.ReceiptFileID)+'\')">'
											+Common.getDic("ACC_lbl_viewEvid")+'</a>';
									}
									return str;
								}
								, sort: false
							},
						]
					break;
		case "app":
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_title","ACC_lbl_noTitle","ACC_lbl_aprvWriter","ACC_lbl_aprvDate","ACC_lbl_eviTotalAmt","ACC_billReqAmt","ACC_lbl_processStatus","ACC_lbl_viewAprv","ACC_lbl_requestType","ACC_lbl_chargeJob","ACC_lbl_company"]);				
			headerData = [
							{ key:'chk',					label:'chk',		width:'30',		align:'center',	formatter:'checkbox'},
							{ key:'CompanyCode',			label:Common.getDic("ACC_lbl_companyCode"),		width:'120',		align:'center', display: false},	
							{ key:'CompanyName',			label:Common.getDic("ACC_lbl_company"),			width:'120', align:'center'},		//회사
							{ key:'ApplicationTitle',		label : Common.getDic("ACC_lbl_title"),			width:'350', align:'left'
								, formatter:function () {
									var retStr = "";
									var title = "("+Common.getDic("ACC_lbl_noTitle")+")";
									
									if(!isEmptyStr(this.item.ApplicationTitle)){
										title = this.item.ApplicationTitle;
									}
									
									if(this.item.ApplicationStatus=="T"){
										retStr = "<a href='#' onClick=\"ExpenceApplicationManage.expAppMan_viewEvidTempPopup('"+this.item.ExpenceApplicationID+"', '"+this.item.ApplicationType+"', '"+this.item.RequestType+"', '" + this.item.RegisterID + "')\"><font color='blue'><u>"+title+"</u></font></a>";										
									}else{
										retStr = "<a href='#' onClick=\"ExpenceApplicationManage.expAppMan_viewEvidPopup('"+this.item.ExpenceApplicationID+"', '"+this.item.ProcessID+"')\"><font color='blue'><u>"+title+"</u></font></a>";
									}
									
									return retStr;
								}
							},
							{ key:'RegisterName',			label : Common.getDic("ACC_lbl_aprvWriter"),		width:'150', align:'center'},
							{ key:'ApplicationDate',		label : Common.getDic("ACC_lbl_aprvDate")+Common.getSession("UR_TimeZoneDisplay"),			width:'150', align:'center',
								formatter:function(){
									return CFN_TransLocalTime(this.item.ApplicationDate,_ServerDateSimpleFormat);
								}, dataType:'DateTime'
							},
							{ key:'ApplicationStatusName',	label : Common.getDic("ACC_lbl_processStatus"),	width:'120', align:'center'},
							{ key:'RequestTypeName',		label : Common.getDic("ACC_lbl_requestType"),		width:'150', align:'center'},	//신청유형
							{ 
								key:'TotalAmountSum',			
								label : Common.getDic("ACC_lbl_eviTotalAmt"),
								width:'100', 
								align:'right',
								formatter: function() {
									return toAmtFormat(Number(AmttoNumFormat(this.item.TotalAmountSum)));
								}
							},
							{ 
								key:'AmountSum',
								label : Common.getDic("ACC_billReqAmt"),
								width:'100',
								align:'right',
								formatter: function() {
									return toAmtFormat(Number(AmttoNumFormat(this.item.AmountSum)));
								}
							},
							{ key:'DocCnt',					label : Common.getDic("ACC_lbl_viewAprv"),			width:'200', align:'center'
								, formatter:function () {
									var str = "";
									var processID = nullToBlank(this.item.ProcessID);
									if(processID != "") {
										if(this.item.ApplicationStatus=="D"
											||this.item.ApplicationStatus=="P"
											||this.item.ApplicationStatus=="DC"
											||this.item.ApplicationStatus=="E"
											||this.item.ApplicationStatus=="R"
											||this.item.ApplicationStatus=="CD"
											||this.item.ApplicationStatus=="CP"
											||this.item.ApplicationStatus=="CE"
											||this.item.ApplicationStatus=="CR"){
											str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManage.expAppMan_LinkOpen(\''
												+this.item.ApplicationStatus+'\', \''+processID+'\')">'
												+Common.getDic("ACC_lbl_viewAprv")+'</a>';
										}
									}
									return str;
								}
								, sort: false
							},
						]
					break;
			
		case "listUser":
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_title","ACC_lbl_noTitle","ACC_lbl_aprvWriter","ACC_lbl_aprvDate","ACC_lbl_payDay","ACC_lbl_proofDate","ACC_lbl_proofTime",
			                   "ACC_lbl_evidType","ACC_lbl_vendorName","ACC_lbl_taxValue","ACC_lbl_supplyValue","ACC_lbl_eviTotalAmt","ACC_billReqAmt",
			                   "ACC_lbl_processStatus","ACC_lbl_docNo","ACC_lbl_addFile","ACC_lbl_viewAprv","ACC_lbl_viewEvid","ACC_lbl_requestType","ACC_lbl_chargeJob",
			                   "ACC_lbl_company","ACC_lbl_useHistory2"]);				
			
			headerData = [
					{ key:'chk',					label:'chk',		width:'30',		align:'center',	formatter:'checkbox'
						, disabled:function(){ 
		              		if(this.item.ApplicationStatus == "T"){
		              			return false;
		              		}else{
		              			return true;
		              		}
						}
					},
					{ key:'CompanyCode',			label:Common.getDic("ACC_lbl_company"),		width:'120',		align:'center',		//회사
						formatter: function() {
							return this.item.CompanyName;
						}
					},	
					{ key:'ApplicationTitle',		label : Common.getDic("ACC_lbl_title"),				width:'200', align:'left'
						, formatter:function () {
							var retStr = "";
							var title = "("+Common.getDic("ACC_lbl_noTitle")+")";
							
							if(!isEmptyStr(this.item.ApplicationTitle)){
								title = this.item.ApplicationTitle;
							}
							
							if(this.item.ApplicationStatus=="T"){
								retStr = "<a href='#' onClick=\"ExpenceApplicationManageUser.expAppManUser_evidWritePage('"+this.item.ExpenceApplicationID+"', '"+this.item.ApplicationType+"', '" +this.item.RequestType+"')\"><font color='blue'><u>"+title+"</u></font></a>";
							}else{
								retStr = "<a href='#' onClick=\"ExpenceApplicationManageUser.expAppManUser_viewEvidPopup('"+this.item.ExpenceApplicationID+"', '"+this.item.ProcessID+"')\"><font color='blue'><u>"+title+"</u></font></a>";
							}
							return retStr;
						}
					},
					{ key:'RegisterName',			label : Common.getDic("ACC_lbl_aprvWriter"),			width:'100', align:'center',
						formatter:function () {
							// 프리젠트 (FlowerName)
						 	var RegisterName = "<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+this.item.RegisterID+"\" data-user-mail>" + this.item.RegisterName + "</div>";
		            	  	return RegisterName;
						}
					},
					{ key:'ApplicationDate',		label : Common.getDic("ACC_lbl_aprvDate")+Common.getSession("UR_TimeZoneDisplay"),				width:'100', align:'center',
						formatter:function(){
							return CFN_TransLocalTime(this.item.ApplicationDate,_ServerDateSimpleFormat);
						}, dataType:'DateTime'
					},
					{ key:'ApplicationStatusName',	label : Common.getDic("ACC_lbl_processStatus"),		width:'100', align:'center'},
					{ key:'RequestTypeName',		label : Common.getDic("ACC_lbl_requestType"),			width:'150', align:'center'},	//신청유형
					{ key:'PayDate',				label : Common.getDic("ACC_lbl_payDay"),				width:'100', align:'center'},
					{ key:'ProofDate',				label : Common.getDic("ACC_lbl_proofDate"),			width:'100', align:'center'
						, formatter:function () {
							var getDateStr = this.item.ProofDate;
							
							var auditColor = "";
							if(this.item.WeekendColor != null && this.item.WeekendColor != "") 
								auditColor = this.item.WeekendColor;
							else if(this.item.VacationColor != null && this.item.VacationColor != "") 
								auditColor = this.item.VacationColor;
							else if(this.item.HolidayColor != null && this.item.HolidayColor != "") 
								auditColor = this.item.HolidayColor;
							
							var str = "<div style='background-color:"+auditColor+"'>"+getDateStr+"</div>"
							return str;
						}
					},
					{ key:'ProofTime',					label : Common.getDic("ACC_lbl_proofTime"),			width:'100', align:'center'		//증빙시간
						, formatter:function () {
							var getTimeStr = this.item.ProofTime;
							if(getTimeStr != null && getTimeStr.length > 8) {
								getTimeStr = getTimeStr.substring(0, 8);
							}
							
							var auditColor = "";
							if(this.item.MidnightColor != null && this.item.MidnightColor != "") 
								auditColor = this.item.MidnightColor;
							
							var str = "<div style='background-color:"+auditColor+"'>"+getTimeStr+"</div>"
							return str;
						}
					},
					{ key:'ProofCodeName',			label : Common.getDic("ACC_lbl_evidType"),				width:'100', align:'center'},
					{ key:'VendorName',				label : Common.getDic("ACC_lbl_vendorName"),			width:'150', align:'center'},
					{ key:'UsageComment',			label : Common.getDic("ACC_lbl_useHistory2"),			width:'200', align:'left'		//적요
						, formatter: function() {
							var comment = this.item.UsageComment;
							if(comment) comment = comment.replace(/<br>/gi, '\r\n');
							return "<div title='"+comment+"'>"+comment+"</div>";
						}
					},
					{ 
						key:'TaxAmount',				
						label : Common.getDic("ACC_lbl_taxValue"),				
						width:'100', 
						align:'right',
						formatter: function() {
							return toAmtFormat(Number(AmttoNumFormat(this.item.TaxAmount)));
						}
					},		
					{ 
						key:'RepAmount',
						label : Common.getDic("ACC_lbl_supplyValue"),
						width:'100',
						align:'right',
						formatter: function() {
							return toAmtFormat(Number(AmttoNumFormat(this.item.RepAmount)));
						}
					},	
					{ 
						key:'TotalAmount',
						label : Common.getDic("ACC_lbl_eviTotalAmt"),			
						width:'100', 
						align:'right',
						formatter: function() {
							return toAmtFormat(Number(AmttoNumFormat(this.item.TotalAmount)));
						}
					},
					{ 
						key:'AmountSum',				
						label : Common.getDic("ACC_billReqAmt"),				
						width:'100', 
						align:'right', 
						formatter:function () {
							// var setAmt = this.item.AmountSum == "" ? 0 : this.item.AmountSum;
							var setAmt = toAmtFormat(Number(AmttoNumFormat(this.item.AmountSum)));
							var auditColor = "";
							if(this.item.AmountSumColor != null && this.item.AmountSumColor != "") 
								auditColor = this.item.AmountSumColor;
							
							var str = "<div style='background-color:"+auditColor+"'>"+setAmt+"</div>";
							return str;
						}
					},
					{ key:'DocNo',					label : Common.getDic("ACC_lbl_docNo"),				width:'100', align:'center'},	//전표번호
					{ key:'FileCnt',				label : Common.getDic("ACC_lbl_addFile"),				width:'70', align:'center'
						, formatter:function () {
							var str = "";
							if(this.item.FileCnt>0){
								str= '<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">'
									+'<span class="tblIcAttFile" onClick="ExpenceApplicationManageUser.expAppManUser_expAppManViewFile(\''+this.item.ExpenceApplicationListID+'\')"></span>'
									+'</div>'
							}
							
							return str;
						}
						, sort: false
					},
					{ key:'DocCnt',					label : Common.getDic("ACC_lbl_viewEvid"),				width:'150', align:'center'
						, formatter:function () {
							var str = "";
							if(this.item.ProofCode=="CorpCard"){
								str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManageUser.expAppManUser_viewEvidListItem(\''
									+this.item.ProofCode+'\', \''+nullToBlank(this.item.CardReceiptID)+'\')">'
									+Common.getDic("ACC_lbl_viewEvid")+'</a>';
							}
							else if(this.item.ProofCode=="TaxBill"){
								str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManageUser.expAppManUser_viewEvidListItem(\''
									+this.item.ProofCode+'\', \''+nullToBlank(this.item.TaxInvoiceID)+'\')">'
									+Common.getDic("ACC_lbl_viewEvid")+'</a>';
							}
							else if(this.item.ProofCode=="Receipt"){
								str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManageUser.expAppManUser_viewEvidListItem(\''
									+this.item.ProofCode+'\', \''+nullToBlank(this.item.ReceiptFileID)+'\')">'
									+Common.getDic("ACC_lbl_viewEvid")+'</a>';
							}
							return str;
						}
						, sort: false
					},
				]
			break;
		case "divUser":
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_title","ACC_lbl_noTitle","ACC_lbl_aprvWriter","ACC_lbl_aprvDate","ACC_lbl_payDay","ACC_lbl_proofDate","ACC_lbl_proofTime",
			                   "ACC_lbl_evidType","ACC_lbl_vendorName","ACC_lbl_taxValue","ACC_lbl_supplyValue","ACC_lbl_eviTotalAmt","ACC_billReqAmt",
			                   "ACC_lbl_account","ACC_lbl_costCenter","ACC_lbl_projectName","ACC_standardBrief","ACC_lbl_processStatus","ACC_lbl_docNo","ACC_lbl_addFile",
			                   "ACC_lbl_viewAprv","ACC_lbl_viewEvid","ACC_lbl_requestType","ACC_lbl_chargeJob","ACC_lbl_company","ACC_lbl_useHistory2"]);
			
			headerData = [
							{ key:'chk',			label:'chk',		width:'30',		align:'center',	formatter:'checkbox', disabled:function(){ return true; }},
							{ key:'CompanyCode',			label:Common.getDic("ACC_lbl_company"),		width:'120',		align:'center',		//회사
								formatter: function() {
									return this.item.CompanyName;
								}
							},	
							{ key:'ApplicationTitle',		label : Common.getDic("ACC_lbl_title"),		width:'200', align:'left'
								, formatter:function () {
									var retStr = "";
									var title = "("+Common.getDic("ACC_lbl_noTitle")+")";
									
									if(!isEmptyStr(this.item.ApplicationTitle)){
										title = this.item.ApplicationTitle;
									}
									
									if(this.item.ApplicationStatus=="T"){
										retStr = "<a href='#' onClick=\"ExpenceApplicationManageUser.expAppManUser_evidWritePage('"+this.item.ExpenceApplicationID+"', '"+this.item.ApplicationType+"', '"+this.item.RequestType+"')\"><font color='blue'><u>"+title+"</u></font></a>";
									}else{
										retStr = "<a href='#' onClick=\"ExpenceApplicationManageUser.expAppManUser_viewEvidPopup('"+this.item.ExpenceApplicationID+"', '"+this.item.ProcessID+"')\"><font color='blue'><u>"+title+"</u></font></a>";
									}
									return retStr;
								}
							},
							{ key:'RegisterName',			label : Common.getDic("ACC_lbl_aprvWriter"),		width:'100', align:'center',
								formatter:function () {
									// 프리젠트 (FlowerName)
								 	var RegisterName = "<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+this.item.RegisterID+"\" data-user-mail>" + this.item.RegisterName + "</div>";
		                		  	return RegisterName;
								}
							},
							{ key:'ApplicationDate',		label : Common.getDic("ACC_lbl_aprvDate")+Common.getSession("UR_TimeZoneDisplay"),			width:'100', align:'center',
								formatter:function(){
									return CFN_TransLocalTime(this.item.ApplicationDate,_ServerDateSimpleFormat);
								}, dataType:'DateTime'
							},
							{ key:'ApplicationStatusName',	label : Common.getDic("ACC_lbl_processStatus"),	width:'100', align:'center'},
							{ key:'RequestTypeName',		label : Common.getDic("ACC_lbl_requestType"),		width:'150', align:'center'},	//신청유형
							{ key:'PayDate',				label : Common.getDic("ACC_lbl_payDay"),			width:'100', align:'center'},
							{ key:'ProofDate',				label : Common.getDic("ACC_lbl_proofDate"),		width:'100', align:'center'},
							{ key:'ProofCodeName',			label : Common.getDic("ACC_lbl_evidType"),			width:'100', align:'center'},
							{ key:'VendorName',				label : Common.getDic("ACC_lbl_vendorName"),		width:'150', align:'center'},
							{ key:'UsageComment',			label : Common.getDic("ACC_lbl_useHistory2"),		width:'200', align:'left'		//적요
								, formatter: function() {
									var comment = this.item.UsageComment;
									if(comment) comment = comment.replace(/<br>/gi, '\r\n');
									return "<div title='"+comment+"'>"+comment+"</div>";
								}
							},
							{ 
								key:'TaxAmount',				
								label : Common.getDic("ACC_lbl_taxValue"),			
								width:'100', 
								align:'right',
								formatter: function() {
									return toAmtFormat(Number(AmttoNumFormat(this.item.TaxAmount)));
								}
							},		
							{ 
								key:'RepAmount',				
								label : Common.getDic("ACC_lbl_supplyValue"),		
								width:'100', 
								align:'right',
								formatter: function() {
									return toAmtFormat(Number(AmttoNumFormat(this.item.RepAmount)));
								}
							},
							{ 
								key:'TotalAmount',			
								label : Common.getDic("ACC_lbl_eviTotalAmt"),		
								width:'100', 
								align:'right',
								formatter: function() {
									return toAmtFormat(Number(AmttoNumFormat(this.item.TotalAmount)));
								}
							},
							{ 
								key:'Amount',					
								label : Common.getDic("ACC_billReqAmt"),			
								width:'100', 
								align:'right',
								formatter: function() {
									return toAmtFormat(Number(AmttoNumFormat(this.item.Amount)));
								}
							},
							{ key:'CostCenterName',			label : Common.getDic("ACC_lbl_costCenter"),		width:'150', align:'center'},
							{ key:'IOName',					label : Common.getDic("ACC_lbl_projectName"),		width:'150', align:'center'},
							{ key:'AccountName',			label : Common.getDic("ACC_lbl_account"),			width:'150', align:'center'},
							{ key:'StandardBriefName',		label : Common.getDic("ACC_standardBrief"),		width:'150', align:'center'},
							{ key:'FileCnt',				label : Common.getDic("ACC_lbl_addFile"),			width:'70', align:'center'
								, formatter:function () {									
									var str = "";
									if(this.item.FileCnt>0){
										str= '<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">'
											+'<span class="tblIcAttFile" onClick="ExpenceApplicationManageUser.expAppManUser_expAppManViewFile(\''+this.item.ExpenceApplicationListID+'\')"></span>'
											+'</div>'
									}
									
									return str;
								}
								, sort: false
							},
							{ key:'DocCnt',					label : Common.getDic("ACC_lbl_viewEvid"),			width:'150', align:'center'
								, formatter:function () {
									var str = "";
									if(this.item.ProofCode=="CorpCard"){
										str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManageUser.expAppManUser_viewEvidListItem(\''
											+this.item.ProofCode+'\', \''+nullToBlank(this.item.CardReceiptID)+'\')">'
											+Common.getDic("ACC_lbl_viewEvid")+'</a>';
									}
									else if(this.item.ProofCode=="TaxBill"){
										str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManageUser.expAppManUser_viewEvidListItem(\''
											+this.item.ProofCode+'\', \''+nullToBlank(this.item.TaxInvoiceID)+'\')">'
											+Common.getDic("ACC_lbl_viewEvid")+'</a>';
									}
									else if(this.item.ProofCode=="Receipt"){
										str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManageUser.expAppManUser_viewEvidListItem(\''
											+this.item.ProofCode+'\', \''+nullToBlank(this.item.ReceiptFileID)+'\')">'
											+Common.getDic("ACC_lbl_viewEvid")+'</a>';
									}
									return str;
								}
								, sort: false
							},
						]
					break;
		case "appUser":
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_title","ACC_lbl_noTitle","ACC_lbl_aprvWriter","ACC_lbl_aprvDate","ACC_lbl_payDay","ACC_lbl_proofDate",
			                   "ACC_lbl_evidType","ACC_lbl_vendorName","ACC_lbl_taxValue","ACC_lbl_supplyValue","ACC_lbl_eviTotalAmt","ACC_billReqAmt",
			                   "ACC_lbl_processStatus","ACC_lbl_docNo","ACC_lbl_addFile","ACC_lbl_viewAprv","ACC_lbl_viewEvid","ACC_lbl_requestType","ACC_lbl_chargeJob","ACC_lbl_company"]);			
			headerData = [
							{ key:'chk',					label:'chk',		width:'30',		align:'center',	formatter:'checkbox'
								, disabled:function(){ 
				              		if(this.item.ApplicationStatus == "T" || this.item.ApplicationStatus == "R"){
				              			return false;
				              		}else{
				              			return true;
				              		}
								}
							},
							{ key:'CompanyCode',			label:Common.getDic("ACC_lbl_company"),		width:'120',		align:'center',		//회사
								formatter: function() {
									return this.item.CompanyName;
								}
							},	
							{ key:'ApplicationTitle',		label : Common.getDic("ACC_lbl_title"),			width:'350', align:'left'
								, formatter:function () {
									var retStr = "";
									var title = "("+Common.getDic("ACC_lbl_noTitle")+")";
									
									if(!isEmptyStr(this.item.ApplicationTitle)){
										title = this.item.ApplicationTitle;
									}
									
									if(this.item.ApplicationStatus=="T"){
										retStr = "<a href='#' onClick=\"ExpenceApplicationManageUser.expAppManUser_evidWritePage('"+this.item.ExpenceApplicationID+"', '"+this.item.ApplicationType+"', '"+this.item.RequestType+"')\"><font color='blue'><u>"+title+"</u></font></a>";										
									}else{
										retStr = "<a href='#' onClick=\"ExpenceApplicationManageUser.expAppManUser_viewEvidPopup('"+this.item.ExpenceApplicationID+"', '"+this.item.ProcessID+"')\"><font color='blue'><u>"+title+"</u></font></a>";
									}
									return retStr;
								}
							},
							{ key:'RegisterName',			label : Common.getDic("ACC_lbl_aprvWriter"),		width:'150', align:'center',
								formatter:function () {
									// 프리젠트 (FlowerName)
								 	var RegisterName = "<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+this.item.RegisterID+"\" data-user-mail>" + this.item.RegisterName + "</div>";
		                		  	return RegisterName;
								}
							},
							{ key:'ApplicationDate',		label : Common.getDic("ACC_lbl_aprvDate")+Common.getSession("UR_TimeZoneDisplay"),			width:'150', align:'center',
								formatter:function(){
									return CFN_TransLocalTime(this.item.ApplicationDate,_ServerDateSimpleFormat);
								}, dataType:'DateTime'							
							},
							{ key:'ApplicationStatusName',	label : Common.getDic("ACC_lbl_processStatus"),	width:'120', align:'center'},
							{ key:'RequestTypeName',		label : Common.getDic("ACC_lbl_requestType"),		width:'150', align:'center'},	//신청유형
							{ 
								key:'TotalAmountSum',			
								label : Common.getDic("ACC_lbl_eviTotalAmt"),
								width:'100', 
								align:'right',
								formatter: function() {
									return toAmtFormat(Number(AmttoNumFormat(this.item.TotalAmountSum)));
								}
							},
							{ 
								key:'AmountSum',
								label : Common.getDic("ACC_billReqAmt"),
								width:'100',
								align:'right',
								formatter: function() {
									return toAmtFormat(Number(AmttoNumFormat(this.item.AmountSum)));
								}
							},
							{ key:'DocCnt',					label : Common.getDic("ACC_lbl_viewAprv"),			width:'150', align:'center'
								, formatter:function () {
									var str = "";
									var processID = nullToBlank(this.item.ProcessID);
									if(processID != "") {
										if(this.item.ApplicationStatus=="D"
											||this.item.ApplicationStatus=="P"
											||this.item.ApplicationStatus=="DC"
											||this.item.ApplicationStatus=="E"
											||this.item.ApplicationStatus=="R"
											||this.item.ApplicationStatus=="CD"
											||this.item.ApplicationStatus=="CP"
											||this.item.ApplicationStatus=="CE"
											||this.item.ApplicationStatus=="CR"){
											str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="ExpenceApplicationManageUser.expAppManUser_LinkOpen(\''
												+this.item.ApplicationStatus+'\', \''+processID+'\')">'
												+Common.getDic("ACC_lbl_viewAprv")+'</a>';
										}
									}
									return str;
								}
								, sort: false
							},
						]
					break;
		case "douzone":
			//개별호출-일괄호출
			Common.getDicList(["NumberFieldType_Year","NumberFieldType_Month","NumberFieldType_Day","ACC_lbl_BuyAutType","ACC_lbl_taxCode","ACC_lbl_deductReason",
			                   "ACC_lbl_cardVendorCode","ACC_lbl_cardCompanyName","ACC_lbl_cardFranchiseNo","ACC_lbl_vendorName","ACC_lbl_CorpRegNo",
			                   "ACC_lbl_supplyValue","ACC_lbl_taxType","ACC_lbl_itemName","ACC_lbl_isTaxInvoice","ACC_lbl_defaultAccountCode",
			                   "ACC_lbl_contraAccountCode","ACC_lbl_cashBillConfirmNo"]);				
			headerData = [
							{ key:'ProofYear',			label : Common.getDic("NumberFieldType_Year"),			width:'70', align:'left'},
							{ key:'ProofMonth',			label : Common.getDic("NumberFieldType_Month"),		width:'70', align:'center'},
							{ key:'ProofDay',			label : Common.getDic("NumberFieldType_Day"),			width:'70', align:'center'},
							{ key:'BuyAutType',			label : Common.getDic("ACC_lbl_BuyAutType"),			width:'70', align:'center'},
							{ key:'ProofTaxType',		label : Common.getDic("ACC_lbl_taxCode"),				width:'70', align:'center'},
							{ key:'DeductReason',		label : Common.getDic("ACC_lbl_deductReason"),			width:'70', align:'center'},
							{ key:'DouzoneCardID',		label : Common.getDic("ACC_lbl_cardVendorCode"),		width:'70', align:'right'},
							{ key:'CardCompany',		label : Common.getDic("ACC_lbl_cardCompanyName"),		width:'70', align:'center'},
							{ key:'CardNo',				label : Common.getDic("ACC_lbl_cardFranchiseNo"),		width:'70', align:'center'},
							{ key:'StoreName',				label : "가맹점명",		width:'70', align:'center'},
							{ key:'StoreRegNo',				label : "가맹점사업자번호",		width:'70', align:'center'},
							{ key:'VendorName',			label : Common.getDic("ACC_lbl_vendorName"),			width:'70', align:'center'},
							{ key:'CorpRegNum',			label : Common.getDic("ACC_lbl_CorpRegNo"),			width:'70', align:'center'},
							{ key:'SupplyCost',			label : Common.getDic("ACC_lbl_supplyValue"),			width:'70', align:'center'},
							{ key:'Tax',				label : Common.getDic("ACC_lbl_taxType"),				width:'70', align:'center'},
							{ key:'ItemName',			label : Common.getDic("ACC_lbl_itemName"),				width:'70', align:'center'},
							{ key:'IsTaxInvoice',		label : Common.getDic("ACC_lbl_isTaxInvoice"),			width:'70', align:'center'},
							{ key:'AccountCode',		label : Common.getDic("ACC_lbl_defaultAccountCode"),	width:'70', align:'center'},
							{ key:'ContraAccountCode',	label : Common.getDic("ACC_lbl_contraAccountCode"),	width:'70', align:'center'},
							{ key:'NTSConfirmNum',		label : Common.getDic("ACC_lbl_cashBillConfirmNo"),	width:'70', align:'center'},
						]
					break;
		case "CardReceiptExcel":
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_dept","ACC_lbl_aprvWriter","ACC_lbl_title","ACC_lbl_aprvDate","ACC_lbl_cardNumber","ACC_lbl_confirmNum",
								"ACC_lbl_approveDate","ACC_lbl_approveTime","ACC_lbl_amountWon","ACC_billReqAmt","ACC_lbl_franchiseCorpName",
				                "ACC_lbl_vendorSector","ACC_lbl_account","ACC_standardBrief","ACC_lbl_useHistory2"]);					
			headerData = [
							{ key:'CompanyCode',			label:Common.getDic("ACC_lbl_company"),		width:'120',		align:'center',		//회사
								formatter: function() {
									return this.item.CompanyName;
								}
							},
							{ key:'DeptName',				label : Common.getDic("ACC_lbl_dept"),					width:'100', align:'center'},
							{ key:'DisplayName',			label : Common.getDic("ACC_lbl_aprvWriter"),			width:'50', align:'center'},
							{ key:'ApplicationType',		label : Common.getDic("ACC_lbl_requestType"),			width:'150', align:'center'},
							{ key:'ApplicationTitle',		label : Common.getDic("ACC_lbl_title"),					width:'150', align:'center'},
							{ key:'ApplicationDate',		label : Common.getDic("ACC_lbl_aprvDate"),				width:'70', align:'center'},
							{ key:'CardNo',					label : Common.getDic("ACC_lbl_cardNumber"),			width:'100', align:'center'},
							{ key:'ApproveNo',				label : Common.getDic("ACC_lbl_confirmNum"),			width:'70', align:'center'},
							{ key:'ApproveDate',			label : Common.getDic("ACC_lbl_approveDate"),			width:'100', align:'center'},
							{ key:'ApproveTime',			label : Common.getDic("ACC_lbl_approveTime"),			width:'70', align:'center'},
							{ key:'PayDate',				label : Common.getDic("ACC_lbl_payDay"),				width:'70', align:'center'},
							{ key:'VendorName',				label : Common.getDic("ACC_lbl_vendorName"),			width:'70', align:'center'},
							{ key:'TaxAmount',				label : Common.getDic("ACC_lbl_taxValue"),				width:'70', align:'center'},
							{ key:'ApproveAmount',			label : Common.getDic("ACC_lbl_amountWon"),				width:'70', align:'right'},
							{ key:'Amount',					label : Common.getDic("ACC_billReqAmt"),				width:'70', align:'right'},
							{ key:'DocNo',					label : Common.getDic("ACC_lbl_docNo"),					width:'70', align:'right'},
							{ key:'StoreName',				label : Common.getDic("ACC_lbl_franchiseCorpName"),		width:'100', align:'center'},
							{ key:'StoreCategory',			label : Common.getDic("ACC_lbl_vendorSector"),			width:'70', align:'center'},
							{ key:'AccountName',			label : Common.getDic("ACC_lbl_account"),				width:'100', align:'center'},
							{ key:'StandardBriefName',		label : Common.getDic("ACC_standardBrief"),				width:'100', align:'center'},
							{ key:'UsageComment',			label : Common.getDic("ACC_lbl_useHistory2"),			width:'200', align:'left'},
						]
					break;
		case "TaxInvoiceExcel":
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_dept","ACC_lbl_aprvWriter","ACC_lbl_title","ACC_lbl_aprvDate","ACC_lbl_confirmNum","ACC_lbl_writeDate",
			                   "ACC_lbl_invoiceCorpName","ACC_lbl_invoiceCorpNum","ACC_lbl_contactName","ACC_lbl_invoiceEmail",
			                   "lbl_Remark","ACC_lbl_supplyValue","ACC_lbl_taxValue","ACC_lbl_totalAmount","ACC_billReqAmt",
			                   "ACC_lbl_account","ACC_standardBrief","ACC_lbl_useHistory2"]);				
			headerData = [
							{ key:'DeptName',				label : Common.getDic("ACC_lbl_dept"),				width:'100', align:'center'},
							{ key:'DisplayName',			label : Common.getDic("ACC_lbl_aprvWriter"),		width:'50', align:'center'},
							{ key:'ApplicationTitle',		label : Common.getDic("ACC_lbl_title"),			width:'150', align:'center'},
							{ key:'ApplicationDate',		label : Common.getDic("ACC_lbl_aprvDate"),			width:'70', align:'center'},
							{ key:'NTSConfirmNum',			label : Common.getDic("ACC_lbl_confirmNum"),		width:'100', align:'center'},
							{ key:'WriteDate',				label : Common.getDic("ACC_lbl_writeDate"),		width:'70', align:'center'},
							{ key:'InvoicerCorpName',		label : Common.getDic("ACC_lbl_invoiceCorpName"),	width:'150', align:'center'},
							{ key:'InvoicerCorpNum',		label : Common.getDic("ACC_lbl_invoiceCorpNum"),	width:'150', align:'center'},
							{ key:'InvoicerContactName',	label : Common.getDic("ACC_lbl_contactName"),		width:'150', align:'center'},
							{ key:'InvoiceeEmail1',			label : Common.getDic("ACC_lbl_invoiceEmail"),		width:'150', align:'center'},
							{ key:'Remark',					label : Common.getDic("lbl_Remark"),				width:'100', align:'center'},
							{ key:'SupplyCostTotal',		label : Common.getDic("ACC_lbl_supplyValue"),		width:'70', align:'right'},
							{ key:'TaxTotal',				label : Common.getDic("ACC_lbl_taxValue"),			width:'70', align:'right'},
							{ key:'TotalAmount',			label : Common.getDic("ACC_lbl_totalAmount"),		width:'70', align:'right'},
							{ key:'Amount',					label : Common.getDic("ACC_billReqAmt"),			width:'70', align:'right'},
							{ key:'AccountName',			label : Common.getDic("ACC_lbl_account"),			width:'100', align:'center'},
							{ key:'StandardBriefName',		label : Common.getDic("ACC_standardBrief"),		width:'100', align:'center'},
							{ key:'UsageComment',			label : Common.getDic("ACC_lbl_useHistory2"),		width:'200', align:'left'},
						]
					break;
		case "userMonthAcc" :
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_costCenter","lbl_User","lbl_sum"]);
			
			expAppCommon.searchMonthlyAccountHeaderData();
			
			headerData = [
							{ key:'GroupName',	label : Common.getDic("ACC_lbl_costCenter"),	width:'150', align:'center'},
							{ key:'UserName',	label : Common.getDic("lbl_User"),		width:'100', align:'center'},
						];
			
			headerData = headerData.concat(expAppCommon.pivotHeaderData);
			
			headerData.push({ key:'TotalSum',	label : Common.getDic("lbl_sum"),		width:'100', align:'right', formatter:"money"});
			
			break;
		case "userMonthSB" :
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_costCenter","lbl_User","lbl_sum"]);
			
			expAppCommon.searchMonthlyStandardBriefHeaderData();
			
			headerData = [
							{ key:'GroupName',	label : Common.getDic("ACC_lbl_costCenter"),	width:'150', align:'center'},
							{ key:'UserName',	label : Common.getDic("lbl_User"),		width:'100', align:'center'},
						];
			
			headerData = headerData.concat(expAppCommon.pivotHeaderData);
			
			headerData.push({ key:'TotalSum',	label : Common.getDic("lbl_sum"),		width:'100', align:'right', formatter:"money"});
			
			break;
		case "deptMonthAcc" :
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_costCenter","lbl_User","lbl_sum"]);
			
			expAppCommon.searchMonthlyAccountHeaderData();
			
			headerData = [
							{ key:'GroupName',	label : Common.getDic("ACC_lbl_costCenter"),	width:'150', align:'center'},
						];
			
			headerData = headerData.concat(expAppCommon.pivotHeaderData);
			
			headerData.push({ key:'TotalSum',	label : Common.getDic("lbl_sum"),		width:'100', align:'right', formatter:"money"});
			
			break;
			
		case "deptMonthSB" :
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_costCenter","lbl_User","lbl_sum"]);
			
			expAppCommon.searchMonthlyStandardBriefHeaderData();
			
			headerData = [
							{ key:'GroupName',	label : Common.getDic("ACC_lbl_costCenter"),	width:'150', align:'center'},
						];
			
			headerData = headerData.concat(expAppCommon.pivotHeaderData);
			
			headerData.push({ key:'TotalSum',	label : Common.getDic("lbl_sum"),		width:'100', align:'right', formatter:"money"});
			
			break;
		case "capital":
			Common.getDicList(["ACC_lbl_title","ACC_lbl_aprvWriter","ACC_lbl_requestType","ACC_btn_capitalSpending","ACC_lbl_realPayDate","ACC_lbl_evidType",
								"ACC_lbl_vendorName","ACC_lbl_eviTotalAmt","ACC_billReqAmt","ACC_lbl_addFile","ACC_lbl_realPayAmount","ACC_lbl_viewEvid","ACC_lbl_company"]);
			headerData = [
					{ key:'chk',						label : 'chk',											width:'30', align:'center',	formatter:'checkbox'},
					{ key:'CompanyName',				label : Common.getDic("ACC_lbl_company"),				width:'120',		align:'center'},		//회사	
					{ key:'ApplicationTitle',			label : Common.getDic("ACC_lbl_title"),				width:'200', align:'left'
						, formatter:function () {
							var retStr = "<a href='#' onClick=\"CapitalSpendingStatus.cptSped_viewExpAppPopup('"+this.item.ExpenceApplicationID+"', '"+this.item.ProcessID+"', '"+this.item.FormInstID+"')\">"
											+"<font color='blue'><u>"+this.item.ApplicationTitle+"</u></font></a>";
							return retStr;
						}
					},
					{ key:'RegisterName',				label : Common.getDic("ACC_lbl_aprvWriter"),			width:'100', align:'center'},	//기안자
					{ key:'RequestTypeName',			label : Common.getDic("ACC_lbl_requestType"),			width:'150', align:'center'},	//신청유형
					{ key:'CapitalStatusName',			label : Common.getDic("ACC_lbl_processStatus"),			width:'100', align:'center'		//처리상태
						, formatter:function () {
							var retStr = "";
							if(this.item.CapitalProcessID != undefined && this.item.CapitalProcessID != "" && this.item.CapitalStatus != "W") {
								retStr = "<a href='#' onClick=\"CapitalSpendingStatus.cptSped_openCapitalSpendingDoc('"+this.item.CapitalProcessID+"', '"+this.item.CapitalStatus+"', '"+this.item.CapitalFormInstID+"')\">"
												+"<font color='blue'><u>"+this.item.CapitalStatusName+"</u></font></a>";
							} else { //대기 상태 or 완료 상태이나 자금지출 보고된 건
								retStr = this.item.CapitalStatusName;
							}
							return retStr;
						}
					},	
					{ key:'RealPayDate',				label : Common.getDic("ACC_lbl_realPayDate"),			width:'100', align:'center'},	//자금집행일
					{ key:'ProofCodeName',				label : Common.getDic("ACC_lbl_evidType"),				width:'100', align:'center'},	//증빙유형
					{ key:'VendorName',					label : Common.getDic("ACC_lbl_vendorName"),			width:'150', align:'center'},	//거래처명
					{ key:'TotalAmount',				label : Common.getDic("ACC_lbl_eviTotalAmt"),			width:'100', align:'right' 		//증빙총액
						, formatter:function () {
							return toAmtFormat(this.item.TotalAmount);
						}
					},	
					{ key:'AmountSum',					label : Common.getDic("ACC_billReqAmt"),				width:'100', align:'right'		//청구금액
						, formatter:function () {
							return toAmtFormat(this.item.AmountSum);
						}
					},	
					{ key:'RealPayAmount',				label : Common.getDic("ACC_lbl_realPayAmount"),		width:'100', align:'right'		//실지급금액
						, formatter:function () {
							return toAmtFormat(this.item.RealPayAmount);
						}
					},	
					{ key:'FileCnt',					label : Common.getDic("ACC_lbl_addFile"),				width:'100', align:'center'		//첨부파일
						, formatter:function () {
							var str = "";
							if(this.item.FileCnt > 0){
								str= '<div class="bodyNode bodyTdText" align="center" id="AXGridTarget_AX_bodyText_AX_0_AX_2_AX_0" title="">'
									+'<span class="tblIcAttFile" onClick="CapitalSpendingStatus.cptSped_ViewFile(\''+this.item.ExpenceApplicationListID+'\')"></span>'
									+'</div>'
							}
							return str;
						}
						, sort: false
					},
					{ key:'DocCnt',						label : Common.getDic("ACC_lbl_viewEvid"),				width:'100', align:'center'
						, formatter:function () {
							var str = "";
							if(this.item.ProofCode=="CorpCard"){
								str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="CapitalSpendingStatus.cptSped_viewEvidListItem(\''
									+this.item.ProofCode+'\', \''+nullToBlank(this.item.CardUID)+'\')">'
									+Common.getDic("ACC_lbl_viewEvid")+'</a>';
							}
							else if(this.item.ProofCode=="TaxBill"){
								str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="CapitalSpendingStatus.cptSped_viewEvidListItem(\''
									+this.item.ProofCode+'\', \''+nullToBlank(this.item.TaxUID)+'\')">'
									+Common.getDic("ACC_lbl_viewEvid")+'</a>';
							}
							else if(this.item.ProofCode=="Receipt"){
								str= '<a href="#" class="btnTypeDefault btnSearchBlue01" onClick="CapitalSpendingStatus.cptSped_viewEvidListItem(\''
									+this.item.ProofCode+'\', \''+nullToBlank(this.item.ReceiptFileID)+'\')">'
									+Common.getDic("ACC_lbl_viewEvid")+'</a>';
							}
							return str 
						}
						, sort: false
					},
				]
			break;
		default:	
		}
		return headerData;
	},
	
	searchMonthlyAccountHeaderData : function() {
		var searchParam = MonthlyAccountSummarySheet.mthAccSum_getSearchParams();		
		
		expAppCommon.pivotHeaderData.clear();
		
		$.ajax({
			url:"/account/expenceApplication/searchMonthlyAccountHeaderData.do",
			data:{
				"searchParam" : JSON.stringify(searchParam)
			},
			cache: false,
			async: false,
			success:function (data) {
				if(data.result == "ok"){
					var getData = data.list;
					if(getData != null && getData.length > 0){
						var jsonHeader = {};
						for (var i = 0; i < getData.length; i++) {
							jsonHeader = { key:getData[i].AccountCode+"Sum", label:getData[i].AccountName, width:'100', align:'right', formatter:"money"}
							expAppCommon.pivotHeaderData.push(jsonHeader);
						}		
					}
				}
				else{
					Common.Error("<spring:message code='Cache.ACC_msg_error' />");
				}
			},
			error:function (error){
				Common.Error("<spring:message code='Cache.ACC_msg_error' />");
			}
		});
	},
	
	searchMonthlyStandardBriefHeaderData : function() {
		var searchParam = MonthlyStandardBriefSummarySheet.mthSBSum_getSearchParams();
		
		expAppCommon.pivotHeaderData.clear();
		
		$.ajax({
			url:"/account/expenceApplication/searchMonthlyStandardBriefHeaderData.do",
			data:{
				"searchParam" : JSON.stringify(searchParam)
			},
			cache: false,
			async: false,
			success:function (data) {
				if(data.result == "ok"){
					var getData = data.list;
					if(getData != null && getData.length > 0){
						var jsonHeader = {};
						for (var i = 0; i < getData.length; i++) {
							jsonHeader = { key:getData[i].StandardBriefID+"Sum", label:getData[i].StandardBriefName, width:'100', align:'right', formatter:"money"}
							expAppCommon.pivotHeaderData.push(jsonHeader);
						}	
					}
				}
				else{
					Common.Error("<spring:message code='Cache.ACC_msg_error' />");
				}
			},
			error:function (error){
				Common.Error("<spring:message code='Cache.ACC_msg_error' />");
			}
		});
	}
}