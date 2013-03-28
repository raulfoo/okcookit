require "pony"

module Email

  def send_email(to,subject,body,attachment)
   Pony.mail(
     :to => to,
     :from => "chris@socialteeth.org", 
     :via => :smtp,
     :attachments => {"MurderMystery.zip" => File.read(attachment)},
     #:attachments => {"MurderMystery.txt" => "Hello"},
     :via_options => {
       :address => "smtp.gmail.com",
       :port => "587",
       :enable_starttls_auto => true,
       :user_name => "chris@socialteeth.org",
       :password => EMAIL_PASSWORD,
       #:headers => { "Content-Type" => "text/html", "Content-Transfer-Encoding" => "base64", "Content-Disposition" => "attachment" },
       :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
     },
       :subject => subject, :html_body => body)
  end
end

