#railties

ARGV: 运行参数
RUBY_VERSION: ruby版本 ='2.3.1'
RUBY_ENGINE: ='ruby'
RUBY_RELEASE_DATE: ruby版本发布日期
RUBY_DESCRIPTION: ruby版本描述信息
Rails::VERSION::STRING: rails版本 ='5.0.1'
Rails.application.root: 项目根目录的Pathname

- rails plugin 命令会require'rails/commands/plugin'而不是'rails/commands/application'
- Array#drop(n) 返回移除前n个元素后的新数组, Array#take(n) 返回前n个元素形成的新数组
- Array#find查找第1个符合条件的元素, Array#reject返回移除特定元素后的数组. reject迭代, find二分. 如果只reject一个元素, 先find判断有没有
- 在~/.railsrc文件中配置template实现自定义Gemfile模板, 实质是将railsrc内容加到'rails new'命令中, 在命令中使用'--rc='来指定railsrc文件, 不指定会使用~/.railsrc文件.
- File.expand_path返回文件绝对路径
- Array#flat_map在map的基础上如果代码块返回的是数组会将数组展开1次,但只是1次, 例如[1,[2,3],[4,[5,6]]].flat_map{|n|n} = [1, 2, 3, 4, [5, 6]], 迭代3次
- rails使用File.readlines(File.expand_path('~/.railsrc')).flat_map(&:split)加载railsrc参数
- 编写终端程序/工具/命令: Thor , 对命令参数进行解析: OptionParser
- 运行rails命令时, 会向上查找. 所以可以在项目下任意路径使用命令
- Object#tap 接收一个代码块, 代码块有一个参数, 这个参数就是Object的self
- config/application.rb会在server启动前被require
- Inflector#demodulize返回去掉前缀后的模块名称
- rails server -d 不会打印日志
- rails通过检查pid文件'tmp/pids/server.pid'来判断是否已有相同的服务器已启动, 这个文件内容就是进程的pid
- config.ru '#\\'之后的代码会被OptionParser解析为Config最后会merge进options
- config.ru 里的代码会以Rack::Builder.new {" + config.ru + "}.to_app来执行
- ruby的autoload将module与path进行关联, module第一次使用时才会加载文件. rails对autoload进行扩展, 在config.eager_load = false时, 使用eager_load!可以让autoload的module也能立即加载
- rails中在某个模块加载后执行hook可使用LazyLoadHooks
- require 可以是绝对路径也可以是$LAOD_PATH($:)的相对路径, 而require_relative是取文件的相对路径
- rails启动, 会依次执行hook :before_configuration(默认空) :before_initialize(默认空) :action_view :after_initialize :action_cable
- Kernel#caller_locations 获取调用栈
- DemoRailsApp < Rails::Application < Rails::Engine < Rails::Railtie(include Initializable)
- TSort模块提供了拓扑排序与强连通分量!!!
- 需要制定对象初始化过程时, 请Initializable. 需要在启动rails项目做工作时, 请Railtie, 所有的Railtie都是单例模式
- railtie中可加入rake_tasks console runner generators
- instance_exec代码块的参数是方法的参数, instance_eval代码块的参数是self
- 有执行task的需求, 请Rake::DSL
- rails使用WEBrick::HTTPServer作为服务器, 启动服务器时调用start, 处理请求的逻辑在run的while循环内.处理每个请求都会调用service(req,res)方法


# TODO
## middleware
```ruby
def build_app(app)
    middleware[options[:environment]].reverse_each do |middleware|
        middleware = middleware.call(self) if middleware.respond_to?(:call)
        next unless middleware
        klass, *args = middleware
        app = klass.new(app, *args)
    end
    app
end
```
## Initializable

## Rails::Railtie

## Rails::Engine

## Rails::Application

## WEBrick::HTTPServer
启动服务器时, 在Rack::Handler::WEBrick.run中, 会实例化一个WEBrick::HTTPServer
- Rack::Handler::WEBrick.run: 
    1. 实例化一个WEBrick::HTTPServer
    2. 然后调用WEBrick::HTTPServer.mount把Rack::Handler::WEBrick与Rails::Application实例置入@mount_tab变量中
    3. 调用WEBrick::HTTPServer.start
- WEBrick::HTTPServer.start: 启动一个线程不断调用run方法

处理请求的逻辑在Rack::Handler::WEBrick.run
每有一个请求, WEBrick::HTTPServer#service(req,res)方法会被调用, 之后在用res.send_response(sock)发送响应
1. WEBrick::HTTPServer#service: 通过访问路径在@mount_tab获取Rack::Handler::WEBrick的单例, 调用Rack::Handler::WEBrick#service(req, res)
2. Rack::Handler::WEBrick#service: 将请求相关的信息封装在HTTPRequest实例env中, 调用status, headers, body = @app.call(env)