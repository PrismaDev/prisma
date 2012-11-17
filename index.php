<?php
	$section = "main";
?>

<!DOCTYPE html>
<html>
	<head>
		<title>Prisma V2</title>
		<meta charset="utf-8" />

		<link href="//netdna.bootstrapcdn.com/twitter-bootstrap/2.2.1/css/bootstrap-combined.min.css" rel="stylesheet" />
		<link rel="stylesheet" href="//code.jquery.com/ui/1.9.1/themes/base/jquery-ui.css" />
		<link href="css/main.css" rel="stylesheet" type="text/css" />
	</head>

	<body>
		<?php
			$templatefile = "client/prisma-".$section.".template";
			require($templatefile);
		?>
		<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
		
		<script src="//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.2/underscore-min.js"></script>
		<script src="//cdnjs.cloudflare.com/ajax/libs/backbone.js/0.9.2/backbone-min.js"></script>
		
		<script src="//cdnjs.cloudflare.com/ajax/libs/datatables/1.9.4/jquery.dataTables.min.js"></script>
		<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.9.1/jquery-ui.min.js"></script>

		<script src="//netdna.bootstrapcdn.com/twitter-bootstrap/2.2.1/js/bootstrap.min.js"></script>

		<?php 
			$jsfile = "client/prisma-".$section.".js";
			echo '<script src="'.$jsfile.'"></script>';
		?>
	</body>
</html>
