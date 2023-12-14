/**
 * employeesNotice - 임직원 소식
 */

var employeesNoticeCount = 0;
var employeesNoticePage = 1;
var employeesNoticeTotalPage = 1;

var employeesNotice ={
		config: {
			webpartType: '', 
			strSelMode : 'ALL',			//검색조건
			strJobMode : 'level',		//표시기준 level: 직급, position : 직위, title : 직급
			strBirthMode : 'D',			//생일기준 M: 월, D: 날짜
			strEnterInterval : 14,		//신규입사에 포함되는 입사일자 기준
			strVacationMode : 'N',		//휴가 포함여부
			straddinterval : 0,			//휴가 표시 일수
			noticeCount : 5,			//포탈 한페이지에 보이는 임직원 소식 개수
			profilePath : Common.getBaseConfig("ProfileImagePath").replace("{0}", Common.getSession("DN_Code")),
			employeesOption : Common.getBaseConfig('Employees_WebpartDisplayOption')
		},
		init: function (data, ext, caller){
			var ext = (typeof ext == 'object') ? ext : {};
			this.caller = caller;
			this.config = $.extend(this.config, ext);
			
			employeesNotice.initNoticeType();
			
			var $this = this;
			strSelMode = ext.strSelMode;
			straddinterval = ext.Addinterval;
			strJobMode = ext.JobMode;
			strBirthMode = ext.BirthMode;
			strEnterInterval = ext.EnterInterval;
			strVacationMode = ext.VacationMode;
			strPortalType = ext.strPortalType;		
			noticeCount = ext.noticeCount;	
			
			$("#boardURL").attr("href",ext.boardURL);

			employeesNotice.getList("0");
			
			//타입 검색
			$("#selMode").on('change',function(){
				strSelMode = $(this).val();
				employeesNotice.getList("0");
			});
			
			//상하분할형 스크롤
			if(this.config.webpartType == 'ptype01'){
				$.mCustomScrollbar.defaults.scrollButtons.enable=true; //enable scrolling buttons by default
		        $(".ptype01_wp_height").mCustomScrollbar({
					mouseWheelPixels: 50,scrollInertia: 350,scrollInertia:0
				});
			}
			
		},	
		getClassKind: function(eventObj){
			var oType = new Object();
			
			switch(eventObj.Type){
				case 'Birth': //생일
					oType["Class"] ="birthday";
					oType["Name"] = "<spring:message code='Cache.lbl_Birthday'/>";
					break;
				case 'Enter'://신규 입사
					oType["Class"] ="newJoin";
					oType["Name"] = "<spring:message code='Cache.lbl_New_Recruit'/>";
					break;
				case 'VACATION_ANNUAL'://휴가
					oType["Class"] ="newJoin";
					oType["Name"] = "<spring:message code='Cache.lbl_Vacation'/>";
					break;
				case 'VACATION_OFF'://반차
					oType["Class"] ="newJoin";
					if(eventObj.offFlag == "PM"){//오후 반차
						oType["Name"] = "<spring:message code='Cache.lbl_PM'/>" +" "+ "<spring:message code='Cache.VACATION_OFF'/>";
					}else{//오전 반차
						oType["Name"] = "<spring:message code='Cache.lbl_AM'/>" +" "+ "<spring:message code='Cache.VACATION_OFF'/>";
					}
					break;
				case 'VACATION_CONGRATULATIONS'://경조사
					oType["Class"] ="newJoin";
					oType["Name"] = "<spring:message code='Cache.VACATION_CONGRATULATIONS'/>";
					break;
				case 'VACATION_SICK_LEAVE'://병가
					oType["Class"] ="newJoin";
					oType["Name"] = "<spring:message code='Cache.VACATION_SICK_LEAVE'/>";
					break;
				case 'VACATION_BEFOREANNUAL'://선연차
					oType["Class"] ="newJoin";
					oType["Name"] = "<spring:message code='Cache.VACATION_BEFOREANNUAL'/>";
					break;
				case 'VACATION_BEFOREOFF'://선반차
					oType["Class"] ="newJoin";
					if(eventObj.offFlag == "PM"){//오후 선반차
						oType["Name"] = "<spring:message code='Cache.lbl_PM'/>" +" "+ "<spring:message code='Cache.VACATION_BEFOREOFF'/>";
					}else{//오전 선반차
						oType["Name"] = "<spring:message code='Cache.lbl_AM'/>" +" "+ "<spring:message code='Cache.VACATION_BEFOREOFF'/>";
					}
					break;
				case 'VACATION_OTHER'://기타
					oType["Class"] ="newJoin";
					oType["Name"] = "<spring:message code='Cache.VACATION_OTHER'/>";
					break;
				default:
					var $codeData = $$(Common.getBaseCode("VACATION_TYPE")).find('CacheData[Code='+eventObj.Type+']');
					var $eventCodeData = $$(Common.getBaseCode("eventType")).find('CacheData[Code='+eventObj.Type+']');
					
					if ($codeData.length > 0){
						oType["Class"] = "newJoin";
						if(eventObj.offFlag == "PM"){ //오후 반차
							oType["Name"] = "<spring:message code='Cache.lbl_PM'/>" +" "+ CFN_GetDicInfo($codeData.attr('MultiCodeName'));
						}else if(eventObj.offFlag == "AM"){//오전 반차
							oType["Name"] = "<spring:message code='Cache.lbl_AM'/>" +" "+ CFN_GetDicInfo($codeData.attr('MultiCodeName'));
						}else{
							oType["Name"] = CFN_GetDicInfo($codeData.attr('MultiCodeName'));
						}
					}else if($eventCodeData.length > 0){
						if($eventCodeData.attr("Code") != "condolence" && $eventCodeData.attr("Code") != ""){
							oType["Class"] = $eventCodeData.attr("Code");
						}else{
							oType["Class"] = "newJoin";
						}
						oType["Name"] = CFN_GetDicInfo($eventCodeData.attr("MultiCodeName"));
					}else {
						oType["Class"] ="";
						oType["Name"] ="";
					}

					break;
			}
			
			return oType;
		},
		getList: function(strPage){			
			if(strPage == "-"){
				if(employeesNoticePage == 1) {
					return;
				}
				else {
					employeesNoticePage--;
					strPage = ((employeesNoticePage-1) * 5).toString();		
				}
			}else if (strPage == "+"){
				if(employeesNoticePage == employeesNoticeTotalPage) {
					return;
				}
				else {
					employeesNoticePage++;
					strPage = ((employeesNoticePage-1) * 5).toString();		
				}
			}else{
				employeesNoticePage = 1;
			}
			$('.staffNewsBtnTx').html('<strong>'+employeesNoticePage+'</strong>/'+employeesNoticeTotalPage);
			
			$.ajax({
				type:"POST",
				url:"/groupware/portal/getEmployeesNoticeList.do",
				data: {'page' : strPage,
					   'selMode': strSelMode,
					   'addinterval' : straddinterval,
					   'birthMode' : strBirthMode,
					   'enterInterval' : strEnterInterval, 
					   'noticeCount' : noticeCount,
					   'callerId' : 'webpart'
				},
				success:function(data) {
					//수행할 업무
					$("#employeesNotice_list").html("");
					employeesNoticeCount = data.employeesList.Count;
					
					if (employeesNoticeCount > 0)  {
						employeesNoticeTotalPage = parseInt(employeesNoticeCount / 5) ;
						if(employeesNoticeCount % 5  > 0) employeesNoticeTotalPage++;
					}else {
						employeesNoticePage = 1, employeesNoticeTotalPage = 1;
					}
					$('.staffNewsBtnTx').html('<strong>'+employeesNoticePage+'</strong>/'+employeesNoticeTotalPage);
					
					$.each( data.employeesList.list, function(index, obj) {
						var classObj = employeesNotice.getClassKind(obj);
						var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
						var strJob = obj.JobLevelName;
				        if(sRepJobTypeConfig == "PN"){
				        	strJob = obj.JobPositionName;
				        } else if(sRepJobTypeConfig == "TN"){
				        	strJob = obj.JobTitleName;
				        } else if(sRepJobTypeConfig == "LN"){
				        	strJob = obj.JobLevelName;
				        }
						
						if (strJobMode == "position") strJob = obj.JobPositionName;
						else if (strJobMode == "title") strJob = obj.JobTitleName;
						$("#employeesNotice_list").append(
							$("#templateEmployeesNoticeCard").html()
								.replace('{NoticekindClassName}', classObj.Class)
								.replace(/{UserCode}/gi, obj.UserCode)		
								.replace(/{MailAddress}/gi, obj.MailAddress)	
								.replace('{Name}', classObj.Name)	
								.replace('{profileImagePath}', coviCmn.loadImage(employeesNotice.config.profilePath + this.UserCode + '.jpg'))	
								.replace('{UserNameJob}', obj.UserName + ' ' +  strJob)	
								.replace('{Date}', obj.Date)	
								.replace('{Date_type2}', obj.Date.replaceAll('-', '.'))	
						);
					});
					if (data.employeesList.list.length < 1){
						$("#employeesNotice_NoDataList").css("display","");
						$("#employeesNotice_list").css("display","none");
					}else{
						$("#employeesNotice_NoDataList").css("display","none");
					}
				}
			});			
		},
		goMoreList: function(){			
			var sTitle = Common.getDic("lbl_Employees") +" "+ Common.getDic("lbl_news");
			var sURL = "/groupware/portal/goEmployeesNoticeListPopup.do?"
					+ 'addinterval=' + straddinterval
					 +  '&birthMode=' + strBirthMode
					 +  '&enterInterval=' + strEnterInterval
					 +  '&jobMode=' + strJobMode
					 + '&vacationMode=' + strVacationMode;
			
			Common.open("","EmployeesList",	sTitle,sURL.replace("{0}", Common.getBaseConfig("WebpartEmp")),"865px","700px","iframe",true,null,null,true);
		},
		initNoticeType: function(){
			var noticeType = Common.getBaseCode('EmployeesNotice');
			var lang = Common.getSession('lang');
			
			var empNotice = noticeType.CacheData;

			$.each(noticeType.CacheData, function(empidx, el){
				var option = el.Code
				if(employeesNotice.config.employeesOption.includes(option)){
					$("#selMode").append('<option value="'+el.Code+'">' + CFN_GetDicInfo(this.MultiCodeName, lang) + '</option>');
				}
			});
		}
}

