# Medivh

A real-time slack status board, using [elixir](http://elixir-lang.github.io/) and [elm](http://elm-lang.org/).

## Quick Start

The following steps will get you running:

  * `mix do deps.get, deps.compile`
  * `cd assets && npm install; cd ../`
  * Create your Slack token for the bot, and place it in `config/dev.secret.exs`. See [configuration](#configuration) for more details.
  * `mix phx.server`
  * Load up [`localhost:4000`](http://localhost:4000).


## Configuration

Create your `config/dev.secret.exs` with the following contents:

```elixir
use Mix.Config

config :medivh, MedivhWeb.Endpoint,
  secret_key_base: "onLgKir80FbMzkw3v3wzngDZmcbyBAzfiJlkWpZR6PPsYgN2L/pkB3LtBWwFluai"

config :medivh,
  slack_token: "<slack token value>""
```

## License (MIT)

Copyright (c) 2018 Matt McFarland

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
