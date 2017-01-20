module MyGem
  class MyRailtie < Rails::Railtie
    initializer 'my_railtie.configure_rails_initialization' do
      # some initialization behavior
    end

    # or

    initializer 'my_railtie.configure_rails_initialization', before: 'other initializer name' do |app|
      app.middleware.use MyRailtie::Middleware
    end

    # Customize the ORM
    config.app_generators.orm :my_railtie_orm

    # Add a to_prepare block which is executed once in production
    # and before each request in development.
    config.to_prepare do
      MyRailtie.setup!
    end

    rake_tasks do                       # self执行
      load 'path/to/my_railtie.tasks'
    end

    generators do
      require 'path/to/my_railtie_generator'
    end

  end
end