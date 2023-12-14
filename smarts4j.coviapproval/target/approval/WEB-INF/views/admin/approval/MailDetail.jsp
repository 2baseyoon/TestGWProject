<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/AdminInclude.jsp"></jsp:include>
<script  type="text/javascript">
	var param = location.search.substring(1).split('&');
	var mode =param[0].split('=')[1];
	var paramMailID =  param[1].split('=')[1];
	
	$(document).ready(function(){		
		modifySetData()
	});
	
	// 레이어 팝업 닫기
	function closeLayer(){
		Common.Close();
	}
	
	//수정화면 data셋팅
	function modifySetData(){
		//data 조회
		$.ajax({
			type:"POST",
			data:{
				"MailID" : paramMailID				
			},
			url:"getMailDetail.do",
			success:function (data) {
				$("#Sender").text(data.list[0].Sender);
				$("#Subject").text(data.list[0].Subject);
				$("#Recipients").text(data.list[0].Recipients);
				$("#SendYN").text(data.list[0].SendYN);
				$("#InsertDate").text(data.list[0].InsertDate);
				$("#ProcessID").text(data.list[0].ProcessID);
				$("#Body").text(data.list[0].Body);
				$("#ErrorMessage").text(data.list[0].ErrorMessage);			
			},
			error:function(response, status, error){
				CFN_ErrorAjax("getMailDetail.do", response, status, error);
			}
		});
	}
	
	
	//재전송 현재 업데이트기능만구현
	function resendSubmit(){
		var SendYN = $("#SendYN").text(); 	
		//resendMail 호출
		$.ajax({
			type:"POST",
			data:{
				"MailID" : paramMailID,
				"SendYN" : "N"					
			},
			url:"resendMail.do",
			success:function (data) {
				if(data.result == "ok"){
					Common.Inform(data.message);
					parent.searchConfig();
					closeLayer();
				}				
								
			},
			error:function(response, status, error){
				CFN_ErrorAjax("resendMail.do", response, status, error);
			}
		});
		
	}
	
	
	
</script>
<form id="DocFolderManagerSetPopup" name="DocFolderManagerSetPopup">
	<div class="pop_body1" style="width:100%;min-height: 100%">
            <table class="AXFormTable" >
                <colgroup>
                    <col id="t_tit4">
                    <col id="">
                </colgroup>
                <tbody>
                    <tr>
                        <th style="width: 85px ;">Sender</th>
                        <td id="Sender">                           
                        </td>
                    </tr>
                    <tr>
                        <th style="width: 85px ;">Subject</th>
                        <td id="Subject">                            
                        </td>
                    </tr>
                    <tr>
                        <th style="width: 85px ;">Recipients</th>
                        <td id="Recipients">                            
                        </td>
                    </tr>
                    <tr>
                        <th style="width: 85px ;">SendYN</th>
                        <td id="SendYN">                                                        
                        </td>
                    </tr>
                    <tr>
                        <th style="width: 85px ;">InsertDate</th>
                        <td id="InsertDate">                                                        
                        </td>
                    </tr>
                    <tr>
                        <th style="width: 85px ;">ProcessID</th>
                        <td id="ProcessID">                                                        
                        </td>
                    </tr>
                    <tr>
                        <th style="width: 85px ;">Body</th>
                        <td>
                        <div id="Body" style="width: 100%; height: 200px; overflow-x: hidden; overflow-y: auto;"></div>
                        </td>
                    </tr>
                    <tr>
                        <th style="width: 85px ;">ErrorMessage</th>
                        <td>
                        	<div id="ErrorMessage" style="width: 100%; height: 200px; -ms-overflow-x: hidden; -ms-overflow-y: auto;">
                        	</div>
                        </td>
                    </tr>
                </tbody>
            </table>        
                <div class="pop_btn2" align="center">
                    <br/>
                       	<input type="button" value="재발송" onclick="resendSubmit();" class="AXButton" />                           					
						<input type="button" value="닫기" onclick="closeLayer();"  class="AXButton" />                    
                </div>           
        </div>

        <input type="hidden" name="EntCode" id="EntCode" />        
        <input type="hidden" name="ParentDocClassID" id="ParentDocClassID" />
     
</form>