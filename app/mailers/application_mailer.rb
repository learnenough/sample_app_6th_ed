class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('SMTP_FROM') { "noreply@example.com" }
  layout 'mailer'
end
