require 'benchmark'
Capistrano::Configuration.class_eval do
  @@benchmarks = []
  def execute_task_with_benchmarking(task)
    if fetch(:benchmark, false)
      name = task.fully_qualified_name
      realtime = Benchmark.realtime do
        execute_task_without_benchmarking(task)
      end
      @@benchmarks << [name,realtime]

      logger.debug "Finished #{name} in #{realtime}"
    else
      execute_task_without_benchmarking(task)
    end
  end

  def self.benchmarks
    @@benchmarks
  end

  alias_method :execute_task_without_benchmarking, :execute_task
  alias_method :execute_task, :execute_task_with_benchmarking
end

Capistrano::Configuration.instance.load do
  namespace :benchmark do
    task :default do
      set :benchmark, true
    end

    task :report do
      puts "Benchmark Report:"
      benchmarks = Capistrano::Configuration.benchmarks
      max = benchmarks.collect{|x| x[0]}.max_by{|a| a.length}.length
      report_block = lambda do |data|
        name,took = data
        mins = '%.0f' % (took / 60)
        secs = '%.0f' % (took % 60)
        puts "  %-#{max}s : %2s mins and %2s secs" % [name,mins,secs]
      end

      puts "Ordered by deploy sequence:"
      benchmarks.each(&report_block)
      puts "Ordered by slowest:"
      benchmarks.sort_by {|x| x[1]}.reverse.each(&report_block)
    end
  end
end
