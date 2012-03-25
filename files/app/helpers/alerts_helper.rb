module AlertsHelper
  # Twitter Bootstrap compatible alerts
  def render_alerts
    if alert
      render_alert('alert', alert)
    elsif notice
      render_alert('alert alert-success', notice)
    end
  end

  def render_alert(alert_classes, message)
    %Q{
<div class="#{alert_classes}">
  <a class="close" data-dismiss="alert">&times;</a>
  #{message}
</div>
    }.html_safe
  end
end