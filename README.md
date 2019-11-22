# Kira
A bot that lives in Slack  
(note: this codebase has been untouched for a while (2-3 years, if not more) now. A lot of module dependencies that Kira uses are now deprecated, or will not work as expected. A new version is in the works!)

Kira is powered by wit.ai's natural language processing. Therefore, every script inside is based on an "intent", and information passed back from the intent gathered by the wit.ai service. Ultimately, this code won't do much good on its own. Kira will only carry out an action if wit.ai and Kira are at least 75% confident that it's figured what the user meant correctly. Unfortunately, wit.ai is limited and will not allow me to make these intents and the wit.ai project public. Additionally, wit.ai has deprecated the legacy project. But, if you're interested in a behind the scenes, contact me.

#### How to setup
Kira is pretty easy to setup on your own. First, make sure you have `npm` installed. Then run `npm install` to install
all the dependencies required. Also make sure to install CoffeeScript by running `npm install -g coffee-script`. 

Then, create a file called `api.txt` in the root of the project. Place your Slack API token inside on line 1 and do not
create any other lines. Please note that certain scripts may need you to insert a service token for it to work correctly (Wordnik, Forecast.io, 

To start the bot, run `coffee begin.coffee`.

#### How to develop
Inside the `details/kira.coffee` file, there are a couple vars that should help with debugging. First, the `name` var changes
which name Kira repsonds do (aka changing Kira to Samantha for instance). Also, there is a `debug` bool. When this is enabled, 
it will enable the bot to respond to itself (helpful if you are testing by making using the same token as the bot) and also will limit its activity to a particular channel. 
