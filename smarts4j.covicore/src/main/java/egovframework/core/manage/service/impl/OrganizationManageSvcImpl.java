package egovframework.core.manage.service.impl;

import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.SecureRandom;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Resource;
import javax.imageio.ImageIO;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.logging.LoggerHelper;
import egovframework.baseframework.sec.AES;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.RedisShardsUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.StringUtil;
import egovframework.core.manage.service.OrganizationManageSvc;
import egovframework.coviframework.service.FileUtilService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.util.HttpClientUtil;
import egovframework.coviframework.util.HttpURLConnectUtil;
import egovframework.coviframework.util.MultipartUtility;
import egovframework.coviframework.util.s3.AwsS3;
import egovframework.coviframework.util.s3.AwsS3Data;
import egovframework.coviframework.vo.ObjectAcl;

@Service("manage.OrganizationManageService")
public class OrganizationManageSvcImpl extends EgovAbstractServiceImpl implements OrganizationManageSvc {

	private Logger LOGGER = LogManager.getLogger(OrganizationManageSvcImpl.class);
//	private HttpURLConnection conn = null;

	@Resource(name = "coviMapperOne")
	private CoviMapperOne coviMapperOne;

	AwsS3 awsS3 = AwsS3.getInstance();

	@Autowired
	FileUtilService fileUtilSvc;

	private String aeskey = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
	private boolean isSaaS = "Y".equals(PropertiesUtil.getGlobalProperties().getProperty("isSaaS", "N"));
	private String disablePrefix = PropertiesUtil.getGlobalProperties().getProperty("disablePrefix", "N");
	private String licSection = "Y";

	
	/**
	 * 그룹 유형 가져오기 select
	 *
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupType() throws Exception {
		CoviList list = coviMapperOne.list("organization.syncmanage.selectGroupType", null);

		CoviMap resultList = new CoviMap();
		resultList.put("list",
				CoviSelectSet.coviSelectJSON(list, "GroupType,SortKey,Priority,DisplayName,MultiDisplayName"));
		return resultList;
	}
	/**
	 * 부서리스트 가져오기 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectAllDeptList(CoviMap params) throws Exception {
		CoviMap resultList = null;
		CoviList list = null;
		int cnt = 0;

		try {
			params.put("lang", SessionHelper.getSession("lang"));
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.conf.manage.selectAllDeptList", params);
			cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectAllDeptListCnt", params);

			resultList.put("list", CoviSelectSet.coviSelectJSON(list,
					"GroupID,GroupCode,CompanyCode,GroupType,MemberOf,GroupPath,RegionCode,DisplayName,MultiDisplayName,ShortName"
					+ ",MultiShortName,OUName,OUPath,SortKey,SortPath,IsUse,IsDisplay,IsMail,IsHR,PrimaryMail,SecondaryMail,ManagerCode"
					+ ",Description,ReceiptUnitCode,ApprovalUnitCode,Receivable,Approvable,RegistDate,ModifyDate"
					+ ",Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,Reserved6,LANG_DISPLAYNAME,LANG_SHORTNAME,MANAGERNAME,MEMBER_CNT"
					));
			resultList.put("cnt", cnt);

		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return resultList;
	}

	/**
	 * 부서 정보 가져오기 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDeptInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.syncmanage.selectDeptInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list,
				"GroupID,GroupCode,CompanyCode,GroupType,MemberOf,DisplayName,ShortName,ParentName,GroupPath,MultiDisplayName,MultiShortName,SortKey,SortPath,IsUse,IsDisplay,IsMail,IsHR,PrimaryMail,SecondaryMail,Description,ReceiptUnitcode,ApprovalUnitCode,Receivable,Approvable,RegistDate,ModifyDate,ManagerCode,Manager,CompanyName,CompanyCode,OUPath,OUName,IsCRM"));
		return resultList;
	}

	/**
	 * 부서 사용 여부 update
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsUseDept(CoviMap params) throws Exception {
		// 사용여부 설정이면 object 사용여부, deletedate 처리
		params.put("ObjectCode", params.get("GroupCode").toString());
		coviMapperOne.update("organization.syncmanage.updateObject", params); // update to sys_object

		return coviMapperOne.update("organization.syncmanage.updateIsUseDept", params);
	};

	/**
	 * 부서 인사 연동 여부 update
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsHRDept(CoviMap params) throws Exception {
		return coviMapperOne.update("organization.syncmanage.updateIsHRDept", params);
	};

	/**
	 * 부서 표시 여부 update
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsDisplayDept(CoviMap params) throws Exception {
		return coviMapperOne.update("organization.syncmanage.updateIsDisplayDept", params);
	};

	/**
	 * 하위부서 존재 여부 체크
	 * 
	 * @param params
	 *            - CoviMap
	 * @return CoviMap - 하위부서 존재 여부
	 * @throws Exception
	 */
	@Override
	public CoviMap selectHasChildDept(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.syncmanage.selectHasChildDept", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "HasChild"));
		return resultList;
	}

	/**
	 * 소속 사용자 존재 여부 체크
	 * 
	 * @param params
	 *            - CoviMap
	 * @return CoviMap - 소속 사용자 존재 여부
	 * @throws Exception
	 */
	@Override
	public CoviMap selectHasUserDept(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.syncmanage.selectHasUserDept", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "HasUser"));
		return resultList;
	}

