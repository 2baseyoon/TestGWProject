package egovframework.covision.groupware.bizreport.mobile.web;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;



import org.apache.commons.io.FilenameUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartRequest;

import egovframework.baseframework.base.Enums.Return;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.ClientInfoHelper;
import egovframework.coviframework.util.DateHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.RedisDataUtil;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.HttpURLConnectUtil;
import egovframework.covision.groupware.bizcard.user.service.BizCardGroupManageService;
import egovframework.covision.groupware.bizcard.user.service.BizCardListService;
import egovframework.covision.groupware.bizcard.user.service.BizCardManageService;

@Controller
@RequestMapping("/mobile/bizreport")
public class MOBizreportCommonCon {

}

