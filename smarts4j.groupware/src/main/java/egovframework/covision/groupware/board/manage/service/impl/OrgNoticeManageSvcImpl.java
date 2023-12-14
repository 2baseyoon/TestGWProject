package egovframework.covision.groupware.board.manage.service.impl;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Stack;

import javax.annotation.Resource;










import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.covision.groupware.board.manage.service.OrgNoticeManageSvc;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("OrgNoticeManageSvc")
public class OrgNoticeManageSvcImpl extends EgovAbstractServiceImpl implements  OrgNoticeManageSvc{
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Autowired
	private FileUtilService fileSvc;
	
	public CoviMap getOrgFolderPath(CoviMap params) throws Exception {
		return coviMapperOne.select("manage.orgnotice.getNoticeFolderPath", params);
		
	}
	/**
	 * 그리드에 사용할 데이터 Select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getOrgNoticeList(CoviMap params) throws Exception {
		
		CoviMap cmap = new CoviMap();
		CoviList list			= new CoviList();
		CoviMap page=null;
		int cnt	= 0;

		if (params.get("pageNo") != null && params.get("pageSize") != null){
			cnt = (int) coviMapperOne.getNumber("manage.orgnotice.getOrgNoticeListCount" , params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}	
		
		cmap.put("page", page);
		cmap.put("list",coviMapperOne.list("manage.orgnotice.getOrgNoticeList", params));
		return cmap;
		
	}
	
	@Override
	public int exportMessage(CoviMap params) throws Exception {
		// 1.게시글 번호 생성
		params.put("numberingRule", RedisDataUtil.getBaseConfig("UseBoardCategoryNumber", params.getString("domainID")));
		String number = coviMapperOne.getString("user.message.selectNumberByBoard", params);
		params.put("number", number);
		
		params.put("creatorCode", params.get("userCode"));
		params.addAll(coviMapperOne.select("user.message.selectCreatorProfileData", params));
		// 2.게시글 복사
		int moveFlag = coviMapperOne.insert("user.message.copyMessageByOrg", params);
		
		if(moveFlag > 0){
			String orgMessageID = params.getString("orgMessageID");
		
			// 4.첨부 파일, 본문 정보, 사용자저의 필드 정보 복사
/*			List mf = new ArrayList();
			params.put("orgMessageID", orgMessageID);
			migrateMessageSysFile(params, mf);
	*/		
			params.put("seq", params.get("messageID"));
			params.put("depth", 0);
			params.put("step", 0);

			// 아래 updateMessageSeq 에서 orgMessageID를 비워주기 전에 copy하여 SYS_CONTENTS에 body값이 들어가게 함.
			coviMapperOne.update("user.message.copyMessageContents", params);
			
			params.put("orgMessageID", "");
			coviMapperOne.update("user.message.updateMessageSeq", params);	//seq, depth, step, parentID 변경
			
			params.put("comment", "{\"FolderID\":\""+params.getString("folderID")+"\",\"MessageID\":\""+params.getString("messageID")+"\"}");

			// 5. 처리 이력 기록
			params.put("messageID", orgMessageID);
			coviMapperOne.insert("user.message.createHistory", params);
		}
		return moveFlag;
	}
	
	//문서이관, 개정, 복사에 사용
	public void migrateMessageSysFile(CoviMap params, List<MultipartFile> mf) throws Exception{
		StringUtil func = new StringUtil();
	
		String uploadPath = params.getString("bizSection") + File.separator;	// Board, Doc를 붙여서 서비스 타입별 디렉터리 관리
		String orgPath = "Board" + File.separator;
		CoviList fileInfos = CoviList.fromObject(params.getString("fileInfos"));
		CoviList fileObj = fileSvc.moveToService(fileInfos, mf, orgPath, uploadPath , params.getString("bizSection"), params.getString("folderID"), "FD", params.getString("messageID"), params.getString("version"));
		//CHECK: 파일 업로드 후 파일 개수외에 확장자 정보를 필요로 할 수 있음
		
		params.put("storageControl", "+");
		coviMapperOne.update("user.message.updateCurrentFileSizeByMessage", params);	//게시글 점유 용량 업데이트
	}
	
	/**
	 * @description 게시판/문서관리 메뉴 목록 조회
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectMenuList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		CoviList list = coviMapperOne.list("manage.orgnotice.selectMenuList", params);
		resultList.put("list",list);
		return resultList;
	}	
	
	@Override
	public CoviMap getNoticeHistoryList(CoviMap params) throws Exception {
		
		CoviMap cmap = new CoviMap();
		CoviList list			= new CoviList();
		CoviMap page=null;
		int cnt	= 0;

		if (params.get("pageNo") != null && params.get("pageSize") != null){
			cnt = (int) coviMapperOne.getNumber("manage.orgnotice.getNoticeHistoryListCount" , params);
			page = ComUtils.setPagingData(params, cnt);
			params.addAll(page);
		}	
		
		cmap.put("page", page);
		cmap.put("list",coviMapperOne.list("manage.orgnotice.getNoticeHistoryList", params));
		return cmap;
		
	}
	
	@Override
	public int checkSystemNotice(CoviMap params) throws Exception {
		return (int) coviMapperOne.getNumber("manage.orgnotice.getNotReadSystemNoticeCount", params);
	}
}
