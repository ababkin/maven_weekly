<apply template="base">
  <h3>Groups</h3>
  <groupLinkForms>
    <form class="form-inline" method="POST" action="/add-link">
      <div class="form-group">
        <label ><groupName/></label>
        <button type="submit" class="add_link_button btn-xs btn btn-default">Add to newsletter</button>
      </div>
      <input type="hidden" name="group_id" value="${groupId}"/>
      <input type="hidden" name="link"/>
    </form>
  </groupLinkForms>
</apply>

<script>
  $(document).ready(function(){
    var port = chrome.runtime.connect("ajhjpiboagkhffibgcipdcjfglnfieap");
    var currentUrl;
    port.onMessage.addListener(function(formValues){
      $.post("http://mavenweekly.com/add-link", formValues, function(responseBody){
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
