package egovframework.covision.coviflow.form.service.impl;

import egovframework.baseframework.util.SessionHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.HttpsUtil;

import javax.annotation.Resource;



import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.covision.coviflow.form.service.ApvlineManagerSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


@Service("apvlinemanagerService")
public class ApvlineManagerSvcImpl extends EgovAbstractServiceImpl implements ApvlineManagerSvc {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap selectPrivateDomainList(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList list = coviMapperOne.list("form.apvlinemanager.selectPrivateDomainList", params);

		returnList.put("list",CoviSelectSet.coviSelectJSON(list, "PrivateDomainDataID,DisplayName,Abstract,Description,PrivateContext,DefaultYN"));
		
		return returnList;
	}

	@Override
	public int deletePrivateDomain(CoviMap params) {
		return coviMapperOne.delete("form.apvlinemanager.deletePrivateDomain",params);
	}

	@Override
	public CoviMap selectDistributionList(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList list = coviMapperOne.list("form.apvlinemanager.selectDistributionList", params);

		returnList.put("list",CoviSelectSet.coviSelectJSON(list, "GroupID,GroupCode,GroupName,Description"));
		
		return returnList;
	}

	@Override
	public int updatePrivateDomain(CoviMap params) throws Exception {
		return coviMapperOne.update("form.apvlinemanager.updatePrivateDomain",params);
	}

	@Override
	public CoviMap selectPrivateDistribution(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList list = coviMapperOne.list("form.apvlinemanager.selectPrivateDistributionList", params);

		returnList.put("list",CoviSelectSet.coviSelectJSON(list, "GroupID,Type,DisplayName,OwnerID"));
		
		return returnList;
	}

	@Override
	public CoviMap selectPrivateDistributionMember(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList list = coviMapperOne.list("form.apvlinemanager.selectPrivateDistributionMember", params);

		returnList.put("list",CoviSelectSet.coviSelectJSON(list, "GroupMemberID,GroupID,Type,ReceiptID,ReceiptName,ReceiptDeptID,ReceiptDeptName,DNName,HasChild,SortKey"));
		
		return returnList;
	}

	@Override
	public int deletePrivateDistribution(CoviMap params) throws Exception {
		int cnt = 0;
		cnt += coviMapperOne.delete("form.apvlinemanager.deletePrivateDistribution",params);
		cnt += coviMapperOne.delete("form.apvlinemanager.deletePrivateDistributionMember",params);
		return cnt;
	}

	@Override
	public int deletePrivateDistributionMemberData(CoviMap params) throws Exception {
		return coviMapperOne.delete("form.apvlinemanager.deletePrivateDistributionMemberData",params);
	}

	@Override
	public CoviMap selectDistributionMember(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList list = coviMapperOne.list("form.apvlinemanager.selectDistributionMember", params);

		returnList.put("list",CoviSelectSet.coviSelectJSON(list, "Code,Name"));
		
		return returnList;
	}

	@Override
	public int updatePrivateDomainDefaultY(CoviMap params) throws Exception{
		int cnt = coviMapperOne.update("form.apvlinemanager.updataPrivateDomainDefaultN",params);
		cnt += coviMapperOne.update("form.apvlinemanager.updataPrivateDomainDefaultY",params);
		return cnt;
	}

	@Override
	public int updatePrivateDomainDefaultN(CoviMap params) throws Exception{
		return coviMapperOne.update("form.apvlinemanager.updataPrivateDomainDefaultN",params);
	}

	@Override
	public CoviMap selectAbsentMember(CoviMap params) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviList list = coviMapperOne.list("form.apvlinemanager.checkAbsentMember", params);
		returnList.put("list",CoviSelectSet.coviSelectJSON(list, "PERSON_CODE,PERSON_ID,DISPLAY_NAME,UNIT_CODE,UNIT_NAME,JOBTITLE_Z,JOBLEVEL_Z,JOBPOSITION_Z,ENT_CODE"));
		
