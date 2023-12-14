
var baseCodeCommon = {
	//Grid Header 항목 시작
	getGridHeader: function( pHeaderType ){
		var headerData;
		switch( pHeaderType ){

		case "CC":
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_companyCode","ACC_lbl_companyName","ACC_lbl_isUse","ACC_lbl_syncDate","ACC_lbl_modifyDate","ACC_lbl_company"]);

			headerData = [
							{	key:'CompanyCode',	label:Common.getDic("ACC_lbl_company"),			width:'70',		align:'center',		//회사
								formatter: function() {
									return this.item.CompanyName;
								}
							},
			    			{ key:'Code',			label:Common.getDic("ACC_lbl_companyCode"),		width:'70', align:'center',		//회사코드
						    	formatter:function () {
				            		 return "<a onclick='BaseCodeViewCC.onCodeClick(" + this.item.BaseCodeID + "); return false;'><font color='blue'><u>"+this.item.Code+"</u></font></a>";
				            	}
			    			},							
							{ key:'CodeName',  		label:Common.getDic("ACC_lbl_companyName"), 	width:'110', align:'center'},	//회사명
							{ key:'IsUse',  		label:Common.getDic("ACC_lbl_isUse"), 			width:'40', align:'center'},	//사용여부
							{ key:'RegistDate', 	label:Common.getDic("ACC_lbl_syncDate")+Common.getSession("UR_TimeZoneDisplay"), 		width:'110', align:'center',
								formatter:function(){
									return CFN_TransLocalTime(this.item.RegistDate,_ServerDateFullFormat );
								}, dataType:'DateTime'
							},	//동기화일시
							{ key:'ModifyDate', 	label:Common.getDic("ACC_lbl_modifyDate")+Common.getSession("UR_TimeZoneDisplay"), 		width:'110', align:'center',
								formatter:function(){
									return CFN_TransLocalTime(this.item.ModifyDate,_ServerDateFullFormat );
								}, dataType:'DateTime'						
							}	//수정일자
	        ];
			break;
		case "PT":
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_PayTypeCode","ACC_lbl_PayTypeName","ACC_lbl_isUse","ACC_lbl_syncDate","ACC_lbl_modifyDate","ACC_lbl_company"]);
			headerData = [
							{	key:'CompanyCode',	label:Common.getDic("ACC_lbl_company"),		width:'70',		align:'center',		//회사
								formatter: function() {
									return this.item.CompanyName;
								}
							},
			    			{ key:'Code',			label:Common.getDic("ACC_lbl_PayTypeCode"),			width:'70', align:'center',	//지급조건코드
						    	formatter:function () {
				            		 return "<a onclick='BaseCodeViewPT.onCodeClick(" + this.item.BaseCodeID + "); return false;'><font color='blue'><u>"+this.item.Code+"</u></font></a>";
				            	}
			    			},
							{ key:'CodeName',  		label:Common.getDic("ACC_lbl_PayTypeName"), 	width:'110', align:'center'},	//지급조건명
							{ key:'IsUse',  		label:Common.getDic("ACC_lbl_isUse"), 			width:'40', align:'center'},	
							{ key:'RegistDate', 	label:Common.getDic("ACC_lbl_syncDate")+Common.getSession("UR_TimeZoneDisplay"), 		width:'110', align:'center',
								formatter:function(){
									return CFN_TransLocalTime(this.item.RegistDate,_ServerDateFullFormat );
								}, dataType:'DateTime'								
							},
							{ key:'ModifyDate', 	label:Common.getDic("ACC_lbl_modifyDate")+Common.getSession("UR_TimeZoneDisplay"), 		width:'110', align:'center',
								formatter:function(){
									return CFN_TransLocalTime(this.item.ModifyDate,_ServerDateFullFormat );
								}, dataType:'DateTime'								
							}
			];
			break;
		case "PM":
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_payMethodCode","ACC_lbl_pay","ACC_lbl_isUse","ACC_lbl_syncDate","ACC_lbl_modifyDate","ACC_lbl_company"]);
			headerData = [
							{	key:'CompanyCode',	label:Common.getDic("ACC_lbl_company"),		width:'70',		align:'center',		//회사
								formatter: function() {
									return this.item.CompanyName;
								}
							},
							{ key:'Code',			label:Common.getDic("ACC_lbl_payMethodCode"),	width:'70', align:'center',
						    	formatter:function () {
				            		 return "<a onclick='BaseCodeViewPM.onCodeClick(" + this.item.BaseCodeID + "); return false;'><font color='blue'><u>"+this.item.Code+"</u></font></a>";
				            	}
			    			},							
							{ key:'CodeName',  		label:Common.getDic("ACC_lbl_pay"), 	width:'110', align:'center'},
							{ key:'IsUse',  		label:Common.getDic("ACC_lbl_isUse"), 			width:'40', align:'center'},
							{ key:'RegistDate', 	label:Common.getDic("ACC_lbl_syncDate")+Common.getSession("UR_TimeZoneDisplay"), 		width:'110', align:'center',
								formatter:function(){
									return CFN_TransLocalTime(this.item.RegistDate,_ServerDateFullFormat );
								}, dataType:'DateTime'								
							},
							{ key:'ModifyDate', 	label:Common.getDic("ACC_lbl_modifyDate")+Common.getSession("UR_TimeZoneDisplay"), 		width:'110', align:'center',
								formatter:function(){
									return CFN_TransLocalTime(this.item.ModifyDate,_ServerDateFullFormat );
								}, dataType:'DateTime'								
							}
			];
			break;
		case "TC":
			//개별호출-일괄호출
			Common.getDicList(["ACC_lbl_tax","ACC_lbl_taxName","ACC_lbl_isUse","ACC_lbl_syncDate","ACC_lbl_modifyDate","ACC_lbl_company"]);
			headerData = [
							{	key:'CompanyCode',	label:Common.getDic("ACC_lbl_company"),		width:'70',		align:'center',		//회사
								formatter: function() {
									return this.item.CompanyName;
								}
							},
							{ key:'Code',			label:Common.getDic("ACC_lbl_tax"),			width:'70', align:'center',	//세금코드
						    	formatter:function () {
				            		 return "<a onclick='BaseCodeViewTC.onCodeClick(" + this.item.BaseCodeID + "); return false;'><font color='blue'><u>"+this.item.Code+"</u></font></a>";
				            	}
			    			},
							{ key:'CodeName',  		label:Common.getDic("ACC_lbl_taxName"), 		width:'110', align:'center'},	//세금코드명
							{ key:'IsUse',  		label:Common.getDic("ACC_lbl_isUse"), 			width:'40' , align:'center'},		
							{ key:'RegistDate', 	label:Common.getDic("ACC_lbl_syncDate")+Common.getSession("UR_TimeZoneDisplay"), 		width:'110', align:'center',
								formatter:function(){
									return CFN_TransLocalTime(this.item.RegistDate,_ServerDateFullFormat );
								}, dataType:'DateTime'								
							},
							{ key:'ModifyDate', 	label:Common.getDic("ACC_lbl_modifyDate")+Common.getSession("UR_TimeZoneDisplay"), 		width:'110', align:'center',
								formatter:function(){
									return CFN_TransLocalTime(this.item.ModifyDate,_ServerDateFullFormat );
								}, dataType:'DateTime'								
							}
				];
				break;
				/*
				회사코드 - CompanyCd 	- CC
				지급조건 - PayType		- PT
				지급방법 - PayMethod 	- PM
				세금코드 - TaxCode		- TC
				 */
		case "OP":
			Common.getDicList(["ACC_lbl_company","lbl_apv_date2","ACC_lbl_amt","ACC_lbl_isUse","ACC_lbl_syncDate","ACC_lbl_modifyDate"]);
			headerData = [
	              {	
	            	  key:'CompanyCode',	
	            	  label:Common.getDic("ACC_lbl_company"),		
	            	  width:'70',		
	            	  align:'center',
	            	  formatter: function() {
	            		  return this.item.CompanyName;
	            	  }
	              },
	              { 
	            	  key:'Code',			
	            	  label:Common.getDic("lbl_apv_date2"),			
	            	  width:'70', 
	            	  align:'center',
	            	  formatter:function(){
	            		  return CFN_TransLocalTime(this.item.Code,_ServerDateSimpleFormat);
	            	  },
	            	  dataType:'DateTime'
	              },
	              { 
	            	  key:'Reserved1',  
	            	  label:Common.getDic("ACC_lbl_amt"), 		
	            	  width:'70',
	            	  align:'center'
	              },
	              { 
	            	  key:'IsUse',  		
	            	  label:Common.getDic("ACC_lbl_isUse"), 	
	            	  width:'40', 
	            	  align:'center'
	              },		
	              { 
	            	  key:'RegistDate', 	
	            	  label:Common.getDic("ACC_lbl_syncDate") + Common.getSession("UR_TimeZoneDisplay"), 
	            	  width:'110',
	            	  align:'center',
	            	  formatter:function(){
	            		  return CFN_TransLocalTime(this.item.RegistDate,_ServerDateFullFormat);
	            	  }, 
	            	  dataType:'DateTime'								
	              },
	              {
	            	  key:'ModifyDate', 
	            	  label:Common.getDic("ACC_lbl_modifyDate") + Common.getSession("UR_TimeZoneDisplay"),
	            	  width:'110', 
	            	  align:'center',
	            	  formatter:function(){
	            		  return CFN_TransLocalTime(this.item.ModifyDate,_ServerDateFullFormat );
	            	  }, 
	            	  dataType:'DateTime'								
	              }
			];
			break;
			
			default:	
		}
		return headerData;
	},
	getBaceCodeGrp: function( pType ){
		var GroupCode;
		switch( pType ){
			case "CC":
				GroupCode = "CompanyCode";
				break;
			case "PT":
				GroupCode = "PayType";
				break;
			case "PM":
				GroupCode = "PayMethod";
				break;
			case "TC":
				GroupCode = "TaxCode";
				break;
			case "OP":
				GroupCode = "Opinet"
				break;
			default:
		}
		return GroupCode;
	},

	getBaseCodeTitle : function( pType ){
		//개별호출-일괄호출
		Common.getDicList(["ACC_lbl_companyCodeManagement","ACC_lbl_payTypeManagement","ACC_lbl_payMethodManagement","ACC_lbl_taxCodeManagement"]);
		
		var pageTitle;
		switch( pType ){
			case "CC":
				pageTitle = Common.getDic("ACC_lbl_companyCodeManagement");	//회사코드관리
				break;
			case "PT":
				pageTitle = Common.getDic("ACC_lbl_payTypeManagement");	//지급조건관리
				break;
			case "PM":
				pageTitle = Common.getDic("ACC_lbl_payMethodManagement");	//지급방법관리
				break;
			case "TC":
				pageTitle = Common.getDic("ACC_lbl_taxCodeManagement");	//세금코드관리
				break;
			case "OP":
				pageTitle = Common.getDic("ACC_lbl_OpinetManagement");	// 국내유가관리
				break;
			default:	
		}
		return pageTitle;
	},

	getLabelObj: function( pType ){
		//개별호출-일괄호출
		Common.getDicList(["ACC_lbl_company","ACC_lbl_companyCode","ACC_lbl_companyName","ACC_lbl_isUse","ACC_lbl_syncDate","ACC_lbl_modifyDate"
		                   ,"ACC_lbl_PayTypeCode","ACC_lbl_PayTypeName","ACC_lbl_payMethodCode","ACC_lbl_pay","ACC_lbl_tax","ACC_lbl_taxName","ACC_lbl_surtaxType"]);
		
		var LabelObject;
		switch( pType ){
			case "CompanyCode":
				LabelObject = {
					Company 	: Common.getDic("ACC_lbl_company"),
					Code 		: Common.getDic("ACC_lbl_companyCode"),
					CodeName 	: Common.getDic("ACC_lbl_companyName"),
					IsUse 		: Common.getDic("ACC_lbl_isUse"),
					RegistDate 	: Common.getDic("ACC_lbl_syncDate"),
					ModifyDate 	: Common.getDic("ACC_lbl_modifyDate"),
				};
					
				break;
			case "PayType":
				LabelObject = {
					Company 	: Common.getDic("ACC_lbl_company"),
					Code 		: Common.getDic("ACC_lbl_PayTypeCode"),
					CodeName 	: Common.getDic("ACC_lbl_PayTypeName"),
					IsUse 		: Common.getDic("ACC_lbl_isUse"),
					RegistDate 	: Common.getDic("ACC_lbl_syncDate"),
					ModifyDate 	: Common.getDic("ACC_lbl_modifyDate"),
				};
				break;
			case "PayMethod":
				LabelObject = {
					Company 	: Common.getDic("ACC_lbl_company"),
					Code 		: Common.getDic("ACC_lbl_payMethodCode"),
					CodeName 	: Common.getDic("ACC_lbl_pay"),
					IsUse 		: Common.getDic("ACC_lbl_isUse"),
					RegistDate 	: Common.getDic("ACC_lbl_syncDate"),
					ModifyDate 	: Common.getDic("ACC_lbl_modifyDate"),
				};
				break;
			case "TaxCode":
				LabelObject = {
					Company 	: Common.getDic("ACC_lbl_company"),
					Code 		: Common.getDic("ACC_lbl_tax"),
					CodeName 	: Common.getDic("ACC_lbl_taxName"),
					Reserved1 	: Common.getDic("ACC_lbl_surtaxType"),
					IsUse 		: Common.getDic("ACC_lbl_isUse"),
					RegistDate 	: Common.getDic("ACC_lbl_syncDate"),
					ModifyDate 	: Common.getDic("ACC_lbl_modifyDate"),
				};
				break;
			case "Opinet":
				LabelObject = {
					Company 	: Common.getDic("ACC_lbl_company"),
					Code 		: Common.getDic("lbl_apv_date2"),
					CodeName 	: Common.getDic("lbl_apv_date2"),
					Reserved1 	: Common.getDic("ACC_lbl_amt"),
					IsUse 		: Common.getDic("ACC_lbl_isUse"),
					RegistDate 	: Common.getDic("ACC_lbl_syncDate"),
					ModifyDate 	: Common.getDic("ACC_lbl_modifyDate"),
				};
				break;
			default:	
		}
		return LabelObject;
	}

	
}