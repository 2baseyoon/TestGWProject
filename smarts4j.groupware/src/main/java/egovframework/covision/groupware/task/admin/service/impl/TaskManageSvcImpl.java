package egovframework.covision.groupware.task.admin.service.impl;

import java.util.Iterator;
import java.util.Objects;
import java.util.Set;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.covision.groupware.task.admin.service.TaskManageSvc;

@Service("taskManageService")
public class TaskManageSvcImpl extends EgovAbstractServiceImpl implements TaskManageSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	

	@Override
	public void transferTask(CoviMap params) throws Exception {
		coviMapperOne.update("admin.task.updateFolderOwner",params); //폴더 주인 변경
		coviMapperOne.update("admin.task.updateTaskOwner",params); //업무 주인 변경
	}

	@Override
	public CoviList getGroupChartData(CoviMap params) throws Exception {
		CoviList retArr = new CoviList();
		
		CoviList arrFolderStata = RedisDataUtil.getBaseCode("FolderState");
		CoviList arrPersonData = CoviSelectSet.coviSelectJSON(coviMapperOne.list("admin.task.selectGroupChartPersonData", params), "State,StateCnt");
		CoviList arrShareData = CoviSelectSet.coviSelectJSON(coviMapperOne.list("admin.task.selectGroupChartShareData", params), "State,StateCnt");
		
		CoviMap personData = new CoviMap();
		personData.put("Kind", "개인");//개인(lbl_apv_person)
		CoviMap shareData = new CoviMap();
		shareData.put("Kind", "공유"); //공유(lbl_sharing)
		
		
		for(Object stateObj : arrFolderStata){
			String code = ((CoviMap) stateObj).getString("Code") ;
			personData.put(code, 0);
			shareData.put(code, 0);
		}
		
		for(Object obj : arrPersonData){
			CoviMap dataObj = (CoviMap)obj;
			personData.put(dataObj.getString("State"), dataObj.getInt("StateCnt"));
		}
		
		for(Object obj : arrShareData){
			CoviMap dataObj = (CoviMap)obj;
			shareData.put(dataObj.getString("State"), dataObj.getInt("StateCnt"));
		}
		
		retArr.add(personData);
		retArr.add(shareData);
		
		return retArr;
	}

	@Override
	public CoviMap getUserFolderList(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("admin.task.selectFolderOfFolderListCnt", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList folderList =  coviSelectJSONForTaskList( coviMapperOne.list("admin.task.selectFolderOfFolderList", params), "FolderID,DisplayName,FolderState,FolderStateCode,IsShare,OwnerCode,RegisterCode,ParentFolderID,RegisterName,RegistDate");
		resultObj.put("list", folderList);
		resultObj.put("page", page);
		
		return resultObj;
	}

	@Override
	public CoviMap getUserTaskList(CoviMap params) throws Exception {
		CoviMap resultObj = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("admin.task.selectTaskOfFolderListCnt", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList taskList = coviSelectJSONForTaskList( coviMapperOne.list("admin.task.selectTaskOfFolderList", params),  "TaskID,FolderID,Subject,TaskState,StartDate,EndDate,TaskStateCode,IsDelay,IsRead,RegistDate,OwnerCode,RegisterCode,RegisterName");
		resultObj.put("list", taskList);
		resultObj.put("page", page);
		
		return resultObj;
	}
	
	//업무관리용
		@SuppressWarnings("unchecked")
		public CoviList coviSelectJSONForTaskList(CoviList clist, String str) throws Exception {
			String[] cols = str.split(",");
			CoviMap taskDic = getTaskDic();

			CoviList returnArray = new CoviList();

			if (null != clist && clist.size() > 0) {
				for (int i = 0; i < clist.size(); i++) {

					CoviMap newObject = new CoviMap();

					for (int j = 0; j < cols.length; j++) {
						Set<String> set = clist.getMap(i).keySet();
						Iterator<String> iter = set.iterator();

						while (iter.hasNext()) {
							Object ar = iter.next();
							if (ar.equals(cols[j].trim())) {
								if (ar.equals("FolderState") || ar.equals("TaskState")) {
									newObject.put(cols[j], Objects.toString(taskDic.getString(ar+"_"+clist.getMap(i).getString(cols[j])), clist.getMap(i).getString(cols[j]) ));	
								}else {
									newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
								}
							}
						}
					}
					returnArray.add(newObject);
				}
			}
			return returnArray;
		}

		//업무관리용 
		@SuppressWarnings("unchecked")
		public  CoviMap coviSelectJSONForTaskList(CoviMap obj, String str) throws Exception {
			String [] cols = str.split(",");
			CoviMap taskDic = getTaskDic();
			
			CoviMap newObject = new CoviMap();
			for(int j=0; j<cols.length; j++){
				Set<String> set = obj.keySet();
				Iterator<String> iter = set.iterator();
				
				while(iter.hasNext()){   
					String ar = (String)iter.next();
					if(ar.equals(cols[j].trim())){
						if (ar.equals("FolderState") || ar.equals("TaskState")) {
							newObject.put(cols[j], Objects.toString(taskDic.getString(ar+"_"+obj.getString(cols[j])),obj.getString(cols[j]) ));	
						}else {
							newObject.put(cols[j], obj.getString(cols[j]));
						}
					}
				}
			}
			
			return newObject;
		}
		
		// 업무관리에서 사용하는 다국어 값 세팅
		public CoviMap getTaskDic() throws Exception {
			CoviMap taskDic = new CoviMap();
			
			CoviMap taskState = RedisDataUtil.getBaseCodeGroupDic("TaskState");
			CoviMap workState = RedisDataUtil.getBaseCodeGroupDic("FolderState");
			
			for(Object key : taskState.keySet()){
				String strKey = key.toString();
				taskDic.put("TaskState_"+strKey, taskState.getString(strKey) );
			}		
			
			for(Object key : workState.keySet()){
				String strKey = key.toString();
				taskDic.put("FolderState_"+strKey, workState.getString(strKey) );
			}		
			
			taskDic.put("", "");
			
			return taskDic;
		}
	
	
	
}