		return returnList;
	}

	@Override
	public CoviMap selectAbsentGroup(CoviMap params) throws Exception{
		CoviMap returnList = new CoviMap();
		CoviList list = coviMapperOne.list("form.apvlinemanager.checkAbsentGroup", params);
		returnList.put("list",list);
		
		return returnList;
	}

	@Override
	public int insertPrivateDomainData(CoviMap params) throws Exception {
		return coviMapperOne.insert("form.apvlinemanager.insertPrivateDomainData", params);
	}

	@Override
	public int insertPrivateDistribution(CoviMap params) throws Exception{
		return coviMapperOne.insert("form.apvlinemanager.insertPrivateDistribution", params);
	}

	@Override
	public int insertPrivateDistributionMember(CoviMap params2) throws Exception {
		return coviMapperOne.insert("form.apvlinemanager.insertPrivateDistributionMember", params2);
	}

	@Override
	public int selectApvlineAuth(CoviMap params) {
		return (int) coviMapperOne.getNumber("form.apvlinemanager.selectApvlineAuth", params);
	}

	@Override
	public CoviMap selectPrivateGovDistributionMember(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList list = coviMapperOne.list("form.apvlinemanager.selectPrivateGovDistributionMember", params);

		if(list.size() > 0) {
			returnList.put("list",CoviSelectSet.coviSelectJSON(list, "OUCODE,OUORDER,UCORGFULLNAME,OU,TOPOUCODE,DN,REPOUCODE,PARENTOUCODE,PARENTOUNAME,OULEVEL,ISUSE,USEYN,UCCHIEFTITLE,DISPLAY_UCCHIEFTITLE,HASSUBOU,AN,OUSTEP"));
		} else {
			list = coviMapperOne.list("form.apvlinemanager.selectPrivateGov24DistributionMember", params);
			
			returnList.put("list", CoviSelectSet.coviSelectJSON(list, "ORGCD,CMPNYNM,SENDERNM,BIZNO,ADRES,DELETEFLAG,HASSUBOU,PARENTOUCODE,AN,DN,OUSTEP,DISPLAY_UCCHIEFTITLE"));
		}
		
		return returnList;
	}

	@Override
	public CoviMap selectDistributionMemberList(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList list = coviMapperOne.list("form.apvlinemanager.selectDistributionMemberList", params);

		returnList.put("list",CoviSelectSet.coviSelectJSON(list, "GroupMemberID,GroupID,Type,ReceiptID,ReceiptName,ReceiptDeptID,ReceiptDeptName,DNName,HasChild,SortKey"));
		
		return returnList;
	}
	
	// 문서 내 결재선 임직원/부서 자동완성 목록 조회
	@Override
	public CoviMap selectAddInLineAutoSearchList(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		
		String useAffiliateSearch = SessionHelper.getSession("DN_Code").equals("ORGROOT") ? "Y" : RedisDataUtil.getBaseConfig("useAffiliateSearch");

		if(StringUtil.replaceNull(useAffiliateSearch,"").equals("N")){
			params.put("companyCode", SessionHelper.getSession("DN_Code"));	
        }
		
		CoviList list = coviMapperOne.list("form.apvlinemanager.selectAddInLineAutoSearchList", params);

		returnList.put("list",CoviSelectSet.coviSelectJSON(list, "itemType,AN,DN,LV,TL,PO,RG,RGNM,ETID,ETNM,EM"));
		
		return returnList;
	}

	//의견 댓글 조회
	@Override
	public CoviMap selectDocCommentList(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList list = coviMapperOne.list("form.apvlinemanager.selectDocCommentList", params);
		
		returnList.put("list",list);
		
		return returnList;
	}

	//의견 댓글 추가
	@Override
	public int addDocComment(CoviMap params) throws Exception {
		return coviMapperOne.insert("form.apvlinemanager.addDocComment",params);
	}
	
	//댓글 알림
	public void setCommentMessage(CoviMap formObj) throws Exception {
		CoviList messageInfos = new CoviList();

		String status = "COMMENT";
		
		CoviMap messageInfo = new CoviMap();
				
		messageInfo.put("UserId", formObj.getString("Initiator"));
		messageInfo.put("Initiator", formObj.getString("Initiator"));
		messageInfo.put("SenderID", SessionHelper.getSession("USERID")); //발신자
		messageInfo.put("Status", status); 
		messageInfo.put("ProcessId", formObj.getString("ProcessID")); 
		messageInfo.put("WorkitemId", formObj.getString("WorkitemId"));
		messageInfo.put("FormInstId", formObj.getString("FormInstID"));
		messageInfo.put("Type", "UR");
		messageInfo.put("Comment", ComUtils.RemoveScriptAndStyle(formObj.getString("Comment")));
			
		messageInfos.add(messageInfo);
		
		// 알림발송
		String approvalURL = PropertiesUtil.getGlobalProperties().getProperty("smart4j.path") +	"/approval"; 
		String httpCommURL = approvalURL + "/legacy/setmessage.do";
		
		if(!messageInfos.isEmpty()) {
			CoviMap params2 = new CoviMap(); 
			params2.put("MessageInfo",  messageInfos);
			
			HttpsUtil httpsUtil = new HttpsUtil();
			httpsUtil.httpsClientWithRequest(httpCommURL, "POST", params2, "UTF-8",  null);	
		}
	}
	
	//의견 댓글의 덧글 추가
	@Override
	public int addDocCommentReply(CoviMap params) throws Exception {
		return coviMapperOne.insert("form.apvlinemanager.addDocCommentReply",params);
	}
	
	//대댓글 정렬
	@Override
	public int updateDocCommentSort(CoviMap params) throws Exception {
		return coviMapperOne.insert("form.apvlinemanager.updateDocCommentSort",params);
	}

	//덧글 카운트 증가
	@Override
	public int updateCommentRelpyCnt(String CommentID) throws Exception {
		return coviMapperOne.update("form.apvlinemanager.updateCommentRelpyCnt",CommentID);
	}

	//댓글 수정
	@Override
	public int modifyDocComment(CoviMap params) throws Exception {
		return coviMapperOne.update("form.apvlinemanager.modifyDocComment",params);
	}

	//댓글 삭제
	@Override
	public int delDocComment(String CommentID) throws Exception {
		return coviMapperOne.delete("form.apvlinemanager.delDocComment",CommentID);
	}

	@Override
	public int delRelayCount(CoviMap params) throws Exception {
		return coviMapperOne.update("form.apvlinemanager.delRelpyCnt",params);
	}
	
}
