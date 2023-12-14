package egovframework.covision.coviflow.admin.service.impl;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.DicHelper;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.ListAdminSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;



@Service("listAdminSvc")
public class ListAdminSvcImpl extends EgovAbstractServiceImpl implements ListAdminSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public CoviMap getEntinfototalListData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("admin.listadmin.selectEntinfototalListData", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DN_ID,DisplayName,sortkey,DN_Code"));
		return resultList;
	}

	@Override
	public CoviMap selectListAdminData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.listadmin.selectListAdminDataCnt", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);
		list = coviMapperOne.list("admin.listadmin.selectListAdminData", params);
		
		resultList.put("list", coviSelectJSONForListAdmin(list, "FormID,SubJect,FormName,PiName,PiDscr,FormInstID,InitiatorName,InitiatorID,InitiatorUnitID,InitiatorUnitName,PiID,PiState,PfID,PfPerFormerID,PfPerFormerName,PfSubKind,BusinessState,PiBusinessDate1,PiBusinessDate2,DocNo,WiBusinessDate1,WiBusinessDate2,WorkDt,WiID,PiFinished,InitiatorSIPAddress,FormPrefix,PiStarted,PiDeletedDate,EntCode,ProcessID,FormSubject,IsArchived,CompletedDate,InitiatedDate,BusinessData1,BusinessData2"));
		resultList.put("page", pagingData);
		
		return resultList;
	}
	
	@Override
	public CoviMap selectListAdminData_Store(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap pagingData = null;
		CoviList list = null;
		int listCnt = (int) coviMapperOne.getNumber("admin.listadmin.selectListAdminDataCnt_Store", params);
		
		pagingData = ComUtils.setPagingData(params, listCnt);
		params.addAll(pagingData);		
		list = coviMapperOne.list("admin.listadmin.selectListAdminData_Store", params);
		
		resultList.put("list", coviSelectJSONForListAdmin(list, "FormID,SubJect,FormName,PiName,PiDscr,FormInstID,InitiatorName,InitiatorID,InitiatorUnitID,InitiatorUnitName,PiID,PiState,PfID,PfPerFormerID,PfPerFormerName,PfSubKind,BusinessState,PiBusinessDate1,PiBusinessDate2,DocNo,WiBusinessDate1,WiBusinessDate2,WorkDt,WiID,PiFinished,InitiatorSIPAddress,FormPrefix,PiStarted,PiDeletedDate,EntCode,ProcessID,FormSubject,IsArchived,CompletedDate,InitiatedDate"));
		resultList.put("page", pagingData);
		
		return resultList;
	}

	@Override
	public CoviMap selectDocumentInfo(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.listadmin.selectDocumentInfo", params);
		CoviMap resultList = new CoviMap();
		resultList.put("map", coviSelectJSONForMapAdmin(map, "FormID,SubJect,FormName,PiName,PiDscr,FormInstID,InitiatorName,InitiatorID,InitiatorUnitID,InitiatorUnitName,PiID,PiState,PfID,PfPerFormerID,PfPerFormerName,PfSubKind,BusinessState,PiBusinessDate1,PiBusinessDate2,DocNo,WiBusinessDate1,WiBusinessDate2,WorkDt,WiID,PiFinished,InitiatorSIPAddress,FormPrefix,PiStarted,PiDeletedDate,FormSubject,BodyType,BodyContext,DocLinks,CompletedDate,InitiatedDate,IsSecureDoc,DocYn,AttachFileInfo,ExtInfo"));
		return resultList;
	}


	// 구분(SubKind) 다국어 처리와 결재단계 표시값 변경 처리를 위한 메소드
	@SuppressWarnings("unchecked")
	private CoviList coviSelectJSONForMapAdmin(CoviMap map, String str) throws Exception {
		String [] cols = str.split(",");
		CoviMap subKindDic = setSubKindDic();

		CoviList returnArray = new CoviList();

		CoviMap newObject = new CoviMap();

		for(int j=0; j<cols.length; j++){
			Set<String> set = map.keySet();
			Iterator<String> iter = set.iterator();

			while(iter.hasNext()){
				Object ar = iter.next();
				if(ar.equals(cols[j].trim())){
					if(ar.equals("SubKind")){
						newObject.put(cols[j], subKindDic.getString(map.getString(cols[j])));
					}else if(ar.equals("ApprovalStep")){
						String[] approvalStep = map.getString(cols[j]).split("_");
						newObject.put(cols[j], approvalStep[1]+"/"+approvalStep[0]);
					}else if(ar.equals("PiState")){
						newObject.put(cols[j], subKindDic.getString(map.getString(cols[j])));
					}else if(ar.equals("BusinessState")){
						newObject.put(cols[j], subKindDic.getString(map.getString(cols[j])));
					}else if(ar.equals("IsSecureDoc")){
						newObject.put(cols[j], subKindDic.getString(map.getString(cols[j])));
					}else{
						newObject.put(cols[j], map.getString(cols[j]));
					}
				}
			}
		}
		returnArray.add(newObject);
		return returnArray;
	}

	// 구분(SubKind) 다국어 처리와 결재단계 표시값 변경 처리를 위한 메소드
	@SuppressWarnings("unchecked")
	private CoviList coviSelectJSONForListAdmin(CoviList clist, String str) throws Exception {
		String [] cols = str.split(",");
		CoviMap subKindDic = setSubKindDic();

		CoviList returnArray = new CoviList();

		if(null != clist && !clist.isEmpty()){
			for(int i=0; i<clist.size(); i++){

				CoviMap newObject = new CoviMap();

				for(int j=0; j<cols.length; j++){
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();

					while(iter.hasNext()){
						Object ar = iter.next();
						if(ar.equals(cols[j].trim())){
							if(ar.equals("SubKind")){
								newObject.put(cols[j], subKindDic.getString(clist.getMap(i).getString(cols[j])));
							}else if(ar.equals("ApprovalStep")){
								String[] approvalStep = clist.getMap(i).getString(cols[j]).split("_");
								newObject.put(cols[j], approvalStep[1]+"/"+approvalStep[0]);
							}else if(ar.equals("PiState")){
								newObject.put(cols[j], subKindDic.getString(clist.getMap(i).getString(cols[j])));
							}else if(ar.equals("BusinessState")){
								newObject.put(cols[j], subKindDic.getString(clist.getMap(i).getString(cols[j])));
							}else{
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

	//구분 다국어값 가져오는 메소드
	@SuppressWarnings("unchecked")
	private CoviMap setSubKindDic() throws Exception{
		CoviMap rSubKinds = new CoviMap();

		rSubKinds.put("T000", "lbl_apv_app");			//결재 - 결재
		rSubKinds.put("T021", "lbl_apv_app");			//참조 - 결재
		rSubKinds.put("T004", "lbl_apv_reject_consent");		//협조 - 개인협조
		rSubKinds.put("T015", "lbl_apv_reject_consent");		//협조 - 개인협조
		rSubKinds.put("T005", "lbl_apv_review");		//후결 - 후결
		rSubKinds.put("SP", "lbl_apv_reading");		//열람 - 열람
		rSubKinds.put("T006", "lbl_apv_reading");		//열람 - 열람
		rSubKinds.put("T008", "lbl_apv_charge");		//담당 - 담당
		rSubKinds.put("T011", "lbl_apv_charge");		//담당 - 담당
		rSubKinds.put("T012", "lbl_apv_charge");		//담당 - 담당
		rSubKinds.put("T009", "lbl_apv_consent");		//합의 - 개인합의
		rSubKinds.put("T010", "lbl_apv_preview");		//예고 - 예고
		rSubKinds.put("T013", "lbl_apv_cc");				//참조 - 참조
		rSubKinds.put("T020", "lbl_apv_cc");				//참조 - 참조
		rSubKinds.put("0", "lbl_apv_cc");					//참조 - 참조
		rSubKinds.put("T014", "lbl_apv_notice2");		//통지 - 통지
		rSubKinds.put("T016", "lbl_apv_audit");			//감사 - 감사
		rSubKinds.put("T017", "lbl_apv_law");			//감사(준법) - 준법
		rSubKinds.put("T018", "lbl_apv_PublicInspect");		//공람 - 공람
		rSubKinds.put("T019", "lbl_apv_Confirm");				//확인 - 확인
		rSubKinds.put("A", "lbl_apv_consult");					//품의함 - 품의함
		rSubKinds.put("R", "lbl_apv_receive");					//수신 - 수신
		rSubKinds.put("E", "lbl_apv_receive");					//접수 - 수신
		rSubKinds.put("REQCMP", "lbl_apv_receive");		//신청처리 - 수신
		rSubKinds.put("S", "lbl_apv_send");		//발신 - 발신
		rSubKinds.put("P", "lbl_apv_send");		//발신 - 발신
		rSubKinds.put("C", "btn_apv_Circulate");		//회람 - 회람
		rSubKinds.put("2", "btn_apv_Circulate");		//열람 - 회람
		rSubKinds.put("AS", "btn_apv_redraft");		//재기안(협조기안) - 재기안
		rSubKinds.put("AD", "btn_apv_redraft");		//재기안(감사기안) - 재기안
		rSubKinds.put("AE", "btn_apv_redraft");		//재기안(준법기안) - 재기안
		rSubKinds.put("1", "lbl_apv_cc");				//참조 - 참조
		rSubKinds.put("T", "lbl_apv_Temporary");			//임시
		rSubKinds.put("W", "btn_apv_Withdraw");				//회수
		
		
		rSubKinds.put("288", "lbl_apv_Processing");				//진행
		rSubKinds.put("528", "TaskActType_CO");				//완료
		rSubKinds.put("546", "lbl_apv_setschema_99");				//기안취소
		rSubKinds.put("275", "Messaging_Error");				//오류
		rSubKinds.put("02_01_", "TodoMsgType_Approval_Doc");				//승인
		rSubKinds.put("02_02_", "TodoMsgType_TaskReject");				//반려
		rSubKinds.put("-", "-");				// -
		rSubKinds.put("N", "일반");				// 관리자-결재문서관리툴 기밀여부 일반
		rSubKinds.put("Y", "기밀");				// 관리자-결재문서관리툴 기밀여부 기밀

		StringBuilder  subKindDicCode = new StringBuilder();
		
		for(Iterator<String> keys=rSubKinds.keys();keys.hasNext();){
			subKindDicCode.append(rSubKinds.getString(keys.next()) + ";");
		}

		CoviList dicobj = DicHelper.getDicAll(subKindDicCode.toString());

		Iterator<String> keys1 = rSubKinds.keys();
		while(keys1.hasNext()) {
			String key1 = keys1.next();
			
			String dicKey = rSubKinds.getString(key1);
			String dicVal = dicobj.getJSONObject(0).getString(dicKey);
			if(dicVal != null && !dicVal.equals("")) {
				rSubKinds.put(key1, dicVal);
			}
		}

		return rSubKinds;
	}

	// 전자결재 리스트 조회 조건 가져오는 메소드
	// APPROVAL, ACCOUNT 등..
	public CoviMap getApprovalListCode(CoviMap params, String businessData1) throws Exception {		
		// 통합결재에 포함되는 타 시스템 코드
		List<String> bizDataList = new ArrayList<>();

		// 전자결재 포함유무
		if(StringUtil.isBlank(businessData1) || businessData1.equalsIgnoreCase("APPROVAL")) {
			params.put("isApprovalList", "Y");
			
			// 통합결재 사용유무
			if(RedisDataUtil.getBaseConfig("useTotalApproval").equalsIgnoreCase("Y")) {
				CoviList totalApprovalListType = RedisDataUtil.getBaseCode("TotalApprovalListType"); // 통합결재에 표시할 타시스템
				
				for (int i=0; i< totalApprovalListType.size(); i++) {
					// 사용여부 Y 인 경우
					if(totalApprovalListType.getJSONObject(i).optString("IsUse").equalsIgnoreCase("Y")) {
						bizDataList.add(totalApprovalListType.getJSONObject(i).getString("Code"));
					}
				}	
			}
		}
		else {
			params.put("isApprovalList", "N");
			params.put("businessData1", businessData1);
			bizDataList.add(businessData1);
		}
		params.put("bizDataList", bizDataList);
		
		return params;
	}
}
