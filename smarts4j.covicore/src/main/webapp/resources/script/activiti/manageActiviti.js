var SERVER_PATH = "http://localhost:8081";
var processDefinitionId = "RequestProc7:1:258030";
var processDefinitionKey = "RequestProc7";
// 결재선 데이터 변경
// 입력값 : processInstanceID, approvalLine
function putApprovalLine(processInstanceID, approvalLine) {
	// process ID
	$.ajax({
		type : 'PUT',
		/*
		 * headers : { "Access-Control-Allow-Origin" : SERVER_PATH },
		 */
		dataType : 'json',
		data : JSON.stringify([ {
			"name" : "g_appvLine",
			"type" : "string",
			"value" : approvalLine
		} ]),
		async : false,
		beforeSend : function(xhr) {
			// xhr.overrideMimeType("text/plain; charset=x-user-defined");
			xhr.setRequestHeader("Authorization", "Basic "
					+ btoa("kermit:kermit"));
		},

		url : SERVER_PATH + "/activiti-rest/service/runtime/process-instances/"
				+ processInstanceID + "/variables",
		success : function(data) {
			var dataText = "";
			for (let i = 0; i < data.length; i++) {
				if (data[i].name == 'g_appvLine') {
					dataText = data[i].value;
					break;
				}
			}

			// $("#approvalLineData").text(dataText);
			// alert(dataText);
		},
		error : function(error) {
			alert(error.responseText);
		}
	});
}

// 결재선 정보 변경 - processInstanceID 값으로 해당 variables 가져온 후, 입력 받은 값으로 결재선 변경한 후,
// 결재선 데이터 업데이트
function modifyApprovalLine(processInstanceID, initiatorcode, stepsResult,
		divisiontype, taskResult, routetype, stepTaskResult, personCode,
		personTaskStatus, personTaskKind, personTaskResult) {
	$.ajax({
		type : "GET",
		/*
		 * headers : { "Access-Control-Allow-Origin" : "http://localhost" },
		 */
		dataType : 'json',
		beforeSend : function(xhr) {
			// xhr.overrideMimeType("text/plain; charset=x-user-defined");
			xhr.setRequestHeader("Authorization", "Basic "
					+ btoa("kermit:kermit"));
		},
		async : false,
		url : SERVER_PATH + "/activiti-rest/service/runtime/process-instances/"
				+ processInstanceID + "/variables",
		success : function(data) {
			var now = new Date();				//현재 시각
			now = XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss",now)
			
			var dataText = "";
			for (i = 0; i < data.length; i++) {
				// alert(data[i].name);
				// alert(data[i].value);

				if (data[i].name == 'g_appvLine') {
					dataText = data[i].value;
					break;
				}
			}

			var approvalLine = dataText;
			// var divisiontype = "send";
			var xmlDoc = $.parseXML(approvalLine);

			if (initiatorcode != '') {
				if (stepsResult != '')
					$(xmlDoc).find(
							"steps[initiatorcode='" + initiatorcode + "']")
							.attr("result", stepsResult);

				if (taskResult != '') {
					$(xmlDoc).find(
							"steps[initiatorcode='" + initiatorcode
									+ "']>division[divisiontype='"
									+ divisiontype
									+ "']>taskinfo[status='active']").attr(
							"result", taskResult);

				}

				if (routetype != '')
					$(xmlDoc).find(
							"steps[initiatorcode='" + initiatorcode
									+ "']>division[divisiontype='"
									+ divisiontype + "']>step").attr(
							"routetype", routetype);

				if (stepTaskResult != '')
					$(xmlDoc).find(
							"steps[initiatorcode='" + initiatorcode
									+ "']>division[divisiontype='"
									+ divisiontype
									+ "']>step>taskinfo[status='active']")
							.attr("result", stepTaskResult);

				//(POC에서 주로 사용되는 부분)
				if (personTaskResult != '') {

					if (personTaskResult == 'withdraw') {
						$(xmlDoc).find(
								"steps[initiatorcode='" + initiatorcode
										+ "']>division>step>ou>person>taskinfo[status='active']").attr(
								"result", personTaskResult);
						//결재 날짜 및 시간
						$(xmlDoc).find(
								"steps[initiatorcode='" + initiatorcode
										+ "']>division>step>ou>person>taskinfo[status='active']").attr(
								"datecompleted", now);
					}
					else{
						$(xmlDoc).find(
								"steps[initiatorcode='" + initiatorcode
										+ "']>division>step>ou>person[code='"
										+ personCode
										+ "']>taskinfo[status='active']").attr(
								"result", personTaskResult);
						//결재 날짜 및 시간
						$(xmlDoc).find(
								"steps[initiatorcode='" + initiatorcode
										+ "']>division>step>ou>person[code='"
										+ personCode
										+ "']>taskinfo[status='active']").attr(
								"datecompleted", now);
					}

				}

				if (personTaskKind != '' && personTaskResult != '') {
					$(xmlDoc).find(
							"steps[initiatorcode='" + initiatorcode
									+ "']>division[divisiontype='"
									+ divisiontype + "']>step>ou>person[code='"
									+ personCode + "']>taskinfo[kind='"
									+ personTaskKind + "']").attr("result",
							personTaskResult);
				}

				var xmlData = "";
				/* for IE */
				if (window.ActiveXObject) {
					xmlData = xmlDoc.xml;
				}
				// code for Mozilla, Firefox, Opera, etc.
				else {
					xmlData = (new XMLSerializer()).serializeToString(xmlDoc);
				}

				$("#approvalLineData").text(xmlData);

				// 결재선 업데이트
				putApprovalLine(processInstanceID, xmlData);
			}

		},
		error : function(error) {
			alert(error.responseJSON.exception);
		}
	});
}

