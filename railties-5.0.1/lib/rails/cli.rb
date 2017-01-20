require 'rails/app_loader'

# If we are inside a Rails application this method performs an exec and thus
# the rest of this script is not run.
Rails::AppLoader.exec_app                                         #

require 'rails/ruby_version_check'                                # 检查版本: rails 5.0.1 需要ruby版本 >= 2.2.2
Signal.trap("INT") { puts; exit(1) }                              # UNIX信号注册, 遇到INT信号时执行代码块: 输出, 退出

if ARGV.first == 'plugin'                                         # 运行参数第一个是'plugin'的话
  ARGV.shift
  require 'rails/commands/plugin'
else
  require 'rails/commands/application'
end


=begin TODO
require 'rails/app_loader'
Rails::AppLoader.exec_app



=end