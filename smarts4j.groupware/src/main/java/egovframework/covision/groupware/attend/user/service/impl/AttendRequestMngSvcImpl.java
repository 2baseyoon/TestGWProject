package egovframework.covision.groupware.attend.user.service.impl;

import javax.annotation.Resource;

import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.SessionHelper;


import egovframework.baseframework.util.json.JSONParser;
import org.springframework.stereotype.Service;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.RedisDataUtil;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import egovframework.covision.groupware.attend.user.service.AttendRequestMngSvc;
import egovframework.covision.groupware.attend.user.util.AttendUtils;

@Service("AttendRequestMngSvc")
public class AttendRequestMngSvcImpl extends EgovAbstractServiceImpl implements AttendRequestMngSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	/**
	 * @Method Name : getAttendRequestList
	 * @Description : 근무제 조회
	 */
	@Override 
	public CoviMap getAttendRequestList(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap page			= new CoviMap();
		CoviList list			= new CoviList();

		params.put("lang", SessionHelper.getSession("lang"));
		
		if (params.get("pageNo") != null && params.get("pageSize") != null){
			int cnt	= 0;
			cnt = (int) coviMapperOne.getNumber("attend.req_mng.getRequestListCnt" , params);
			page= AttendUtils.setPagingData( AttendUtils.nvlInt(params.get("pageNo"),1), AttendUtils.nvlInt(params.get("pageSize"),10), cnt);
			params.addAll(page);
		}	
		list = coviMapperOne.list("attend.req_mng.getRequestList", params);
		for(Object objDetail : list) {
			CoviMap attendObj = (CoviMap)objDetail;
			
			if (attendObj.getString("ReqType").equals("A") || attendObj.getString("ReqType").equals("L"))//출근/퇴근 신청서 거리
			{
				JSONParser parser = new JSONParser();
				CoviList obj = (CoviList)parser.parse(attendObj.getString("ReqData")) ;
				CoviMap resultMap = (CoviMap)obj.get(0);
				if (resultMap.get("CommutePointX") != null && resultMap.get("CommutePointY") != null){
					double distance = AttendUtils.getPointDistance(attendObj.getDouble("WorkPointX"), attendObj.getDouble("WorkPointY"), Double.parseDouble(resultMap.get("CommutePointX").toString()),Double.parseDouble(resultMap.get("CommutePointY").toString()));
					attendObj.put("WorkDis",distance);
				}
			}	
		}
		
		resultList.put("list", list);
		resultList.put("page", page);
		
		return resultList; 
	}

	/**
	 * @Method Name : getAttendRequestDetail
	 * @Description : 요청정보상세
	 */
	@Override 
	public CoviMap getAttendRequestDetail(CoviMap params) throws Exception {
		CoviMap resultList	= new CoviMap();
		CoviMap data			= new CoviMap();
		CoviMap bfData			= new CoviMap();

		params.put("lang", SessionHelper.getSession("lang"));

		data	= coviMapperOne.selectOne("attend.req_mng.getRequestDetail", params);

		DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		Calendar cal = Calendar.getInstance();
		JSONParser parser = new JSONParser();
		if (data.get("ReqData") != null){
			String reqData = data.getString("ReqData");
			CoviList obj = (CoviList)parser.parse(reqData);
			if ("V".equals(data.getString("ReqType")))//휴가 이름 가져오기
			{	
				CoviMap resultMap = obj.getMap(0);
				String VacFlagName = RedisDataUtil.getBaseCodeDic("VACATION_TYPE", resultMap.getString("VacFlag"), SessionHelper.getSession("lang"));			 // 에러게시판 Folder ID
				data.put("VacFlagName", VacFlagName);
				data.put("VacOffFlag", resultMap.getString("VacOffFlag"));
				data.put("startTime", resultMap.getString("startTime"));
				data.put("endTime", resultMap.getString("endTime"));

			} else if ("S".equals(data.getString("ReqType")))//근무정보가져오기
			{
				for(int i=0; i<obj.size(); i++) {
					CoviMap resultMap = (CoviMap) obj.get(i);
					//CoviMap params = new CoviMap();
					String schSeq = resultMap.get("SchSeq").toString();
					if(!"-1".equals(schSeq)) {
						params.put("SchSeq", schSeq);
						CoviMap detailMap = coviMapperOne.selectOne("attend.schedule.getAttendScheduleDetail", params);
						if(detailMap != null) {
							resultMap.put("SchName", detailMap.get("SchName"));

							int dayNum = 0;
							if ("T".equals((String) resultMap.get("Mode"))) { // 기간이 아닌 날짜 선택일 때만 날짜별로 근무시간을 가져옴, 기간 일 때는 기본 시간으로 표시
								String inputDate = resultMap.get("WorkDate").toString();
								Date date = df.parse(inputDate);
								cal.setTime(date);
								dayNum = cal.get(Calendar.DAY_OF_WEEK);
							}
							switch(dayNum){
								case 1:
									resultMap.put("StartTime", detailMap.get("StartSunHour")+""+detailMap.get("StartSunMin"));
									resultMap.put("EndTime", detailMap.get("EndSunHour")+""+detailMap.get("EndSunMin"));
									break ;
								case 2:
									resultMap.put("StartTime", detailMap.get("StartMonHour")+""+detailMap.get("StartMonMin"));
									resultMap.put("EndTime", detailMap.get("EndMonHour")+""+detailMap.get("EndMonMin"));
									break ;
								case 3:
									resultMap.put("StartTime", detailMap.get("StartTueHour")+""+detailMap.get("StartTueMin"));
									resultMap.put("EndTime", detailMap.get("EndTueHour")+""+detailMap.get("EndTueMin"));
									break ;
								case 4:
									resultMap.put("StartTime", detailMap.get("StartWedHour")+""+detailMap.get("StartWedMin"));
									resultMap.put("EndTime", detailMap.get("EndWedHour")+""+detailMap.get("EndWedMin"));
									break ;
								case 5:
									resultMap.put("StartTime", detailMap.get("StartThuHour")+""+detailMap.get("StartThuMin"));
									resultMap.put("EndTime", detailMap.get("EndThuHour")+""+detailMap.get("EndThuMin"));
									break ;
								case 6:
									resultMap.put("StartTime", detailMap.get("StartFriHour")+""+detailMap.get("StartFriMin"));
									resultMap.put("EndTime", detailMap.get("EndFriHour")+""+detailMap.get("EndFriMin"));
									break ;
								case 7:
									resultMap.put("StartTime", detailMap.get("StartSatHour")+""+detailMap.get("StartSatMin"));
									resultMap.put("EndTime", detailMap.get("EndSatHour")+""+detailMap.get("EndSatMin"));
									break ;
								default:
									resultMap.put("StartTime", detailMap.get("AttDayStartTime"));
									resultMap.put("EndTime", detailMap.get("AttDayEndTime"));
									break;

							}

						}
					}
				}
			} else if ("O".equals(data.getString("ReqType")) || "H".equals(data.getString("ReqType"))) {
				CoviMap resultMap = (CoviMap)obj.get(0);
				CoviMap tmpParam = new CoviMap();
				tmpParam.put("UserName", resultMap.get("UrName").toString());
				tmpParam.put("UserCode", resultMap.get("UserCode").toString());
				tmpParam.put("JobDate", resultMap.get("WorkDate").toString());
				tmpParam.put("CompanyCode", resultMap.get("CompanyCode").toString());
				tmpParam.put("ReqType", data.getString("ReqType"));

				CoviMap returnMap = coviMapperOne.selectOne("attend.req_mng.attendanceRealWorkInfo", tmpParam);
				if (returnMap != null) {
					resultMap.put("RealWorkInfo", CoviSelectSet.coviSelectMapJSON(returnMap));
				} else {
					resultMap.put("RealWorkInfo", null);
				}
			}
			resultList.put("reqList",	obj);
		}	
		resultList.put("data",	data);
		return resultList; 
	}

	
	
}
