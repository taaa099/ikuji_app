require "sidekiq-scheduler"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }

  schedule_file = "config/sidekiq.yml"
  if File.exist?(schedule_file) && Sidekiq.server?
    schedule = YAML.load_file(schedule_file)
    Sidekiq.schedule = schedule["schedule"] || schedule[:schedule]
    Sidekiq::Scheduler.enabled = true       # ← ここで有効化
    Sidekiq::Scheduler.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end
