package egovframework.core.sevice.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.core.sevice.LoggingSvc;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("loggingService")
public class LoggingSvcImpl extends EgovAbstractServiceImpl implements LoggingSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap selectConnectFalse(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.LogConnectFalseLog.selectCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		
		CoviList list = coviMapperOne.list("sys.LogConnectFalseLog.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LogID,UserCode,UserName,MachineName,DeptName,LogonID,Region,IPAddress,OS,Browser,Resolution,Year,Month,Week,Day,Hour,LogonAgentInfo,LogonTryDate"));
		return resultList;
	}
	
	@Override
	public CoviMap selectConnect(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.LogConnectLog.selectCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);	//DeptName,
 		}		
		CoviList list = coviMapperOne.list("sys.LogConnectLog.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LogID,UserCode,UserName,MachineName,UR_Code,DeptName,LogonID,Region,IPAddress,OS,Browser,Resolution,Year,Month,Week,Day,Hour,LogonAgentInfo,SessionID,ReSessionCnt,StayTime,LogonDate,LogoutDate"));
		return resultList;
	}

	@Override
	public CoviMap selectConnectExcel(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("sys.LogConnectLog.selectgrid", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserCode,UserName,DeptName,OS,Browser,IPAddress,LogonDate,LogoutDate"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectError(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.LogErrorLog.selectCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		
		CoviList list = coviMapperOne.list("sys.LogErrorLog.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LogID,MachineName,UserCode,ErrorUserName,DeptName,LogonID,ErrorType,ProcessState,AlertMessage,ErrorMessage,SiteName,ServiceType,SubSystem,PageURL,PageParam,MethodName,IPAddress,EventDate"));
		return resultList;
	}

	@Override
	public CoviMap selectErrorPage(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("sys.LogErrorLog.selectPage", params);
		int cnt = (int) coviMapperOne.getNumber("sys.LogErrorLog.selectCount", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LogID,MachineName,UserCode,ErrorUserName,DeptName,LogonID,ErrorType,ProcessState,AlertMessage,ErrorMessage,SiteName,ServiceType,SubSystem,PageURL,PageParam,MethodName,IPAddress,EventDate"));
		resultList.put("cnt", cnt);
		return resultList;
	}
	
	@Override
	public CoviMap selectErrorExcel(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("sys.LogErrorLog.selectgrid", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ErrorType,EventDate,PageURL,ErrorUserName,DeptName,IPAddress"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectPageMove(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.LogPageMoveLog.selectCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		
		CoviList list = coviMapperOne.list("sys.LogPageMoveLog.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LogID,MoveUserName,UserCode,LogonID,DeptName,PageURL,ObjectType,IPAddress,MoveDate,CompanyCode"));
		return resultList;
	}
	
	@Override
	public CoviMap selectPageMoveExcel(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("sys.LogPageMoveLog.selectgrid", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "MoveDate,CompanyCode,PageURL,IPAddress,MoveUserName,DeptName"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectPerformance(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.LogPerformanceLog.selectCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		
		CoviList list = coviMapperOne.list("sys.LogPerformanceLog.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LogID,MachineName,UR_Code,UserName,DeptName,LogonID,SiteName,LogType,LogTitle,ThreadID,RunTime,MethodName,PageURL,PageParam,IPAddress,EventDate"));
		return resultList;
	}

	@Override
	public CoviMap selectPerformanceExcel(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("sys.LogPerformanceLog.selectgrid", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LogType,EventDate,ThreadID,RunTime,PageURL,LogonID,UserName,DeptName,IPAddress,MachineName"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectUserInfoChange(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.LogUserInfoProcessingLog.selectCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		

 		CoviList list = coviMapperOne.list("sys.LogUserInfoProcessingLog.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LogID,PerformerID,PerformerName,TargetID,TargetName,KindOfAction,ActionDate,Note"));
		return resultList;
	}
	
	@Override
	public CoviMap selectHttpConnect(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.LogConnectLog.selectHttpConnectCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}
 		
		CoviList list = coviMapperOne.list("sys.LogConnectLog.selectHttpConnect", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LogID,LogType,Method,ConnectURL,RequestBody,RequestDate,ResultState,ResultType,ResponseMsg,ResponseDate"));
		return resultList;
	}
	
	@Override
	public String selectDetailErrorLogMessage(CoviMap params) throws Exception {
		String str = coviMapperOne.getString("sys.LogConnectLog.selectDetailErrorLogMessage", params);

		return str;
	}

	@Override
	public CoviMap selectUserCheck(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("sys.LogUserCheck.selectUserCheckCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 		}
		
		CoviList list = coviMapperOne.list("sys.LogUserCheck.selectUserCheck",params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "AuthKey,AuthType,LogonID,AuthStatus,AuthEQ_Info,EQ_AuthKind,ReqTime,SuccessTime,CheckTime,ReqDay"));
		
		return resultList;
	}

	@Override
	public CoviMap selectExtDbSync(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("sys.dbsync.selectLogCnt", params);
		CoviMap page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("sys.dbsync.selectLog", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public String selectExtDbSyncDetail(CoviMap params) throws Exception {
		return coviMapperOne.getString("sys.dbsync.selectLogDetail", params);
	}
	
	@Override
	public CoviMap selectFileDownload(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("sys.LogFileDownloadLog.selectCount", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("sys.LogFileDownloadLog.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LogID,UserCode,DisplayName,DeptName,FileID,FileUUID,ServiceType,FileName,IsMobile,IPAddress,ReferURL,DownloadResult,FailReason,RequestDate"));
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public CoviMap selectFileDownloadExcel(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("sys.LogFileDownloadLog.selectgrid", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DisplayName,DeptName,ServiceType,FileName,IsMobile,IPAddress,ReferURL,DownloadResult,FailReason,RequestDate "));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectAuthError(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
 		CoviMap page = new CoviMap();
 		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("autherror.selectCount", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 			resultList.put("cnt", cnt);
 		}		
		CoviList list = coviMapperOne.list("autherror.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LogID,UserCode,LogonID,AuthErrorUserName,DeptName,PageURL,IPAddress,CompanyCode,ErrorDate,AuditClass,AuditMethod,ErrorType,ErrorMessage"));
		return resultList;
	}
	
	@Override
	public CoviMap selectAuthErrorExcel(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("autherror.selectgrid", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "ErrorDate,CompanyCode,PageURL,AuthErrorUserName,DeptName,AuditClass,AuditMethod,ErrorType,ErrorMessage"));
		
		return resultList;
	}
	
	@Override
	public CoviMap selectACLChange(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("sys.LogACLChangeLog.selectCount", params);
		page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("sys.LogACLChangeLog.selectgrid", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LogChangeID,ChangeType,ObjectID,ObjectType,ObjectName,SubjectName,SubjectType,Security,Create,Delete,Modify,Execute,View,Read,IsSubInclude,InheritedObjectID,RegisterCode,RegisterName,RegisterDeptName,RegistDateDate"));
		resultList.put("page", page);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectAuthChangeHistoryExcel(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("sys.LogACLChangeLog.selectexcelgrid", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "RegistDateDate,ChangeType,ObjectType,ObjectName,SubjectName,SubjectType,InheritedObjectID,Security,Create_,Delete_,Modify,Execute,View,Read_,IsSubInclude,RegisterName"));
		
		return resultList;
	}

}
