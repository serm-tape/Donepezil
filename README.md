# :pill: Donepezil :pill:

This is application for doing something with facebook w/o logging in but uses app access token instead.

## :city_sunrise: Build
To build, make sure you have Elixir installed then run `mix escript.build` and go :rocket:, your package will be there.

## :zap: Usage
This app need 1 args `--mode` which can be `image` `ff` and `reactions`. Then you will be asked for
- `app_id` your fb app id can be unpublished one
- `app_secret` your fb app secret according to your app_id
- `object url` url to facebook object, usually be post url

### image
`./donepezil --mode=image` save image comment from specific post.
*Example use case:*
- Facebook campaign that participants need to comment image or screen shot and admin can run this application to save image at once.
- Saving memes lol.

### ff
`./donepezil --mode=ff` find which comment your friend replied to. Just enter your friend name or comment message you want to find.
*Example use case:*
- Sometimes, in news feed there will be a feed like 'your friend reply to a a comment in that post' but you want to know which comment he/she replied to.

### reactions
`./donepezil --mode=reactions` to get all reactions on specific post return in csv.
*Example use case:*
- Marketing campaign that you want to pick a lucky one who react `LIKE|HAHA|SAD|ANGRY|...` to this post.

## TODO
[ ] ~~Make windows support~~

## Trivia
Donepezil is medicine for alzheimer