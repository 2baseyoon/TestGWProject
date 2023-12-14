	//그룹 수정 
	function modifyGroup(pShareType, pGroupID){

		//window.location.reload(true);
		//개별호출-일괄호출
		Common.getDicList(["lbl_group","lbl_Modify"]);
		
		var url = "/groupware/bizcard/ModifyBizCardGroup.do";
		var sTitle = coviDic.dicMap["lbl_group"] + " " + coviDic.dicMap["lbl_Modify"]; /*그룹 수정*/
		Common.open("", "CreateBizCardGroupPop", sTitle, url + "?sharetype=" + pShareType + "&groupid=" + pGroupID, "450px", "240px", "iframe", true, null, null, true);
		
		return;
	}
	
	//그룹 수정 
	function modifyGroupPop(pShareType, pGroupID){

		//window.location.reload(true);
		//개별호출-일괄호출
		Common.getDicList(["lbl_group","lbl_Modify"]);
		
		var url = "/groupware/bizcard/ModifyBizCardGroupPop.do";
		var sTitle = coviDic.dicMap["lbl_group"] + " " + coviDic.dicMap["lbl_Modify"]; /*그룹 수정*/
		Common.open("", "CreateBizCardGroupPop", sTitle, url + "?sharetype=" + pShareType + "&groupid=" + pGroupID, "750px", "480px", "iframe", true, null, null, true);
		
		return;
	}
	
	//그룹 연락처 조회 
	function searchBizCardGroupPersonListPop(pShareType, pGroupID, pGroupName){
		var popupId = "BizCardGroupPersonListPop";
		
		Common.getDicList(["lbl_group","lbl_Views"]);
		
		var url = "/groupware/bizcard/getBizCardGroupPersonListPop.do";
		var sTitle = coviDic.dicMap["lbl_group"] + " " + coviDic.dicMap["lbl_Views"]; /*그룹 조회*/
		Common.open("", popupId, sTitle, url + "?ShareType=" + pShareType + "&GroupID=" + pGroupID + "&GroupName=" + encodeURIComponent(pGroupName) + "&PopupId=" + popupId,
				"550px", "480px", "iframe", true, null, null, true);
		
		return;
	}
	
	/**
	 * 이동, 복사
	 */
	function AdjustCheck(target, pMode){
	
		var checkCheckList 		= target.getCheckedList(0);// 체크된 리스트 객체
		var BizCardIDTemp 		= []; //체크된 항목 저장용 배열
		var BizCardID 				= ""; //체크된 항목을 문장으로 나열 (A;B; . . ;)
		var Mode 			= "";
		var GroupCnt = 0;
		var sTitle = "";
		
		//개별호출-일괄호출
		Common.getDicList(["msg_apv_003","lbl_BizCard","lbl_Copy","lbl_Move","msg_BizGroupNotMove","msg_ScriptApprovalError"]);
		
		if(checkCheckList.length == 0){
			Common.Inform(Common.getDic("msg_apv_003"), Common.getDic("CPMail_info_msg")); // 선택된 항목이 없습니다.
		}else if(checkCheckList.length > 0){
			
			for(var i = 0; i < checkCheckList.length; i++){
				BizCardIDTemp.push(checkCheckList[i].BizCardID);
				if(checkCheckList[i].BizCardType == "Group"){
					GroupCnt++;
				}
			}
			if(GroupCnt == 0){
				BizCardID = BizCardIDTemp.join(",");
				Mode = pMode;
			
				if(Mode == "C"){
					sTitle = coviDic.dicMap["lbl_BizCard"] + " " + coviDic.dicMap["lbl_Copy"]; /*명함 복사*/
				}else{
					sTitle = coviDic.dicMap["lbl_BizCard"] + " " + coviDic.dicMap["lbl_Move"]; /*명함 이동*/
				}
				Common.open("", "AdjustBizCardLocation",  sTitle, "/groupware/bizcard/AdjustBizCardLocation.do" + "?mode=" + Mode + "&bizcardid=" + BizCardID , "450px", "240px", "iframe", true, null, null, true);
			}else{
				Common.Inform(Common.getDic("msg_BizGroupNotMove"), Common.getDic("CPMail_info_msg")); // 연락처 그룹은 이동,복사 할 수 없습니다.
			}
		}else{
			Common.Warning(Common.getDic("msg_ScriptApprovalError")); // 오류 발생
		}
	}
	
	/**
	 * 명함 수정 페이지 개별 복사
	 */
	function BizCardCopy(pMode, pBizCardID){		
		var sTitle = Common.getDic("lbl_BizCard") + " " + Common.getDic("lbl_Copy"); /*명함 복사*/
				
		Common.open("", "AdjustBizCardLocation",  sTitle, "/groupware/bizcard/AdjustBizCardLocation.do" + "?mode=" + pMode + "&bizcardid=" + pBizCardID , "450px", "240px", "iframe", true, null, null, true);
	}
	
    /**
	 * 삭제
	 * param : 그리드 객체, 타입(P/D/U/C), 모드(Person/Group)
	 */
	function BizCardDeleteCheck(gridObj, pTypeCode, pMode){
		
		var checkCheckList 		= gridObj.getCheckedList(0);// 체크된 리스트 객체
		var BizCardIDTemp 		= []; //체크된 항목 저장용 배열
		var BizCardID 			= ""; //체크된 항목을 문장으로 나열 (A;B; . . ;)
		var BizCardTypeTemp		= []; //체크된 항목 저장용 배열
		var BizCardTypeCode 	= "";

		//개별호출-일괄호출
		Common.getDicList(["msg_apv_003","msg_apv_093","msg_ScriptApprovalError"]);
		
		if(checkCheckList.length == 0){
			Common.Inform(Common.getDic("msg_apv_003"), Common.getDic("CPMail_info_msg")); // 선택된 항목이 없습니다.
		}else if(checkCheckList.length > 0){
			if(pMode == 'Person'){
				for(var i = 0; i < checkCheckList.length; i++){
					BizCardIDTemp.push(checkCheckList[i].BizCardID);
					BizCardTypeTemp.push(checkCheckList[i].BizCardType);
				}
				BizCardID = BizCardIDTemp.join(",");
				BizCardTypeCode = BizCardTypeTemp.join(",");
				var TypeCode = pTypeCode;

				Common.Confirm(coviDic.dicMap["msg_apv_093"], "Inform", function (result) {
					if (result) {
						$.ajax({
							url: "/groupware/bizcard/deleteBizCardAllList.do" ,
							type:"post",
							data:{
				 				"BizCardID":BizCardID,
				 				"TypeCode":TypeCode,
				 				"BizCardTypeCode":BizCardTypeCode
								},
							async:false,
							success:function (res) {
									gridObj.reloadList();
									//closeLayer();
							},
							error:function(response, status, error){
								CFN_ErrorAjax("/groupware/bizcard/deleteBizCardAllList.do", response, status, error);
							}
						});
					}
				});	
			} else{ //Group
				for(var j = 0; j < checkCheckList.length; j++){
					BizCardIDTemp.push(checkCheckList[j].GroupID);
				}
				BizCardID = BizCardIDTemp.join(",");
				TypeCode = pTypeCode;
				
				Common.Confirm(coviDic.dicMap["msg_apv_093"], "Inform", function (result) {
					if (result) {
						$.ajax({
							url: "/groupware/bizcard/deleteBizCardGroupList.do",
							type:"post",
							data:{
				 				"BizCardID":BizCardID,
				 				"TypeCode":TypeCode
								},
							async:false,
							success:function (res) {
									gridObj.reloadList();
									//closeLayer();
							},
							error:function(response, status, error){
								CFN_ErrorAjax("/groupware/bizcard/deleteBizCardGroupList.do", response, status, error);
							}
						});
					}
				});
			}
			
		}else{
			Common.Warning(Common.getDic("msg_ScriptApprovalError")); // 오류 발생
		}
	}
	
	function DeleteCheck(gridObj, pTypeCode, pMode){
		
		var checkCheckList 		= gridObj.getCheckedList(0);// 체크된 리스트 객체
		var BizCardIDTemp 		= []; //체크된 항목 저장용 배열
		var BizCardID 				= ""; //체크된 항목을 문장으로 나열 (A;B; . . ;)
		var TypeCode 			= "";

		//개별호출-일괄호출
		Common.getDicList(["msg_apv_003","msg_apv_093","msg_ScriptApprovalError"]);
		
		if(checkCheckList.length == 0){
			Common.Inform(Common.getDic("msg_apv_003"), Common.getDic("CPMail_info_msg")); // 선택된 항목이 없습니다.
		}else if(checkCheckList.length > 0){
			
			if(pMode == 'Person'){
				for(var i = 0; i < checkCheckList.length; i++){
					BizCardIDTemp.push(checkCheckList[i].BizCardID);
				}
			} else{ //Group
				for(var j = 0; j < checkCheckList.length; j++){
					BizCardIDTemp.push(checkCheckList[j].GroupID);
				}
			}
			
			BizCardID = BizCardIDTemp.join(",");
			TypeCode = pTypeCode;
			
			Common.Confirm(coviDic.dicMap["msg_apv_093"], "Inform", function (result) {
				if (result) {
					$.ajax({
						url: (pMode == "Person" ? "/groupware/bizcard/deleteBizCardList.do" : "/groupware/bizcard/deleteBizCardGroupList.do"),
						type:"post",
						data:{
			 				"BizCardID":BizCardID,
			 				"TypeCode":TypeCode
							},
						async:false,
						success:function (res) {
								gridObj.reloadList();
								//closeLayer();
						},
						error:function(response, status, error){
							CFN_ErrorAjax((pMode == "Person" ? "/groupware/bizcard/deleteBizCardList.do" : "/groupware/bizcard/deleteBizCardGroupList.do"), response, status, error);
						}
					});
				}
			});
		}else{
			Common.Warning(Common.getDic("msg_ScriptApprovalError")); // 오류 발생
		}
	}

	/**
	 * 즐겨찾기 ctrl
	 */
	function ChangeFavoriteStatus(pBizID, pObj){
		
		var BizCardID = pBizID;
		var StatusToBe = '';
		if($(pObj).find("a").hasClass('active')) StatusToBe = "N";
		else StatusToBe = "Y";

		$.ajax({
			url:"/groupware/bizcard/changeFavoriteStatus.do",
			type:"post",
			data:{
 				"BizCardID":BizCardID,
 				"StatusToBe":StatusToBe
				},
			async:false,
			success:function (res) {
				if(StatusToBe == "Y") $(pObj).find("a").addClass("active");
				else $(pObj).find("a").removeClass("active");
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/bizcard/changeFavoriteStatus.do", response, status, error);
			}
		});
		
	}
	
	//Grid Header 항목 시작
	function getGridHeader( pHeaderType ){
		var headerData;
		
		//개별호출-일괄호출
		Common.getDicList(["lbl_name","lbl_MobilePhone","lbl_Email2","lbl_Company","lbl_CompanyPhone","lbl_JobTitle","lbl_Division"
		                   ,"lbl_ShareType_Personal","lbl_ShareType_Dept","lbl_ShareType_Comp",
		                   "lbl_CompanyName","lbl_RepName","lbl_Email2","lbl_Phone","lbl_HomeAddress","lbl_MobilePhone","lbl_Company","lbl_CompanyPhone"
		                   ,"lbl_JobTitle"]);
		
		switch( pHeaderType ){
			case "P":
				headerData = [
						  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
						  {key:'IsFavorite',hideFilter : 'Y', colHeadTool:false, label:'<a class=\"tblBtnFavorite\" href=\"#\">Favorite</a>', width:'20', align:'center', sort:false, formatter : function() {
		                 	  var IsFavorite = "<span style='color:black;' onclick='ChangeFavoriteStatus(" + this.item.BizCardID + ",this)'>";
		                	  if(this.item.IsFavorite == "Y") {
		                		  IsFavorite += "<a class=\"tblBtnFavorite active\" href=\"#\">Favorite</a>";
		                	  }else{
		                		  IsFavorite += "<a class=\"tblBtnFavorite\" href=\"#\">Favorite</a>";
		                	  }
		                	  IsFavorite += "</span>"; 
		                	  return IsFavorite;
		                  }},
		                  {key:'Name',  label:coviDic.dicMap["lbl_name"], width:'200', align:'center',  //이름
		                	  formatter:function () {
		      					return "<a href='#' onclick='viewBizCardPop(\""+ this.item.BizCardID +"\"); return false;'>"+this.item.Name+"</a>";
		      				}},
		                  {key:'PhoneNum',  label:coviDic.dicMap["lbl_MobilePhone"], width:'100', align:'center', formatter : function() { //핸드폰
		                		var PhoneNum = this.item.PhoneNum;
		                		if(PhoneNum.indexOf(";") > -1)
		                			PhoneNum = PhoneNum.substr(0,PhoneNum.indexOf(";"));
		                		return PhoneNum;
		                  }},
		                  {key:'EMAIL', label:coviDic.dicMap["lbl_Email2"], width:'70', align:'center', formatter : function() { //이메일
		                		var EMAIL = this.item.EMAIL;
		                		if(EMAIL.indexOf(";") > -1)
		                			EMAIL = EMAIL.substr(0,EMAIL.indexOf(";"));
		                		return EMAIL;
		                  }},
		                  {key:'ComName',  label:coviDic.dicMap["lbl_Company"], width:'70', align:'center'}, //회사
		                  {key:'ComPhoneNum',  label:coviDic.dicMap["lbl_CompanyPhone"], width:'70', align:'center', formatter : function() { //회사 전화
		                		var ComPhoneNum = this.item.ComPhoneNum;
		                		if(ComPhoneNum.indexOf(";") > -1)
		                			ComPhoneNum = ComPhoneNum.substr(0,ComPhoneNum.indexOf(";"));
		                		return ComPhoneNum;
		                  }},
		                  {key:'JobTitle', label:coviDic.dicMap["lbl_JobTitle"], width:'70', align:'center'}, //직책
		                  {key:'ShareType',  label:coviDic.dicMap["lbl_Division"], width:'70', align:'center', formatter : function() { //구분
		                	  var shareType = "";
		                	  switch(this.item.ShareType) {
		                	  case 'P' : shareType = coviDic.dicMap["lbl_ShareType_Personal"]; break; //개인
		                	  case 'D' : shareType = coviDic.dicMap["lbl_ShareType_Dept"]; break; //부서
		                	  case 'U' : shareType = coviDic.dicMap["lbl_ShareType_Comp"]; break; //회사
		                	  }
		                	  return shareType;
	                	  }}
		               ];
				break;
			case "C":
				headerData = [
				                {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
					            {key:'ComName',  label:coviDic.dicMap["lbl_CompanyName"], width:'70', align:'center'}, //회사명
					            {key:'ComRepName',  label:coviDic.dicMap["lbl_RepName"], width:'50', align:'center'}, //대표자명
					            {key:'EMAIL', label:coviDic.dicMap["lbl_Email2"], width:'70', align:'center', formatter : function() { //이메일
					          		var EMAIL = this.item.EMAIL;
					          		if(EMAIL.indexOf(";") > -1)
					          			EMAIL = EMAIL.substr(0,EMAIL.indexOf(";"));
					          		return EMAIL;
					            }},
					            {key:'PhoneNum',  label:coviDic.dicMap["lbl_Phone"], width:'70', align:'center', formatter : function() { //전화
					          		var PhoneNum = this.item.PhoneNum;
					          		
					          		if(PhoneNum.indexOf(";") > -1)
					          			PhoneNum = PhoneNum.substr(0,PhoneNum.indexOf(";"));
					          		return PhoneNum;
					            }},
					            {key:'ComAddress', label:coviDic.dicMap["lbl_HomeAddress"], width:'100', align:'center', formatter : function() { //주소
					          		var ComAddress = this.item.ComAddress;
					
					          		if(ComAddress.length > 25)
					          			ComAddress = ComAddress.substr(0,25) + "...";
					          		return ComAddress;
					            }}
					    ];
				break;
			case "F":
				headerData = [
							  {key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
							  {key:'Name',  label:coviDic.dicMap["lbl_name"], width:'200', align:'center', //이름
			                	  formatter:function () {
			      					return "<a href='#' onclick='viewBizCardPop(\""+ this.item.BizCardID +"\"); return false;'>"+this.item.Name+"</a>";
			      				}},
			                  {key:'PhoneNum',  label:coviDic.dicMap["lbl_MobilePhone"], width:'100', align:'center', formatter : function() { //핸드폰
			                		var PhoneNum = this.item.PhoneNum;
			                		if(PhoneNum.indexOf(";") > -1)
			                			PhoneNum = PhoneNum.substr(0,PhoneNum.indexOf(";"));
			                		return PhoneNum;
			                  }},
			                  {key:'EMAIL', label:coviDic.dicMap["lbl_Email2"], width:'70', align:'center', formatter : function() { //이메일
			                		var EMAIL = this.item.EMAIL;
			                		if(EMAIL.indexOf(";") > -1)
			                			EMAIL = EMAIL.substr(0,EMAIL.indexOf(";"));
			                		return EMAIL;
			                  }},
			                  {key:'ComName',  label:coviDic.dicMap["lbl_Company"], width:'70', align:'center'}, //회사
			                  {key:'ComPhoneNum',  label:coviDic.dicMap["lbl_CompanyPhone"], width:'70', align:'center', formatter : function() { //회사 전화
			                		var ComPhoneNum = this.item.ComPhoneNum;
			                		if(ComPhoneNum.indexOf(";") > -1)
			                			ComPhoneNum = ComPhoneNum.substr(0,ComPhoneNum.indexOf(";"));
			                		return ComPhoneNum;
			                  }},
			                  {key:'JobTitle', label:coviDic.dicMap["lbl_JobTitle"], width:'70', align:'center'}, //직책
			                  {key:'ShareType',  label:coviDic.dicMap["lbl_Division"], width:'70', align:'center', formatter : function() { //구분
			                	  var shareType = "";
			                	  switch(this.item.ShareType) {
			                	  case 'P' : shareType = coviDic.dicMap["lbl_ShareType_Personal"]; break; //개인
			                	  case 'D' : shareType = coviDic.dicMap["lbl_ShareType_Dept"]; break; //부서
			                	  case 'U' : shareType = coviDic.dicMap["lbl_ShareType_Comp"]; break; //회사
			                	  }
			                	  return shareType;
		                	  }}
				      		];
				break;
		}
		return headerData;
	}
	
	/**
	 * 개별 연락처 내보내기
	 */
	var eachExportImportExport = function(gridObj) {
		var checkCheckList = gridObj.getCheckedList(0); // 체크된 리스트 객체
		if(checkCheckList.length < 1) {
			Common.Warning(Common.getDic("msg_apv_003")); //선택된 항목이 없습니다.
			return false;
			//CoviMenu_GetContent("/groupware/bizcard/moveToExportFileBizCard.do?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard&BizCardID=");
		}else{
			var tempBizCardIDs = "";
			var tempBizGroupIDs =  "";

			for (var i = 0; i < checkCheckList.length; i++) {
				if(checkCheckList[i].BizCardType == "BizCard") {
					tempBizCardIDs += checkCheckList[i].BizCardID + ";";
				} else if(checkCheckList[i].BizCardType == "Group") {
					if(checkCheckList[i].BizCardID == null && checkCheckList[i].GroupID) {
						tempBizGroupIDs += checkCheckList[i].GroupID + ";";
					} else {
						tempBizGroupIDs += checkCheckList[i].BizCardID + ";";
					}
					
				}
			}
			CoviMenu_GetContent("/groupware/bizcard/moveToExportFileBizCard.do?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard&BizCardID=" + encodeURIComponent(tempBizCardIDs.slice(0, -1)) + "&BizGroupID=" + encodeURIComponent(tempBizGroupIDs.slice(0, -1)));
		}
		console.dir(event);
		// 이벤트 기본동작 방지
		event.preventDefault ? event.preventDefault() : (event.returnValue = false);	
		// 버블링 방지
		event.stopPropagation ? event.stopPropagation() : (event.cancelBubble = true);	
		
		return false;
	}
		
	
	/**
	 * 우편번호 검색 ctrl
	 */
	var searchZipCode = function(obj) {
		new daum.Postcode({
	        oncomplete: function (data) {
	            // 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

	            // 도로명 주소의 노출 규칙에 따라 주소를 조합한다.
	            // 내려오는 변수가 값이 없는 경우엔 공백('')값을 가지므로, 이를 참고하여 분기 한다.
	            var fullRoadAddr = data.roadAddress; // 도로명 주소 변수
	            var extraRoadAddr = ''; // 도로명 조합형 주소 변수

	            // 법정동명이 있을 경우 추가한다. (법정리는 제외)
	            // 법정동의 경우 마지막 문자가 "동/로/가"로 끝난다.
	            if (data.bname !== '' && /[동|로|가]$/g.test(data.bname)) {
	                extraRoadAddr += data.bname;
	            }
	            // 건물명이 있고, 공동주택일 경우 추가한다.
	            if (data.buildingName !== '' && data.apartment === 'Y') {
	                extraRoadAddr += (extraRoadAddr !== '' ? ', ' + data.buildingName : data.buildingName);
	            }
	            // 도로명, 지번 조합형 주소가 있을 경우, 괄호까지 추가한 최종 문자열을 만든다.
	            if (extraRoadAddr !== '') {
	                extraRoadAddr = ' (' + extraRoadAddr + ')';
	            }
	            // 도로명, 지번 주소의 유무에 따라 해당 조합형 주소를 추가한다.
	            if (fullRoadAddr !== '') {
	                fullRoadAddr += extraRoadAddr;
	            }

	            // 우편번호와 주소 정보를 해당 필드에 넣는다.
	            $("#txtComZipCode").val(data.zonecode);
	            $("#txtComAddress").val(fullRoadAddr);


	            // 사용자가 '선택 안함'을 클릭한 경우, 예상 주소라는 표시를 해준다.
	            //if (data.autoRoadAddress) {
	            //    //예상되는 도로명 주소에 조합형 주소를 추가한다.
	            //    var expRoadAddr = data.autoRoadAddress + extraRoadAddr;
	            //    document.getElementById('guide').innerHTML = '(예상 도로명 주소 : ' + expRoadAddr + ')';

	            //} else if (data.autoJibunAddress) {
	            //    var expJibunAddr = data.autoJibunAddress;
	            //    document.getElementById('guide').innerHTML = '(예상 지번 주소 : ' + expJibunAddr + ')';

	            //} else {
	            //    document.getElementById('guide').innerHTML = '';
	            //}
	        }
	    }).open();
	}
				
	 /*doButtonCase['btPrint'] = function (oBtn, oVar) {//인쇄
		    if (oVar.elmComment.length == 0) {
		        try { document.getElementById("CommentList").style.display = "none"; } catch (e) { }
		    } 
		    m_CmtBln = false;
		    bPresenceView = false;
		    __displayApvList(oVar.m_evalJSON);
		    printDiv = "<html><body>" + getBodyHTML() + "</body></html>";
		    if (!_ie) {
		        oVar.iWidth = 1000; oVar.iHeight = 700;
		    } else {
		        oVar.iWidth = 100; oVar.iHeight = 100;
		    }

		    //차기 제품 하드코딩 start- hichang
		    gPrintType = "0";
		    //차기 제품 하드코딩 end- hichang

		    if (gPrintType == "0") {
		        oVar.sUrl = "form/Print.do";
		    } else if (gPrintType == "1") {
		        m_oFormReader.print_part('editor');
		    }
		    m_CmtBln = true;
		    bPresenceView = true;
		    __displayApvList(oVar.m_evalJSON);
		}			*/
				