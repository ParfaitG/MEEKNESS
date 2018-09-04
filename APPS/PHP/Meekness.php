<html>
<head><title>Meekness</title></head>
<link rel="stylesheet" type="text/css" href="style.css"/>

<body>

  <div class="basic-grey">
    <h1>Meekness Characters</h1>
  <?php

    // DEFINE FUNCTIONS
    function dbConnect() {

	$host='****';
	$database='****';
	$username='***';
	$password='***';

	# open connection
	$conn = new PDO("mysql:host=$host;port=3306;dbname=$database",$username,$password);
	$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        return $conn;	    
    }

    function getChar($dbh, $orig) {
        
        # GET CHARACTER AND DATA
	$sql = "SELECT c.`Character`, c.Description, c.Quote, c.Picture FROM Characters c WHERE c.ID = ?";

	$STH = $dbh->prepare($sql);
        $STH->bindParam(1, $orig, PDO::PARAM_INT);
        $STH->execute();

        $row = $STH->fetch(PDO::FETCH_ASSOC);

        return array(base64_encode($row['Picture']), $row['Description'], $row['Quote']);

    }

    function getQual($dbh, $orig) {

        # GET QUALITIES
        $sql = "SELECT q.Quality FROM Characters c " .
               "INNER JOIN Qualities q ON q.CharacterID = c.ID " . 
	       "WHERE c.ID = ?";

      	$STH = $dbh->prepare($sql);
        $STH->bindParam(1, $orig, PDO::PARAM_INT);
        $STH->execute();
 
        $qualities = [];

        $STH->setFetchMode(PDO::FETCH_ASSOC);

        while($row = $STH->fetch()) {
            $qualities[] = $row['Quality'];
        }

        return $qualities;
    }


    function getCharMatches($dbh, $orig) {

        # MATCHED CHARACTERS
        $sql = "SELECT c2.ID, c2.Character As MatchedChar
                FROM 
                 (SELECT c.ID, c.`Character`, q.Quality
                  FROM `Characters` c
                  INNER JOIN Qualities q ON c.ID = q.CharacterID
                 ) c1
                INNER JOIN 
                 (SELECT c.ID, c.`Character`, q.Quality 
                  FROM `Characters` c
                  INNER JOIN Qualities q ON c.ID = q.CharacterID
                 ) c2 ON c1.Quality = c2.Quality
                WHERE c1.ID = ? AND c2.ID <> ?
                GROUP BY c1.`Character`, c2.ID, c2.`Character`
                ORDER BY Count(*) DESC";

      	$STH = $dbh->prepare($sql);
        $STH->bindParam(1, $orig, PDO::PARAM_INT);
        $STH->bindParam(2, $orig, PDO::PARAM_INT);
        $STH->execute();
 
        $qualities = [];

        $STH->setFetchMode(PDO::FETCH_ASSOC);

        while($row = $STH->fetch()) {
            $qualities[] = array($row['ID'], $row['MatchedChar']);
        }

        return $qualities;
    }

    function getQualMatches($dbh, $orig) {

        # MATCHED QUALITIES
        $sql = "SELECT c1.Quality As MatchedQual
                FROM 
                 (SELECT c.ID, c.`Character`, q.Quality
                  FROM `Characters` c
                  INNER JOIN Qualities q ON c.ID = q.CharacterID
                 ) c1
                INNER JOIN 
                 (SELECT c.ID, c.`Character`, q.Quality 
                  FROM `Characters` c
                  INNER JOIN Qualities q ON c.ID = q.CharacterID
                 ) c2 ON c1.Quality = c2.Quality
                WHERE c1.ID = ? AND c2.ID <> ?
                GROUP BY c1.`Quality`
                ORDER BY Count(*) DESC";


      	$STH = $dbh->prepare($sql);
        $STH->bindParam(1, $orig, PDO::PARAM_INT);
        $STH->bindParam(2, $orig, PDO::PARAM_INT);
        $STH->execute();
 
        $qualities = [];

        $STH->setFetchMode(PDO::FETCH_ASSOC);

        while($row = $STH->fetch()) {
            $qualities[] = $row['MatchedQual'];
        }

        return $qualities;

    }

    function dbClose($dbh) {
	$dbh = null;
    }

    $dbh = dbConnect();

    $sql = "SELECT `ID`, `Character` FROM Characters ORDER BY `Character`";
    $STH = $dbh->query($sql);

  ?>

    <form name="meekform" class="smart-green" action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post">
       <h2>Character</h2>
          <select name="meekchar" onchange="this.form.submit()">
              <option value="">Select a Character</option>
  <?php 
       
	  while($row = $STH->fetch(PDO::FETCH_ASSOC)) {
  ?>
              <option value="<?php echo $row["ID"]; ?>"><?php echo $row["Character"]; ?></option>
  <?php
          }

    dbClose($dbh);

  ?>
          </select>
       <input type="hidden" name="isSubmit" value="true">
    </form>

  <?php

    if (isset($_POST['isSubmit'])) { 
        $meek_char = $_POST['meekchar'];
    } else {
        $meek_char = 25;
    }

        $dbh = dbConnect();
        $output = getChar($dbh, $meek_char);
  ?>

        <img src="data:image/jpeg;base64, <?php echo $output[0]; ?>" alt="Meek Character" height="300" width="400">
        <h3>Description</h3>
        <p><?php echo $output[1]; ?></p>
        <h3>Quote</h3>
        <p><?php echo $output[2]; ?></p>

        <h3>Qualities</h3>
        <ul>
  <?php
         
         $output = getQual($dbh, $meek_char);

         foreach($output as $qual) {
  ?>
	    <li><?php echo $qual; ?></li>

  <?php
     	 }         
         $output = getCharMatches($dbh, $meek_char);
  ?>
	 </ul>
        <h3>Matches</h3>
        <ul>
            <li>Matches <?php echo count($output); ?> out of 150 Characters</li>
            <br/>
            <li>Top 5 Character Matches</li>
            <ul>
  <?php
         for($i=0; $i<5; $i++) {
  ?>
	    <form id="charlinks_<?php echo $i; ?>" action="<?php echo $_SERVER['PHP_SELF']; ?>" method="post">
               <input type="hidden" name="meekchar" value="<?php echo $output[$i][0]; ?>">
               <input type="hidden" name="isSubmit" value="true">
               <li><a href="#" onclick="document.getElementById('charlinks_<?php echo $i; ?>').submit();"><?php echo $output[$i][1]; ?></a></li> 
            </form>
  <?php
     	 }
  ?>
            </ul>
            <br/>
            <li>Top 5 Quality Matches</li>
            <ul>
  <?php
         
         $output = getQualMatches($dbh, $meek_char);

         for($i=0; $i<5; $i++) {
  ?>
	    <li><?php echo $output[$i]; ?></li>

  <?php
     	 }
  ?>
            </ul>
        </ul>

  <?php
   dbClose($dbh);
  ?>

     </div>

  </body>
</html>
