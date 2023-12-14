package egovframework.covision.groupware.collab.user.web;

import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.collab.user.service.CollabTodoSvc;
import egovframework.covision.groupware.collab.user.service.CollabProjectSvc;
import egovframework.covision.groupware.util.Ajax;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.Map;

import egovframework.baseframework.data.CoviMap;

@Controller
@RequestMapping("collab/todo")
public class CollabTodoCon {

    @Autowired
    private CollabTodoSvc collabTodoSvc;

    @Autowired
    private CollabProjectSvc collabProjectSvc;

    /**
     * @param params 내업무 리스트
     *               작성자 : jycho2
     * @return
     */
    @RequestMapping(value = "/myTaskList.do")
    public @ResponseBody    ModelMap myTaskList(@RequestParam Map<String, Object> params)  throws Exception {
        ModelMap modelMap = new ModelMap();
        try {
            //내 할일 목록
        	CoviMap cmap = new CoviMap();
        	cmap.put("myTodo","Y");
        	cmap.put("mode","STAT");
        	cmap.put("lang", SessionHelper.getSession("lang"));
        	cmap.put("USERID", SessionHelper.getSession("USERID"));
        	cmap.put("CompanyCode", SessionHelper.getSession("DN_Code"));
        	cmap.put("date1", ComUtils.removeMaskAll(params.get("date1")));
        	cmap.put("date2", ComUtils.removeMaskAll(params.get("date2")));
        	cmap.put("searchOption", params.get("searchOption"));
        	cmap.put("searchWord", params.get("searchWord"));
        	cmap.put("searchText", params.get("searchText"));
        	cmap.put("completMonth", params.get("completMonth"));
        	cmap.put("pageNo", params.get("pageNo"));
        	cmap.put("pageSize", params.get("pageSize"));
        	cmap.put("tagtype", params.get("tagType"));
        	cmap.put("tagval", params.get("tagVal"));

/*          modelMap.put("taskList", taskData.get("list"));
            modelMap.put("taskPage", taskData.get("page"));*/
			CoviMap taskInfo  = collabProjectSvc.getProjectTask(cmap);
			modelMap.put("taskFilter", taskInfo.get("taskFilter"));
			modelMap.put("taskData", taskInfo.get("taskData"));
        	
            //상단카운트
            modelMap.put("taskStat", collabTodoSvc.myTaskStat(cmap));
            modelMap.put("result", Ajax.OK.result());
        } catch (NullPointerException e) {
            modelMap.put("result", Ajax.NO.result());
        } catch (Exception e) {
            modelMap.put("result", Ajax.NO.result());
        }
        return modelMap;
    }

    /**
     * @param * 작성자 : jycho2
     * @return
     */
    @RequestMapping(value = "/collabTagPopup.do")
    public ModelAndView getTodoTagPop(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String returnURL = "user/collab/CollabTagPopup";
        ModelAndView mav = new ModelAndView(returnURL);
        return mav;
    }

    /**
     * 오더변경
     * 작성자 :jycho2
     *
     * @return
     */
    @RequestMapping(value = "orderUpd.do")
    public @ResponseBody
    ModelMap orderUpd(@RequestParam Map<String,Object> params) {

        ModelMap modelMap = new ModelMap();
        try {
            modelMap.put("msg", collabTodoSvc.orderUpd(params));
            modelMap.put("result", Ajax.OK.result());
        } catch (NullPointerException e) {
            e.toString();
            modelMap.put("result", Ajax.NO.result());
        } catch (Exception e) {
            e.toString();
            modelMap.put("result", Ajax.NO.result());
        }
        return modelMap;
    }
}
