package egovframework.covision.groupware.attend.user.web.rest;

import egovframework.baseframework.base.Enums;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.PropertiesUtil;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.attend.user.service.AttendAdminSettingSvc;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * @author nkpark
 */
@Controller
//@Api("Admin Controller API V1")
@RequestMapping("/attendAdminRest")
public class AttendAdminSettingRestCon {
    private Logger LOGGER = LogManager.getLogger(AttendAdminSettingRestCon.class);

    final String isDevMode = PropertiesUtil.getGlobalProperties().getProperty("isDevMode");

    @Autowired
    AttendAdminSettingSvc attendAdminSettingSvc;

    /**
     * @Method Name : getWorkPlaceListRest
     * @작성일 : 2021. 8. 13.
     * @작성자 : nkpark
     * @변경이력 :
     * @Method 설명 : 관리자 설정 - 근무지관리 리스트 조회 - restApi
     * @param request
     * @param response
     * @return
     * @throws Exception
     */
   // @ApiOperation(value = "XXX담기"  , notes ="XXX담기를  위한 API" , response=CoviMap.class )
    @RequestMapping(value = "/getWorkPlaceList.rest", method = RequestMethod.GET)
    public @ResponseBody
    CoviMap getWorkPlaceListRest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CoviMap returnList = new CoviMap();
        CoviMap resultList = new CoviMap();

        try {
            CoviMap params = new CoviMap();
            params.put("schTypeSel", request.getParameter("schTypeSel"));
            params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));

            resultList = attendAdminSettingSvc.getWorkPlaceList(params);


            returnList.put("list", resultList.get("list"));
            returnList.put("result", "ok");
            returnList.put("status", Enums.Return.SUCCESS);
            returnList.put("message", "조회되었습니다");
        } catch (NullPointerException e) {
            returnList.put("status", Enums.Return.FAIL);
            returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage(): DicHelper.getDic("msg_apv_030"));
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            returnList.put("status", Enums.Return.FAIL);
            returnList.put("message", "Y".equalsIgnoreCase(isDevMode)?e.getMessage(): DicHelper.getDic("msg_apv_030"));
            LOGGER.error(e.getLocalizedMessage(), e);
        }

        return returnList;
    }

    @RequestMapping(value = "/s3test.rest", method = RequestMethod.GET)
    public @ResponseBody
    CoviMap test(HttpServletRequest request, HttpServletResponse response) throws Exception {
        CoviMap returnList = new CoviMap();
        CoviMap resultList = new CoviMap();
        try {
            CoviMap params = new CoviMap();
            params.put("schTypeSel", request.getParameter("schTypeSel"));
            params.put("schTxt", ComUtils.RemoveSQLInjection(request.getParameter("schTxt"), 100));

            returnList.put("list", "dddd");
            returnList.put("result", "ok");
            returnList.put("status", Enums.Return.SUCCESS);
            returnList.put("message", "조회되었습니다");
        } catch (NullPointerException e) {
            returnList.put("status", Enums.Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        } catch (Exception e) {
            returnList.put("status", Enums.Return.FAIL);
            LOGGER.error(e.getLocalizedMessage(), e);
        }

        return returnList;
    }
}
