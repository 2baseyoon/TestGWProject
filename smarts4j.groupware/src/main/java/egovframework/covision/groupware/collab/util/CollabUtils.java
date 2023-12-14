package egovframework.covision.groupware.collab.util;


import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.MessageHelper;
import egovframework.baseframework.util.SessionHelper;

import java.util.List;
import java.util.HashMap;

import egovframework.covision.groupware.collab.user.service.CollabTaskSvc;
import egovframework.covision.groupware.collab.user.service.CollabProjectSvc;

import egovframework.baseframework.base.StaticContextAccessor;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.baseframework.base.Enums.Return;

/**
 * @author sjhan0418
 * {@link Description}
 */
public class CollabUtils {

	/**request값을 key와 value로 추가한다.*/
	public static void sendMessage(String msgType, String receiverCode)throws Exception {
		CoviMap etcParam = new CoviMap();
		etcParam.put("prjName","");
		etcParam.put("taskName","");
		sendMessage(msgType, receiverCode, etcParam);
		
	}
	//타스트 상태 변경시 /하위 업무 등록및 하위업무 완료시 메세지 전송
	public static void sendTaskMessage(String msgType, int taskSeq)throws Exception {
		//완료 상태 변경시 키 밖에 없음
//		getTask
		CoviMap reqMap = new CoviMap();
		reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		reqMap.put("USERID", SessionHelper.getSession("USERID"));
		reqMap.put("taskSeq", taskSeq);
		
		CollabTaskSvc collabTaskSvc = StaticContextAccessor.getBean(CollabTaskSvc.class);
		CoviMap data = collabTaskSvc.getTask(reqMap);
		CoviMap taskData =(CoviMap)data.get("taskData");
		List mapList = (List)data.get("mapList");

		if (mapList.size()>0){
			CoviMap mapData = (CoviMap )mapList.get(0);
			taskData.put("PrjName", mapData.get("PrjName"));
			taskData.put("SectionName", mapData.get("SectionName"));
		}	
		
		taskData.put("linkList", data.get("linkList"));
		List trgMember =(List)data.get("memberList");
		sendTaskMessage(msgType, taskSeq, taskData, trgMember, Integer.parseInt(String.valueOf(taskData.get("ParentKey"))));
		
	}
	
