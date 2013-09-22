MAIL_SETTINGS = YAML.load(File.open(File.join(Rails.root, 'config', 'mail.yml')))

ActionMailer::Base.smtp_settings = MAIL_SETTINGS[Rails.env].symbolize_keys