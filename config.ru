require './lib/racker'
use Rack::Reloader
use Rack::Static, :urls => ["/stylesheets"], :root => "assets"
use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           secret: 'no secret'
run Racker