	public static void sendTaskMessage(String msgType, int taskSeq, CoviMap taskData, List<?> trgMyMember, int parentTaskSeq)throws Exception {
		StringBuffer sbTarget = new StringBuffer();
        for (int i=0; i < trgMyMember.size(); i++){
        	if (i>0) sbTarget.append(";");
        	
        	sbTarget.append((String)((HashMap)trgMyMember.get(i)).get("UserCode")); 
        }    
      
        CoviMap msgMap = new CoviMap();
        msgMap.put("taskName",taskData.get("TaskName"));
        msgMap.put("prjName",taskData.get("PrjName"));
        msgMap.put("sectionName",taskData.get("SectionName"));
        
        msgMap.put("PopupURL","/groupware/collabTask/CollabTaskPopup.do?taskSeq="+taskSeq+"&topTaskSeq="+ parentTaskSeq);
        msgMap.put("GotoURL","/groupware/collabTask/CollabTaskPopup.do?taskSeq="+ taskSeq+"&topTaskSeq="+ parentTaskSeq);
        CollabUtils.sendMessage(msgType, sbTarget.toString(), msgMap);
		CollabTaskSvc collabTaskSvc = StaticContextAccessor.getBean(CollabTaskSvc.class);
		CoviMap reqMap = new CoviMap();
        
        // 업무 등록일 경우 상위 업무에도 메세지 전송  
        if (msgType.equals("TaskAdd")){
	        if (parentTaskSeq > 0){
	        	//int parentTaskSeq = 0;//상위키 찾기
	    		reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
	    		reqMap.put("USERID", SessionHelper.getSession("USERID"));
	    		reqMap.put("taskSeq", parentTaskSeq);
	    		
	    		CoviMap data = collabTaskSvc.getTask(reqMap);
	    		List<?> trgMember =(List)data.get("memberList");
	    		CoviMap taskPrData =(CoviMap)data.get("taskData");
	    		taskData.put("TaskName",taskPrData.get("TaskName")+">"+taskData.get("TaskName"));
	    		//상위 중복 제거
	    		for (int i=0; i < trgMember.size(); i++){
	    			String userId = (String)((HashMap)trgMember.get(i)).get("UserCode");
	    			for (int j=0; j< trgMyMember.size(); j++){
	    				if (((String)((HashMap)trgMyMember.get(j)).get("UserCode")).equals(userId)){
	    					trgMember.remove(i);
	    					break;
	    				}
	    			}
	    		}
	    		sendTaskMessage("TaskAddSub", parentTaskSeq, taskData, trgMember, 0);
	        }
	    }
        
        //업무과 완료일때 후행업무에게도 알림
        if (taskData.getString("TaskStatus").equals("C")){
        	List linkList  = (List)taskData.get("linkList");
        	if (linkList != null){
	        	for (int i=0; i  < linkList.size(); i++){
	        		CoviMap linkData = (CoviMap )linkList.get(i);
	        		if (linkData.getString("LinkType").equals("BF")){
	        			reqMap = new CoviMap();
	    	    		reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
	    	    		reqMap.put("USERID", SessionHelper.getSession("USERID"));
	    	    		reqMap.put("taskSeq", linkData.getString("LinkTaskSeq"));
	    	    		
	        			CoviMap data = collabTaskSvc.getTask(reqMap);
	        			List trgMember =(List)data.get("memberList");
	        			sbTarget = new StringBuffer();
	        	        for (int j=0; j < trgMember.size(); j++){
	        	        	if (j>0) sbTarget.append(";");
	        	        	
	        	        	sbTarget.append((String)((HashMap)trgMember.get(j)).get("UserCode")); 
	        	        }    
	        			sendMessage("TaskLink", sbTarget.toString(), msgMap);
	        		}
	        	}
        	}
        }
	}

	//관련업무
	public static void sendTaskLinkMessage1(CoviMap params)throws Exception {
		//후행업무에가 알림전송
		if (params.get("taskStatus").equals("C")){
			//CollabUtils.sendTaskMessage("TaskComplete",  params);
		}
	}	

