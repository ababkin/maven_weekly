<html>
  <head>
    <title>Snap web server</title>
    <link rel="stylesheet" type="text/css" href="/screen.css"/>
    <link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
    <script>
      $(document).ready(function(){
        var port = chrome.runtime.connect("oakegmlednpcfcjchpbgbimhgknflehc");
        var currentUrl;
        port.onMessage.addListener(function(formValues){
          $.post("http://localhost:8000/add-link", formValues, function(responseBody){
            $("#content").replaceWith(responseBody);
          }, "html");
        });

        $(".add_link_button").on("click", function(e){
          e.preventDefault();
          var formInputs = $(e.currentTarget).closest("form").children("input");
          var formValues = {};
          $.each(formInputs, function(index, input){
            var $input = $(input);
            var inputName = $input.attr("name");
            var inputValue = $input.val();
            formValues[inputName] = inputValue
          });
          retrieveCurrentUrlAndSubmitForm(formValues);
        });

        function retrieveCurrentUrlAndSubmitForm(formValues){ 
          port.postMessage(formValues);
        };
      });
    </script>
  </head>
  <body>
    <div class="container" id="content">
      <apply-content/>
    </div>
  </body>

</html>
