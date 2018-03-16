module TasksHelper

  def task_status(task)
    case task.status
      when "open"
        "Open"
      when "in_progress"
        "In Progress"
      when "waiting"
        "Waiting"
      when "resolved"
        "Resolved"
    end
  end



end