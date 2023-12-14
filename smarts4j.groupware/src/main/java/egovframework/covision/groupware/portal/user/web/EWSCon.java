package egovframework.covision.groupware.portal.user.web;

import java.net.URI;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.service.FileUtilService;
import egovframework.covision.groupware.portal.user.service.PortalSvc;
import microsoft.exchange.webservices.data.core.ExchangeService;
import microsoft.exchange.webservices.data.core.PropertySet;
import microsoft.exchange.webservices.data.core.enumeration.misc.ConnectingIdType;
import microsoft.exchange.webservices.data.core.enumeration.misc.ExchangeVersion;
import microsoft.exchange.webservices.data.core.enumeration.property.BasePropertySet;
import microsoft.exchange.webservices.data.core.enumeration.property.WellKnownFolderName;
import microsoft.exchange.webservices.data.core.enumeration.search.FolderTraversal;
import microsoft.exchange.webservices.data.core.enumeration.search.SortDirection;
import microsoft.exchange.webservices.data.core.service.folder.Folder;
import microsoft.exchange.webservices.data.core.service.item.EmailMessage;
import microsoft.exchange.webservices.data.core.service.item.Item;
import microsoft.exchange.webservices.data.core.service.schema.FolderSchema;
import microsoft.exchange.webservices.data.core.service.schema.ItemSchema;
import microsoft.exchange.webservices.data.credential.ExchangeCredentials;
import microsoft.exchange.webservices.data.credential.WebCredentials;
import microsoft.exchange.webservices.data.misc.ImpersonatedUserId;
import microsoft.exchange.webservices.data.search.FindFoldersResults;
import microsoft.exchange.webservices.data.search.FindItemsResults;
import microsoft.exchange.webservices.data.search.FolderView;
import microsoft.exchange.webservices.data.search.ItemView;
import microsoft.exchange.webservices.data.search.filter.SearchFilter;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

/**
 * @Class Name : EWSCon.java
 * @Description : Exchange 공통 컨테이너 Controller
 * @Modification Information @ 2017.06.19 최초생성
 *
 * @author 코비젼 연구소
 * @since 2017. 06.19
 * @version 1.0
 * @see Copyright (C) by Covision All right reserved.
 */

@Controller
public class EWSCon {
	private static final Logger LOGGER = LogManager.getLogger(PortalCon.class);

	final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

	/**
	 * getUnMailCnt - 안읽은 메일건수 정보 가져오기
	 * 
	 * @param url
	 * @return returnData
	 * @throws Exception
	 */