	//마일스톤 등롤시
	public static void sendMileMessage(String msgType, int taskSeq)throws Exception {

		CoviMap reqMap = new CoviMap();
		reqMap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
		reqMap.put("USERID", SessionHelper.getSession("USERID"));
		reqMap.put("taskSeq", taskSeq);
		
		CollabTaskSvc collabTaskSvc = StaticContextAccessor.getBean(CollabTaskSvc.class);
		CoviMap data = collabTaskSvc.getTask(reqMap);
		CoviMap taskData =(CoviMap)data.get("taskData");
		List mapList = (List)data.get("mapList");

		CoviMap msgMap = new CoviMap();
		if (mapList.size()>0){
			CoviMap mapData = (CoviMap )mapList.get(0);
			msgMap.put("prjName", mapData.get("PrjName"));
			msgMap.put("sectionName", mapData.get("SectionName"));
		}	
		
		List trgMember =(List)data.get("memberList");
		StringBuffer sbTarget = new StringBuffer();
        for (int i=0; i < trgMember.size(); i++){
        	if (i>0) sbTarget.append(";");
        	
        	sbTarget.append((String)((HashMap)trgMember.get(i)).get("UserCode")); 
        }    
        
//		msgMap.put("taskName","");
        msgMap.put("taskName",taskData.get("TaskName"));
        sendMessage("TaskMile", sbTarget.toString(), msgMap);
        //프로젝트 담당자에게도 메세지 전송
        CollabProjectSvc collabProjectSvc = StaticContextAccessor.getBean(CollabProjectSvc.class);

        for (int j=0; j < mapList.size(); j++){
        	msgMap = new CoviMap();
			CoviMap mapData = (CoviMap )mapList.get(j);
			if(mapData.getString("PrjType").equals("P")) {
				int prjSeq  = mapData.getInt("PrjSeq");

				CoviMap prjList = collabProjectSvc.getProject(prjSeq);
				CoviMap prjData = (CoviMap)prjList.get("prjData");

				List memberList = (List)prjList.get("memberList");
				List managerList = (List)prjList.get("managerList");
				sbTarget = new StringBuffer();
		        for (int i=0; i < memberList.size(); i++){
		        	if (!sbTarget.toString().equals("")) sbTarget.append(";");
		        	
		        	sbTarget.append((String)((HashMap)memberList.get(i)).get("UserCode")); 
		        }  
		        for (int i=0; i < managerList.size(); i++){
		        	if (!sbTarget.toString().equals("")) sbTarget.append(";");
		        	
		        	sbTarget.append((String)((HashMap)managerList.get(i)).get("UserCode")); 
		        }  
		        
		        msgMap.put("prjName", prjData.get("PrjName"));
		        msgMap.put("taskName",taskData.get("TaskName"));
		        sendMessage("PrjMile", sbTarget.toString(), msgMap);
			}
		}	
	}
	