// 결재자 승인취소
// 입력값: processInstanceID, initiatorcode, personCode
function cancelApproval(processInstanceID, initiatorcode) {
	modifyApprovalLine(processInstanceID, initiatorcode, '', 'send', '', '',
			'', '', '', '', 'withdraw');

	alert('승인 취소 처리되었습니다.');

	self.close();
}

// 수신함-재기안
// 입력값: processInstanceID, initiatorcode, personCode
function reDraft(processInstanceID, initiatorcode, personCode) {
	modifyApprovalLine(processInstanceID, initiatorcode, '', 'receive', '', '',
			'', personCode, '', 'charge', 'completed');

	alert('재기안 처리되었습니다.');

	self.close();
}

// 수신함-결재자 승인
// 입력값: processInstanceID, initiatorcode, personCode
function approveApproval(processInstanceID, initiatorcode, personCode) {
	modifyApprovalLine(processInstanceID, initiatorcode, '', 'receive', '', '',
			'', personCode, '', 'normal', 'completed');

	alert('승인 처리되었습니다.');

	self.close();
}

// 결재자 승인
// 입력값: processInstanceID, initiatorcode, personCode, personTaskStatus
function setApproveCompleted(processInstanceID, initiatorcode, personCode) {
	modifyApprovalLine(processInstanceID, initiatorcode, '', 'send', '', '',
			'', personCode, 'active', '', 'completed');

	alert('승인 처리되었습니다.');

	self.close();
}

// 결재자 반려
// 입력값: processInstanceID, initiatorcode, personCode, personTaskStatus
function setApproveRejected(processInstanceID, initiatorcode, personCode) {
	modifyApprovalLine(processInstanceID, initiatorcode, '', 'send', '', '',
			'', personCode, 'active', '', 'rejected');

	// 프로세스 종료 처리 - Test 위해서 놔둠.
	// deleteProcessInstance(processInstanceID);

	// alert('반려 처리되었습니다.');

	// self.close();
}

// 결재자 동의
// 입력값: processInstanceID, initiatorcode, personCode, personTaskStatus
function setApproveAgreed(processInstanceID, initiatorcode, personCode) {
	modifyApprovalLine(processInstanceID, initiatorcode, '', 'send', '', '',
			'', personCode, '', '', 'agreed');

	alert('동의 처리되었습니다.');

	self.close();
}

// 결재자 거부
// 입력값: processInstanceID, initiatorcode, personCode, personTaskStatus
function setApproveDisagreed(processInstanceID, initiatorcode, personCode) {
	modifyApprovalLine(processInstanceID, initiatorcode, '', 'send', '', '',
			'', personCode, '', '', 'disagreed');

	alert('거부 처리되었습니다.');

	self.close();
}

