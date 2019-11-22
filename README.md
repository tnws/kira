# Kira
A bot that lives in Slack  
(note: this code is old and may or may not work. Kira4 is in the works!)

#### How to setup
TODO: add information about wit.ai  
Kira is pretty easy to setup on your own. First, make sure you have `npm` installed. Then run `npm install` to install
all the dependencies required. Also make sure to install CoffeeScript by running `npm install -g coffee-script`. 

Then, create a file called `api.txt` in the root of the project. Place your Slack API token inside on line 1 and do not
create any other lines.

To start the bot, run `coffee begin.coffee`

#### How to develop
Inside the `details/kira.coffee` file, there are a couple vars that should help with debugging. First, the `name` var changes
which name Kira repsonds do (aka changing Kira to Samantha for instance). Also, there is a `debug` bool. When this is enabled, 
it will enable the bot to respond to itself (helpful if you are testing by making your account the bot) and also will limit its activity to
the `#bot-testing` channel. 