	public static String getMessageSubejct(String taskType, CoviMap etcParam){
		String ret = "";
		if (taskType.equals("PROJECT") && etcParam.getBoolean("prjName") != null)
			ret	= "["+ etcParam.get("prjName")+"] " + DicHelper.getDic("lbl_Project"); // 프로젝트
		else
			ret = etcParam.get("prjName")==null?"[My]": "["+ etcParam.get("prjName")+"]"+
					(etcParam.get("sectionName")!=null&&((String)etcParam.get("sectionName")).equals("")?"["+ etcParam.get("sectionName")+"]":"")+
						"["+ etcParam.get("taskName")+"] "+(taskType.equals("SUBTASK")?DicHelper.getDic("lbl_Subtask"):DicHelper.getDic("lbl_task_task")); // 하위업무, 업무
		return ret;
	}
	
	
	public static void sendMessage(String msgType, String receiverCode, CoviMap etcParam)throws Exception {

		String messagingSubject = "";
		String receiverText = "";
		CoviMap sendMessage = new CoviMap();
		sendMessage.put("ServiceType", "Collab");
		sendMessage.put("MsgType", msgType);


		String pDomainId = SessionHelper.getSession("DN_ID");
		String sUrl = MessageHelper.getInstance().replaceLinkUrl(pDomainId, PropertiesUtil.getGlobalProperties().getProperty("smart4j.path"),false);
		
		if (msgType.equals("PrjAdd") || msgType.equals("PrjAddMember") || msgType.equals("PrjMod") || msgType.equals("PrjMile") ){
	        sendMessage.put("PopupURL", sUrl+(etcParam.get("PopupURL") == null?"/groupware/layout/collab_CollabPortal.do?CLSYS=collab&CLMD=user&CLBIZ=Collab":etcParam.get("PopupURL")));
	        sendMessage.put("GotoURL",  sUrl+(etcParam.get("GotoURL")  == null?"/groupware/layout/collab_CollabPortal.do?CLSYS=collab&CLMD=user&CLBIZ=Collab":etcParam.get("GotoURL")));
		}else{
	        sendMessage.put("PopupURL", sUrl+(etcParam.get("PopupURL") == null?"/groupware/collabTask/CollabTaskPopup.do?taskSeq="+etcParam.get("taskSeq"):etcParam.get("PopupURL")));
	        sendMessage.put("GotoURL",  sUrl+(etcParam.get("GotoURL")  == null?"/groupware/collabTask/CollabTaskPopup.do?taskSeq="+etcParam.get("taskSeq"):etcParam.get("GotoURL")));
		}
        
        switch (msgType){
	        case "PrjAdd":	//프로젝트 생성
	        	messagingSubject =  DicHelper.getDic("msg_created").replace("{0}", getMessageSubejct("PROJECT", etcParam)); // {0}가 생성되었습니다.
	        	receiverText =  DicHelper.getDic("msg_whoCreate").replace("{0}", SessionHelper.getSession("USERNAME"))
	        			.replace("{1}", getMessageSubejct("PROJECT", etcParam)); // {0}님이 {1}를 생성하였습니다.
	        	break;
	        case "PrjAddMember"://프로젝트 담당자 추가
	        	messagingSubject = DicHelper.getDic("msg_created").replace("{0}", getMessageSubejct("PROJECT", etcParam)); // {0}에 초대되었습니다.
	        	receiverText =  DicHelper.getDic("msg_whoInvited").replace("{0}", SessionHelper.getSession("USERNAME"))
	        			.replace("{1}", getMessageSubejct("PROJECT", etcParam)); // {0}님이 {1}에 초대하였습니다
	        	break;
	        case "PrjMod":		//프로젝트 변경(상태)
	        	messagingSubject = DicHelper.getDic("msg_changeStatus").replace("{0}", getMessageSubejct("PROJECT", etcParam)); // {0} 상태가 변경가 되었습니다.
	        	receiverText =  DicHelper.getDic("msg_whoChangeStatus").replace("{0}", SessionHelper.getSession("USERNAME"))
	        			.replace("{1}", getMessageSubejct("PROJECT", etcParam)); // {0}님이 {1}의 상태를 변경하였습니다.
	        	break;
	        case "PrjMile":		//마일스톤
	        	messagingSubject = DicHelper.getDic("msg_registMilestone").replace("{0}", getMessageSubejct("TASK", etcParam)); // {0} 마일스톤 등록되었습니다.
	        	receiverText =  DicHelper.getDic("msg_whoRegistMilestone").replace("{0}", SessionHelper.getSession("USERNAME"))
	        			.replace("{1}", getMessageSubejct("PROJECT", etcParam)); // {0}님이 {1} 마일스톤 등록하였습니다.
	        	break;
	        case "TaskAdd":	//업무생성
	        	messagingSubject =  DicHelper.getDic("msg_created").replace("{0}", getMessageSubejct("TASK", etcParam)); // {0}가 생성되었습니다.
	        	receiverText =  DicHelper.getDic("msg_whoCreate").replace("{0}", SessionHelper.getSession("USERNAME"))
	        			.replace("{1}", getMessageSubejct("TASK", etcParam)); // {0}님이 {1}를 생성하였습니다.
	        	break;
	        case "TaskAddMember"://업무담당자추가
	        	messagingSubject = DicHelper.getDic("msg_created").replace("{0}", getMessageSubejct("TASK", etcParam)); // {0}에 초대되었습니다.
	        	receiverText =  DicHelper.getDic("msg_whoInvited").replace("{0}", SessionHelper.getSession("USERNAME"))
	        			.replace("{1}", getMessageSubejct("TASK", etcParam)); // {0}님이 {1}에 초대하였습니다
	        	break;
	        case "TaskMod":		//업무변경(상태)
	        	messagingSubject = DicHelper.getDic("msg_changeStatus").replace("{0}", getMessageSubejct("TASK", etcParam)); // {0} 상태가 변경가 되었습니다.
	        	receiverText =  DicHelper.getDic("msg_whoChangeStatus").replace("{0}", SessionHelper.getSession("USERNAME"))
	        			.replace("{1}", getMessageSubejct("TASK", etcParam)); // {0}님이 {1}의 상태를 변경하였습니다.
	        	break;
	        case "TaskMile":		//마일스톤
	        	messagingSubject = DicHelper.getDic("msg_registMilestone").replace("{0}", getMessageSubejct("TASK", etcParam)); // {0} 마일스톤 등록되었습니다.
	        	receiverText =  DicHelper.getDic("msg_whoRegistMilestone").replace("{0}", SessionHelper.getSession("USERNAME"))
	        			.replace("{1}", getMessageSubejct("PROJECT", etcParam)); // {0}님이 {1} 마일스톤 등록하였습니다.
	        	break;
	        case "TaskLink":		//관련업무
	        	messagingSubject = DicHelper.getDic("lbl_LinkAF") + " " + DicHelper.getDic("msg_completed").replace("{0}", getMessageSubejct("TASK", etcParam)); // {0}가 완료되었습니다.
	        	receiverText =  DicHelper.getDic("msg_whoCompleted").replace("{0}", SessionHelper.getSession("USERNAME"))
	        			.replace("{1}", DicHelper.getDic("lbl_LinkAF") + "[" + getMessageSubejct("PROJECT", etcParam) + "]"); // {0}님이 {1}를 완료하였습니다.
	        	break;
	        case "TaskApproval":	//관련결재
	        	messagingSubject = DicHelper.getDic("msg_contentsChange").replace("{0}", getMessageSubejct("TASK", etcParam)); // {0}의 내용이 변경되었습니다.
	        	receiverText =  DicHelper.getDic("msg_whoChange").replace("{0}", SessionHelper.getSession("USERNAME"))
	        			.replace("{1}", getMessageSubejct("TASK", etcParam)); // {0}님이 {1}를 변경하였습니다.
	        	break;
	        case "TaskAddSub":		//하위업무
	        	messagingSubject = DicHelper.getDic("msg_created").replace("{0}", getMessageSubejct("SUBTASK", etcParam)); // {0}가 생성되었습니다.
	        	receiverText =  DicHelper.getDic("msg_whoCreate").replace("{0}", SessionHelper.getSession("USERNAME"))
	        			.replace("{1}", getMessageSubejct("SUBTASK", etcParam)); // {0}님이 {1}를 생성하였습니다.
	        	break;
	        	
/*	        case "TaskAddComment":
	        	messagingSubject =  "업무에  댓글이 등록되었습니다.";
	        	receiverText =  SessionHelper.getSession("USERNAME")+"님이 ["+ etcParam.get("taskName")+"] 업무에  댓글이 등록되었습니다. 협업스페이스에서 확인해보세요.";
	        	break;*/
	        default :
	        	break;
        }
        //나한테 보내는 메세지 제외
        receiverText += " " + DicHelper.getDic("msg_checkOutCollab");
		String[] ReceiversCodeArr = receiverCode.split(";");
		StringBuffer sbTarget = new StringBuffer("");
		for (int i=0; i < ReceiversCodeArr.length; i++){
			if (!ReceiversCodeArr[i].equals(SessionHelper.getSession("USERID"))){
	        	if (!sbTarget.toString().equals("")) sbTarget.append(";");
	        	sbTarget.append(ReceiversCodeArr[i]); 
			}
		}
        //중복제거
		MessageHelper.getInstance().insertMessageData(sendMessage, SessionHelper.getSession("USERID"), sbTarget.toString(), messagingSubject,receiverText);
	}
	