// 해당 프로세스 인스턴스 variables 가져오기
// 입력값: processInstanceID
function getApprovalLine(processInstanceID) {
	$.ajax({
		type : "GET",
		/*
		 * headers : { "Access-Control-Allow-Origin" : "http://localhost" },
		 */
		dataType : 'json',
		beforeSend : function(xhr) {
			// xhr.overrideMimeType("text/plain; charset=x-user-defined");
			xhr.setRequestHeader("Authorization", "Basic "
					+ btoa("kermit:kermit"));
		},
		async : false,
		url : SERVER_PATH + "/activiti-rest/service/runtime/process-instances/"
				+ processInstanceID + "/variables",
		success : function(data) {
			var dataText = "";
			for (i = 0; i < data.length; i++) {
				if (data[i].name == 'g_appvLine') {
					dataText = data[i].value;
					break;
				}
			}
			// alert(dataText);
			$("#approvalLineData").text(dataText);
		},
		error : function(error) {
			alert(error.responseJSON.exception);
		}
	});
}

// 프로세스 인스턴스 정보 가져오기
function getProcessInstance() {
	$.ajax({
		type : "GET",
		/*
		 * headers : { "Access-Control-Allow-Origin" : SERVER_PATH },
		 */
		dataType : 'json',
		beforeSend : function(xhr) {
			// xhr.overrideMimeType("text/plain; charset=x-user-defined");
			xhr.setRequestHeader("Authorization", "Basic "
					+ btoa("kermit:kermit"));
		},
		async : false,
		url : SERVER_PATH + "/activiti-rest/service/runtime/process-instances",
		success : function(data) {
			for (i = 0; i < data.data.length; i++) {
				alert(data.data[i].id);
			}
		},
		error : function(error) {
			alert(error.responseJSON.exception);
		}
	});
}

// 프로세스 시작
// 입력값 : processDefinitionId, approvalLine, formData, initiator
function startProcessInstance(processDefinitionId, approvalLine, formData,
		initiator) {
	approvalLine = approvalLine != "" ? approvalLine : null;
	$.ajax({
		type : "POST",
		/*
		 * headers : { "Access-Control-Allow-Origin" : SERVER_PATH },
		 */
		contentType : "application/json", // send as JSON -
		// application/x-www-form-urlencoded;
		// charset=utf-8 오류 발생시 추가
		dataType : 'json',
		beforeSend : function(xhr) {
			// xhr.overrideMimeType("text/plain; charset=x-user-defined");
			xhr.setRequestHeader("Authorization", "Basic "
					+ btoa("kermit:kermit"));
		},
		data : JSON.stringify({
			"processDefinitionId" : processDefinitionId,
			"businessKey" : "RequestProcess",
			"variables" : [ {
				"name" : "g_context",
				// "scope":"global", // global 이라 명시해도 local로 바뀜.
				"value" : formData
			}, {
				"name" : "g_appvLine",
				"value" : approvalLine
			}, {
				"name" : "duedate",
				"value" : new Date().toISOString().substring(0, 10)
			}, {
				"name" : "initiator",
				"value" : initiator
			},
			/*
			 * { "name":"approver", "value":initiator },
			 */
			{
				"name" : "g_isCancelled",
				"value" : false
			}, {
				"name" : "difficulty",
				"value" : 50
			} ]
		}),
		async : false,
		url : SERVER_PATH + "/activiti-rest/service/runtime/process-instances",
		success : function(data) {

			alert("ID: " + data.id + "\r\n" + "Url: " + data.url + "\r\n"
					+ "BusinessKey: " + data.businessKey + "\r\n"
					+ "Suspended: " + data.suspended + "\r\n" + "Ended: "
					+ data.ended + "\r\n" + "ProcessDefinitionId: "
					+ data.processDefinitionId + "\r\n"
					+ "ProcessDefinitionUrl: " + data.processDefinitionUrl
					+ "\r\n" + "ActivityId: " + data.activityId + "\r\n"
					+ "Variables: " + data.variables + "\r\n" + "TenantId: "
					+ data.tenantId + "\r\n" + "Completed: " + data.completed);

			alert('기안 처리되었습니다.');

			self.close();
		},
		error : function(error) {
			alert(error.responseJSON.exception);
		}
	});
}

// 태스크 완료
// 입력값 : taskID
function taskComplete(taskID) {
	// taskID = 215730;
	$.ajax({
		type : "POST",
		/*
		 * headers : { "Access-Control-Allow-Origin" : SERVER_PATH },
		 */
		contentType : "application/json", // send as JSON -
		// application/x-www-form-urlencoded;
		// charset=utf-8 오류 발생시 추가
		dataType : 'json',
		beforeSend : function(xhr) {
			// xhr.overrideMimeType("text/plain; charset=x-user-defined");
			xhr.setRequestHeader("Authorization", "Basic "
					+ btoa("kermit:kermit"));
		},
		data : JSON.stringify({
			"action" : "complete",
			"variables" : []
		}),
		async : false,
		url : SERVER_PATH + "/activiti-rest/service/runtime/tasks/" + taskID,
		success : function(data) {
			alert('태스크 완료 처리되었습니다.');
		},
		error : function(error) {
			// alert(error.responseText);
		}
	});
}

