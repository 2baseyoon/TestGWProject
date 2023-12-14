package egovframework.covision.coviflow.common.service.impl;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.coviflow.common.service.EdmsTransferSvc;


@Service("edmsTransferService")
public class EdmsTransferSvcImpl extends EgovAbstractServiceImpl implements EdmsTransferSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	public static final int STATUS_READY = 0; // 대기
	public static final int STATUS_PROGRESS = 1; // 작업중
	public static final int STATUS_PDF_COMPLETE = 3; // PDF 변환완료
	public static final int STATUS_COMPLETE = 5; // 이관데이터 생성완료
	public static final int STATUS_TRANSFER_COMPLETE = 2; // 최종이관 완료
	public static final int STATUS_ERROR = 9; // 오류
	
	@Override
	public CoviList getEdmsTrasferTarget() throws Exception{
		CoviList list = coviMapperOne.list("form.edmstransfer.getEdmsTrasferTarget", new CoviMap());
		return CoviSelectSet.coviSelectJSON(list, "DocId,DraftId,ProcessId,EndFlag,FlagDate,DNID,DN_Code");
	}

	@Override
	public int setFlagMulti(CoviMap param) throws Exception{
		return coviMapperOne.update("form.edmstransfer.updateFlagMulti", param);
	}
	
	@Override
	public int setFlag(CoviMap param) throws Exception{
		return coviMapperOne.update("form.edmstransfer.updateFlag", param);
	}
}
