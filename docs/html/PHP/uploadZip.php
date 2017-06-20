<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="../../favicon.ico">

    <title>Cover Template for Bootstrap</title>

    <!-- Bootstrap core CSS -->
    <link href="./dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <link href="./assets/css/ie10-viewport-bug-workaround.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="cover.css" rel="stylesheet">

    <!-- Just for debugging purposes. Don't actually copy these 2 lines! -->
    <!--[if lt IE 9]><script src="../../assets/js/ie8-responsive-file-warning.js"></script><![endif]-->
    <script src="./assets/js/ie-emulation-modes-warning.js"></script>

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

    <div class="site-wrapper">

      <div class="site-wrapper-inner">

        <div class="cover-container">

          <div class="masthead clearfix">
            <div class="inner">
              <h3 class="masthead-brand">MaAp Laboratory</h3>
              <nav>
                <ul class="nav masthead-nav">
                  <li class="active"><a href="index.html">Home</a></li>
                  <li><a href="#">Downloads</a></li>
                  <li><a href="#">Tutorial</a></li>
		  <li><a href="#">About</a></li>
                </ul>
              </nav>
            </div>
          </div>
			
          <div class="inner cover">
            <h1 class="cover-heading">Neurocelle</h1>
            <p class="lead">A machine learning environment!</p>
		
		<form action=uploadZip.php method="post" enctype="multipart/form-data">
   			<label class="btn btn-default btn-file">
	        		<input type="file" name="fileToUpload" id="fileToUpload">
			</label>
			<input type="submit" value="Upload File" name="submit">
		</form>
		
		<?php
			$location = "uploads/";
			$name = $_FILES["fileToUpload"]["name"];
			$tmp_name = $_FILES["fileToUpload"]["tmp_name"];
			$size = $_FILES["fileToUpload"]["size"];
			$type = $_FILES["fileToUpload"]["type"];
			$ext = strtolower(substr($name,strpos($name,".")+1));
			
			//echo $ext;
			
			
			// Testing ...	
			if(isset($name)){
				if(!empty($name) && ($ext == "zip" || $ext == "tar.gz")){// && $type == "application/zip"){
					// Can upload only .zip files until 10M.
					if(move_uploaded_file($tmp_name,$location.$name)){
						echo "<p>Your file was successfully uploaded!</p>";
						
						$oname = substr($name,0,strpos($name,"."));
						
						passthru('mkdir actions/'. $oname, $returnval);
						passthru('cp ' . $location.$name . ' actions/' . $oname, $returnval);
						//passthru('cp ' . $location.$name . ' /home/leonel);
						//passthru('chmod 777 actions/' . $oname . '/' . $name, $returnval);
						passthru('chmod 777 -R actions/', $returnval);
						
						// Command 'cd' doesn't works.
						if($ext == 'zip'){
							passthru('unzip actions/' . $oname . '/' . $name . ' -d actions/' . $oname, $returnval);
						} else {
							passthru('tar -zxvf actions/' . $oname . '/' . $name . ' -C actions/' . $oname, $returnval);
						}
						
						// Matlab RUN!!
						//passthru('matlab -nojvm -r \'cd actions/' . $oname . '; '. $oname .'\'', $returnval);
						//exec('matlab -nojvm -r \'cd actions/' . $oname . '; '. $oname .'\' > actions/' . $oname . '/output');
						//passthru('pwd', $returnval);
						//echo $returnval;
						
						passthru('./ncl;', $returnval);
						passthru('echo "Msg atoumatica neurocelle" | mutt -s "Tretas" -c estrogonelda@hotmail.com estrogonelda@gmail.com -a actions/' . $oname . '/' . $name, $returnval);
						echo "<hr/>".$returnval;
					}else{
						echo "Error while uploading file!" . "<br>";
					}
				}else{
					echo "<p> Please, choose a .zip file. </p>";
				}
			}else{
				echo "<br> File unset.";
			}
		?>
          </div>

          <div class="mastfoot">
            <div class="inner">
              <p>Cover template for <a href="http://getbootstrap.com">Bootstrap</a>, by <a href="tplt.zip">@mdo</a>.</p>
            </div>
          </div>

        </div>

      </div>

    </div>

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
    <script>window.jQuery || document.write('<script src="../../assets/js/vendor/jquery.min.js"><\/script>')</script>
    <script src="../../dist/js/bootstrap.min.js"></script>
    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="../../assets/js/ie10-viewport-bug-workaround.js"></script>
  </body>
</html>

