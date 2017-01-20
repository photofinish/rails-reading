module MyEngine
  class MyEngine < Rails::Engine
    # Add a load path for this specific Engine
    config.autoload_paths << File.expand_path("../lib/some/path", __FILE__)

    initializer "my_engine.add_middleware" do |app|
      app.middleware.use MyEngine::Middleware
    end

    # set up generators for engines
    config.generators do |g|
      g.orm             :active_record
      g.template_engine :erb
      g.test_framework  :test_unit
    end

    # set generators for an application
    config.app_generators.orm :datamapper

    # place your controllers in lib/controllers
    paths["app/controllers"] = "lib/controllers"
  end



  # warp a rack application
  class Engine < Rails::Engine
    endpoint MyRackApplication
  end

  # mount your engine in application's routes
  Rails.application.routes.draw do
    mount MyEngine::Engine => "/engine"
  end

  # use middleware
  middleware.use SomeMiddleware




  # do not use endpoint
  # ENGINE/config/routes.rb
  MyEngine::Engine.routes.draw do
    get "/" => "posts#index"
  end


  # TODO
end