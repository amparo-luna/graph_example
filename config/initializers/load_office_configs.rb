config_file = "#{Rails.root}/config/office.yml"
office_config = YAML.load_file(config_file)[Rails.env].with_indifferent_access if File.exists?(config_file)

CLIENT_ID = office_config[:client_id]
CLIENT_SECRET = office_config[:client_secret]
NOTIFY_URL = office_config[:notify_url]
