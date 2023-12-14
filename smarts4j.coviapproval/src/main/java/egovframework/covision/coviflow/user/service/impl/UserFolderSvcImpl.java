package egovframework.covision.coviflow.user.service.impl;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.coviflow.common.util.ComUtils;
import egovframework.covision.coviflow.user.service.UserFolderSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("userFolderSvc")
public class UserFolderSvcImpl extends EgovAbstractServiceImpl implements UserFolderSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	// 사용자별 폴더 리스트 조회
	public CoviMap selectUserFolderList(CoviMap params) throws Exception {
		//
		CoviList list = null;
		if(params.get("mode").equals("all")){
			list = coviMapperOne.list("user.UserFolderList.selectUserFolderList", params);
		}else{
			list = coviMapperOne.list("user.UserFolderList.selectUserFolder1LvList", params);
		}
		CoviMap resultList = new CoviMap();
		resultList.put("list", ComUtils.coviSelectJSONForApprovalList("", list, "FolderID,ParentsID,OwnerID,FolDerName,FolDerMode"));
			//
		return resultList;
	}

	@Override
	public int insertFolderCopy(CoviMap params) throws Exception {
		//
		int cnt = 0;
		if(params.optString("mode").equalsIgnoreCase("TCInfo") || params.optString("mode").equalsIgnoreCase("DeptTCInfo")){ //부서참조함/개인결재참조함
			cnt = coviMapperOne.insert("user.UserFolderList.insertJWF_TCInfoUserfolerlistdescription", params);
			cnt = coviMapperOne.insert("user.UserFolderList.insertJWF_TCInfoUserFolderList", params);
		}else{
			cnt = coviMapperOne.insert("user.UserFolderList.insertJWF_Userfolerlistdescription", params);
			cnt = coviMapperOne.insert("user.UserFolderList.insertJWF_UserFolderList", params);
		}
			cnt = coviMapperOne.update("user.UserFolderList.updateJWF_Userfolerlistdescription", params);
		return cnt;
	}

	@Override
	public int insert(CoviMap params) throws Exception {
		return coviMapperOne.insert("user.UserFolderList.insertUserFolder", params);
	}
	
	@Override
	public int selectDuplicateFolderCnt(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("user.UserFolderList.selectDuplicateFolderCnt", params);
	}

