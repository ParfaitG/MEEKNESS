<html>
<head><title>Meekness</title></head>
<link rel="stylesheet" type="text/css" href="style.css"/>

<body>

  <div class="dark-matter">
    <h1>Meekness Characters</h1>

  <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
  <%@ page contentType="text/html" pageEncoding="UTF-8" import="proc.util.MeeknessData" %>
  <%@ page import="java.util.List" %>

  <%@ page trimDirectiveWhitespaces="true" %>

  <% 

       MeeknessData myclass = new MeeknessData();

       List<String[]> charCbo = myclass.charDropDown();
       session.setAttribute("charCbo", charCbo); 

       Integer meekchar;

       if((request.getParameter("isSubmit") == null)?false:true){
            meekchar = Integer.parseInt(request.getParameter("meekchar"));
       } else {
            meekchar = 197;
       }

       List<String> charList = myclass.getChar(meekchar);
       session.setAttribute("charList", charList); 

       List<String> qualList = myclass.getQual(meekchar);
       session.setAttribute("qualList", qualList); 

       List<String[]> mcharList = myclass.getMatchChars(meekchar);
       session.setAttribute("mcharList", mcharList); 

       List<String> mqualList = myclass.getMatchQuals(meekchar);
       session.setAttribute("mqualList", mqualList); 
  %>

    <form id="meek_form" class="dark-matter" method="post" action="<%=request.getRequestURI()%>">
       <h2>Character</h2>
       <select name="meekchar" onchange="this.form.submit()">
          <option value="">Select a Character</option>
             <c:forEach items="${charCbo}" var="value">
                <option value="${value[0]}">${value[1]}</option>
             </c:forEach>
       </select>
       <input type="hidden" name="isSubmit" value="true">
    </form>

    <img src="<c:out value="${charList[0]}"/>" alt="Meek Character" height="300" width="400">
    <h3>Description</h3>
    <p><c:out value="${charList[1]}"/></p>
    <h3>Quote</h3>
    <p><c:out value="${charList[2]}"/></p>
    <h3>Qualities</h3>
    <ul>
       <c:forEach items="${qualList}" var="value">
         <li>${value}</li>
       </c:forEach>
    </ul>
    <h3>Matches</h3>
    <ul>
       <li>Matches <c:out value="${mcharList.size()}"/> out of 150 characters</li>
       <br/>
       <li>Top 5 Characters Matches</li>
       <ul>
          <c:forEach begin="0" end="4" varStatus="i">
	    <form id="charlinks_${i.index}" action="<%= request.getRequestURI() %>" method="post">
               <input type="hidden" name="meekchar" value="${mcharList[i.index][0]}">
               <input type="hidden" name="isSubmit" value="true">
	       <li><a href="#" onclick="document.getElementById('charlinks_${i.index}').submit();">${mcharList[i.index][1]}</a></li>
            </form>
          </c:forEach>
       </ul>
       <br/>
       <li>Top 5 Quality Matches</li>
           <ul>
             <c:forEach begin="0" end="4" varStatus="i">
   	        <li>${mqualList[i.index]}</li>
             </c:forEach>
           </ul>
     </ul>
     </div>

</body>
</html>