	public static CoviMap sendEumChannel(String sendUrl, String sendMethod, CoviMap paramsObj) throws Exception {
		HttpClientUtil httpClient = new HttpClientUtil();
		String eumServerUrl = RedisDataUtil.getBaseConfig("eumServerUrl");
		CoviMap paramsHeader = new CoviMap();
		paramsHeader.put("Covi-User-Access-ID",paramsObj.getString("USERID"));
		CoviMap result = httpClient.httpRestAPIConnect(eumServerUrl+sendUrl, "json", sendMethod, paramsObj.toString(), paramsHeader);
		return result;
	}	
	
	
	public static CoviMap createChannel(CoviMap params) throws Exception {
		CoviMap paramsObj = new CoviMap();
		CoviMap resultMap = new CoviMap();
		
		java.util.Iterator<String> iter = params.keySet().iterator();
		while(iter.hasNext()){   
			String key = iter.next();
			paramsObj.put(key, params.get(key));
		}	

		paramsObj.put("roomType", "C");
		paramsObj.put("description", "");
		paramsObj.put("categoryCode", "COMMON");
		paramsObj.put("openType", "O");
		paramsObj.put("secretKey", "");
		
		CoviMap result = sendEumChannel("/server/na/s/channel/room", "POST", paramsObj);//httpClient.httpRestAPIConnect(eumServerUrl+"/server/na/s/channel/room", "json", "POST", paramsObj, paramsHeader);

		if(CoviMap.fromObject(result.toString()).getJSONObject("body").getString("status").equals("SUCCESS")){
			String roomId = CoviMap.fromObject(result.toString()).getJSONObject("body").getJSONObject("result").getJSONObject("room").getString("roomId");
			resultMap.put("status", Return.SUCCESS);
			resultMap.put("roomId", roomId);
		}else{
			resultMap.put("status",  Return.FAIL);
			resultMap.put("message", CoviMap.fromObject(result.toString()).getJSONObject("body").getString("result"));
		}
		
		return resultMap;
	}	
	