//	// 구분(SubKind) 다국어 처리와 결재단계 표시값 변경 처리를 위한 메소드
//	@SuppressWarnings("unchecked")
//	private CoviList coviSelectJSONForApprovalList(CoviList clist, String str) throws Exception {
//		String [] cols = str.split(",");
//		CoviMap subKindDic = setSubKindDic();
//
//		CoviList returnArray = new CoviList();
//
//		if(null != clist && clist.size() > 0){
//			for(int i=0; i<clist.size(); i++){
//
//				CoviMap newObject = new CoviMap();
//
//				for(int j=0; j<cols.length; j++){
//					Set<String> set = clist.getMap(i).keySet();
//					Iterator<String> iter = set.iterator();
//
//					while(iter.hasNext()){
//						Object ar = iter.next();
//						//String ar = (String)iter.next();
//						if(ar.equals(cols[j].trim())){
//							if(ar.equals("SubKind")){
//								newObject.put(cols[j], subKindDic.getString(clist.getMap(i).getString(cols[j])));
//							}else if(ar.equals("ApprovalStep")){
//								String[] approvalStep = clist.getMap(i).getString(cols[j]).split("_");
//								newObject.put(cols[j], approvalStep[1]+"/"+approvalStep[0]);
//							}else{
//								newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
//							}
//						}
//					}
//				}
//				returnArray.add(newObject);
//			}
//		}
//		return returnArray;
//	}
//
//	//구분 다국어값 가져오는 메소드
//	private CoviMap setSubKindDic() throws Exception{
//		CoviMap rSubKinds = new CoviMap();
//
//		rSubKinds.put("T000", "lbl_apv_app");			//결재 - 결재
//		rSubKinds.put("T021", "lbl_apv_app");			//참조 - 결재
//		rSubKinds.put("T004", "lbl_apv_reject_consent");		//협조 - 개인협조
//		rSubKinds.put("T015", "lbl_apv_reject_consent");		//협조 - 개인협조
//		rSubKinds.put("T005", "lbl_apv_review");		//후결 - 후결
//		rSubKinds.put("SP", "lbl_apv_reading");		//열람 - 열람
//		rSubKinds.put("T006", "lbl_apv_reading");		//열람 - 열람
//		rSubKinds.put("T008", "lbl_apv_charge");		//담당 - 담당
//		rSubKinds.put("T011", "lbl_apv_charge");		//담당 - 담당
//		rSubKinds.put("T012", "lbl_apv_charge");		//담당 - 담당
//		rSubKinds.put("T009", "lbl_apv_consent");		//합의 - 개인합의
//		rSubKinds.put("T010", "lbl_apv_preview");		//예고 - 예고
//		rSubKinds.put("T013", "lbl_apv_cc");				//참조 - 참조
//		rSubKinds.put("T020", "lbl_apv_cc");				//참조 - 참조
//		rSubKinds.put("0", "lbl_apv_cc");					//참조 - 참조
//		rSubKinds.put("T014", "lbl_apv_notice2");		//통지 - 통지
//		rSubKinds.put("T016", "lbl_apv_audit");			//감사 - 감사
//		rSubKinds.put("T017", "lbl_apv_law");			//감사(준법) - 준법
//		rSubKinds.put("T018", "lbl_apv_PublicInspect");		//공람 - 공람
//		rSubKinds.put("T019", "lbl_apv_Confirm");				//확인 - 확인
//		rSubKinds.put("A", "lbl_apv_consult");					//품의함 - 품의함
//		rSubKinds.put("T014", "lbl_apv_notice2");				//통지 - 통지
//		rSubKinds.put("R", "lbl_apv_receive");					//수신 - 수신
//		rSubKinds.put("E", "lbl_apv_receive");					//접수 - 수신
//		rSubKinds.put("REQCMP", "lbl_apv_receive");		//신청처리 - 수신
//		rSubKinds.put("S", "lbl_apv_send");		//발신 - 발신
//		rSubKinds.put("P", "lbl_apv_send");		//발신 - 발신
//		rSubKinds.put("C", "btn_apv_Circulate");		//회람 - 회람
//		rSubKinds.put("2", "btn_apv_Circulate");		//열람 - 회람
//		rSubKinds.put("AS", "btn_apv_redraft");		//재기안(협조기안) - 재기안
//		rSubKinds.put("AD", "btn_apv_redraft");		//재기안(감사기안) - 재기안
//		rSubKinds.put("AE", "btn_apv_redraft");		//재기안(준법기안) - 재기안
//		rSubKinds.put("1", "lbl_apv_cc");				//참조 - 참조
//		rSubKinds.put("T", "lbl_apv_Temporary");			//임시
//		rSubKinds.put("W", "btn_apv_Withdraw");				//회수
//
//		String subKindDicCode = "";
//
//		for(Iterator<String> keys=rSubKinds.keys();keys.hasNext();){
//			subKindDicCode += rSubKinds.getString(keys.next()) + ";";
//		}
//
//		CoviList dicobj = DicHelper.getDicAll(subKindDicCode);
//
//		for(int i=0; i<rSubKinds.size();i++){
//			Iterator<String> keys1=rSubKinds.keys();
//			String key1 = keys1.next();
//
//			for(Iterator<String> keys2=dicobj.getJSONObject(0).keys(); keys2.hasNext();){
//				String key2 = keys2.next();
//				if(rSubKinds.getString(key1).equals(key2)){
//					rSubKinds.remove(key1);
//					rSubKinds.put(key1, dicobj.getJSONObject(0).getString(key2));
//					break;
//				}
//			}
//		}
//
//		return rSubKinds;
//	}

}