	/**
	 * 부서 일정 대상 추가
	 * 
	 * @param params
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int insertDeptScheduleCreation(CoviMap params) throws Exception {
		int iReturn = 0;
		try {
			iReturn = coviMapperOne.insert("organization.syncmanage.insertDeptSchedule", params);
		} catch (NullPointerException e){
			LOGGER.error("insertDeptScheduleCreation error : " + e.getMessage());
		} catch (Exception e) {
			LOGGER.error("insertDeptScheduleCreation error : " + e.getMessage());
		}
		return iReturn;
	}

	/**
	 * @description 부서 일정 대상 가져오기
	 */
	@Override
	public CoviMap selectDeptSchedule(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.syncmanage.selectDeptSchedule", null);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list,
				"DomainID,GroupCode,CompanyCode,MenuID,FolderType,DisplayName,MultiDisplayName,OwnerCode"));
		return resultList;
	}

	/**
	 * @description 부서 일정 생성
	 * @return int
	 * @throws Exception
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	@Override
	public int insertDeptScheduleInfo() throws Exception {
		// Folder 데이터 저장
		int returnVal = 0;
		int iReturn = 0;
		CoviMap folderDataObj = new CoviMap();
		folderDataObj.put("MemberOf", RedisDataUtil.getBaseConfig("ScheduleTotalFolderID"));
		String sortKey = "";
		String sSecLevel = RedisDataUtil.getBaseConfig("DefaultSecurityLevel", SessionHelper.getSession("DN_ID"))
				.equals("") ? "90"
						: RedisDataUtil.getBaseConfig("DefaultSecurityLevel", SessionHelper.getSession("DN_ID"));

		// CoviMap ids =
		// coviMapperOne.select("organization.syncmanage.selectDomainMenuID",
		// folderDataObj);
		// sortKey = coviMapperOne.selectOne("organization.syncmanage.selectSortKey",
		// folderDataObj);

		CoviList arrDeptList = (CoviList) selectDeptSchedule(null).get("list");

		if (arrDeptList != null && arrDeptList.size() > 0) {
			int Deptcnt = arrDeptList.size();

			for (int i = 0; i < Deptcnt; i++) {
				sortKey = coviMapperOne.selectOne("organization.syncmanage.selectSortKey", folderDataObj);

				folderDataObj.put("DomainID", "0");
				folderDataObj.put("MenuID", "7");
				folderDataObj.put("FolderType", arrDeptList.getJSONObject(i).getString("FolderType"));
				folderDataObj.put("ParentObjectID", "0");
				folderDataObj.put("ParentObjectType", "DN");
				folderDataObj.put("LinkFolderID", null);
				folderDataObj.put("DisplayName", arrDeptList.getJSONObject(i).getString("DisplayName"));
				folderDataObj.put("MultiDisplayName", arrDeptList.getJSONObject(i).getString("MultiDisplayName"));
				folderDataObj.put("SortKey", sortKey);
				folderDataObj.put("SecurityLevel", sSecLevel);
				folderDataObj.put("IsInherited", "N");
				folderDataObj.put("IsShared", "N");
				folderDataObj.put("IsUse", "Y");
				folderDataObj.put("IsDisplay", "Y");
				folderDataObj.put("IsURL", "N");
				folderDataObj.put("URL", "");
				folderDataObj.put("IsMobileSupport", null);
				folderDataObj.put("IsAdminNotice", null);
				folderDataObj.put("ManageCompany", arrDeptList.getJSONObject(i).getString("DomainID"));
				folderDataObj.put("IsMsgSecurity", null);
				folderDataObj.put("Description", null);
				folderDataObj.put("OwnerCode", arrDeptList.getJSONObject(i).getString("OwnerCode"));
				folderDataObj.put("RegisterCode", arrDeptList.getJSONObject(i).getString("OwnerCode"));
				folderDataObj.put("ModifierCode", arrDeptList.getJSONObject(i).getString("OwnerCode"));
				folderDataObj.put("DeleteDate", null);
				folderDataObj.put("Reserved1", null); // 개인일정 공유
				folderDataObj.put("Reserved2", RedisDataUtil.getBaseConfig("FolderDefaultColor")); // 일정 기본
																												// 컬러
				folderDataObj.put("Reserved3", null);
				folderDataObj.put("Reserved4", "Y"); // 관리자 하위메뉴 표시 여부
				folderDataObj.put("Reserved5", arrDeptList.getJSONObject(i).getString("GroupCode")); // 부서코드 맵핑 처리

				returnVal = coviMapperOne.insert("organization.syncmanage.insertFolderData", folderDataObj);

				String folderID = folderDataObj.getString("FolderID");
				CoviMap idParam = new CoviMap();
				idParam.put("FolderID", folderID);
				// Folder SortPath, FolderPath Update
				String sortPath = coviMapperOne.selectOne("organization.syncmanage.selectComSortPathCreateS", idParam);
				String folderPath = coviMapperOne.selectOne("organization.syncmanage.selectComObjectPathCreateS", idParam);
				idParam.put("SortPath", sortPath);
				idParam.put("FolderPath", folderPath);
				coviMapperOne.update("organization.syncmanage.updateSortPath", idParam);
				coviMapperOne.update("organization.syncmanage.updateFolderPath", idParam);

				String aclString = "";
				
				// 부서 일정 생성 시 수정/삭제 권한 부여 여부 (기본은 수정/삭제 권한을 부여하지 않는다)
				if(RedisDataUtil.getBaseConfig("ScheduleDefaultCorrectACL").equalsIgnoreCase("Y")) {
					aclString = "[{\"SubjectCode\":\"" + arrDeptList.getJSONObject(i).getString("GroupCode") + "\",\"SubjectType\":\"GR\",\"AclList\":\"SCDMEVR\"}]";
				} else {
					aclString = "[{\"SubjectCode\":\"" + arrDeptList.getJSONObject(i).getString("GroupCode") + "\",\"SubjectType\":\"GR\",\"AclList\":\"SC__EVR\"}]";
				}
				
				CoviList aclDataList = new CoviList();
				CoviList aclDataObj1 = CoviList.fromObject(StringEscapeUtils.unescapeHtml(aclString));
				aclDataList.addAll((Collection) aclDataObj1);
				// 권한 데이터 저장
				if (returnVal > 0) {
					CoviList aclDatas = null;
					for (Object obj : aclDataList) {
						aclDatas = new CoviList();
						CoviMap aclDataObj = new CoviMap();
						aclDataObj.addAll((Map) obj);

						ObjectAcl aclObject = new ObjectAcl();
						aclObject.setObjectID(Integer.parseInt(folderID));
						aclObject.setObjectType("FD");
						aclObject.setSubjectType(aclDataObj.getString("SubjectType"));
						aclObject.setSubjectCode(aclDataObj.getString("SubjectCode"));
						aclObject.setAclList(aclDataObj.getString("AclList"));

						aclDatas.add(aclObject);
					}

					iReturn = coviMapperOne.insert("framework.authority.insertACLList", aclDatas);

					if (iReturn == 1 && RedisDataUtil.getBaseConfig("DeptScheduleInherit").equalsIgnoreCase("N")) {
						CoviMap params1 = new CoviMap();
						params1.put("gr_code", arrDeptList.getJSONObject(i).getString("GroupCode"));
						CoviList arrresultList = (CoviList) selectSubGroupList(params1).get("list");
						CoviMap arrresult = selectSubGroupList(params1);
						int subCnt = arrresult.getInt("cnt");
						aclDataList = new CoviList();

						if (subCnt > 0) {
							for (int j = 0; j < subCnt; j++) {
								aclString = "[{\"SubjectCode\":\"" + arrresultList.getJSONObject(j).getString("GroupCode") + "\",\"SubjectType\":\"GR\",\"AclList\":\"_______\"}]";
								aclDataObj1 = CoviList.fromObject(StringEscapeUtils.unescapeHtml(aclString));
								aclDataList.addAll((Collection) aclDataObj1);

								aclDatas = new CoviList();
								for (Object obj : aclDataList) {
									CoviMap aclDataObj = new CoviMap();
									aclDataObj.addAll((Map) obj);

									ObjectAcl aclObject = new ObjectAcl();
									aclObject.setObjectID(Integer.parseInt(folderID));
									aclObject.setObjectType("FD");
									aclObject.setSubjectType(aclDataObj.getString("SubjectType"));
									aclObject.setSubjectCode(aclDataObj.getString("SubjectCode"));
									aclObject.setAclList(aclDataObj.getString("AclList"));

									aclDatas.add(aclObject);

									iReturn += coviMapperOne.insert("framework.authority.insertACLList", aclDatas);
								}
							}
						}
					}

					// Redis 권한 데이터 초기화
					RedisShardsUtil.getInstance().removeAll(folderDataObj.getString("domainID"),
							RedisDataUtil.PRE_ACL + folderDataObj.getString("domainID") + "_*");
					folderDataObj.put("CreateYN", "Y");
					folderDataObj.put("GroupCode", arrDeptList.getJSONObject(i).getString("GroupCode"));
					coviMapperOne.update("organization.syncmanage.updateDeptSchedule", folderDataObj);
				}

			}
		}
		return returnVal;
	}

	/**
	 * @description 부서 일정 수정
	 * @param params
	 * @throws Exception
	 */
	@Override
	public int updateDeptScheduleInfo(CoviMap params) throws Exception {
		CoviMap fParams = new CoviMap();
		int iReturn = coviMapperOne.update("organization.syncmanage.updateFolderData", params);
		if (iReturn > 0) {

			@SuppressWarnings("rawtypes")
			List FolderChildList = coviMapperOne.list("organization.syncmanage.selectFolderChildList", params);

			if (FolderChildList.size() > 0) {
				for (int j = 0; j < FolderChildList.size(); ++j) {
					CoviMap SubParams = new CoviMap();
					SubParams = (CoviMap) FolderChildList.get(j);
					fParams.put("FolderID", SubParams.get("FolderID"));
					fParams.put("Reserved5", SubParams.get("Reserved5"));

					String sortPath = coviMapperOne.selectOne("organization.syncmanage.selectComSortPathCreateS",
							fParams);
					fParams.put("SortPath", sortPath);

					coviMapperOne.update("organization.syncmanage.updateSortPath", fParams);
				}
			}
		}
		return iReturn;
	}


	/**
	 * 하위 그룹 목록 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectSubGroupList(CoviMap params) throws Exception {

		CoviMap resultList = new CoviMap();
		CoviList list = null;
		int cnt = 0;

		try {
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.syncmanage.selectSubGroupList", params);
			cnt = (int) coviMapperOne.getNumber("organization.syncmanage.selectSubGroupListCnt", params);

			resultList.put("list", CoviSelectSet.coviSelectJSON(list,
					"GroupCode,MultiDisplayName,IsUse,GroupType,CompanyCode,GroupPath,SortPath,MultiShortName,OUName,ShortName,SortKey,MemberOf,IsMail,PrimaryMail"));
			resultList.put("cnt", cnt);
		} catch (NullPointerException e){
			LOGGER.error("selectSubGroupList Error  " + "[Message : " + e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("selectSubGroupList Error  " + "[Message : " + e.getMessage() + "]");
		}

		return resultList;
	}
	////////////////////////////////////////////////////////////////////////////////////////////
	//그룹
	////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * 그룹리스트 가져오기 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getAllGroupList(CoviMap params) throws Exception {
		CoviMap resultList = null;
		CoviList list = null;
		int cnt = 0;

		try {
			params.put("lang", SessionHelper.getSession("lang"));
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.conf.manage.selectAllGroupList", params);
			cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectAllGroupListCnt", params);

			resultList.put("list", CoviSelectSet.coviSelectJSON(list,
					"GroupID,GroupCode,CompanyCode,GroupType,MemberOf,GroupPath,RegionCode,DisplayName,MultiDisplayName,ShortName"
					+ ",MultiShortName,OUName,OUPath,SortKey,SortPath,IsUse,IsDisplay,IsMail,IsHR,PrimaryMail,SecondaryMail,ManagerCode"
					+ ",Description,ReceiptUnitCode,ApprovalUnitCode,Receivable,Approvable,RegistDate,ModifyDate"
					+ ",Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,Reserved6,LANG_DISPLAYNAME,MEMBER_CNT"));
			resultList.put("cnt", cnt);

		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return resultList;
	}

	/**
	 * 그룹 정보 가져오기 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.conf.manage.selectGroupInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list,
				"GroupID,GroupCode,CompanyCode,GroupType,MemberOf,GroupPath,RegionCode,DisplayName,MultiDisplayName,ShortName,MultiShortName,OUName,OUPath,SortKey,SortPath,IsUse,IsDisplay,IsMail,IsHR,PrimaryMail,SecondaryMail,ManagerCode,Description,ReceiptUnitCode,ApprovalUnitCode,Receivable,Approvable,RegistDate,ModifyDate,Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,Reserved6,CompanyName,ParentName,Manager,MailDomain,DomainID,IsCRM"));
		return resultList;
	}

	/**
	 * 그룹 사용 여부 update
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsUseGroup(CoviMap params) throws Exception {
		return coviMapperOne.update("organization.syncmanage.updateIsUseGroup", params);
	};

	/**
	 * 하위 그룹 존재 여부 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectHasChildGroup(CoviMap params) throws Exception {
		int hasChildCnt = (int) coviMapperOne.getNumber("organization.syncmanage.selectHasChildGroup", params);

		return hasChildCnt;
	}

	/**
	 * 하위 사용자 존재 여부 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSONObject
	 * @throws Exception
	 */
	@Override
	public int selectHasUserGroup(CoviMap params) throws Exception {
		int hasChildCnt = (int) coviMapperOne.getNumber("organization.syncmanage.selectHasUserGroup", params);

		return hasChildCnt;
	}
	

	/**
	 * 소속 사용자 존재 여부 체크
	 * 
	 * @param params
	 *            - CoviMap
	 * @return CoviMap - 소속 사용자 존재 여부
	 * @throws Exception
	 */
	@Override
	public int selectHasGroupMember(CoviMap params) throws Exception {
		int hasroupMemberCnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectHasGroupMember", params);

		return hasroupMemberCnt;
	}
	

	/**
	 * 하위 부서 Path 정보 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDeptPathInfo(CoviMap params) throws Exception {

		CoviList list = coviMapperOne.list("organization.syncmanage.selectDeptPathInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupCode,GroupPath,OUPath,SortPath"));
		return resultList;
	}

	

	/**
	 * 하위 부서 Path 정보 update
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateDeptPathInfo(CoviMap params) throws Exception {
		int retCnt = coviMapperOne.update("organization.syncmanage.updateDeptPathInfo", params);
		return retCnt;
	}

	/**
	 * 부서 Path 정보 업데이트
	 * 
	 * @return void
	 * @throws Exception
	 */
	@Override
	public void updateDeptPathInfoAll() {
		String groupcode = "";

		LOGGER.info("updateDeptPathInfo execute");

		try {
			// list 가져오기 => Dept 전체
			CoviList list = coviMapperOne.list("organization.syncmanage.selectSyncDeptInfo", null);
			CoviList groupList = CoviSelectSet.coviSelectJSON(list, "GroupCode,CompanyCode,MemberOf,SortKey,OUName");

			LOGGER.info("updateDeptPathInfo > selectDeptInfo completed");

			// Sync execution
			for (Object group : groupList) {
				CoviMap groupParams = new CoviMap();
				CoviMap groupObj = (CoviMap) group;
				groupcode = groupObj.get("GroupCode").toString();

				LOGGER.info("updateDeptPathInfo > [" + groupObj.get("GroupCode") + "] "
						+ groupObj.get("CompanyCode").toString() + " " + groupObj.get("MemberOf").toString());

				// GroupPath, SortPath, OUPath Create
				String[] resultString = getGroupPath(groupObj.get("CompanyCode").toString(),
						groupObj.get("MemberOf").toString()).split("&");
				String strGroupPath = "";
				String strSortPath = "";
				String strOUPath = "";

				LOGGER.info("updateDeptPathInfo > [" + groupObj.get("GroupCode") + "] getGroupPath completed");

				if (resultString.length > 0 && (resultString[1].isEmpty() != true)
						&& (resultString[2].isEmpty() != true)) {
					// LOGGER.info("updateDeptPathInfo > [" + groupObj.get("GroupCode") + "]
					// getGroupPath setting started ");
					strGroupPath = resultString[0] + groupObj.get("GroupCode") + ";";
					LOGGER.info("updateDeptPathInfo > [" + groupObj.get("GroupCode") + "] getGroupPath setting > "
							+ strGroupPath);
					strSortPath = resultString[1]
							+ String.format("%015d", Integer.parseInt((String) groupObj.get("SortKey"))) + ";";
					LOGGER.info("updateDeptPathInfo > [" + groupObj.get("GroupCode") + "] getGroupPath setting > "
							+ strSortPath);
					strOUPath = resultString[2] + groupObj.get("OUName") + ";";
				}

				LOGGER.info("updateDeptPathInfo > [" + groupObj.get("GroupCode") + "] getGroupPath setting finished ");

				// grouppath, sortpath, oupath update
				groupParams.put("GroupCode", groupObj.get("GroupCode"));
				groupParams.put("GroupPath", strGroupPath);
				groupParams.put("OUPath", strOUPath);
				groupParams.put("SortPath", strSortPath);

				LOGGER.info("updateDeptPathInfo > [" + groupObj.get("GroupCode") + "] updateDeptPathInfo excute ");
				coviMapperOne.update("organization.syncmanage.updateDeptPathInfo", groupParams);
			}

		} catch (NullPointerException ex){
			LOGGER.error("updateDeptPathInfo Error [GroupCode : " + groupcode + "] " + "[Message : " + ex.getMessage()
			+ "]", ex);
		} catch (Exception ex) {
			LOGGER.error("updateDeptPathInfo Error [GroupCode : " + groupcode + "] " + "[Message : " + ex.getMessage()
					+ "]", ex);
		} finally {
			LOGGER.info("updateDeptPathInfo execute complete");
		}

	}
	////////////////////////////////////////////////////////////////////////////////////////////
	//그룹
	////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * 그룹 정보 가져오기 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupInfoList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.conf.manage.selectGroupInfoList", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list,
				"GroupID,GroupCode,CompanyCode,GroupType,MemberOf,DisplayName,ShortName,ParentName,GroupPath,MultiDisplayName,DisplayName,MultiShortName,SortKey,SortPath,IsUse,IsDisplay,IsMail,IsHR,PrimaryMail,SecondaryMail,Description,ReceiptUnitcode,ApprovalUnitCode,Receivable,Approvable,RegistDate,ModifyDate,ManagerCode,Manager,CompanyName,CompanyCode,OUPath,OUName"));
		return resultList;
	}

	/**
	 * 그룹 delete
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int deleteGroup(CoviMap params) throws Exception {
		int iReturn = 0;

		try {
			LOGGER.debug("deleteGroup execute [" + params.get("GroupCode") + "]");
			LOGGER.debug("deleteGroup - deleteObject execute");

			iReturn = coviMapperOne.update("organization.syncmanage.deleteObject", params); // delete to sys_object
			if (true) {//iReturn == 1
				LOGGER.debug("deleteGroup - deleteObject execute complete");
				LOGGER.debug("deleteGroup - deleteObjectGroup execute");
				iReturn = coviMapperOne.delete("organization.syncmanage.deleteObjectGroup", params); // delete to
																										// sys_object_group
				if (true) {//iReturn == 1
					LOGGER.debug("deleteGroup - deleteObjectGroup execute complete");
					params.put("SyncStatus", 'Y');
					if ("Sync".equals(params.getString("SyncManage"))) {
						String strLog = "";
						String sObjectType = params.get("GroupType").toString().toUpperCase();
						if ("DEPT".equals(sObjectType)) strLog = "부서 ";
						else if ("JOBLEVEL".equals(sObjectType)) strLog = "직급 ";
						else if ("JOBPOSITION".equals(sObjectType)) strLog = "직위 ";
						else if ("JOBTITLE".equals(sObjectType)) strLog = "직책 ";
						
						strLog += "[" + params.get("GroupCode") + "] 삭제됨";
						
						insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", sObjectType, "DELETE", strLog, "");
					}
				}
			}
		} catch (NullPointerException ex){
			iReturn = 0;
			params.put("SyncStatus", 'N');
			LOGGER.error("deleteGroup Error [ObjectCode : " + params.get("GroupCode") + "] " + "[Message : "
					+ ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "";
				String sObjectType = params.get("GroupType").toString().toUpperCase();
				if ("DEPT".equals(sObjectType)) strLog = "부서 ";
				else if ("JOBLEVEL".equals(sObjectType)) strLog = "직급 ";
				else if ("JOBPOSITION".equals(sObjectType)) strLog = "직위 ";
				else if ("JOBTITLE".equals(sObjectType)) strLog = "직책 ";
				
				strLog += "[" + params.get("GroupCode") + "] 삭제 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", sObjectType, "DELETE", strLog, "");
			}
		} 
		catch (Exception ex) {
			iReturn = 0;
			params.put("SyncStatus", 'N');
			LOGGER.error("deleteGroup Error [ObjectCode : " + params.get("GroupCode") + "] " + "[Message : "
					+ ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "";
				String sObjectType = params.get("GroupType").toString().toUpperCase();
				if ("DEPT".equals(sObjectType)) strLog = "부서 ";
				else if ("JOBLEVEL".equals(sObjectType)) strLog = "직급 ";
				else if ("JOBPOSITION".equals(sObjectType)) strLog = "직위 ";
				else if ("JOBTITLE".equals(sObjectType)) strLog = "직책 ";
				
				strLog += "[" + params.get("GroupCode") + "] 삭제 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", sObjectType, "DELETE", strLog, "");
			}
		} 
		finally {
			insertGroupLogList(params);
		}

		return iReturn;
	}
	/**
	 * 그룹/사용자 목록 우선순위 update
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap updateGroupUserListSortKey(CoviMap params) throws Exception {

		CoviMap resultObj = new CoviMap();
		int returnCnt = 0;
		String strSortKey_A = null;
		String strSortKey_B = null;
		String strSortPath_A = "";
		String strSortPath_B = "";
		String strGroupPath_A = "";
		String strGroupPath_B = "";
		String strType = null;
		try {
			strType = params.get("Type").toString();
			if (strType.equals("group")) {
				// get SortKey
				params.put("GroupCode", params.get("Code_A"));
				CoviMap list_A = coviMapperOne.select("organization.conf.manage.selectGroupSortKey", params);
				params.put("GroupCode", params.get("Code_B"));
				CoviMap list_B = coviMapperOne.select("organization.conf.manage.selectGroupSortKey", params);
				

				strSortKey_A = list_A.get("SortKey").toString();
				strSortPath_A = list_A.get("SortPath").toString();
				strGroupPath_A = list_A.get("GroupPath").toString();

				strSortKey_B = list_B.get("SortKey").toString();
				strSortPath_B = list_B.get("SortPath").toString();
				strGroupPath_B = list_B.get("GroupPath").toString();
				
				
				// update SortKey
				params.put("GroupCode", params.get("Code_A"));
				params.put("SortKey", strSortKey_B);
				params.put("SortPath", strSortPath_B);
				returnCnt += coviMapperOne.update("organization.conf.manage.updateGroupSort", params);
				setSortPathByMemberOf(params.get("Code_A").toString());

				params.put("GroupCode", params.get("Code_B"));
				params.put("SortKey", strSortKey_A);
				params.put("SortPath", strSortPath_A);
				returnCnt += coviMapperOne.update("organization.conf.manage.updateGroupSort", params);
				setSortPathByMemberOf(params.get("Code_B").toString());
			} else if (strType.equals("user")) {
				// get SortKey
				params.put("TargetCode", params.get("Code_A"));
				strSortKey_A = coviMapperOne.select("organization.syncmanage.selectUserSortKey", params).get("SortKey")
						.toString();
				params.put("TargetCode", params.get("Code_B"));
				strSortKey_B = coviMapperOne.select("organization.syncmanage.selectUserSortKey", params).get("SortKey")
						.toString();

				// update SortKey
				params.put("TargetCode", params.get("Code_A"));
				params.put("TargetSortKey", strSortKey_B);
				returnCnt += coviMapperOne.update("organization.syncmanage.updateUserSortKey", params);
				params.put("TargetCode", params.get("Code_B"));
				params.put("TargetSortKey", strSortKey_A);
				returnCnt += coviMapperOne.update("organization.syncmanage.updateUserSortKey", params);
			}
		} catch (NullPointerException e){
			returnCnt = 0;
			LOGGER.error("updateGroupUserListSortKey Error  " + "[Message : " + e.getMessage() + "]");
		} catch (Exception e) {
			returnCnt = 0;
			LOGGER.error("updateGroupUserListSortKey Error  " + "[Message : " + e.getMessage() + "]");
		}

		if (returnCnt > 0)
			resultObj.put("result", "OK");
		else
			resultObj.put("result", "FAIL");

		return resultObj;
	}
	/**
	 * moveDeptOrgUser : 다수 사용자 부서이동
	 */
	@Override
	public int moveDeptOrgUser(CoviMap params) throws Exception {
		return coviMapperOne.update("organization.conf.manage.moveDeptOrgUser", params);
	}
	
	/**
	 * 그룹  우선순위 update
	 * 
	 * @param params
	 *            - CoviMap(GroupCode)
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public void setSortPathByMemberOf(String strGroupCode) throws Exception 
	{
		CoviMap resultObj = new CoviMap();
		String strTGroupCode = null;
		int returnCnt = 0;
		try {
			CoviMap params = new CoviMap();
			params.put("TargetID", new String[]{strGroupCode});
			CoviList list = coviMapperOne.list("organization.conf.manage.selectGroupInfoWithSubList", params);

			for (Object group : list) {
				CoviMap groupParams = new CoviMap();
				CoviMap groupObj = (CoviMap) group;
				strTGroupCode = groupObj.get("GroupCode").toString();

				String[] resultString = getGroupPath(groupObj.get("CompanyCode").toString(),
						groupObj.get("MemberOf").toString()).split("&");
				String strSortPath = "";
				
				if (resultString.length > 0 && (resultString[1].isEmpty() != true)) {
					strSortPath = resultString[1]+ String.format("%015d", Integer.parseInt(groupObj.get("SortKey").toString())) + ";";
					
				}

				groupParams.put("GroupCode", groupObj.get("GroupCode"));
				groupParams.put("SortPath", strSortPath);
				coviMapperOne.update("organization.conf.manage.updateGroupSort", groupParams);
			}

		} catch (NullPointerException e){
			throw e;
		} catch (Exception e) {
			throw e;
		}
	}
	/**
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupInfoWithSubList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.conf.manage.selectGroupInfoWithSubList", params);
		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list,
				"GroupID,GroupCode,GroupType,MemberOf,ParentName,GroupPath,MultiDisplayName,MultiShortName,DisplayName,SortKey,SortPath"
				+ ",OUName,OUPath,IsUse,IsDisplay,IsMail,IsHR,PrimaryMail,SecondaryMail,Description,ReceiptUnitCode,ApprovalUnitCode,Receivable"
				+ ",Approvable,RegistDate,ModifyDate,ManagerCode,Manager,CompanyName,CompanyCode"));
		return resultList;
	}
	
	/**
	 * 임의그룹 중복 여부 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectIsDuplicateGroupCode(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.syncmanage.selectIsDuplicateGroupCode", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate"));
		return resultList;
	};

	/**
	 * 메일 주소 중복 여부 select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectIsDuplicateMail(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.admin.selectIsDuplicateMail", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate"));
		return resultList;
	}
	/**
	 * 그룹 메일 사용 여부 update
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsMailGroup(CoviMap params) throws Exception {
		return coviMapperOne.update("organization.syncmanage.updateIsMailGroup", params);
	}

	/**
	 * 부서 정보 insert
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */ 
	@Override
	public int insertGroup(CoviMap params) throws Exception {
		int iReturn = 0;

		try {
			LOGGER.debug("insertGroup execute [" + params.get("GroupCode") + "]");
			LOGGER.debug("insertGroup - insertObject execute");

			iReturn = coviMapperOne.insert("organization.syncmanage.insertObject", params); // insert to sys_object
			if (iReturn == 1) {
				LOGGER.debug("insertGroup - insertObject execute complete");
				LOGGER.debug("insertGroup - insertObjectGroup execute");
				iReturn = coviMapperOne.insert("organization.syncmanage.insertObjectGroup", params); // insert to sys_object_group

				if (iReturn == 1) {
					if (!"Sync".equals(params.getString("SyncManage"))) {
						String GroupPath = coviMapperOne.selectOne("organization.syncmanage.selectFNGroupPath", params);
						String SortPath = coviMapperOne.selectOne("organization.syncmanage.selectFNSortPath", params);
						String OUPath = coviMapperOne.selectOne("organization.syncmanage.selectFNOUPath", params);
						params.put("GroupPath", GroupPath);
						params.put("SortPath", SortPath);
						params.put("OUPath", OUPath);
						iReturn = coviMapperOne.update("organization.syncmanage.updateFNGroupPath", params);
						LOGGER.debug("insertGroup - insertObjectGroup execute complete");
					} 
					else {
						params.put("SyncStatus", 'Y');
						
						if ("Sync".equals(params.getString("SyncManage"))) {
							String strLog = "";
							String sObjectType = params.get("GroupType").toString().toUpperCase();
							if ("DEPT".equals(sObjectType)) strLog = "부서 ";
							else if ("JOBLEVEL".equals(sObjectType)) strLog = "직급 ";
							else if ("JOBPOSITION".equals(sObjectType)) strLog = "직위 ";
							else if ("JOBTITLE".equals(sObjectType)) strLog = "직책 ";
							
							strLog += "[" + params.get("GroupCode") + "] 추가됨";
							
							insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", sObjectType, "INSERT", strLog, "");
						}
					}
				} 
				else {
					throw new Exception("insertGroup - insertObjectGroup execute failed");
				}
			} 
			else {
				throw new Exception("insertGroup - insertObject execute failed");
			}
		} catch (NullPointerException ex){
			params.put("SyncStatus", 'N');
			LOGGER.error("insertGroup Error [ObjectCode : " + params.get("GroupCode") + "] " + "[Message : " + ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "";
				String sObjectType = params.get("GroupType").toString().toUpperCase();
				if ("DEPT".equals(sObjectType)) strLog = "부서 ";
				else if ("JOBLEVEL".equals(sObjectType)) strLog = "직급 ";
				else if ("JOBPOSITION".equals(sObjectType)) strLog = "직위 ";
				else if ("JOBTITLE".equals(sObjectType)) strLog = "직책 ";
				
				strLog += "[" + params.get("GroupCode") + "] 추가 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", sObjectType, "INSERT", strLog, "");
			}
		} 
		catch (Exception ex) {
			params.put("SyncStatus", 'N');
			LOGGER.error("insertGroup Error [ObjectCode : " + params.get("GroupCode") + "] " + "[Message : " + ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "";
				String sObjectType = params.get("GroupType").toString().toUpperCase();
				if ("DEPT".equals(sObjectType)) strLog = "부서 ";
				else if ("JOBLEVEL".equals(sObjectType)) strLog = "직급 ";
				else if ("JOBPOSITION".equals(sObjectType)) strLog = "직위 ";
				else if ("JOBTITLE".equals(sObjectType)) strLog = "직책 ";
				
				strLog += "[" + params.get("GroupCode") + "] 추가 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", sObjectType, "INSERT", strLog, "");
			}
		} 
		finally {
			insertGroupLogList(params);
		}

		return iReturn;
	}

	/**
	 * 그룹 정보 update
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateGroup(CoviMap params) throws Exception {
		int iReturn = 0;

		try {
			LOGGER.debug("updateGroup execute [" + params.get("GroupCode") + "]");
			LOGGER.debug("updateGroup - updateObject execute");
			iReturn = coviMapperOne.update("organization.syncmanage.updateObject", params); // update to sys_object
			LOGGER.debug("updateGroup - updateObject execute complete");
			if (iReturn != 1) // sys_object에 해당 데이터가 없을 경우
			{
				LOGGER.debug("updateGroup - updateObject failed");
				LOGGER.debug("updateGroup - insertObject execute");
				coviMapperOne.insert("organization.syncmanage.insertObject", params); // insert to sys_object
				LOGGER.debug("updateGroup - insertObject execute complete");
			}

			LOGGER.debug("updateGroup - updateObjectGroup execute");
			iReturn = coviMapperOne.update("organization.syncmanage.updateObjectGroup", params); // update to sys_object_group
			LOGGER.debug("updateGroup - updateObjectGroup execute complete");
			if (iReturn != 1) // sys_object_group에 해당 데이터가 없을 경우
			{
				LOGGER.debug("updateGroup - updateObjectGroup failed");
				LOGGER.debug("updateGroup - insertObjectGroup execute");
				iReturn = coviMapperOne.insert("organization.syncmanage.insertObjectGroup", params); // insert to sys_object_group
			}

			if (iReturn > 0) { // path 업데이트
				if (!"Sync".equals(params.getString("SyncManage"))) {
					String GroupPath = coviMapperOne.selectOne("organization.syncmanage.selectFNGroupPath", params);
					String SortPath = coviMapperOne.selectOne("organization.syncmanage.selectFNSortPath", params);
					String OUPath = coviMapperOne.selectOne("organization.syncmanage.selectFNOUPath", params);
					params.put("GroupPath", GroupPath);
					params.put("SortPath", SortPath);
					params.put("OUPath", OUPath);
					iReturn = coviMapperOne.update("organization.syncmanage.updateFNGroupPath", params);
					LOGGER.debug("updateGroup - updateFNGroupPath execute complete");
				}
				params.put("SyncStatus", 'Y');

				if (params.get("GroupType").toString().contains("Job")
						|| params.get("GroupType").toString().equals("Dept")) { // update JobLevel, JobPosition, JobTitle, Dept
					LOGGER.debug("updateGroup - updateUserGroupName execute");
					coviMapperOne.update("organization.syncmanage.updateUserGroupName", params); // update to sys_object_user_basegroup
					LOGGER.debug("updateGroup - updateUserGroupName execute complete");
				}
			}

			params.put("SyncStatus", 'Y');
			
			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "";
				String sObjectType = params.get("GroupType").toString().toUpperCase();
				if ("DEPT".equals(sObjectType)) strLog = "부서 ";
				else if ("JOBLEVEL".equals(sObjectType)) strLog = "직급 ";
				else if ("JOBPOSITION".equals(sObjectType)) strLog = "직위 ";
				else if ("JOBTITLE".equals(sObjectType)) strLog = "직책 ";
				
				strLog += "[" + params.get("GroupCode") + "] 수정됨";
				
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", sObjectType, "UPDATE", strLog, "");
			}
		} catch (NullPointerException ex){
			iReturn = 0;
			params.put("SyncStatus", 'N');
			LOGGER.error("updateGroup Error [ObjectCode : " + params.get("GroupCode") + "] " + "[Message : " + ex.getMessage() + "]", ex);
			
			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "";
				String sObjectType = params.get("GroupType").toString().toUpperCase();
				if ("DEPT".equals(sObjectType)) strLog = "부서 ";
				else if ("JOBLEVEL".equals(sObjectType)) strLog = "직급 ";
				else if ("JOBPOSITION".equals(sObjectType)) strLog = "직위 ";
				else if ("JOBTITLE".equals(sObjectType)) strLog = "직책 ";
				
				strLog += "[" + params.get("GroupCode") + "] 수정 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", sObjectType, "UPDATE", strLog, "");
			}
		} 
		catch (Exception ex) {
			iReturn = 0;
			params.put("SyncStatus", 'N');
			LOGGER.error("updateGroup Error [ObjectCode : " + params.get("GroupCode") + "] " + "[Message : " + ex.getMessage() + "]", ex);
			
			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "";
				String sObjectType = params.get("GroupType").toString().toUpperCase();
				if ("DEPT".equals(sObjectType)) strLog = "부서 ";
				else if ("JOBLEVEL".equals(sObjectType)) strLog = "직급 ";
				else if ("JOBPOSITION".equals(sObjectType)) strLog = "직위 ";
				else if ("JOBTITLE".equals(sObjectType)) strLog = "직책 ";
				
				strLog += "[" + params.get("GroupCode") + "] 수정 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", sObjectType, "UPDATE", strLog, "");
			}
		}
		finally {
			insertGroupLogList(params);
		}

		return iReturn;
	}

	/**
	 * 그룹멤버 목록(By GroupCode)
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap getGroupMemberList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
 		if(params.containsKey("pageNo")) {
 			int cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectGroupMemberListCnt", params);
 			page = ComUtils.setPagingData(params,cnt);
 			params.addAll(page);
 			resultList.put("page", page);
 		}


 		CoviList list = coviMapperOne.list("organization.conf.manage.selectGroupMemberList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "TYPE,CODE,CODENAME,MAILADDRESS,MEMBERID"));
		
		
		return resultList;
	}
	
	
	/**
	 * 그룹 멤버 추가
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int addGroupMember(CoviMap params) throws Exception {
		int iCnt = 0;

		String URList1 = "";
		String GRList1 = "";
		if (params.get("URList") != null && !params.get("URList").equals("")) {
			URList1 = params.get("URList").toString();
		}
		if (params.get("GRList") != null && !params.get("GRList").equals("")) {
			GRList1 = params.get("GRList").toString();
		}

		if (URList1 != null && !URList1.equals("")) {
			String URList[] = URList1.split(";");
			for (int i = 0; i < URList.length; i++) {
				params.put("UserCode", URList[i]);

				int nCnt = (int) coviMapperOne.getNumber("organization.syncmanage.selectIsDuplicateGroupMemberUser",
						params);
				if (nCnt == 0) {
					params.put("URList", URList[i]);
					iCnt += coviMapperOne.insert("organization.syncmanage.insertAddGroupMemberUser", params);
				}
			}
		}
		if (GRList1 != null && !GRList1.equals("")) {
			String GRList[] = GRList1.split(";");
			for (int i = 0; i < GRList.length; i++) {
				params.put("MemberGroupCode", GRList[i]);

				int nCnt = (int) coviMapperOne.getNumber("organization.syncmanage.selectIsDuplicateGroupMember",
						params);
				if (nCnt == 0) {
					params.put("GRList", GRList[i]);
					iCnt += coviMapperOne.insert("organization.syncmanage.insertGroupMemberGroup", params);
				}
			}
		}

		return iCnt;
	}

	/**
	 * 그룹 멤버 삭제
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int deleteGroupMember(CoviMap params) throws Exception {
		int iCnt = 0;
		if (params.get("deleteDataUser") != null) {
			iCnt += coviMapperOne.delete("organization.syncmanage.deleteGroupMemberUser", params);
		}
		if (params.get("deleteDataGroup") != null) {
			iCnt += coviMapperOne.delete("organization.syncmanage.deleteGroupMemberGroup", params);
		}
		return iCnt;
	}

	
	
	/**
	 * 코드 값으로 정보 가져오기(그룹, 회사) select
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectDefaultSetInfoGroup(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.conf.manage.selectDefaultSetInfoGroupByDomainId", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CompanyName,GroupName,CompanyCode,MailDomain,DomainID"));
		return resultList;
	}
	

	/**
	 * 그룹 기타 정보 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupEtcInfo(CoviMap params) throws Exception {

		CoviList list = coviMapperOne.list("organization.syncmanage.selectGroupEtcInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "CompanyID,GroupPath,SortPath,OUPath"));
		return resultList;
	}

	/**
	 * 그룹리스트 가져오기 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupListByGroupType(CoviMap params) throws Exception {
		CoviMap resultList = null;
		CoviList list = null;
		CoviMap page = null;

		try {
			params.put("lang", SessionHelper.getSession("lang"));
			resultList = new CoviMap();
			if(params.containsKey("pageNo")) {
	 			int cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectGroupListByGroupTypeCnt", params);
	 			page = ComUtils.setPagingData(params,cnt);
	 			params.addAll(page);
	 			resultList.put("page", page);
	 		}
			list = coviMapperOne.list("organization.conf.manage.selectGroupListByGroupType", params);
			resultList.put("list", CoviSelectSet.coviSelectJSON(list,
					"GroupID,GroupCode,CompanyCode,GroupType,MemberOf,GroupPath,RegionCode,DisplayName,MultiDisplayName,ShortName"
					+ ",MultiShortName,OUName,OUPath,SortKey,SortPath,IsUse,IsDisplay,IsMail,IsHR,PrimaryMail,SecondaryMail,ManagerCode"
					+ ",Description,ReceiptUnitCode,ApprovalUnitCode,Receivable,Approvable,RegistDate,ModifyDate"
					+ ",Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,Reserved6,LANG_DISPLAYNAME,MEMBER_CNT"));
			

		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return resultList;
	}
	
	/**
	 * @description 그룹의 Path 관련 정보 추출
	 * @param CompanyCode String
	 * @param MemberOf String
	 * @return String
	 * @throws Exception
	 */
	@Override
	public String getGroupPath(String CompanyCode, String MemberOf) {
		String GroupPath = "";
		String SortPath = "";
		String OUPath = "";
		try {
			CoviMap params = new CoviMap();
			params.put("CompanyCode", CompanyCode);
			params.put("GroupCode", MemberOf);
			CoviMap returnList = selectGroupPath(params);

			GroupPath = returnList.getJSONArray("list").getJSONObject(0).getString("GroupPath");
			SortPath = returnList.getJSONArray("list").getJSONObject(0).getString("SortPath");
			OUPath = returnList.getJSONArray("list").getJSONObject(0).getString("OUPath");

		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		LOGGER.info(GroupPath + "&" + SortPath + "&" + OUPath);
		return GroupPath + "&" + SortPath + "&" + OUPath;
	}
	/**
	 * @description 그룹의 Path 관련 정보 조회
	 * @param params
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupPath(CoviMap params) throws Exception {

		CoviList list = coviMapperOne.list("organization.conf.manage.selectGroupInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GroupPath,SortPath,OUPath"));
		return resultList;
	}
	

	/**
	 * 엑셀다운로드
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectGroupExcelList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		String sField = ""; // 항목 설정
		CoviList list = null;
		int cnt = 0;
		

		if (params.get("groupType").toString().equalsIgnoreCase("dept")) { 
			params.put("EXCEL", "Y");
			sField = "UPPER_GroupCode,UPPER_LANG_DISPLAYNAME,LANG_DISPLAYNAME,GroupCode,SortKey,LANG_SHORTNAME,IsUse,IsHR,IsDisplay,PrimaryMail,MANAGERNAME,DEPT_FULL_PATH";
			//sField = "UPPER_GroupCode,UPPER_LANG_DISPLAYNAME,GroupCode,SortKey,LANG_DISPLAYNAME,LANG_SHORTNAME,IsUse,IsHR,IsDisplay,PrimaryMail,MANAGERNAME,DEPT_FULL_PATH";
			list = coviMapperOne.list("organization.conf.manage.selectAllDeptList", params);
			cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectAllDeptListCnt", params);
		}
		else if (params.get("groupType").toString().equalsIgnoreCase("group")) { // group
			sField = "DisplayName,SortKey,ShortName,PrimaryMail,IsUse,MEMBER_CNT";
			list = coviMapperOne.list("organization.conf.manage.selectAllGroupList", params);
			cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectAllGroupListCnt", params);
		}
		else if ("JOBTITLE".equals(params.get("groupType").toString().toUpperCase())
				||"JOBLEVEL".equals(params.get("groupType").toString().toUpperCase())
				||"JOBPOSITION".equals(params.get("groupType").toString().toUpperCase())
				||"REGION".equals(params.get("groupType").toString().toUpperCase())) { 
			sField = "LANG_DISPLAYNAME,SortKey,GroupCode,PrimaryMail,IsUse";
			list = coviMapperOne.list("organization.conf.manage.selectGroupListByGroupType", params);
			cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectGroupListByGroupTypeCnt", params);
		}
		else if(params.get("groupType").toString().equalsIgnoreCase("addjob")){
			sField = "LANG_USERNAME,LANG_COMPANYNAME,LANG_DEPTNAME,LANG_JOBTITLENAME,LANG_JOBPOSITIONNAME,LANG_JOBLEVELNAME";
			list = coviMapperOne.list("organization.conf.manage.selectAddJobList", params);
			cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectAddJobListCnt", params);
		}
		
		else if (params.get("groupType").toString().equalsIgnoreCase("user")) {
			sField = "LANG_DEPTNAME,LANG_DISPLAYNAME,SORTKEY,LANG_JOBTITLENAME,LANG_JOBPOSITIONNAME,LANG_JOBLEVELNAME,ISUSE,ISHR,ISDISPLAY,MAILADDRESS";
			list = coviMapperOne.list("organization.conf.manage.selectUserList", params);
			cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectUserListCnt", params);
		}
		else if (params.get("groupType").toString().equalsIgnoreCase("exDept")) {
			//sField = "GroupCode,CompanyCode,MemberOf,DisplayName,MultiDisplayName,SortKey,IsUse,IsHR,IsDisplay,IsMail,PrimaryMail,ManagerCode";
			sField = params.getString("headerKey");
			list = coviMapperOne.list("organization.conf.syncexcel.selectallDeptList", params);
			cnt = (int) coviMapperOne.getNumber("organization.conf.syncexcel.selectallDeptListCnt", params);
		}
		else if (params.get("groupType").toString().equalsIgnoreCase("exUser")) {
			//sField = "LicSeq,UserCode,CompanyCode,DeptCode,LogonID,LogonPW,EmpNo,DisplayName,MultiDisplayName,JobPositionCode,JobTitleCode,JobLevelCode,SortKey,IsUse,IsHR,IsDisplay,UseMailConnect,EnterDate,RetireDate,BirthDiv,BirthDate,PhotoPath,MailAddress,ExternalMailAddress,ChargeBusiness,PhoneNumberInter,PhoneNumber,Mobile,Fax,UseMessengerConnect";
			sField = params.getString("headerKey");

			list = coviMapperOne.list("organization.conf.syncexcel.selectallUserList", params);
			cnt = (int) coviMapperOne.getNumber("organization.conf.syncexcel.selectallUserListCnt", params);
		}
		/*
		else if (params.get("type").toString().equalsIgnoreCase("title")
				|| params.get("type").toString().equalsIgnoreCase("position")
				|| params.get("type").toString().equalsIgnoreCase("level")) {
			sField = "GroupCode,GroupName,SortKey,IsUse,IsHR,PrimaryMail,Description";
			list = coviMapperOne.list("organization.syncmanage.selectArbitraryGroupList", params);
			cnt = (int) coviMapperOne.getNumber("organization.syncmanage.selectArbitraryGroupListCnt", params);
		}
		else if (params.get("type").toString().equalsIgnoreCase("region")) {
			sField = "DomainName,GroupCode,GroupName,SortKey,IsUse,IsHR,PrimaryMail,Description";
			list = coviMapperOne.list("organization.syncmanage.selectRegionList", params);
			cnt = (int) coviMapperOne.getNumber("organization.syncmanage.selectRegionListCnt", params);
		}
		else if(params.get("type").toString().equalsIgnoreCase("addjob")){
			sField = "UserName,CompanyName,DeptName,JobTitleName,JobPositionName,JobLevelName,IsHR";
			list = coviMapperOne.list("organization.syncmanage.selectAddJobList", params);
			cnt = (int) coviMapperOne.getNumber("organization.syncmanage.selectAddJobListCnt", params);
		}
		else if (params.get("type").toString().equalsIgnoreCase("groupmember")) {
			sField = "Type,Code,CodeName,MailAddress";
			list = coviMapperOne.list("organization.syncmanage.selectGroupMemberList", params);
			cnt = (int) coviMapperOne.getNumber("organization.syncmanage.selectGroupMemberListCnt", params);
		}
		
		*/
		
		resultList.put("headerKey", sField);
		resultList.put("list", coviSelectJSONForExcel(list, sField));
		resultList.put("cnt", cnt);
		return resultList;
	}
	

	/**
	 * 엑셀 정보 리턴
	 * 
	 * @param clist
	 * @param str
	 * @return CoviList
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public static CoviList coviSelectJSONForExcel(CoviList clist, String str) throws Exception {
		String[] cols = str.split(",");

		CoviList returnArray = new CoviList();

		if (null != clist && clist.size() > 0) {
			for (int i = 0; i < clist.size(); i++) {

				CoviMap newObject = new CoviMap();

				for (int j = 0; j < cols.length; j++) {
					Set<String> set = clist.getMap(i).keySet();
					Iterator<String> iter = set.iterator();

					while (iter.hasNext()) {
						Object ar = iter.next();
						if (ar.equals(cols[j].trim())) {
							newObject.put(cols[j], clist.getMap(i).getString(cols[j]));
						}
					}
				}
				returnArray.add(newObject);
			}
		}
		return returnArray;
	}
	

	/**
	 * domainId로 회사정보 가져오기
	 * @param params - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectCompanyInfoGroupByDomainId(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.conf.manage.selectCompanyInfoGroupByDomainId", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "DomainCode,MailDomain,DomainID"));
		return resultList;
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//겸직
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * 겸직리스트 가져오기 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectAddJobList(CoviMap params) throws Exception {
		CoviMap resultList = null;
		CoviMap page = null;
		CoviList list = null;

		try {
			resultList = new CoviMap();
			params.put("lang", SessionHelper.getSession("lang"));
	 		if(params.containsKey("pageNo")) {
	 			int cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectAddJobListCnt", params);
	 			page = ComUtils.setPagingData(params,cnt);
	 			params.addAll(page);
	 			resultList.put("page", page);
	 		}
			list = coviMapperOne.list("organization.conf.manage.selectAddJobList", params);
			
			resultList.put("list", CoviSelectSet.coviSelectJSON(list,
					"NO,USERCODE,COMPANYCODE,LANG_COMPANYNAME,DEPTCODE,LANG_DEPTNAME,JOBTITLECODE,LANG_JOBTITLENAME"
					+ ",JOBPOSITIONCODE,LANG_JOBPOSITIONNAME,JOBLEVELCODE,JOBTYPE,LANG_JOBLEVELNAME,ISHR,SORTKEY,LANG_USERNAME"));
			

		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return resultList;
	}
	/**
	 * 겸직상세정보 가져오기 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectAddJobInfoData(CoviMap params) throws Exception {
		CoviMap resultList = null;
		CoviList list = null;
		int cnt = 0;

		try {
			params.put("lang", SessionHelper.getSession("lang"));
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.conf.manage.selectAddJobInfo", params);

			resultList.put("list", CoviSelectSet.coviSelectJSON(list,
					"NO,USERCODE,JOBTYPE,USERNAME,MULTIUSERNAME,COMPANYCODE,COMPANYNAME,MULTICOMPANYNAME,DEPTCODE,DEPTNAME"
					+ ",MULTIDEPTNAME,JOBTITLECODE,JOBTITLENAME,MULTIJOBTITLENAME,JOBPOSITIONCODE,JOBPOSITIONNAME,MULTIJOBPOSITIONNAME"
					+ ",JOBLEVELCODE,JOBTYPE,JOBLEVELNAME,MULTIJOBLEVELNAME,ISHR"));
			resultList.put("cnt", cnt);

		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return resultList;
	}
	/**
	 * 임의 그룹 드롭다운 목록 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectArbitraryGroupDropdownlist(CoviMap params) throws Exception {

		CoviMap resultList = null;
		CoviList list = null;

		try {
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.conf.manage.selectArbitraryGroupDropdownlist", params);

			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "GROUPTYPE,GROUPCODE,GROUPNAME"));

		} catch (NullPointerException e){
			LOGGER.error("selectArbitraryGroupDropdownlist Error  " + "[Message : " + e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("selectArbitraryGroupDropdownlist Error  " + "[Message : " + e.getMessage() + "]");
		}

		return resultList;

	}
 
	/**
	 * 겸직 추가
	 * 
	 * @param params CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int insertAddjob(CoviMap params) throws Exception {
		int iReturn = 0;

		try {
			LOGGER.debug("insertAddjob execute [" + params.get("UserCode") + "]");

			// 1. insert to sys_object_user_basegroup
			LOGGER.debug("insertAddjob - insertUserBasegroupInfo execute");
			iReturn = coviMapperOne.insert("organization.syncmanage.insertUserBasegroupInfo", params);
			LOGGER.debug("insertAddjob - insertUserBasegroupInfo execute complete");
			// 2. delete to sys_object_group_member
			LOGGER.debug("insertAddjob - deleteUserGroupDefaultMember execute");
			iReturn += coviMapperOne.delete("organization.syncmanage.deleteUserGroupDefaultMember", params);
			LOGGER.debug("insertAddjob - deleteUserGroupDefaultMember execute complete");
			// 3. insert to sys_object_group_member
			LOGGER.debug("insertAddjob - insertUserGroupMember execute");
			iReturn += coviMapperOne.insert("organization.syncmanage.insertGroupMemberUser", params);
			LOGGER.debug("insertAddjob - insertUserGroupMember execute complete");

			params.put("SyncStatus", 'Y');
			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 겸직 추가됨";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "ADDJOB", "INSERT", strLog, "");
			}
		} catch (NullPointerException ex){
			params.put("SyncStatus", 'N');
			LOGGER.error("insertAddjob Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : " + ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 겸직 추가 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "ADDJOB", "INSERT", strLog, "");
			}
		} 
		catch (Exception ex) {
			params.put("SyncStatus", 'N');
			LOGGER.error("insertAddjob Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : " + ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 겸직 추가 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "ADDJOB", "INSERT", strLog, "");
			}
		} 
		finally {
			coviMapperOne.insert("organization.syncmanage.insertAddJobLogList", params);
		}

		return iReturn;
	}
	/**
	 * 겸직 수정
	 * 
	 * @param params CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int updateAddjob(CoviMap params) throws Exception {
		int bReturn = 0;

		try {
			LOGGER.debug("updateAddjob execute [" + params.get("UserCode") + "]");
			// 1.겸직 삭제
			bReturn = deleteAddjob(params);
			// 2.겸직추가 (SYS_OBJECT_USER_BASEGROUP Insert)
			bReturn += insertAddjob(params);

			LOGGER.debug("updateAddjob - updateObjectUserBasegroup execute complete");
			params.put("SyncStatus", 'Y');
			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 겸직 수정됨";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "ADDJOB", "UPDATE", strLog, "");
			}
		} catch (NullPointerException ex){
			params.put("SyncStatus", 'N');
			LOGGER.error("updateAddjob Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : " + ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 겸직 수정 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "ADDJOB", "UPDATE", strLog, "");
			}
		} 
		catch (Exception ex) {
			params.put("SyncStatus", 'N');
			LOGGER.error("updateAddjob Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : " + ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 겸직 수정 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "ADDJOB", "UPDATE", strLog, "");
			}
		}

		return bReturn;
	}
	/**
	 * 겸직 삭제
	 * 
	 * @param params CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public int deleteAddjob(CoviMap params) throws Exception {
		int iReturn = 0;

		try {
			LOGGER.debug("deleteAddjob execute [" + params.get("UserCode") + "]");

			LOGGER.debug("deleteAddjob - deleteObjectUserBasegroup execute");
			iReturn = coviMapperOne.update("organization.syncmanage.deleteObjectUserBasegroup", params);

			if (iReturn > 0) {
				iReturn = coviMapperOne.delete("organization.syncmanage.deleteUserGroupDefaultMember", params);
			}
			
			if (iReturn > 0) {
				iReturn = coviMapperOne.delete("organization.syncmanage.insertGroupMemberUser", params);
				params.put("SyncStatus", 'Y');
				
				if ("Sync".equals(params.getString("SyncManage"))) {
					String strLog = "사용자 ";
					strLog += "[" + params.get("UserCode") + "] 겸직 삭제됨";
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "ADDJOB", "DELETE", strLog, "");
				}
			}
		} catch (NullPointerException ex){
			params.put("SyncStatus", 'N');
			LOGGER.error("deleteAddjob Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : " + ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 겸직 삭제 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "ADDJOB", "DELETE", strLog, "");
			}
		} 
		catch (Exception ex) {
			params.put("SyncStatus", 'N');
			LOGGER.error("deleteAddjob Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : " + ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 겸직 삭제 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "ADDJOB", "DELETE", strLog, "");
			}
		} 
		finally {
			coviMapperOne.insert("organization.syncmanage.insertAddJobLogList", params);
		}
		
		return iReturn;
	}

	/**
	 * 겸직 정보 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectAddJobInfoList(CoviMap params) throws Exception {

		CoviMap resultList = null;
		CoviList list = null;

		try {
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.syncmanage.selectAddJobInfoList", params);

			resultList.put("list", CoviSelectSet.coviSelectJSON(list,
					"NO,UserCode,UserName,LogonID,DisplayName,CompanyCode,DeptCode,JobTitleCode,JobPositionCode,JobLevelCode,JobType,CompanyName,DeptName,JobTitleName,JobPositionName,JobLevelName,IsHR"));

		} catch (NullPointerException e){
			LOGGER.error("selectAddJobInfoList Error  " + "[Message : " + e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("selectAddJobInfoList Error  " + "[Message : " + e.getMessage() + "]");
		}

		return resultList;
	}

	/**
	 * 사용자 겸직 정보 cnt
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectUserAddJobListCnt(CoviMap params) throws Exception {
		CoviMap resultList = null;
		int cnt = 0;

		try {
			resultList = new CoviMap();
			cnt = (int) coviMapperOne.getNumber("organization.syncmanage.selectUserAddJobListCnt", params);

			resultList.put("cnt", cnt);
		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}
		return resultList;
	}
	/**
	 * 사용자 그룹정보
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectUserGroupList(CoviMap params) throws Exception {

		CoviMap resultList = null;
		CoviList list = null;

		try {
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.conf.manage.selectUserGroupList", params);

			resultList.put("list", CoviSelectSet.coviSelectJSON(list,"groupCode,PrimaryMail"));

		} catch (NullPointerException e){
			LOGGER.error("selectAddJobInfoList Error  " + "[Message : " + e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("selectAddJobInfoList Error  " + "[Message : " + e.getMessage() + "]");
		}

		return resultList;
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// 사용자
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * 사용자 목록 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectUserList(CoviMap params) throws Exception {
		CoviMap resultList = null;
		CoviMap page = null;
		CoviList list = null;

		try {
			resultList = new CoviMap();
			if(params.containsKey("pageNo")) {
	 			int cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectUserListCnt", params);
	 			page = ComUtils.setPagingData(params,cnt);
	 			params.addAll(page);
	 			resultList.put("page", page);
	 		}
			list = coviMapperOne.list("organization.conf.manage.selectUserList", params);

			resultList.put("list", CoviSelectSet.coviSelectJSON(list,"USERID,USERCODE,SORTKEY,LANG_DISPLAYNAME,LANG_JOBTITLENAME,LANG_JOBPOSITIONNAME,LANG_JOBLEVELNAME,ISUSE,ISHR,MAILADDRESS,ISDISPLAY"));
			

		} catch (NullPointerException e){
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return resultList;
	}
	
	


	/**
	 * 사용자 정보 insert
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int insertUser(CoviMap params) throws Exception {
		int returnCnt = 0;

		try {
			LOGGER.debug("insertUser execute [" + params.get("UserCode") + "]");
			params.put("aeskey", aeskey);
			params.put("isSaaS", (isSaaS)?"Y":"N");

			//0.LogonID Dup Check
			LOGGER.debug("insertUser - checkDupLogonID execute");
			returnCnt = (int)coviMapperOne.getNumber("organization.syncmanage.selectDupLogonIDCnt", params);
			if(returnCnt != 0) {
				LOGGER.error("insertUser - checkDupLogonID Failed");
				throw new Exception("insertUser - checkDupLogonID Failed");
			}else {
				LOGGER.debug("insertUser - checkDupLogonID execute complete");
			}

			// 1. insert to sys_object
			LOGGER.debug("insertUser - insertObject execute");
			returnCnt = coviMapperOne.insert("organization.syncmanage.insertObject", params);
			if (returnCnt != 1) {
				LOGGER.error("insertUser - insertObject Failed");
				throw new Exception();
			}
			else {
				LOGGER.debug("insertUser - insertObject execute complete");
			}

			// 2. insert to sys_object_user
			LOGGER.debug("insertUser - insertUserDefaultInfo execute [" + params.get("UserCode") + "]");
			returnCnt = coviMapperOne.insert("organization.conf.manage.insertUserDefaultInfo", params);
			LOGGER.debug("insertUser - insertUserDefaultInfo execute complete");

			if (returnCnt == 1) {
				// 3. insert to sys_object_user_info
				LOGGER.debug("insertUser - insertUserDefaultInfo2 execute [" + params.get("UserCode") + "]");
				returnCnt += coviMapperOne.insert("organization.syncmanage.insertUserDefaultInfo2", params);
				LOGGER.debug("insertUser - insertUserDefaultInfo2 complete complete");
			}

			if (returnCnt == 2) {
				// 4. insert to sys_object_user_basegroup
				LOGGER.debug("insertUser - insertUserBasegroupInfo execute [" + params.get("UserCode") + "]");
				returnCnt += coviMapperOne.insert("organization.syncmanage.insertUserBasegroupInfo", params);
				LOGGER.debug("insertUser - insertUserBasegroupInfo execute complete");
			}

			if (returnCnt == 3) {
				// 5. insert to sys_object_user_approval
				LOGGER.debug("insertUser - insertUserApprovalInfo execute [" + params.get("UserCode") + "]");
				returnCnt += coviMapperOne.insert("organization.syncmanage.insertUserApprovalInfo", params);
				LOGGER.debug("insertUser - insertUserApprovalInfo execute complete");
			}

			if (returnCnt == 4) {
				// 6. insert to sys_object_group_member
				LOGGER.debug("insertUser - insertUserGroupMember execute");
				returnCnt += coviMapperOne.insert("organization.syncmanage.insertUserGroupMember", params);
				LOGGER.debug("insertUser - insertUserGroupMember execute complete");
				params.put("SyncStatus", 'Y');
				if ("Sync".equals(params.getString("SyncManage"))) {
					String strLog = "사용자 ";
					strLog += "[" + params.get("UserCode") + "] 추가됨";
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "USER", "INSERT", strLog, "");
				}
			}

			// 6. update to sys_object_user photopath
			if ("Manage".equals(params.getString("SyncManage"))) {
				returnCnt += updateOrgUserPhotoPath(params);
			}
			else {
				if (RedisDataUtil.getBaseConfig("PhotoSync").equalsIgnoreCase("URL")) {
					returnCnt += getImagefromUrl(params.get("PhotoPath").toString(), params.get("UserCode").toString(),
							params.get("PhotoDate").toString()); // 연동할 때 사진 변경일자 필요
				} 
				else if (RedisDataUtil.getBaseConfig("PhotoSync").equalsIgnoreCase("API")) {
					returnCnt += convertBase64toImage(params); // 연동할 때 사진 변경일자 필요
				}
			}
		} catch (NullPointerException ex){
			params.put("SyncStatus", 'N');
			LOGGER.error("insertUser Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : " + ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 추가 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "USER", "INSERT", strLog, "");
			}
		} 
		catch (Exception ex) {
			params.put("SyncStatus", 'N');
			LOGGER.error("insertUser Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : " + ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 추가 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "USER", "INSERT", strLog, "");
			}
		} 
		finally {
			coviMapperOne.insert("organization.syncmanage.insertUserLogList", params);
		}

		return returnCnt;
	}

	/**
	 * 사용자 정보 update
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateUser(CoviMap params) throws Exception {
		int returnCnt = 0;
		try {
			LOGGER.debug("updateUser execute [" + params.get("UserCode") + "]");

			// 1. update to sys_object
			LOGGER.debug("updateUser - updateObject execute [" + params.get("UserCode") + "]");
			returnCnt = coviMapperOne.update("organization.syncmanage.updateObject", params);
			LOGGER.debug("updateUser - updateObject execute complete");

			// 2. update to sys_object_user
			LOGGER.debug("updateUser - updateUserDefaultInfo execute [" + params.get("UserCode") + "]");
			returnCnt = coviMapperOne.update("organization.conf.manage.updateUserDefaultInfo", params);
			LOGGER.debug("updateUser - updateUserDefaultInfo execute complete");

			if (returnCnt < 2) {
				// 3. insert to sys_object_user_info
				LOGGER.debug("insertUser - updateUserDefaultInfo2 execute [" + params.get("UserCode") + "]");
				returnCnt += coviMapperOne.update("organization.syncmanage.updateUserDefaultInfo2", params);
				LOGGER.debug("insertUser - updateUserDefaultInfo2 complete complete");
			}

			if (returnCnt < 3) {
				// 4. update to sys_object_user_basegroup
				LOGGER.debug("updateUser - updateUserBaseGroupInfo execute [" + params.get("UserCode") + "]");

				if ((int) coviMapperOne.getNumber("organization.syncmanage.selectUserBaseGroupInfoCnt", params) > 0) {
					returnCnt += coviMapperOne.insert("organization.syncmanage.updateUserBaseGroupInfo", params);
				} 
				else {
					returnCnt += coviMapperOne.insert("organization.syncmanage.insertUserBasegroupInfo", params);
				}

				LOGGER.debug("updateUser - updateUserBaseGroupInfo execute complete");
			}

			if (returnCnt < 4) {
				// 5. update to sys_object_user_approval
				if (RedisDataUtil.getBaseConfig("IsUseApprovalSet").equals("Y")) {
					LOGGER.debug("updateUser - updateUserApprovalInfo execute [" + params.get("UserCode") + "]");
					returnCnt += coviMapperOne.insert("organization.syncmanage.updateUserApprovalInfo", params);
					LOGGER.debug("updateUser - updateUserApprovalInfo execute complete");
				} 
				else returnCnt += 1;
			}

			if (returnCnt < 5) {
				// 6. delete to sys_object_group_member
				LOGGER.debug("updateUser - deleteUserGroupDefaultMember execute [" + params.get("UserCode") + "]");
				returnCnt += coviMapperOne.delete("organization.syncmanage.deleteUserGroupDefaultMember", params);
				LOGGER.debug("updateUser - deleteUserGroupDefaultMember execute complete");

				// 7. insert to sys_object_group_member
				LOGGER.debug("updateUser - insertUserGroupMember execute [" + params.get("UserCode") + "]");
				returnCnt += coviMapperOne.insert("organization.syncmanage.insertUserGroupMember", params);
				LOGGER.debug("updateUser - insertUserGroupMember execute complete");

				params.put("SyncStatus", 'Y');
				if ("Sync".equals(params.getString("SyncManage"))) {
					String strLog = "사용자 ";
					strLog += "[" + params.get("UserCode") + "] 수정됨";
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "USER", "UPDATE", strLog, "");
				}
			}

			// 8. update to sys_object_user photopath
			if ("Manage".equals(params.getString("SyncManage"))) {
				LOGGER.debug("updateUser - updateOrgUserPhotoPath execute [" + params.get("UserCode") + "]");
				returnCnt += updateOrgUserPhotoPath(params);
				LOGGER.debug("updateUser - updateOrgUserPhotoPath execute complete");
			} 
			else {
				if (RedisDataUtil.getBaseConfig("PhotoSync").equalsIgnoreCase("URL")) {
					returnCnt += getImagefromUrl(params.get("PhotoPath").toString(), params.get("UserCode").toString(),
							params.get("PhotoDate").toString()); // 연동할 때 사진 변경일자 필요
				} 
				else if (RedisDataUtil.getBaseConfig("PhotoSync").equalsIgnoreCase("API")) {
					returnCnt += convertBase64toImage(params); // 연동할 때 사진 변경일자 필요
				}
			}
		} catch (NullPointerException ex){
			params.put("SyncStatus", 'N');
			LOGGER.error("updateUser Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : "
					+ ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 수정 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "USER", "UPDATE", strLog, "");
			}
		}
		catch (Exception ex) {
			params.put("SyncStatus", 'N');
			LOGGER.error("updateUser Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : "
					+ ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 수정 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "USER", "UPDATE", strLog, "");
			}
		}
		finally {
			coviMapperOne.insert("organization.syncmanage.insertUserLogList", params);
		}
		
		return returnCnt;
	}

	/**
	 * 사용자 정보 delete
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int deleteUser(CoviMap params) throws Exception {
		int returnCnt = 0;
		try {
			LOGGER.debug("deleteUser execute [" + params.get("UserCode") + "]");

			// 1. delete from sys_object
			LOGGER.debug("deleteUser - deleteObject execute");
			returnCnt = coviMapperOne.update("organization.syncmanage.deleteObject", params);
			LOGGER.debug("deleteUser - deleteObject execute complete");

			// 2. delete from sys_object_user
			LOGGER.debug("deleteUser - deleteUser execute [" + params.get("UserCode") + "]");
			returnCnt = coviMapperOne.update("organization.syncmanage.deleteUser", params);
			LOGGER.debug("deleteUser - deleteUser execute complete");

			if (returnCnt == 1) {
				// 3. delete from sys_object_user_basegroup
				LOGGER.debug("deleteUser - deleteUserBaseGroup execute [" + params.get("UserCode") + "]");
				returnCnt += coviMapperOne.update("organization.syncmanage.deleteUserBaseGroup", params);
				LOGGER.debug("deleteUser - deleteUserBaseGroup execute complete");
			}

			if (returnCnt == 2) {
				// 4. delete from sys_object_user_basegroup (AddJob)
				LOGGER.debug("deleteUser - deleteAddJobBaseGroup execute [" + params.get("UserCode") + "]");
				coviMapperOne.delete("organization.syncmanage.deleteAddJobBaseGroup", params);
				LOGGER.debug("deleteUser - deleteAddJobBaseGroup execute");

				// 5. delete from sys_object_group_member
				LOGGER.debug("deleteUser - deleteUserGroupMember execute [" + params.get("UserCode") + "]");
				returnCnt += coviMapperOne.delete("organization.syncmanage.deleteUserGroupMember", params);
				LOGGER.debug("deleteUser - deleteUserGroupMember execute");
			}

			if (returnCnt > 2) {
				// 5. delete from sys_object_group_member
				LOGGER.debug("deleteUser - insertRetiredGroupMember execute [" + params.get("UserCode") + "]");
				returnCnt += coviMapperOne.insert("organization.syncmanage.insertRetiredGroupMember", params);
				LOGGER.debug("deleteUser - insertRetiredGroupMember execute");
				params.put("SyncStatus", 'Y');
				
				if ("Sync".equals(params.getString("SyncManage"))) {
					String strLog = "사용자 ";
					strLog += "[" + params.get("UserCode") + "] 삭제됨";
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "USER", "DELETE", strLog, "");
				}
			}
		} catch (NullPointerException ex){
			params.put("SyncStatus", 'N');
			LOGGER.error("deleteUser Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : "
					+ ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 삭제 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "USER", "DELETE", strLog, "");
			}
		} 
		catch (Exception ex) {
			params.put("SyncStatus", 'N');
			LOGGER.error("deleteUser Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : "
					+ ex.getMessage() + "]", ex);

			if ("Sync".equals(params.getString("SyncManage"))) {
				String strLog = "사용자 ";
				strLog += "[" + params.get("UserCode") + "] 삭제 실패";
				strLog += "[Message : " + ex.getMessage() + "]";
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "USER", "DELETE", strLog, "");
			}
		} 
		finally {
			coviMapperOne.insert("organization.syncmanage.insertUserLogList", params);
		}
		return returnCnt;
	}
	/**
	 * 자동동기화 사용자 사진정보 업데이트
	 */
	@Override
	public int convertBase64toImage(CoviMap params) throws Exception {
		int retCnt = 0;

		String apiURL = null;
		String method = "GET";

		SimpleDateFormat dformat = new SimpleDateFormat("yyyyMMdd");
		Calendar today = Calendar.getInstance();
		today.add(Calendar.DATE, -2);
		int beforeday = Integer.parseInt(dformat.format(today.getTime()));

		if (!params.getString("PhotoPath").equals("") && !params.getString("PHOTO_DATE").equals("") && beforeday <= Integer.parseInt(params.getString("PHOTO_DATE"))) {
			try {
				final String path = RedisDataUtil.getBaseConfig("ProfileImagePath");
				apiURL = RedisDataUtil.getBaseConfig("PhotoAPI");
				LOGGER.debug(apiURL);

				String sPERSONID = params.get("PERSONID").toString();

				apiURL = apiURL + sPERSONID;
				CoviMap jObj = getJson(apiURL, method);

				if (jObj.get("code").toString().equals("200") && jObj.get("success").toString().equalsIgnoreCase("true")) {
					String companyCode = SessionHelper.getSession("DN_Code");
					String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);
					
					File target = new File(FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + backStorage + path + sPERSONID + ".jpg");
					
					byte[] imageByte = Base64.decodeBase64(jObj.get("data").toString());
					
					try (FileOutputStream fos = new FileOutputStream(target);) {						
						boolean bReturn = target.createNewFile();
						
						if (!bReturn)
							throw new IOException("convertBase64toImage : Fail to create new file.");

						fos.write(imageByte);

						params.put("PhotoPath", path + sPERSONID + ".jpg");
						params.put("UserCode", params.getString("UserCode"));

						retCnt = coviMapperOne.update("organization.syncmanage.updateOrgUserPhotoPath", params);
						
						if (retCnt > 0) {
							if ("Sync".equals(params.getString("SyncManage"))) {
								insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "UR",
										"DB", "ConvertBase64toImage success [" + params.get("UserCode") + "]", "");
							}
						}
					}
				} else {
					if ("Sync".equals(params.getString("SyncManage"))) {
						insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "DB",
								"ConvertBase64toImage Error [ObjectCode : " + params.get("UserCode") + "] "
										+ "[Message : " + jObj.get("message").toString() + "]",
								"");
						insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "DB",
								"ConvertBase64toImage Error [ObjectCode : " + params.get("UserCode") + "] "
										+ "[StackTrace : " + jObj.get("message").toString() + "]",
								"");
					}
				}

			} catch (NullPointerException e){
				if ("Sync".equals(params.getString("SyncManage"))) {
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "DB",
							"ConvertBase64toImage Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : "
									+ e.getMessage() + "]",
							"");
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			} catch (Exception e) {
				if ("Sync".equals(params.getString("SyncManage"))) {
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "DB",
							"ConvertBase64toImage Error [ObjectCode : " + params.get("UserCode") + "] " + "[Message : "
									+ e.getMessage() + "]",
							"");
					LOGGER.error(e.getLocalizedMessage(), e);
				}
			}
		}

		return retCnt;
	}
	

	/**
	 * 사용자 사진정보 업데이트 - 관리자화면
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateOrgUserPhotoPath(CoviMap params) throws Exception {
		FileOutputStream out = null;
		int retCnt = 0;

		if (!params.getString("PhotoPath").equals("")) {
			try {
				final String path = RedisDataUtil.getBaseConfig("ProfileImageFolderPath");
				String companyCode = SessionHelper.getSession("DN_Code");
				String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);

				// 0. 디렉토리, 파일 체크
				if(awsS3.getS3Active()) {
					String dir = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + backStorage + path;
					String key = dir+"/"+params.getString("UserCode");
					if(awsS3.exist(key)){
						awsS3.delete(key);
					}
					String key2 = dir+"/"+params.getString("UserCode") + "_org";
					if(awsS3.exist(key2)){
						awsS3.delete(key2);
					}
					String orgKey = dir+"/"+params.getString("UserCode") + "_org.jpg";
					// 1. 파일 생성(리사이즈, 원본)
					MultipartFile mFile = (MultipartFile) params.get("FileInfo");
					awsS3.upload(mFile.getInputStream(), orgKey, mFile.getContentType(), mFile.getSize());
					String thumKey = FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1)
							+ backStorage + path + params.getString("UserCode") + ".jpg";

					fileUtilSvc.makeThumb(thumKey, mFile.getInputStream(), FilenameUtils.getExtension(mFile.getName())); //썸네일 저장
				}else {
					File dir = new File(
							FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1) + backStorage + path);
					if (!dir.exists()) {
						boolean dReturn = dir.mkdirs();
						if (!dReturn)
							throw new IOException("updateOrgUserPhotoPath : Unable to create path.");
					}

					File existFile = new File(dir, params.getString("UserCode"));
					if (existFile.exists()) {
						boolean dReturn = existFile.delete();

						dReturn = new File(dir, params.getString("UserCode") + "_org").delete();

						if (!dReturn)
							throw new IOException("updateOrgUserPhotoPath : Fail to delete file.");
					}

					// 1. 파일 생성(리사이즈, 원본)
					MultipartFile mFile = (MultipartFile) params.get("FileInfo");
					File file = new File(dir, params.getString("UserCode") + "_org.jpg");
					mFile.transferTo(file);

					Image src = ImageIO.read(file);
					BufferedImage resizeImage = new BufferedImage(200, 200, BufferedImage.TYPE_INT_RGB);
					resizeImage.getGraphics().drawImage(src.getScaledInstance(200, 200, Image.SCALE_SMOOTH), 0, 0, null);
					out = new FileOutputStream(FileUtil.getBackPath().substring(0, FileUtil.getBackPath().length() - 1)
							+ backStorage + path + params.getString("UserCode") + ".jpg");
					ImageIO.write(resizeImage, "jpg", out);
				}

				// 2. photoPath 업데이트
				params.put("PhotoPath", RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode) + path
						+ params.getString("UserCode") + ".jpg");
				params.put("UserCode", params.getString("UserCode"));

				retCnt = coviMapperOne.update("organization.syncmanage.updateOrgUserPhotoPath", params);
				if (retCnt > 0) {
					if ("Sync".equals(params.getString("SyncManage"))) {
						insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "UR", "DB",
								"updateOrgUserPhotoPath success [" + params.get("UserCode") + "]", "");
					}
				}
			} catch (NullPointerException ex){
				if ("Sync".equals(params.getString("SyncManage"))) {
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "DB",
							"updateOrgUserPhotoPath Error [ObjectCode : " + params.get("UserCode") + "] "
									+ "[Message : " + ex.getMessage() + "]",
							"");
					LOGGER.error(ex.getLocalizedMessage(), ex);
				}
			} 
			catch (Exception ex) {
				if ("Sync".equals(params.getString("SyncManage"))) {
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "DB",
							"updateOrgUserPhotoPath Error [ObjectCode : " + params.get("UserCode") + "] "
									+ "[Message : " + ex.getMessage() + "]",
							"");
					LOGGER.error(ex.getLocalizedMessage(), ex);
				}
			} 
			finally {
				if (out != null) {
					out.close();
				}
			}
		}
		return retCnt;
	}

	/**
	 * URL 사진 경로에서 이미지 생성하기
	 *
	 * @param strUrl String
	 * @param strUserCode String
	 * @param strPhotoDate String
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int getImagefromUrl(String strUrl, String strUserCode, String strPhotoDate) throws Exception {
		int iReturn = 0;
		final String path = RedisDataUtil.getBaseConfig("ProfileImagePath");
		URL url = null;
		CoviMap params = new CoviMap();

		SimpleDateFormat dformat = new SimpleDateFormat("yyyyMMdd");
		Calendar today = Calendar.getInstance();
		today.add(Calendar.DATE, -2);
		int beforeday = Integer.parseInt(dformat.format(today.getTime()));

		if (!strUrl.equals("") && !strPhotoDate.equals("") && beforeday <= Integer.parseInt(strPhotoDate)) {
			InputStream in = null;
			OutputStream out = null;
			try {
				url = new URL(strUrl);
				in = url.openStream();
				
				out = new FileOutputStream(FileUtil.checkTraversalCharacter(FileUtil.getBackPath() + path + strUserCode + ".jpg"));

				while (true) {
					int data = in.read();
					if (data == -1) {
						break;
					}
					out.write(data);
				}

				params.put("PhotoPath", path + strUserCode + ".jpg");
				params.put("UserCode", strUserCode);

				iReturn = coviMapperOne.update("organization.syncmanage.updateOrgUserPhotoPath", params);

			} catch (IOException e){
				LOGGER.error(e.getLocalizedMessage(), e);
			} catch (Exception e) {
				LOGGER.error(e.getLocalizedMessage(), e);
			} finally {
				if (in != null) {
					try{in.close();}catch(IOException e) {LOGGER.error(e.getLocalizedMessage());}
				}
				if (out != null) {
					try{out.close();}catch(IOException e) {LOGGER.error(e.getLocalizedMessage());}
				}
			}
		}
		return iReturn;
	}
	
	/**
	 * 사용자 비밀번호 초기화
	 * 
	 * @param params
	 *            - CoviMap
	 * @return String
	 * @throws Exception
	 */
	@Override
	public String resetUserPassword(CoviMap params) throws Exception {
		String sNewPassword = null;
		params.put("aeskey", aeskey);
		StringBuffer sTemp = new StringBuffer();
		int mCount = 0;

		try {
			if (!RedisDataUtil.getBaseConfig("InitPassword").equals("")) {
				sNewPassword = RedisDataUtil.getBaseConfig("InitPassword");

			} else {
				SecureRandom rnd = new SecureRandom();				
				for (int i = 0; i < 10; i++) {
					int iIndex = rnd.nextInt(3);
					switch (iIndex) {
					case 0:
						sTemp.append((char) ((int) (rnd.nextInt(26)) + 97));
						break;
					case 1:
						sTemp.append((char) ((int) (rnd.nextInt(26)) + 65));
						break;
					case 2:
						sTemp.append(rnd.nextInt(10));
						break;
					default :
						break;
					}
				}
				sNewPassword = sTemp.toString();
				LOGGER.debug("비밀번호 랜덤 생성 : " + sNewPassword);
			}
			params.put("sNewPassword", sNewPassword);

			mCount = coviMapperOne.update("organization.conf.manage.resetUserPassword", params);
			if (mCount == 1) {
				coviMapperOne.update("organization.conf.manage.resetUserPasswordLock", params);
			}
		} catch (NullPointerException e){
			sNewPassword = "FAIL";
			LOGGER.error("resetUserPassword Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} catch (Exception e) {
			sNewPassword = "FAIL";
			LOGGER.error("resetUserPassword Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		}
		return sNewPassword;
	}
	
	/**
	 * 사용자 정보 중복 체크
	 * 
	 * @param params
	 *            - CoviMap
	 * @return CoviMap - 중복 여부
	 * @throws Exception
	 */
	@Override
	public CoviMap selectIsDuplicateUserInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.conf.manage.selectIsDuplicateUserInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate"));
		return resultList;
	}
	
	/**
	 * 사용자 사번 중복 체크 (SaaS)
	 * 
	 * @param params
	 *            - CoviMap
	 * @return CoviMap - 중복 여부
	 * @throws Exception
	 */
	@Override
	public CoviMap selectIsDuplicateEmpno(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.conf.manage.selectIsDuplicateEmpno", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "isDuplicate"));
		return resultList;
	}
	
	/**
	 * 비밀번호 정책 확인
	 * 
	 * @param params
	 *            - CoviMap
	 * @return json
	 * @throws Exception
	 */
	@Override
	public CoviMap usePWPolicyCheck(CoviMap params) throws Exception {
		CoviList list = null;

		int cnt = (int) coviMapperOne.getNumber("organization.syncmanage.updatePasswordPolicyCount", params);

		if (cnt > 0) {
			list = coviMapperOne.list("organization.syncmanage.getPolicy", params);
		} else {
			params.clear();
			params.put("DomainCode", "ORGROOT");

			list = coviMapperOne.list("organization.syncmanage.getPolicy", params);
		}

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list,
				"DomainID,IsUseComplexity,MaxChangeDate,MinimumLength,ChangeNoticeDate"));

		return resultList;
	}

	/**
	 * 사용자 사용 여부 update
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsUseUser(CoviMap params) throws Exception {
		return coviMapperOne.update("organization.syncmanage.updateIsUseUser", params);
	};

	/**
	 * 사용자 인사 연동 여부 update
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsHRUser(CoviMap params) throws Exception {
		return coviMapperOne.update("organization.syncmanage.updateIsHRUser", params);
	}

	/**
	 * 사용자 display 여부 update
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int - update 결과 상태
	 * @throws Exception
	 */
	@Override
	public int updateIsDisplayUser(CoviMap params) throws Exception {
		return coviMapperOne.update("organization.conf.manage.updateIsDisplayUser", params);
	} 
	/**
	 * 라이선스정보 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectLicenseInfo(CoviMap params) throws Exception {

		CoviMap resultList = null;
		CoviList list = null;
		
		try {
			params.put("licSection", licSection);
			if(!isSaaS){
				params.put("domainId", "0");
				params.put("domainCode", "ORGROOT");
			}
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.conf.manage.selectLicenseInfo", params);

			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "LicSeq,LicName,LicMail"));

		} catch (NullPointerException e){
			LOGGER.error("selectLicenseInfo Error  " + "[Message : " + e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("selectLicenseInfo Error  " + "[Message : " + e.getMessage() + "]");
		}

		return resultList;

	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//인디메일,타임스퀘어
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * 서비스 유형 select
	 *
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectServiceTypeList() throws Exception {

		CoviList list = coviMapperOne.list("organization.syncmanage.selectServiceTypeList", null);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "optionValue,optionText"));
		return resultList;
	}
	
	
	/**
	 * 사용자 정보 가져오기 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectUserInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.conf.manage.selectUserInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list,
				"UserID,UserCode,LogonID,EmpNo,DisplayName,MultiDisplayName,NickName,MultiAddress,HomePage,PhoneNumber"
				+ ",Mobile,FAX,IPPhone,UseMessengerConnect,SortKey,SecurityLevel,Description,IsUse,IsHR,IsDisplay,EnterDate"
				+ ",RetireDate,PhotoPath,BirthDiv,BirthDate,UseMailConnect,MailAddress,ExternalMailAddress,ChargeBusiness"
				+ ",PhoneNumberInter,Reserved2,Reserved3,Reserved4,ManagerName,Reserved5,CompanyCode,MultiCompanyName,DeptCode"
				+ ",DeptName,MultiDeptName,RegionCode,MultiRegionName,JobPositionCode,JobTitleCode,JobLevelCode,JobPositionName"
				+ ",JobTitleName,JobLevelName,DeputyOption,UseDeputy,DeputyOption,DeputyCode,DeputyName,DeputyFromDate,DeputyToDate,AlertConfig"
				+ ",ApprovalUnitCode,ApprovalUnitName,ReceiptUnitCode,ReceiptUnitName,UseApprovalMessageBoxView,UseMobile,DomainID"
				+ ",CheckUserIP,StartIP,EndIP,AD_DISPLAYNAME,AD_FIRSTNAME,AD_LASTNAME,AD_INITIALS,AD_OFFICE,AD_HOMEPAGE,AD_COUNTRY,AD_COUNTRYID,AD_COUNTRYCODE"
				+ ",AD_STATE,AD_CITY,AD_STREETADDRESS,AD_POSTOFFICEBOX,AD_POSTALCODE,AD_USERACCOUNTCONTROL,AD_ACCOUNTEXPIRES,AD_PHONENUMBER,AD_HOMEPHONE,AD_PAGER"
				+ ",AD_MOBILE,AD_FAX,AD_IPPHONE,AD_INFO,AD_TITLE,AD_DEPARTMENT,AD_COMPANY,AD_MANAGERCODE,EX_PRIMARYMAIL,EX_SECONDARYMAIL,EX_STORAGESERVER,EX_STORAGEGROUP"
				+ ",EX_STORAGESTORE,EX_CUSTOMATTRIBUTE01,EX_CUSTOMATTRIBUTE02,EX_CUSTOMATTRIBUTE03,EX_CUSTOMATTRIBUTE04,EX_CUSTOMATTRIBUTE05,EX_CUSTOMATTRIBUTE06"
				+ ",EX_CUSTOMATTRIBUTE07,EX_CUSTOMATTRIBUTE08,EX_CUSTOMATTRIBUTE09,EX_CUSTOMATTRIBUTE10,EX_CUSTOMATTRIBUTE11,EX_CUSTOMATTRIBUTE12,EX_CUSTOMATTRIBUTE13"
				+ ",EX_CUSTOMATTRIBUTE14,EX_CUSTOMATTRIBUTE15,MSN_POOLSERVERNAME,MSN_POOLSERVERDN,MSN_SIPADDRESS,MSN_ANONMY,MSN_MEETINGPOLICYNAME,MSN_MEETINGPOLICYDN"
				+ ",MSN_PHONECOMMUNICATION,MSN_PBX,MSN_LINEPOLICYNAME,MSN_LINEPOLICYDN,MSN_LINEURI,MSN_LINESERVERURI,MSN_FEDERATION,MSN_REMOTEACCESS,MSN_PUBLICIMCONNECTIVITY"
				+ ",MSN_INTERNALIMCONVERSATION,MSN_FEDERATEDIMCONVERSATION,AD_ISUSE,EX_ISUSE,MSN_ISUSE,AD_CN,AD_SamAccountName,AD_UserPrincipalName"
				+ ",MultiJobTitleName,MultiJobPositionName,MultiJobLevelName,LicSeq,IsCRM"));
		return resultList;
	}
	/**
	 * 사용자 정보 가져오기 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectUserGroupMailInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.conf.manage.selectUserGroupMailInfo", params);

		CoviMap resultList = new CoviMap();
		resultList.put("list", CoviSelectSet.coviSelectJSON(list,
				"USERCODE,DISPLAYNAME,MailAddress,DeptCode,DeptName,DeptMailAddress,JobPositionCode,JobPositionName"
				+ ",JobPositionMailAddress,JobTitleCode,JobTitleName,JobTitleMailAddress,JobLevelCode,JobLevelName,JobLevelMailAddress"
				+ ",RegionCode,RegionName,RegionMailAddress"
				+ ",OUPath"));
		return resultList;
	}
	
	// 인디메일 API
	/**
	 * 인디메일 연동 여부
	 * 
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public boolean getIndiSyncTF() throws Exception {
		boolean bReturn;
		bReturn = RedisDataUtil.getBaseConfig("IsSyncIndi").equals("Y") ? true : false;
		return bReturn;
	}

	/**
	 * IndiMail 사용자 계정상태 확인
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public CoviMap getIndiMailUserStatus(CoviMap params) throws Exception {
		String apiURL = null;
		String sMode = "?job=userStatus";
		String sDomain = null;
		String method = "POST";
		CoviMap jObj = new CoviMap();

		try {
			apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL") + sMode;
			LOGGER.debug(apiURL);

			String sMailAddress = params.get("MailAddress").toString();
			sDomain = sMailAddress.split("@")[1];

			String sLogonID = sMailAddress.split("@")[0];

			sLogonID = java.net.URLEncoder.encode(sLogonID, java.nio.charset.StandardCharsets.UTF_8.toString());

			apiURL = apiURL + String.format("&id=%s&domain=%s", sLogonID, sDomain);
			jObj = getJson(apiURL, method);
		} catch (NullPointerException ex){
			LOGGER.error("IndiMail getIndiMailUserStatus Error [" + params.get("UserCode") + "]" + "[Message : "
					+ ex.getMessage() + "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "IndiMail",
						"IndiMail getIndiMailUserStatus Error [" + params.get("UserCode") + "]" + "[Message : "
								+ ex.getMessage() + "]",
						"");
			}
		} catch (Exception ex) {
			LOGGER.error("IndiMail getIndiMailUserStatus Error [" + params.get("UserCode") + "]" + "[Message : "
					+ ex.getMessage() + "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "IndiMail",
						"IndiMail getIndiMailUserStatus Error [" + params.get("UserCode") + "]" + "[Message : "
								+ ex.getMessage() + "]",
						"");
			}
		}
		return jObj;
	}

	/**
	 * IndiMail 사용자 계정 추가
	 * 
	 * @param params
	 *            - CoviMap
	 * @return
	 * @throws Exception
	 */
	@Override
	public CoviMap addUser(CoviMap params) throws Exception {
		String apiURL = null;
		String sMode = "?job=addUser";
		String sDomain = null;
		String method = "GET";
		CoviMap jObj = new CoviMap();

		try {
			apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL") + sMode;
			LOGGER.debug(apiURL);

			String sMailAddress = params.getString("MailAddress");

			sDomain = sMailAddress.split("@")[1];// RedisDataUtil.getBaseConfig("IndiMailDomain").toString();

			String sLogonID = sMailAddress.split("@")[0];// params.get("LogonID").toString();
			// String sPassword = params.get("DecLogonPassword").toString();
			AES aes = new AES(aeskey, "N");
			String sPassword = aes.encrypt(params.get("DecLogonPassword").toString());
			String sName = params.get("DisplayName").toString();
			String sEnc = "";
			String sCompany = params.get("CompanyCode").toString();
			String sDeptId = params.get("GroupMailAddress").toString();
			String sDeptName = params.get("DeptName").toString();
			String sStatus = "A";
			String slang = params.get("LanguageCode").toString();
			String sTimeZone = params.get("TimeZoneCode").toString();
			String sMailSize = RedisDataUtil.getBaseConfig("IndiMailSize");
			String sFileSize = "10";
			String sContacts = "1";
			sMailSize = "".equals(sMailSize) ? "1024" : sMailSize;
			sLogonID = java.net.URLEncoder.encode(sLogonID, java.nio.charset.StandardCharsets.UTF_8.toString());
			sName = java.net.URLEncoder.encode(sName, java.nio.charset.StandardCharsets.UTF_8.toString());
			sDeptName = java.net.URLEncoder.encode(sDeptName, java.nio.charset.StandardCharsets.UTF_8.toString());
			sDeptId = java.net.URLEncoder.encode(sDeptId, java.nio.charset.StandardCharsets.UTF_8.toString());

			apiURL = apiURL + String.format(
					"&id=%s&name=%s&domain=%s&company=%s&enc=%s&deptId=%s&deptName=%s&status=%s&lang=%s&timezone=%s&mailsize=%s&filesize=%s&contacts=%s&pw=%s",
					sLogonID, sName, sDomain, sCompany, sEnc, sDeptId, sDeptName, sStatus, slang, sTimeZone,
					sMailSize, sFileSize, sContacts, sPassword);
			jObj = getJson(apiURL, method);

			if (!jObj.get("returnCode").toString().equals("0")) {
				LOGGER.error(jObj.toString());
				if ("Sync".equals(params.getString("SyncManage"))) {
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "IndiMail",
							"IndiMail addUser Error [" + params.get("UserCode") + "]" + "[Message : " + jObj.toString()
									+ "]",
							"");
				}
			} else {
				if ("Sync".equals(params.getString("SyncManage"))) {
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "UR", "IndiMail",
							"IndiMail addUser Success [" + params.get("UserCode") + "]", "");
				}
			}
		} catch (NullPointerException e){
			LOGGER.error(
					"IndiMail addUser Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage() + "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "IndiMail",
						"IndiMail addUser Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
								+ "]",
						"");
			}
		} catch (Exception e) {
			LOGGER.error(
					"IndiMail addUser Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage() + "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "IndiMail",
						"IndiMail addUser Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
								+ "]",
						"");
			}
		}
		return jObj;
	}

	/**
	 * IndiMail 사용자 계정 수정/삭제
	 * 
	 * @param params
	 *            - CoviMap
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public CoviMap modifyUser(CoviMap params) throws Exception {
		StringBuffer apiURL = new StringBuffer();
		String sMode = "?job=modifyUser";
		String sDomain = null;
		String sLogonID = null;
		String method = "GET";
		CoviMap jObj = new CoviMap();

		try {
			apiURL.append(RedisDataUtil.getBaseConfig("IndiMailAPIURL") + sMode);
			LOGGER.debug(apiURL.toString());

			String sMailAddress = params.get("MailAddress").toString();

			sDomain = sMailAddress.split("@")[1];// RedisDataUtil.getBaseConfig("IndiMailDomain").toString();
			String sMailStatus = params.get("mailStatus").toString();

			// S 인디메일 계정 비활성화
			if (sMailStatus.equals("S")) {
				// 동기화시
				if ("Sync".equals(params.getString("SyncManage"))) {
					sLogonID = java.net.URLEncoder.encode(sMailAddress.split("@")[0],
							java.nio.charset.StandardCharsets.UTF_8.toString());
					sMailStatus = java.net.URLEncoder.encode(sMailStatus,
							java.nio.charset.StandardCharsets.UTF_8.toString());
					String sName = params.get("DisplayName").toString();
					String sCompany = params.get("CompanyCode").toString();
					String sDeptId = "";
					String sOldDeptId = params.get("oldGroupMailAddress") != null
							&& !params.get("oldGroupMailAddress").toString().equalsIgnoreCase("undefined")
							&& !params.get("oldGroupMailAddress").equals("")
									? params.get("oldGroupMailAddress").toString()
									: "";
					sOldDeptId = java.net.URLEncoder.encode(sOldDeptId,
							java.nio.charset.StandardCharsets.UTF_8.toString());

					apiURL.append(
							String.format("&id=%s&name=%s&status=%s&domain=%s&company=%s&deptId=%s&deptOldEmail=%s",
									sLogonID, sName, sMailStatus, sDomain, sCompany, sDeptId, sOldDeptId));
					jObj = getJson(apiURL.toString(), method);
					if (!jObj.get("returnCode").toString().equals("0")) {
						LOGGER.error(jObj.toString()); // print error context
						if ("Sync".equals(params.getString("SyncManage"))) {
							insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR",
									"IndiMail", "IndiMail modifyUser Error [" + params.get("UserCode") + "]"
											+ "[Message : " + jObj.toString() + "]",
									"");
						}
					} else {
						if ("Sync".equals(params.getString("SyncManage"))) {
							insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "UR",
									"IndiMail", "IndiMail modifyUser Success [" + params.get("UserCode") + "]", "");
						}
					}
				} else {
					// 조직관리
					sLogonID = sMailAddress.split("@")[0];
					params.put("LogonID", sLogonID);

					CoviMap reObject = getIndiMailUserStatus(params);
					String rReturnCode = reObject.get("returnCode").toString();
					String rResult = reObject.get("result").toString();
					if (rReturnCode.equals("0") && rResult.equals("0")) { // 계정이 존재하면
						sLogonID = java.net.URLEncoder.encode(sLogonID,
								java.nio.charset.StandardCharsets.UTF_8.toString());
						sMailStatus = java.net.URLEncoder.encode(sMailStatus,
								java.nio.charset.StandardCharsets.UTF_8.toString());
						String sName = params.get("DisplayName").toString();
						sName = java.net.URLEncoder.encode(sName, java.nio.charset.StandardCharsets.UTF_8.toString());
						String sCompany = params.get("CompanyCode").toString();
						String sDeptId = "";
						String sOldDeptId = params.get("oldGroupMailAddress") != null
								&& !params.get("oldGroupMailAddress").toString().equalsIgnoreCase("undefined")
								&& !params.get("oldGroupMailAddress").equals("")
										? params.get("oldGroupMailAddress").toString()
										: "";
						sOldDeptId = java.net.URLEncoder.encode(sOldDeptId,
								java.nio.charset.StandardCharsets.UTF_8.toString());

						apiURL.append(
								String.format("&id=%s&name=%s&status=%s&domain=%s&company=%s&deptId=%s&deptOldEmail=%s",
										sLogonID, sName, sMailStatus, sDomain, sCompany, sDeptId, sOldDeptId));
						jObj = getJson(apiURL.toString(), method);
						if (!jObj.get("returnCode").toString().equals("0")) {
							LOGGER.error(jObj.toString()); // print error context
							if ("Sync".equals(params.getString("SyncManage"))) {
								insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR",
										"IndiMail", "IndiMail modifyUser Error [" + params.get("UserCode") + "]"
												+ "[Message : " + jObj.toString() + "]",
										"");
							}
						} else {
							if ("Sync".equals(params.getString("SyncManage"))) {
								insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "UR",
										"IndiMail", "IndiMail modifyUser Success [" + params.get("UserCode") + "]", "");
							}
						}
					}
				}
			} else {
				sLogonID = sMailAddress.split("@")[0];
				sLogonID = java.net.URLEncoder.encode(sLogonID, java.nio.charset.StandardCharsets.UTF_8.toString());
				AES aes = new AES(aeskey, "N");
				String sPassword = aes.encrypt(params.get("DecLogonPassword").toString());
				String sName = params.get("DisplayName").toString();
				sName = java.net.URLEncoder.encode(sName, java.nio.charset.StandardCharsets.UTF_8.toString());
				String sCompany = params.get("CompanyCode").toString();
				String sDeptId = params.get("GroupMailAddress").toString().isEmpty() ? ""
						: params.get("GroupMailAddress").toString();
				sMailStatus = java.net.URLEncoder.encode(sMailStatus,
						java.nio.charset.StandardCharsets.UTF_8.toString());
				String sOldDeptId = params.get("oldGroupMailAddress") != null
						&& !params.get("oldGroupMailAddress").toString().equalsIgnoreCase("undefined")
						&& !params.get("oldGroupMailAddress").equals("")
						&& !sDeptId.equals(params.get("oldGroupMailAddress"))
								? params.get("oldGroupMailAddress").toString()
								: "";
				sDeptId = java.net.URLEncoder.encode(sDeptId, java.nio.charset.StandardCharsets.UTF_8.toString());
				sOldDeptId = java.net.URLEncoder.encode(sOldDeptId, java.nio.charset.StandardCharsets.UTF_8.toString());

				/*apiURL.append(
						String.format("&id=%s&name=%s&status=%s&domain=%s&company=%s&deptId=%s&deptOldEmail=%s&pw=%s",
								sLogonID, sName, sMailStatus, sDomain, sCompany,
								sDeptId, sOldDeptId, sPassword));*/
				apiURL.append(
						String.format("&id=%s&name=%s&status=%s&domain=%s&company=%s&deptId=%s&deptOldEmail=%s",
								sLogonID, sName, sMailStatus, sDomain, sCompany,
								sDeptId, sOldDeptId));
				jObj = getJson(apiURL.toString(), method);
				if (!jObj.get("returnCode").toString().equals("0")) {
					LOGGER.error(jObj.toString()); // print error context
					if ("Sync".equals(params.getString("SyncManage"))) {
						insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR",
								"IndiMail", "IndiMail modifyUser Error [" + params.get("UserCode") + "]" + "[Message : "
										+ jObj.toString() + "]",
								"");
					}
				} else {
					if ("Sync".equals(params.getString("SyncManage"))) {
						insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "UR",
								"IndiMail", "IndiMail modifyUser Success [" + params.get("UserCode") + "]", "");
					}
				}

			}
		} catch (NullPointerException e){
			LOGGER.error("IndiMail modifyUser Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
					+ "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "IndiMail",
						"IndiMail modifyUser Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
								+ "]",
						"");
			}
		} catch (Exception e) {
			LOGGER.error("IndiMail modifyUser Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
					+ "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "IndiMail",
						"IndiMail modifyUser Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
								+ "]",
						"");
			}
		}
		return jObj;
	}

	/**
	 * IndiMail 비밀번호 수정
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public String indiModifyPass(CoviMap params) throws Exception {
		String bReturn = "E0";
		boolean isSync = false;
		String sMode = "?job=modifyPass";
		String key =null;
		String apiURL = null;
		String sDomain = null;
		String strMailAddress = null;
		String sMailID = null;
		String sLogonPW = null;
		try {
			isSync = RedisDataUtil.getBaseConfig("IsSyncIndi").equals("Y") ? true : false;
			if (isSync) {
				key = PropertiesUtil.getDecryptedProperty(PropertiesUtil.getSecurityProperties().getProperty("aes.key"));
				AES aes = new AES(key, "N");
				
				apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL") + sMode;

				strMailAddress = params.get("MailAddress").toString();
				if(strMailAddress.split("@").length!=2)
					return "0";
				sMailID = strMailAddress.split("@")[0];
				sDomain = strMailAddress.split("@")[1];
				sLogonPW = aes.encrypt(params.get("LogonPW").toString());
				
				apiURL = apiURL + String.format("&id=%s&domain=%s&pw=%s", sMailID, sDomain, sLogonPW);
				
				CoviMap jObj = getJson(apiURL, "POST");
				
				if(jObj.get("returnCode").toString().equals("0")) {
					bReturn = "0";
				} 
				
			}else{
				bReturn = "0";
			}
		} catch (NullPointerException ex){
			LOGGER.error(
					"indiModifyPass Error [" + params.get("LogonID") + "]" + "[Message : " + ex.getMessage() + "]");
		} catch (Exception ex) {
			LOGGER.error(
					"indiModifyPass Error [" + params.get("LogonID") + "]" + "[Message : " + ex.getMessage() + "]");
		}

		return bReturn;
	}

	/**
	 * IndiMail 그룹 api 호출
	 * 
	 * @param params
	 *            - CoviMap
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public boolean setIndiMailGroup(CoviMap params) throws Exception {
		boolean bReturn = false;
		String apiURL = null;
		String sMode = null;
		String sPrimaryMail = null;
		String sDeptCode = null;
		String sDisplayName = null;
		String sMemberOf = null;
		String sGroupStatus = null;
		String sParentMailAddress = null;
		String sDomain = null;
		CoviMap jObj= null;
		String method = "POST";
		CoviMap map = new CoviMap();
		try {
			sMode = params.get("MODE").toString();
			apiURL = RedisDataUtil.getBaseConfig("IndiMailAPIURL") + sMode;
			LOGGER.debug(apiURL);

			sPrimaryMail = params.get("PrimaryMail").toString();
			sDomain = sPrimaryMail.split("@")[1];// RedisDataUtil.getBaseConfig("IndiMailDomain").toString();
			sDeptCode = sPrimaryMail.split("@")[0];// params.get("GroupCode").toString();
			sDisplayName = params.get("DisplayName").toString();
			sMemberOf = params.get("MemberOf").toString();
			sGroupStatus = params.get("GroupStatus").toString();
			
			map.put("GroupCode", sMemberOf);
			sParentMailAddress = selectGroupMail(map); 
			
			sDeptCode = java.net.URLEncoder.encode(sDeptCode, java.nio.charset.StandardCharsets.UTF_8.toString());
			sDisplayName = java.net.URLEncoder.encode(sDisplayName, java.nio.charset.StandardCharsets.UTF_8.toString());
			sParentMailAddress = java.net.URLEncoder.encode(sParentMailAddress, java.nio.charset.StandardCharsets.UTF_8.toString());

			apiURL = apiURL + String.format("&id=%s&name=%s&enc=%s&deptId=%s&status=%s&domain=%s", sDeptCode,
					sDisplayName, "0", sParentMailAddress, sGroupStatus, sDomain);

			jObj = getJson(apiURL, method);
			if (jObj.get("returnCode").toString().equals("0")) {
				bReturn = true;
			} else {
				LOGGER.error(jObj.toString()); // print error context
			}
		} catch (NullPointerException ex){
			LOGGER.error("modifyGroup Error [" + params.get("GroupCode") + "]" + "[Message : " + ex.getMessage() + "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "GR", "IndiMail",
						"IndiMail modifyGroup Error [" + params.get("GroupCode") + "]" + "[Message : " + ex.getMessage()
								+ "]",
						"");
			}
		} catch (Exception ex) {
			LOGGER.error("modifyGroup Error [" + params.get("GroupCode") + "]" + "[Message : " + ex.getMessage() + "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "GR", "IndiMail",
						"IndiMail modifyGroup Error [" + params.get("GroupCode") + "]" + "[Message : " + ex.getMessage()
								+ "]",
						"");
			}
		}
		return bReturn;
	}

	
	/**
	 * 그룹메일주소 가져오기 select
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - String
	 * @throws Exception
	 */
	@Override
	public String selectGroupMail(CoviMap params) throws Exception {
		String sReturn = coviMapperOne.getString("organization.syncmanage.selectGroupMail", params);
		if (sReturn == null) sReturn = "";
		return sReturn;
	}


	/**
	 * IndiMail USER api 호출
	 * 
	 * @param params
	 *            - CoviMap
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public CoviMap setIndiMailUser(CoviMap params) throws Exception {
		StringBuffer apiURL = new StringBuffer();
		String strJob = null;
		String strMailDomain = null;
		String strMailID = null;
		String method = "GET";
		CoviMap jObj = new CoviMap();
		String strDisplayName = null;
		String strCompanyCode = null;
		String strGroupMailAddress = null;
		String strOldGroupMailAddress = null;
		String strMailAddress = null;
		String strMailStatus = null;
		String strPassword = null;
		String strMode = null;
		String strGroupName = null;

		try {
			strMode = params.get("MODE").toString();
			strJob = strMode.equalsIgnoreCase("ADD")?"addUser":"modifyUser";
			
			apiURL.append(RedisDataUtil.getBaseConfig("IndiMailAPIURL") + "?job="+strJob);
			LOGGER.debug(apiURL.toString());
			strMailAddress = params.get("MailAddress").toString();
			strMailDomain = strMailAddress.split("@")[1];
			strMailStatus = params.get("mailStatus").toString();
			strGroupName = params.get("GroupName").toString();
			strGroupName=java.net.URLEncoder.encode(strGroupName, java.nio.charset.StandardCharsets.UTF_8.toString());

			strMailID = strMailAddress.split("@")[0]; 
			strCompanyCode = params.get("CompanyCode").toString();
			strDisplayName = params.get("DisplayName").toString();
			strDisplayName = java.net.URLEncoder.encode(strDisplayName, java.nio.charset.StandardCharsets.UTF_8.toString());
			strGroupMailAddress = params.get("GroupMailAddress").toString();
			strOldGroupMailAddress = params.get("oldGroupMailAddress").toString();
			strGroupMailAddress = (strGroupMailAddress != null&& !strGroupMailAddress.equalsIgnoreCase("undefined")&& !strGroupMailAddress.equals(""))? strGroupMailAddress: "";
			strOldGroupMailAddress = (strOldGroupMailAddress != null&& !strOldGroupMailAddress.equalsIgnoreCase("undefined")&& !strOldGroupMailAddress.equals(""))? strOldGroupMailAddress: "";
			
			strMailID = java.net.URLEncoder.encode(strMailID,java.nio.charset.StandardCharsets.UTF_8.toString());
			strMailStatus = java.net.URLEncoder.encode(strMailStatus,java.nio.charset.StandardCharsets.UTF_8.toString());
			strOldGroupMailAddress = java.net.URLEncoder.encode(strOldGroupMailAddress,java.nio.charset.StandardCharsets.UTF_8.toString());
			if(strMode.equalsIgnoreCase("ADD")){
				AES aes = new AES(aeskey, "N");
				strPassword = aes.encrypt(params.get("DecLogonPassword").toString());
				strMailStatus= "A";
				String strlang = params.get("LanguageCode").toString();
				String strTimeZone = params.get("TimeZoneCode").toString();
				String strMailSize = RedisDataUtil.getBaseConfig("IndiMailSize");
				String strFileSize = "10";
				String strContacts = "1";
				String strEnc = "";
				strMailSize = "".equals(strMailSize) ? "1024" : strMailSize;

				apiURL = apiURL.append(String.format(
						"&id=%s&name=%s&domain=%s&company=%s&enc=%s&deptId=%s&deptName=%s&status=%s&lang=%s&timezone=%s&mailsize=%s&filesize=%s&contacts=%s&pw=%s",
						strMailID, strDisplayName, strMailDomain, strCompanyCode, strEnc, strGroupMailAddress, strGroupName, strMailStatus, strlang, strTimeZone,
						strMailSize, strFileSize, strContacts, strPassword));
			}
			else
				apiURL.append(String.format("&id=%s&name=%s&status=%s&domain=%s&company=%s&deptId=%s&deptOldEmail=%s",
								strMailID, strDisplayName, strMailStatus, strMailDomain, strCompanyCode, strGroupMailAddress, strOldGroupMailAddress));
			jObj = getJson(apiURL.toString(), method);
			
			if (!jObj.get("returnCode").toString().equals("0")) {
				LOGGER.error(jObj.toString()); // print error context
				if ("Sync".equals(params.getString("SyncManage"))) {
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR",
							"IndiMail", "IndiMail "+strMode+" Error [" + params.get("UserCode") + "]"
									+ "[Message : " + jObj.toString() + "]",
							"");
				}
			} else {
				if ("Sync".equals(params.getString("SyncManage"))) {
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Info", "UR",
							"IndiMail", "IndiMail "+strMode+" Success [" + params.get("UserCode") + "]", "");
				}
			}
		} catch (NullPointerException e){
			LOGGER.error("IndiMail "+strMode+" Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
					+ "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "IndiMail",
						"IndiMail "+strMode+" Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
								+ "]",
						"");
			}
		} catch (Exception e) {
			LOGGER.error("IndiMail "+strMode+" Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
					+ "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "IndiMail",
						"IndiMail "+strMode+" Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
								+ "]",
						"");
			}
		}
		return jObj;
	}
	////////////////////////////////////////////////////////////////////////////////////////////
	// 타임스퀘어 API
	/**
	 * 타임스퀘어 버젼
	 * 
	 * @return Stirng
	 * @throws Exception
	 */
	@Override
	public String getTSVer() throws Exception {
		String sReturn;
		sReturn = RedisDataUtil.getBaseConfig("TimeSquareAPIVer");
		return sReturn;
	}

	/**
	 * 타임스퀘어 연동 여부
	 * 
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public boolean getTSSyncTF() throws Exception {
		boolean bReturn;
		bReturn = RedisDataUtil.getBaseConfig("IsSyncTimeSquare").equals("Y") ? true : false;
		return bReturn;
	}

	/**
	 * 타임스퀘어 사용자/부서 추가
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int addUsersyncusermap(CoviMap params) throws Exception {
		int bReturn = 0;
		String apiURL = null;
		String sMode = "syncusermap";
		String method = "POST";

		try {
			String syncMode = params.get("SyncMode").toString(); // 조직도 동기화 부서/사용자 구분코드
			String sUc = null;
			String sGC = null;
			String sLv = null;
			String sDn = null;
			String sUt = null;
			String sOd = null;

			String job_title_code = null;
			String ex_job_title_name = null;
			String job_position_code = null;
			String ex_job_position_name = null;
			String job_level_code = null;
			String ex_job_level_name = null;
			String phone_number_inter = null;
			String phone_number = null;

			if (syncMode.equals("U")) {
				sUc = params.get("LogonID").toString(); // UserCode
				sGC = params.get("DeptCode").toString(); // GroupCode
				sLv = "0"; // 조직도상 노드의 레벨 0
				sDn = params.get("DisplayName").toString(); // Displayname
				sUt = "U"; // UserType U
				sOd = params.get("SortKey").toString(); // 부서내 정렬순서
				// sGroup_type = "company";
				// sCompany_code = params.get("CompanyCode").toString(); //계열사 경우 회사코드
				job_title_code = !params.get("JobTitleCode").toString().equals("") && params.get("JobTitleCode") != null
						? params.get("JobTitleCode").toString()
						: "";
				ex_job_title_name = !params.get("JobTitleName").toString().equals("")
						&& params.get("JobTitleName") != null ? params.get("JobTitleName").toString() : "";
				job_position_code = !params.get("JobPositionCode").toString().equals("")
						&& params.get("JobPositionCode") != null ? params.get("JobPositionCode").toString() : "";
				ex_job_position_name = !params.get("JobPositionName").toString().equals("")
						&& params.get("JobPositionName") != null ? params.get("JobPositionName").toString() : "";
				job_level_code = !params.get("JobLevelCode").toString().equals("") && params.get("JobLevelCode") != null
						? params.get("JobLevelCode").toString()
						: "";
				ex_job_level_name = !params.get("JobLevelName").toString().equals("")
						&& params.get("JobLevelName") != null ? params.get("JobLevelName").toString() : "";
				phone_number_inter = !params.get("PhoneNumberInter").toString().equals("")
						&& params.get("PhoneNumberInter") != null ? params.get("PhoneNumberInter").toString() : "";
				phone_number = !params.get("PhoneNumber").toString().equals("") && params.get("PhoneNumber") != null
						? params.get("PhoneNumber").toString()
						: "";
			} else if (syncMode.equals("G")) {
				sUc = params.get("GroupCode").toString();
				if (sUc.equals("ORGROOT"))
					sGC = "";
				else
					sGC = params.get("MemberOf").toString();
				sLv = "0";
				sDn = params.get("DisplayName").toString();
				sUt = "G";
				sOd = params.get("SortKey").toString();
			}

			if (sUc != null && sGC != null) {
				sUc = java.net.URLEncoder.encode(sUc, java.nio.charset.StandardCharsets.UTF_8.toString());
				sGC = java.net.URLEncoder.encode(sGC, java.nio.charset.StandardCharsets.UTF_8.toString());
				// sDn = java.net.URLEncoder.encode(sDn,
				// java.nio.charset.StandardCharsets.UTF_8.toString());
			}

			apiURL = RedisDataUtil.getBaseConfig("TimeSquareAPIURLv2") + sMode;
			LOGGER.debug(apiURL);

			String apiData = "{\"uc\":\"" + sUc + "\",\"gc\":\"" + sGC + "\",\"lv\":\"" + sLv + "\",\"dn\":\"" + sDn
					+ "\",\"ut\":\"" + sUt + "\",\"od\":\"" + sOd
					// + "\",\"group_type\":\"" + sGroup_type + "\",\"company_code\":\"" +
					// sCompany_code
					+ "\",\"job_title_code\":\"" + job_title_code + "\",\"ex_job_title_name\":\"" + ex_job_title_name
					+ "\",\"job_position_code\":\"" + job_position_code + "\",\"ex_job_position_name\":\""
					+ ex_job_position_name + "\",\"job_level_code\":\"" + job_level_code + "\",\"ex_job_level_name\":\""
					+ ex_job_level_name + "\",\"phone_number_inter\":\"" + phone_number_inter + "\",\"phone_number\":\""
					+ phone_number + "\"}";
			byte[] postData = apiData.getBytes("UTF-8");

			try {
				URL strurl;
				StringUtil func = new StringUtil();
				String responseMsg = "";
				String RequestDate = func.getCurrentTimeStr();
				int statusCode = 404;
				StringBuffer response = new StringBuffer();
				String jsonText = "";

				HttpURLConnection conn = null;
				try {
					strurl = new URL(apiURL);
					conn = (HttpURLConnection) strurl.openConnection();
					conn.setReadTimeout(15000);
					conn.setConnectTimeout(15000);
					conn.setRequestMethod(method);
					conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
					conn.setDoInput(true);
					conn.setDoOutput(true);

					if (true) {
						try (DataOutputStream wr = new DataOutputStream(conn.getOutputStream());) {
							wr.write(postData);
							
							int responseCode = conn.getResponseCode();

							if (responseCode == 200) { // 정상 호출
								bReturn = 1;
								try (InputStream in = conn.getInputStream(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {

									byte[] buf = new byte[1024 * 8];
									int length = 0;
									while ((length = in.read(buf)) != -1) {
										out.write(buf, 0, length);
									}

									jsonText = new String(out.toByteArray(), "UTF-8");
									CoviMap resultList = CoviMap.fromObject(jsonText);
									LOGGER.debug("[HttpURLConnect] [" + strurl + "] Return Msg : " + resultList);
								}
							} else {
								// 에러 발생
								// 오류 처리 추가 할 것
								bReturn = 0;
								throw new RuntimeException("Failed : HTTP error code : " + conn.getResponseCode());
							}
						}
					}
					
					statusCode = conn.getResponseCode();
				} catch (RuntimeException e) {
					throw new RuntimeException("Failed : HTTP error code (RuntimeException) : " + e.getMessage());
				} catch (Exception e) {
					statusCode = 500;
					responseMsg = e.toString();
					bReturn = 0;
					LOGGER.debug("[HttpURLConnect] [" + apiURL + "] Connect Exception : " + e.toString());
				} finally {
					if (conn != null) {
						conn.disconnect();
						conn = null;
					}
					if (apiURL.indexOf("sendmessaging") > 0 && statusCode < 299) {

					} else {
						params.put("LogType", "URL");
						params.put("Method", method);
						params.put("ConnetURL", apiURL);

						params.put("RequestDate", RequestDate);
						params.put("ResultState", Integer.toString(statusCode));
						params.put("RequestBody", "");

						if (func.f_NullCheck(responseMsg).equals("")) {
							if (statusCode < 299) {
								bReturn = 1;
								params.put("ResultType", "SUCCESS");
							} else {
								bReturn = 0;
								params.put("ResultType", "FAIL");
							}
							params.put("ResponseMsg", response.toString());
						} else {
							bReturn = 0;
							params.put("ResultType", "FAIL");
							params.put("ResponseMsg", responseMsg);
						}

						params.put("ResponseDate", func.getCurrentTimeStr());
						LoggerHelper.httpLog(params);
					}
					LoggerHelper.httpLog(params);
				}
			} catch (IOException e) {
				bReturn = 0;
				LOGGER.error("TimeSquare addUsersyncusermap Error [" + params.get("UserCode") + "]" + "[Message : "
						+ e.getMessage() + "]");
				if ("Sync".equals(params.getString("SyncManage"))) {
					insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "TS",
							"TS addUsersyncusermap Error [" + params.get("UserCode") + "]" + "[Message : "
									+ e.getMessage() + "]",
							"");
				}
			}
		} catch (NullPointerException e) {
			bReturn = 0;
			LOGGER.error("TimeSquare addUsersyncusermap Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "TS",
						"TS addUsersyncusermap Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
								+ "]",
						"");
			}
		} catch (Exception e) {
			bReturn = 0;
			LOGGER.error("TimeSquare addUsersyncusermap Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "TS",
						"TS addUsersyncusermap Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
								+ "]",
						"");
			}
		}
		return bReturn;
	}

	/**
	 * 타임스퀘어 사용자 계정 수정(비밀번호)
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public String resetuserpasswordTS(CoviMap params) throws Exception {
		String sReturn = "";
		int iReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try {
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());

			wrTS = httpClient.streamAdd(wrTS, "job", "modifyUser");
			wrTS = httpClient.streamAdd(wrTS, "loginId", params.get("LogonID").toString());

			if (RedisDataUtil.getBaseConfig("UseSaml").equals("1")) {
				wrTS = httpClient.streamAdd(wrTS, "authType", "saml");
				wrTS = httpClient.streamAdd(wrTS, "password", "");
			} else {
				wrTS = httpClient.streamAdd(wrTS, "password", params.get("Returnpass").toString());
			}

			wrTS = httpClient.streamAdd(wrTS, "", "");
			iReturn = httpClient.httpClientTSConnect(conTS, wrTS);
			sReturn = Integer.toString(iReturn);

		} catch (NullPointerException e){
			sReturn = "0";
			LOGGER.error("TimeSquare resetuserpassword Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "TS",
						"TS resetuserpassword Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
								+ "]",
						"");
			}
		} catch (Exception e) {
			sReturn = "0";
			LOGGER.error("TimeSquare resetuserpassword Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
			if ("Sync".equals(params.getString("SyncManage"))) {
				insertLogListLog(Integer.parseInt(params.get("SyncMasterID").toString()), "Error", "UR", "TS",
						"TS resetuserpassword Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage()
								+ "]",
						"");
			}
		} finally {
			if (conTS != null) {
				conTS.disconnect();
				conTS = null;
			}
			if (wrTS != null) {
				wrTS.close();
			}
		}

		return sReturn;
	}

	/**
	 * 타임스퀘어 사용자 사진 변경
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@SuppressWarnings("unused")
	@Override
	public int setUserPhoto(CoviMap params) throws Exception {
		int bReturn = 0;
		String sMode = "syncimage";
		if (params.get("PhotoPath") != null && !"".equals(params.getString("PhotoPath"))) {
			final String path = RedisDataUtil.getBaseConfig("ProfileImageFolderPath");
			String companyCode = SessionHelper.getSession("DN_Code");
			String backStorage = RedisDataUtil.getBaseConfig("BackStorage").replace("{0}", companyCode);

			if(awsS3.getS3Active(companyCode)){
				String dir = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + path;
				String key = dir+"/"+params.getString("UserCode");
				if(awsS3.exist(key)){
					awsS3.delete(key);
				}
				key = dir+"/"+params.getString("UserCode")+ "_org";
				if(awsS3.exist(key)){
					awsS3.delete(key);
				}
				if (params.get("FileInfo") != null && !params.get("FileInfo").equals("")) {
					MultipartFile mFile = (MultipartFile) params.get("FileInfo");
					String key2 = dir+"/"+params.getString("UserCode") + "_org.jpg";
					awsS3.upload(mFile.getInputStream(), key2, mFile.getContentType(), mFile.getSize());
				}
			}else {
				File dir = new File(FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + path);
				if (!dir.exists()) {
					boolean dReturn = dir.mkdirs();
					if (!dReturn)
						throw new IOException("updateOrgUserPhotoPath : Unable to create path.");
				}

				File existFile = new File(dir, params.getString("UserCode"));
				if (existFile.exists()) {
					boolean dReturn = existFile.delete();

					dReturn = new File(dir, params.getString("UserCode") + "_org").delete();

					if (!dReturn)
						throw new IOException("updateOrgUserPhotoPath : Fail to delete file.");
				}

				if (params.get("FileInfo") != null && !params.get("FileInfo").equals("")) {
					MultipartFile mFile = (MultipartFile) params.get("FileInfo");
					File file = new File(dir, params.getString("UserCode") + "_org.jpg");
					mFile.transferTo(file);
				}
			}

			String username = params.get("LogonID").toString();
			String filePath = FileUtil.getBackPath(companyCode).substring(0, FileUtil.getBackPath(companyCode).length() - 1) + backStorage + path
					+ params.getString("UserCode") + ".jpg";
			String requestURL = RedisDataUtil.getBaseConfig("TimeSquareAPIURLv2") + sMode;
			String charset = "UTF-8";

			try {
				MultipartUtility multipart = new MultipartUtility(requestURL, charset);

				multipart.addFormField("username", username);
				if(awsS3.getS3Active(companyCode)){
					AwsS3Data awsS3Data = awsS3.downData(filePath);
					try (InputStream is = awsS3Data.getContentStream();){
						multipart.addFilePart("image", is, awsS3Data.getName());
					}
				}else {
					multipart.addFilePart("image", new File(filePath));
				}
				List<String> response = multipart.finish();

				for (String line : response) {
					// System.out.println(line);
				}
				bReturn = 0;
			} catch (NullPointerException e){
				bReturn = 2;
			} catch (Exception ex) {
				bReturn = 2;
			}
		}
		return bReturn;
	}

	/**
	 * 타임스퀘어 계정존재 여부 조회
	 * 
	 * @param params
	 *            - CoviMap
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public boolean getUsersyncexistuser(CoviMap params) throws Exception {
		boolean bReturn = false;
		String apiURL = null;
		String sMode = "syncexistuser?d=";
		String method = "GET";

		try {
			String sUsername = params.get("LogonID").toString();

			sUsername = java.net.URLEncoder.encode(sUsername, java.nio.charset.StandardCharsets.UTF_8.toString());

			apiURL = RedisDataUtil.getBaseConfig("TimeSquareAPIURLv2") + sMode;
			LOGGER.debug(apiURL);
			apiURL = apiURL + "{" + "\"username\":\"" + sUsername + "\"" + "}";
			CoviMap jObj = getJson(apiURL, method);

			if (jObj.get("returnCode").toString().equals("0")) {
				if (jObj.get("userstatus").toString().equals("false")) {
					bReturn = false;
				} else {
					bReturn = true;
				}

			} else {
				bReturn = false;
				LOGGER.error(jObj.toString()); // print error context
			}
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare getUsersyncexistuser Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("TimeSquare getUsersyncexistuser Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		}
		return bReturn;
	}

	/**
	 * 타임스퀘어 계정활성화 여부 조회
	 * 
	 * @param params
	 *            - CoviMap
	 * @return boolean
	 * @throws Exception
	 */
	@Override
	public boolean getUserStatusSyncstatususer(CoviMap params) throws Exception {
		boolean bReturn = false;
		String apiURL = null;
		String sMode = "syncstatususer?d=";
		String method = "GET";

		try {
			String sUsername = params.get("LogonID").toString();

			sUsername = java.net.URLEncoder.encode(sUsername, java.nio.charset.StandardCharsets.UTF_8.toString());

			apiURL = RedisDataUtil.getBaseConfig("TimeSquareAPIURLv2") + sMode;
			LOGGER.debug(apiURL);
			apiURL = apiURL + "{" + "\"username\":\"" + sUsername + "\"" + "}";
			CoviMap jObj = getJson(apiURL, method);

			if (jObj.get("returnCode").toString().equals("0")) {
				bReturn = true;
			} else {
				bReturn = false;
				LOGGER.error(jObj.toString()); // print error context
			}
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare getUserStatusSyncstatususer Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("TimeSquare getUserStatusSyncstatususer Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		}
		return bReturn;
	}

	/**
	 * 타임스퀘어 사용자 계정 업데이트(비밀번호 제외)
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateUserSyncupdate(CoviMap params) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try {
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());

			wrTS = httpClient.streamAdd(wrTS, "job", "modifyUser");
			wrTS = httpClient.streamAdd(wrTS, "loginId", params.get("LogonID").toString());
			wrTS = httpClient.streamAdd(wrTS, "email", params.get("MailAddress").toString());
			wrTS = httpClient.streamAdd(wrTS, "displayName", params.get("DisplayName").toString());
			wrTS = httpClient.streamAdd(wrTS, "order", params.get("SortKey").toString());
			wrTS = httpClient.streamAdd(wrTS, "phoneNumberInter", params.get("PhoneNumberInter").toString());
			wrTS = httpClient.streamAdd(wrTS, "phoneNumber", params.get("PhoneNumber").toString());
			wrTS = httpClient.streamAdd(wrTS, "memberOf", params.get("DeptCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobTitleCode", params.get("JobTitleCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobTitleName", params.get("JobTitleName").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobPositionCode", params.get("JobPositionCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobPositionName", params.get("JobPositionName").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobLevelCode", params.get("JobLevelCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobLevelName", params.get("JobLevelName").toString());
			wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());
			wrTS = httpClient.streamAdd(wrTS, "companyCode", params.get("CompanyCode").toString());

			if (params.get("oldCompanyCode") != null
					&& !params.getString("CompanyCode").equals(params.getString("oldCompanyCode"))) {
				wrTS = httpClient.streamAdd(wrTS, "oldTeamName", params.get("oldCompanyCode").toString());
				wrTS = httpClient.streamAdd(wrTS, "teamName", params.get("CompanyCode").toString());
			}

			if (params.get("oldDeptCode") != null
					&& !params.getString("DeptCode").equals(params.getString("oldDeptCode"))) {
				wrTS = httpClient.streamAdd(wrTS, "oldChannelName", params.get("oldDeptCode").toString());
				wrTS = httpClient.streamAdd(wrTS, "channelName", params.get("DeptCode").toString());
			}

			if (params.get("PhotoPath") != null && !params.get("PhotoPath").toString().equals("")) {
				try {
					wrTS = httpClient.streamFileAdd(wrTS, "profileImage", params);
				} catch (NullPointerException e){
					LOGGER.error("TimeSquare updateUserSyncupdate PhotoPath Error [" + params.get("UserCode") + "]"
							+ "[Message : " + e.getMessage() + "]");
				} catch (Exception e) {
					LOGGER.error("TimeSquare updateUserSyncupdate PhotoPath Error [" + params.get("UserCode") + "]"
							+ "[Message : " + e.getMessage() + "]");
				}
			}

			if (params.get("BySaml").toString().equals("1")) {
				wrTS = httpClient.streamAdd(wrTS, "authType", "saml");
				wrTS = httpClient.streamAdd(wrTS, "password", "");
			}

			wrTS = httpClient.streamAdd(wrTS, "", "");

			bReturn = httpClient.httpClientTSConnect(conTS, wrTS);

		} catch (NullPointerException e){
			LOGGER.error("TimeSquare updateUserSyncupdate Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("TimeSquare updateUserSyncupdate Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} finally {
			if (conTS != null) {
				conTS.disconnect();
				conTS = null;
			}
			if (wrTS != null) {
				wrTS.close();
			}
		}

		return bReturn;
	}

	/**
	 * 타임스퀘어 사용자 계정 추가
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int addUserSync(CoviMap params) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try {
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());

			wrTS = httpClient.streamAdd(wrTS, "job", "addUser");
			wrTS = httpClient.streamAdd(wrTS, "loginId", params.get("LogonID").toString());
			wrTS = httpClient.streamAdd(wrTS, "email", params.get("MailAddress").toString());
			wrTS = httpClient.streamAdd(wrTS, "password", params.get("DecLogonPassword").toString());
			wrTS = httpClient.streamAdd(wrTS, "displayName", params.get("DisplayName").toString());
			wrTS = httpClient.streamAdd(wrTS, "order", params.get("SortKey").toString());
			wrTS = httpClient.streamAdd(wrTS, "phoneNumberInter", params.get("PhoneNumberInter").toString());
			wrTS = httpClient.streamAdd(wrTS, "phoneNumber", params.get("PhoneNumber").toString());
			wrTS = httpClient.streamAdd(wrTS, "memberOf", params.get("DeptCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobTitleCode", params.get("JobTitleCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobTitleName", params.get("JobTitleName").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobPositionCode", params.get("JobPositionCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobPositionName", params.get("JobPositionName").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobLevelCode", params.get("JobLevelCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobLevelName", params.get("JobLevelName").toString());
			wrTS = httpClient.streamAdd(wrTS, "companyCode", params.get("CompanyCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());
			// 기본 아님
			wrTS = httpClient.streamAdd(wrTS, "teamName", params.get("CompanyCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "channelName", params.get("DeptCode").toString());

			if (!params.getString("PhotoPath").equals("")) {
				try {
					wrTS = httpClient.streamFileAdd(wrTS, "profileImage", params);
				} catch (NullPointerException e){
					LOGGER.error("TimeSquare addUser PhotoPath Error [" + params.get("UserCode") + "]" + "[Message : "
							+ e.getMessage() + "]");
				} catch (Exception e) {
					LOGGER.error("TimeSquare addUser PhotoPath Error [" + params.get("UserCode") + "]" + "[Message : "
							+ e.getMessage() + "]");
				}
			}

			if (params.get("BySaml").toString().equals("1")) {
				wrTS = httpClient.streamAdd(wrTS, "authType", "saml");
			}

			wrTS = httpClient.streamAdd(wrTS, "", "");

			bReturn = httpClient.httpClientTSConnect(conTS, wrTS);

		} catch (NullPointerException e){
			LOGGER.error(
					"TimeSquare addUser Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error(
					"TimeSquare addUser Error [" + params.get("UserCode") + "]" + "[Message : " + e.getMessage() + "]");
		} finally {
			if (conTS != null) {
				conTS.disconnect();
				conTS = null;
			}
			if (wrTS != null) {
				wrTS.close();
			}
		}

		return bReturn;
	}

	/**
	 * 타임스퀘어 사용자 계정 삭제(계정비활성화)
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int deleteUserSyncdelete(CoviMap params) throws Exception {
		return isUseUserSyncupdate(params, "N");
	}

	/**
	 * 타임스퀘어 사용자 계정 활성화
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int isUseUserSyncupdate(CoviMap params, String pIsUse) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try {
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());

			wrTS = httpClient.streamAdd(wrTS, "job", "modifyUser");
			wrTS = httpClient.streamAdd(wrTS, "loginId", params.get("LogonID").toString());
			wrTS = httpClient.streamAdd(wrTS, "isUse", pIsUse);
			wrTS = httpClient.streamAdd(wrTS, "", "");

			bReturn = httpClient.httpClientTSConnect(conTS, wrTS);
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare isUseUserSyncupdate Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("TimeSquare isUseUserSyncupdate Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} finally {
			if (conTS != null) {
				conTS.disconnect();
				conTS = null;
			}
			if (wrTS != null) {
				wrTS.close();
			}
		}
		return bReturn;
	}

	/**
	 * 타임스퀘어 부서/그룹 추가
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int addGroupSync(CoviMap params) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try {
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());
			// 공통 파라미터
			wrTS = httpClient.streamAdd(wrTS, "groupCode", params.get("GroupCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "displayName", params.get("DisplayName").toString());
			wrTS = httpClient.streamAdd(wrTS, "order", params.get("SortKey").toString());
			wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());

			switch (params.get("GroupType").toString().toUpperCase()) {
			case "DEPT":
				wrTS = httpClient.streamAdd(wrTS, "job", "addGroup");
				wrTS = httpClient.streamAdd(wrTS, "createType",
						RedisDataUtil.getBaseConfig("TSGroupSyncCreateType"));
				wrTS = httpClient.streamAdd(wrTS, "companyCode", params.get("CompanyCode").toString());
				wrTS = httpClient.streamAdd(wrTS, "memberOf", params.get("MemberOf").toString());
				wrTS = httpClient.streamAdd(wrTS, "level", "1");
				break;
			case "JOBTITLE":
				wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
				wrTS = httpClient.streamAdd(wrTS, "groupType", "T");
				wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());
				break;
			case "JOBLEVEL":
				wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
				wrTS = httpClient.streamAdd(wrTS, "groupType", "L");
				wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());
				break;
			case "JOBPOSITION":
				wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
				wrTS = httpClient.streamAdd(wrTS, "groupType", "P");
				wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());
				break;
			default : 
				break;
			}

			wrTS = httpClient.streamAdd(wrTS, "", "");

			bReturn = httpClient.httpClientTSConnect(conTS, wrTS);

		} catch (NullPointerException e){
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("GroupCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("GroupCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} finally {
			if (conTS != null) {
				conTS.disconnect();
				conTS = null;
			}
			if (wrTS != null) {
				wrTS.close();
			}
		}

		return bReturn;
	}

	/**
	 * 타임스퀘어 그룹 수정
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int updateGroupSync(CoviMap params) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try {
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());

			wrTS = httpClient.streamAdd(wrTS, "groupCode", params.get("GroupCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "displayName", params.get("DisplayName").toString());
			wrTS = httpClient.streamAdd(wrTS, "order", params.get("SortKey").toString());
			wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());

			switch (params.get("GroupType").toString().toUpperCase()) {
			case "DEPT":
				wrTS = httpClient.streamAdd(wrTS, "job", "modifyGroup");
				wrTS = httpClient.streamAdd(wrTS, "createType", "channel");
				wrTS = httpClient.streamAdd(wrTS, "companyCode", params.get("CompanyCode").toString());
				wrTS = httpClient.streamAdd(wrTS, "memberOf", params.get("MemberOf").toString());
				wrTS = httpClient.streamAdd(wrTS, "level", "1");
				break;
			case "JOBTITLE":
				wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
				wrTS = httpClient.streamAdd(wrTS, "groupType", "T");
				break;
			case "JOBLEVEL":
				wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
				wrTS = httpClient.streamAdd(wrTS, "groupType", "L");
				break;
			case "JOBPOSITION":
				wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
				wrTS = httpClient.streamAdd(wrTS, "groupType", "P");
				break;
			default :
				break;
			}

			wrTS = httpClient.streamAdd(wrTS, "", "");

			bReturn = httpClient.httpClientTSConnect(conTS, wrTS);

		} catch (NullPointerException e){
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("GroupCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("GroupCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} finally {
			if (conTS != null) {
				conTS.disconnect();
				conTS = null;
			}
			if (wrTS != null) {
				wrTS.close();
			}
		}

		return bReturn;
	}

	/**
	 * 타임스퀘어 그룹 삭제
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int deleteGroupSync(CoviMap params) throws Exception {
		return isUseGroupSyncUpdate(params, "N");
	}

	/**
	 * 타임스퀘어 그룹 활성/비활성화
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int isUseGroupSyncUpdate(CoviMap params, String pIsUse) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try {
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());

			wrTS = httpClient.streamAdd(wrTS, "groupCode", params.get("GroupCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "isUse", pIsUse);

			switch (params.get("GroupType").toString().toUpperCase()) {
			case "DEPT":
				wrTS = httpClient.streamAdd(wrTS, "job", "modifyGroup");
				break;
			case "JOBTITLE":
				wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
				wrTS = httpClient.streamAdd(wrTS, "groupType", "T");
				break;
			case "JOBLEVEL":
				wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
				wrTS = httpClient.streamAdd(wrTS, "groupType", "L");
				break;
			case "JOBPOSITION":
				wrTS = httpClient.streamAdd(wrTS, "job", "syncGroupType");
				wrTS = httpClient.streamAdd(wrTS, "groupType", "P");
				break;
			default :
				break;
			}

			wrTS = httpClient.streamAdd(wrTS, "", "");

			bReturn = httpClient.httpClientTSConnect(conTS, wrTS);

		} catch (NullPointerException e){
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("GroupCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("GroupCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} finally {
			if (conTS != null) {
				conTS.disconnect();
				conTS = null;
			}
			if (wrTS != null) {
				wrTS.close();
			}
		}

		return bReturn;
	}

	/**
	 * 타임스퀘어 사용자 직급,직위,직책 동기화
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int setUserTypeSyncentcoder(CoviMap params) throws Exception {
		int bReturn = 0;
		String apiURL = null;
		String sMode = "syncentcode?d=";
		String method = "GET";

		try {
			String sId = params.get("GroupCode").toString();
			String sType = params.get("GroupType").toString().toUpperCase();
			String sDisplayname = params.get("GroupName").toString();
			String sSortkey = params.get("SortKey").toString();
			String sIsuse = params.get("IsUse").toString();

			if (sType.equals("JOBPOSITION"))
				sType = "P";
			else if (sType.equals("JOBTITLE"))
				sType = "T";
			else if (sType.equals("JOBLEVEL"))
				sType = "L";

			sId = java.net.URLEncoder.encode(sId, java.nio.charset.StandardCharsets.UTF_8.toString());
			sType = java.net.URLEncoder.encode(sType, java.nio.charset.StandardCharsets.UTF_8.toString());
			sDisplayname = java.net.URLEncoder.encode(sDisplayname, java.nio.charset.StandardCharsets.UTF_8.toString());
			sIsuse = java.net.URLEncoder.encode(sIsuse, java.nio.charset.StandardCharsets.UTF_8.toString());

			apiURL = RedisDataUtil.getBaseConfig("TimeSquareAPIURLv2") + sMode;
			LOGGER.debug(apiURL);

			apiURL = apiURL + "{\"id\":\"" + sId + "\",\"type\":\"" + sType + "\",\"display_name\":\"" + sDisplayname
					+ "\",\"sort_key\":\"" + sSortkey + "\",\"is_use\":\"" + sIsuse + "\"}";
			CoviMap jObj = getJson(apiURL, method);

			if (!jObj.get("returnCode").toString().equals("0")) { // 추가오류
				bReturn = 0;
				LOGGER.error(jObj.toString()); // print error context
			} else {
				bReturn = 1;
			}
		} catch (NullPointerException e){
			LOGGER.error("TimeSquare setUserTypeSyncentcoder Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		} catch (Exception e) {
			LOGGER.error("TimeSquare setUserTypeSyncentcoder Error [" + params.get("UserCode") + "]" + "[Message : "
					+ e.getMessage() + "]");
		}
		return bReturn;
	}

	/**
	 * 타임스퀘어 겸직 연동
	 * 
	 * @param params
	 *            - CoviMap
	 * @return int
	 * @throws Exception
	 */
	@Override
	public int insertUpdateAddJobSync(CoviMap params) throws Exception {
		int bReturn = 0;
		HttpClientUtil httpClient = new HttpClientUtil();
		HttpURLConnection conTS = null;
		DataOutputStream wrTS = null;
		try {
			conTS = httpClient.getTSConnection();
			wrTS = new DataOutputStream(conTS.getOutputStream());

			wrTS = httpClient.streamAdd(wrTS, "job", "syncAddJob");
			wrTS = httpClient.streamAdd(wrTS, "loginId", params.get("LogonID").toString());
			wrTS = httpClient.streamAdd(wrTS, "displayName", params.get("DisplayName").toString());
			if (params.get("IsUse").toString().equals("N")) // Y->N 으로 변경하는 경우 등록된 겸직부서 넘겨준다
				wrTS = httpClient.streamAdd(wrTS, "oldMemberOf", params.get("GroupCode").toString());
			else
				wrTS = httpClient.streamAdd(wrTS, "oldMemberOf", ""); // 추가하는 경우 안넘겨준다
			wrTS = httpClient.streamAdd(wrTS, "memberOf", params.get("GroupCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "isUse", params.get("IsUse").toString());
			wrTS = httpClient.streamAdd(wrTS, "order", params.get("SortKey").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobTitleCode", params.get("JobTitleCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobTitleName", params.get("JobTitleName").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobPositionCode", params.get("JobPositionCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobPositionName", params.get("JobPositionName").toString());
			wrTS = httpClient.streamAdd(wrTS, "jobLevelCode", params.get("JobLevelCode").toString());
			wrTS = httpClient.streamAdd(wrTS, "exJobLevelName", params.get("JobLevelName").toString());
			wrTS = httpClient.streamAdd(wrTS, "phoneNumberInter", params.get("PhoneNumberInter").toString());
			wrTS = httpClient.streamAdd(wrTS, "phoneNumber", params.get("PhoneNumber").toString());

			wrTS = httpClient.streamAdd(wrTS, "", "");

			bReturn = httpClient.httpClientTSConnect(conTS, wrTS);

		} catch (NullPointerException e){
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("LogonID") + "]" + "[Message : " + e.getMessage()
			+ "]");
		} catch (Exception e) {
			LOGGER.error("TimeSquare addDeptSync Error [" + params.get("LogonID") + "]" + "[Message : " + e.getMessage()
					+ "]");
		} finally {
			if (conTS != null) {
				conTS.disconnect();
				conTS = null;
			}
			if (wrTS != null) {
				wrTS.close();
			}
		}

		return bReturn;
	}

	/**
	 * @description 타임스퀘어 연동
	 * @param encodedUrl String
	 * @param method String
	 * @return JSONObject
	 * @throws Exception
	 */
	@Override
	public CoviMap getJson(String encodedUrl, String method) throws Exception {
		CoviMap resultList = new CoviMap();
		HttpURLConnectUtil url = new HttpURLConnectUtil();
		String sMethod = method;

		try {
			if (sMethod.equals("POST")) {
				resultList = url.httpConnect(encodedUrl, sMethod, 10000, 10000, "xform", "Y");
			} else if (sMethod.equals("GET")) {
				resultList = url.httpConnect(encodedUrl, sMethod, 10000, 10000, "xform", "Y");
			}
			LOGGER.debug("URL : " + encodedUrl);
		} catch (NullPointerException ex){
			throw ex;
		} catch (Exception ex) {
			throw ex;
		} finally {
			url.httpDisConnect();
		}

		return resultList;
	}

	////////////////////////////////////////////////////////////////////////////////////////////
	//로그
	////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * 로그 기록
	 * 
	 * @param params
	 *            - CoviMap
	 * @return void
	 * @throws Exception
	 */
	@Override
	public void insertGroupLogList(CoviMap params) throws Exception {
		if (params.get("SyncType") != null)
			coviMapperOne.insert("organization.syncmanage.insertGroupLogList", params); // insert to log_object_group
	}

	/**
	 * insertLogListLog : 동기화 로그 기록
	 * 
	 * @param SyncMasterID
	 * @param LogType
	 * @param TargetType
	 * @param SyncType
	 * @param LogMessage
	 * @param SyncServer
	 * @throws Exception
	 */
	@Override
	public void insertLogListLog(int SyncMasterID, String LogType, String TargetType, String SyncType, String LogMessage, String SyncServer) throws Exception {
		CoviMap params = new CoviMap();

		params.put("LogMasterID", SyncMasterID);
		params.put("LogType", LogType);
		params.put("TargetType", TargetType);
		params.put("SyncType", SyncType);
		params.put("LogMessage", LogMessage);
		params.put("SyncServer", SyncServer);

		try {
			coviMapperOne.insert("organization.syncmanage.insertLogListLog", params);
		} catch (NullPointerException ex){
			LOGGER.error("insertLogListLog Error  " + "[Message : " + ex.getMessage() + "]");
		}
		catch (Exception ex) {
			LOGGER.error("insertLogListLog Error  " + "[Message : " + ex.getMessage() + "]");
		}
	}
	@Override
	public CoviList selectSubSystemGroupInfo(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("organization.conf.manage.selectGroupInfo", params);
		return list;
	}

	/**
	 * 부서리스트 가져오기 select (CRM 테스트용 - 삭제)
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectCrmDeptList(CoviMap params) throws Exception {
		CoviMap resultList = null;
		CoviList list = null;
		int cnt = 0;

		try {
			params.put("lang", SessionHelper.getSession("lang"));
			resultList = new CoviMap();
			list = coviMapperOne.list("organization.conf.manage.selectCrmDeptList", params);
			cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectAllDeptListCnt", params);

			resultList.put("list", CoviSelectSet.coviSelectJSON(list,
					"GroupID,GroupCode,CompanyCode,GroupType,MemberOf,GroupPath,RegionCode,DisplayName,MultiDisplayName,ShortName"
					+ ",MultiShortName,OUName,OUPath,SortKey,SortPath,IsUse,IsDisplay,IsMail,IsHR,PrimaryMail,SecondaryMail,ManagerCode"
					+ ",Description,ReceiptUnitCode,ApprovalUnitCode,Receivable,Approvable,RegistDate,ModifyDate"
					+ ",Reserved1,Reserved2,Reserved3,Reserved4,Reserved5,Reserved6,LANG_DISPLAYNAME,LANG_SHORTNAME,MANAGERNAME,MEMBER_CNT"
					));
			resultList.put("cnt", cnt);

		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return resultList;
	}

	// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// 사용자 (CRM 테스트용 - 삭제)
	// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * 사용자 목록 select (CRM 테스트용 - 삭제)
	 * 
	 * @param params
	 *            - CoviMap
	 * @return resultList - JSON
	 * @throws Exception
	 */
	@Override
	public CoviMap selectCrmUserList(CoviMap params) throws Exception {
		CoviMap resultList = null;
		CoviMap page = null;
		CoviList list = null;

		try {
			resultList = new CoviMap();
			if (params.containsKey("pageNo")) {
				int cnt = (int) coviMapperOne.getNumber("organization.conf.manage.selectUserListCnt", params);
				page = ComUtils.setPagingData(params, cnt);
				params.addAll(page);
				resultList.put("page", page);
			}
			list = coviMapperOne.list("organization.conf.manage.selectCrmUserList", params);

			resultList.put("list", CoviSelectSet.coviSelectJSON(list, "USERCODE,SORTKEY,LANG_DISPLAYNAME,LANG_JOBTITLENAME,LANG_JOBPOSITIONNAME,LANG_JOBLEVELNAME,ISUSE,ISHR,MAILADDRESS,ISDISPLAY"));

		} catch (ArrayIndexOutOfBoundsException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (NullPointerException e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		} catch (Exception e) {
			LOGGER.error(e.getLocalizedMessage(), e);
		}

		return resultList;
	}
	
}