	@RequestMapping(value = "portal/getUnMailCount.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap getUnMailCount(HttpServletRequest request, HttpServletResponse respons)
			throws Exception {

		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);

		String useremail = userDataObj.getString("UR_Mail");

		String Exch_EWSURL = RedisDataUtil.getBaseConfig("Exch_EWSURL");

		String Exch_AdminID = RedisDataUtil.getBaseConfig("Exch_AdminID");
		String Exch_AdminPW = RedisDataUtil.getBaseConfig("Exch_AdminPW");
		String Exch_Domain = RedisDataUtil.getBaseConfig("Exch_Domain");

		CoviMap returnData = new CoviMap();
		String totalCount = "0";
		try {
			// ExchangeService service = new
			// ExchangeService(ExchangeVersion.Exchange2010_SP2);
			ExchangeService service = new ExchangeService(ExchangeVersion.Exchange2010);
			service.setUrl(new URI(Exch_EWSURL));

			ExchangeCredentials credentials = new WebCredentials(Exch_AdminID, Exch_AdminPW, Exch_Domain);
			service.setCredentials(credentials);

			ImpersonatedUserId imperUserid = new ImpersonatedUserId(ConnectingIdType.SmtpAddress, useremail);
			service.setImpersonatedUserId(imperUserid);

			int unreadcnt = 0;

			Folder inboxfolder = Folder.bind(service, WellKnownFolderName.Inbox);
			unreadcnt = inboxfolder.getUnreadCount();

			FolderView view = new FolderView(Integer.MAX_VALUE);
			view.setTraversal(FolderTraversal.Deep);

			SearchFilter searchFilter = new SearchFilter.IsGreaterThan(FolderSchema.UnreadCount, 0);
			FindFoldersResults foldersResults = service.findFolders(WellKnownFolderName.Inbox, view);

			ArrayList<Folder> folderIds = foldersResults.getFolders();
			for (int i = 0; i < folderIds.size(); i++) {
				Folder fd = folderIds.get(i);
				String folderClass = fd.getFolderClass();
				String folderName = fd.getDisplayName();
				LOGGER.debug("folderClass:" + folderClass + ":folderName:" + folderName);
				if (folderClass.equals("IPF.Note")) {
					int UnreadCount = fd.getUnreadCount();
					unreadcnt += UnreadCount;
				}
			}
			totalCount = Integer.toString(unreadcnt);
			returnData.put("count", totalCount);
			returnData.put("status", Return.SUCCESS);

		} catch (NullPointerException ex) {
			LOGGER.error("getUnMailCount 오류 getMessage:" + ex.getMessage(), ex);
			returnData.put("count", totalCount);
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y") ? ex.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			LOGGER.error("getUnMailCount 오류 getMessage:" + ex.getMessage(), ex);
			returnData.put("count", totalCount);
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y") ? ex.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}

	/**
	 * 웹파트 - 임직원소식 > 웹파트 이메일 목록 조회
	 * 
	 * @param request
	 * @param response
	 * @return
	 * @throws Exception
	*/
	@RequestMapping(value = "portal/getMailList.do", method = { RequestMethod.GET, RequestMethod.POST })
	public @ResponseBody CoviMap getMailList(HttpServletRequest request, HttpServletResponse response)
			throws Exception {

		String domainName = request.getServerName();

		domainName = domainName.replace("dgw.", "").replace("mgw.", "").replace("gw.", "");

		String PageCount = request.getParameter("PageCount");

		boolean isMobile = ClientInfoHelper.isMobile(request);
		CoviMap userDataObj = SessionHelper.getSession(isMobile);

		String useremail = userDataObj.getString("UR_Mail");
		String Exch_EWSURL = RedisDataUtil.getBaseConfig("Exch_EWSURL");
		String Exch_AdminID = RedisDataUtil.getBaseConfig("Exch_AdminID");
		String Exch_AdminPW = RedisDataUtil.getBaseConfig("Exch_AdminPW");
		String Exch_Domain = RedisDataUtil.getBaseConfig("Exch_Domain");

		CoviMap returnData = new CoviMap();
		JSONArray returnArray = new JSONArray();

		try {

			ExchangeService service = new ExchangeService(ExchangeVersion.Exchange2010);
			service.setUrl(new URI(Exch_EWSURL));

			ExchangeCredentials credentials = new WebCredentials(Exch_AdminID, Exch_AdminPW, Exch_Domain);
			service.setCredentials(credentials);

			ImpersonatedUserId imperUserid = new ImpersonatedUserId(ConnectingIdType.SmtpAddress, useremail);
			service.setImpersonatedUserId(imperUserid);

			ItemView view = new ItemView(Integer.parseInt(PageCount));
			view.getOrderBy().add(ItemSchema.DateTimeReceived, SortDirection.Descending);
			FindItemsResults<Item> findItemsResults = service.findItems(WellKnownFolderName.Inbox, view);

			for (Item item : findItemsResults) {
				PropertySet propSet = new PropertySet(BasePropertySet.IdOnly);

				item.load();
				Item items = Item.bind(service, item.getId(), propSet);
				EmailMessage email = (EmailMessage) items;
				email.load();

				String strIsRead = "N";
				if (email.getIsRead()) {
					strIsRead = "Y";
				}
				String strFromEmail = email.getFrom().toString();
				String strSender = email.getSender().getName();
				String strSubject = email.getSubject();
				SimpleDateFormat fm = new SimpleDateFormat("yyyy-MM-dd");
				String strReceivedDate = fm.format(item.getDateTimeReceived());
				String itemId = URLEncoder.encode(email.getId().toString(), "UTF-8");
				String strChangeKey = URLEncoder.encode(email.getId().getChangeKey(), "UTF-8");
				// &mck=CQAAABYAAACJs7nhb4FaTYIhAS8g8XsRAAADn59Q";
				// String strLinkUrl = mailSvcUrl +
				// "/WebSite/Mail/MailView_WindowPop.aspx?system=Mail&mid="+itemId+"&mck="+strChangeKey;
				JSONObject jsonObj = new JSONObject();
				// jsonObj.put("LinkUrl",strLinkUrl);
				jsonObj.put("mid", itemId);
				jsonObj.put("mck", strChangeKey);
				jsonObj.put("FromEmail", strFromEmail);
				jsonObj.put("FromName", strSender);
				jsonObj.put("Subject", strSubject);
				jsonObj.put("DateReceive", strReceivedDate);
				jsonObj.put("IsRead", strIsRead);
				returnArray.add(jsonObj);
			}

			returnData.put("data", returnArray);
			returnData.put("status", Return.SUCCESS);

		} catch (NullPointerException ex) {
			LOGGER.error("getMailList 오류 getMessage:" + ex.getMessage(), ex);
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y") ? ex.getMessage() : DicHelper.getDic("msg_apv_030"));
		} catch (Exception ex) {
			LOGGER.error("getMailList 오류 getMessage:" + ex.getMessage(), ex);
			returnData.put("status", Return.FAIL);
			returnData.put("message", isDevMode.equalsIgnoreCase("Y") ? ex.getMessage() : DicHelper.getDic("msg_apv_030"));
		}

		return returnData;
	}
 
}