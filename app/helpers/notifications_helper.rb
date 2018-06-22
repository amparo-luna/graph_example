require 'neatjson'

module NotificationsHelper
  def format_json_for_html(hash)
    JSON.neat_generate(hash)
  end
end
