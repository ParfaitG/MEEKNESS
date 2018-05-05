<html>
<head><title>Meekness</title></head>
<link rel="stylesheet" type="text/css" href="style.css"/>

<body>

  <div class="dark-matter">
    <h1>Meekness Characters</h1>

  <%@ page trimDirectiveWhitespaces="true" %>

  <%@ page import = "java.util.*" %>
  <%@ page import = "java.sql.*" %>
  <%@ page import = "java.io.InputStream" %>
  <%@ page import = "java.io.ByteArrayInputStream" %>
  <%@ page import = "java.io.ByteArrayOutputStream" %>
  <%@ page import = "java.io.IOException" %>
  <%@ page import = "org.apache.commons.io.IOUtils" %>
  <%@ page import = "org.apache.commons.codec.binary.Base64" %>

  <%
      String url = "jdbc:postgresql://*****:5432/meekness?user=***&password=***&ssl=false";            

      Connection conn = null;  
      Class.forName("org.postgresql.Driver");
      conn = DriverManager.getConnection(url, username, password);  

      String strSQL = "SELECT c.ID, c.Character FROM Characters c ORDER BY c.Character";

      PreparedStatement pstmt = conn.prepareStatement(strSQL);

      ResultSet rs = pstmt.executeQuery();
   
  %>
    <form class="dark-matter" action="<%=request.getRequestURI()%>">
       <h2>Character</h2>
       <select name="meekchar" onchange="this.form.submit()">
  <%
      while (rs.next()) {
  %>
          <option value="<%= rs.getInt("ID") %>"><%= rs.getString("Character") %></option>
  <%
      }
      rs.close();
      pstmt.close();
  %>
       </select>
       <input type="hidden" name="isSubmit" value="true">
    </form>

  <%!

      public List<String> getChar(Connection conn, int i){

         List<String> charList = new ArrayList<String>(); 

	 String strSQL = "SELECT c.Character, c.Description, c.Quote, c.Picture FROM Characters c WHERE c.ID = ?";

         try { 
	      PreparedStatement pstmt = conn.prepareStatement(strSQL);
              pstmt.setInt(1, i);

	      ResultSet rs = pstmt.executeQuery();

	      rs.next();
	      rs.getString(1);

	      //Blob blob = rs.getBlob("Picture");
              InputStream blob = ((InputStream) rs.getBinaryStream("Picture"));
	      //byte[] returnBytes = blob.getBytes(1, (int)blob.length());
              byte[] returnBytes = IOUtils.toByteArray(blob);

	      StringBuilder sb = new StringBuilder();
	      sb.append("data:image/jpeg;base64,");
	      sb.append(Base64.encodeBase64String(returnBytes));

	      String imgData = sb.toString();
              String descData = rs.getString(2);
              String quoteData = (rs.getString(3) == null) ? "" : rs.getString(3);

              charList.add(imgData);
              charList.add(descData);
              charList.add(quoteData);

	      rs.close();
	      pstmt.close();
 
	 } catch ( SQLException err ) {            
	     System.out.println(err.getMessage());           
	 } catch ( IOException ioe ) {            
             System.out.println(ioe.getMessage());            
         }    

         return charList;
      }

      public List<String> getQual(Connection conn, int i){

         List<String> l = new ArrayList<String>();

	 String strSQL = "SELECT q.Quality " +
	                 " FROM Characters c INNER JOIN Qualities q" + 
		         "  ON q.CharacterID = c.ID" + 
		         " WHERE c.ID = ?";

         try { 

	      PreparedStatement pstmt = conn.prepareStatement(strSQL);
              pstmt.setInt(1, i);

	      ResultSet rs = pstmt.executeQuery();

	      while (rs.next()) {
	         l.add(rs.getString("Quality"));
     	      }

	 } catch ( SQLException err ) {            
	      System.out.println(err.getMessage());          
	 }  

         return l;

      }
    
    
  %>

  <%

      if((request.getParameter("isSubmit") == null)?false:true){

         List<String> charList = getChar(conn, Integer.parseInt(request.getParameter("meekchar")));

  %>

	 <img src="<%= charList.get(0) %>" alt="Meek Character" height="300" width="400">
	 <h3>Description</h3>
         <p><%= charList.get(1) %></p>
	 <h3>Quote</h3>
         <p><%= charList.get(2) %></p>
	 <h3>Qualities</h3>
	 <ul>

  <%
         List<String> qualList = getQual(conn, Integer.parseInt(request.getParameter("meekchar")));

         for (String s: qualList) {
  %>
	     <li><%= s %></li>

  <%
     	 }
	 rs.close();
	 pstmt.close();
  %>

	  </ul>
     </div>

  <%
      } else {

         List<String> charList = getChar(conn, 197);

  %>

	 <img src="<%= charList.get(0) %>" alt="Meek Character" height="300" width="400">
	 <h3>Description</h3>
         <p><%= charList.get(1) %></p>
	 <h3>Quote</h3>
         <p><%= charList.get(2) %></p>
	 <h3>Qualities</h3>
	 <ul>

  <%
         List<String> qualList = getQual(conn, 197);

         for (String s: qualList) {
  %>
	     <li><%= s %></li>

  <%
     	 }
	 rs.close();
	 pstmt.close();
  %>

	  </ul>
     </div>

  <%

     }
     conn.close();
  %>
</body>
</html>
