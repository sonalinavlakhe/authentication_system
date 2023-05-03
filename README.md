# Authentication System

Custom authentication system for a Ruby on Rails application that
includes 

* Sign up

* Sign in

* Multi-factor authentication

* Forgot password

* Remember me

## Prerequisites

 1. Ruby (version ruby 2.7.7p221)
 2. Rails (version Rails 5.2.8.1)
 3. PostgreSQL (version psql (PostgreSQL) 14.7 (Homebrew))

## Configuration

   1. secret.yml.example

       Replace secret.yml.example to secret.yml 
       and respective twilio configuration, secret_key and username and password for email.
       
       1. Create secret key in rails
       
          ```
          rails secret
          
       2. Set up Twilio Account
          
          https://www.twilio.com/try-twilio

       3. Sending email through gmail account
       
          Follow this link to allow your gmail account to send email as Google blocks all suspicious login attempts. By using app password, we able to               solve the problem

          https://stackoverflow.com/questions/30331624/gmail-blocking-rails-app-from-sending-email
 
      ```
      development:
        secret_key_base: "secret_key_base"
        twilio_account_sid: "twilio_account_sid"
        twilio_auth_token: "twilio_auth_token"
        twilio_phone_number: "twilio_phone_number"
        user_name: "email_username"
        password: "email_password"

      test:
        secret_key_base: "secret_key_base"
        twilio_account_sid: "twilio_account_sid"
        twilio_auth_token: "twilio_auth_token"
        twilio_phone_number: "twilio_phone_number"
        user_name: "email_username"
        password: "email_password"
        
## Getting Started

  1. Clone the repository
  
      ```
      git clone https://github.com/sonalinavlakhe/authentication_system.git
      cd authentication_system
      
  2. Install dependencies
      
      ```
      bundle install
      
  3. Setup the database

      ```
      rails db:create
      rails db:migrate
      
  4. Start the server
      
      ```
      rails server
      
   5. Open a web browser and navigate to http://localhost:3000
   
## Run Test
 
 ```
  rspec spec/
 

