

import org.bson.Document;

import com.mongodb.MongoClient;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoCollection;
import com.mongodb.DBCursor;
import com.mongodb.BasicDBObject;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Projections;
import com.mongodb.client.MongoCursor;

import java.util.List;
import java.util.ArrayList;
import java.util.logging.Logger;
import java.util.logging.Level;

import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import java.awt.*;  
import java.awt.event.*;
import java.awt.image.BufferedImage;
import javax.swing.*;
import javax.imageio.ImageIO;


public class Mongo_Swing extends Frame implements WindowListener {
      
   private static final long serialVersionUID = 7526472295622776147L;   
   
   public static void main(String[] args) {      
      Build_GUI();
   }

   public static void Build_GUI() {
      
      ArrayList<String> char_list = new ArrayList<String>();

      Logger mongoLogger = Logger.getLogger( "org.mongodb.driver" );
      mongoLogger.setLevel(Level.SEVERE); 

      MongoClient client = new MongoClient( "*****" , 27017 );
      MongoDatabase conn = client.getDatabase("meekness");

      char_list = get_CharData(conn);

      client.close();

      try {
        new Mongo_Swing(char_list);

      } catch ( IOException ioe ) {            
          System.out.println(ioe.getMessage());            
      }        
   }

   public static ArrayList<String> get_CharData(MongoDatabase db){

      ArrayList<String> dbList = new ArrayList<String>();      

      Document query = new Document("character",1);

      MongoCollection<Document> collection = db.getCollection("characters");
      MongoCursor<Document> cursor = collection.find().projection(Projections.include("character")).sort(query).iterator(); 


      while(cursor.hasNext()){
          Document o = cursor.next();
          dbList.add(o.get("character").toString());             
      }

      cursor.close();
     
      return(dbList);      
   }

   public static List<Object> get_CharPic(MongoDatabase db, String param){

      List<Object> dbList = new ArrayList<Object>(); 
   
      MongoCollection<Document> collection = db.getCollection("characters");
      MongoCursor<Document> cursor = collection.find(Filters.eq("character", param))
                                               .projection(Projections.include("character", "picture", "description")).iterator(); 

      while(cursor.hasNext()){
          Document o = cursor.next();

          dbList.add(o.get("character"));             
          dbList.add(o.get("picture")); 
          dbList.add(o.get("description")); 
      }

      cursor.close();

      return(dbList);      
   }
   
   public static ArrayList<String> get_QualData(MongoDatabase db, String param){

      ArrayList<String> dbList = new ArrayList<String>();      

      MongoCollection<Document> collection = db.getCollection("characters");
      MongoCursor<Document> cursor = collection.find(Filters.eq("character", param))
                                               .projection(Projections.include("character", "qualities")).iterator(); 

      while(cursor.hasNext()){
          Document o = cursor.next();

          Document q = (Document)o.get("qualities");
          for (Object d: q.values())
             dbList.add(d.toString());
             
      }
     
      cursor.close();

      return(dbList);      
   }  

