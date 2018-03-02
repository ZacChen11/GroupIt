module TasksHelper

  def task_status(task)
    case task.status
      when 1
        "Opening"
      when 2
        "In Progress"
      when 3
        "Waiting"
      when 4
        "Resolved"
    end
  end

end