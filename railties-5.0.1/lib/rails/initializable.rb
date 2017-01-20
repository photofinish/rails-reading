require 'tsort'

module Rails
  module Initializable
    def self.included(base) #:nodoc:
      base.extend ClassMethods                                            # ClassMethods模块里的方法作为类方法
    end

    class Initializer
      attr_reader :name, :block

      def initialize(name, context, options, &block)
        options[:group] ||= :default
        @name, @context, @options, @block = name, context, options, block
      end

      def before
        @options[:before]
      end

      def after
        @options[:after]
      end

      def belongs_to?(group)
        @options[:group] == group || @options[:group] == :all
      end

      def run(*args)
        @context.instance_exec(*args, &block)
      end

      def bind(context)                                                              # 被绑定的 context 用于执行代码块
        return self if @context
        Initializer.new(@name, context, @options, &block)
      end
    end

    class Collection < Array
      include TSort

      alias :tsort_each_node :each
      def tsort_each_child(initializer, &block)                                      # 通过before after来制定依赖规则
        select { |i| i.before == initializer.name || i.name == initializer.after }.each(&block)
      end

      def +(other)
        Collection.new(to_a + other.to_a)
      end
    end

    def run_initializers(group=:default, *args)                                       # 执行initializers, 可指定group
      return if instance_variable_defined?(:@ran)                                     # 标识是否已执行过?
      initializers.tsort_each do |initializer|                                        # 使用拓扑排序来迭代
        initializer.run(*args) if initializer.belongs_to?(group)
      end
      @ran = true
    end

    def initializers
      @initializers ||= self.class.initializers_for(self)                             # 获取绑定上下文后的initializers
    end

    module ClassMethods
      def initializers                                                                # 初始化列表
        @initializers ||= Collection.new
      end

      def initializers_chain
        initializers = Collection.new
        ancestors.reverse_each do |klass|                                             # 从祖先开始自上往下获取 全部的initializers
          next unless klass.respond_to?(:initializers)
          initializers = initializers + klass.initializers
        end
        initializers
      end

      def initializers_for(binding)                                                    # 将祖先链中的initializers绑定上下文到参数
        Collection.new(initializers_chain.map { |i| i.bind(binding) })
      end

      def initializer(name, opts = {}, &blk)                                           # 传递代码块来新增一个initializer, 可指定 :before /:after
        raise ArgumentError, "A block must be passed when defining an initializer" unless blk
        opts[:after] ||= initializers.last.name unless initializers.empty? || initializers.find { |i| i.name == opts[:before] }
        initializers << Initializer.new(name, nil, opts, &blk)
      end
    end
  end
end
