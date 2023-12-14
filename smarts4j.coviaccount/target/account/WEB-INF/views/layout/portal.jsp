<%@ page language="java" contentType="text/html; charset=UTF-8"    pageEncoding="UTF-8"%>
<!-- <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> -->
<!doctype html>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles" %>
<!-- <html> -->
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title></title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body>
        <table style="width:100%;height:100%">
      <tr>
        <td>
          <tiles:insertAttribute name="header" />
        </td>
      </tr>
      <tr style="height:400px">
      <td>
       	<tiles:insertAttribute name="content" />
      </td>
      </tr>
      <tr>
        <td>
          <tiles:insertAttribute name="footer" />
        </td>
      </tr>
    </table>
  </body>
</html>