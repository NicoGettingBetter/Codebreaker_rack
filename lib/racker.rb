require_relative "codebreaker.rb"
require "erb"
 
class Racker
  def self.call(env)
      new(env).response.finish
    end

    def initialize(env)
      @request = Rack::Request.new(env)
    end
   
  def response
    case @request.path
    when "/" then render("index.html.erb")
    when "/start" then start
    when "/play" then play
    when "/game_over" then game_over
    when "/save" then save
    when "/hint" then get_hint
    else Rack::Response.new("Not Found", 404)
    end
  end

  def start
    @request.session.clear
    @request.session[:codebreaker] = Codebreaker::Game.new
    codebreaker.start
    redirect_to('/')
  end

  def play
    guess = @request.params['guess']
    @request.session[:result] = codebreaker.match_secret_code(guess)
    @request.session[:guess] = guess
    if (codebreaker.game_status)
      redirect_to('/game_over')
    else
      redirect_to('/')
    end
  end
 
  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    Rack::Response.new(ERB.new(File.read(path)).result(binding))
  end

  def guess
    @request.session[:guess]
  end

  def result
    @request.session[:result]
  end

  def redirect_to(path)
    Rack::Response.new { |response| response.redirect("#{path}") }
  end

  def codebreaker
    @request.session[:codebreaker]
  end

  def game_over
    render('game_over.html.erb')
  end

  def save
    codebreaker.save_result(@request.params['user_name'])
    redirect_to('/start')
  end

  def hint
    @request.session[:hint]
  end

  def score_table
    Codebreaker::Game.load_results
  end

  def get_hint
    @request.session[:hint] = codebreaker.hint unless hint
    redirect_to('/')
  end

  def count_of_try
    codebreaker.count_of_try - codebreaker.num_of_try
  end
end