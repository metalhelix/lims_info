
require 'mechanize'

module LimsInfo
  class LimsUtils
    # logs into lims using provided username and password
    def self.login username, password
      agent = Mechanize.new
      agent.user_agent_alias = 'Mac Safari'
      url = "http://limskc01/zanmodules/_site/index.php"

      page = agent.get(url)
      form = page.form_with :id => "auth"
      username_field = form.field_with(:name => "username")
      username_field.value = username

      password_field = form.field_with(:name => "password")
      password_field.value = password
      form.submit
      agent
    end

    # input is an agent that has already signed in
    # output is an array of hashes
    def self.user_list agent
      # a semi-random order. shouldn't matter which, right?
      # well it does matter - because different users have different levels
      # of access to lims pages
      #url = "http://limskc01/zanmodules/molbio/ngs_editOrder.php?o=10"
      # so lets try the new ordre page
      url = "http://limskc01/zanmodules/molbio/ngs_orderNew.php"

      # extra data is hidden in attributes of the options that are lost
      # when rendering the page.
      #
      # so - the .body method gives you the source of the page and we
      # parse manually to get at these extra values
      page = agent.get(url).body

      users = []

      # apparently this new line character works. didn't test much
      page.split("\n").each do |line|
        # extremely fragile Regex built off of this example:
        # <option value="2678"  firstName="" lastName="" loginName="CytoStaff">,  (CytoStaff)</option>
        if line =~ /\s*<option\s+value=\"(.*)\"\s+firstName=\"(.*)\"\s+lastName=\"(.*)\"\s+loginName=\"(.*)\">/
          user = {:id => $1, :first_name => $2, :last_name => $3, :login => $4}
          users << user
        end
      end
      users
    end
  end
end