	public static CoviMap addChannelMember(String roomId, CoviMap params) throws Exception {
		CoviMap paramsObj = new CoviMap();
		CoviMap resultMap = new CoviMap();
		
		java.util.Iterator<String> iter = params.keySet().iterator();
		while(iter.hasNext()){   
			String key = iter.next();
			paramsObj.put(key, params.get(key));

		}	

		CoviMap result = sendEumChannel("/server/na/s/channel/join/"+roomId, "POST", paramsObj);
		
		if(CoviMap.fromObject(result.toString()).getJSONObject("body").getString("status").equals("SUCCESS")){
			resultMap.put("status", Return.SUCCESS);
			resultMap.put("roomId", roomId);
		}else{
			resultMap.put("status",  Return.FAIL);
			resultMap.put("message", CoviMap.fromObject(result.toString()).getJSONObject("body").getString("result"));
		}
		
		return resultMap;
	}	
	
	public static CoviMap removeChannelMember(String roomId, CoviMap params) throws Exception {
		CoviMap paramsObj = new CoviMap();
		CoviMap resultMap = new CoviMap();
		
		java.util.Iterator<String> iter = params.keySet().iterator();
		while(iter.hasNext()){   
			String key = iter.next();
			paramsObj.put(key, params.get(key));

		}	
		paramsObj.put("leave", "Y");
		paramsObj.put("roomType", "C");
		CoviMap result = sendEumChannel("/server/na/s/channel/leave/"+roomId, "POST", paramsObj);
		
		if(CoviMap.fromObject(result.toString()).getJSONObject("body").getString("status").equals("SUCCESS")){
			resultMap.put("status", Return.SUCCESS);
			resultMap.put("roomId", roomId);
		}else{
			resultMap.put("status",  Return.FAIL);
			resultMap.put("message", CoviMap.fromObject(result.toString()).getJSONObject("body").getString("result"));
		}
		
		return resultMap;
	}

	public static String getMyGrouptPath(){
		String groupPath = SessionHelper.getSession("GR_GroupPath");
		int partLvl = Integer.parseInt(RedisDataUtil.getBaseConfig("CollabPartLevel"));
		String[] arrayPath = groupPath.split(";");
		if (arrayPath.length > partLvl){
			groupPath = groupPath.substring(0, groupPath.substring(0, groupPath.length()-1).lastIndexOf(";"))+";";
		}
		
		return groupPath;
	}
}