   public static byte[] hexStringToByteArray(String s) {

       // CREDIT: @Dave L.: https://stackoverflow.com/a/140861/1422451

       int len = s.length();
       byte[] data = new byte[len / 2];

       for (int i = 0; i < len; i += 2) {
           data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                                + Character.digit(s.charAt(i+1), 16));
       }
       return data;
   }

   public static void runData(String charPick, JPanel guipanel, GridBagConstraints c) throws IOException {

      List<Object> charpic_list = new ArrayList<Object>();
      ArrayList<String> qual_list = new ArrayList<String>();

      MongoClient client = new MongoClient( "10.0.0.220" , 27017 );
      MongoDatabase conn = client.getDatabase("meekness");

      charpic_list = get_CharPic(conn, charPick);
      qual_list = get_QualData(conn, charpic_list.get(0).toString());

      client.close();

      if(guipanel.getComponentCount() > 3) {

         Component[] componentList = guipanel.getComponents();

         // REMOVE PREVIOUS CHARACTER AND QUALITIES
         for(Component cp : componentList){

            if (cp == componentList[0]) continue;
            if (cp == componentList[1]) continue;
            if (cp == componentList[2]) continue;

            guipanel.remove(cp);

         }
         guipanel.revalidate();
         guipanel.repaint();
      }

      Font ctrlFont = new Font("Arial", Font.PLAIN, 12);
      Font headFont = ctrlFont.deriveFont(18F);

      // CHARACTER IMAGE   
      JLabel imglbl = new JLabel(charpic_list.get(0).toString(), SwingConstants.CENTER);      
      imglbl.setFont(headFont);      
      c.fill = GridBagConstraints.HORIZONTAL;
      c.ipady = 0; 
      c.weighty = 0.05;      
      c.gridx = 0;
      c.gridy = 2;
      guipanel.add(imglbl, c);

      byte[] blob = hexStringToByteArray(charpic_list.get(1).toString());

      ImageIcon imgIcon = new ImageIcon(blob);
      Image image = imgIcon.getImage(); 						
      Image newimg = image.getScaledInstance(386, 250,  java.awt.Image.SCALE_SMOOTH);
      imgIcon = new ImageIcon(newimg);

      JLabel imagelabel = new JLabel("", imgIcon, JLabel.LEFT);   

      c.fill = GridBagConstraints.HORIZONTAL;
      c.ipady = 0; 
      c.weighty = 0.05;      
      c.gridx = 0;
      c.gridy = 3;
      guipanel.add(imagelabel, c);


      // DESCRIPTION LABEL
      JLabel desc_lbl = new JLabel("<html><body style='width:290px'>" + charpic_list.get(2).toString(), SwingConstants.CENTER);
      desc_lbl.setFont(ctrlFont);
      c.fill = GridBagConstraints.HORIZONTAL;
      c.ipady = 0; 
      c.weighty = 0.05;      
      c.gridx = 0;
      c.gridy = 4;
      guipanel.add(desc_lbl, c);


      // QUALITY LABELS
      for (int i = 0; i < qual_list.size(); i++){
	JLabel qual_lbl = new JLabel(qual_list.get(i), SwingConstants.LEFT);
	qual_lbl.setFont(headFont);
	c.fill = GridBagConstraints.HORIZONTAL;
	c.ipady = 0; 
	c.weighty = 0.05;      
	c.gridx = 0;
	c.gridy = i + 5;
	guipanel.add(qual_lbl, c);
      }  

   }


   public Mongo_Swing(ArrayList<String> char_list) throws IOException {

      // SUPER FRAME SETTINGS
      setTitle("Meekness Characters");    
      setSize(400, 850);
      JPanel guipanel = new JPanel(new GridBagLayout());
      GridBagConstraints c = new GridBagConstraints();
      add(guipanel);
            
      Font ctrlFont = new Font("Arial", Font.PLAIN, 12);
      Font headFont = ctrlFont.deriveFont(18F);
            
      // DB IMAGE      
      ImageIcon dbimgIcon = new ImageIcon("Mongo.jpg");
      Image dbimage = dbimgIcon.getImage();
      Image newdbimg = dbimage.getScaledInstance(70, 70,  java.awt.Image.SCALE_SMOOTH);
      dbimgIcon = new ImageIcon(newdbimg);
      JLabel dbimagelabel = new JLabel("", dbimgIcon, JLabel.LEFT);      
      c.fill = GridBagConstraints.HORIZONTAL;
      c.ipady = 0; 
      c.weighty = 0.05;      
      c.gridx = 0;
      c.gridy = 0;
      guipanel.add(dbimagelabel, c);
 
      JLabel dbimglbl = new JLabel("               MongoDB", SwingConstants.LEFT);      
      dbimglbl.setFont(headFont);      
      c.fill = GridBagConstraints.HORIZONTAL;
      c.ipady = 0; 
      c.weighty = 0.05;      
      c.gridx = 0;
      c.gridy = 0;
      guipanel.add(dbimglbl, c);
      

      // CHARACTERS DROP DOWN
      Choice charChoice = new Choice();
      charChoice.setFont(ctrlFont);
      c.fill = GridBagConstraints.HORIZONTAL;
      c.ipady = 0; 
      c.weighty = 0.05;      
      c.gridx = 0;
      c.gridy = 1;
      guipanel.add(charChoice, c);
      
      for (String i: char_list){
         charChoice.add(i);
      } 
      guipanel.add(charChoice, c);

      runData("Singer, Amazing Grace", guipanel, c);

      charChoice.addItemListener(new ItemListener(){ 
	 public void itemStateChanged(ItemEvent ie){           
             try {           
                runData(charChoice.getSelectedItem().toString(), guipanel, c);
             } catch ( IOException ioe ) {            
                System.out.println(ioe.getMessage());            
             } 
         }            
      });

      addWindowListener(this);     
      setVisible(true);      

   }
   
   // WindowEvent handlers
   @Override
   public void windowClosing(WindowEvent evt) {
      // Terminate the program
      System.exit(0);                                                          
   }
   
   @Override public void windowOpened(WindowEvent evt) { }
   @Override public void windowClosed(WindowEvent evt) { }
   @Override public void windowIconified(WindowEvent evt) { }
   @Override public void windowDeiconified(WindowEvent evt) { }
   @Override public void windowActivated(WindowEvent evt) { }
   @Override public void windowDeactivated(WindowEvent evt) { }
}
