## How to Setup

1. Run `export BUFFER_ACCESS_TOKEN=1/deadbeefbaffed` to make sure the
   `BUFFER_ACCESS_TOKEN` is set. Run `echo $BUFFER_ACCESS_TOKEN` to make
sure it is setup correctly.

Or, assuming that `BUFFER_ACCESS_TOKEN` is in your `.env`, run `export
$(cat .env)` before you run the command

2. Run `ruby buffer.rb <issue-number>` to buffer to Twitter
