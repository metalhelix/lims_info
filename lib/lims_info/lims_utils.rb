
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
  end
end
