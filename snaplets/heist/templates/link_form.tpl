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
