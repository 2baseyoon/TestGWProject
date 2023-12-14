package egovframework.covision.coviflow.user.service.impl;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.FileUtil;
import egovframework.covision.coviflow.common.util.ComUtils;
import egovframework.covision.coviflow.user.service.CommonApprovalListSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("commonApprovalListSvc")
public class CommonApprovalListSvcImpl extends EgovAbstractServiceImpl implements CommonApprovalListSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override 	// 결재함  리스트/그래픽 목록조회
	public CoviMap selectDomainListData(CoviMap params) throws Exception {
		//
		CoviList	list = coviMapperOne.list("user.commonApprovalList.selectDomainListData", params);
		CoviList	domainList 	= CoviSelectSet.coviSelectJSON(list, "DomainDataID,DomainDataName,ProcessID,DomainDataContext");
		CoviMap 	resultList 	= new CoviMap();
		
		for(int i = 0; i < domainList.size(); i++)
		{
			CoviMap domainObject = (CoviMap)domainList.get(i);
			
			if(!domainObject.get("DomainDataContext").equals("")){
				CoviMap apvLineObj = CoviMap.fromObject(domainObject.get("DomainDataContext"));
				
				domainObject.put("DomainDataContext", ComUtils.changeCommentFileInfos(apvLineObj));
			}
		}
		
		resultList.put("list", domainList);
		
		return resultList;
	}

	@Override 	// 결재함  첨부목록 조회
	public CoviMap selectCommFileListData(CoviMap params) throws Exception {
		//
		CoviList	list = coviMapperOne.list("user.commonApprovalList.selectCommFileListData", params);
		CoviMap 	resultList 	= new CoviMap();
		resultList.put("list",FileUtil.getFileTokenArray(CoviSelectSet.coviSelectJSON(list, "FileID,StorageID,ServiceType,ObjectID,ObjectType,MessageID,Version,SaveType,LastSeq,Seq,FilePath,FileName,SavedName,Size,ThumWidth,ThumHeight,Description,RegistDate,UserName,Num,UserCode")));
		return resultList;
	}

	@Override 	//결재함 읽음확인 목록 조회
	public CoviMap selectDocreadHistoryListData(CoviMap params) throws Exception {
		//
		CoviList	list = coviMapperOne.list("user.commonApprovalList.selectDocreadHistoryListData", params);
		CoviMap 	resultList 	= new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DocReadID,UserID,DeptName,UserName,JobTitle,JobLevel,ReadDate,ProcessID,FormInstID,AdminYN"));
		return resultList;
	}

	@Override 	//감사문서함 공통 그룹별 목록 데이터 조회
	public CoviMap selectAdminMnLIstData(CoviMap params) throws Exception {
		//
		CoviList	list = coviMapperOne.list("user.approvalList.selectAdminMnLIstData", params);
		CoviMap 	resultList 	= new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "MenuID,DisplayName,TypeCode"));
		return resultList;
	}
	
	@Override	//docreadhistory 테이블 단일 데이터 조회 - 안읽은 게시물 제목 스타일 변경 처리용
	public int selectSingleDocreadData(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.commonApprovalList.selectSingleDocreadData", params);
	}

	@Override	// 피권한자 권한 조회
	public CoviMap getPersonDirectorOfPerson(CoviMap params) throws Exception {
		CoviMap 	resultList	= new CoviMap();
		int cnt = coviMapperOne.selectOne("user.approvalList.selectPersonOneCount", params);
		
		if(cnt > 0){
			CoviList list = coviMapperOne.list("user.approvalList.selectPersonOne", params);
			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "UserName,UserCode,ViewStartDate,ViewEndDate"));	
		}
		return resultList;
	}
	

	@Override	// 피권한부서 권한 조회
	public CoviList getPersonDirectorOfUnitData(CoviMap params) throws Exception {
		CoviList directorArr = new CoviList();
		CoviList unitDirectorArr = new CoviList();
		//int cnt = coviMapperOne.selectOne("user.deptapprovalList.selectDeptDirectorAllCount", params);
		
		/*
		 * '소속부서'  AS UnitName
			,'all'        AS UnitCode
		 */
		
		CoviList list = coviMapperOne.list("user.deptapprovalList.selectDeptDirector", params);
		directorArr = CoviSelectSet.coviSelectJSON(list, "UnitName,UnitCode,ViewStartDate,ViewEndDate");
		int directorArrLen = directorArr.size();
		
		list = coviMapperOne.list("user.deptapprovalList.selectDeptUnitDirector", params);
		unitDirectorArr = CoviSelectSet.coviSelectJSON(list, "UnitName,UnitCode,ViewStartDate,ViewEndDate");
		
		if(directorArrLen > 0 || !unitDirectorArr.isEmpty()){
			for(Object obj : unitDirectorArr){
				CoviMap unitDirectorObj = (CoviMap) obj;
				for(int i=0; i<directorArrLen; i++){
					CoviMap directorObj = directorArr.getJSONObject(i);
					if(directorObj.optString("UnitCode").equalsIgnoreCase(unitDirectorObj.getString("UnitCode"))){
						break;
					}else if(directorArrLen == i+1){
						directorArr.add(unitDirectorObj);
					}
				}
			}
			
			if(directorArrLen == 0){
				directorArr = unitDirectorArr;
			}
			
			CoviMap tmpObj = new CoviMap();
			tmpObj.put("UnitName", DicHelper.getDic("lbl_apv_BelongDept"));
			tmpObj.put("UnitCode", "all");
			
			directorArr.add(0, tmpObj);
		}
		
		return directorArr;
	}
}
