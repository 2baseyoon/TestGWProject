<%@ WebHandler Language="C#" Class="AspServer.UploadHandler" %>

using System;
using System.IO;
using System.Web;

namespace AspServer
{
    public class UploadHandler : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            string allowFileExt = "gif,jpg,jpeg,png,bmp,wmv,asf,swf,avi,mpg,mpeg,mp4,txt,doc,docx,xls,xlsx,ppt,pptx,hwp,zip,pdf,flv";
            string allowFileMimeType = "image/gif,image/jpeg,image/png,image/bmp,video/x-ms-wmv,video/x-ms-asf,video/mpeg,video/mp4,text/plain," +
                        "application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet," +
                        "application/vnd.ms-powerpoint,application/vnd.openxmlformats-officedocument.presentationml.presentation,application/x-hwp,application/haansofthwp," +
                        "application/vnd.hancom.hwp,application/zip,application/pdf,video/x-flv";
            int uploadMaxSize = 2147483647;

            string uploadDir = "/upload/" + DateTime.Now.ToString("yyyyMMdd") + "/";
            string uploadDirPath = HttpContext.Current.Server.MapPath(uploadDir);

            if (!Directory.Exists(uploadDirPath))
            {
                Directory.CreateDirectory(uploadDirPath);
            }

            context.Response.ContentType = "application/json";

            try {
                HttpPostedFile file = context.Request.Files["file"];
                int extPos = file.FileName.LastIndexOf(".");
                string ext = null;

                if (extPos > -1)
                {
                    ext = file.FileName.Substring(extPos + 1).ToLower();
                }

                if (ext != null && file.ContentLength <= uploadMaxSize && allowFileExt.Contains(ext) && allowFileMimeType.Contains(file.ContentType))
                {
                    string filePath = uploadDirPath + System.IO.Path.GetFileName(file.FileName);
                    file.SaveAs(filePath);

                    string appUrl = HttpRuntime.AppDomainAppVirtualPath;

                    if (appUrl != "/")
                    {
                        appUrl = "/" + appUrl;
                    }
                    else
                    {
                        appUrl = "";
                    }

                    var baseUrl = string.Format("{0}://{1}{2}", context.Request.Url.Scheme, context.Request.Url.Authority, appUrl);


                    context.Response.Write("{\"location\": \"" + baseUrl + uploadDir + file.FileName + "\"}");
                } else
                {
                    context.Response.Write("{\"Error\": \"file type not allowed!\"}");
                }

            } catch(Exception e)
            {
                Console.WriteLine("{0} Exception caught.", e.Message);
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}