package egovframework.covision.groupware.attend.user.service.impl;

import javax.annotation.Resource;

import com.google.gson.Gson;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.attend.user.service.AttendScheduleSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;

@Service("AttendScheduleSvc")
public class AttendScheduleSvcImpl extends EgovAbstractServiceImpl implements AttendScheduleSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * @Method Name : getAttendScheduleList
	 * @Description : 근무제 조회
	 */
	@Override 
	public CoviMap getAttendScheduleList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("attend.schedule.getAttendScheduleListCnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
			params.addAll(page);
		}	
		list	= coviMapperOne.list("attend.schedule.getAttendScheduleList", params);	
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList; 
	}

	/**
	 * @Method Name : getAttendScheduleList
	 * @Description : 근무제상세 조회
	 */
	@Override 
	public CoviMap getAttendScheduleDetail(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		
		
		list	= coviMapperOne.list("attend.schedule.getAttendScheduleDetail", params);	
		resultList.put("list",	list);
		
		return resultList; 
	}
	
	public int addAttendSchedule (CoviMap params) throws Exception {
		int cnt = coviMapperOne.insert("attend.schedule.insertAttendSchedule", params);
		return params.getInt("SchSeq") ;
	}
	
	public int saveAttendSchedule  (CoviMap params) throws Exception {
		return coviMapperOne.update("attend.schedule.updateAttendSchedule", params);
	}

	public int deleteAttendSchedule  (List objList) throws Exception {

		int cnt = 0;
		for(int i=0; i<objList.size(); i++){
			int scheduleCnt = 0;
			Map item = (Map)objList.get(i);
			scheduleCnt = coviMapperOne.delete("attend.schedule.deleteAttendSchedule", item);
			if(scheduleCnt > 0) {
				// 근무일정 템플릿 출, 퇴근 장소 지정 삭제
				coviMapperOne.delete("attend.schedule.deleteAttSchWorkPlaceBySchSeq", item);
				// 근태_관리_근무제_할당 삭제
				coviMapperOne.delete("attend.schedule.delAttSchAllocBySchSeq", item);
			}
			cnt += scheduleCnt;
		}
		return cnt;
	}
	
	public int updateAttendScheduleBase  (CoviMap params) throws Exception {
		return coviMapperOne.update("attend.schedule.updateAttendScheduleBase", params);
	}

	public int updateAttendScheduleValid  (CoviMap params) throws Exception {
		return coviMapperOne.update("attend.schedule.updateAttendScheduleValid", params);
	}
	/**
	 * @Method Name : getSchMemberInfo
	 * @Description : 근무 지정자 조회
	 */
	@Override 
	public CoviMap getSchMemberInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();

		params.put("lang", SessionHelper.getSession("lang"));
		params.put("UR_TimeZone",ComUtils.GetLocalCurrentDate("yyyy-MM-dd"));
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("attend.schedule.getAttSchMemberInfoCnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);

			params.addAll(page);
		}	

		list	= coviMapperOne.list("attend.schedule.getAttSchMemberInfo", params);	
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList; 
	}

	@Override
	public void setSchMemberInfo(CoviMap params) throws Exception {
		coviMapperOne.insert("attend.schedule.setAttSchMember",params);
	}

	@Override
	public void delSchMemberInfo(CoviMap params) throws Exception {
		coviMapperOne.insert("attend.schedule.delAttSchMember",params);
	}
	
	/**
	 * @Method Name : getSchAllocInfo
	 * @Description : 근무 사용가능자 조회
	 */
	@Override 
	public CoviMap getSchAllocInfo(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt			= 0;
			cnt		= (int) coviMapperOne.getNumber("attend.schedule.getAttSchAllocInfoCnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);

			params.addAll(page);
		}	
		list	= coviMapperOne.list("attend.schedule.getAttSchAllocInfo", params);	
		resultList.put("list",	list);
		resultList.put("page",	page);
		
		return resultList; 
	}

	@Override
	public int setSchAllocInfo(List objList) throws Exception {
		int cnt = 0;
		for(int i=0; i<objList.size(); i++){
			Map item = (Map)objList.get(i);
			item.put("UserCode", SessionHelper.getSession("USERID"));

			cnt += coviMapperOne.insert("attend.schedule.setAttSchAlloc", item);
		}
		return cnt;
		
	}

	@Override
	public int delSchAllocInfo(List objList) throws Exception {
		int cnt = 0;
		for(int i=0; i<objList.size(); i++){
			Map item = (Map)objList.get(i);
			cnt += coviMapperOne.insert("attend.schedule.delAttSchAlloc", item);
		}
		return cnt;
	}
	
	/**
	 * @Method Name : uploadExcel
	 * @Description : 엑셀 다운로드
	 */
	@Override
	public CoviMap uploadExcel(CoviMap params) throws Exception{
		int cnt = 0;
		CoviMap resultList	= new CoviMap();
		
		ArrayList<ArrayList<Object>> dataList = AttendUtils.extractionExcelData(params, 3);	// 엑셀 데이터 추출
		int totalCnt   =0 ;
		int successCnt =0;
		int failCnt = 0;

		for (ArrayList list : dataList) { // 추가
			if(list.size()<50){continue;}//입력 컬럼수 체크
			CoviMap item = new  CoviMap();
			item.put("AttSeq", params.get("AttSeq"));
			item.put("UserCode", SessionHelper.getSession("UR_Code"));
			item.put("CompanyCode",SessionHelper.getSession("DN_Code"));

			
			int idx=0;
			int workSysType = Integer.parseInt(list.get(idx++).toString());
			if(workSysType==1){
				item.put("SelfCommYn","Y");
			}
			item.put("WorkingSystemType", workSysType);//근무유형
			item.put("SchName", list.get(idx++));
			item.put("AttDayStartTime", list.get(idx++));
			item.put("AttDayEndTime", list.get(idx++));
			item.put("NextDayYn", list.get(idx));
			idx=2;
			String[] Weeks = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
			for (int i=0; i <Weeks.length; i++){
				//System.out.println(idx + ":" + ((String) list.get(idx)) + Weeks[i]);
				item.put("Start" + Weeks[i] + "Hour", (String.valueOf(list.get(idx)).substring(0, 2)));
				item.put("Start" + Weeks[i] + "Min", (String.valueOf(list.get(idx++)).substring(2, 4)));
				item.put("End" + Weeks[i] + "Hour", (String.valueOf(list.get(idx)).substring(0, 2)));
				item.put("End" + Weeks[i] + "Min", (String.valueOf(list.get(idx++)).substring(2, 4)));
				item.put("NextDayYn" + Weeks[i], list.get(idx++));
			}
			item.put("AssYn", list.get(idx++));

			//코어타임, 출근가능시간, 퇴근 가능시간 추출
			item.put("CoreTimeYn", list.get(idx++));
			item.put("CoreStartTimeHour", (String.valueOf(list.get(idx)).substring(0, 2)));
			item.put("CoreStartTimeMin", (String.valueOf(list.get(idx++)).substring(2, 4)));
			item.put("CoreEndTimeHour", (String.valueOf(list.get(idx)).substring(0, 2)));
			item.put("CoreEndTimeMin", (String.valueOf(list.get(idx++)).substring(2, 4)));

			item.put("AttDayAC", Integer.parseInt(list.get(idx++).toString()));
			item.put("AttDayIdle", Integer.parseInt(list.get(idx++).toString()));

			for (int i=0; i <Weeks.length; i++){
				item.put("Ac" + Weeks[i], (Integer.parseInt(list.get(idx++).toString())));
				item.put("Idle" + Weeks[i], (Integer.parseInt(list.get(idx++).toString())));
			}

			item.put("GoWorkTimeYn", list.get(idx++));
			item.put("GoWorkStartTimeHour", (String.valueOf(list.get(idx)).substring(0, 2)));
			item.put("GoWorkStartTimeMin", (String.valueOf(list.get(idx++)).substring(2, 4)));
			item.put("GoWorkEndTimeHour", (String.valueOf(list.get(idx)).substring(0, 2)));
			item.put("GoWorkEndTimeMin", (String.valueOf(list.get(idx++)).substring(2, 4)));
			item.put("OffWorkTimeYn", list.get(idx++));

			item.put("OffWorkStartTimeHour", (String.valueOf(list.get(idx)).substring(0, 2)));
			item.put("OffWorkStartTimeMin", (String.valueOf(list.get(idx++)).substring(2, 4)));
			item.put("OffWorkEndTimeHour", (String.valueOf(list.get(idx)).substring(0, 2)));
			item.put("OffWorkEndTimeMin", (String.valueOf(list.get(idx++)).substring(2, 4)));

			Object strMemo = null;
			strMemo = list.get(idx);
			if(strMemo!=null) {
				item.put("Memo", strMemo.toString());
			}

			item.put("USERID", SessionHelper.getSession("UR_Code"));
			item.put("CompanyCode",SessionHelper.getSession("DN_Code"));

			cnt = coviMapperOne.insert("attend.schedule.insertAttendSchedule", item);
			if (cnt >0) successCnt++;
			else failCnt++;		
			totalCnt++;
		}

		resultList.put("totalCnt", totalCnt);
		resultList.put("successCnt", successCnt);
		resultList.put("failCnt", failCnt);
		return resultList;
	}

	@Override
	public List<CoviMap> getWorkPlaceList(CoviMap params) throws Exception {
		List<CoviMap> result;
		result = coviMapperOne.list("attend.schedule.getWorkPlaceList", params);

		return result;
	}

	@Override
	public List<CoviMap> getAddWorkPlaceList(CoviMap params) throws Exception {
		List<CoviMap> result;
		result = coviMapperOne.list("attend.schedule.getAddWorkPlaceList", params);

		return result;
	}

	@Override
	public void insertAttSchWorkPlace(CoviMap params) throws Exception {
		coviMapperOne.insert("attend.schedule.insertAttSchWorkPlace", params);
	}

	@Override
	public void deleteAttSchWorkPlace(CoviMap params) throws Exception {
		coviMapperOne.delete("attend.schedule.deleteAttSchWorkPlace", params);
	}

}
