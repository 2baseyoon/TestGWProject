package egovframework.covision.groupware.portal.user.service.impl;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.sec.AES;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.portal.user.service.PNPortalSvc;

@Service("PNPortalService")
public class PNPortalSvcImpl extends EgovAbstractServiceImpl implements PNPortalSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	public int saveUserPortalOption(CoviMap params) throws Exception{
		return coviMapperOne.insert("pn.portal.saveUserPortalOption", params);
	}
	
	public String selectUserPortalOption(CoviMap params) throws Exception{
		return coviMapperOne.selectOne("pn.portal.selectUserPortalOption", params);
	}
	
	@Override
	public CoviList selectProfileImagePath(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("pn.portal.selectProfileImagePath", params);
		return CoviSelectSet.coviSelectJSON(list, "UserCode,MailAddress,PhotoPath");
	}
	
	//링크사이트 게시글 조회
	@Override
	public CoviMap selectRollingBannerBoardList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviList list = coviMapperOne.list("pn.portal.selectRollingBannerBoardList",params);
		resultList.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,Version,FolderID,MenuID,Subject,BodyText,RegistDate,CreatorCode,OwnerCode,CreateDate,BannerTitle,BannerSubTitle,BannerText,BannerImageOption,BannerBoardOption,BannerOpenOption,BannerLinkOption,LinkURL,SortKey,ServiceType,FilePath,SavedName,FullPath"));
		return resultList;
	}
	
	@Override
	public CoviMap getApprovalList(CoviMap params) throws Exception {
		CoviMap returnList = new CoviMap();
		CoviList list = new CoviList();
		
		list = coviMapperOne.list("pn.portal.selectApprovalList", params);
		returnList.put("approval",  CoviSelectSet.coviSelectJSON(list, "ProcessID,WorkItemID,PerformerID,FormInstID,ProcessDescriptionID,FormSubject,FormPrefix,FormID,InitiatorID,InitiatorName,UserCode,UserName,FormSubKind,Created,TaskID,PhotoPath,DomainDataContext,SchemaContext,BusinessData1,BusinessData2,IsFile,IsComment,ProcessName"));
		
		//draftkey 추가
		AES aes = new AES("", "N");
		CoviList ResultListArr = (CoviList)returnList.get("approval");
        for(Object obj : ResultListArr){
            CoviMap ResultListobj = (CoviMap)obj;
            if(ResultListobj.has("FormInstID") && ResultListobj.has("WorkItemID") && ResultListobj.has("ProcessID") && ResultListobj.has("TaskID")){
            	String draftkey = ResultListobj.getString("FormInstID") +  "@" + ResultListobj.getString("WorkItemID") +  "@" + ResultListobj.getString("ProcessID") +  "@" + ResultListobj.getString("TaskID");
            	ResultListobj.put("formDraftkey", aes.encrypt(draftkey));
            }
        }
		
		list = coviMapperOne.list("pn.portal.selectProcessList", params);
		returnList.put("process", CoviSelectSet.coviSelectJSON(list, "ProcessID,WorkItemID,PerformerID,FormInstID,ProcessDescriptionID,FormSubject,FormPrefix,FormID,InitiatorID,InitiatorName,UserCode,UserName,FormSubKind,StartDate,Finished,TaskID,DomainDataContext,PhotoPath,BusinessData1,BusinessData2,IsFile,IsComment"));
		
		return returnList;
	}
	
	public CoviMap getApprovalListCode(CoviMap params, String businessData1) throws Exception {		
		// 통합결재에 포함되는 타 시스템 코드
		List<String> bizDataList = new ArrayList<String>();

		// 전자결재 포함유무
		if(StringUtil.isBlank(businessData1) || businessData1.equalsIgnoreCase("APPROVAL")) {
			params.put("isApprovalList", "Y");
			
			bizDataList.add("");
			bizDataList.add("APPROVAL");
			
			// 통합결재 사용유무
			if(RedisDataUtil.getBaseConfig("useTotalApproval").equalsIgnoreCase("Y")) {
				CoviList TotalApprovalListType = RedisDataUtil.getBaseCode("TotalApprovalListType"); // 통합결재에 표시할 타시스템
				
				for (int i = 0; i < TotalApprovalListType.size(); i++) {
					// 사용여부 Y 인 경우
					if(TotalApprovalListType.getJSONObject(i).getString("IsUse").equalsIgnoreCase("Y")) {
						bizDataList.add(TotalApprovalListType.getJSONObject(i).getString("Code"));
					}
				}	
			}
		} else {
			params.put("isApprovalList", "N");
			bizDataList.add(businessData1);
			
			params.put("businessData1", businessData1);
		}
		params.put("bizDataList", bizDataList);
		
		return params;
	}
	
	@Override
	public CoviMap selectBoardMessageList(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		CoviList list = coviMapperOne.list("pn.portal.selectBoardMessageList",params);
		result.put("list",CoviSelectSet.coviSelectJSON(list, "MenuID,FolderName,FolderID,Subject,Version,MessageID,FolderName,CreateDate,CreatorCode,CreatorName,UseIncludeRecentReg,RecentlyDay,IsRead,FileID"));
		return result;
	}
	
	@Override
	public CoviList selectLastestUsedFormList(CoviMap params) throws Exception {
		CoviList resultList = new CoviList();
		CoviList list = coviMapperOne.list("pn.portal.selectLastUsedFormList", params);
		resultList = CoviSelectSet.coviSelectJSON(list, "ProcessID,PerformerID,WorkitemID,FormPrefix,InitiatorID,InitiatorName,InitiatorName,InitiatorUnitID,InitiatorUnitName,UserCode,UserName,SubKind,FormSubKind,FormID,FormName,EndDate,RealEndDate,TYPE");		
		return resultList;
	}
	
	@Override
	public CoviMap selectSystemLinkBoardList(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		CoviList list = coviMapperOne.list("pn.portal.selectSystemLinkBoardList",params);
		result.put("list",CoviSelectSet.coviSelectJSON(list, "MessageID,Version,FolderID,MenuID,Subject,CodeName,MultiCodeName,BodyText,LinkURL,Reserved1,RegistDate,CreatorCode,OwnerCode,CreateDate,OpenType,ServiceType,FilePath,SavedName,FullPath"));
		return result;
	}
	
	@Override
	public CoviMap setWebpartThumbnailList(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		CoviList list = coviMapperOne.list("pn.portal.setWebpartThumbnailList",params);
		result.put("list",CoviSelectSet.coviSelectJSON(list, "WebpartID,WebpartName,Thumbnail"));
		return result;
	}

	@Override
	public int selectUserRewardVacDay(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("pn.portal.selectUserRewardVacDay", params);
	}
	
	@Override
	public int selectSiteLinkListCnt(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("pn.portal.selectSiteLinkListCnt", params);
	}
	
	@Override
	public CoviMap selectSiteLinkList(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		CoviList list = coviMapperOne.list("pn.portal.selectSiteLinkList", params);
		result.put("list", CoviSelectSet.coviSelectJSON(list, "SiteLinkID,UserCode,SiteLinkName,SiteLinkURL,SortKey,Thumbnail"));
		return result;
	}
	
	@Override
	public CoviMap selectSiteLinkData(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		CoviList list = coviMapperOne.list("pn.portal.selectSiteLinkData", params);
		result.put("list", CoviSelectSet.coviSelectJSON(list, "SiteLinkID,UserCode,SiteLinkName,SiteLinkURL,SortKey,Thumbnail"));
		return result;
	}
	
	@Override
	public int insertSiteLink(CoviMap params) throws Exception {
		return (int) coviMapperOne.insert("pn.portal.insertSiteLink", params);
	}
	
	@Override
	public int updateSiteLink(CoviMap params) throws Exception {
		return (int) coviMapperOne.update("pn.portal.updateSiteLink", params);
	}
	
	@Override
	public int deleteSiteLink(CoviMap params) throws Exception {
		return (int) coviMapperOne.delete("pn.portal.deleteSiteLink", params);
	}
	
	@Override
	public CoviMap selectCommentList(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		CoviList list = coviMapperOne.list("pn.portal.selectCommentList", params);
		result.put("list", CoviSelectSet.coviSelectJSON(list, "CommentID,MemberOf,TargetServiceType,TargetID,Comment,Context,LikeCount,ReplyCount,RegisterCode,RegistDate,DeleteDate,Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,MyLikeCount"));
		return result;
	}
	
	@Override
	public CoviMap selectPasswordPolicy(CoviMap params) throws Exception {
		CoviMap result = coviMapperOne.select("pn.portal.selectPasswordPolicy", params);		
		
		return result;
	}
	
	@Override
	public String selectPwChangeDate(CoviMap params) throws Exception {
		return coviMapperOne.selectOne("pn.portal.selectPwChangeDate", params);
	}
	
}
