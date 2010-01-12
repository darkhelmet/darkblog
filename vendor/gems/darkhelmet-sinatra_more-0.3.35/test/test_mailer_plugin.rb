require 'helper'
require 'fixtures/mailer_app/app'

class TestMailerPlugin < Test::Unit::TestCase
  def app
    MailerDemo.tap { |app| app.set :environment, :test }
  end

  context 'for mail delivery in sample application' do
    setup { MailerDemo::SampleMailer.smtp_settings = MailerDemo.smtp_settings }

    should 'be able to deliver plain text emails' do
      assert_email_sent(:to => 'john@fake.com', :from => 'noreply@birthday.com', :via => :smtp,
                        :subject => "Happy Birthday!", :body => "Happy Birthday Joey! \nYou are turning 21")
      visit '/deliver/plain', :post
      assert_equal 'mail delivered', last_response.body
    end

    should 'be able to deliver html emails' do
      assert_email_sent(:to => 'julie@fake.com', :from => 'noreply@anniversary.com', :type => 'html', :via => :smtp,
                        :subject => "Happy anniversary!", :body => "<p>Yay Joey & Charlotte!</p>\n<p>You have been married 16 years</p>")
      visit '/deliver/html', :post
      assert_equal 'mail delivered', last_response.body
    end
  end

  protected

  def assert_email_sent(mail_attributes)
    delivery_attributes = mail_attributes.merge(:smtp => MailerDemo.smtp_settings)
    Sinatra::MailerPlugin::MailObject.any_instance.expects(:send_mail).with(delivery_attributes).once.returns(true)
  end
end
