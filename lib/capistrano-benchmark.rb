require 'benchmark'
Capistrano::Configuration.class_eval do
  def execute_task_with_benchmarking(task)
    if fetch(:benchmark, false)
      realtime = Benchmark.realtime do
        execute_task_without_benchmarking(task)
      end

      logger.debug "Finished #{task.fully_qualified_name} in #{realtime}"
    else
      execute_task_without_benchmarking(task)
    end
  end

  alias_method :execute_task_without_benchmarking, :execute_task
  alias_method :execute_task, :execute_task_with_benchmarking
end

task :benchmark do
  set :benchmark, true
end