// 프로세스 삭제
// 입력값 : processInstanceID
function deleteProcessInstance(processInstanceID) {
	// processInstanceID = 100001;
	$.ajax({
		type : "DELETE",
		/*
		 * headers : { "Access-Control-Allow-Origin" : SERVER_PATH },
		 */
		contentType : "application/json",
		dataType : 'json',
		beforeSend : function(xhr) {
			xhr.setRequestHeader("Authorization", "Basic "
					+ btoa("kermit:kermit"));
		},
		async : false,
		url : SERVER_PATH + "/activiti-rest/service/runtime/process-instances/"
				+ processInstanceID,
		success : function(data) {
			// alert(data.action);
			alert('프로세스 삭제 처리되었습니다.');

			self.close();
		},
		error : function(error) {
			alert(error.responseText);
		}
	});
}

// 기안 취소
// 입력값 : processInstanceID
function putIsCancelled(processInstanceID) {
	// processInstanceID = 235037;

	$.ajax({
		type : 'PUT',
		/*
		 * headers : { "Access-Control-Allow-Origin" : SERVER_PATH },
		 */
		dataType : 'json',
		data : JSON.stringify([ {
			"name" : "g_isCancelled",
			"value" : true
		} ]),
		beforeSend : function(xhr) {
			xhr.setRequestHeader("Authorization", "Basic "
					+ btoa("kermit:kermit"));
		},
		async : false,
		url : SERVER_PATH + "/activiti-rest/service/runtime/process-instances/"
				+ processInstanceID + "/variables",
		success : function(data) {
			var dataText = "";
			for (i = 0; i < data.length; i++) {
				if (data[i].name == 'g_isCancelled') {
					dataText = data[i].value;
					break;
				}
			}

			// $("#approvalLineData").text(dataText);
			//alert(dataText);

			deleteProcessInstance(processInstanceID);

			alert('기안 취소 처리되었습니다.');

			self.close();
		},
		error : function(error) {
			alert(error.responseText);
		}
	});
}

// 부서내 취소(반송)
// 입력값 : processInstanceID
function putIsCancelledInReceive(processInstanceID) {
	// processInstanceID = 235037;

	$.ajax({
		type : 'PUT',
		/*
		 * headers : { "Access-Control-Allow-Origin" : SERVER_PATH },
		 */
		dataType : 'json',
		data : JSON.stringify([ {
			"name" : "g_isCancelledInReceive",
			"value" : true
		} ]),
		beforeSend : function(xhr) {
			xhr.setRequestHeader("Authorization", "Basic "
					+ btoa("kermit:kermit"));
		},
		async : false,
		url : SERVER_PATH + "/activiti-rest/service/runtime/process-instances/"
				+ processInstanceID + "/variables",
		success : function(data) {
			var dataText = "";
			for (i = 0; i < data.length; i++) {
				if (data[i].name == 'g_isCancelledInReceive') {
					dataText = data[i].value;
					break;
				}
			}

			// $("#approvalLineData").text(dataText);
			//alert(dataText);

			alert('부서내 반송 처리 되었습니다.');

			self.close();
		},
		error : function(error) {
			alert(error.responseText);
		}
	});
}

// processInstanceID 관련 task 완료 처리
// 입력값 : processInstanceID
function setTaskComplete(processInstanceID) {
	$.ajax({
		type : "GET",
		/* headers: {"Access-Control-Allow-Origin": SERVER_PATH}, */
		dataType : 'json',
		beforeSend : function(xhr) {
			xhr.setRequestHeader("Authorization", "Basic "
					+ btoa("kermit:kermit"));
		},
		async : false,
		url : SERVER_PATH
				+ "/activiti-rest/service/runtime/tasks?processInstanceId="
				+ processInstanceID,
		success : function(response) {
			for (i = 0; i < response.data.length; i++) {
				alert(response.data[i].id);

				taskComplete(response.data[i].id);
			}
		},
		error : function(error) {
			alert(error.message);
		}
	});
}
