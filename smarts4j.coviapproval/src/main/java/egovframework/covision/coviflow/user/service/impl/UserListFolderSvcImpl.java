package egovframework.covision.coviflow.user.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.coviflow.common.util.ComUtils;
import egovframework.covision.coviflow.user.service.UserListFolderSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("userListFolderSvc")
public class UserListFolderSvcImpl extends EgovAbstractServiceImpl implements UserListFolderSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	// 사용자별 폴더 리스트 조회
	public CoviMap selectUserFolderList(CoviMap params) throws Exception {
		//
		CoviList list = null;
		list = coviMapperOne.list("user.UserListFolder.selectUserFolderList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, "FolderID,ParentsID,OwnerID,FolDerName,FolDerMode,RegDate"));
		//
		return resultList;
	}

	@Override
	//개인폴더 목록 데이터 조회
	public CoviMap selectUserFolderDataList(CoviMap params) throws Exception {
		
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		CoviList 	list = null;
		int cnt = 0;
		
		String strCountQuery = "";
		String strListQuery = "";
		String strListCol = "";
		if(params.get("folderMode").equals("A")){ // 개인폴더관리
			strCountQuery = "user.UserListFolder.selectFolderListCnt";
			strListQuery = "user.UserListFolder.selectFolderList";
			strListCol = "FolderID,ParentsID,OwnerID,FolDerName,FolDerMode,RegDate";
		}else{ // 사용자가 생성한 폴더 리스트함
			strCountQuery = "user.UserListFolder.selectFolderIDListCnt";
			strListQuery = "user.UserListFolder.selectFolderIDList";
			strListCol = "FolderID,ParentsID,OwnerID,FolDerName,FolDerMode,FolderListID,RegDate,InitiatorID,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserFolderListDescriptionID,ProcessID,FormInstID,FormID,FormName,FormSubject,IsSecureDoc,IsFile,FileExt,IsComment,ApproverCode,ApproverName,ApprovalStep,ApproverSIPAddress,IsReserved,ReservedGubun,ReservedTime,Priority,IsModify,Reserved1,Reserved2";
		}
		
		cnt = (int) coviMapperOne.getNumber(strCountQuery, params);
		
		page = egovframework.coviframework.util.ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		list = coviMapperOne.list(strListQuery, params);
		
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, strListCol));
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public int update(CoviMap params) throws Exception {
		return coviMapperOne.update("user.UserListFolder.updateUserFolder", params);
	}

	@Override
	public int updateUserFolderMove(CoviMap params) throws Exception {
		return coviMapperOne.update("user.UserListFolder.updateUserFolderMove", params);
	}

	@Override
	public int deleteUserFolderList(CoviMap params) throws Exception {
		//
		int cnt = 0;
		if(params.get("folderMode").equals("A")){ // 개인폴더관리 삭제
			if(params.get("parentId").equals("0")){ // 1레벨 폴더를 삭제할경우
				cnt = coviMapperOne.update("user.UserListFolder.update1LvJWF_UserFolderList", params);
				cnt = coviMapperOne.update("user.UserListFolder.update1LvJWF_UserFolder", params);
			}else{ // 2레벨 폴더를 삭제 할경우
				cnt = coviMapperOne.update("user.UserListFolder.update2LvJWF_UserFolderList", params);
				cnt = coviMapperOne.update("user.UserListFolder.update2LvJWF_UserFolder", params);
			}
		}else{ // 생성된 폴더에 선택한함 삭제
			cnt = coviMapperOne.update("user.UserListFolder.update2LvJWF_UserFolderList", params);
		}
		return cnt;
	}
	
	@Override
	public int selectUserFolderAuth(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("user.UserListFolder.selectUserFolderAuth", params);
	}
}
