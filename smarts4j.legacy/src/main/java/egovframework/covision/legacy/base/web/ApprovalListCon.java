package egovframework.covision.legacy.base.web;

import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ACLHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.legacy.base.service.BoardCommonSvc;



public class ApprovalListCon {
	private static final Logger LOGGER = LogManager.getLogger(ApprovalListCon.class);
			
	@Autowired
	private BoardCommonSvc boardSvc;
	
	@RequestMapping(value = "board/selectFolderTreeData.do", method=RequestMethod.POST)
	public @ResponseBody CoviMap getFolderTreeList(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String bizSection = request.getParameter("bizSection");
		String menuID = request.getParameter("menuID");
		CoviMap returnList = new CoviMap();
		CoviList result = new CoviList();
		CoviList resultList = new CoviList();
		try{
			CoviMap params = new CoviMap();

			String domainID = SessionHelper.getSession("DN_ID");
			String userCode = SessionHelper.getSession("USERID");
			String isAdmin = SessionHelper.getSession("isAdmin");
			
			//Superadmin이 아닌경우 자신이 담당자, 계열사에 따른 MenuID를 조회해와야함.
			String[] groupPath = SessionHelper.getSession("GR_GroupPath").split(";");
			params.put("domainID", domainID);
			params.put("userCode", userCode);
			params.put("lang", SessionHelper.getSession("lang"));
			params.put("menuID", menuID);
			params.put("bizSection", bizSection);
			params.put("groupPath", groupPath);
			
			// 유저는  폴더 권한 처리 skip
			CoviList assignedDomainList = ComUtils.getAssignedDomainCode();	//할당된 도메인 코드
			params.put("assignedDomain", assignedDomainList);
//			int chkSysAuth = boardCommonSvc.checkSysAuthority(params);
			
			if(!"Y".equalsIgnoreCase(isAdmin)) {
				Set<String> authorizedObjectCodeSet = ACLHelper.getACL(SessionHelper.getSession(), "FD", bizSection, "V");
				String[] objectArray = authorizedObjectCodeSet.toArray(new String[authorizedObjectCodeSet.size()]);
				
				params.put("aclData","(" + ACLHelper.join(objectArray, ",") + ")" );
			}
			
			result = (CoviList) boardSvc.selectTreeFolderMenu(params).get("list");
			int index = 0;	//AXTree index array 체크용
		    for(Object jsonobject : result){
				CoviMap folderData = (CoviMap) jsonobject;
				
				// 트리를 그리기 위한 데이터
				folderData.put("no", folderData.get("FolderID"));
				folderData.put("nodeName", folderData.get("FolderName"));	//추후 다국어로 변경
				folderData.put("nodeValue", folderData.get("FolderID"));
				folderData.put("pno", folderData.get("MemberOf"));
				folderData.put("chk", "N");
				folderData.put("rdo", "N");
				folderData.put("ownerFlag", folderData.get("OwnerFlag"));
				folderData.put("index", index);
				folderData.put("bizSection", bizSection);
				
				if(folderData.get("FolderType").equals("Folder") || folderData.get("FolderType").equals("Root")){
					//폴더 선택시 하위메뉴 표시하는 메소드 호출
					folderData.put("nodeName", folderData.get("FolderName"));	//span 태그 테스트
				} else {
					folderData.put("type", "board_default");	//사용자 게시판은 아이콘 구별 하지 않음
					folderData.put("nodeName", folderData.get("FolderName"));	//span 태그 테스트
				}
				resultList.add(folderData);
				index++;
			}
			returnList.put("list", resultList);
			returnList.put("result", "ok");

			returnList.put("status", Return.SUCCESS);
			returnList.put("message", "조회되었습니다");
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
			returnList.put("status", Return.FAIL);
			returnList.put("message", e.getMessage());
		}
		return returnList;
	}
}
